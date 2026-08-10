import Foundation
import XCTest
@testable import AlbumPhotoCore

final class VerifiedPhotoReuseTests: XCTestCase {
    private func setup(
        data: Data = TestFixtures.data("verified reuse")
    ) async throws -> (
        AlbumApplicationService,
        AlbumSnapshot,
        AlbumSnapshot,
        PhotoAssetMetadata,
        Data
    ) {
        let service = TestFixtures.service()
        let (source, metadata) = try await TestFixtures.albumWithRegisteredPhoto(
            service: service,
            data: data
        )
        let target = try await service.createAlbum(named: "Cible")
        return (service, source, target, metadata, data)
    }

    private func multiChunkData() -> Data {
        Data((0..<(SHA256.defaultFileChunkSize + 257)).map {
            UInt8(truncatingIfNeeded: ($0 &* 29) &+ 11)
        })
    }

    // 3:PHO-016...3:PHO-018, 3:LOC-012
    func testVerifiedReuseChecksBytesThenCreatesIndependentLogicalAsset() async throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let (service, source, target, metadata, data) = try await setup(
            data: multiChunkData()
        )
        let store = ContentAddressedAssetStore(directoryURL: directory)
        _ = try await store.store(data: data, detectedContentType: metadata.mimeType)
        let coordinator = VerifiedPhotoReuseCoordinator(
            assetStore: store,
            applicationService: service
        )
        let result = try await coordinator.reusePhotos(
            assetIDs: [metadata.id],
            from: source.id,
            to: target.id
        )
        XCTAssertEqual(result.count, 1)
        XCTAssertNotEqual(result[0].id, metadata.id)
        XCTAssertEqual(result[0].contentHash, metadata.contentHash)
        let storedTarget = try await service.album(id: target.id)
        XCTAssertEqual(storedTarget.photoAssetIDs, [result[0].id])
    }

    // 3:PHO-016, 3:LOC-012
    func testMissingBlobRejectsReuseWithoutCreatingMembership() async throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let (service, source, target, metadata, _) = try await setup()
        let coordinator = VerifiedPhotoReuseCoordinator(
            assetStore: ContentAddressedAssetStore(directoryURL: directory),
            applicationService: service
        )
        do {
            _ = try await coordinator.reusePhotos(
                assetIDs: [metadata.id],
                from: source.id,
                to: target.id
            )
            XCTFail("Le blob absent devait bloquer la réutilisation")
        } catch {}
        let storedTarget = try await service.album(id: target.id)
        XCTAssertTrue(storedTarget.photoAssetIDs.isEmpty)
    }

    // 3:PHO-016, 3:LOC-012, 3:SEC-007
    func testCorruptBlobRejectsReuseWithoutCreatingMembership() async throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let (service, source, target, metadata, data) = try await setup()
        let store = ContentAddressedAssetStore(directoryURL: directory)
        _ = try await store.store(data: data, detectedContentType: metadata.mimeType)
        let storedURL = await store.url(for: metadata.contentHash)
        let file = try XCTUnwrap(storedURL)
        var corrupted = data
        corrupted.replaceSubrange(0..<1, with: [data[0] ^ 0xff])
        XCTAssertEqual(corrupted.count, data.count)
        try corrupted.write(to: file, options: .atomic)
        let coordinator = VerifiedPhotoReuseCoordinator(
            assetStore: store,
            applicationService: service
        )
        await XCTAssertThrowsDomainError({
            try await coordinator.reusePhotos(
                assetIDs: [metadata.id],
                from: source.id,
                to: target.id
            )
        }, matching: { $0 == .invalidBlobIndex(metadata.contentHash) })
        let storedTarget = try await service.album(id: target.id)
        XCTAssertTrue(storedTarget.photoAssetIDs.isEmpty)
    }
}
