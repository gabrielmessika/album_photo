import AlbumPhotoCore
import Combine
import SwiftUI

private struct AlbumRenameRequest: Identifiable {
    let album: AlbumSnapshot
    var id: UUID { album.id }
}

private struct AlbumTrashRequest: Identifiable {
    let album: AlbumSnapshot
    var id: UUID { album.id }
}

private struct AlbumCoverRequest: Identifiable {
    let albumID: UUID
    var id: UUID { albumID }
}

struct LibraryView: View {
    @EnvironmentObject private var appModel: AppModel

    @State private var showsCreateAlbum = false
    @State private var renameRequest: AlbumRenameRequest?
    @State private var trashRequest: AlbumTrashRequest?
    @State private var coverRequest: AlbumCoverRequest?
    @State private var showsTrash = false
    @State private var openedAlbum: AlbumRoute?

    private let maintenanceTimer = Timer.publish(
        every: 6 * 60 * 60,
        on: .main,
        in: .common
    ).autoconnect()

    private let columns = [
        GridItem(.adaptive(minimum: 210, maximum: 340), spacing: 22)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if appModel.isLoading && appModel.albums.isEmpty {
                    ProgressView("Chargement de vos albums…")
                } else if appModel.albums.isEmpty {
                    ContentUnavailableView {
                        Label("Aucun album", systemImage: "rectangle.stack.badge.plus")
                    } description: {
                        Text("Créez un album pour composer librement chaque page.")
                    } actions: {
                        Button("Créer un album") { showsCreateAlbum = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(appModel.albums) { album in
                                albumCard(album)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Mes albums")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Annuler", systemImage: "arrow.uturn.backward") {
                        Task { await appModel.undoLibraryAction() }
                    }
                    .disabled(!appModel.canUndoLibrary)
                    .keyboardShortcut("z", modifiers: .command)

                    Button("Rétablir", systemImage: "arrow.uturn.forward") {
                        Task { await appModel.redoLibraryAction() }
                    }
                    .disabled(!appModel.canRedoLibrary)
                    .keyboardShortcut("z", modifiers: [.command, .shift])
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Corbeille", systemImage: "trash") {
                        showsTrash = true
                    }

                    Button("Créer un album", systemImage: "plus") {
                        showsCreateAlbum = true
                    }
                    .keyboardShortcut("n", modifiers: .command)
                }
            }
            .task { await appModel.loadLibrary() }
            .refreshable { await appModel.loadLibrary() }
            .onReceive(maintenanceTimer) { _ in
                Task { await appModel.loadLibrary() }
            }
        }
        .sheet(isPresented: $showsCreateAlbum) {
            AlbumNameSheet(
                title: "Nouvel album",
                actionTitle: "Créer",
                initialName: ""
            ) { name in
                showsCreateAlbum = false
                Task {
                    guard let album = await appModel.createAlbum(named: name),
                          await appModel.prepareToOpenAlbum(album.id) else { return }
                    openedAlbum = AlbumRoute(albumID: album.id)
                }
            }
        }
        .sheet(item: $renameRequest) { request in
            AlbumNameSheet(
                title: "Renommer l’album",
                actionTitle: "Renommer",
                initialName: request.album.name
            ) { name in
                let albumID = request.album.id
                renameRequest = nil
                Task { _ = await appModel.renameAlbum(id: albumID, to: name) }
            }
        }
        .sheet(item: $coverRequest) { request in
            CoverPickerView(albumID: request.albumID)
                .environmentObject(appModel)
        }
        .sheet(isPresented: $showsTrash) {
            TrashView()
                .environmentObject(appModel)
        }
        .fullScreenCover(item: $openedAlbum, onDismiss: {
            Task { try? await appModel.refreshLibrary() }
        }) { route in
            AlbumEditorView(albumID: route.albumID)
                .environmentObject(appModel)
        }
        .alert(item: $trashRequest) { request in
            Alert(
                title: Text("Placer « \(request.album.name) » dans la corbeille ?"),
                message: Text(
                    "L’album pourra être restauré pendant 30 jours avant sa suppression automatique."
                ),
                primaryButton: .destructive(Text("Mettre à la corbeille")) {
                    Task { _ = await appModel.moveToTrash(id: request.album.id) }
                },
                secondaryButton: .cancel(Text("Annuler"))
            )
        }
        .alert(
            "Une action n’a pas pu être terminée",
            isPresented: Binding(
                get: { appModel.errorMessage != nil },
                set: { if !$0 { appModel.clearError() } }
            )
        ) {
            Button("OK") { appModel.clearError() }
        } message: {
            Text(appModel.errorMessage ?? "")
        }
    }

    private func albumCard(_ album: AlbumSnapshot) -> some View {
        Button {
            openAlbum(album.id)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                AlbumCoverView(
                    album: album,
                    library: appModel.librarySnapshot,
                    imageCache: appModel.imageCache
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.secondary.opacity(0.25), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.13), radius: 7, y: 3)

                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(album.name)
                            .font(.headline)
                            .lineLimit(2)
                        Text("\(album.pages.count) page\(album.pages.count > 1 ? "s" : "")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(
                            "Modifié \(album.updatedAt.formatted(.relative(presentation: .named)))"
                        )
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Ouvrir", systemImage: "square.and.pencil") {
                openAlbum(album.id)
            }
            Button("Renommer", systemImage: "pencil") {
                renameRequest = AlbumRenameRequest(album: album)
            }
            Button("Choisir la couverture", systemImage: "photo.on.rectangle") {
                coverRequest = AlbumCoverRequest(albumID: album.id)
            }
            Divider()
            Button("Mettre à la corbeille", systemImage: "trash", role: .destructive) {
                trashRequest = AlbumTrashRequest(album: album)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(album.name), \(album.pages.count) pages")
        .accessibilityHint("Ouvre l’album dans l’éditeur")
        .accessibilityAction(named: "Renommer") {
            renameRequest = AlbumRenameRequest(album: album)
        }
        .accessibilityAction(named: "Choisir la couverture") {
            coverRequest = AlbumCoverRequest(albumID: album.id)
        }
        .accessibilityAction(named: "Mettre à la corbeille") {
            trashRequest = AlbumTrashRequest(album: album)
        }
    }

    private func openAlbum(_ albumID: UUID) {
        Task {
            guard await appModel.prepareToOpenAlbum(albumID) else { return }
            openedAlbum = AlbumRoute(albumID: albumID)
        }
    }
}

private struct AlbumNameSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let actionTitle: String
    let initialName: String
    let onConfirm: (String) -> Void

    @State private var name: String

    init(
        title: String,
        actionTitle: String,
        initialName: String,
        onConfirm: @escaping (String) -> Void
    ) {
        self.title = title
        self.actionTitle = actionTitle
        self.initialName = initialName
        self.onConfirm = onConfirm
        _name = State(initialValue: initialName)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nom de l’album", text: $name)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.done)
                    .onSubmit(confirm)

                if trimmedName.isEmpty {
                    Label("Saisissez un nom non vide.", systemImage: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(actionTitle, action: confirm)
                        .disabled(trimmedName.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func confirm() {
        guard !trimmedName.isEmpty else { return }
        onConfirm(trimmedName)
    }
}
