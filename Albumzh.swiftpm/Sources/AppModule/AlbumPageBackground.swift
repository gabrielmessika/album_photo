import AlbumPhotoCore
import SwiftUI

/// Rendu partagé des fonds du lot 1. Les trois images sont embarquées dans
/// `Backgrounds.xcassets` afin que le manifeste Swift Playgrounds reste généré.
struct AlbumPageBackground: View {
    let selection: BackgroundSelection
    var imageCache: PhotoImageCache?
    var maximumPixelSize: Int

    init(
        selection: BackgroundSelection,
        imageCache: PhotoImageCache?,
        maximumPixelSize: Int = 2_048
    ) {
        self.selection = selection
        self.imageCache = imageCache
        self.maximumPixelSize = maximumPixelSize
    }

    var body: some View {
        Group {
            switch selection {
            case .none:
                Color.white
            case let .solid(color):
                color.swiftUIColor
            case let .catalog(reference):
                BundledBackgroundImage(
                    dataAssetName: Self.dataAssetName(for: reference.catalogID),
                    fallbackContentHash: reference.fallbackContentHash,
                    cache: imageCache,
                    maximumPixelSize: maximumPixelSize
                )
                    .aspectRatio(4.0 / 5.0, contentMode: .fill)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .accessibilityHidden(true)
    }

    static func localizedName(for selection: BackgroundSelection) -> String {
        switch selection {
        case .none:
            return "Aucun"
        case .solid:
            return "Couleur unie"
        case let .catalog(reference):
            return BackgroundCatalog.theme(id: reference.catalogID)?.localizedName
                ?? "Fond indisponible"
        }
    }

    static func dataAssetName(for catalogID: String) -> String {
        switch catalogID {
        case "album.classicSpiral": "AlbumClassicSpiralData"
        case "album.travelKraft": "AlbumTravelKraftData"
        case "album.minimalDark": "AlbumMinimalDarkData"
        default: "MissingCatalogResource"
        }
    }
}

extension SRGBAColor {
    var swiftUIColor: Color {
        Color(
            .sRGB,
            red: red,
            green: green,
            blue: blue,
            opacity: alpha
        )
    }
}
