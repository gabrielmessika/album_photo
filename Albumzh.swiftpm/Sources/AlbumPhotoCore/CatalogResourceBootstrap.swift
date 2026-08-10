import Foundation

public struct CatalogResourceBootstrapInput: Sendable, Equatable {
    public let catalogID: String
    public let catalogVersion: Int
    public let data: Data
    public let detectedContentType: String

    public init(
        catalogID: String,
        catalogVersion: Int = 1,
        data: Data,
        detectedContentType: String
    ) {
        self.catalogID = catalogID
        self.catalogVersion = catalogVersion
        self.data = data
        self.detectedContentType = detectedContentType
    }
}

/// Coordinates bundle-byte validation, immutable storage and one atomic index
/// commit. A failure can leave only an unreferenced immutable blob, never a
/// dangling logical reference; retry is content- and command-idempotent.
public actor CatalogResourceBootstrapService {
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
    public func bootstrap(
        _ inputs: [CatalogResourceBootstrapInput],
        commandID: UUID = UUID()
    ) async throws -> [AssetBlobIndexEntry] {
        guard !inputs.isEmpty else { return [] }
        var validated: [(CatalogResourceBootstrapInput, String, Int64)] = []
        for input in inputs {
            guard let descriptor = BuiltInCatalogRegistry.descriptor(
                id: input.catalogID,
                version: input.catalogVersion
            ), case let .asset(expectedHash, expectedMIMEType, expectedByteCount)
                = descriptor.payload,
                  input.detectedContentType.lowercased() == expectedMIMEType.lowercased(),
                  Int64(input.data.count) == expectedByteCount,
                  SHA256.hexDigest(input.data) == expectedHash else {
                throw DomainValidationError.invalidCatalogReference(input.catalogID)
            }
            validated.append((input, expectedHash, expectedByteCount))
        }

        var entries: [AssetBlobIndexEntry] = []
        for (input, expectedHash, expectedByteCount) in validated {
            let stored = try await assetStore.store(
                data: input.data,
                detectedContentType: input.detectedContentType
            )
            guard stored.contentHash == expectedHash,
                  stored.byteCount == expectedByteCount else {
                throw DomainValidationError.invalidBlobIndex(expectedHash)
            }
            entries.append(stored)
        }
        return try await applicationService.registerCatalogBlobs(
            entries,
            commandID: commandID
        )
    }
}
