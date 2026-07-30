import AlbumPhotoCore
import SwiftUI

struct BackgroundPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let model: AlbumEditorViewModel

    var body: some View {
        NavigationStack {
            List(BackgroundCatalog.themes) { theme in
                Button {
                    Task {
                        await model.changeBackground(to: theme.id)
                        dismiss()
                    }
                } label: {
                    HStack {
                        AlbumPageBackground(backgroundID: theme.id)
                            .frame(width: 48, height: 60)
                        Text(theme.localizedName)
                        Spacer()
                        if model.album.backgroundID == theme.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .navigationTitle("Fond de l’album")
            .toolbar {
                Button("Fermer") { dismiss() }
            }
        }
    }
}
