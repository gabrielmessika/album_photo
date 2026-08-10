import Foundation

public struct PersistedTransaction: Codable, Sendable, Equatable {
    public let commandID: UUID
    public let expectedRevision: UInt64
    public let resultingSnapshot: LocalLibrarySnapshot

    public init(
        commandID: UUID,
        expectedRevision: UInt64,
        resultingSnapshot: LocalLibrarySnapshot
    ) {
        self.commandID = commandID
        self.expectedRevision = expectedRevision
        self.resultingSnapshot = resultingSnapshot
    }
}

public protocol LibraryRepository: Sendable {
    func load() async throws -> LocalLibrarySnapshot
    func commit(_ transaction: PersistedTransaction) async throws
    func flush() async throws
}

public enum PersistenceCheckpoint: String, Codable, Sendable, Equatable, Hashable {
    case afterGenerationRootPrepared
    case afterGenerationRootPublish
    case afterJournalWrite
    case afterSnapshotReplace
    case beforeJournalCleanup
    case afterAssetStaging
    case afterAssetValidation
    case afterBlobMove
}

public protocol PersistenceFaultInjector: Sendable {
    func hit(_ checkpoint: PersistenceCheckpoint) throws
}

public struct NoPersistenceFaults: PersistenceFaultInjector {
    public init() {}
    public func hit(_ checkpoint: PersistenceCheckpoint) throws {}
}

public struct FailingPersistenceInjector: PersistenceFaultInjector {
    public let checkpoint: PersistenceCheckpoint

    public init(checkpoint: PersistenceCheckpoint) {
        self.checkpoint = checkpoint
    }

    public func hit(_ checkpoint: PersistenceCheckpoint) throws {
        if self.checkpoint == checkpoint {
            throw DomainValidationError.injectedFailure(checkpoint.rawValue)
        }
    }
}

public actor InMemoryLibraryRepository: LibraryRepository {
    private var snapshot: LocalLibrarySnapshot

    public init(snapshot: LocalLibrarySnapshot = .empty) {
        self.snapshot = snapshot
    }

    public func load() throws -> LocalLibrarySnapshot {
        snapshot
    }

    public func commit(_ transaction: PersistedTransaction) throws {
        if snapshot.appliedCommandIDs.contains(transaction.commandID) { return }
        guard transaction.expectedRevision == snapshot.revision else {
            throw DomainValidationError.staleRevision(
                expected: transaction.expectedRevision,
                actual: snapshot.revision
            )
        }
        guard transaction.resultingSnapshot.revision == transaction.expectedRevision + 1,
              transaction.resultingSnapshot.appliedCommandIDs.contains(transaction.commandID) else {
            throw DomainValidationError.persistenceFailure("transaction non idempotente")
        }
        try DomainValidator.validate(transaction.resultingSnapshot)
        snapshot = transaction.resultingSnapshot
    }

    public func flush() {}
}

/// JSON transaction repository used by the lot-1 implementation.
/// A complete post-command image in `Journal/pending.json` makes replay
/// deterministic and idempotent without decoding any 2.1 store.
public actor TransactionalJSONLibraryRepository: LibraryRepository {
    private struct Header: Decodable {
        let modelGeneration: String
        let schemaVersion: Int
    }

    private let rootURL: URL
    private let databaseDirectoryURL: URL
    private let journalDirectoryURL: URL
    private let storeURL: URL
    private let pendingURL: URL
    private let fileManager: FileManager
    private let injector: any PersistenceFaultInjector

    public init(
        directoryURL: URL,
        fileManager: FileManager = .default,
        faultInjector: any PersistenceFaultInjector = NoPersistenceFaults()
    ) {
        self.rootURL = directoryURL
        self.databaseDirectoryURL = directoryURL.appendingPathComponent("Database", isDirectory: true)
        self.journalDirectoryURL = directoryURL.appendingPathComponent("Journal", isDirectory: true)
        self.storeURL = databaseDirectoryURL.appendingPathComponent("library-v1.json")
        self.pendingURL = journalDirectoryURL.appendingPathComponent("pending.json")
        self.fileManager = fileManager
        self.injector = faultInjector
    }

    public init(
        storageRoot: AlbumPhotoStorageRoot,
        fileManager: FileManager = .default,
        faultInjector: any PersistenceFaultInjector = NoPersistenceFaults()
    ) {
        self.init(
            directoryURL: storageRoot.url,
            fileManager: fileManager,
            faultInjector: faultInjector
        )
    }

    public func load() throws -> LocalLibrarySnapshot {
        try ensureDirectories()
        var snapshot = try readSnapshot()
        if fileManager.fileExists(atPath: pendingURL.path) {
            let transaction = try JSONDecoder.albumPhotoDecoder.decode(
                PersistedTransaction.self,
                from: Data(contentsOf: pendingURL)
            )
            if snapshot.appliedCommandIDs.contains(transaction.commandID) {
                discardPublishedJournalIfPossible()
            } else {
                guard transaction.expectedRevision == snapshot.revision else {
                    throw DomainValidationError.staleRevision(
                        expected: transaction.expectedRevision,
                        actual: snapshot.revision
                    )
                }
                try validate(transaction: transaction)
                try writeSnapshot(transaction.resultingSnapshot)
                snapshot = transaction.resultingSnapshot
                // From this point the transaction is committed. Journal
                // cleanup is housekeeping and cannot turn durable success into
                // a reported failure (3:LOC-011...3:LOC-014).
                discardPublishedJournalIfPossible()
            }
        }
        return snapshot
    }

    public func commit(_ transaction: PersistedTransaction) throws {
        try ensureDirectories()
        let current = try load()
        if current.appliedCommandIDs.contains(transaction.commandID) { return }
        guard transaction.expectedRevision == current.revision else {
            throw DomainValidationError.staleRevision(
                expected: transaction.expectedRevision,
                actual: current.revision
            )
        }
        try validate(transaction: transaction)
        try CanonicalJSON.encode(transaction).write(to: pendingURL, options: .atomic)
        try injector.hit(.afterJournalWrite)
        try writeSnapshot(transaction.resultingSnapshot)
        do {
            try injector.hit(.afterSnapshotReplace)
            try injector.hit(.beforeJournalCleanup)
        } catch {
            // `writeSnapshot` has already atomically published the complete
            // post-command image. Leave the redundant journal for the next
            // load, but report success so the same application-service
            // instance records its undo command and can retry idempotently.
            return
        }
        discardPublishedJournalIfPossible()
    }

    public func flush() throws {
        _ = try load()
    }

    private func validate(transaction: PersistedTransaction) throws {
        guard transaction.resultingSnapshot.revision == transaction.expectedRevision + 1,
              transaction.resultingSnapshot.appliedCommandIDs.contains(transaction.commandID) else {
            throw DomainValidationError.persistenceFailure("transaction non idempotente")
        }
        try DomainValidator.validate(transaction.resultingSnapshot)
    }

    private func ensureDirectories() throws {
        // The caller supplies the generation-3 root. No sibling or legacy path
        // is inspected (3:LOC-029...3:LOC-031).
        try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: databaseDirectoryURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: journalDirectoryURL, withIntermediateDirectories: true)
    }

    private func readSnapshot() throws -> LocalLibrarySnapshot {
        guard fileManager.fileExists(atPath: storeURL.path) else {
            let empty = LocalLibrarySnapshot.empty
            try writeSnapshot(empty)
            return empty
        }
        let data = try Data(contentsOf: storeURL)
        let header = try JSONDecoder.albumPhotoDecoder.decode(Header.self, from: data)
        guard header.modelGeneration == AlbumModelVersion.generation else {
            throw DomainValidationError.unsupportedGeneration(header.modelGeneration)
        }
        guard header.schemaVersion == AlbumModelVersion.schemaVersion else {
            throw DomainValidationError.unsupportedSchema(header.schemaVersion)
        }
        let snapshot = try JSONDecoder.albumPhotoDecoder.decode(LocalLibrarySnapshot.self, from: data)
        try DomainValidator.validate(snapshot)
        return snapshot
    }

    private func writeSnapshot(_ snapshot: LocalLibrarySnapshot) throws {
        try CanonicalJSON.encode(snapshot).write(to: storeURL, options: .atomic)
    }

    private func discardPublishedJournalIfPossible() {
        guard fileManager.fileExists(atPath: pendingURL.path) else { return }
        try? fileManager.removeItem(at: pendingURL)
    }
}

public struct AssetBlobImport: Sendable, Equatable {
    public let entry: AssetBlobIndexEntry
    public let wasDeduplicated: Bool

    public init(entry: AssetBlobIndexEntry, wasDeduplicated: Bool) {
        self.entry = entry
        self.wasDeduplicated = wasDeduplicated
    }
}

/// Immutable content-addressed files. Image decoding and static-format
/// inspection stay in an injected Apple adapter; this actor owns copying,
/// hashing, deduplication and resolution.
public actor ContentAddressedAssetStore {
    private let rootURL: URL
    private let assetsURL: URL
    private let stagingURL: URL
    private let fileManager: FileManager
    private let injector: any PersistenceFaultInjector

    public init(
        directoryURL: URL,
        fileManager: FileManager = .default,
        faultInjector: any PersistenceFaultInjector = NoPersistenceFaults()
    ) {
        self.rootURL = directoryURL
        self.assetsURL = directoryURL.appendingPathComponent("Assets", isDirectory: true)
        self.stagingURL = directoryURL.appendingPathComponent("Staging", isDirectory: true)
        self.fileManager = fileManager
        self.injector = faultInjector
    }

    public init(
        storageRoot: AlbumPhotoStorageRoot,
        fileManager: FileManager = .default,
        faultInjector: any PersistenceFaultInjector = NoPersistenceFaults()
    ) {
        self.init(
            directoryURL: storageRoot.url,
            fileManager: fileManager,
            faultInjector: faultInjector
        )
    }

    public func importFile(
        at sourceURL: URL,
        detectedContentType: String
    ) throws -> AssetBlobIndexEntry {
        try importFileDetailed(at: sourceURL, detectedContentType: detectedContentType).entry
    }

    public func importFileDetailed(
        at sourceURL: URL,
        detectedContentType: String
    ) throws -> AssetBlobImport {
        try ensureDirectories()
        let stagingFile = stagingURL.appendingPathComponent(UUID().uuidString.lowercased())
        try fileManager.copyItem(at: sourceURL, to: stagingFile)
        return try finalizeStagedFile(stagingFile, detectedContentType: detectedContentType)
    }

    public func store(
        data: Data,
        detectedContentType: String
    ) throws -> AssetBlobIndexEntry {
        try storeDetailed(data: data, detectedContentType: detectedContentType).entry
    }

    public func storeDetailed(
        data: Data,
        detectedContentType: String
    ) throws -> AssetBlobImport {
        try ensureDirectories()
        guard !data.isEmpty, !detectedContentType.isEmpty else {
            throw DomainValidationError.invalidPhotoMetadata
        }
        let stagingFile = stagingURL.appendingPathComponent(UUID().uuidString.lowercased())
        try data.write(to: stagingFile, options: .atomic)
        return try finalizeStagedFile(stagingFile, detectedContentType: detectedContentType)
    }

    public func url(for contentHash: String) -> URL? {
        let value = assetsURL.appendingPathComponent("sha256-\(contentHash)")
        return fileManager.fileExists(atPath: value.path) ? value : nil
    }

    public func data(for contentHash: String) throws -> Data {
        guard let url = url(for: contentHash) else {
            throw DomainValidationError.invalidBlobIndex(contentHash)
        }
        let data = try Data(contentsOf: url)
        guard SHA256.hexDigest(data) == contentHash else {
            throw DomainValidationError.invalidBlobIndex(contentHash)
        }
        return data
    }

    /// Verifies the physical blob in a bounded-memory pass. Both the bytes
    /// read and their count must match the persisted content-addressed entry.
    @discardableResult
    public func verifyPhysicalBlob(
        contentHash: String,
        expectedByteCount: Int64,
        chunkSize: Int = SHA256.defaultFileChunkSize
    ) throws -> SHA256FileFingerprint {
        guard expectedByteCount >= 0,
              let url = url(for: contentHash) else {
            throw DomainValidationError.invalidBlobIndex(contentHash)
        }
        let fingerprint = try SHA256.fingerprint(
            fileAt: url,
            chunkSize: chunkSize
        )
        guard fingerprint.contentHash == contentHash,
              fingerprint.byteCount == expectedByteCount else {
            throw DomainValidationError.invalidBlobIndex(contentHash)
        }
        return fingerprint
    }

    public func contains(_ contentHash: String) -> Bool {
        url(for: contentHash) != nil
    }

    public func cleanStaging() throws {
        try ensureDirectories()
        for url in try fileManager.contentsOfDirectory(
            at: stagingURL,
            includingPropertiesForKeys: nil
        ) {
            try? fileManager.removeItem(at: url)
        }
    }

    private func finalizeStagedFile(
        _ stagingFile: URL,
        detectedContentType: String
    ) throws -> AssetBlobImport {
        defer { try? fileManager.removeItem(at: stagingFile) }
        try injector.hit(.afterAssetStaging)
        guard !detectedContentType.isEmpty else {
            throw DomainValidationError.invalidPhotoMetadata
        }
        let fingerprint = try SHA256.fingerprint(fileAt: stagingFile)
        guard fingerprint.byteCount > 0 else {
            throw DomainValidationError.invalidPhotoMetadata
        }
        let hash = fingerprint.contentHash
        let destination = assetsURL.appendingPathComponent("sha256-\(hash)")
        try injector.hit(.afterAssetValidation)
        var deduplicated = false
        if fileManager.fileExists(atPath: destination.path) {
            try verifyPhysicalBlob(
                contentHash: hash,
                expectedByteCount: fingerprint.byteCount
            )
            deduplicated = true
        } else {
            try fileManager.moveItem(at: stagingFile, to: destination)
        }
        try injector.hit(.afterBlobMove)
        return AssetBlobImport(
            entry: AssetBlobIndexEntry(
                contentHash: hash,
                relativePath: "Assets/sha256-\(hash)",
                byteCount: fingerprint.byteCount,
                detectedContentType: detectedContentType,
                referenceCount: 0,
                state: .available
            ),
            wasDeduplicated: deduplicated
        )
    }

    private func ensureDirectories() throws {
        try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: assetsURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: stagingURL, withIntermediateDirectories: true)
    }
}
