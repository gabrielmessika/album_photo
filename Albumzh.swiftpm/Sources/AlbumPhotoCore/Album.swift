import Foundation

public enum DisplayMode: String, Codable, Sendable, Hashable {
    case singlePage
    case doublePage
}

public enum CoverSelection: Codable, Sendable, Equatable {
    case automatic
    case pageMedia(pageID: UUID, assetID: UUID)
}

public struct Page: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID

    public init(id: UUID = UUID()) {
        self.id = id
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
