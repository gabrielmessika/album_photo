import AlbumPhotoCore
import SwiftUI

struct PageManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var editMode: EditMode = .active
    let model: AlbumEditorViewModel
    let assetStore: MediaAssetStore

    var body: some View {
        let pages = model.album.pages
        let backgroundID = model.album.backgroundID
        let activePageID = model.activePageID

        NavigationStack {
            List {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    PageManagerRow(
                        page: page,
                        pageNumber: index + 1,
                        backgroundID: backgroundID,
                        isActive: page.id == activePageID,
                        assetStore: assetStore
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

private struct PageManagerRow: View {
    let page: Page
    let pageNumber: Int
    let backgroundID: String
    let isActive: Bool
    let assetStore: MediaAssetStore

    var body: some View {
        HStack(spacing: 16) {
            PageThumbnailView(
                page: page,
                backgroundID: backgroundID,
                assetStore: assetStore
            )
            .frame(width: 64, height: 80)

            Text("Page \(pageNumber)")
                .font(.headline)

            if isActive {
                Spacer()
                Text("Active")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            isActive ? "Page \(pageNumber), active" : "Page \(pageNumber)"
        )
    }
}
