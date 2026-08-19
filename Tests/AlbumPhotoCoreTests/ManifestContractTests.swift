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
        XCTAssertEqual(BuiltInLayoutTemplateCatalog.manifestData, manifestData)
        XCTAssertEqual(BuiltInLayoutTemplateCatalog.manifest.templates, manifest.templates)
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

    // 3:EDT-003, 3:EDT-008, 3:EDT-016, 3:EDT-020, 3:PAG-002, 3:PAG-013, 3:PAG-017
    func testPageWorkspaceUsesConfirmedAppendAndExplicitPageManagementLabel() throws {
        let appModule = repositoryRoot
            .appendingPathComponent("Albumzh.swiftpm/Sources/AppModule", isDirectory: true)
        let core = repositoryRoot
            .appendingPathComponent("Albumzh.swiftpm/Sources/AlbumPhotoCore", isDirectory: true)
        let editor = try String(
            contentsOf: appModule.appendingPathComponent("AlbumEditorView.swift"),
            encoding: .utf8
        )
        let viewModel = try String(
            contentsOf: appModule.appendingPathComponent("EditorViewModel.swift"),
            encoding: .utf8
        )
        let globalPages = try String(
            contentsOf: appModule.appendingPathComponent("GlobalPagesView.swift"),
            encoding: .utf8
        )
        let service = try String(
            contentsOf: core.appendingPathComponent("AlbumApplicationService.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(editor.contains("pageWorkspaceCommandRow(addPageTitle: \"Ajouter une page\")"))
        XCTAssertTrue(editor.contains("Task { await model.requestPageAddition() }"))
        XCTAssertTrue(editor.contains("if model.showsPageAdditionConfirmation"))
        XCTAssertTrue(editor.contains("PageAdditionConfirmationDialog("))
        XCTAssertTrue(editor.contains("Color.black.opacity(0.35)"))
        XCTAssertTrue(editor.contains("\"Ne plus demander\""))
        XCTAssertTrue(editor.contains("à la fin de l’album"))
        XCTAssertTrue(editor.contains("minHeight: 340"))
        XCTAssertTrue(editor.contains("min(400, geometry.size.width - 32)"))
        XCTAssertFalse(editor.contains(".sheet(isPresented: $model.showsPageAdditionConfirmation)"))
        XCTAssertFalse(editor.contains(".presentationSizing(.fitted)"))
        XCTAssertFalse(editor.contains(".presentationSizing(.page)"))
        XCTAssertFalse(editor.contains(".presentationDetents([.height(280)])"))
        XCTAssertTrue(editor.contains(".accessibilityLabel(\"Ajouter une page\")"))
        XCTAssertFalse(editor.contains("pageWorkspaceCommandRow(addPhotoTitle:"))
        XCTAssertFalse(editor.contains("func addPhotoButton(title:"))
        XCTAssertTrue(editor.contains(".accessibilityLabel(mode.accessibilityLabel)"))
        XCTAssertTrue(globalPages.contains("Task { await model.requestPageAddition() }"))
        XCTAssertTrue(globalPages.contains("isOn: $model.skipsPageAdditionConfirmation"))
        XCTAssertTrue(viewModel.contains("func requestPageAddition() async"))
        XCTAssertTrue(viewModel.contains("func confirmPageAddition() async"))
        XCTAssertTrue(viewModel.contains("private func addPageToEnd() async"))
        XCTAssertTrue(viewModel.contains("@Published var skipsPageAdditionConfirmation = false"))
        XCTAssertTrue(viewModel.contains("case .global: \"Gérer les pages\""))
        XCTAssertTrue(viewModel.contains("case .global: \"Gérer les pages — Vue globale\""))
        XCTAssertFalse(viewModel.contains("case .global: \"Organiser\""))
        XCTAssertFalse(viewModel.contains("func beginNewPhotoFrameChoice()"))
        XCTAssertTrue(service.contains("album.pages.append(PageSnapshot(id: pageID))"))
        XCTAssertFalse(service.contains("after activePageID"))
    }

    // 3:AUT-009...3:AUT-011, 3:EDT-001, 3:EDT-020
    func testPhotosPanelExposesConfirmedAlbumFillWithEveryDensity() throws {
        let appModule = repositoryRoot
            .appendingPathComponent("Albumzh.swiftpm/Sources/AppModule", isDirectory: true)
        let core = repositoryRoot
            .appendingPathComponent("Albumzh.swiftpm/Sources/AlbumPhotoCore", isDirectory: true)
        let photosPanel = try String(
            contentsOf: appModule.appendingPathComponent("PhotosPanelView.swift"),
            encoding: .utf8
        )
        let editor = try String(
            contentsOf: appModule.appendingPathComponent("AlbumEditorView.swift"),
            encoding: .utf8
        )
        let viewModel = try String(
            contentsOf: appModule.appendingPathComponent("EditorViewModel.swift"),
            encoding: .utf8
        )
        let service = try String(
            contentsOf: core.appendingPathComponent("AlbumApplicationService.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(photosPanel.contains("Button(\"Remplir l’album\", systemImage: \"wand.and.stars\")"))
        XCTAssertFalse(photosPanel.contains("GroupBox"))
        XCTAssertTrue(photosPanel.contains("model.requestAlbumFill(.balanced)"))
        XCTAssertTrue(photosPanel.contains(".disabled(!model.canFillAlbum)"))
        XCTAssertTrue(editor.contains("private struct AlbumFillConfirmationDialog: View"))
        XCTAssertTrue(editor.contains("Text(\"Aérée (1–2)\")"))
        XCTAssertTrue(editor.contains("Text(\"Équilibrée (3–4)\")"))
        XCTAssertTrue(editor.contains("Text(\"Dense (5–8)\")"))
        XCTAssertTrue(editor.contains("Button(\"Valider\", action: onConfirm)"))
        XCTAssertTrue(editor.contains("else if let plan = model.albumFillConfirmation"))
        XCTAssertTrue(editor.contains("Task { await model.confirmAlbumFill(plan) }"))
        XCTAssertTrue(viewModel.contains("albumFillConfirmationMessage"))
        XCTAssertTrue(viewModel.contains("plan.emptyPhotoFrameCount"))
        XCTAssertTrue(viewModel.contains("plan.reusedPageCount"))
        XCTAssertTrue(viewModel.contains("plan.createdPageCount"))
        XCTAssertTrue(service.contains("public func planAlbumFill("))
        XCTAssertTrue(service.contains("public func fillAlbum("))
        XCTAssertTrue(service.contains("label: \"Remplir l’album\""))
    }

    // 3:EDT-008, 3:EDT-014, 3:TPL-012, 3:TBX-002...006,
    // 3:TBX-009...017, 3:TBX-020, 3:TBX-021, 3:TBX-024, 3:TXA-001...004
    func testTextEditorUsesNativeAttributedSelectionAndActivatesTextTemplates() throws {
        let appModule = repositoryRoot
            .appendingPathComponent("Albumzh.swiftpm/Sources/AppModule", isDirectory: true)
        let core = repositoryRoot
            .appendingPathComponent("Albumzh.swiftpm/Sources/AlbumPhotoCore", isDirectory: true)
        let editor = try String(
            contentsOf: appModule.appendingPathComponent("AlbumEditorView.swift"),
            encoding: .utf8
        )
        let textEditor = try String(
            contentsOf: appModule.appendingPathComponent("AlbumTextEditorView.swift"),
            encoding: .utf8
        )
        let textPanel = try String(
            contentsOf: appModule.appendingPathComponent("TextPanelView.swift"),
            encoding: .utf8
        )
        let pageBackground = try String(
            contentsOf: appModule.appendingPathComponent("AlbumPageBackground.swift"),
            encoding: .utf8
        )
        let canvas = try String(
            contentsOf: appModule.appendingPathComponent("PageCanvasView.swift"),
            encoding: .utf8
        )
        let layouts = try String(
            contentsOf: appModule.appendingPathComponent("LayoutPanelView.swift"),
            encoding: .utf8
        )
        let viewModel = try String(
            contentsOf: appModule.appendingPathComponent("EditorViewModel.swift"),
            encoding: .utf8
        )
        let service = try String(
            contentsOf: core.appendingPathComponent("AlbumApplicationService.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(textEditor.contains("TextEditor(text: $text, selection: $selection)"))
        XCTAssertTrue(textEditor.contains("AttributedTextSelection"))
        XCTAssertTrue(textEditor.contains("AlbumTextFormattingDefinition"))
        XCTAssertTrue(textEditor.contains("struct AlbumTextModelAttributes: AttributeScope"))
        XCTAssertTrue(textEditor.contains("private struct ApplyAlbumFont"))
        XCTAssertTrue(textEditor.contains("ApplyAlbumFont(pageHeight: pageHeight)"))
        XCTAssertTrue(textEditor.contains(
            "typealias AttributeKey = AttributeScopes.SwiftUIAttributes.FontAttribute"
        ))
        XCTAssertTrue(textEditor.contains("private struct ApplyAlbumForegroundColor"))
        XCTAssertTrue(textEditor.contains(
            "typealias AttributeKey = AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute"
        ))
        XCTAssertTrue(textEditor.contains(
            "typealias AttributeKey = AttributeScopes.CoreTextAttributes.TextAlignmentAttribute"
        ))
        XCTAssertTrue(textEditor.contains(
            "typealias AttributeKey = AttributeScopes.CoreTextAttributes.LineHeightAttribute"
        ))
        XCTAssertFalse(textEditor.contains(
            "typealias AttributeKey = AlbumTextStyleAttribute"
        ))
        XCTAssertFalse(textEditor.contains(
            "typealias AttributeKey = AlbumParagraphStyleAttribute"
        ))
        XCTAssertTrue(textEditor.contains(
            ".textInputFormattingControlVisibility(.hidden, for: .all)"
        ))
        XCTAssertTrue(textEditor.contains("selection: request.pageBackground"))
        XCTAssertTrue(textEditor.contains(".scrollContentBackground(.hidden)"))
        XCTAssertTrue(textEditor.contains(".allowsHitTesting(false)"))
        XCTAssertTrue(textEditor.contains(".zIndex(0)"))
        XCTAssertTrue(textEditor.contains(".zIndex(1)"))
        XCTAssertTrue(pageBackground.contains(
            ".frame(maxWidth: .infinity, maxHeight: .infinity)\n        .clipped()"
        ))
        XCTAssertTrue(textEditor.contains("pageHeight: request.previewPageHeight"))
        XCTAssertTrue(textEditor.contains("TextPrototypeEngine.renderedFontSize("))
        XCTAssertTrue(textEditor.contains("return .normal"))
        XCTAssertFalse(textEditor.contains(
            "pageHeight: AlbumPhotoConstants.canonicalPageHeight"
        ))
        XCTAssertTrue(textEditor.contains(".opacity(opacity)"))
        XCTAssertTrue(textEditor.contains("Circle()"))
        XCTAssertTrue(textEditor.contains(".fill(option.color.swiftUIColor)"))
        XCTAssertTrue(textEditor.contains(".popover(isPresented: $showsColorPalette)"))
        XCTAssertTrue(textEditor.contains("LazyVStack(alignment: .leading, spacing: 6)"))
        XCTAssertTrue(textEditor.contains(".frame(maxHeight: 320)"))
        XCTAssertTrue(textEditor.contains("retainedSelection: AttributedTextSelection?"))
        XCTAssertTrue(textEditor.contains("retainSelectionForFormatting()"))
        XCTAssertTrue(textEditor.contains("Sélection conservée"))
        XCTAssertTrue(textEditor.contains("formattingScopeLabel(\"Sélection\""))
        XCTAssertTrue(textEditor.contains("formattingScopeLabel(\"Paragraphe\""))
        XCTAssertTrue(textEditor.contains("formattingScopeLabel(\"Zone\""))
        XCTAssertTrue(textEditor.contains("Masquer le clavier"))
        XCTAssertTrue(textEditor.contains("newValue.characters.count > 1_000"))
        XCTAssertTrue(textEditor.contains("acceptedInsertedCount"))
        XCTAssertTrue(textEditor.contains("result.removeSubrange"))
        XCTAssertTrue(textEditor.contains("static let runBoundaries"))
        let orderedCommands = [
            "fontMenu", "sizeMenu", "Button(\"Gras\"", "Button(\"Italique\"",
            "colorMenu", "alignmentMenu", "lineSpacingMenu", "opacityMenu"
        ]
        var commandOffset = textEditor.startIndex
        for command in orderedCommands {
            let range = try XCTUnwrap(textEditor.range(
                of: command,
                range: commandOffset..<textEditor.endIndex
            ), command)
            commandOffset = range.upperBound
        }

        XCTAssertTrue(editor.contains("Menu(\"Ajouter\", systemImage: \"plus\")"))
        XCTAssertTrue(editor.contains(
            "Button(\"Ajouter du texte\", systemImage: \"text.badge.plus\")"
        ))
        XCTAssertEqual(
            editor.components(
                separatedBy: "Button(\"Ajouter du texte\", systemImage: \"text.badge.plus\")"
            ).count - 1,
            1,
            "Ajouter du texte ne doit plus être superposé au canevas"
        )
        XCTAssertTrue(editor.contains("case .text:"))
        XCTAssertTrue(editor.contains("TextPanelView(model: model)"))
        XCTAssertTrue(editor.contains(".sheet(item: $model.textEditingRequest)"))
        XCTAssertTrue(textPanel.contains(
            "Button(\"Ajouter un texte\", systemImage: \"text.badge.plus\")"
        ))
        XCTAssertTrue(editor.contains("TextElementInspectorView(model: model, text: text)"))
        XCTAssertTrue(textPanel.contains("Text(\"Texte à afficher\")"))
        XCTAssertTrue(textPanel.contains("dans l’inspecteur de l’élément"))
        XCTAssertTrue(textPanel.contains("Format de toute la zone"))
        XCTAssertTrue(textPanel.contains("applySelectedTextCharacterStyle"))
        XCTAssertTrue(textPanel.contains("applySelectedTextParagraphStyle"))
        XCTAssertTrue(textPanel.contains("setSelectedTextOpacity"))
        XCTAssertTrue(viewModel.contains("case text"))
        XCTAssertTrue(viewModel.contains(
            "case photos\n    case text\n    case layouts\n    case backgrounds"
        ))
        XCTAssertEqual(
            editor.components(separatedBy: "if panel == .text {").count - 1,
            2,
            "Les rails régulier et compact doivent séparer les ajouts de la page"
        )
        XCTAssertTrue(viewModel.contains("previewPageHeight: textPreviewPageHeight"))
        XCTAssertTrue(viewModel.contains("func beginAddingText()"))
        XCTAssertTrue(viewModel.contains("func commitTextEditing("))
        XCTAssertTrue(viewModel.contains("firstOverflowingTextLocation"))
        XCTAssertTrue(canvas.contains("Label(\"Ajouter du texte\""))
        XCTAssertTrue(canvas.contains("TextPrototypeEngine.overflows"))
        XCTAssertTrue(canvas.contains("model.handleCanvasTap("))
        XCTAssertFalse(layouts.contains("!template.textSlots.isEmpty"))
        XCTAssertFalse(layouts.contains("prochain incrément"))
        XCTAssertTrue(service.contains("public func addTextBox("))
        XCTAssertTrue(service.contains("public func updateTextBox("))
        XCTAssertTrue(service.contains("label: \"Ajouter du texte\""))
        XCTAssertTrue(service.contains("label: \"Modifier le texte\""))
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
