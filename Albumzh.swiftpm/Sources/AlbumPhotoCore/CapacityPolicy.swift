import Foundation

public enum AlbumCapacityElementKind: String, Sendable, Equatable, Hashable {
    case photo
    case text
    case sticker
}

public enum AlbumCapacityWarning: Sendable, Equatable, Hashable {
    case pageCount(actual: Int, guaranteed: Int)
    case albumByteCount(actual: Int64, guaranteed: Int64)
    case elementCount(
        pageID: UUID,
        kind: AlbumCapacityElementKind,
        actual: Int,
        guaranteed: Int
    )
}

/// Centralized, non-blocking envelope diagnostics for 3:PAG-012,
/// 3:LOC-017, 3:LOC-018 and 3:PERF-015.
public enum AlbumCapacityPolicy {
    public static let guaranteedPageCount = 100
    public static let guaranteedElementCountPerKindAndPage = 20
    public static let guaranteedAlbumByteCount: Int64 = 5_000_000_000

    public static func warnings(
        for album: AlbumSnapshot,
        photoAssets: [PhotoAssetMetadata]
    ) -> [AlbumCapacityWarning] {
        var result: [AlbumCapacityWarning] = []

        if album.pages.count > guaranteedPageCount {
            result.append(.pageCount(
                actual: album.pages.count,
                guaranteed: guaranteedPageCount
            ))
        }

        for page in album.pages {
            let counts = page.elements.reduce(
                into: [AlbumCapacityElementKind: Int]()
            ) { partial, element in
                let kind: AlbumCapacityElementKind
                switch element {
                case .photo: kind = .photo
                case .text: kind = .text
                case .sticker: kind = .sticker
                }
                partial[kind, default: 0] += 1
            }
            for kind in [
                AlbumCapacityElementKind.photo,
                .text,
                .sticker
            ] where counts[kind, default: 0] > guaranteedElementCountPerKindAndPage {
                result.append(.elementCount(
                    pageID: page.id,
                    kind: kind,
                    actual: counts[kind, default: 0],
                    guaranteed: guaranteedElementCountPerKindAndPage
                ))
            }
        }

        let albumAssetIDs = Set(album.photoAssetIDs)
        var byteCountByHash: [String: Int64] = [:]
        for metadata in photoAssets where albumAssetIDs.contains(metadata.id) {
            byteCountByHash[metadata.contentHash] = max(
                byteCountByHash[metadata.contentHash] ?? 0,
                metadata.byteCount
            )
            if let derivative = metadata.displayDerivative {
                byteCountByHash[derivative.contentHash] = max(
                    byteCountByHash[derivative.contentHash] ?? 0,
                    derivative.byteCount
                )
            }
        }
        for reference in catalogReferences(in: album) {
            guard let descriptor = BuiltInCatalogRegistry.descriptor(
                id: reference.catalogID,
                version: reference.catalogVersion
            ), case let .asset(contentHash, _, byteCount) = descriptor.payload else {
                continue
            }
            byteCountByHash[contentHash] = max(
                byteCountByHash[contentHash] ?? 0,
                byteCount
            )
        }
        let albumByteCount = byteCountByHash.values.reduce(Int64(0)) { partial, value in
            let (sum, overflow) = partial.addingReportingOverflow(value)
            return overflow ? Int64.max : sum
        }
        if albumByteCount > guaranteedAlbumByteCount {
            result.append(.albumByteCount(
                actual: albumByteCount,
                guaranteed: guaranteedAlbumByteCount
            ))
        }

        return result
    }

    private static func catalogReferences(
        in album: AlbumSnapshot
    ) -> [CatalogResourceReference] {
        album.pages.flatMap { page in
            var references: [CatalogResourceReference] = []
            if case let .catalog(reference) = page.background {
                references.append(reference)
            }
            for element in page.elements {
                switch element {
                case let .photo(frame):
                    references.append(frame.mask.shape)
                    if let decorativeFrame = frame.decorativeFrame {
                        references.append(decorativeFrame)
                    }
                case let .sticker(sticker):
                    references.append(sticker.resource)
                case .text:
                    break
                }
            }
            return references
        }
    }
}
