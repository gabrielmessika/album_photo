public enum TextContrastHint: String, Codable, Sendable {
    case darkText
    case lightText
}

public struct BackgroundTheme: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let localizedName: String
    public let textContrastHint: TextContrastHint
    public let version: Int

    public init(
        id: String,
        localizedName: String,
        textContrastHint: TextContrastHint,
        version: Int = 1
    ) {
        self.id = id
        self.localizedName = localizedName
        self.textContrastHint = textContrastHint
        self.version = version
    }
}

public enum BackgroundCatalog {
    public static let themes = [
        BackgroundTheme(
            id: "album.classicSpiral",
            localizedName: "Album classique",
            textContrastHint: .darkText
        ),
        BackgroundTheme(
            id: "album.travelKraft",
            localizedName: "Carnet de voyage",
            textContrastHint: .darkText
        ),
        BackgroundTheme(
            id: "album.minimalDark",
            localizedName: "Nuit minimaliste",
            textContrastHint: .lightText
        )
    ]

    public static func theme(id: String) -> BackgroundTheme {
        themes.first(where: { $0.id == id }) ?? themes[0]
    }
}
