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
    @State private var album: Album
    let service: AlbumService
    let assetStore: MediaAssetStore
    let onAlbumChanged: (Album) -> Void

    init(
        album: Album,
        service: AlbumService,
        assetStore: MediaAssetStore,
        onAlbumChanged: @escaping (Album) -> Void
    ) {
        _album = State(initialValue: album)
        self.service = service
        self.assetStore = assetStore
        self.onAlbumChanged = onAlbumChanged
    }

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
                                Button {
                                    choose(.pageMedia(pageID: page.id, assetID: assetID))
                                } label: {
                                    HStack {
                                        PageThumbnailView(
                                            page: page,
                                            backgroundID: album.backgroundID,
                                            assetStore: assetStore
                                        )
                                        .frame(width: 64, height: 80)
                                        Text("Page \(index + 1)")
                                        Spacer()
                                        if album.coverSelection == .pageMedia(
                                            pageID: page.id,
                                            assetID: assetID
                                        ) {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Choisir la couverture")
            .toolbar {
                Button("Terminé") { dismiss() }
            }
        }
    }

    private func choose(_ selection: CoverSelection) {
        Task {
            if let updated = try? await service.changeCover(of: album.id, to: selection) {
                album = updated
                onAlbumChanged(updated)
            }
        }
    }
}
