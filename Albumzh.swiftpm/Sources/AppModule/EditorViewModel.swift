import AlbumPhotoCore
import Foundation
import SwiftUI

enum DefaultPhotoQualityPolicy {
    static func state(
        for placement: PhotoPlacement,
        locale: Locale = .current
    ) -> PhotoQualityState? {
        let canvas = defaultCanvasInches(locale: locale)
        guard let ppi = try? PhotoQualityEngine.pixelsPerInch(
            nativeScale: placement.nativeScale,
            canvasWidthInches: canvas.width,
            canvasHeightInches: canvas.height
        ) else { return nil }
        return try? PhotoQualityEngine.state(for: ppi)
    }

    static func defaultCanvasInches(locale: Locale = .current) -> GeometrySize {
        let letterRegions: Set<String> = [
            "US", "CA", "MX", "PH", "GT", "CR", "PA", "CO", "VE", "CL"
        ]
        let usesLetter = locale.region.map {
            letterRegions.contains($0.identifier.uppercased())
        } ?? false
        let sheetMillimeters = usesLetter
            ? GeometrySize(width: 215.9, height: 279.4)
            : GeometrySize(width: 210, height: 297)
        let margin = 12.0
        let portrait = fittedCanvas(
            width: sheetMillimeters.width - margin * 2,
            height: sheetMillimeters.height - margin * 2
        )
        let landscape = fittedCanvas(
            width: sheetMillimeters.height - margin * 2,
            height: sheetMillimeters.width - margin * 2
        )
        let selected = portrait.width * portrait.height >= landscape.width * landscape.height
            ? portrait : landscape
        return GeometrySize(
            width: selected.width / 25.4,
            height: selected.height / 25.4
        )
    }

    private static func fittedCanvas(width: Double, height: Double) -> GeometrySize {
        let canvasWidth = min(width, height * 4 / 5)
        return GeometrySize(width: canvasWidth, height: canvasWidth * 5 / 4)
    }
}

enum EditorPanel: String, CaseIterable, Identifiable {
    case photos
    case layouts
    case backgrounds

    var id: String { rawValue }

    var title: String {
        switch self {
        case .photos: "Photos"
        case .layouts: "Mise en page"
        case .backgrounds: "Fonds"
        }
    }

    var symbol: String {
        switch self {
        case .photos: "photo.on.rectangle"
        case .layouts: "rectangle.3.group"
        case .backgrounds: "paintpalette"
        }
    }
}

struct LayoutTemplateConfirmationRequest: Identifiable, Equatable {
    let template: LayoutTemplateDefinition
    let removedPhotoCount: Int

    var id: String { "\(template.id)#\(template.version)" }
}

enum EditorPresentationMode: String, CaseIterable, Identifiable {
    case page
    case global
    case preview

    var id: String { rawValue }

    var title: String {
        switch self {
        case .page: "Créer"
        case .global: "Organiser"
        case .preview: "Prévisualiser"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .page: "Créer — Vue page"
        case .global: "Organiser — Vue globale"
        case .preview: "Prévisualiser"
        }
    }

    var symbol: String {
        switch self {
        case .page: "rectangle.portrait"
        case .global: "square.grid.2x2"
        case .preview: "eye"
        }
    }
}

enum EditorInteractionState: Equatable {
    case idle
    case movingElement(UUID)
    case resizingElement(UUID)
    case rotatingElement(UUID)
    case croppingPhoto(UUID)
    case zoomingCanvas
    case turningPage

    var blocksPageNavigation: Bool {
        self != .idle
    }
}

enum PhotoChoiceMode: Equatable {
    case newFrame(pageID: UUID)
    case fillFrame(pageID: UUID, elementID: UUID, replacesContent: Bool)

    var title: String {
        switch self {
        case .newFrame:
            return "Choisir une photo pour un nouveau cadre"
        case let .fillFrame(_, _, replacesContent):
            return replacesContent
                ? "Choisir la photo de remplacement"
                : "Choisir une photo pour remplir ce cadre"
        }
    }

    var symbol: String {
        switch self {
        case .newFrame:
            return "photo.badge.plus"
        case let .fillFrame(_, _, replacesContent):
            return replacesContent
                ? "arrow.triangle.2.circlepath"
                : "rectangle.dashed"
        }
    }
}

struct CropDraft: Equatable {
    let elementID: UUID
    let entry: PhotoPlacement
    var placement: PhotoPlacement
    var sessionMinimum: Double
}

enum ImportFileProgressStatus: Equatable {
    case waiting
    case copying
    case copied
    case failed
}

struct ImportFileProgressItem: Identifiable, Equatable {
    let id: Int
    let filename: String
    var status: ImportFileProgressStatus
}

struct ImportProgressState: Equatable {
    var completed: Int
    var items: [ImportFileProgressItem]

    var total: Int { items.count }
    var copiedCount: Int { items.filter { $0.status == .copied }.count }
    var failedCount: Int { items.filter { $0.status == .failed }.count }
    var waitingCount: Int { items.filter { $0.status == .waiting }.count }

    var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
}

enum PhotoImportFailureStatus: String {
    case interrupted = "Interrompu"
    case unsupported = "Format non pris en charge"
    case inaccessible = "Fichier inaccessible"
}

struct FailedPhotoImport: Identifiable {
    let id = UUID()
    let url: URL
    let source: PhotoSource
    let usesSecurityScope: Bool
    let isTemporary: Bool
    let status: PhotoImportFailureStatus
    let message: String
}

@MainActor
final class EditorViewModel: ObservableObject {
    private enum CapacityWarningKey: Hashable {
        case pages
        case bytes
        case elements(UUID, AlbumCapacityElementKind)
    }

    private struct ImportExecutionResult {
        let registeredPaths: Set<String>
        let wasCancelled: Bool
    }

    let albumID: UUID
    let sceneID = UUID()
    let service: AlbumApplicationService
    let mediaStore: AppleMediaStore
    let imageCache: PhotoImageCache

    private let appModel: AppModel
    private var cropGestureStart: PhotoPlacement?
    private var geometryGestureStart: ElementGeometry?
    private var suppressGeometryUpdatesUntilGestureEnds = false
    private var rotationPreviewEntry: (
        pageID: UUID,
        elementID: UUID,
        geometry: ElementGeometry
    )?
    private var rotationGestureOffset: Double?
    private var renderedPageSizes: [UUID: CGSize] = [:]
    private var canvasWorkspaceSizes: [UUID: CGSize] = [:]
    private var previewRestoreState: (pageID: UUID?, elementID: UUID?)?
    private var ownsLease = false
    private var knownCapacityWarningKeys: Set<CapacityWarningKey> = []
    private var activeBusinessOperationCount = 0
    private var businessOperationWaiters: [CheckedContinuation<Void, Never>] = []
    private var businessOperationTurnIsOccupied = false
    private var businessOperationTurnWaiters: [CheckedContinuation<Void, Never>] = []
    private var operationBlockTokens: Set<UUID> = []
    private var activeImportTask: Task<Void, Never>?
    private var activeImportTaskID: UUID?
    private var layoutShuffleBag = LayoutShuffleBag()

    @Published private(set) var album: AlbumSnapshot?
    @Published private(set) var photos: [PhotoAssetMetadata] = []
    @Published var activePageID: UUID?
    @Published var selectedElementID: UUID?
    @Published var activePanel: EditorPanel = .photos {
        didSet {
            if activePanel != .photos { cancelPhotoChoice() }
        }
    }
    @Published var presentationMode: EditorPresentationMode = .page
    @Published var interaction: EditorInteractionState = .idle
    @Published var cropDraft: CropDraft?
    @Published var geometryDraft: ElementGeometry?
    @Published var snapGuides: [SnapGuide] = []
    @Published var canvasViewports: [UUID: CanvasViewportState] = [:]
    @Published var saveState: SavePresentationState = .saved(nil)
    @Published var canUndo = false
    @Published var canRedo = false
    @Published private(set) var hasCompatibleClipboard = false
    @Published private(set) var clipboardContainsEmptyPhotoFrame = false
    @Published var isReadOnly = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var capacityWarning: String?
    @Published var importProgress: ImportProgressState?
    @Published private(set) var failedImports: [FailedPhotoImport] = []
    @Published private(set) var isImportTaskRunning = false
    @Published var photoSort: PhotoSortOption = .importedAt
    @Published var sortsAscending = true
    @Published var hidesUsedPhotos = false
    @Published var helpContext: HelpContext?
    @Published private(set) var photoChoiceMode: PhotoChoiceMode?
    @Published var layoutTemplateConfirmation: LayoutTemplateConfirmationRequest?
    @Published var showsAutomaticLayoutConfirmation = false
    @Published var showsAutomaticLayoutDisabledNotice = false

    init(albumID: UUID, appModel: AppModel) {
        self.albumID = albumID
        self.appModel = appModel
        self.service = appModel.service
        self.mediaStore = appModel.mediaStore
        self.imageCache = appModel.imageCache
    }

    var activePage: PageSnapshot? {
        guard let activePageID else { return album?.pages.first }
        return album?.page(id: activePageID)
    }

    var activePageIndex: Int {
        guard let album, let activePageID,
              let value = album.pages.firstIndex(where: { $0.id == activePageID }) else {
            return 0
        }
        return value
    }

    var canGoPrevious: Bool { activePageIndex > 0 }
    var canGoNext: Bool {
        guard let album else { return false }
        return activePageIndex < album.pages.count - 1
    }

    var selectedElement: PageElement? {
        guard let selectedElementID else { return nil }
        return activePage?.element(id: selectedElementID)
    }

    var selectedPhotoFrame: PhotoFrameElement? {
        selectedElement?.photoFrame
    }

    var selectedPhotoMetadata: PhotoAssetMetadata? {
        guard let assetID = selectedPhotoFrame?.content?.assetID else { return nil }
        return photos.first { $0.id == assetID }
    }

    var layoutTemplates: [LayoutTemplateDefinition] {
        BuiltInLayoutTemplateCatalog.active
    }

    var currentLayoutTemplateKey: LayoutTemplateKey? {
        guard let page = activePage,
              page.layout.photoMode == .template,
              let id = page.layout.templateID,
              let version = page.layout.templateVersion else { return nil }
        return LayoutTemplateKey(id: id, version: version)
    }

    var compatibleDiceTemplates: [LayoutTemplateDefinition] {
        guard let page = activePage else { return [] }
        return layoutTemplates.filter {
            LayoutTemplateEngine.compatibleWithDice($0, page: page)
        }
    }

    var canShuffleLayout: Bool {
        let current = currentLayoutTemplateKey
        let alternatives = compatibleDiceTemplates.filter {
            LayoutTemplateKey(id: $0.id, version: $0.version) != current
        }
        return !isReadOnly && !alternatives.isEmpty
    }

    var canPaste: Bool {
        hasCompatibleClipboard
            && !(activePage?.layout.isAutoLayoutEnabled == true
                && clipboardContainsEmptyPhotoFrame)
    }

    var canAddEmptyPhotoFrame: Bool {
        !isReadOnly && activePage?.layout.isAutoLayoutEnabled != true
    }

    var canDuplicateSelectedElement: Bool {
        guard !isReadOnly, let selectedElement else { return false }
        if activePage?.layout.isAutoLayoutEnabled == true,
           let frame = selectedElement.photoFrame {
            return frame.content != nil
        }
        return true
    }

    var visiblePhotos: [PhotoAssetMetadata] {
        guard hidesUsedPhotos else { return photos }
        return photos.filter { occurrenceCount(of: $0.id) == 0 }
    }

    var otherActiveAlbums: [AlbumSnapshot] {
        appModel.albums
            .filter { $0.id != albumID && !$0.isTrashed }
            .sorted { lhs, rhs in
                if lhs.updatedAt != rhs.updatedAt { return lhs.updatedAt > rhs.updatedAt }
                let nameOrder = lhs.name.localizedCompare(rhs.name)
                if nameOrder != .orderedSame { return nameOrder == .orderedAscending }
                return lhs.id.uuidString < rhs.id.uuidString
            }
    }

    var currentPhotoHashes: Set<String> {
        Set(photos.map(\.contentHash))
    }

    var viewport: CanvasViewportState {
        get {
            guard let activePageID else { return .fitted }
            return canvasViewports[activePageID] ?? .fitted
        }
        set {
            guard let activePageID else { return }
            canvasViewports[activePageID] = newValue
        }
    }

    var canSave: Bool {
        guard !isReadOnly, saveState != .saving else { return false }
        if saveState == .failed || geometryDraft != nil { return true }
        guard let cropDraft else { return false }
        return cropDraft.placement != cropDraft.entry
    }

    /// Bloque immédiatement le démarrage de nouvelles mutations pendant une
    /// transition de cycle de vie. Le token permet d'imbriquer sans ambiguïté
    /// une fermeture explicite, un passage en arrière-plan et une sauvegarde.
    @discardableResult
    func beginClosingTransition() -> UUID {
        beginOperationBlock()
    }

    func endClosingTransition(_ token: UUID) {
        endOperationBlock(token)
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let leaseService = await service.editLeases
            ownsLease = await leaseService.acquire(albumID: albumID, sceneID: sceneID)
            isReadOnly = !ownsLease
            album = try await service.album(id: albumID)
            if activePageID == nil { activePageID = album?.pages.first?.id }
            try await reloadPhotosAndSession()
            refreshCapacityWarnings()
        } catch {
            if ownsLease {
                let leaseService = await service.editLeases
                await leaseService.release(albumID: albumID, sceneID: sceneID)
                ownsLease = false
                isReadOnly = true
            }
            present(error, fallback: "Impossible d’ouvrir l’album.")
        }
    }

    func retryEditAccess() async {
        guard isReadOnly, !isLoading, operationBlockTokens.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        let leaseService = await service.editLeases
        guard await leaseService.acquire(albumID: albumID, sceneID: sceneID) else {
            return
        }
        ownsLease = true

        do {
            album = try await service.album(id: albumID)
            try await reloadPhotosAndSession()
            keepValidPageAndSelection()
            refreshCapacityWarnings()
            isReadOnly = false
            errorMessage = nil
        } catch {
            await leaseService.release(albumID: albumID, sceneID: sceneID)
            ownsLease = false
            isReadOnly = true
            present(error, fallback: "Impossible de reprendre l’édition de l’album.")
        }
    }

    @discardableResult
    func close(reacquireOnFailure: Bool = false) async -> Bool {
        let operationBlockToken = beginOperationBlock()
        defer { endOperationBlock(operationBlockToken) }
        cancelImportTask()
        await waitForBusinessOperationsToFinish()

        var closeError: Error?
        if ownsLease {
            do {
                let closed = try await service.closeEditingSession(
                    albumID: albumID,
                    sceneID: sceneID
                )
                ownsLease = false
                isReadOnly = true
                if !closed {
                    closeError = DomainValidationError.persistenceFailure(
                        "la scène ne possède plus le verrou d’édition"
                    )
                }
            } catch {
                closeError = error
                saveState = .failed
                // Le Core annule la transition de fermeture en cas d’échec du
                // flush et conserve le propriétaire ainsi que ses historiques.
                // Libérer ici permettrait à une autre scène de reprendre ces
                // piles avant qu’elles soient consolidées.
                ownsLease = true
                isReadOnly = false
            }
        }
        do {
            try await appModel.refreshLibrary()
        } catch {
            // Une session déjà fermée durablement ne doit pas être rouverte et
            // privée de son historique uniquement parce que le rafraîchissement
            // de présentation a échoué. La bibliothèque réessaiera à l’affichage.
            appModel.present(
                error,
                fallback: "Impossible d’actualiser la bibliothèque."
            )
        }
        if let closeError {
            if reacquireOnFailure, !ownsLease {
                let leaseService = await service.editLeases
                ownsLease = await leaseService.acquire(
                    albumID: albumID,
                    sceneID: sceneID
                )
                isReadOnly = !ownsLease
            }
            present(closeError, fallback: "Impossible de terminer la session d’édition.")
            return false
        }
        // Failed Apple Photos transfers are retryable only while this editor is
        // alive. On a successful close, remove its owned temporary copies and
        // forget non-temporary File URLs without ever deleting user originals.
        discardFailedImports()
        return true
    }

    func reloadPhotos() async {
        do {
            photos = try await service.photoAssets(
                in: albumID,
                sortedBy: photoSort,
                ascending: sortsAscending
            )
        } catch {
            present(error, fallback: "Impossible de charger les photos.")
        }
    }

    func photos(inOtherAlbum albumID: UUID) async -> [PhotoAssetMetadata] {
        guard let source = appModel.librarySnapshot.album(id: albumID),
              !source.isTrashed else { return [] }
        return source.photoAssetIDs.compactMap {
            appModel.librarySnapshot.photoAsset(id: $0)
        }
    }

    func isPhotoBlobAvailable(_ metadata: PhotoAssetMetadata) async -> Bool {
        let blobByHash = Dictionary(
            uniqueKeysWithValues: appModel.librarySnapshot.blobIndex.map {
                ($0.contentHash, $0)
            }
        )
        guard let original = blobByHash[metadata.contentHash],
              original.state == .available,
              original.byteCount == metadata.byteCount,
              original.detectedContentType.lowercased() == metadata.mimeType.lowercased(),
              await mediaStore.verifyPhysicalBlob(
                  contentHash: metadata.contentHash,
                  expectedByteCount: metadata.byteCount
              ) else {
            return false
        }
        guard let derivative = metadata.displayDerivative else { return true }
        guard let derivativeBlob = blobByHash[derivative.contentHash],
              derivativeBlob.state == .available,
              derivativeBlob.byteCount == derivative.byteCount,
              derivativeBlob.detectedContentType.lowercased()
                == derivative.mimeType.lowercased() else {
            return false
        }
        return await mediaStore.verifyPhysicalBlob(
            contentHash: derivative.contentHash,
            expectedByteCount: derivative.byteCount
        )
    }

    func occurrenceCount(of assetID: UUID) -> Int {
        guard let album else { return 0 }
        return DomainValidator.occurrenceCount(of: assetID, in: album)
    }

    func metadata(for assetID: UUID) -> PhotoAssetMetadata? {
        photos.first { $0.id == assetID }
            ?? appModel.librarySnapshot.photoAsset(id: assetID)
    }

    func elementSelectionLabel(_ element: PageElement) -> String {
        let ordered = activePage?.orderedElements ?? []
        let depthIndex = ordered.firstIndex(where: { $0.id == element.id })
        let depth = depthIndex.map { "plan \($0 + 1) sur \(ordered.count)" }
            ?? "profondeur inconnue"
        let position = approximatePosition(of: element.geometry)
        switch element {
        case let .photo(frame):
            guard let placement = frame.content else {
                return "Cadre photo vide — \(position) — \(depth)"
            }
            let description = placement.accessibilityDescription?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let filename = metadata(for: placement.assetID)?.originalFilename?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let detail = [description, filename]
                .compactMap { value in
                    guard let value, !value.isEmpty else { return nil }
                    return value
                }
                .first ?? "photo \(placement.assetID.uuidString.prefix(6))"
            return "Photo — \(detail) — \(position) — \(depth)"
        case let .text(text):
            let excerpt = text.content.plainText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            return "Texte — \(excerpt.isEmpty ? "vide" : String(excerpt.prefix(32))) — \(position) — \(depth)"
        case let .sticker(sticker):
            return "Sticker — \(sticker.resource.catalogID) — \(position) — \(depth)"
        }
    }

    private func approximatePosition(of geometry: ElementGeometry) -> String {
        let horizontal = geometry.centerX < 1.0 / 3.0
            ? "gauche" : geometry.centerX > 2.0 / 3.0 ? "droite" : "centre"
        let vertical = geometry.centerY < 1.0 / 3.0
            ? "haut" : geometry.centerY > 2.0 / 3.0 ? "bas" : "milieu"
        return "\(vertical) \(horizontal)"
    }

    func select(elementID: UUID?) {
        guard cropDraft == nil else { return }
        selectedElementID = elementID
    }

    func beginNewPhotoFrameChoice() {
        guard !isReadOnly, cropDraft == nil, let pageID = activePageID else { return }
        selectedElementID = nil
        activePanel = .photos
        photoChoiceMode = .newFrame(pageID: pageID)
    }

    func beginSelectedPhotoFrameChoice() {
        guard !isReadOnly, cropDraft == nil, let pageID = activePageID,
              let frame = selectedPhotoFrame else { return }
        activePanel = .photos
        photoChoiceMode = .fillFrame(
            pageID: pageID,
            elementID: frame.id,
            replacesContent: frame.content != nil
        )
    }

    func cancelPhotoChoice() {
        photoChoiceMode = nil
    }

    func showPage(_ pageID: UUID) {
        guard !interaction.blocksPageNavigation,
              album?.pages.contains(where: { $0.id == pageID }) == true else { return }
        if activePageID != pageID {
            cancelPhotoChoice()
            layoutShuffleBag.reset()
        }
        activePageID = pageID
        selectedElementID = nil
    }

    func goPrevious() {
        guard canGoPrevious, !interaction.blocksPageNavigation, let album else { return }
        showPage(album.pages[activePageIndex - 1].id)
    }

    func goNext() {
        guard canGoNext, !interaction.blocksPageNavigation, let album else { return }
        showPage(album.pages[activePageIndex + 1].id)
    }

    func navigateBySwipe(translation: CGSize, pageWidth: CGFloat) {
        guard !interaction.blocksPageNavigation else { return }
        let horizontal = abs(translation.width)
        let vertical = abs(translation.height)
        guard horizontal > vertical * 1.25,
              horizontal >= max(44, pageWidth * 0.25) else { return }
        interaction = .turningPage
        if translation.width < 0 { goNextIgnoringTransitionLock() }
        else { goPreviousIgnoringTransitionLock() }
        interaction = .idle
    }

    func beginPreviewSession() {
        guard previewRestoreState == nil else { return }
        previewRestoreState = (activePageID, selectedElementID)
    }

    func endPreviewSession() {
        guard let restore = previewRestoreState else { return }
        previewRestoreState = nil
        if let pageID = restore.pageID,
           album?.page(id: pageID) != nil {
            activePageID = pageID
        }
        if let elementID = restore.elementID,
           activePage?.element(id: elementID) != nil {
            selectedElementID = elementID
        } else {
            selectedElementID = nil
        }
        interaction = .idle
    }

    func addPage() async {
        guard let current = activePageID else { return }
        let newID = UUID()
        await mutate("Impossible d’ajouter la page.") {
            try await self.service.addPage(
                to: self.albumID,
                after: current,
                pageID: newID
            )
        }
        if album?.page(id: newID) != nil { showPage(newID) }
    }

    func deletePage(_ pageID: UUID) async {
        guard let before = album,
              before.pages.count > 1,
              let deletedIndex = before.pages.firstIndex(where: { $0.id == pageID }) else { return }
        let didDelete = await mutate("Impossible de supprimer la page.") {
            try await self.service.deletePage(from: self.albumID, pageID: pageID)
        }
        guard didDelete else { return }
        if let pages = album?.pages, !pages.isEmpty {
            activePageID = pages[min(deletedIndex, pages.count - 1)].id
            selectedElementID = nil
            canvasViewports[pageID] = nil
        }
    }

    func movePage(_ pageID: UUID, before destinationID: UUID) async {
        guard let album, pageID != destinationID else { return }
        var ids = album.pages.map(\.id)
        guard let source = ids.firstIndex(of: pageID),
              let destination = ids.firstIndex(of: destinationID) else { return }
        ids.remove(at: source)
        ids.insert(pageID, at: source < destination ? destination - 1 : destination)
        await reorderPages(ids)
    }

    func movePageByOffset(_ pageID: UUID, delta: Int) async {
        guard let album, let index = album.pages.firstIndex(where: { $0.id == pageID }) else {
            return
        }
        let target = min(album.pages.count - 1, max(0, index + delta))
        guard target != index else { return }
        var ids = album.pages.map(\.id)
        let value = ids.remove(at: index)
        ids.insert(value, at: target)
        await reorderPages(ids)
    }

    func movePageToEnd(_ pageID: UUID) async {
        guard let album,
              album.pages.last?.id != pageID,
              album.pages.contains(where: { $0.id == pageID }) else { return }
        var ids = album.pages.map(\.id)
        ids.removeAll { $0 == pageID }
        ids.append(pageID)
        await reorderPages(ids)
    }

    private func reorderPages(_ orderedIDs: [UUID]) async {
        await mutate("Impossible de réorganiser les pages.") {
            try await self.service.reorderPages(
                in: self.albumID,
                orderedPageIDs: orderedIDs
            )
        }
    }

    func setBackground(_ background: BackgroundSelection, allPages: Bool) async {
        guard let pageID = activePageID else { return }
        if case .catalog = background {
            saveState = .saving
            await appModel.waitForCatalogBootstrap()
        }
        if allPages {
            await mutate("Impossible d’appliquer le fond à toutes les pages.") {
                try await self.service.applyBackgroundToAllPages(
                    background,
                    in: self.albumID
                )
            }
        } else {
            await mutate("Impossible de changer le fond.") {
                try await self.service.setBackground(
                    background,
                    on: pageID,
                    in: self.albumID
                )
            }
        }
    }

    func requestLayoutTemplate(_ template: LayoutTemplateDefinition) async {
        guard let page = activePage, template.isActive else { return }
        guard template.textSlots.isEmpty else {
            errorMessage = "Les modèles avec texte seront activés avec l’éditeur de texte du prochain incrément."
            return
        }
        switch LayoutTemplateEngine.preview(applying: template, to: page).disposition {
        case let .disabledBecauseTextWouldBeRemoved(count):
            errorMessage = count == 1
                ? "Ce modèle retirerait une zone de texte non vide."
                : "Ce modèle retirerait \(count) zones de texte non vides."
        case let .requiresPhotoRemovalConfirmation(count):
            layoutTemplateConfirmation = LayoutTemplateConfirmationRequest(
                template: template,
                removedPhotoCount: count
            )
        case .ready:
            await applyLayoutTemplate(template, confirmsPhotoRemoval: false)
        }
    }

    func confirmLayoutTemplateApplication() async {
        guard let request = layoutTemplateConfirmation else { return }
        layoutTemplateConfirmation = nil
        await applyLayoutTemplate(
            request.template,
            confirmsPhotoRemoval: true
        )
    }

    func cancelLayoutTemplateApplication() {
        layoutTemplateConfirmation = nil
    }

    func shuffleLayout() async {
        guard let pageID = activePageID else { return }
        var generator = SystemRandomNumberGenerator()
        guard let selected = layoutShuffleBag.choose(
            compatible: compatibleDiceTemplates,
            current: currentLayoutTemplateKey,
            using: &generator
        ) else { return }
        await mutate("Impossible de changer aléatoirement la mise en page.") {
            try await self.service.applyLayoutTemplate(
                id: selected.id,
                version: selected.version,
                to: pageID,
                in: self.albumID
            )
        }
    }

    func requestAutomaticLayout(_ isEnabled: Bool) async {
        guard let page = activePage else { return }
        if isEnabled,
           !page.layout.isAutoLayoutEnabled,
           page.elements.contains(where: { $0.photoFrame != nil }) {
            showsAutomaticLayoutConfirmation = true
            return
        }
        await applyAutomaticLayout(isEnabled, confirmsReplacement: false)
    }

    func confirmAutomaticLayout() async {
        showsAutomaticLayoutConfirmation = false
        await applyAutomaticLayout(true, confirmsReplacement: true)
    }

    func cancelAutomaticLayout() {
        showsAutomaticLayoutConfirmation = false
    }

    func setAutoLayoutDensity(_ density: AutoLayoutDensity) async {
        guard let pageID = activePageID else { return }
        layoutShuffleBag.reset()
        await mutate("Impossible de changer la densité automatique.") {
            try await self.service.setAutoLayoutDensity(
                density,
                on: pageID,
                in: self.albumID
            )
        }
    }

    private func applyLayoutTemplate(
        _ template: LayoutTemplateDefinition,
        confirmsPhotoRemoval: Bool
    ) async {
        guard let pageID = activePageID else { return }
        let wasAutomatic = activePage?.layout.isAutoLayoutEnabled == true
        layoutShuffleBag.reset()
        let succeeded = await mutate("Impossible d’appliquer cette mise en page.") {
            try await self.service.applyLayoutTemplate(
                id: template.id,
                version: template.version,
                to: pageID,
                in: self.albumID,
                confirmsPhotoRemoval: confirmsPhotoRemoval
            )
        }
        if succeeded, wasAutomatic {
            showsAutomaticLayoutDisabledNotice = true
        }
    }

    private func applyAutomaticLayout(
        _ isEnabled: Bool,
        confirmsReplacement: Bool
    ) async {
        guard let pageID = activePageID else { return }
        layoutShuffleBag.reset()
        await mutate("Impossible de modifier la mise en page automatique.") {
            try await self.service.setAutomaticLayoutEnabled(
                isEnabled,
                on: pageID,
                in: self.albumID,
                confirmsReplacement: confirmsReplacement
            )
        }
    }

    func renameAlbum(to name: String) async {
        guard await beginBusinessOperation() else { return }
        defer { endBusinessOperation() }

        saveState = .saving
        do {
            album = try await service.renameAlbum(
                albumID,
                to: name,
                history: .editor
            )
            try await appModel.refreshLibrary()
            markSaved()
        } catch {
            saveState = .failed
            present(error, fallback: "Impossible de renommer l’album.")
        }
    }

    /// Acquires the editor operation turn before PhotosUI starts materializing
    /// temporary files. A close/background transition therefore waits for the
    /// transfer and its cleanup instead of releasing the edit lease underneath
    /// an in-flight picker task (3:APP-006, 3:PERF-011, 3:SEC-008).
    func importPickedFiles(
        loading files: @MainActor () async -> [PickedPhotoFile]
    ) async {
        guard await beginBusinessOperation() else { return }
        defer { endBusinessOperation() }

        let loadedFiles = await files()
        let values = loadedFiles.map(\.url)
        guard !values.isEmpty else { return }

        var retainedFailurePaths = Set<String>()
        defer {
            for value in values where !retainedFailurePaths.contains(value.path) {
                try? FileManager.default.removeItem(at: value)
            }
        }
        guard !Task.isCancelled else {
            errorMessage = "Import annulé. Les fichiers temporaires ont été nettoyés."
            return
        }

        _ = await performImportFiles(
            values,
            source: .applePhotos,
            usesSecurityScope: false,
            temporaryFiles: true,
            replacesFailures: true
        )
        // Even when cancellation arrives after one source has failed, its
        // temporary copy must remain available to the retry command for the
        // lifetime of the editor. Every other transfer copy is removed by the
        // defer above.
        retainedFailurePaths = Set(
            failedImports.filter(\.isTemporary).map { $0.url.path }
        )
        if Task.isCancelled {
            errorMessage = "Import annulé. Les copies déjà validées restent dans l’album."
        }
    }

    func importFiles(
        _ urls: [URL],
        source: PhotoSource,
        usesSecurityScope: Bool,
        temporaryFiles: Bool = false,
        replacesFailures: Bool = true
    ) async {
        guard !urls.isEmpty, await beginBusinessOperation() else { return }
        defer { endBusinessOperation() }

        _ = await performImportFiles(
            urls,
            source: source,
            usesSecurityScope: usesSecurityScope,
            temporaryFiles: temporaryFiles,
            replacesFailures: replacesFailures
        )
    }

    private func performImportFiles(
        _ urls: [URL],
        source: PhotoSource,
        usesSecurityScope: Bool,
        temporaryFiles: Bool,
        replacesFailures: Bool
    ) async -> ImportExecutionResult {
        let saveStateBeforeImport = saveState
        saveState = .saving
        if replacesFailures {
            discardFailedImports()
        }
        importProgress = ImportProgressState(
            completed: 0,
            items: urls.enumerated().map { index, url in
                ImportFileProgressItem(
                    id: index,
                    filename: url.lastPathComponent,
                    status: .waiting
                )
            }
        )
        var newFailures: [FailedPhotoImport] = []
        var registrations: [(URL, PhotoRegistration)] = []
        var didRegisterPhotos = false
        var registrationFailed = false
        var wasCancelled = false
        for (index, url) in urls.enumerated() {
            guard !Task.isCancelled else {
                wasCancelled = true
                break
            }
            updateImportProgressItem(at: index, status: .copying)
            let hasAccess = !usesSecurityScope || url.startAccessingSecurityScopedResource()
            defer {
                if usesSecurityScope && hasAccess { url.stopAccessingSecurityScopedResource() }
            }
            do {
                guard hasAccess else { throw ApplePhotoImportError.inaccessibleFile }
                let prepared = try await mediaStore.prepareImport(
                    at: url,
                    source: source,
                    originalFilename: url.lastPathComponent
                )
                registrations.append((
                    url,
                    PhotoRegistration(
                        metadata: prepared.metadata,
                        blob: prepared.blob,
                        displayDerivativeBlob: prepared.displayDerivativeBlob
                    )
                ))
                updateImportProgressItem(at: index, status: .copied)
                if Task.isCancelled {
                    wasCancelled = true
                    break
                }
            } catch {
                if Task.isCancelled {
                    wasCancelled = true
                    break
                }
                updateImportProgressItem(at: index, status: .failed)
                newFailures.append(FailedPhotoImport(
                    url: url,
                    source: source,
                    usesSecurityScope: usesSecurityScope,
                    isTemporary: temporaryFiles,
                    status: Self.importFailureStatus(for: error),
                    message: Self.message(for: error)
                ))
            }
        }
        if Task.isCancelled { wasCancelled = true }
        if !registrations.isEmpty {
            do {
                let previousAssetIDs = album?.photoAssetIDs ?? []
                album = try await service.registerPhotos(
                    registrations.map(\.1),
                    in: albumID
                )
                didRegisterPhotos = album?.photoAssetIDs != previousAssetIDs
            } catch {
                registrationFailed = true
                for (url, _) in registrations {
                    newFailures.append(FailedPhotoImport(
                        url: url,
                        source: source,
                        usesSecurityScope: usesSecurityScope,
                        isTemporary: temporaryFiles,
                        status: .interrupted,
                        message: Self.message(for: error)
                    ))
                }
            }
        }
        if Task.isCancelled { wasCancelled = true }
        importProgress = nil
        do {
            try await reloadPhotosAndSession()
            try await appModel.refreshLibrary()
            refreshCapacityWarnings()
        } catch {
            present(error, fallback: "Impossible d’actualiser les photos importées.")
        }
        if registrationFailed {
            saveState = .failed
        } else if didRegisterPhotos {
            markSaved()
        } else {
            // Des refus de formats individuels ne constituent pas un échec de
            // persistance et ne remplacent pas le dernier état durable connu.
            saveState = saveStateBeforeImport
        }
        failedImports.append(contentsOf: newFailures)
        if wasCancelled {
            errorMessage = didRegisterPhotos
                ? "Import annulé après l’enregistrement des copies déjà terminées."
                : "Import annulé. Aucune nouvelle photo n’a été enregistrée."
        } else if !newFailures.isEmpty {
            errorMessage = "\(newFailures.count) photo(s) n’ont pas été importées. Utilisez Réessayer pour traiter uniquement ces erreurs."
        }
        return ImportExecutionResult(
            registeredPaths: didRegisterPhotos
                ? Set(registrations.map { $0.0.path }) : [],
            wasCancelled: wasCancelled
        )
    }

    func retryFailedImports() async {
        let pending = failedImports
        guard let first = pending.first else { return }
        guard await beginBusinessOperation() else { return }
        defer { endBusinessOperation() }

        failedImports = []
        let result = await performImportFiles(
            pending.map(\.url),
            source: first.source,
            usesSecurityScope: first.usesSecurityScope,
            temporaryFiles: first.isTemporary,
            replacesFailures: false
        )

        // Cancellation may stop between two source files. Keep every source
        // that was neither registered nor replaced by a fresh failure so the
        // user can retry again while the editor remains open.
        var failedPaths = Set(failedImports.map { $0.url.path })
        if result.wasCancelled {
            for item in pending
            where !result.registeredPaths.contains(item.url.path)
                && !failedPaths.contains(item.url.path) {
                failedImports.append(item)
                failedPaths.insert(item.url.path)
            }
        }
        for item in pending
        where item.isTemporary && !failedPaths.contains(item.url.path) {
            try? FileManager.default.removeItem(at: item.url)
        }
    }

    /// Owns the single UI-visible import task for initial imports and retries.
    /// The business-operation gate inside each operation remains the FIFO
    /// authority; this wrapper only supplies cancellation and prevents a second
    /// launch while the first command is running.
    func startImportTask(
        _ operation: @escaping @MainActor () async -> Void
    ) {
        guard activeImportTask == nil else { return }
        let operationID = UUID()
        activeImportTaskID = operationID
        isImportTaskRunning = true
        activeImportTask = Task { @MainActor [weak self] in
            await operation()
            guard let self, self.activeImportTaskID == operationID else { return }
            self.activeImportTask = nil
            self.activeImportTaskID = nil
            self.isImportTaskRunning = false
        }
    }

    func cancelImportTask() {
        activeImportTask?.cancel()
    }

    func discardFailedImports() {
        for item in failedImports where item.isTemporary {
            try? FileManager.default.removeItem(at: item.url)
        }
        failedImports = []
    }

    @discardableResult
    func reusePhotos(_ assetIDs: [UUID], from sourceAlbumID: UUID) async -> Bool {
        guard !assetIDs.isEmpty, await beginBusinessOperation() else { return false }
        defer { endBusinessOperation() }

        saveState = .saving
        do {
            _ = try await appModel.photoReuseCoordinator.reusePhotos(
                assetIDs: assetIDs,
                from: sourceAlbumID,
                to: albumID
            )
            album = try await service.album(id: albumID)
            try await reloadPhotosAndSession()
            try await appModel.refreshLibrary()
            refreshCapacityWarnings()
            markSaved()
            return true
        } catch {
            saveState = .failed
            present(error, fallback: "Impossible de réutiliser ces photos.")
            return false
        }
    }

    func removePhotoAsset(_ assetID: UUID) async {
        await mutate("Impossible de supprimer cette photo de l’album.") {
            try await self.service.removePhotoAsset(assetID, from: self.albumID)
        }
        await reloadPhotos()
    }

    func placePhoto(_ assetID: UUID, center: GeometryPoint = GeometryPoint(x: 0.5, y: 0.5)) async {
        guard let pageID = activePageID else { return }
        let choice = photoChoiceMode
        let targetFrameID: UUID?
        switch choice {
        case let .fillFrame(choicePageID, elementID, _)
            where choicePageID == pageID
                && activePage?.element(id: elementID)?.photoFrame != nil:
            targetFrameID = elementID
        case .newFrame(let choicePageID) where choicePageID == pageID:
            targetFrameID = nil
        case .some:
            cancelPhotoChoice()
            return
        case .none:
            targetFrameID = selectedPhotoFrame?.id
        }

        if let targetFrameID {
            let succeeded = await mutate("Impossible de remplir le cadre.") {
                try await self.service.fillPhotoFrame(
                    targetFrameID,
                    with: assetID,
                    on: pageID,
                    in: self.albumID
                )
            }
            if succeeded {
                selectedElementID = targetFrameID
                cancelPhotoChoice()
            }
        } else {
            let newID = UUID()
            let succeeded = await mutate("Impossible d’ajouter le cadre photo.") {
                try await self.service.addPhotoFrame(
                    to: pageID,
                    in: self.albumID,
                    assetID: assetID,
                    center: center,
                    elementID: newID
                )
            }
            if succeeded, activePage?.element(id: newID) != nil {
                selectedElementID = newID
                cancelPhotoChoice()
            }
        }
    }

    func addEmptyPhotoFrame() async {
        guard let pageID = activePageID else { return }
        let newID = UUID()
        await mutate("Impossible d’ajouter le cadre vide.") {
            try await self.service.addPhotoFrame(
                to: pageID,
                in: self.albumID,
                elementID: newID
            )
        }
        if activePage?.element(id: newID) != nil { selectedElementID = newID }
    }

    func removePhotoFromSelectedFrame() async {
        guard let pageID = activePageID, let elementID = selectedElementID else { return }
        await mutate("Impossible de retirer la photo.") {
            try await self.service.removePhotoFromFrame(
                elementID,
                on: pageID,
                in: self.albumID
            )
        }
    }

    func deleteSelectedElement() async {
        guard let pageID = activePageID, let elementID = selectedElementID else { return }
        await mutate("Impossible de supprimer le cadre.") {
            try await self.service.deleteElement(
                elementID,
                on: pageID,
                in: self.albumID
            )
        }
        if activePage?.element(id: elementID) == nil { selectedElementID = nil }
    }

    func duplicateSelectedElement() async {
        guard let pageID = activePageID, let elementID = selectedElementID else { return }
        let newID = UUID()
        await mutate("Impossible de dupliquer le cadre.") {
            try await self.service.duplicateElement(
                elementID,
                on: pageID,
                in: self.albumID,
                newElementID: newID,
                offsetNormalized: self.elementCommandOffset(on: pageID)
            )
        }
        if activePage?.element(id: newID) != nil { selectedElementID = newID }
    }

    func rotatePhotoContent(by quarterTurns: Int) async {
        guard let pageID = activePageID, let elementID = selectedElementID else { return }
        await mutate("Impossible de pivoter la photo.") {
            try await self.service.rotatePhotoContent(
                elementID: elementID,
                on: pageID,
                in: self.albumID,
                quarterTurnDelta: quarterTurns
            )
        }
    }

    func flipPhotoContent() async {
        guard let pageID = activePageID, let elementID = selectedElementID else { return }
        await mutate("Impossible de retourner la photo.") {
            try await self.service.flipPhotoContent(
                elementID: elementID,
                on: pageID,
                in: self.albumID
            )
        }
    }

    func moveSelectedElementDepth(_ move: ElementDepthMove) async {
        guard let pageID = activePageID, let elementID = selectedElementID else { return }
        await mutate("Impossible de modifier l’ordre de profondeur.") {
            try await self.service.moveElementDepth(
                move,
                elementID: elementID,
                on: pageID,
                in: self.albumID
            )
        }
    }

    func beginGeometryGesture(elementID: UUID, kind: EditorInteractionState) {
        guard !isReadOnly, cropDraft == nil,
              !suppressGeometryUpdatesUntilGestureEnds,
              let element = activePage?.element(id: elementID) else { return }
        selectedElementID = elementID
        geometryGestureStart = element.geometry
        geometryDraft = element.geometry
        rotationGestureOffset = nil
        snapGuides = []
        interaction = kind
    }

    func beginTwoFingerTransform(elementID: UUID) {
        guard !isReadOnly, cropDraft == nil,
              !suppressGeometryUpdatesUntilGestureEnds,
              let element = activePage?.element(id: elementID) else { return }
        switch interaction {
        case .idle:
            break
        case let .movingElement(activeID) where activeID == elementID:
            break
        case let .resizingElement(activeID) where activeID == elementID:
            return
        default:
            return
        }

        selectedElementID = elementID
        // A first finger can briefly start the move recognizer before the
        // second finger arrives. Restart from the committed geometry so the
        // two-finger transform owns one coherent draft and one command.
        geometryGestureStart = element.geometry
        geometryDraft = element.geometry
        rotationGestureOffset = nil
        snapGuides = []
        interaction = .resizingElement(elementID)
    }

    func updateMove(translation: CGSize, pageSize: CGSize) {
        guard let start = geometryGestureStart,
              case let .movingElement(elementID) = interaction,
              pageSize.width > 0, pageSize.height > 0 else { return }
        var proposed = start
        proposed.centerX += translation.width / pageSize.width
        proposed.centerY += translation.height / pageSize.height
        let others = activePage?.elements
            .filter { $0.id != elementID }
            .map(\.geometry) ?? []
        let snapped = CanvasSnapEngine.snap(
            moving: proposed,
            otherElements: others,
            pageSizePoints: GeometrySize(
                width: pageSize.width,
                height: pageSize.height
            )
        )
        if snapGuides.isEmpty && !snapped.guides.isEmpty {
            AppleFeedback.snapped()
        }
        geometryDraft = snapped.geometry
        snapGuides = snapped.guides
    }

    func updateResize(
        translation: CGSize,
        pageSize: CGSize,
        horizontalSign: Double,
        verticalSign: Double
    ) {
        guard let start = geometryGestureStart,
              case .resizingElement = interaction,
              pageSize.width > 0, pageSize.height > 0 else { return }
        let cosine = cos(-start.rotationRadians)
        let sine = sin(-start.rotationRadians)
        let localX = Double(translation.width) * cosine
            - Double(translation.height) * sine
        let localY = Double(translation.width) * sine
            + Double(translation.height) * cosine
        var value = start
        value.width = max(
            0.05,
            start.width + horizontalSign * 2 * localX / Double(pageSize.width)
        )
        value.height = max(
            0.05,
            start.height + verticalSign * 2 * localY / Double(pageSize.height)
        )
        geometryDraft = value
    }

    func updateRotation(location: CGPoint, pageSize: CGSize) {
        guard var value = geometryGestureStart,
              case .rotatingElement = interaction,
              pageSize.width > 0, pageSize.height > 0 else { return }
        let center = CGPoint(
            x: value.centerX * pageSize.width,
            y: value.centerY * pageSize.height
        )
        let pointerAngle = atan2(location.y - center.y, location.x - center.x)
        if rotationGestureOffset == nil {
            rotationGestureOffset = value.rotationRadians - pointerAngle
        }
        value.rotationRadians = pointerAngle + (rotationGestureOffset ?? 0)
        geometryDraft = value
    }

    func updateTwoFingerTransform(
        elementID: UUID,
        magnification: Double,
        rotationRadians: Double
    ) {
        guard let start = geometryGestureStart,
              selectedElementID == elementID,
              case let .resizingElement(activeID) = interaction,
              activeID == elementID,
              magnification.isFinite,
              magnification > 0,
              rotationRadians.isFinite else { return }
        var value = start
        value.width = max(0.05, start.width * magnification)
        value.height = max(0.05, start.height * magnification)
        value.rotationRadians = start.rotationRadians + rotationRadians
        geometryDraft = value
    }

    func commitGeometryGesture() async {
        guard await beginBusinessOperation() else {
            geometryGestureStart = nil
            rotationGestureOffset = nil
            snapGuides = []
            interaction = .idle
            return
        }
        defer { endBusinessOperation() }
        await finishGeometryGesture()
    }

    /// SAV-001 — si Sauvegarder a déjà finalisé le brouillon pendant que le
    /// doigt reste posé, tous les événements cumulatifs suivants appartiennent
    /// encore à l’ancien flux et doivent être ignorés jusqu’au relâchement.
    func endGeometryGestureStreamIfSuppressed() -> Bool {
        let wasSuppressed = suppressGeometryUpdatesUntilGestureEnds
        suppressGeometryUpdatesUntilGestureEnds = false
        return wasSuppressed
    }

    private func finishGeometryGesture() async {
        guard let geometryDraft, let pageID = activePageID,
              let elementID = selectedElementID else { return }
        let disablesAutomaticLayout = activePage?.layout.isAutoLayoutEnabled == true
            && activePage?.element(id: elementID)?.photoFrame != nil

        let operation: () async throws -> AlbumSnapshot = {
            try await self.service.updateElementGeometry(
                geometryDraft,
                elementID: elementID,
                on: pageID,
                in: self.albumID
            )
        }
        let succeeded = await performMutation(
            "Impossible d’enregistrer la transformation.",
            operation: operation
        )
        geometryGestureStart = nil
        rotationGestureOffset = nil
        snapGuides = []
        interaction = .idle
        if succeeded {
            self.geometryDraft = nil
            if disablesAutomaticLayout {
                showsAutomaticLayoutDisabledNotice = true
            }
        }
    }

    func adjustSelectedGeometry(
        deltaX: Double = 0,
        deltaY: Double = 0,
        deltaWidth: Double = 0,
        deltaHeight: Double = 0,
        deltaDegrees: Double = 0
    ) async {
        guard var geometry = selectedElement?.geometry,
              let pageID = activePageID,
              let elementID = selectedElementID else { return }
        let disablesAutomaticLayout = activePage?.layout.isAutoLayoutEnabled == true
            && selectedPhotoFrame != nil
        geometry.centerX = min(1, max(0, geometry.centerX + deltaX))
        geometry.centerY = min(1, max(0, geometry.centerY + deltaY))
        geometry.width = max(0.05, geometry.width + deltaWidth)
        geometry.height = max(0.05, geometry.height + deltaHeight)
        geometry.rotationRadians += deltaDegrees * .pi / 180
        let succeeded = await mutate("Impossible d’enregistrer la transformation.") {
            try await self.service.updateElementGeometry(
                geometry,
                elementID: elementID,
                on: pageID,
                in: self.albumID
            )
        }
        if succeeded, disablesAutomaticLayout {
            showsAutomaticLayoutDisabledNotice = true
        }
    }

    func makeSelectedElementFullPage() async {
        guard let pageID = activePageID,
              let elementID = selectedElementID,
              let selectedElement else { return }
        let disablesAutomaticLayout = activePage?.layout.isAutoLayoutEnabled == true
            && selectedElement.photoFrame != nil
        let geometry = ElementGeometry(
            centerX: 0.5,
            centerY: 0.5,
            width: 1,
            height: 1,
            rotationRadians: 0,
            order: selectedElement.geometry.order
        )
        let succeeded = await mutate("Impossible d’adapter le cadre à la page.") {
            try await self.service.updateElementGeometry(
                geometry,
                elementID: elementID,
                on: pageID,
                in: self.albumID
            )
        }
        if succeeded, disablesAutomaticLayout {
            showsAutomaticLayoutDisabledNotice = true
        }
    }

    func updatePhotoAccessibilityDescription(
        _ description: String,
        elementID: UUID,
        pageID: UUID
    ) async {
        guard description.count <= 500,
              var placement = album?.page(id: pageID)?
                .element(id: elementID)?.photoFrame?.content else { return }
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
        placement.accessibilityDescription = trimmed.isEmpty ? nil : trimmed
        await mutate("Impossible d’enregistrer la description accessible.") {
            try await self.service.updatePhotoPlacement(
                placement,
                elementID: elementID,
                on: pageID,
                in: self.albumID
            )
        }
    }

    func beginElementRotationPreview(elementID: UUID) {
        guard !isReadOnly, cropDraft == nil, let pageID = activePageID,
              let geometry = activePage?.element(id: elementID)?.geometry else { return }
        selectedElementID = elementID
        rotationPreviewEntry = (pageID, elementID, geometry)
        geometryDraft = geometry
    }

    func previewElementRotation(elementID: UUID, degrees: Double) {
        guard degrees.isFinite,
              let entry = rotationPreviewEntry,
              entry.elementID == elementID else { return }
        var geometry = entry.geometry
        geometry.rotationRadians = degrees * .pi / 180
        geometryDraft = geometry
    }

    func cancelElementRotationPreview(elementID: UUID) {
        guard rotationPreviewEntry?.elementID == elementID else { return }
        rotationPreviewEntry = nil
        geometryDraft = nil
    }

    func commitElementRotationPreview(elementID: UUID, degrees: Double) async {
        guard degrees.isFinite,
              let entry = rotationPreviewEntry,
              entry.elementID == elementID else { return }
        var geometry = entry.geometry
        geometry.rotationRadians = degrees * .pi / 180
        let disablesAutomaticLayout = activePage?.layout.isAutoLayoutEnabled == true
            && activePage?.element(id: elementID)?.photoFrame != nil
        let succeeded = await mutate("Impossible d’enregistrer la rotation.") {
            try await self.service.updateElementGeometry(
                geometry,
                elementID: elementID,
                on: entry.pageID,
                in: self.albumID
            )
        }
        rotationPreviewEntry = nil
        geometryDraft = nil
        if succeeded, activePage?.element(id: elementID) != nil {
            selectedElementID = elementID
            if disablesAutomaticLayout {
                showsAutomaticLayoutDisabledNotice = true
            }
        }
    }

    func beginCrop() {
        guard !isReadOnly,
              let frame = selectedPhotoFrame,
              let placement = frame.content,
              let metadata = metadata(for: placement.assetID),
              let minimum = try? PhotoCropGeometry.sessionMinimumNativeScale(
                  entryNativeScale: placement.nativeScale,
                  metadata: metadata,
                  frameGeometry: frame.geometry,
                  quarterTurns: placement.quarterTurns
              ) else { return }
        cropDraft = CropDraft(
            elementID: frame.id,
            entry: placement,
            placement: placement,
            sessionMinimum: minimum
        )
        interaction = .croppingPhoto(frame.id)
        helpContext = nil
    }

    func startCropGesture() {
        if cropGestureStart == nil {
            cropGestureStart = cropDraft?.placement
        }
    }

    func updateCropScale(magnification: Double) {
        guard let start = cropGestureStart ?? cropDraft?.placement,
              var draft = cropDraft,
              let value = try? PhotoCropGeometry.clampScale(
                  start.nativeScale * magnification,
                  sessionMinimum: draft.sessionMinimum
              ) else { return }
        draft.placement.nativeScale = value
        cropDraft = draft
    }

    func setCropScale(_ value: Double) {
        guard var draft = cropDraft,
              let clamped = try? PhotoCropGeometry.clampScale(
                  value,
                  sessionMinimum: draft.sessionMinimum
              ) else { return }
        draft.placement.nativeScale = clamped
        cropDraft = draft
    }

    func updateCropTranslation(_ translation: CGSize, frameSize: CGSize) {
        guard let start = cropGestureStart ?? cropDraft?.placement,
              var draft = cropDraft,
              let metadata = metadata(for: start.assetID),
              let frame = selectedPhotoFrame,
              let render = try? PhotoCropGeometry.renderGeometry(
                  placement: start,
                  metadata: metadata,
                  frameGeometry: frame.geometry
              ), frameSize.width > 0, frameSize.height > 0,
              let transformedStart = try? PhotoCropGeometry.transformedFocalPoint(
                  x: start.focalX,
                  y: start.focalY,
                  quarterTurns: start.quarterTurns,
                  flippedHorizontally: start.flippedHorizontally
              ) else { return }
        let canonicalX = Double(translation.width / frameSize.width) * render.frameSize.width
        let canonicalY = Double(translation.height / frameSize.height) * render.frameSize.height
        var transformed = GeometryPoint(
            x: min(1, max(0, transformedStart.x - canonicalX / render.renderedPhotoSize.width)),
            y: min(1, max(0, transformedStart.y - canonicalY / render.renderedPhotoSize.height))
        )
        if start.flippedHorizontally { transformed.x = 1 - transformed.x }
        let source = Self.inverseQuarterTurn(
            transformed,
            quarterTurns: start.quarterTurns
        )
        draft.placement.focalX = source.x
        draft.placement.focalY = source.y
        cropDraft = draft
    }

    func rotateCrop(by delta: Int) {
        guard var draft = cropDraft,
              let frame = selectedPhotoFrame,
              let metadata = metadata(for: draft.placement.assetID) else { return }
        draft.placement.quarterTurns = (
            (draft.placement.quarterTurns + delta) % 4 + 4
        ) % 4
        if let minimum = try? PhotoCropGeometry.sessionMinimumNativeScale(
            entryNativeScale: draft.entry.nativeScale,
            metadata: metadata,
            frameGeometry: frame.geometry,
            quarterTurns: draft.placement.quarterTurns
        ) {
            draft.sessionMinimum = minimum
            draft.placement.nativeScale = max(minimum, draft.placement.nativeScale)
        }
        cropDraft = draft
    }

    func flipCrop() {
        cropDraft?.placement.flippedHorizontally.toggle()
    }

    func resetCrop() {
        guard var draft = cropDraft else { return }
        draft.placement.nativeScale = 1
        draft.placement.focalX = 0.5
        draft.placement.focalY = 0.5
        draft.placement.quarterTurns = 0
        draft.placement.flippedHorizontally = false
        cropDraft = draft
    }

    func endCropGesture() {
        cropGestureStart = nil
    }

    func cancelCrop() {
        cropGestureStart = nil
        cropDraft = nil
        interaction = .idle
    }

    func commitCrop() async {
        guard await beginBusinessOperation() else { return }
        defer { endBusinessOperation() }
        await finishCrop()
    }

    private func finishCrop() async {
        guard let draft = cropDraft, let pageID = activePageID else { return }

        let operation: () async throws -> AlbumSnapshot = {
            try await self.service.updatePhotoPlacement(
                draft.placement,
                elementID: draft.elementID,
                on: pageID,
                in: self.albumID
            )
        }
        let succeeded = await performMutation(
            "Impossible d’enregistrer le cadrage.",
            operation: operation
        )
        if succeeded {
            cropGestureStart = nil
            cropDraft = nil
            interaction = .idle
        }
    }

    func zoomCanvasIn() {
        let start = viewport
        var value = start
        value.zoom = CanvasZoomEngine.nextStep(after: value.zoom)
        viewport = constrainedViewport(value, previousZoom: start.zoom)
    }

    func zoomCanvasOut() {
        let start = viewport
        var value = start
        value.zoom = CanvasZoomEngine.previousStep(before: value.zoom)
        viewport = constrainedViewport(value, previousZoom: start.zoom)
    }

    func fitCanvas() {
        viewport = .fitted
    }

    func pinchCanvas(
        from start: CanvasViewportState,
        magnification: Double,
        anchor: GeometryPoint,
        fittedPageSize: CGSize,
        viewportSize: CGSize
    ) {
        guard cropDraft == nil else { return }
        let pinched = CanvasZoomEngine.pinched(
            start,
            magnification: magnification,
            anchor: anchor
        )
        viewport = CanvasZoomEngine.panned(
            pinched,
            translationPoints: GeometryPoint(x: 0, y: 0),
            fittedPageSizePoints: GeometrySize(
                width: Double(fittedPageSize.width),
                height: Double(fittedPageSize.height)
            ),
            viewportSizePoints: GeometrySize(
                width: Double(viewportSize.width),
                height: Double(viewportSize.height)
            )
        )
    }

    func panCanvas(
        from start: CanvasViewportState,
        translation: CGSize,
        fittedPageSize: CGSize,
        viewportSize: CGSize
    ) {
        guard cropDraft == nil else { return }
        viewport = CanvasZoomEngine.panned(
            start,
            translationPoints: GeometryPoint(
                x: Double(translation.width),
                y: Double(translation.height)
            ),
            fittedPageSizePoints: GeometrySize(
                width: Double(fittedPageSize.width),
                height: Double(fittedPageSize.height)
            ),
            viewportSizePoints: GeometrySize(
                width: Double(viewportSize.width),
                height: Double(viewportSize.height)
            )
        )
    }

    func transformCanvas(
        from start: CanvasViewportState,
        magnification: Double,
        translation: CGSize,
        anchor: GeometryPoint,
        fittedPageSize: CGSize,
        viewportSize: CGSize
    ) {
        guard cropDraft == nil else { return }
        viewport = CanvasZoomEngine.transformed(
            start,
            magnification: magnification,
            translationPoints: GeometryPoint(
                x: Double(translation.width),
                y: Double(translation.height)
            ),
            anchorNormalized: anchor,
            fittedPageSizePoints: GeometrySize(
                width: Double(fittedPageSize.width),
                height: Double(fittedPageSize.height)
            ),
            viewportSizePoints: GeometrySize(
                width: Double(viewportSize.width),
                height: Double(viewportSize.height)
            )
        )
    }

    func copySelected() async {
        guard let pageID = activePageID, let elementID = selectedElementID else { return }
        guard await beginBusinessOperation() else { return }
        defer { endBusinessOperation() }

        do {
            try await service.copyElement(elementID, on: pageID, in: albumID)
            try await refreshSessionState()
        } catch {
            present(error, fallback: "Impossible de copier le cadre.")
        }
    }

    func cutSelected() async {
        guard let pageID = activePageID, let elementID = selectedElementID else { return }
        await mutate("Impossible de couper le cadre.") {
            try await self.service.cutElement(elementID, on: pageID, in: self.albumID)
        }
        if activePage?.element(id: elementID) == nil { selectedElementID = nil }
    }

    func paste() async {
        guard let pageID = activePageID else { return }
        let newID = UUID()
        await mutate("Impossible de coller le cadre.") {
            try await self.service.pasteElement(
                on: pageID,
                in: self.albumID,
                newElementID: newID,
                offsetNormalized: self.elementCommandOffset(on: pageID)
            )
        }
        if activePage?.element(id: newID) != nil { selectedElementID = newID }
    }

    func undo() async {
        layoutShuffleBag.reset()
        await mutate("Impossible d’annuler cette action.") {
            try await self.service.undo(albumID: self.albumID)
        }
        keepValidSelection()
    }

    func redo() async {
        layoutShuffleBag.reset()
        let previousPageIDs = Set(album?.pages.map(\.id) ?? [])
        let succeeded = await mutate("Impossible de rétablir cette action.") {
            try await self.service.redo(albumID: self.albumID)
        }
        if succeeded {
            let recreated = (album?.pages ?? []).filter {
                !previousPageIDs.contains($0.id)
            }
            if recreated.count == 1 {
                activePageID = recreated[0].id
                selectedElementID = nil
            }
        }
        keepValidSelection()
    }

    @discardableResult
    func save() async -> Bool {
        // Une scène en lecture seule n'a aucune mutation locale à consolider.
        // Ce succès sans effet permet à la fermeture explicite de continuer.
        if isReadOnly { return true }
        guard ownsLease else {
            errorMessage = "La session d’édition n’est pas encore disponible."
            return false
        }

        let operationBlockToken = beginOperationBlock()
        defer { endOperationBlock(operationBlockToken) }
        await waitForBusinessOperationsToFinish()

        if let rotationPreviewEntry {
            cancelElementRotationPreview(elementID: rotationPreviewEntry.elementID)
        }
        if geometryDraft != nil {
            // La sauvegarde possède déjà la barrière : réenregistrer cette
            // mutation créerait une attente sur elle-même.
            suppressGeometryUpdatesUntilGestureEnds = true
            await finishGeometryGesture()
            guard saveState != .failed else { return false }
        }
        if cropDraft != nil {
            await finishCrop()
            guard saveState != .failed else { return false }
        }
        saveState = .saving
        do {
            try await service.save()
            album = try await service.album(id: albumID)
            try await reloadPhotosAndSession()
            try await appModel.refreshLibrary()
            keepValidPageAndSelection()
            refreshCapacityWarnings()
            markSaved()
            return true
        } catch {
            saveState = .failed
            present(error, fallback: "Impossible d’enregistrer. Réessayez.")
            return false
        }
    }

    func clearError() { errorMessage = nil }

    func clearCapacityWarning() { capacityWarning = nil }

    func recordRenderedPageSize(
        _ size: CGSize,
        viewportSize: CGSize,
        pageID: UUID
    ) {
        guard size.width > 0, size.height > 0,
              viewportSize.width > 0, viewportSize.height > 0 else { return }
        renderedPageSizes[pageID] = size
        canvasWorkspaceSizes[pageID] = viewportSize
    }

    @discardableResult
    private func mutate(
        _ fallback: String,
        operation: () async throws -> AlbumSnapshot
    ) async -> Bool {
        guard await beginBusinessOperation() else { return false }
        defer { endBusinessOperation() }

        return await performMutation(fallback, operation: operation)
    }

    @discardableResult
    private func performMutation(
        _ fallback: String,
        operation: () async throws -> AlbumSnapshot
    ) async -> Bool {
        guard ownsLease, !isReadOnly else {
            errorMessage = "Cet album est déjà modifié dans une autre fenêtre."
            return false
        }
        saveState = .saving
        do {
            album = try await operation()
            try await reloadPhotosAndSession()
            try await appModel.refreshLibrary()
            keepValidPageAndSelection()
            refreshCapacityWarnings()
            markSaved()
            return true
        } catch {
            saveState = .failed
            present(error, fallback: fallback)
            return false
        }
    }

    /// Accepts commands while editing remains available, then gives each one
    /// an explicit FIFO turn. The Core also serializes durable transactions;
    /// this UI-side queue prevents an older async completion from replacing a
    /// newer album snapshot, progress state or undo state on the main actor.
    private func beginBusinessOperation() async -> Bool {
        guard ownsLease, !isReadOnly else {
            errorMessage = "Cet album est déjà modifié dans une autre fenêtre."
            return false
        }
        guard operationBlockTokens.isEmpty else {
            errorMessage = "Une sauvegarde ou une fermeture est en cours."
            return false
        }
        activeBusinessOperationCount += 1
        await acquireBusinessOperationTurn()
        return true
    }

    private func endBusinessOperation() {
        guard activeBusinessOperationCount > 0 else {
            assertionFailure("Fin d’opération métier sans opération active.")
            return
        }
        releaseBusinessOperationTurn()
        activeBusinessOperationCount -= 1
        guard activeBusinessOperationCount == 0 else { return }

        let waiters = businessOperationWaiters
        businessOperationWaiters.removeAll(keepingCapacity: true)
        for waiter in waiters {
            waiter.resume()
        }
    }

    private func acquireBusinessOperationTurn() async {
        guard businessOperationTurnIsOccupied else {
            businessOperationTurnIsOccupied = true
            return
        }
        await withCheckedContinuation { continuation in
            businessOperationTurnWaiters.append(continuation)
        }
    }

    private func releaseBusinessOperationTurn() {
        guard !businessOperationTurnWaiters.isEmpty else {
            businessOperationTurnIsOccupied = false
            return
        }
        businessOperationTurnWaiters.removeFirst().resume()
    }

    private func waitForBusinessOperationsToFinish() async {
        guard activeBusinessOperationCount > 0 else { return }
        await withCheckedContinuation { continuation in
            businessOperationWaiters.append(continuation)
        }
    }

    private func beginOperationBlock() -> UUID {
        let token = UUID()
        operationBlockTokens.insert(token)
        return token
    }

    private func endOperationBlock(_ token: UUID) {
        operationBlockTokens.remove(token)
    }

    private func reloadPhotosAndSession() async throws {
        photos = try await service.photoAssets(
            in: albumID,
            sortedBy: photoSort,
            ascending: sortsAscending
        )
        try await refreshSessionState()
    }

    private func refreshSessionState() async throws {
        let value = await service.sessionState(for: albumID)
        let clipboard = await service.clipboardPayload()
        canUndo = value.canUndo
        canRedo = value.canRedo
        hasCompatibleClipboard = value.hasCompatibleClipboard
        clipboardContainsEmptyPhotoFrame = clipboard?.element.photoFrame != nil
            && clipboard?.element.photoFrame?.content == nil
    }

    private func markSaved() {
        saveState = .saved(Date())
    }

    private func updateImportProgressItem(
        at index: Int,
        status: ImportFileProgressStatus
    ) {
        guard var progress = importProgress,
              progress.items.indices.contains(index) else { return }
        progress.items[index].status = status
        if status == .copied || status == .failed {
            progress.completed = max(progress.completed, index + 1)
        }
        importProgress = progress
    }

    private func refreshCapacityWarnings() {
        guard let album else { return }
        let warnings = AlbumCapacityPolicy.warnings(
            for: album,
            photoAssets: photos
        )
        let currentKeys = Set(warnings.map(capacityWarningKey))
        let newlyExceeded = warnings.filter {
            !knownCapacityWarningKeys.contains(capacityWarningKey($0))
        }
        knownCapacityWarningKeys = currentKeys
        guard !newlyExceeded.isEmpty else { return }
        capacityWarning = capacityWarningMessage(newlyExceeded, album: album)
    }

    private func capacityWarningKey(_ warning: AlbumCapacityWarning) -> CapacityWarningKey {
        switch warning {
        case .pageCount:
            return .pages
        case .albumByteCount:
            return .bytes
        case let .elementCount(pageID, kind, _, _):
            return .elements(pageID, kind)
        }
    }

    private func capacityWarningMessage(
        _ warnings: [AlbumCapacityWarning],
        album: AlbumSnapshot
    ) -> String {
        let details = warnings.map { warning -> String in
            switch warning {
            case let .pageCount(actual, guaranteed):
                return "L’album contient \(actual) pages ; l’enveloppe garantie est de \(guaranteed)."
            case let .albumByteCount(actual, guaranteed):
                let actualValue = ByteCountFormatter.string(
                    fromByteCount: actual,
                    countStyle: .decimal
                )
                let guaranteedValue = ByteCountFormatter.string(
                    fromByteCount: guaranteed,
                    countStyle: .decimal
                )
                return "L’album utilise \(actualValue) ; l’enveloppe garantie est de \(guaranteedValue)."
            case let .elementCount(pageID, kind, actual, guaranteed):
                let pageNumber = album.pages.firstIndex { $0.id == pageID }
                    .map { $0 + 1 } ?? 0
                let label: String
                switch kind {
                case .photo: label = "cadres photo"
                case .text: label = "zones de texte"
                case .sticker: label = "stickers"
                }
                return "La page \(pageNumber) contient \(actual) \(label) ; l’enveloppe garantie est de \(guaranteed)."
            }
        }
        return details.joined(separator: "\n")
            + "\nLa commande a réussi. Vous pouvez continuer si l’appareil dispose de ressources suffisantes."
    }

    private func keepValidPageAndSelection() {
        guard let album else { return }
        if activePageID.flatMap({ album.page(id: $0) }) == nil {
            activePageID = album.pages.first?.id
        }
        keepValidSelection()
    }

    private func elementCommandOffset(on pageID: UUID) -> GeometryPoint {
        let size = renderedPageSizes[pageID] ?? CGSize(
            width: CGFloat(AlbumPhotoConstants.canonicalPageWidth),
            height: CGFloat(AlbumPhotoConstants.canonicalPageHeight)
        )
        return GeometryPoint(
            x: 12 / Double(size.width),
            y: 12 / Double(size.height)
        )
    }

    private func constrainedViewport(
        _ proposed: CanvasViewportState,
        previousZoom: Double
    ) -> CanvasViewportState {
        guard let pageID = activePageID,
              let rendered = renderedPageSizes[pageID],
              let workspace = canvasWorkspaceSizes[pageID],
              previousZoom > 0 else { return proposed }
        return CanvasZoomEngine.panned(
            proposed,
            translationPoints: GeometryPoint(x: 0, y: 0),
            fittedPageSizePoints: GeometrySize(
                width: Double(rendered.width) / previousZoom,
                height: Double(rendered.height) / previousZoom
            ),
            viewportSizePoints: GeometrySize(
                width: Double(workspace.width),
                height: Double(workspace.height)
            )
        )
    }

    private func keepValidSelection() {
        if let selectedElementID,
           activePage?.element(id: selectedElementID) == nil {
            self.selectedElementID = nil
        }
    }

    private func goNextIgnoringTransitionLock() {
        guard let album, activePageIndex < album.pages.count - 1 else { return }
        activePageID = album.pages[activePageIndex + 1].id
        selectedElementID = nil
    }

    private func goPreviousIgnoringTransitionLock() {
        guard let album, activePageIndex > 0 else { return }
        activePageID = album.pages[activePageIndex - 1].id
        selectedElementID = nil
    }

    private func present(_ error: Error, fallback: String) {
        errorMessage = Self.message(for: error, fallback: fallback)
    }

    private static func message(for error: Error, fallback: String = "Une erreur est survenue.") -> String {
        if let value = error as? DomainValidationError { return value.description }
        if let value = error as? LocalizedError, let description = value.errorDescription {
            return description
        }
        return fallback
    }

    private static func importFailureStatus(
        for error: Error
    ) -> PhotoImportFailureStatus {
        guard let value = error as? ApplePhotoImportError else {
            return .interrupted
        }
        switch value {
        case .animatedImage, .unsupportedFormat, .imageTooLarge, .invalidDimensions:
            return .unsupported
        case .inaccessibleFile, .undecodableImage, .insufficientStorage:
            return .inaccessible
        }
    }

    private static func inverseQuarterTurn(
        _ point: GeometryPoint,
        quarterTurns: Int
    ) -> GeometryPoint {
        switch ((quarterTurns % 4) + 4) % 4 {
        case 0: return point
        case 1: return GeometryPoint(x: point.y, y: 1 - point.x)
        case 2: return GeometryPoint(x: 1 - point.x, y: 1 - point.y)
        default: return GeometryPoint(x: 1 - point.y, y: point.x)
        }
    }
}
