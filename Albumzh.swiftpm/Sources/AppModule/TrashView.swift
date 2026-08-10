import AlbumPhotoCore
import SwiftUI

private struct PermanentAlbumDeletionRequest: Identifiable {
    let album: AlbumSnapshot
    var id: UUID { album.id }
}

struct TrashView: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.dismiss) private var dismiss

    @State private var deletionRequest: PermanentAlbumDeletionRequest?

    var body: some View {
        NavigationStack {
            Group {
                if appModel.trashedAlbums.isEmpty {
                    ContentUnavailableView(
                        "Corbeille vide",
                        systemImage: "trash",
                        description: Text(
                            "Les albums placés ici peuvent être restaurés pendant 30 jours."
                        )
                    )
                } else {
                    List {
                        ForEach(appModel.trashedAlbums) { album in
                            HStack(spacing: 14) {
                                AlbumCoverView(
                                    album: album,
                                    library: appModel.librarySnapshot,
                                    imageCache: appModel.imageCache
                                )
                                .frame(width: 96)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(album.name)
                                        .font(.headline)
                                    if let trashedAt = album.trashedAt {
                                        Text(expirationText(for: trashedAt))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                Menu {
                                    Button("Restaurer", systemImage: "arrow.uturn.backward") {
                                        Task { await appModel.restore(id: album.id) }
                                    }
                                    Button(
                                        "Supprimer définitivement",
                                        systemImage: "trash.slash",
                                        role: .destructive
                                    ) {
                                        deletionRequest = PermanentAlbumDeletionRequest(
                                            album: album
                                        )
                                    }
                                } label: {
                                    Label("Actions pour \(album.name)", systemImage: "ellipsis.circle")
                                        .labelStyle(.iconOnly)
                                }
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityAction(named: "Restaurer") {
                                Task { await appModel.restore(id: album.id) }
                            }
                            .accessibilityAction(named: "Supprimer définitivement") {
                                deletionRequest = PermanentAlbumDeletionRequest(album: album)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Corbeille")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .task { await appModel.loadLibrary() }
        }
        .alert(item: $deletionRequest) { request in
            Alert(
                title: Text("Supprimer définitivement « \(request.album.name) » ?"),
                message: Text(
                    "Cette action retirera définitivement l’album de la bibliothèque locale. "
                        + "Les photos encore référencées par un autre album restent conservées. "
                        + "Elle ne peut pas être annulée."
                ),
                primaryButton: .destructive(Text("Supprimer définitivement")) {
                    Task { _ = await appModel.permanentlyDelete(id: request.album.id) }
                },
                secondaryButton: .cancel(Text("Annuler"))
            )
        }
    }

    private func expirationText(for trashedAt: Date) -> String {
        let expiration = trashedAt.addingTimeInterval(30 * 24 * 60 * 60)
        if expiration <= Date() { return "Suppression automatique imminente" }
        return "Suppression automatique \(expiration.formatted(.relative(presentation: .named)))"
    }
}
