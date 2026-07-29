import AlbumPhotoCore
import SwiftUI

@MainActor
@Observable
final class LibraryViewModel {
    let service: AlbumService

    var albums: [Album] = []
    var isCreatingAlbum = false
    var proposedName = ""
    var errorMessage: String?

    init(service: AlbumService) {
        self.service = service
    }

    func load() async {
        do {
            albums = try await service.albums()
        } catch {
            errorMessage = "Impossible de charger les albums."
        }
    }

    func createAlbum() async {
        do {
            _ = try await service.createAlbum(named: proposedName)
            proposedName = ""
            isCreatingAlbum = false
            albums = try await service.albums()
        } catch AlbumValidationError.emptyName {
            errorMessage = "Le nom de l’album ne peut pas être vide."
        } catch {
            errorMessage = "Impossible de créer l’album."
        }
    }
}

struct LibraryView: View {
    @State private var model: LibraryViewModel

    init(service: AlbumService) {
        _model = State(initialValue: LibraryViewModel(service: service))
    }

    private let columns = [
        GridItem(.adaptive(minimum: 180), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if model.albums.isEmpty {
                    ContentUnavailableView {
                        Label("Aucun album", systemImage: "photo.on.rectangle.angled")
                    } description: {
                        Text("Créez votre premier album photo.")
                    } actions: {
                        Button("Créer un album") {
                            model.isCreatingAlbum = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(model.albums) { album in
                                NavigationLink {
                                    AlbumEditorView(album: album, service: model.service)
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.brown.gradient)
                                                .aspectRatio(4 / 3, contentMode: .fit)
                                            Text(album.name)
                                                .font(.title3.bold())
                                                .foregroundStyle(.white)
                                                .multilineTextAlignment(.center)
                                                .padding()
                                        }
                                        Text(album.name)
                                            .font(.headline)
                                        Text(
                                            album.updatedAt,
                                            format: .dateTime.day().month().year()
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                    .accessibilityElement(children: .combine)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Albums")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Créer", systemImage: "plus") {
                        model.isCreatingAlbum = true
                    }
                }
            }
            .task {
                await model.load()
            }
            .alert("Nouvel album", isPresented: $model.isCreatingAlbum) {
                TextField("Nom", text: $model.proposedName)
                Button("Annuler", role: .cancel) {
                    model.proposedName = ""
                }
                Button("Créer") {
                    Task { await model.createAlbum() }
                }
            } message: {
                Text("Choisissez un nom pour l’album.")
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
}
