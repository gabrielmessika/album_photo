import AlbumPhotoCore
import SwiftUI

@MainActor
@Observable
final class LibraryViewModel {
    private struct RenameAction {
        let albumID: UUID
        let oldName: String
        let newName: String
    }

    let service: AlbumService

    var albums: [Album] = []
    var isCreatingAlbum = false
    var proposedName = ""
    var albumBeingRenamed: Album?
    var proposedRename = ""
    var albumPendingTrash: Album?
    var errorMessage: String?
    private var undoRenames: [RenameAction] = []
    private var redoRenames: [RenameAction] = []

    var canUndoRename: Bool { !undoRenames.isEmpty }
    var canRedoRename: Bool { !redoRenames.isEmpty }

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

    func beginRenaming(_ album: Album) {
        albumBeingRenamed = album
        proposedRename = album.name
    }

    func renameAlbum() async {
        guard let album = albumBeingRenamed else { return }

        do {
            let renamed = try await service.renameAlbum(
                album.id,
                to: proposedRename
            )
            undoRenames.append(
                RenameAction(
                    albumID: album.id,
                    oldName: album.name,
                    newName: renamed.name
                )
            )
            redoRenames.removeAll()
            albumBeingRenamed = nil
            proposedRename = ""
            albums = try await service.albums()
        } catch AlbumValidationError.emptyName {
            errorMessage = "Le nom de l’album ne peut pas être vide."
        } catch {
            errorMessage = "Impossible de renommer l’album."
        }
    }

    func movePendingAlbumToTrash() async {
        guard let album = albumPendingTrash else { return }

        do {
            _ = try await service.moveAlbumToTrash(album.id)
            albumPendingTrash = nil
            albums = try await service.albums()
        } catch {
            errorMessage = "Impossible de déplacer l’album dans la corbeille."
        }
    }

    func undoRename() async {
        guard let action = undoRenames.popLast() else { return }

        do {
            _ = try await service.renameAlbum(
                action.albumID,
                to: action.oldName
            )
            redoRenames.append(action)
            albums = try await service.albums()
        } catch {
            undoRenames.append(action)
            errorMessage = "Impossible d’annuler le renommage."
        }
    }

    func redoRename() async {
        guard let action = redoRenames.popLast() else { return }

        do {
            _ = try await service.renameAlbum(
                action.albumID,
                to: action.newName
            )
            undoRenames.append(action)
            albums = try await service.albums()
        } catch {
            redoRenames.append(action)
            errorMessage = "Impossible de rétablir le renommage."
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
                                .contextMenu {
                                    Button("Renommer", systemImage: "pencil") {
                                        model.beginRenaming(album)
                                    }
                                    Button(
                                        "Supprimer",
                                        systemImage: "trash",
                                        role: .destructive
                                    ) {
                                        model.albumPendingTrash = album
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Albums")
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button("Annuler le renommage", systemImage: "arrow.uturn.backward") {
                        Task { await model.undoRename() }
                    }
                    .disabled(!model.canUndoRename)

                    Button("Rétablir le renommage", systemImage: "arrow.uturn.forward") {
                        Task { await model.redoRename() }
                    }
                    .disabled(!model.canRedoRename)

                    NavigationLink {
                        TrashView(service: model.service)
                    } label: {
                        Label("Corbeille", systemImage: "trash")
                    }
                }

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
                "Renommer l’album",
                isPresented: Binding(
                    get: { model.albumBeingRenamed != nil },
                    set: {
                        if !$0 {
                            model.albumBeingRenamed = nil
                            model.proposedRename = ""
                        }
                    }
                )
            ) {
                TextField("Nom", text: $model.proposedRename)
                Button("Annuler", role: .cancel) {}
                Button("Renommer") {
                    Task { await model.renameAlbum() }
                }
            } message: {
                Text("Saisissez le nouveau nom de l’album.")
            }
            .confirmationDialog(
                "Placer cet album dans la corbeille ?",
                isPresented: Binding(
                    get: { model.albumPendingTrash != nil },
                    set: { if !$0 { model.albumPendingTrash = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Placer dans la corbeille", role: .destructive) {
                    Task { await model.movePendingAlbumToTrash() }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text(
                    "L’album pourra être restauré pendant trente jours."
                )
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
