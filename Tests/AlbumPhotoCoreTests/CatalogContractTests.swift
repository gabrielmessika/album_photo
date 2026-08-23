import Foundation
import XCTest
@testable import AlbumPhotoCore

final class CatalogContractTests: XCTestCase {
    private struct ExpectedRenderer {
        let primitive: String
        let parameters: [String: Any]
        let goldenPath: String
        let goldenHash: String
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    // 3:CAT-001...3:CAT-009, 3:SHR-010, 3:SHR-012, 3:TST-006
    func testPublishedNativeVectorDescriptorsAreCompleteAndByteVerifiable() throws {
        let catalog = try jsonObject("docs/catalog-resources-v1.json")
        let resources = try XCTUnwrap(catalog["resources"] as? [[String: Any]])
        let shapes = resources.filter { $0["category"] as? String == "shape" }
        let expected = expectedRenderers

        XCTAssertEqual(shapes.count, 6)
        XCTAssertEqual(Set(shapes.compactMap { $0["catalogID"] as? String }), Set(expected.keys))
        XCTAssertEqual(CatalogShapeRenderer.supportedRendererIDs, Set(expected.keys))

        for shape in shapes {
            let catalogID = try XCTUnwrap(shape["catalogID"] as? String)
            let renderer = try XCTUnwrap(expected[catalogID])
            XCTAssertEqual(shape["catalogVersion"] as? Int, 1, catalogID)
            XCTAssertEqual(shape["payloadKind"] as? String, "nativeVector", catalogID)
            XCTAssertEqual(shape["rendererID"] as? String, catalogID, catalogID)
            XCTAssertEqual(shape["license"] as? String, "project-code", catalogID)
            XCTAssertNil(shape["relativePath"], catalogID)
            XCTAssertNil(shape["mimeType"], catalogID)
            XCTAssertNil(shape["byteCount"], catalogID)
            XCTAssertNil(shape["sha256"], catalogID)

            let contract = try XCTUnwrap(shape["rendererContract"] as? [String: Any])
            XCTAssertEqual(contract["coordinateSpace"] as? String, "unitBoundingBoxTopLeft")
            XCTAssertEqual(contract["primitive"] as? String, renderer.primitive)
            XCTAssertEqual(contract["pathClosure"] as? String, "closed")
            XCTAssertEqual(contract["fillRule"] as? String, "nonzero")
            XCTAssertEqual(contract["intrinsicStroke"] as? String, "none")
            XCTAssertEqual(contract["clipToElementBounds"] as? Bool, true)
            let parameters = try XCTUnwrap(contract["parameters"] as? [String: Any])
            XCTAssertEqual(try canonicalJSON(parameters), try canonicalJSON(renderer.parameters))

            let golden = try XCTUnwrap(contract["goldenMask"] as? [String: Any])
            XCTAssertEqual(golden["relativePath"] as? String, renderer.goldenPath)
            XCTAssertEqual(golden["format"] as? String, "pbm-p1")
            XCTAssertEqual(golden["sampleLocation"] as? String, "pixelCenter")
            XCTAssertEqual(golden["width"] as? Int, 64)
            XCTAssertEqual(golden["height"] as? Int, 48)
            XCTAssertEqual(golden["byteCount"] as? Int, 6_153)
            XCTAssertEqual(golden["sha256"] as? String, renderer.goldenHash)

            let goldenData = try Data(contentsOf: repositoryRoot
                .appendingPathComponent("docs", isDirectory: true)
                .appendingPathComponent(renderer.goldenPath))
            XCTAssertEqual(goldenData.count, 6_153, catalogID)
            XCTAssertEqual(SHA256.hexDigest(goldenData), renderer.goldenHash, catalogID)
            XCTAssertTrue(goldenData.starts(with: Data("P1\n64 48\n".utf8)), catalogID)
        }
    }

    // 3:CAT-009, 3:STK-009, 3:SHR-013 — the Lot-0 schema can describe the
    // complete Lot-2 registry without publishing unlicensed payload entries.
    func testSchemaPublishesFutureStickerFrameAndRendererContractFields() throws {
        let schema = try jsonObject("docs/schema/catalog-resources-v1.schema.json")
        let definitions = try XCTUnwrap(schema["$defs"] as? [String: Any])
        let resource = try XCTUnwrap(definitions["resource"] as? [String: Any])
        let branches = try XCTUnwrap(resource["oneOf"] as? [[String: Any]])
        XCTAssertEqual(branches.count, 2)

        let asset = try XCTUnwrap(branches.first { branch in
            let properties = branch["properties"] as? [String: Any]
            let payload = properties?["payloadKind"] as? [String: Any]
            return payload?["const"] as? String == "asset"
        })
        let assetProperties = try XCTUnwrap(asset["properties"] as? [String: Any])
        for field in [
            "pixelWidth",
            "pixelHeight",
            "localizedTags",
            "stickerCategory",
            "intrinsicAspectRatio",
            "sourceCapInsetsPixels",
            "destinationCapInsets",
            "nineSliceContract"
        ] {
            XCTAssertNotNil(assetProperties[field], field)
        }

        let nativeVector = try XCTUnwrap(branches.first { branch in
            let properties = branch["properties"] as? [String: Any]
            let payload = properties?["payloadKind"] as? [String: Any]
            return payload?["const"] as? String == "nativeVector"
        })
        let nativeProperties = try XCTUnwrap(nativeVector["properties"] as? [String: Any])
        XCTAssertNotNil(nativeProperties["rendererContract"])
        XCTAssertNil(nativeProperties["relativePath"])
        XCTAssertNil(nativeProperties["sha256"])

        for definition in [
            "localizedTags",
            "intrinsicAspectRatio",
            "sourceCapInsetsPixels",
            "destinationCapInsets",
            "nineSliceContract",
            "rendererContract",
            "rendererParameters",
            "goldenMask"
        ] {
            XCTAssertNotNil(definitions[definition], definition)
        }
    }

    // 3:STK-009...3:STK-012, 3:SHR-005, 3:SHR-011, 3:SHR-013
    func testPublishedLot2CatalogHasRequiredLocalizedStickerAndFrameMetadata() throws {
        XCTAssertEqual(BuiltInStickerCatalog.definitions.count, 40)
        let stickersByCategory = Dictionary(
            grouping: BuiltInStickerCatalog.definitions,
            by: \.category
        )
        XCTAssertEqual(Set(stickersByCategory.keys), Set(StickerCatalogCategory.allCases))
        for category in StickerCatalogCategory.allCases {
            let stickers = try XCTUnwrap(stickersByCategory[category])
            XCTAssertEqual(stickers.count, 8, category.rawValue)
            XCTAssertTrue(stickers.allSatisfy {
                !$0.localizedName.isEmpty
                    && $0.localizedTags.count >= 3
                    && Set($0.localizedTags).count == $0.localizedTags.count
                    && max($0.pixelWidth, $0.pixelHeight) <= 512
                    && min($0.pixelWidth, $0.pixelHeight) > 0
            }, category.rawValue)
        }
        XCTAssertGreaterThan(
            Set(BuiltInStickerCatalog.definitions.map {
                "\($0.pixelWidth)x\($0.pixelHeight)"
            }).count,
            1,
            "STK-007 doit pouvoir remplacer par un rapport intrinsèque différent"
        )

        let frames = BuiltInDecorativeFrameCatalog.definitions
        XCTAssertEqual(frames.count, 6)
        XCTAssertEqual(
            frames.map(\.catalogID),
            [
                "frame.whiteBorder",
                "frame.blackBorder",
                "frame.kraftTape",
                "frame.travelStamp",
                "frame.botanical",
                "frame.instantPhoto"
            ]
        )
        XCTAssertEqual(
            frames.map(\.localizedName),
            [
                "Bord blanc",
                "Bord noir",
                "Ruban kraft",
                "Tampon voyage",
                "Feuillage",
                "Photo instantanée"
            ]
        )
        for frame in frames {
            XCTAssertEqual(frame.pixelWidth, 512)
            XCTAssertEqual(frame.pixelHeight, 512)
            XCTAssertEqual(
                frame.sourceCapInsetsPixels,
                CatalogPixelInsets(top: 128, left: 128, bottom: 128, right: 128)
            )
            XCTAssertEqual(
                frame.destinationCapInsets,
                CatalogFractionalInsets(top: 0.2, left: 0.2, bottom: 0.2, right: 0.2)
            )
        }
    }

    // 3:SHR-013 — la photo utilise uniquement l'ouverture transparente
    // centrale et ne traverse pas les transparences extérieures du décor.
    func testDecorativeFrameApertureFindsLargestCentralTransparentRectangle() throws {
        let width = 9
        let height = 9
        var alpha = [UInt8](repeating: 255, count: width * height)
        for y in 1...7 {
            for x in 1...7 {
                alpha[y * width + x] = 0
            }
            alpha[y * width + 2] = 9
        }
        alpha[4 * width + 4] = 8

        XCTAssertEqual(
            DecorativeFrameAlphaGeometry.centralTransparentBounds(
                alphaValues: alpha,
                pixelWidth: width,
                pixelHeight: height
            ),
            CatalogPixelBounds(x: 3, y: 1, width: 5, height: 7)
        )
    }

    // 3:SHR-013 — une source incohérente ou sans centre transparent ne doit
    // jamais produire une ouverture artificielle.
    func testDecorativeFrameApertureRejectsInvalidOrOpaqueCentre() {
        XCTAssertNil(DecorativeFrameAlphaGeometry.centralTransparentBounds(
            alphaValues: [0, 0, 0],
            pixelWidth: 2,
            pixelHeight: 2
        ))
        XCTAssertNil(DecorativeFrameAlphaGeometry.centralTransparentBounds(
            alphaValues: [0, 0, 0, 255],
            pixelWidth: 2,
            pixelHeight: 2
        ))
    }

    private func jsonObject(_ relativePath: String) throws -> [String: Any] {
        let data = try Data(contentsOf: repositoryRoot.appendingPathComponent(relativePath))
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func canonicalJSON(_ object: Any) throws -> Data {
        try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
    }

    private var expectedRenderers: [String: ExpectedRenderer] {
        [
            "shape.rectangle": ExpectedRenderer(
                primitive: "rectangle",
                parameters: ["kind": "bounds", "x": 0, "y": 0, "width": 1, "height": 1],
                goldenPath: "golden/shape-masks-v1/shape-rectangle.pbm",
                goldenHash: "2690338ccd22e03a38e6d80c6b21c9ef5dbdf0ba14ea888df47089d56ee1b8f1"
            ),
            "shape.roundedRectangle": ExpectedRenderer(
                primitive: "roundedRectangle",
                parameters: [
                    "kind": "roundedBounds",
                    "x": 0,
                    "y": 0,
                    "width": 1,
                    "height": 1,
                    "cornerRadiusFactor": 0.12,
                    "cornerRadiusRelativeTo": "minElementDimension"
                ],
                goldenPath: "golden/shape-masks-v1/shape-roundedRectangle.pbm",
                goldenHash: "822ff8d71f44121bc84b4e0d5d4451ebece3317557f3751045156b971312aca1"
            ),
            "shape.circle": ExpectedRenderer(
                primitive: "circle",
                parameters: [
                    "kind": "centeredCircle",
                    "centerX": 0.5,
                    "centerY": 0.5,
                    "radiusFactor": 0.5,
                    "radiusRelativeTo": "minElementDimension"
                ],
                goldenPath: "golden/shape-masks-v1/shape-circle.pbm",
                goldenHash: "b1ea230295decfdd14b04d51a5e22274ae89180a6c993d75d6869f9000a1081b"
            ),
            "shape.oval": ExpectedRenderer(
                primitive: "ellipse",
                parameters: [
                    "kind": "ellipseInBounds",
                    "centerX": 0.5,
                    "centerY": 0.5,
                    "radiusX": 0.5,
                    "radiusY": 0.5
                ],
                goldenPath: "golden/shape-masks-v1/shape-oval.pbm",
                goldenHash: "1c22fbeb1c0030e72ea731536adcbb1575ad503a49a39f7a8d2a880de64dafd9"
            ),
            "shape.heart": ExpectedRenderer(
                primitive: "cubicBezierPath",
                parameters: [
                    "kind": "svgCubicPath",
                    "path": "M .50 .95 C .44 .88 .08 .65 .08 .34 C .08 .15 .21 .05 .36 .05 C .44 .05 .49 .10 .50 .17 C .51 .10 .56 .05 .64 .05 C .79 .05 .92 .15 .92 .34 C .92 .65 .56 .88 .50 .95 Z"
                ],
                goldenPath: "golden/shape-masks-v1/shape-heart.pbm",
                goldenHash: "fda470ca05a0e8bfc923d726f9035df62b1673d743d8438de6bd58a8cdb116cd"
            ),
            "shape.star": ExpectedRenderer(
                primitive: "alternatingRadialPolygon",
                parameters: [
                    "kind": "alternatingRadialPolygon",
                    "centerX": 0.5,
                    "centerY": 0.5,
                    "vertexCount": 10,
                    "startAnglePi": -0.5,
                    "angularStepPi": 0.2,
                    "evenVertexRadius": 0.5,
                    "oddVertexRadius": 0.22
                ],
                goldenPath: "golden/shape-masks-v1/shape-star.pbm",
                goldenHash: "518a5fbb66784e12362ad264212651cd6284d1b0ff6284f846e9e8362afb8599"
            )
        ]
    }
}
