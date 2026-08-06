import AlbumPhotoCore
import SwiftUI

struct CropEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let model: AlbumEditorViewModel
    let assetStore: MediaAssetStore
    @State private var placement: MediaPlacement

    init(
        model: AlbumEditorViewModel,
        initialPlacement: MediaPlacement,
        assetStore: MediaAssetStore
    ) {
        self.model = model
        self.assetStore = assetStore
        _placement = State(initialValue: initialPlacement)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                PlacedMediaView(placement: placement, store: assetStore)
                    .aspectRatio(4 / 5, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay { RoundedRectangle(cornerRadius: 12).stroke(.secondary) }

                LabeledContent("Zoom ×\(placement.normalizedScale, format: .number.precision(.fractionLength(1)))") {
                    Slider(value: $placement.normalizedScale, in: 1...8)
                }
                LabeledContent("Horizontal") {
                    Slider(value: $placement.normalizedOffsetX, in: -1...1)
                }
                LabeledContent("Vertical") {
                    Slider(value: $placement.normalizedOffsetY, in: -1...1)
                }

                Button("Réinitialiser", systemImage: "arrow.counterclockwise") {
                    placement.normalizedScale = 1
                    placement.normalizedOffsetX = 0
                    placement.normalizedOffsetY = 0
                }
            }
            .padding()
            .navigationTitle("Recadrer la photo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Terminé") {
                        Task {
                            if await model.applyCrop(placement) { dismiss() }
                        }
                    }
                }
            }
        }
    }
}
