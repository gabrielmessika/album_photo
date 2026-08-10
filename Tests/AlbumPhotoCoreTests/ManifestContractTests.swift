import Foundation
import XCTest
@testable import AlbumPhotoCore

final class ManifestContractTests: XCTestCase {
    private struct CanonicalPage: Decodable {
        let width: Int
        let height: Int
    }

    private struct TemplateManifest: Decodable {
        let manifestVersion: Int
        let modelGeneration: String
        let canonicalPage: CanonicalPage
        let templates: [LayoutTemplateDefinition]
    }

    private struct CatalogManifest: Decodable {
        let registryVersion: Int
        let resources: [Resource]

        struct Resource: Decodable {
            let catalogID: String
            let catalogVersion: Int
            let category: String
            let payloadKind: String
            let mimeType: String?
            let byteCount: Int64?
            let sha256: String?
            let rendererID: String?
        }
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    // 3:TPL-003, 3:TPL-019, 3:TST-006
    func testPublishedTemplateManifestHashAndFourVariantsForOneThroughEightPhotos() throws {
        let docs = repositoryRoot.appendingPathComponent("docs", isDirectory: true)
        let manifestData = try Data(contentsOf: docs.appendingPathComponent(
            "layout-templates-v1.json"
        ))
        let checksums = try String(contentsOf: docs.appendingPathComponent(
            "catalog-checksums-v1.sha256"
        ), encoding: .utf8)
        let expectedHash = try XCTUnwrap(checksums.split(separator: "\n")
            .first { $0.hasSuffix("  layout-templates-v1.json") }?
            .split(separator: " ").first.map(String.init))
        XCTAssertEqual(SHA256.hexDigest(manifestData), expectedHash)

        let manifest = try JSONDecoder().decode(TemplateManifest.self, from: manifestData)
        XCTAssertEqual(manifest.manifestVersion, 1)
        XCTAssertEqual(manifest.modelGeneration, AlbumModelVersion.generation)
        XCTAssertEqual(manifest.canonicalPage.width, 2_400)
        XCTAssertEqual(manifest.canonicalPage.height, 3_000)
        try LayoutTemplateEngine.validateCatalog(manifest.templates)
        let variants = Dictionary(grouping: manifest.templates) { $0.photoSlots.count }
        for count in 1...8 {
            XCTAssertGreaterThanOrEqual(variants[count]?.count ?? 0, 4, "\(count) photo(s)")
        }
    }

    // 3:CAT-001...3:CAT-009, 3:DAT-041
    func testPublishedCatalogMatchesRuntimePayloadContractsExactly() throws {
        let data = try Data(contentsOf: repositoryRoot.appendingPathComponent(
            "docs/catalog-resources-v1.json"
        ))
        let manifest = try JSONDecoder().decode(CatalogManifest.self, from: data)
        XCTAssertEqual(manifest.registryVersion, 1)
        XCTAssertEqual(manifest.resources.count, BuiltInCatalogRegistry.entries.count)
        for resource in manifest.resources {
            let descriptor = try XCTUnwrap(BuiltInCatalogRegistry.descriptor(
                id: resource.catalogID,
                version: resource.catalogVersion
            ))
            XCTAssertEqual(descriptor.category.rawValue, resource.category)
            switch descriptor.payload {
            case let .asset(hash, mimeType, byteCount):
                XCTAssertEqual(resource.payloadKind, "asset")
                XCTAssertEqual(resource.sha256, hash)
                XCTAssertEqual(resource.mimeType, mimeType)
                XCTAssertEqual(resource.byteCount, byteCount)
                XCTAssertNil(resource.rendererID)
            case let .nativeVector(rendererID):
                XCTAssertEqual(resource.payloadKind, "nativeVector")
                XCTAssertEqual(resource.rendererID, rendererID)
                XCTAssertNil(resource.sha256)
                XCTAssertNil(resource.mimeType)
                XCTAssertNil(resource.byteCount)
            }
        }
    }

    // Lot 0, 3:PKG-003, 3:PKG-005...3:PKG-007
    func testPhotoAlbumSchemaAndExamplesAreValidJSONAndChecksumsAreLowercaseSHA256() throws {
        let docs = repositoryRoot.appendingPathComponent("docs", isDirectory: true)
        let jsonFiles = [
            "photoalbum-format-v1.schema.json",
            "examples/Minimal.photoalbum/manifest.json",
            "examples/Minimal.photoalbum/checksums.json",
            "examples/invalid/path-traversal-manifest.json",
            "examples/invalid/wrong-generation-manifest.json"
        ]
        for path in jsonFiles {
            let data = try Data(contentsOf: docs.appendingPathComponent(path))
            XCTAssertNoThrow(try JSONSerialization.jsonObject(with: data), path)
        }
        let checksumsData = try Data(contentsOf: docs.appendingPathComponent(
            "examples/Minimal.photoalbum/checksums.json"
        ))
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: checksumsData) as? [String: Any]
        )
        let files = try XCTUnwrap(object["files"] as? [[String: Any]])
        for file in files {
            let hash = try XCTUnwrap(file["sha256"] as? String)
            XCTAssertNotNil(hash.range(of: "^[0-9a-f]{64}$", options: .regularExpression))
        }
    }

    // 3:FMT-002, 3:PKG-003, 3:PKG-016, 3:IMP-023
    func testPublishedPackageSchemaMatchesPersistedMIMEsAndExclusivePayloadKinds() throws {
        let docs = repositoryRoot.appendingPathComponent("docs", isDirectory: true)
        let packageSchemaData = try Data(contentsOf: docs.appendingPathComponent(
            "photoalbum-format-v1.schema.json"
        ))
        let packageSchema = try XCTUnwrap(
            JSONSerialization.jsonObject(with: packageSchemaData) as? [String: Any]
        )
        let definitions = try XCTUnwrap(packageSchema["$defs"] as? [String: Any])
        let photoAsset = try XCTUnwrap(definitions["photoAsset"] as? [String: Any])
        let photoProperties = try XCTUnwrap(photoAsset["properties"] as? [String: Any])
        let mimeType = try XCTUnwrap(photoProperties["mimeType"] as? [String: Any])
        let publishedMIMEs = try XCTUnwrap(mimeType["enum"] as? [String])
        XCTAssertEqual(Set(publishedMIMEs), DomainValidator.acceptedPhotoMIMETypes)

        let packageResource = try XCTUnwrap(definitions["catalogResource"] as? [String: Any])
        try assertExclusivePayloadBranches(packageResource)

        let catalogSchemaData = try Data(contentsOf: docs.appendingPathComponent(
            "schema/catalog-resources-v1.schema.json"
        ))
        let catalogSchema = try XCTUnwrap(
            JSONSerialization.jsonObject(with: catalogSchemaData) as? [String: Any]
        )
        let catalogDefinitions = try XCTUnwrap(catalogSchema["$defs"] as? [String: Any])
        let catalogResource = try XCTUnwrap(catalogDefinitions["resource"] as? [String: Any])
        try assertExclusivePayloadBranches(catalogResource)
    }

    private func assertExclusivePayloadBranches(
        _ resourceSchema: [String: Any],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let branches = try XCTUnwrap(
            resourceSchema["oneOf"] as? [[String: Any]],
            file: file,
            line: line
        )
        XCTAssertEqual(branches.count, 2, file: file, line: line)
        let branchesByKind = try Dictionary(uniqueKeysWithValues: branches.map { branch in
            let properties = try XCTUnwrap(
                branch["properties"] as? [String: Any],
                file: file,
                line: line
            )
            let payload = try XCTUnwrap(
                properties["payloadKind"] as? [String: Any],
                file: file,
                line: line
            )
            let kind = try XCTUnwrap(payload["const"] as? String, file: file, line: line)
            return (kind, properties)
        })
        let asset = try XCTUnwrap(branchesByKind["asset"], file: file, line: line)
        let nativeVector = try XCTUnwrap(
            branchesByKind["nativeVector"],
            file: file,
            line: line
        )
        XCTAssertNil(asset["rendererID"], file: file, line: line)
        XCTAssertNotNil(asset["relativePath"], file: file, line: line)
        XCTAssertNotNil(nativeVector["rendererID"], file: file, line: line)
        XCTAssertNil(nativeVector["relativePath"], file: file, line: line)
        XCTAssertNil(nativeVector["sha256"], file: file, line: line)
    }
}
