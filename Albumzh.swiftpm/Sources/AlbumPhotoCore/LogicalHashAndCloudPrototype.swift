import Foundation

// MARK: - Logical album fingerprint (3:DAT-020...3:DAT-027)

private struct AlbumLogicalProjection: Codable {
    let modelGeneration: String
    let schemaVersion: Int
    let name: String
    let coverSelection: CoverSelection
    let photoAssetIDs: [UUID]
    let photoAssets: [LogicalPhotoAssetMetadata]
    let pages: [PageSnapshot]
}

/// DAT-027 fingerprints logical originals, not operational display artifacts.
/// A regenerated RAW PNG may therefore change without creating a new logical
/// album revision as long as the exact original and its metadata are unchanged.
private struct LogicalPhotoAssetMetadata: Codable {
    let id: UUID
    let contentHash: String
    let mimeType: String
    let originalFilename: String?
    let pixelWidth: Int
    let pixelHeight: Int
    let byteCount: Int64
    let colorSpaceName: String?
    let isHDR: Bool
    let source: PhotoSource
    let importedAt: Date
    let capturedAt: Date?

    init(_ metadata: PhotoAssetMetadata) {
        id = metadata.id
        contentHash = metadata.contentHash
        mimeType = metadata.mimeType
        originalFilename = metadata.originalFilename
        pixelWidth = metadata.pixelWidth
        pixelHeight = metadata.pixelHeight
        byteCount = metadata.byteCount
        colorSpaceName = metadata.colorSpaceName
        isHDR = metadata.isHDR
        source = metadata.source
        importedAt = metadata.importedAt
        capturedAt = metadata.capturedAt
    }
}

public enum AlbumLogicalFingerprint {
    /// Returns the exact canonical bytes hashed for an album. Operational
    /// dates (`createdAt`, `updatedAt`, `trashedAt`) and library diagnostics
    /// are intentionally absent from the projection.
    public static func canonicalPayload(
        album: AlbumSnapshot,
        photoAssets: [PhotoAssetMetadata]
    ) throws -> Data {
        let byID = Dictionary(uniqueKeysWithValues: photoAssets.map { ($0.id, $0) })
        guard byID.count == photoAssets.count else {
            throw DomainValidationError.duplicateIdentifier("asset logique")
        }
        let ordered = album.photoAssetIDs.compactMap { byID[$0] }
        guard ordered.count == album.photoAssetIDs.count,
              Set(byID.keys) == Set(album.photoAssetIDs) else {
            throw DomainValidationError.invalidPhotoMetadata
        }
        let records = Dictionary(uniqueKeysWithValues: ordered.map {
            ($0.id, PhotoAssetRecord(albumID: album.id, metadata: $0))
        })
        for metadata in ordered { try DomainValidator.validate(metadata) }
        try DomainValidator.validate(album, recordsByID: records)
        return try CanonicalJSON.encode(AlbumLogicalProjection(
            modelGeneration: album.modelGeneration,
            schemaVersion: album.schemaVersion,
            name: album.name,
            coverSelection: album.coverSelection,
            photoAssetIDs: album.photoAssetIDs,
            photoAssets: ordered.map(LogicalPhotoAssetMetadata.init),
            pages: album.pages
        ))
    }

    public static func hash(
        album: AlbumSnapshot,
        photoAssets: [PhotoAssetMetadata]
    ) throws -> String {
        SHA256.hexDigest(try canonicalPayload(album: album, photoAssets: photoAssets))
    }
}

// MARK: - Cloud record granularity prototype (lot 0 / 3:SYN-001...3:SYN-007)

public enum CloudPrototypeRecordType: String, Codable, Sendable, Equatable, Hashable {
    case album
    case page
    case asset
    case blob
}

public enum CloudPrototypeMutationKind: String, Codable, Sendable, Equatable, Hashable {
    case upsert
    case delete
}

public struct CloudPrototypeRecord: Sendable, Equatable {
    public let type: CloudPrototypeRecordType
    public let mutation: CloudPrototypeMutationKind
    public let recordName: String
    public let canonicalPayload: Data
    public let payloadHash: String
    public let requiresExternalAsset: Bool

    public init(
        type: CloudPrototypeRecordType,
        mutation: CloudPrototypeMutationKind,
        recordName: String,
        canonicalPayload: Data
    ) {
        self.type = type
        self.mutation = mutation
        self.recordName = recordName
        self.canonicalPayload = canonicalPayload
        self.payloadHash = SHA256.hexDigest(canonicalPayload)
        self.requiresExternalAsset = canonicalPayload.count >= 750_000
    }
}

public struct CloudPrototypeBatch: Sendable, Equatable {
    public let records: [CloudPrototypeRecord]

    public init(records: [CloudPrototypeRecord]) {
        self.records = records
    }

    public var inlineByteCount: Int {
        records.reduce(into: 0) { total, record in
            if !record.requiresExternalAsset { total += record.canonicalPayload.count }
        }
    }
}

public struct CloudPrototypePlan: Sendable, Equatable {
    public let zoneName: String
    public let batches: [CloudPrototypeBatch]

    public init(zoneName: String = "AlbumZone", batches: [CloudPrototypeBatch]) {
        self.zoneName = zoneName
        self.batches = batches
    }

    public var records: [CloudPrototypeRecord] { batches.flatMap(\.records) }
}

/// Adapter boundary. The lot-1 app injects `DisabledCloudSyncService`; a
/// CloudKit-backed actor is intentionally deferred until the 1.1 lot.
public protocol CloudSyncService: Sendable {
    func enqueue(_ plan: CloudPrototypePlan) async throws
}

public actor DisabledCloudSyncService: CloudSyncService {
    public init() {}
    public func enqueue(_ plan: CloudPrototypePlan) async throws {}
}

public actor RecordingCloudSyncService: CloudSyncService {
    public private(set) var plans: [CloudPrototypePlan] = []

    public init() {}

    public func enqueue(_ plan: CloudPrototypePlan) async throws {
        plans.append(plan)
    }
}

private struct CloudAlbumPayload: Codable {
    let modelGeneration: String
    let schemaVersion: Int
    let id: UUID
    let name: String
    let coverSelection: CoverSelection
    let pageIDs: [UUID]
    let photoAssetIDs: [UUID]
    let createdAt: Date
    let updatedAt: Date
    let trashedAt: Date?
}

private struct CloudAssetPayload: Codable {
    let albumID: UUID
    let metadata: PhotoAssetMetadata
}

private struct CloudBlobPayload: Codable {
    let contentHash: String
    let byteCount: Int64
    let detectedContentType: String
}

private struct CloudDeletionPayload: Codable {
    let entityID: UUID
}

public enum CloudRecordPlanner {
    public static func fullPlan(
        album: AlbumSnapshot,
        photoAssets: [PhotoAssetMetadata],
        blobs: [AssetBlobIndexEntry]
    ) throws -> CloudPrototypePlan {
        var records = [try albumRecord(album)]
        records += try album.pages.map(pageRecord)
        records += try photoAssets.map { try assetRecord(albumID: album.id, metadata: $0) }
        let requiredHashes = Set(photoAssets.flatMap(\.durableContentHashes))
        let requiredBlobs = blobs.filter { requiredHashes.contains($0.contentHash) }
            .sorted { $0.contentHash < $1.contentHash }
        records += try requiredBlobs.map(blobRecord)
        return CloudPrototypePlan(batches: deterministicBatches(records))
    }

    /// Produces only the records whose independently synchronized content
    /// changed. An untouched page is never bundled with another page edit.
    public static func changes(
        from before: AlbumSnapshot,
        to after: AlbumSnapshot
    ) throws -> CloudPrototypePlan {
        guard before.id == after.id else {
            throw DomainValidationError.persistenceFailure("albums Cloud incompatibles")
        }
        var records: [CloudPrototypeRecord] = []
        let metadataChanged = before.name != after.name
            || before.coverSelection != after.coverSelection
            || before.pages.map(\.id) != after.pages.map(\.id)
            || before.photoAssetIDs != after.photoAssetIDs
            || before.updatedAt != after.updatedAt
            || before.trashedAt != after.trashedAt
        if metadataChanged { records.append(try albumRecord(after)) }

        let beforePages = Dictionary(uniqueKeysWithValues: before.pages.map { ($0.id, $0) })
        let afterPages = Dictionary(uniqueKeysWithValues: after.pages.map { ($0.id, $0) })
        for page in after.pages where beforePages[page.id] != page {
            records.append(try pageRecord(page))
        }
        for pageID in before.pages.map(\.id) where afterPages[pageID] == nil {
            let payload = try CanonicalJSON.encode(CloudDeletionPayload(entityID: pageID))
            records.append(CloudPrototypeRecord(
                type: .page,
                mutation: .delete,
                recordName: pageRecordName(pageID),
                canonicalPayload: payload
            ))
        }
        return CloudPrototypePlan(batches: deterministicBatches(records))
    }

    private static func albumRecord(_ album: AlbumSnapshot) throws -> CloudPrototypeRecord {
        let payload = try CanonicalJSON.encode(CloudAlbumPayload(
            modelGeneration: album.modelGeneration,
            schemaVersion: album.schemaVersion,
            id: album.id,
            name: album.name,
            coverSelection: album.coverSelection,
            pageIDs: album.pages.map(\.id),
            photoAssetIDs: album.photoAssetIDs,
            createdAt: album.createdAt,
            updatedAt: album.updatedAt,
            trashedAt: album.trashedAt
        ))
        return CloudPrototypeRecord(
            type: .album,
            mutation: .upsert,
            recordName: "album-\(album.id.uuidString.lowercased())",
            canonicalPayload: payload
        )
    }

    private static func pageRecord(_ page: PageSnapshot) throws -> CloudPrototypeRecord {
        CloudPrototypeRecord(
            type: .page,
            mutation: .upsert,
            recordName: pageRecordName(page.id),
            canonicalPayload: try CanonicalJSON.encode(page)
        )
    }

    private static func pageRecordName(_ pageID: UUID) -> String {
        "page-\(pageID.uuidString.lowercased())"
    }

    private static func assetRecord(
        albumID: UUID,
        metadata: PhotoAssetMetadata
    ) throws -> CloudPrototypeRecord {
        CloudPrototypeRecord(
            type: .asset,
            mutation: .upsert,
            recordName: "asset-\(metadata.id.uuidString.lowercased())",
            canonicalPayload: try CanonicalJSON.encode(CloudAssetPayload(
                albumID: albumID,
                metadata: metadata
            ))
        )
    }

    private static func blobRecord(_ blob: AssetBlobIndexEntry) throws -> CloudPrototypeRecord {
        CloudPrototypeRecord(
            type: .blob,
            mutation: .upsert,
            recordName: "blob-\(blob.contentHash)",
            canonicalPayload: try CanonicalJSON.encode(CloudBlobPayload(
                contentHash: blob.contentHash,
                byteCount: blob.byteCount,
                detectedContentType: blob.detectedContentType
            ))
        )
    }

    private static func deterministicBatches(
        _ input: [CloudPrototypeRecord]
    ) -> [CloudPrototypeBatch] {
        let records = input.sorted {
            if $0.type.rawValue != $1.type.rawValue {
                return $0.type.rawValue < $1.type.rawValue
            }
            return $0.recordName < $1.recordName
        }
        var batches: [[CloudPrototypeRecord]] = []
        var current: [CloudPrototypeRecord] = []
        var inlineBytes = 0
        for record in records {
            let addition = record.requiresExternalAsset ? 0 : record.canonicalPayload.count
            if !current.isEmpty && (current.count == 200 || inlineBytes + addition > 1_000_000) {
                batches.append(current)
                current = []
                inlineBytes = 0
            }
            current.append(record)
            inlineBytes += addition
        }
        if !current.isEmpty { batches.append(current) }
        return batches.map(CloudPrototypeBatch.init(records:))
    }
}
