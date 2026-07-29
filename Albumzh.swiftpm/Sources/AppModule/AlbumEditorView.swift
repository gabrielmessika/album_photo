import AlbumPhotoCore
import SwiftUI

@MainActor
@Observable
final class AlbumEditorViewModel {
    private let service: AlbumService

    var album: Album
    var activePageID: UUID
    var errorMessage: String?

    init(album: Album, service: AlbumService) {
        self.album = album
        self.activePageID = album.pages[0].id
        self.service = service
    }

    func addPage() async {
        do {
            album = try await service.addPage(
                to: album.id,
                after: activePageID
            )
            if let activeIndex = album.pages.firstIndex(
                where: { $0.id == activePageID }
            ) {
                activePageID = album.pages[activeIndex + 1].id
            }
        } catch {
            errorMessage = "Impossible d’ajouter la page."
        }
    }
}

struct AlbumEditorView: View {
    @State private var model: AlbumEditorViewModel

    init(album: Album, service: AlbumService) {
        _model = State(
            initialValue: AlbumEditorViewModel(album: album, service: service)
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Label("Mode édition", systemImage: "pencil")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(Array(model.album.pages.enumerated()), id: \.element.id) {
                        index,
                        page in
                        Button {
                            model.activePageID = page.id
                        } label: {
                            VStack(spacing: 8) {
                                AlbumPageBackground(
                                    backgroundID: model.album.backgroundID
                                )
                                    .aspectRatio(4 / 5, contentMode: .fit)
                                    .frame(width: 220)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                model.activePageID == page.id
                                                    ? Color.accentColor
                                                    : Color.secondary.opacity(0.3),
                                                lineWidth: model.activePageID == page.id ? 3 : 1
                                            )
                                    }
                                    .shadow(radius: 3)
                                Text("Page \(index + 1)")
                                    .font(.headline)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Page \(index + 1)")
                        .accessibilityAddTraits(
                            model.activePageID == page.id ? .isSelected : []
                        )
                    }
                }
                .padding()
            }

            Button("Ajouter une page", systemImage: "plus.rectangle.on.rectangle") {
                Task { await model.addPage() }
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .navigationTitle(model.album.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Erreur",
            isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { if !$0 { model.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}
