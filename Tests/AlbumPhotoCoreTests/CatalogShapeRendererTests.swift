import Foundation
import XCTest
@testable import AlbumPhotoCore

final class CatalogShapeRendererTests: XCTestCase {
    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    // 3:SHR-012, 3:CAT-009, 3:TST-006
    func testAllSixRendererIDsProduceTheFrozenNonSquareGoldenMasks() throws {
        let expected: [String: (filename: String, sha256: String)] = [
            "shape.rectangle": (
                "shape-rectangle.pbm",
                "2690338ccd22e03a38e6d80c6b21c9ef5dbdf0ba14ea888df47089d56ee1b8f1"
            ),
            "shape.roundedRectangle": (
                "shape-roundedRectangle.pbm",
                "822ff8d71f44121bc84b4e0d5d4451ebece3317557f3751045156b971312aca1"
            ),
            "shape.circle": (
                "shape-circle.pbm",
                "b1ea230295decfdd14b04d51a5e22274ae89180a6c993d75d6869f9000a1081b"
            ),
            "shape.oval": (
                "shape-oval.pbm",
                "1c22fbeb1c0030e72ea731536adcbb1575ad503a49a39f7a8d2a880de64dafd9"
            ),
            "shape.heart": (
                "shape-heart.pbm",
                "fda470ca05a0e8bfc923d726f9035df62b1673d743d8438de6bd58a8cdb116cd"
            ),
            "shape.star": (
                "shape-star.pbm",
                "518a5fbb66784e12362ad264212651cd6284d1b0ff6284f846e9e8362afb8599"
            )
        ]
        XCTAssertEqual(CatalogShapeRenderer.supportedRendererIDs, Set(expected.keys))

        let goldenDirectory = repositoryRoot.appendingPathComponent(
            "docs/golden/shape-masks-v1",
            isDirectory: true
        )
        for (rendererID, fixture) in expected {
            let mask = try CatalogShapeRenderer.rasterize(
                rendererID: rendererID,
                width: 64,
                height: 48
            )
            let generated = Data(mask.portableBitmapASCII.utf8)
            let frozen = try Data(contentsOf: goldenDirectory.appendingPathComponent(
                fixture.filename
            ))
            XCTAssertEqual(generated, frozen, rendererID)
            XCTAssertEqual(generated.count, 6_153, rendererID)
            XCTAssertEqual(SHA256.hexDigest(generated), fixture.sha256, rendererID)
        }
    }

    // 3:SHR-012 — circle uses min dimension; oval reaches all four bounds.
    func testCircleAndOvalRemainDistinctInANonSquareElement() throws {
        XCTAssertFalse(try CatalogShapeRenderer.contains(
            rendererID: "shape.circle",
            normalizedX: 0.05,
            normalizedY: 0.5,
            elementWidth: 200,
            elementHeight: 100
        ))
        XCTAssertTrue(try CatalogShapeRenderer.contains(
            rendererID: "shape.oval",
            normalizedX: 0.05,
            normalizedY: 0.5,
            elementWidth: 200,
            elementHeight: 100
        ))
    }

    // 3:SHR-012 — closed paths, non-zero fill and clipping.
    func testRepresentativeInsideOutsideAndClippedSamples() throws {
        XCTAssertTrue(try contains("shape.rectangle", x: 0, y: 1))
        XCTAssertFalse(try contains("shape.rectangle", x: -0.001, y: 0.5))
        XCTAssertFalse(try contains("shape.roundedRectangle", x: 0.01, y: 0.01))
        XCTAssertTrue(try contains("shape.roundedRectangle", x: 0.5, y: 0.5))
        XCTAssertTrue(try contains("shape.heart", x: 0.5, y: 0.5))
        XCTAssertFalse(try contains("shape.heart", x: 0.5, y: 0.01))
        XCTAssertTrue(try contains("shape.star", x: 0.5, y: 0.5))
        XCTAssertFalse(try contains("shape.star", x: 0.01, y: 0.01))
    }

    func testRendererRejectsUnknownIDsInvalidDimensionsAndNonFiniteCoordinates() throws {
        XCTAssertThrowsError(try CatalogShapeRenderer.rasterize(
            rendererID: "shape.unknown",
            width: 64,
            height: 48
        )) { error in
            XCTAssertEqual(
                error as? CatalogShapeRendererError,
                .unsupportedRendererID("shape.unknown")
            )
        }
        XCTAssertThrowsError(try CatalogShapeRenderer.rasterize(
            rendererID: "shape.rectangle",
            width: 0,
            height: 48
        )) { error in
            XCTAssertEqual(
                error as? CatalogShapeRendererError,
                .invalidDimensions(width: 0, height: 48)
            )
        }
        XCTAssertThrowsError(try CatalogShapeRenderer.rasterize(
            rendererID: "shape.rectangle",
            width: Int.max,
            height: 2
        )) { error in
            XCTAssertEqual(
                error as? CatalogShapeRendererError,
                .invalidDimensions(width: Int.max, height: 2)
            )
        }
        XCTAssertThrowsError(try CatalogShapeRenderer.contains(
            rendererID: "shape.rectangle",
            normalizedX: .nan,
            normalizedY: 0.5,
            elementWidth: 64,
            elementHeight: 48
        )) { error in
            XCTAssertEqual(error as? CatalogShapeRendererError, .nonFiniteCoordinate)
        }
        XCTAssertThrowsError(try CatalogShapeRenderer.contains(
            rendererID: "shape.rectangle",
            normalizedX: 0.5,
            normalizedY: 0.5,
            elementWidth: -Double.greatestFiniteMagnitude,
            elementHeight: 48
        )) { error in
            XCTAssertEqual(
                error as? CatalogShapeRendererError,
                .invalidDimensions(width: 0, height: 0)
            )
        }
    }

    private func contains(_ rendererID: String, x: Double, y: Double) throws -> Bool {
        try CatalogShapeRenderer.contains(
            rendererID: rendererID,
            normalizedX: x,
            normalizedY: y,
            elementWidth: 64,
            elementHeight: 48
        )
    }
}
