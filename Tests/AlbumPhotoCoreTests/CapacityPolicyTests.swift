import Foundation
import XCTest
@testable import AlbumPhotoCore

final class CapacityPolicyTests: XCTestCase {
    // 3:PAG-012, 3:LOC-018, 3:PERF-015
    func testWarnsOnlyAfterGuaranteedPageAndElementEnvelopes() {
        var pages = (0..<100).map { _ in PageSnapshot(id: UUID()) }
        pages[0].elements = (0..<20).map { index in
            .photo(PhotoFrameElement(
                id: UUID(),
                geometry: ElementGeometry(order: Int64(index + 1) * 1_024)
            ))
        }
        var album = AlbumSnapshot(
            id: UUID(),
            name: "Capacite",
            createdAt: Date(timeIntervalSince1970: 0)
        )
        album.pages = pages
        XCTAssertTrue(AlbumCapacityPolicy.warnings(
            for: album,
            photoAssets: []
        ).isEmpty)

        var exceeded = album
        exceeded.pages.append(PageSnapshot(id: UUID()))
        exceeded.pages[0].elements.append(PageElement.photo(PhotoFrameElement(
            id: UUID(),
            geometry: ElementGeometry(order: 21 * 1_024)
        )))
        XCTAssertEqual(
            Set(AlbumCapacityPolicy.warnings(for: exceeded, photoAssets: [])),
            Set([
                .pageCount(actual: 101, guaranteed: 100),
                .elementCount(
                    pageID: exceeded.pages[0].id,
                    kind: .photo,
                    actual: 21,
                    guaranteed: 20
                )
            ])
        )
    }

    // 3:LOC-017, 3:PERF-015
    func testAlbumBytesAreDeduplicatedByContentHash() {
        let albumID = UUID()
        let firstID = UUID()
        let secondID = UUID()
        let sharedHash = String(repeating: "a", count: 64)
        let distinctHash = String(repeating: "b", count: 64)
        var album = AlbumSnapshot(
            id: albumID,
            name: "Volume",
            createdAt: Date(timeIntervalSince1970: 0),
            background: .none
        )
        album.photoAssetIDs = [firstID, secondID]
        let first = PhotoAssetMetadata(
            id: firstID,
            contentHash: sharedHash,
            mimeType: "image/png",
            pixelWidth: 1,
            pixelHeight: 1,
            byteCount: 3_000_000_000,
            source: .files,
            importedAt: Date(timeIntervalSince1970: 0)
        )
        let duplicate = PhotoAssetMetadata(
            id: secondID,
            contentHash: sharedHash,
            mimeType: "image/png",
            pixelWidth: 1,
            pixelHeight: 1,
            byteCount: 3_000_000_000,
            source: .files,
            importedAt: Date(timeIntervalSince1970: 0)
        )
        XCTAssertFalse(AlbumCapacityPolicy.warnings(
            for: album,
            photoAssets: [first, duplicate]
        ).contains { warning in
            if case .albumByteCount = warning { return true }
            return false
        })

        let distinct = PhotoAssetMetadata(
            id: secondID,
            contentHash: distinctHash,
            mimeType: "image/png",
            pixelWidth: 1,
            pixelHeight: 1,
            byteCount: 3_000_000_000,
            source: .files,
            importedAt: Date(timeIntervalSince1970: 0)
        )
        let warnings = AlbumCapacityPolicy.warnings(
            for: album,
            photoAssets: [first, distinct]
        )
        XCTAssertTrue(warnings.contains(AlbumCapacityWarning.albumByteCount(
            actual: 6_000_000_000,
            guaranteed: 5_000_000_000
        )))
    }
}
