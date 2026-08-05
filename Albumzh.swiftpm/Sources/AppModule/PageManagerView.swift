import AlbumPhotoCore
import SwiftUI

struct PageManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var editMode: EditMode = .active
    let model: AlbumEditorViewModel
    let assetStore: MediaAssetStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(model.album.pages.enumerated()), id: \.element.id) {
                    index,
                    page in
                    HStack(spacing: 16) {
                        PageThumbnailView(
                            page: page,
                            backgroundID: model.album.backgroundID,
                            assetStore: assetStore
                        )
                        .frame(width: 64, height: 80)

                        Text("Page \(index + 1)")
                            .font(.headline)

                        if page.id == model.activePageID {
                            Spacer()
                            Text("Active")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(
                        page.id == model.activePageID
                            ? "Page \(index + 1), active"
                            : "Page \(index + 1)"
                    )
                }
                .onMove { source, destination in
                    Task {
                        await model.movePages(
                            fromOffsets: source,
                            toOffset: destination
                        )
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Gérer les pages")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Terminé") {
                        dismiss()
                    }
                }
            }
        }
    }
}
