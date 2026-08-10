import Foundation
import XCTest
@testable import AlbumPhotoCore

enum TestFixtures {
    static let albumID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let pageID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let assetID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let elementID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let date = Date(timeIntervalSince1970: 1_700_000_000.123)

    static func data(_ marker: String = "photo") -> Data {
        Data(marker.utf8)
    }

    static func blob(
        data: Data = data(),
        mimeType: String = "image/jpeg"
    ) -> AssetBlobIndexEntry {
        let hash = SHA256.hexDigest(data)
        return AssetBlobIndexEntry(
            contentHash: hash,
            relativePath: "Assets/sha256-\(hash)",
            byteCount: Int64(data.count),
            detectedContentType: mimeType
        )
    }

    static func metadata(
        id: UUID = assetID,
        data: Data = data(),
        mimeType: String = "image/jpeg",
        width: Int = 2_400,
        height: Int = 1_800,
        source: PhotoSource = .files,
        displayDerivative: PhotoDisplayDerivative? = nil
    ) -> PhotoAssetMetadata {
        PhotoAssetMetadata(
            id: id,
            contentHash: SHA256.hexDigest(data),
            mimeType: mimeType,
            originalFilename: "fixture.jpg",
            pixelWidth: width,
            pixelHeight: height,
            byteCount: Int64(data.count),
            colorSpaceName: "sRGB",
            source: source,
            importedAt: date,
            capturedAt: date.addingTimeInterval(-100),
            displayDerivative: displayDerivative
        )
    }

    static func displayDerivative(
        data: Data = data("raw display png"),
        width: Int = 1_600,
        height: Int = 1_200
    ) -> PhotoDisplayDerivative {
        PhotoDisplayDerivative(
            contentHash: SHA256.hexDigest(data),
            pixelWidth: width,
            pixelHeight: height,
            byteCount: Int64(data.count)
        )
    }

    static func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("album-photo-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func service() -> AlbumApplicationService {
        AlbumApplicationService(repository: InMemoryLibraryRepository(
            snapshot: LocalLibrarySnapshot(blobIndex: catalogBlobEntries)
        ))
    }

    static var catalogBlobEntries: [AssetBlobIndexEntry] {
        BuiltInCatalogRegistry.entries.compactMap { descriptor in
            guard case let .asset(hash, mimeType, byteCount) = descriptor.payload else {
                return nil
            }
            return AssetBlobIndexEntry(
                contentHash: hash,
                relativePath: "Assets/sha256-\(hash)",
                byteCount: byteCount,
                detectedContentType: mimeType,
                referenceCount: 1,
                state: .available
            )
        }
    }

    static func albumWithRegisteredPhoto(
        service: AlbumApplicationService,
        albumID: UUID = albumID,
        pageID: UUID = pageID,
        assetID: UUID = assetID,
        data: Data = data(),
        width: Int = 2_400,
        height: Int = 1_800
    ) async throws -> (AlbumSnapshot, PhotoAssetMetadata) {
        _ = try await service.createAlbum(
            named: "Guatemala",
            id: albumID,
            firstPageID: pageID,
            now: date
        )
        let metadata = metadata(
            id: assetID,
            data: data,
            width: width,
            height: height
        )
        let album = try await service.registerPhoto(
            metadata,
            blob: blob(data: data),
            in: albumID,
            now: date.addingTimeInterval(1)
        )
        return (album, metadata)
    }
}

func XCTAssertThrowsDomainError<T>(
    _ expression: () async throws -> T,
    matching predicate: (DomainValidationError) -> Bool,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Une erreur de domaine était attendue", file: file, line: line)
    } catch let error as DomainValidationError {
        XCTAssertTrue(predicate(error), "Erreur inattendue : \(error)", file: file, line: line)
    } catch {
        XCTFail("Type d’erreur inattendu : \(error)", file: file, line: line)
    }
}

struct PredictableRandomNumberGenerator: RandomNumberGenerator {
    private var values: [UInt64]
    private var index = 0

    init(_ values: [UInt64]) {
        self.values = values.isEmpty ? [0] : values
    }

    mutating func next() -> UInt64 {
        defer { index += 1 }
        return values[index % values.count]
    }
}
