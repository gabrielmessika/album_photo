import Foundation

/// Coordinates the physical integrity preflight required immediately before
/// creating independent logical assets in another album (3:PHO-016...018,
/// 3:LOC-012). The application service still revalidates both albums and
/// commits every destination asset in one idempotent transaction.
public actor VerifiedPhotoReuseCoordinator {
    private let assetStore: ContentAddressedAssetStore
    private let applicationService: AlbumApplicationService

    public init(
        assetStore: ContentAddressedAssetStore,
        applicationService: AlbumApplicationService
    ) {
        self.assetStore = assetStore
        self.applicationService = applicationService
    }

    @discardableResult
    public func reusePhotos(
        assetIDs: [UUID],
        from sourceAlbumID: UUID,
        to targetAlbumID: UUID,
        newAssetIDs: [UUID]? = nil,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> [PhotoAssetMetadata] {
        let snapshot = try await applicationService.snapshot()
        guard let source = snapshot.album(id: sourceAlbumID), !source.isTrashed else {
            throw DomainValidationError.albumNotFound(sourceAlbumID)
        }
        let metadataByID = Dictionary(uniqueKeysWithValues: snapshot
            .photoAssets(in: sourceAlbumID).map { ($0.id, $0) })
        let blobByHash = Dictionary(uniqueKeysWithValues: snapshot.blobIndex.map {
            ($0.contentHash, $0)
        })
        for assetID in assetIDs {
            guard source.photoAssetIDs.contains(assetID),
                  let metadata = metadataByID[assetID] else {
                throw DomainValidationError.assetNotFound(assetID)
            }
            var representations = [(
                hash: metadata.contentHash,
                byteCount: metadata.byteCount,
                mimeType: metadata.mimeType
            )]
            if let derivative = metadata.displayDerivative {
                representations.append((
                    derivative.contentHash,
                    derivative.byteCount,
                    derivative.mimeType
                ))
            }
            for representation in representations {
                guard let blob = blobByHash[representation.hash],
                      blob.state == .available,
                      blob.byteCount == representation.byteCount,
                      blob.detectedContentType.lowercased()
                        == representation.mimeType.lowercased() else {
                    throw DomainValidationError.assetNotFound(assetID)
                }
                try await assetStore.verifyPhysicalBlob(
                    contentHash: representation.hash,
                    expectedByteCount: representation.byteCount
                )
            }
        }
        return try await applicationService.reusePhotos(
            assetIDs: assetIDs,
            from: sourceAlbumID,
            to: targetAlbumID,
            newAssetIDs: newAssetIDs,
            now: now,
            commandID: commandID
        )
    }
}
