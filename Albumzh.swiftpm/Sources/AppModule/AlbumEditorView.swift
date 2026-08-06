import AlbumPhotoCore
import SwiftUI
import PhotosUI

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
    var isShowingBackgrounds = false
    var isShowingCropEditor = false
    var errorMessage: String?

    var canUndo: Bool { !undoActions.isEmpty }
    var canRedo: Bool { !redoActions.isEmpty }
    var canDeletePage: Bool { album.pages.count > 1 }
    var activePageIndex: Int {
        album.pages.firstIndex(where: { $0.id == activePageID }) ?? 0
    }
    var canGoPrevious: Bool { activePageIndex > 0 }
    var canGoNext: Bool { activePageIndex < album.pages.count - 1 }

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

    func changeBackground(to backgroundID: String) async {
        let before = album
        do {
            let updated = try await service.changeBackground(
                of: album.id,
                to: backgroundID
            )
            record(EditAction(before: before, after: updated))
            album = updated
            isShowingBackgrounds = false
        } catch {
            errorMessage = "Impossible de changer le fond."
        }
    }

    func changeDisplayMode(to mode: DisplayMode) async {
        guard mode != album.preferredDisplayMode else { return }
        let before = album
        do {
            let updated = try await service.changeDisplayMode(
                of: album.id,
                to: mode
            )
            record(EditAction(before: before, after: updated))
            album = updated
        } catch {
            errorMessage = "Impossible de changer le mode d’affichage."
        }
    }
    func setMedia(_ assetID: UUID) async { let before = album; if let updated = try? await service.setMedia(assetID: assetID, on: activePageID, in: album.id) { record(EditAction(before: before, after: updated)); album = updated } else { errorMessage = "Impossible d’ajouter la photo." } }
    func removeMedia() async { let before = album; if let updated = try? await service.removeMedia(from: activePageID, in: album.id) { record(EditAction(before: before, after: updated)); album = updated } else { errorMessage = "Impossible de supprimer la photo." } }
    func applyCrop(_ placement: MediaPlacement) async -> Bool {
        let before = album
        do {
            let updated = try await service.changeMediaCrop(
                on: activePageID,
                in: album.id,
                scale: placement.normalizedScale,
                offsetX: placement.normalizedOffsetX,
                offsetY: placement.normalizedOffsetY
            )
            record(EditAction(before: before, after: updated))
            album = updated
            return true
        } catch {
            errorMessage = "Impossible d’enregistrer le cadrage."
            return false
        }
    }

    func goPrevious() {
        guard canGoPrevious else { return }
        activePageID = album.pages[activePageIndex - 1].id
    }

    func goNext() {
        guard canGoNext else { return }
        activePageID = album.pages[activePageIndex + 1].id
    }

    func navigateBySwipe(towardNext: Bool, availableWidth: Double) {
        let usesSpread = album.preferredDisplayMode == .doublePage
            && availableWidth >= 600
        let step = usesSpread ? 2 : 1
        let currentIndex = usesSpread
            ? (activePageIndex / 2) * 2
            : activePageIndex
        let destination = towardNext
            ? min(currentIndex + step, album.pages.count - 1)
            : max(currentIndex - step, 0)
        guard destination != currentIndex else { return }
        activePageID = album.pages[destination].id
    }

    func visiblePages(availableWidth: Double) -> [Page] {
        guard
            album.preferredDisplayMode == .doublePage,
            availableWidth >= 600
        else {
            return [album.pages[activePageIndex]]
        }
        let firstIndex = (activePageIndex / 2) * 2
        return Array(album.pages[firstIndex..<min(firstIndex + 2, album.pages.count)])
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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var model: AlbumEditorViewModel
    @State private var selectedPhoto: PhotosPickerItem?
    let assetStore: MediaAssetStore

    init(album: Album, service: AlbumService, assetStore: MediaAssetStore) {
        _model = State(
            initialValue: AlbumEditorViewModel(album: album, service: service)
        )
        self.assetStore = assetStore
    }

    var body: some View {
        let activePageHasMedia = model.album.pages[model.activePageIndex]
            .mediaPlacement != nil

        VStack(spacing: 20) {
            Label("Mode édition", systemImage: "pencil")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

            Picker(
                "Affichage",
                selection: Binding(
                    get: { model.album.preferredDisplayMode },
                    set: { mode in
                        Task { await model.changeDisplayMode(to: mode) }
                    }
                )
            ) {
                Text("Une page").tag(DisplayMode.singlePage)
                Text("Deux pages").tag(DisplayMode.doublePage)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            AlbumSpreadView(model: model, assetStore: assetStore)

            HStack {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(
                        activePageHasMedia ? "Remplacer la photo" : "Ajouter une photo",
                        systemImage: "photo.badge.plus"
                    )
                }
                if activePageHasMedia {
                    Button("Recadrer", systemImage: "crop") {
                        model.isShowingCropEditor = true
                    }
                    Button("Supprimer la photo", role: .destructive) {
                        Task { await model.removeMedia() }
                    }
                }
            }

            HStack {
                Button("Précédent", systemImage: "chevron.left") {
                    model.goPrevious()
                }
                .disabled(!model.canGoPrevious)

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

                Button("Suivant", systemImage: "chevron.right") {
                    model.goNext()
                }
                .disabled(!model.canGoNext)
            }
            .padding(.bottom)
        }
        .navigationTitle(model.album.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Albums", systemImage: "chevron.left") {
                    dismiss()
                }
            }

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

                Button("Choisir le fond", systemImage: "paintpalette") {
                    model.isShowingBackgrounds = true
                }
            }
        }
        .sheet(isPresented: $model.isShowingPageManager) {
            PageManagerView(model: model, assetStore: assetStore)
        }
        .sheet(isPresented: $model.isShowingBackgrounds) {
            BackgroundPickerView(model: model)
        }
        .sheet(isPresented: $model.isShowingCropEditor) {
            if let placement = model.album.pages[model.activePageIndex].mediaPlacement {
                CropEditorView(
                    model: model,
                    initialPlacement: placement,
                    assetStore: assetStore
                )
            }
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
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task {
                defer { selectedPhoto = nil }
                guard let data = try? await item.loadTransferable(type: Data.self), let id = try? assetStore.importData(data) else { model.errorMessage = "Impossible d’importer la photo."; return }
                await model.setMedia(id)
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
