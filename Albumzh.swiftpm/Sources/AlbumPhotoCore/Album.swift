import Foundation

public enum DisplayMode: String, Codable, Sendable, Hashable {
    case singlePage
    case doublePage
}

public enum CoverSelection: Codable, Sendable, Equatable {
    case automatic
    case pageMedia(pageID: UUID, assetID: UUID)
}

public struct MediaPlacement: Codable, Sendable, Equatable {
    public let assetID: UUID
    public var normalizedScale: Double
    public var normalizedOffsetX: Double
    public var normalizedOffsetY: Double

    public init(
        assetID: UUID,
        normalizedScale: Double = 1,
        normalizedOffsetX: Double = 0,
        normalizedOffsetY: Double = 0
    ) {
        self.assetID = assetID
        self.normalizedScale = normalizedScale
        self.normalizedOffsetX = normalizedOffsetX
        self.normalizedOffsetY = normalizedOffsetY
    }

    private enum CodingKeys: String, CodingKey {
        case assetID, normalizedScale, normalizedOffsetX, normalizedOffsetY
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        assetID = try values.decode(UUID.self, forKey: .assetID)
        normalizedScale = try values.decodeIfPresent(
            Double.self,
            forKey: .normalizedScale
        ) ?? 1
        normalizedOffsetX = try values.decodeIfPresent(
            Double.self,
            forKey: .normalizedOffsetX
        ) ?? 0
        normalizedOffsetY = try values.decodeIfPresent(
            Double.self,
            forKey: .normalizedOffsetY
        ) ?? 0
    }
}

public struct Page: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public var mediaPlacement: MediaPlacement?

    public init(id: UUID = UUID(), mediaPlacement: MediaPlacement? = nil) {
        self.id = id
        self.mediaPlacement = mediaPlacement
    }
}

public extension Album {
    var resolvedCoverOccurrence: CoverSelection? {
        if case let .pageMedia(pageID, assetID) = coverSelection,
           pages.contains(where: { $0.id == pageID && $0.mediaPlacement?.assetID == assetID }) {
            return coverSelection
        }
        guard let page = pages.first(where: { $0.mediaPlacement != nil }),
              let assetID = page.mediaPlacement?.assetID else { return nil }
        return .pageMedia(pageID: page.id, assetID: assetID)
    }
}

public struct Album: Identifiable, Codable, Sendable, Equatable {
    public static let currentSchemaVersion = 1
    public static let classicSpiralBackgroundID = "album.classicSpiral"

    public let schemaVersion: Int
    public let id: UUID
    public var name: String
    public var backgroundID: String
    public var preferredDisplayMode: DisplayMode
    public var coverSelection: CoverSelection
    public var pages: [Page]
    public let createdAt: Date
    public var updatedAt: Date
    public var trashedAt: Date?

    public init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        firstPageID: UUID = UUID()
    ) {
        self.schemaVersion = Self.currentSchemaVersion
        self.id = id
        self.name = name
        self.backgroundID = Self.classicSpiralBackgroundID
        self.preferredDisplayMode = .doublePage
        self.coverSelection = .automatic
        self.pages = [Page(id: firstPageID)]
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.trashedAt = nil
    }
}
