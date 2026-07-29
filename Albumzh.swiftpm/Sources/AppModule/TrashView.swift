import AlbumPhotoCore
import SwiftUI

@MainActor
@Observable
final class TrashViewModel {
    private let service: AlbumService

    var albums: [Album] = []
    var errorMessage: String?

    init(service: AlbumService) {
        self.service = service
    }

    func load() async {
        do {
            albums = try await service.trashedAlbums()
        } catch {
            errorMessage = "Impossible de charger la corbeille."
        }
    }

    func restore(_ album: Album) async {
        do {
            _ = try await service.restoreAlbum(album.id)
            albums = try await service.trashedAlbums()
        } catch {
            errorMessage = "Impossible de restaurer l’album."
        }
    }
}

struct TrashView: View {
    @State private var model: TrashViewModel

    init(service: AlbumService) {
        _model = State(initialValue: TrashViewModel(service: service))
    }

    var body: some View {
        Group {
            if model.albums.isEmpty {
                ContentUnavailableView(
                    "Corbeille vide",
                    systemImage: "trash",
                    description: Text("Les albums supprimés apparaîtront ici.")
                )
            } else {
                List(model.albums) { album in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(album.name)
                                .font(.headline)
                            if let trashedAt = album.trashedAt {
                                Text(
                                    "Supprimé le \(trashedAt.formatted(date: .abbreviated, time: .shortened))"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Button("Restaurer") {
                            Task { await model.restore(album) }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .navigationTitle("Corbeille")
        .task {
            await model.load()
        }
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
