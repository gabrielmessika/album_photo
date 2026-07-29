import AlbumPhotoCore
import SwiftUI

@MainActor
@Observable
final class AlbumEditorViewModel {
    private struct EditAction {
        let before: Album
        let after: Album
    }

    private let service: AlbumService
    private var undoActions: [EditAction] = []
    private var redoActions: [EditAction] = []

    var album: Album
    var activePageID: UUID
    var isConfirmingPageDeletion = false
    var isShowingPageManager = false
    var errorMessage: String?

    var canUndo: Bool { !undoActions.isEmpty }
    var canRedo: Bool { !redoActions.isEmpty }
    var canDeletePage: Bool { album.pages.count > 1 }

    init(album: Album, service: AlbumService) {
        self.album = album
        self.activePageID = album.pages[0].id
        self.service = service
    }

    func addPage() async {
        let before = album
        do {
            let updated = try await service.addPage(
                to: album.id,
                after: activePageID
            )
            record(EditAction(before: before, after: updated))
            album = updated
            if let activeIndex = updated.pages.firstIndex(
                where: { $0.id == activePageID }
            ) {
                activePageID = updated.pages[activeIndex + 1].id
            }
        } catch {
            errorMessage = "Impossible d’ajouter la page."
        }
    }

    func deleteActivePage() async {
        guard canDeletePage else { return }
        let before = album
        guard let deletedIndex = album.pages.firstIndex(
            where: { $0.id == activePageID }
        ) else {
            errorMessage = "La page active est introuvable."
            return
        }

        do {
            let updated = try await service.deletePage(
                from: album.id,
                pageID: activePageID
            )
            record(EditAction(before: before, after: updated))
            album = updated
            activePageID = updated.pages[min(deletedIndex, updated.pages.count - 1)].id
            isConfirmingPageDeletion = false
        } catch {
            errorMessage = "Impossible de supprimer la page."
        }
    }

    func movePages(fromOffsets: IndexSet, toOffset: Int) async {
        guard fromOffsets.count == 1, let sourceIndex = fromOffsets.first else {
            errorMessage = "Une seule page peut être déplacée à la fois."
            return
        }

        let before = album
        var orderedIDs = album.pages.map(\.id)
        let movedID = orderedIDs.remove(at: sourceIndex)
        let adjustedOffset = toOffset > sourceIndex ? toOffset - 1 : toOffset
        orderedIDs.insert(
            movedID,
            at: min(max(0, adjustedOffset), orderedIDs.count)
        )
        guard orderedIDs != album.pages.map(\.id) else { return }

        do {
            let updated = try await service.reorderPages(
                in: album.id,
                orderedPageIDs: orderedIDs
            )
            record(EditAction(before: before, after: updated))
            album = updated
        } catch {
            errorMessage = "Impossible de réorganiser les pages."
        }
    }

    func undo() async {
        guard let action = undoActions.popLast() else { return }

        do {
            album = try await service.applyEditorSnapshot(action.before)
            redoActions.append(action)
            keepValidActivePage()
        } catch {
            undoActions.append(action)
            errorMessage = "Impossible d’annuler la modification."
        }
    }

    func redo() async {
        guard let action = redoActions.popLast() else { return }

        do {
            album = try await service.applyEditorSnapshot(action.after)
            undoActions.append(action)
            keepValidActivePage()
        } catch {
            redoActions.append(action)
            errorMessage = "Impossible de rétablir la modification."
        }
    }

    func closeSession() {
        undoActions.removeAll()
        redoActions.removeAll()
    }

    private func record(_ action: EditAction) {
        undoActions.append(action)
        redoActions.removeAll()
    }

    private func keepValidActivePage() {
        if !album.pages.contains(where: { $0.id == activePageID }) {
            activePageID = album.pages[0].id
        }
    }
}

struct AlbumEditorView: View {
    @Environment(\.scenePhase) private var scenePhase
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

            HStack {
                Button(
                    "Ajouter une page",
                    systemImage: "plus.rectangle.on.rectangle"
                ) {
                    Task { await model.addPage() }
                }
                .buttonStyle(.borderedProminent)

                Button(
                    "Supprimer la page",
                    systemImage: "trash",
                    role: .destructive
                ) {
                    model.isConfirmingPageDeletion = true
                }
                .buttonStyle(.bordered)
                .disabled(!model.canDeletePage)
            }
            .padding(.bottom)
        }
        .navigationTitle(model.album.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                Button("Annuler", systemImage: "arrow.uturn.backward") {
                    Task { await model.undo() }
                }
                .disabled(!model.canUndo)

                Button("Rétablir", systemImage: "arrow.uturn.forward") {
                    Task { await model.redo() }
                }
                .disabled(!model.canRedo)

                Button("Gérer les pages", systemImage: "rectangle.stack") {
                    model.isShowingPageManager = true
                }
            }
        }
        .sheet(isPresented: $model.isShowingPageManager) {
            PageManagerView(model: model)
        }
        .alert(
            "Supprimer cette page ?",
            isPresented: $model.isConfirmingPageDeletion
        ) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                Task { await model.deleteActivePage() }
            }
        } message: {
            Text("Cette action pourra être annulée pendant la session.")
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                model.closeSession()
            }
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
