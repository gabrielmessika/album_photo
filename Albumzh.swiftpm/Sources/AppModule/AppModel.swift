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
            for input in BundledBackgroundResources.bootstrapInputs() {
                // Une ressource bundle absente ou corrompue ne bloque jamais
                // l’accès : le blob déjà indexé reste le fallback de BG-008.
                guard (try? await mediaStore.ensureStorageCapacity(
                    forByteCount: Int64(input.data.count)
                )) != nil else { continue }
                _ = try? await catalogBootstrap.bootstrap(
                    [input],
                    commandID: Self.catalogBootstrapCommandID(input.catalogID)
                )
            }
            _ = try await service.evaluateTrashExpiration(
                trigger: didEvaluateRetentionAtLaunch
                    ? .applicationActive : .applicationLaunch
            )
            didEvaluateRetentionAtLaunch = true
            try await refreshLibrary()
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
            return UUID(uuidString: "8d156ffa-9fb1-4b18-9ad4-ea22df2ce470")!
        }
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
