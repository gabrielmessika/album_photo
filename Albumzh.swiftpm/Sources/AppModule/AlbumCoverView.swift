import AlbumPhotoCore
import SwiftUI

struct AlbumCoverView: View {
    let album: Album

    var body: some View {
        AlbumPageBackground(backgroundID: album.backgroundID)
        .aspectRatio(4 / 3, contentMode: .fit)
        .overlay {
            Text(album.name)
                .font(.title3.bold())
                .foregroundStyle(album.backgroundID == "album.minimalDark" ? .white : .black)
                .multilineTextAlignment(.center)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .padding()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Couverture de l’album \(album.name)")
    }
}

struct CoverPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let album: Album

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                AlbumCoverView(album: album)
                    .frame(maxWidth: 360)

                ContentUnavailableView(
                    "Aucun média disponible",
                    systemImage: "photo.badge.plus",
                    description: Text(
                        "La couverture affiche automatiquement le nom sur le fond de l’album. "
                            + "Après l’ajout de médias aux pages, vous pourrez choisir une occurrence existante."
                    )
                )
            }
            .padding()
            .navigationTitle("Choisir la couverture")
            .toolbar {
                Button("Fermer") { dismiss() }
            }
        }
    }
}
