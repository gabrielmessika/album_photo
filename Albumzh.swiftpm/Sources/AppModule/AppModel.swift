import AlbumPhotoCore
import Foundation
import SwiftUI

enum SavePresentationState: Equatable {
    case saved(Date?)
    case saving
    case failed

    var label: String {
        switch self {
        case let .saved(date):
            guard let date else { return "Enregistré" }
            return "Enregistré à \(date.formatted(date: .omitted, time: .shortened))"
        case .saving:
            return "Enregistrement…"
        case .failed:
            return "Échec de sauvegarde"
        }
    }

    var symbol: String {
        switch self {
        case .saved: "checkmark.circle"
        case .saving: "arrow.triangle.2.circlepath"
        case .failed: "exclamationmark.triangle"
        }
    }
}

@MainActor
final class AppModel: ObservableObject {
    let service: AlbumApplicationService
    let mediaStore: AppleMediaStore
    let imageCache: PhotoImageCache
    let photoReuseCoordinator: VerifiedPhotoReuseCoordinator
    private let catalogBootstrap: CatalogResourceBootstrapService

    @Published private(set) var albums: [AlbumSnapshot] = []
    @Published private(set) var trashedAlbums: [AlbumSnapshot] = []
    @Published private(set) var librarySnapshot: LocalLibrarySnapshot = .empty
    @Published private(set) var canUndoLibrary = false
    @Published private(set) var canRedoLibrary = false
    @Published var errorMessage: String?
    @Published private(set) var isLoading = false
    private var didPrepareStorage = false
    private var didEvaluateRetentionAtLaunch = false
    private var retentionMaintenanceTask: Task<Void, Never>?
    private var catalogBootstrapTask: Task<Void, Never>?
    private var defaultCatalogBootstrapTask: Task<Void, Never>?

    init(
        service: AlbumApplicationService,
        mediaStore: AppleMediaStore,
        catalogBootstrap: CatalogResourceBootstrapService,
        photoReuseCoordinator: VerifiedPhotoReuseCoordinator
    ) {
        self.service = service
        self.mediaStore = mediaStore
        self.catalogBootstrap = catalogBootstrap
        self.photoReuseCoordinator = photoReuseCoordinator
        self.imageCache = PhotoImageCache(mediaStore: mediaStore)
    }

    deinit {
        retentionMaintenanceTask?.cancel()
        catalogBootstrapTask?.cancel()
        defaultCatalogBootstrapTask?.cancel()
    }

    func loadLibrary() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            if !didPrepareStorage {
                try await mediaStore.prepareForLaunch()
                didPrepareStorage = true
            }
            _ = try await service.evaluateTrashExpiration(
                trigger: didEvaluateRetentionAtLaunch
                    ? .applicationActive : .applicationLaunch
            )
            didEvaluateRetentionAtLaunch = true
            try await refreshLibrary()
            scheduleMissingCatalogBootstrapIfNeeded()
            startRetentionMaintenanceIfNeeded()
        } catch {
            present(error, fallback: "Impossible de charger la bibliothèque.")
        }
    }

    func refreshLibrary() async throws {
        async let active = service.activeAlbums()
        async let trashed = service.trashedAlbums()
        async let snapshot = service.snapshot()
        albums = try await active
        trashedAlbums = try await trashed
        librarySnapshot = try await snapshot
        canUndoLibrary = await service.canUndoLibrary()
        canRedoLibrary = await service.canRedoLibrary()
    }

    func createAlbum(named name: String) async -> AlbumSnapshot? {
        if let defaultCatalogBootstrapTask {
            await defaultCatalogBootstrapTask.value
        }
        guard defaultCatalogResourceIsReady else {
            errorMessage = "Le fond par défaut n’est pas encore disponible. Réessayez."
            return nil
        }
        do {
            let album = try await service.createAlbum(named: name)
            try await refreshLibrary()
            return album
        } catch {
            present(error, fallback: "Impossible de créer l’album.")
            return nil
        }
    }

    func renameAlbum(id: UUID, to name: String) async -> Bool {
        do {
            _ = try await service.renameAlbum(id, to: name, history: .library)
            try await refreshLibrary()
            return true
        } catch {
            present(error, fallback: "Impossible de renommer l’album.")
            return false
        }
    }

    func moveToTrash(id: UUID) async -> Bool {
        do {
            _ = try await service.moveAlbumToTrash(id)
            try await refreshLibrary()
            return true
        } catch {
            present(error, fallback: "Impossible de placer l’album dans la corbeille.")
            return false
        }
    }

    func restore(id: UUID) async {
        do {
            _ = try await service.restoreAlbum(id)
            try await refreshLibrary()
        } catch {
            present(error, fallback: "Impossible de restaurer l’album.")
        }
    }

    func permanentlyDelete(id: UUID) async -> Bool {
        do {
            try await service.permanentlyDeleteAlbum(id)
            try await refreshLibrary()
            return true
        } catch {
            present(error, fallback: "Impossible de supprimer définitivement l’album.")
            return false
        }
    }

    func setCover(_ selection: CoverSelection, albumID: UUID) async -> Bool {
        do {
            _ = try await service.setCover(
                selection,
                for: albumID,
                fromLibrary: true
            )
            try await refreshLibrary()
            return true
        } catch {
            present(error, fallback: "Impossible de modifier la couverture.")
            return false
        }
    }

    func undoLibraryAction() async {
        do {
            _ = try await service.undoLibrary()
            try await refreshLibrary()
        } catch {
            present(error, fallback: "Impossible d’annuler cette action.")
        }
    }

    func redoLibraryAction() async {
        do {
            _ = try await service.redoLibrary()
            try await refreshLibrary()
        } catch {
            present(error, fallback: "Impossible de rétablir cette action.")
        }
    }

    /// APP-006 / UND-012 — consolide les écritures de la bibliothèque puis
    /// abandonne ses historiques de session avant de changer de contexte.
    @discardableResult
    func closeLibrarySession() async -> Bool {
        do {
            try await service.closeLibrarySession()
            try await refreshLibrary()
            return true
        } catch {
            present(
                error,
                fallback: "Impossible de fermer la session de la bibliothèque."
            )
            return false
        }
    }

    /// APP-002 / APP-006 — une route vers l’éditeur n’est créée qu’après la
    /// clôture durable de la session bibliothèque. La vérification locale
    /// évite aussi d’ouvrir un album devenu absent ou placé dans la corbeille.
    func prepareToOpenAlbum(_ albumID: UUID) async -> Bool {
        guard albums.contains(where: { $0.id == albumID }) else {
            present(
                DomainValidationError.albumNotFound(albumID),
                fallback: "Impossible d’ouvrir l’album."
            )
            return false
        }
        return await closeLibrarySession()
    }

    func metadata(for assetID: UUID) -> PhotoAssetMetadata? {
        librarySnapshot.photoAsset(id: assetID)
    }

    func album(id: UUID) -> AlbumSnapshot? {
        librarySnapshot.album(id: id)
    }

    func waitForCatalogBootstrap() async {
        await catalogBootstrapTask?.value
    }

    func clearError() {
        errorMessage = nil
    }

    private static func catalogBootstrapCommandID(_ catalogID: String) -> UUID {
        switch catalogID {
        case "album.travelKraft":
            return UUID(uuidString: "b3772d40-5dc2-40b7-a987-ad782fe53ad0")!
        case "album.minimalDark":
            return UUID(uuidString: "5d3ebbb0-ff12-4db2-8ff2-6899466341b9")!
        default:
            // Every asset needs its own stable replay key. Reusing one UUID
            // would make the repository treat the second sticker/frame as an
            // already-applied command and leave the rest of the catalog absent.
            let digest = SHA256.hexDigest(Data("catalog-bootstrap:\(catalogID)".utf8))
            let compact = String(digest.prefix(32))
            let uuidComponents = [
                String(compact.prefix(8)),
                String(compact.dropFirst(8).prefix(4)),
                String(compact.dropFirst(12).prefix(4)),
                String(compact.dropFirst(16).prefix(4)),
                String(compact.dropFirst(20).prefix(12))
            ]
            let formatted = uuidComponents.joined(separator: "-")
            return UUID(uuidString: formatted)!
        }
    }

    /// PERF-007 / PERF-016 — le catalogue déjà indexé ne relit plus les PNG du
    /// bundle à chaque relance. Une ressource réellement absente est copiée
    /// après l’affichage de la bibliothèque et ne bloque jamais son ouverture.
    private func scheduleMissingCatalogBootstrapIfNeeded() {
        guard catalogBootstrapTask == nil else { return }
        let indexedHashes: Set<String> = Set(
            librarySnapshot.blobIndex
                .filter { $0.state == .available }
                .map(\.contentHash)
        )
        let missingCatalogIDs: Set<String> = Set(
            BuiltInCatalogRegistry.entries.compactMap { descriptor -> String? in
                guard case let .asset(hash, _, _) = descriptor.payload,
                      !indexedHashes.contains(hash) else { return nil }
                return descriptor.catalogID
            }
        )
        guard !missingCatalogIDs.isEmpty else { return }

        let defaultID = BackgroundCatalog.defaultTheme.catalogID
        let needsDefault = missingCatalogIDs.contains(defaultID)
        let remainingIDs = missingCatalogIDs.subtracting([defaultID])
        let defaultTask: Task<Void, Never>? = needsDefault
            ? Task { [weak self] in
                await Task.yield()
                await self?.bootstrapCatalogResources(
                    catalogIDs: [defaultID],
                    refreshesLibrary: true
                )
            }
            : nil
        defaultCatalogBootstrapTask = defaultTask

        catalogBootstrapTask = Task { [weak self, defaultTask] in
            await defaultTask?.value
            guard let self, !Task.isCancelled else { return }
            self.defaultCatalogBootstrapTask = nil
            await self.bootstrapCatalogResources(
                catalogIDs: remainingIDs,
                refreshesLibrary: false
            )
            self.catalogBootstrapTask = nil
        }
    }

    private var defaultCatalogResourceIsReady: Bool {
        guard let hash = BackgroundCatalog.defaultTheme.fallbackContentHash else {
            return false
        }
        return librarySnapshot.blobIndex.contains {
            $0.contentHash == hash && $0.state == .available
        }
    }

    private func bootstrapCatalogResources(
        catalogIDs: Set<String>,
        refreshesLibrary: Bool
    ) async {
        guard !catalogIDs.isEmpty else { return }
        for input in BundledCatalogResources.bootstrapInputs(
            catalogIDs: catalogIDs
        ) {
            guard !Task.isCancelled,
                  (try? await mediaStore.ensureStorageCapacity(
                      forByteCount: Int64(input.data.count)
                  )) != nil else { continue }
            _ = try? await catalogBootstrap.bootstrap(
                [input],
                commandID: Self.catalogBootstrapCommandID(input.catalogID)
            )
        }
        if refreshesLibrary { try? await refreshLibrary() }
    }

    /// ALB-023 — une seule boucle par conteneur réévalue la corbeille toutes
    /// les 24 heures tant que l’application reste vivante. La tâche n’entretient
    /// pas le modèle artificiellement et est annulée à sa destruction.
    private func startRetentionMaintenanceIfNeeded() {
        guard retentionMaintenanceTask == nil else { return }
        retentionMaintenanceTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: 86_400_000_000_000)
                } catch {
                    return
                }
                guard let self else { return }
                await self.performRetentionMaintenance()
            }
        }
    }

    private func performRetentionMaintenance() async {
        do {
            _ = try await service.evaluateTrashExpiration(
                trigger: .applicationActive
            )
            try await refreshLibrary()
        } catch {
            present(
                error,
                fallback: "Impossible de réévaluer la corbeille automatiquement."
            )
        }
    }

    func present(_ error: Error, fallback: String) {
        if let described = error as? DomainValidationError {
            errorMessage = described.description
        } else if let localized = error as? LocalizedError,
                  let description = localized.errorDescription {
            errorMessage = description
        } else {
            errorMessage = fallback
        }
    }
}

struct AlbumRoute: Identifiable, Equatable {
    let albumID: UUID
    var id: UUID { albumID }
}
