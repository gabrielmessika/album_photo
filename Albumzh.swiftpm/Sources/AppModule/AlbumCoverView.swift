import AlbumPhotoCore
import SwiftUI

struct AlbumCoverView: View {
    let album: Album
    let assetStore: MediaAssetStore

    var body: some View {
        AlbumPageBackground(backgroundID: album.backgroundID)
        .aspectRatio(4 / 3, contentMode: .fit)
        .overlay {
            if case let .pageMedia(_, assetID)? = album.resolvedCoverOccurrence {
                StoredImageView(assetID: assetID, store: assetStore)
                    .clipped()
            } else {
                Text(album.name)
                    .font(.title3.bold())
                    .foregroundStyle(
                        album.backgroundID == "album.minimalDark" ? .white : .black
                    )
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 8)
                    )
                    .padding()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Couverture de l’album \(album.name)")
    }
}

struct CoverPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let album: Album
    let service: AlbumService
    let assetStore: MediaAssetStore

    private var mediaPages: [(offset: Int, element: Page)] {
        Array(album.pages.enumerated()).filter { $0.element.mediaPlacement != nil }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                AlbumCoverView(album: album, assetStore: assetStore)
                    .frame(maxWidth: 360)

                if mediaPages.isEmpty {
                    ContentUnavailableView(
                        "Aucun média disponible",
                        systemImage: "photo.badge.plus",
                        description: Text(
                            "La couverture affiche automatiquement le nom sur le fond de l’album. "
                                + "Après l’ajout de médias aux pages, vous pourrez choisir une occurrence existante."
                        )
                    )
                } else {
                    List {
                        Button("Automatique") {
                            choose(.automatic)
                        }
                        ForEach(mediaPages, id: \.element.id) { index, page in
                            if let assetID = page.mediaPlacement?.assetID {
                                Button("Page \(index + 1)") {
                                    choose(.pageMedia(pageID: page.id, assetID: assetID))
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Choisir la couverture")
            .toolbar {
                Button("Fermer") { dismiss() }
            }
        }
    }

    private func choose(_ selection: CoverSelection) {
        Task {
            _ = try? await service.changeCover(of: album.id, to: selection)
            dismiss()
        }
    }
}
