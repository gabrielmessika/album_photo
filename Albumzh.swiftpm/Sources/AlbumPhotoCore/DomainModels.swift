import Foundation

// MARK: - Model generation

public enum AlbumModelVersion {
    public static let generation = "album-photo-canvas-v1"
    public static let schemaVersion = 1
}

public enum AlbumPhotoConstants {
    public static let canonicalPageWidth = 2_400.0
    public static let canonicalPageHeight = 3_000.0
    public static let maximumNativeScale = 8.0
    public static let elementOrderStep: Int64 = 1_024
    public static let defaultBackgroundID = "album.classicSpiral"
    public static let rectangleShapeID = "shape.rectangle"
}

// MARK: - Shared values

public struct SRGBAColor: Codable, Sendable, Equatable, Hashable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public static let black = SRGBAColor(red: 0, green: 0, blue: 0)
    public static let white = SRGBAColor(red: 1, green: 1, blue: 1)
}

public struct CatalogResourceReference: Codable, Sendable, Equatable, Hashable {
    public let catalogID: String
    public let catalogVersion: Int
    public let fallbackContentHash: String?

    public init(
        catalogID: String,
        catalogVersion: Int = 1,
        fallbackContentHash: String? = nil
    ) {
        self.catalogID = catalogID
        self.catalogVersion = catalogVersion
        self.fallbackContentHash = fallbackContentHash
    }

    public static let rectangleShape = CatalogResourceReference(
        catalogID: AlbumPhotoConstants.rectangleShapeID
    )
}

public enum TextContrastHint: String, Codable, Sendable, Equatable, Hashable {
    case darkText
    case lightText
}

public struct BackgroundTheme: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let catalogID: String
    public let catalogVersion: Int
    public let localizedName: String
    public let textContrastHint: TextContrastHint
    public let fallbackContentHash: String?

    public var id: String { catalogID }

    public init(
        catalogID: String,
        catalogVersion: Int = 1,
        localizedName: String,
        textContrastHint: TextContrastHint,
        fallbackContentHash: String? = nil
    ) {
        self.catalogID = catalogID
        self.catalogVersion = catalogVersion
        self.localizedName = localizedName
        self.textContrastHint = textContrastHint
        self.fallbackContentHash = fallbackContentHash
    }

    public var reference: CatalogResourceReference {
        CatalogResourceReference(
            catalogID: catalogID,
            catalogVersion: catalogVersion,
            fallbackContentHash: fallbackContentHash
        )
    }
}

public enum BackgroundCatalog {
    public static let themes: [BackgroundTheme] = [
        BackgroundTheme(
            catalogID: "album.classicSpiral",
            localizedName: "Album classique",
            textContrastHint: .darkText,
            fallbackContentHash: "b27bf6c33ea7bb7efc22a29ec12960f04276bd868f2ed8b6cf43a879009613a8"
        ),
        BackgroundTheme(
            catalogID: "album.travelKraft",
            localizedName: "Carnet de voyage",
            textContrastHint: .darkText,
            fallbackContentHash: "ab81aea2a31595bef6827a86d62656165fab901982aca415beb9c49d2aa73e41"
        ),
        BackgroundTheme(
            catalogID: "album.minimalDark",
            localizedName: "Nuit minimaliste",
            textContrastHint: .lightText,
            fallbackContentHash: "44244ccc379b566d5b3b27e3d67255eaf52d8ea5362221bb7633b1f5f3ea86b9"
        )
    ]

    public static var defaultTheme: BackgroundTheme { themes[0] }

    public static func theme(id: String) -> BackgroundTheme? {
        themes.first { $0.catalogID == id }
    }
}

public enum CatalogResourceCategory: String, Codable, Sendable, Equatable, Hashable {
    case background
    case sticker
    case shape
    case decorativeFrame
}

public enum CatalogPayloadContract: Sendable, Equatable, Hashable {
    case asset(contentHash: String, mimeType: String, byteCount: Int64)
    case nativeVector(rendererID: String)
}

public struct CatalogResourceDescriptor: Sendable, Equatable, Hashable {
    public let catalogID: String
    public let catalogVersion: Int
    public let category: CatalogResourceCategory
    public let payload: CatalogPayloadContract
    public let sourceLicense: String

    public init(
        catalogID: String,
        catalogVersion: Int,
        category: CatalogResourceCategory,
        payload: CatalogPayloadContract,
        sourceLicense: String
    ) {
        self.catalogID = catalogID
        self.catalogVersion = catalogVersion
        self.category = category
        self.payload = payload
        self.sourceLicense = sourceLicense
    }
}

/// Public contract for resources actually shipped by the Lot-1 build. Sticker
/// and decorative-frame entries are added only with their Lot-2 payloads.
public enum BuiltInCatalogRegistry {
    public static let entries: [CatalogResourceDescriptor] = [
        CatalogResourceDescriptor(
            catalogID: "album.classicSpiral",
            catalogVersion: 1,
            category: .background,
            payload: .asset(
                contentHash: BackgroundCatalog.themes[0].fallbackContentHash!,
                mimeType: "image/png",
                byteCount: 2_466_104
            ),
            sourceLicense: "OpenAI generated project asset"
        ),
        CatalogResourceDescriptor(
            catalogID: "album.travelKraft",
            catalogVersion: 1,
            category: .background,
            payload: .asset(
                contentHash: BackgroundCatalog.themes[1].fallbackContentHash!,
                mimeType: "image/png",
                byteCount: 3_179_776
            ),
            sourceLicense: "OpenAI generated project asset"
        ),
        CatalogResourceDescriptor(
            catalogID: "album.minimalDark",
            catalogVersion: 1,
            category: .background,
            payload: .asset(
                contentHash: BackgroundCatalog.themes[2].fallbackContentHash!,
                mimeType: "image/png",
                byteCount: 1_978_753
            ),
            sourceLicense: "OpenAI generated project asset"
        ),
        CatalogResourceDescriptor(
            catalogID: AlbumPhotoConstants.rectangleShapeID,
            catalogVersion: 1,
            category: .shape,
            payload: .nativeVector(rendererID: "shape.rectangle"),
            sourceLicense: "Native geometry"
        ),
        CatalogResourceDescriptor(
            catalogID: "shape.roundedRectangle",
            catalogVersion: 1,
            category: .shape,
            payload: .nativeVector(rendererID: "shape.roundedRectangle"),
            sourceLicense: "Native geometry"
        ),
        CatalogResourceDescriptor(
            catalogID: "shape.circle",
            catalogVersion: 1,
            category: .shape,
            payload: .nativeVector(rendererID: "shape.circle"),
            sourceLicense: "Native geometry"
        ),
        CatalogResourceDescriptor(
            catalogID: "shape.oval",
            catalogVersion: 1,
            category: .shape,
            payload: .nativeVector(rendererID: "shape.oval"),
            sourceLicense: "Native geometry"
        ),
        CatalogResourceDescriptor(
            catalogID: "shape.heart",
            catalogVersion: 1,
            category: .shape,
            payload: .nativeVector(rendererID: "shape.heart"),
            sourceLicense: "Native geometry"
        ),
        CatalogResourceDescriptor(
            catalogID: "shape.star",
            catalogVersion: 1,
            category: .shape,
            payload: .nativeVector(rendererID: "shape.star"),
            sourceLicense: "Native geometry"
        )
    ]

    public static func descriptor(
        id: String,
        version: Int
    ) -> CatalogResourceDescriptor? {
        entries.first { $0.catalogID == id && $0.catalogVersion == version }
    }
}

// MARK: - Album and page

public enum CoverSelection: Codable, Sendable, Equatable, Hashable {
    case automatic
    case pagePhoto(pageID: UUID, elementID: UUID)

    private enum CodingKeys: String, CodingKey { case type, pageID, elementID }
    private enum Kind: String, Codable { case automatic, pagePhoto }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        switch try values.decode(Kind.self, forKey: .type) {
        case .automatic:
            self = .automatic
        case .pagePhoto:
            self = .pagePhoto(
                pageID: try values.decode(UUID.self, forKey: .pageID),
                elementID: try values.decode(UUID.self, forKey: .elementID)
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .automatic:
            try values.encode(Kind.automatic, forKey: .type)
        case let .pagePhoto(pageID, elementID):
            try values.encode(Kind.pagePhoto, forKey: .type)
            try values.encode(pageID, forKey: .pageID)
            try values.encode(elementID, forKey: .elementID)
        }
    }
}

public enum BackgroundSelection: Codable, Sendable, Equatable, Hashable {
    case none
    case solid(SRGBAColor)
    case catalog(CatalogResourceReference)

    public static var classicSpiral: BackgroundSelection {
        .catalog(BackgroundCatalog.defaultTheme.reference)
    }

    private enum CodingKeys: String, CodingKey {
        case type, red, green, blue, alpha, resource
    }
    private enum Kind: String, Codable { case none, solid, catalog }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        switch try values.decode(Kind.self, forKey: .type) {
        case .none:
            self = .none
        case .solid:
            self = .solid(SRGBAColor(
                red: try values.decode(Double.self, forKey: .red),
                green: try values.decode(Double.self, forKey: .green),
                blue: try values.decode(Double.self, forKey: .blue),
                alpha: try values.decode(Double.self, forKey: .alpha)
            ))
        case .catalog:
            self = .catalog(try values.decode(
                CatalogResourceReference.self,
                forKey: .resource
            ))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .none:
            try values.encode(Kind.none, forKey: .type)
        case let .solid(color):
            try values.encode(Kind.solid, forKey: .type)
            try values.encode(color.red, forKey: .red)
            try values.encode(color.green, forKey: .green)
            try values.encode(color.blue, forKey: .blue)
            try values.encode(color.alpha, forKey: .alpha)
        case let .catalog(reference):
            try values.encode(Kind.catalog, forKey: .type)
            try values.encode(reference, forKey: .resource)
        }
    }
}

public enum PagePhotoLayoutMode: String, Codable, Sendable, Equatable, Hashable {
    case free
    case template
    case automatic
}

public enum AutoLayoutDensity: String, Codable, Sendable, Equatable, Hashable {
    case airy
    case balanced
    case dense
}

public struct PageLayoutState: Codable, Sendable, Equatable, Hashable {
    public var isAutoLayoutEnabled: Bool
    public var photoMode: PagePhotoLayoutMode
    public var templateID: String?
    public var templateVersion: Int?
    public var density: AutoLayoutDensity

    public init(
        isAutoLayoutEnabled: Bool = false,
        photoMode: PagePhotoLayoutMode = .free,
        templateID: String? = nil,
        templateVersion: Int? = nil,
        density: AutoLayoutDensity = .balanced
    ) {
        self.isAutoLayoutEnabled = isAutoLayoutEnabled
        self.photoMode = photoMode
        self.templateID = templateID
        self.templateVersion = templateVersion
        self.density = density
    }

    public static let initial = PageLayoutState()
}

public struct PageSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let id: UUID
    public var background: BackgroundSelection
    public var layout: PageLayoutState
    public var elements: [PageElement]
    public var accessibilityOrder: [UUID]

    public init(
        id: UUID = UUID(),
        background: BackgroundSelection = .classicSpiral,
        layout: PageLayoutState = .initial,
        elements: [PageElement] = [],
        accessibilityOrder: [UUID] = []
    ) {
        self.id = id
        self.background = background
        self.layout = layout
        self.elements = elements
        self.accessibilityOrder = accessibilityOrder
    }

    public var isAutoLayoutEnabled: Bool { layout.isAutoLayoutEnabled }

    public var orderedElements: [PageElement] {
        elements.sorted(by: PageElement.visualOrder)
    }

    public func element(id: UUID) -> PageElement? {
        elements.first { $0.id == id }
    }
}

public struct AlbumSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let modelGeneration: String
    public let schemaVersion: Int
    public let id: UUID
    public var name: String
    public var coverSelection: CoverSelection
    public var photoAssetIDs: [UUID]
    public var pages: [PageSnapshot]
    public let createdAt: Date
    public var updatedAt: Date
    /// Recovery marker while the complete album remains in the local trash.
    /// Definitive deletion replaces the album with an independent
    /// `AlbumDeletionTombstone`.
    public var trashedAt: Date?

    public init(
        id: UUID = UUID(),
        name: String,
        firstPageID: UUID = UUID(),
        createdAt: Date = Date(),
        background: BackgroundSelection = .classicSpiral
    ) {
        self.modelGeneration = AlbumModelVersion.generation
        self.schemaVersion = AlbumModelVersion.schemaVersion
        self.id = id
        self.name = name
        self.coverSelection = .automatic
        self.photoAssetIDs = []
        self.pages = [PageSnapshot(id: firstPageID, background: background)]
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.trashedAt = nil
    }

    public var isTrashed: Bool { trashedAt != nil }

    public var automaticCoverOccurrence: CoverSelection? {
        for page in pages {
            for element in page.orderedElements {
                if let frame = element.photoFrame, frame.content != nil {
                    return .pagePhoto(pageID: page.id, elementID: frame.id)
                }
            }
        }
        return nil
    }

    public var resolvedCoverOccurrence: CoverSelection? {
        if case let .pagePhoto(pageID, elementID) = coverSelection,
           let page = pages.first(where: { $0.id == pageID }),
           let frame = page.elements.first(where: { $0.id == elementID })?.photoFrame,
           frame.content != nil {
            return coverSelection
        }
        return automaticCoverOccurrence
    }

    public func page(id: UUID) -> PageSnapshot? {
        pages.first { $0.id == id }
    }
}

// MARK: - Common element geometry

public struct ElementGeometry: Codable, Sendable, Equatable, Hashable {
    public var centerX: Double
    public var centerY: Double
    public var width: Double
    public var height: Double
    public var rotationRadians: Double
    public var order: Int64

    public init(
        centerX: Double = 0.5,
        centerY: Double = 0.5,
        width: Double = 0.45,
        height: Double = 0.36,
        rotationRadians: Double = 0,
        order: Int64 = AlbumPhotoConstants.elementOrderStep
    ) {
        self.centerX = centerX
        self.centerY = centerY
        self.width = width
        self.height = height
        self.rotationRadians = rotationRadians
        self.order = order
    }
}

// MARK: - Photos

public enum PhotoSource: String, Codable, Sendable, Equatable, Hashable {
    case applePhotos
    case files
    case reusedAlbum
    case googlePhotos
    case importedPackage
}

/// Immutable, content-addressed static representation used to display a RAW
/// original. It is a first-class blob in `Assets`; size-specific files in
/// `Thumbnails` remain disposable caches (3:FMT-002, 3:DAT-010).
public struct PhotoDisplayDerivative: Codable, Sendable, Equatable, Hashable {
    public let contentHash: String
    public let mimeType: String
    public let pixelWidth: Int
    public let pixelHeight: Int
    public let byteCount: Int64

    public init(
        contentHash: String,
        mimeType: String = "image/png",
        pixelWidth: Int,
        pixelHeight: Int,
        byteCount: Int64
    ) {
        self.contentHash = contentHash
        self.mimeType = mimeType
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.byteCount = byteCount
    }
}

public struct PhotoAssetMetadata: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let id: UUID
    public let contentHash: String
    public let mimeType: String
    public let originalFilename: String?
    public let pixelWidth: Int
    public let pixelHeight: Int
    public let byteCount: Int64
    public let colorSpaceName: String?
    public let isHDR: Bool
    public let source: PhotoSource
    public let importedAt: Date
    public let capturedAt: Date?
    public let displayDerivative: PhotoDisplayDerivative?

    public init(
        id: UUID = UUID(),
        contentHash: String,
        mimeType: String,
        originalFilename: String? = nil,
        pixelWidth: Int,
        pixelHeight: Int,
        byteCount: Int64,
        colorSpaceName: String? = nil,
        isHDR: Bool = false,
        source: PhotoSource,
        importedAt: Date = Date(),
        capturedAt: Date? = nil,
        displayDerivative: PhotoDisplayDerivative? = nil
    ) {
        self.id = id
        self.contentHash = contentHash
        self.mimeType = mimeType
        self.originalFilename = originalFilename
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.byteCount = byteCount
        self.colorSpaceName = colorSpaceName
        self.isHDR = isHDR
        self.source = source
        self.importedAt = importedAt
        self.capturedAt = capturedAt
        self.displayDerivative = displayDerivative
    }

    public func reused(id: UUID = UUID(), importedAt: Date = Date()) -> PhotoAssetMetadata {
        PhotoAssetMetadata(
            id: id,
            contentHash: contentHash,
            mimeType: mimeType,
            originalFilename: originalFilename,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            byteCount: byteCount,
            colorSpaceName: colorSpaceName,
            isHDR: isHDR,
            source: .reusedAlbum,
            importedAt: importedAt,
            capturedAt: capturedAt,
            displayDerivative: displayDerivative
        )
    }

    /// Every immutable blob required to make this logical photo independently
    /// usable. The derivative is deliberately not another logical photo.
    public var durableContentHashes: [String] {
        [contentHash] + (displayDerivative.map { [$0.contentHash] } ?? [])
    }
}

public struct PhotoPlacement: Codable, Sendable, Equatable, Hashable {
    public let assetID: UUID
    public var nativeScale: Double
    public var focalX: Double
    public var focalY: Double
    public var quarterTurns: Int
    public var flippedHorizontally: Bool
    public var accessibilityDescription: String?

    public init(
        assetID: UUID,
        nativeScale: Double = 1,
        focalX: Double = 0.5,
        focalY: Double = 0.5,
        quarterTurns: Int = 0,
        flippedHorizontally: Bool = false,
        accessibilityDescription: String? = nil
    ) {
        self.assetID = assetID
        self.nativeScale = nativeScale
        self.focalX = focalX
        self.focalY = focalY
        self.quarterTurns = ((quarterTurns % 4) + 4) % 4
        self.flippedHorizontally = flippedHorizontally
        self.accessibilityDescription = accessibilityDescription
    }
}

public struct PhotoMask: Codable, Sendable, Equatable, Hashable {
    public var shape: CatalogResourceReference

    public init(shape: CatalogResourceReference = .rectangleShape) {
        self.shape = shape
    }
}

public struct PhotoBorder: Codable, Sendable, Equatable, Hashable {
    public var width: Double
    public var color: SRGBAColor

    public init(width: Double = 0, color: SRGBAColor = .black) {
        self.width = width
        self.color = color
    }
}

public struct PhotoFrameStyleDefaults: Codable, Sendable, Equatable, Hashable {
    public var mask: CatalogResourceReference
    public var border: PhotoBorder
    public var decorativeFrame: CatalogResourceReference?

    public init(
        mask: CatalogResourceReference = .rectangleShape,
        border: PhotoBorder = PhotoBorder(),
        decorativeFrame: CatalogResourceReference? = nil
    ) {
        self.mask = mask
        self.border = border
        self.decorativeFrame = decorativeFrame
    }
}

public struct PhotoFrameElement: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let id: UUID
    public var geometry: ElementGeometry
    public var sourceTemplateSlotID: String?
    public var content: PhotoPlacement?
    public var mask: PhotoMask
    public var border: PhotoBorder
    public var decorativeFrame: CatalogResourceReference?

    public init(
        id: UUID = UUID(),
        geometry: ElementGeometry = ElementGeometry(),
        sourceTemplateSlotID: String? = nil,
        content: PhotoPlacement? = nil,
        mask: PhotoMask = PhotoMask(),
        border: PhotoBorder = PhotoBorder(),
        decorativeFrame: CatalogResourceReference? = nil
    ) {
        self.id = id
        self.geometry = geometry
        self.sourceTemplateSlotID = sourceTemplateSlotID
        self.content = content
        self.mask = mask
        self.border = border
        self.decorativeFrame = decorativeFrame
    }
}

// MARK: - Text prototype model

public enum TextAlignmentValue: String, Codable, Sendable, Equatable, Hashable {
    case leading
    case center
    case trailing
    case justified
}

public enum TextWeightValue: String, Codable, Sendable, Equatable, Hashable {
    case regular
    case bold
}

public enum TextFontDesignValue: String, Codable, Sendable, Equatable, Hashable {
    case standard
    case serif
    case rounded
    case monospaced
}

public struct TextFontDefinition: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let id: String
    public let localizedName: String
    public let design: TextFontDesignValue

    public init(id: String, localizedName: String, design: TextFontDesignValue) {
        self.id = id
        self.localizedName = localizedName
        self.design = design
    }
}

/// Offline-safe font manifest. Every entry maps to a system design guaranteed
/// by SwiftUI on the deployment target; no downloadable font is referenced.
public enum BuiltInTextFontCatalog {
    public static let manifest: [TextFontDefinition] = [
        TextFontDefinition(id: "system", localizedName: "Système", design: .standard),
        TextFontDefinition(id: "system.serif", localizedName: "Sérif", design: .serif),
        TextFontDefinition(id: "system.rounded", localizedName: "Arrondie", design: .rounded),
        TextFontDefinition(
            id: "system.monospaced",
            localizedName: "Chasse fixe",
            design: .monospaced
        )
    ]

    public static func definition(id: String) -> TextFontDefinition? {
        manifest.first { $0.id == id }
    }
}

public struct TextStyleDefaults: Codable, Sendable, Equatable, Hashable {
    public var fontID: String
    public var relativeFontSize: Double
    public var weight: TextWeightValue
    public var isItalic: Bool
    public var color: SRGBAColor
    public var alignment: TextAlignmentValue
    public var lineSpacing: Double

    public init(
        fontID: String = "system",
        relativeFontSize: Double = 18.0 / AlbumPhotoConstants.canonicalPageHeight,
        weight: TextWeightValue = .regular,
        isItalic: Bool = false,
        color: SRGBAColor = .black,
        alignment: TextAlignmentValue = .center,
        lineSpacing: Double = 1
    ) {
        self.fontID = fontID
        self.relativeFontSize = relativeFontSize
        self.weight = weight
        self.isItalic = isItalic
        self.color = color
        self.alignment = alignment
        self.lineSpacing = lineSpacing
    }
}

public struct TextRun: Codable, Sendable, Equatable, Hashable {
    public var text: String
    public var fontID: String
    public var relativeFontSize: Double
    public var weight: TextWeightValue
    public var isItalic: Bool
    public var color: SRGBAColor

    public init(text: String, style: TextStyleDefaults = TextStyleDefaults()) {
        self.text = text
        self.fontID = style.fontID
        self.relativeFontSize = style.relativeFontSize
        self.weight = style.weight
        self.isItalic = style.isItalic
        self.color = style.color
    }
}

public struct TextParagraph: Codable, Sendable, Equatable, Hashable {
    public var alignment: TextAlignmentValue
    public var lineSpacing: Double
    public var runs: [TextRun]

    public init(
        alignment: TextAlignmentValue = .center,
        lineSpacing: Double = 1,
        runs: [TextRun] = []
    ) {
        self.alignment = alignment
        self.lineSpacing = lineSpacing
        self.runs = runs
    }
}

public struct TextBoxContent: Codable, Sendable, Equatable, Hashable {
    public var paragraphs: [TextParagraph]

    public init(paragraphs: [TextParagraph] = []) {
        self.paragraphs = paragraphs
    }

    public var plainText: String {
        paragraphs.map { paragraph in
            paragraph.runs.map(\.text).joined()
        }.joined(separator: "\n")
    }
}

public struct TextBoxElement: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let id: UUID
    public var geometry: ElementGeometry
    public var sourceTemplateSlotID: String?
    public var content: TextBoxContent
    public var typingDefaults: TextStyleDefaults
    public var opacity: Double
    public var usesAutomaticHeight: Bool

    public init(
        id: UUID = UUID(),
        geometry: ElementGeometry = ElementGeometry(width: 0.60, height: 0.12),
        sourceTemplateSlotID: String? = nil,
        content: TextBoxContent = TextBoxContent(),
        typingDefaults: TextStyleDefaults = TextStyleDefaults(),
        opacity: Double = 1,
        usesAutomaticHeight: Bool = true
    ) {
        self.id = id
        self.geometry = geometry
        self.sourceTemplateSlotID = sourceTemplateSlotID
        self.content = content
        self.typingDefaults = typingDefaults
        self.opacity = opacity
        self.usesAutomaticHeight = usesAutomaticHeight
    }
}

// MARK: - Sticker prototype model

public struct StickerElement: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let id: UUID
    public var geometry: ElementGeometry
    public var resource: CatalogResourceReference
    public var opacity: Double
    public var flippedHorizontally: Bool

    public init(
        id: UUID = UUID(),
        geometry: ElementGeometry = ElementGeometry(width: 0.2, height: 0.16),
        resource: CatalogResourceReference,
        opacity: Double = 1,
        flippedHorizontally: Bool = false
    ) {
        self.id = id
        self.geometry = geometry
        self.resource = resource
        self.opacity = opacity
        self.flippedHorizontally = flippedHorizontally
    }
}

public enum PageElement: Codable, Sendable, Equatable, Hashable, Identifiable {
    case photo(PhotoFrameElement)
    case text(TextBoxElement)
    case sticker(StickerElement)

    private enum CodingKeys: String, CodingKey { case type, photo, text, sticker }
    private enum Kind: String, Codable { case photo, text, sticker }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        switch try values.decode(Kind.self, forKey: .type) {
        case .photo:
            self = .photo(try values.decode(PhotoFrameElement.self, forKey: .photo))
        case .text:
            self = .text(try values.decode(TextBoxElement.self, forKey: .text))
        case .sticker:
            self = .sticker(try values.decode(StickerElement.self, forKey: .sticker))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .photo(value):
            try values.encode(Kind.photo, forKey: .type)
            try values.encode(value, forKey: .photo)
        case let .text(value):
            try values.encode(Kind.text, forKey: .type)
            try values.encode(value, forKey: .text)
        case let .sticker(value):
            try values.encode(Kind.sticker, forKey: .type)
            try values.encode(value, forKey: .sticker)
        }
    }

    public var id: UUID {
        switch self {
        case let .photo(value): value.id
        case let .text(value): value.id
        case let .sticker(value): value.id
        }
    }

    public var geometry: ElementGeometry {
        get {
            switch self {
            case let .photo(value): value.geometry
            case let .text(value): value.geometry
            case let .sticker(value): value.geometry
            }
        }
        set {
            switch self {
            case var .photo(value):
                value.geometry = newValue
                self = .photo(value)
            case var .text(value):
                value.geometry = newValue
                self = .text(value)
            case var .sticker(value):
                value.geometry = newValue
                self = .sticker(value)
            }
        }
    }

    public var photoFrame: PhotoFrameElement? {
        guard case let .photo(frame) = self else { return nil }
        return frame
    }

    public var textBox: TextBoxElement? {
        guard case let .text(text) = self else { return nil }
        return text
    }

    public var sticker: StickerElement? {
        guard case let .sticker(sticker) = self else { return nil }
        return sticker
    }

    public static func visualOrder(_ lhs: PageElement, _ rhs: PageElement) -> Bool {
        if lhs.geometry.order != rhs.geometry.order {
            return lhs.geometry.order < rhs.geometry.order
        }
        return lhs.id.uuidString.lowercased() < rhs.id.uuidString.lowercased()
    }

    public func replacingID(with id: UUID) -> PageElement {
        switch self {
        case let .photo(value):
            return .photo(PhotoFrameElement(
                id: id,
                geometry: value.geometry,
                sourceTemplateSlotID: nil,
                content: value.content,
                mask: value.mask,
                border: value.border,
                decorativeFrame: value.decorativeFrame
            ))
        case let .text(value):
            return .text(TextBoxElement(
                id: id,
                geometry: value.geometry,
                sourceTemplateSlotID: nil,
                content: value.content,
                typingDefaults: value.typingDefaults,
                opacity: value.opacity,
                usesAutomaticHeight: value.usesAutomaticHeight
            ))
        case let .sticker(value):
            return .sticker(StickerElement(
                id: id,
                geometry: value.geometry,
                resource: value.resource,
                opacity: value.opacity,
                flippedHorizontally: value.flippedHorizontally
            ))
        }
    }
}

// MARK: - Layout prototype model

public enum LayoutSlotKind: String, Codable, Sendable, Equatable, Hashable {
    case photo
    case text
}

public struct LayoutSlotGeometry: Codable, Sendable, Equatable, Hashable {
    public var centerX: Double
    public var centerY: Double
    public var width: Double
    public var height: Double
    public var rotationRadians: Double

    public init(
        centerX: Double,
        centerY: Double,
        width: Double,
        height: Double,
        rotationRadians: Double = 0
    ) {
        self.centerX = centerX
        self.centerY = centerY
        self.width = width
        self.height = height
        self.rotationRadians = rotationRadians
    }

    public func elementGeometry(order: Int64) -> ElementGeometry {
        ElementGeometry(
            centerX: centerX,
            centerY: centerY,
            width: width,
            height: height,
            rotationRadians: rotationRadians,
            order: order
        )
    }
}

public struct LayoutSlotDefinition: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let id: String
    public let kind: LayoutSlotKind
    public let geometry: LayoutSlotGeometry
    public let readingOrder: Int
    public let defaultPhotoStyle: PhotoFrameStyleDefaults?
    public let defaultTextStyle: TextStyleDefaults?

    public init(
        id: String,
        kind: LayoutSlotKind,
        geometry: LayoutSlotGeometry,
        readingOrder: Int,
        defaultPhotoStyle: PhotoFrameStyleDefaults? = nil,
        defaultTextStyle: TextStyleDefaults? = nil
    ) {
        self.id = id
        self.kind = kind
        self.geometry = geometry
        self.readingOrder = readingOrder
        self.defaultPhotoStyle = defaultPhotoStyle
        self.defaultTextStyle = defaultTextStyle
    }
}

public struct LayoutTemplateDefinition: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let id: String
    public let version: Int
    public let isActive: Bool
    public let localizedNameKey: String
    public let slots: [LayoutSlotDefinition]

    public init(
        id: String,
        version: Int,
        isActive: Bool = true,
        localizedNameKey: String,
        slots: [LayoutSlotDefinition]
    ) {
        self.id = id
        self.version = version
        self.isActive = isActive
        self.localizedNameKey = localizedNameKey
        self.slots = slots
    }

    public var photoSlots: [LayoutSlotDefinition] {
        slots.filter { $0.kind == .photo }.sorted(by: LayoutSlotDefinition.slotOrder)
    }

    public var textSlots: [LayoutSlotDefinition] {
        slots.filter { $0.kind == .text }.sorted(by: LayoutSlotDefinition.slotOrder)
    }
}

private extension LayoutSlotDefinition {
    static func slotOrder(_ lhs: LayoutSlotDefinition, _ rhs: LayoutSlotDefinition) -> Bool {
        if lhs.readingOrder != rhs.readingOrder {
            return lhs.readingOrder < rhs.readingOrder
        }
        return lhs.id < rhs.id
    }
}

// MARK: - Local records

public struct PhotoAssetRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let albumID: UUID
    public var metadata: PhotoAssetMetadata

    public var id: UUID { metadata.id }

    public init(albumID: UUID, metadata: PhotoAssetMetadata) {
        self.albumID = albumID
        self.metadata = metadata
    }
}

public enum AssetState: String, Codable, Sendable, Equatable, Hashable {
    case available
    case orphaned
    case staging
    case missing
}

public struct AssetBlobIndexEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let contentHash: String
    public let relativePath: String
    public let byteCount: Int64
    public let detectedContentType: String
    public var referenceCount: Int
    public var state: AssetState

    public var id: String { contentHash }

    public init(
        contentHash: String,
        relativePath: String,
        byteCount: Int64,
        detectedContentType: String,
        referenceCount: Int = 0,
        state: AssetState = .available
    ) {
        self.contentHash = contentHash
        self.relativePath = relativePath
        self.byteCount = byteCount
        self.detectedContentType = detectedContentType
        self.referenceCount = referenceCount
        self.state = state
    }
}

public enum AlbumDeletionReason: String, Codable, Sendable, Equatable, Hashable {
    case userConfirmed
    case retentionExpired
}

/// Durable proof that an album identity was intentionally removed. It does
/// not retain logical asset identifiers or authorize deletion of any blob
/// (3:ALB-020, 3:LOC-008).
public struct AlbumDeletionTombstone: Codable, Sendable, Equatable, Hashable, Identifiable {
    public static let recoveryDuration: TimeInterval = 30 * 24 * 60 * 60

    public let albumID: UUID
    public let trashedAt: Date
    public let deletedAt: Date
    public let reason: AlbumDeletionReason
    public let albumLogicalHash: String
    public let deletionCommandID: UUID

    public var id: UUID { albumID }

    public init(
        albumID: UUID,
        trashedAt: Date,
        deletedAt: Date,
        reason: AlbumDeletionReason,
        albumLogicalHash: String,
        deletionCommandID: UUID
    ) {
        self.albumID = albumID
        self.trashedAt = trashedAt
        self.deletedAt = deletedAt
        self.reason = reason
        self.albumLogicalHash = albumLogicalHash
        self.deletionCommandID = deletionCommandID
    }
}

public struct LocalLibrarySnapshot: Codable, Sendable, Equatable {
    public let modelGeneration: String
    public let schemaVersion: Int
    public var revision: UInt64
    public var albums: [AlbumSnapshot]
    public var photoAssets: [PhotoAssetRecord]
    public var blobIndex: [AssetBlobIndexEntry]
    public var albumDeletionTombstones: [AlbumDeletionTombstone]
    public var appliedCommandIDs: [UUID]

    public init(
        modelGeneration: String = AlbumModelVersion.generation,
        schemaVersion: Int = AlbumModelVersion.schemaVersion,
        revision: UInt64 = 0,
        albums: [AlbumSnapshot] = [],
        photoAssets: [PhotoAssetRecord] = [],
        blobIndex: [AssetBlobIndexEntry] = [],
        albumDeletionTombstones: [AlbumDeletionTombstone] = [],
        appliedCommandIDs: [UUID] = []
    ) {
        self.modelGeneration = modelGeneration
        self.schemaVersion = schemaVersion
        self.revision = revision
        self.albums = albums
        self.photoAssets = photoAssets
        self.blobIndex = blobIndex
        self.albumDeletionTombstones = albumDeletionTombstones
        self.appliedCommandIDs = appliedCommandIDs
    }

    private enum CodingKeys: String, CodingKey {
        case modelGeneration
        case schemaVersion
        case revision
        case albums
        case photoAssets
        case blobIndex
        case albumDeletionTombstones
        case appliedCommandIDs
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        modelGeneration = try container.decode(String.self, forKey: .modelGeneration)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        revision = try container.decode(UInt64.self, forKey: .revision)
        albums = try container.decode([AlbumSnapshot].self, forKey: .albums)
        photoAssets = try container.decode([PhotoAssetRecord].self, forKey: .photoAssets)
        blobIndex = try container.decode([AssetBlobIndexEntry].self, forKey: .blobIndex)
        albumDeletionTombstones = try container.decodeIfPresent(
            [AlbumDeletionTombstone].self,
            forKey: .albumDeletionTombstones
        ) ?? []
        appliedCommandIDs = try container.decode([UUID].self, forKey: .appliedCommandIDs)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(modelGeneration, forKey: .modelGeneration)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(revision, forKey: .revision)
        try container.encode(albums, forKey: .albums)
        try container.encode(photoAssets, forKey: .photoAssets)
        try container.encode(blobIndex, forKey: .blobIndex)
        try container.encode(albumDeletionTombstones, forKey: .albumDeletionTombstones)
        try container.encode(appliedCommandIDs, forKey: .appliedCommandIDs)
    }

    public static let empty = LocalLibrarySnapshot()

    public func album(id: UUID) -> AlbumSnapshot? {
        albums.first { $0.id == id }
    }

    public func photoAsset(id: UUID) -> PhotoAssetMetadata? {
        photoAssets.first { $0.metadata.id == id }?.metadata
    }

    public func photoAssets(in albumID: UUID) -> [PhotoAssetMetadata] {
        guard let album = album(id: albumID) else { return [] }
        let metadata = Dictionary(uniqueKeysWithValues: photoAssets.map { ($0.id, $0.metadata) })
        return album.photoAssetIDs.compactMap { metadata[$0] }
    }
}

public struct AppSettings: Codable, Sendable, Equatable, Hashable {
    public var slideshow: SlideshowSettings

    public init(slideshow: SlideshowSettings = SlideshowSettings()) {
        self.slideshow = slideshow
    }
}

public struct SlideshowSettings: Codable, Sendable, Equatable, Hashable {
    public var screenDurationSeconds: Double
    public var loops: Bool

    public init(screenDurationSeconds: Double = 5, loops: Bool = false) {
        self.screenDurationSeconds = screenDurationSeconds
        self.loops = loops
    }
}
