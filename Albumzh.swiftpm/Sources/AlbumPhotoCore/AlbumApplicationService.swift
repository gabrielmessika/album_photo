import Foundation

public enum PhotoSortOption: String, Codable, Sendable, Equatable, Hashable {
    case capturedAt
    case filename
    case importedAt
}

public struct PhotoRegistration: Sendable, Equatable {
    public let metadata: PhotoAssetMetadata
    public let blob: AssetBlobIndexEntry
    public let displayDerivativeBlob: AssetBlobIndexEntry?

    public init(
        metadata: PhotoAssetMetadata,
        blob: AssetBlobIndexEntry,
        displayDerivativeBlob: AssetBlobIndexEntry? = nil
    ) {
        self.metadata = metadata
        self.blob = blob
        self.displayDerivativeBlob = displayDerivativeBlob
    }
}

public enum ElementDepthMove: String, Codable, Sendable, Equatable, Hashable {
    case front
    case forward
    case backward
    case back
}

/// Selects the session-local history that owns an album rename. The call site
/// must state its UI context so a rename made in the editor cannot silently
/// enter the independent library history (3:UND-004, 3:UND-011).
public enum AlbumRenameHistory: Sendable, Equatable {
    case editor
    case library
}

public enum TrashExpirationTrigger: Sendable, Equatable {
    case applicationLaunch
    case applicationActive
}

public struct TrashExpirationEvaluation: Sendable, Equatable {
    public let didEvaluate: Bool
    public let purgedAlbumCount: Int

    public init(didEvaluate: Bool, purgedAlbumCount: Int) {
        self.didEvaluate = didEvaluate
        self.purgedAlbumCount = purgedAlbumCount
    }
}

public struct ElementClipboardPayload: Codable, Sendable, Equatable {
    public let version: Int
    public let sourceAlbumID: UUID
    public let sourcePageID: UUID
    public let element: PageElement
    public let photoMetadata: PhotoAssetMetadata?

    public init(
        version: Int = 1,
        sourceAlbumID: UUID,
        sourcePageID: UUID,
        element: PageElement,
        photoMetadata: PhotoAssetMetadata?
    ) {
        self.version = version
        self.sourceAlbumID = sourceAlbumID
        self.sourcePageID = sourcePageID
        self.element = element
        self.photoMetadata = photoMetadata
    }
}

public struct AlbumSessionState: Sendable, Equatable {
    public let canUndo: Bool
    public let canRedo: Bool
    public let hasCompatibleClipboard: Bool

    public init(canUndo: Bool, canRedo: Bool, hasCompatibleClipboard: Bool) {
        self.canUndo = canUndo
        self.canRedo = canRedo
        self.hasCompatibleClipboard = hasCompatibleClipboard
    }
}

private struct AlbumStateBundle: Sendable, Equatable {
    let album: AlbumSnapshot
    let assets: [PhotoAssetRecord]
}

private struct ReversibleAlbumCommand: Sendable, Equatable {
    let id: UUID
    let label: String
    let before: AlbumStateBundle
    let after: AlbumStateBundle
}

/// `LibraryRepository.load()` and `commit()` intentionally expose optimistic
/// revisions. Swift actor reentrancy may otherwise let two UI commands load
/// the same revision before either commits. This FIFO gate covers the complete
/// read/validate/commit envelope (3:APP-005, 3:LOC-011...3:LOC-014).
private actor DurableMutationSerialiser {
    private var isOccupied = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func enter() async {
        guard isOccupied else {
            isOccupied = true
            return
        }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    func leave() {
        guard !waiters.isEmpty else {
            isOccupied = false
            return
        }
        waiters.removeFirst().resume()
    }
}

public actor AlbumEditLeaseService {
    private var owners: [UUID: UUID] = [:]
    private var closingOwners: [UUID: UUID] = [:]
    private var libraryMutationOwners: [UUID: UUID] = [:]
    private var isClosingLibrarySession = false

    public init() {}

    public func acquire(albumID: UUID, sceneID: UUID) -> Bool {
        guard !isClosingLibrarySession,
              closingOwners[albumID] == nil,
              libraryMutationOwners[albumID] == nil else { return false }
        if let owner = owners[albumID] { return owner == sceneID }
        owners[albumID] = sceneID
        return true
    }

    public func release(albumID: UUID, sceneID: UUID) {
        // A close in progress owns the transition until its durable flush has
        // either succeeded or failed. This prevents another scene acquiring
        // the album while the first scene is about to clear session history.
        guard closingOwners[albumID] != sceneID else { return }
        if owners[albumID] == sceneID { owners[albumID] = nil }
    }

    public func isReadOnly(albumID: UUID, sceneID: UUID) -> Bool {
        if isClosingLibrarySession
            || closingOwners[albumID] != nil
            || libraryMutationOwners[albumID] != nil { return true }
        return owners[albumID].map { $0 != sceneID } ?? false
    }

    /// Atomically excludes edit-lease acquisition while a library command is
    /// reading and committing one album. The token prevents a stale operation
    /// from releasing another command's barrier (3:APP-002, 3:APP-005).
    func beginLibraryMutation(albumID: UUID, mutationID: UUID) -> Bool {
        guard !isClosingLibrarySession,
              owners[albumID] == nil,
              closingOwners[albumID] == nil,
              libraryMutationOwners.isEmpty else { return false }
        libraryMutationOwners[albumID] = mutationID
        return true
    }

    func completeLibraryMutation(albumID: UUID, mutationID: UUID) {
        if libraryMutationOwners[albumID] == mutationID {
            libraryMutationOwners[albumID] = nil
        }
    }

    func cancelLibraryMutation(albumID: UUID, mutationID: UUID) {
        completeLibraryMutation(albumID: albumID, mutationID: mutationID)
    }

    func beginClosingLibrarySession() -> Bool {
        guard !isClosingLibrarySession, libraryMutationOwners.isEmpty else {
            return false
        }
        isClosingLibrarySession = true
        return true
    }

    func completeClosingLibrarySession() {
        isClosingLibrarySession = false
    }

    func cancelClosingLibrarySession() {
        isClosingLibrarySession = false
    }

    func beginClosing(albumID: UUID, sceneID: UUID) -> Bool {
        guard owners[albumID] == sceneID, closingOwners[albumID] == nil else {
            return false
        }
        closingOwners[albumID] = sceneID
        return true
    }

    func completeClosing(albumID: UUID, sceneID: UUID) {
        guard owners[albumID] == sceneID, closingOwners[albumID] == sceneID else {
            return
        }
        closingOwners[albumID] = nil
        owners[albumID] = nil
    }

    func cancelClosing(albumID: UUID, sceneID: UUID) {
        if closingOwners[albumID] == sceneID {
            closingOwners[albumID] = nil
        }
    }
}

/// Application-facing actor. Every validated mutation is committed before its
/// resulting snapshot is returned, so a SwiftUI view never writes storage.
public actor AlbumApplicationService {
    private let repository: any LibraryRepository
    public let editLeases: AlbumEditLeaseService
    private let durableMutationSerialiser = DurableMutationSerialiser()
    private var undoStacks: [UUID: [ReversibleAlbumCommand]] = [:]
    private var redoStacks: [UUID: [ReversibleAlbumCommand]] = [:]
    private var libraryUndoStack: [ReversibleAlbumCommand] = []
    private var libraryRedoStack: [ReversibleAlbumCommand] = []
    private var libraryReplayAlbumIDs: [UUID: UUID] = [:]
    private var clipboard: ElementClipboardPayload?
    private var clipboardMutationVersion: UInt64 = 0
    private var lastTrashExpirationEvaluationAt: Date?

    public init(
        repository: any LibraryRepository,
        editLeases: AlbumEditLeaseService = AlbumEditLeaseService()
    ) {
        self.repository = repository
        self.editLeases = editLeases
    }

    // MARK: Queries

    public func snapshot() async throws -> LocalLibrarySnapshot {
        try await repository.load()
    }

    public func activeAlbums() async throws -> [AlbumSnapshot] {
        try await repository.load().albums
            .filter { !$0.isTrashed }
            .sorted(by: albumRecencyOrder)
    }

    public func trashedAlbums() async throws -> [AlbumSnapshot] {
        try await repository.load().albums
            .filter(\.isTrashed)
            .sorted {
                let lhs = $0.trashedAt ?? .distantPast
                let rhs = $1.trashedAt ?? .distantPast
                return lhs == rhs ? $0.id.uuidString < $1.id.uuidString : lhs > rhs
            }
    }

    public func album(id: UUID) async throws -> AlbumSnapshot {
        guard let album = try await repository.load().album(id: id) else {
            throw DomainValidationError.albumNotFound(id)
        }
        return album
    }

    public func photoAssets(
        in albumID: UUID,
        sortedBy sort: PhotoSortOption = .importedAt,
        ascending: Bool = true
    ) async throws -> [PhotoAssetMetadata] {
        let state = try await repository.load()
        guard state.album(id: albumID) != nil else {
            throw DomainValidationError.albumNotFound(albumID)
        }
        let values = state.photoAssets(in: albumID).sorted { lhs, rhs in
            let result: Bool
            switch sort {
            case .capturedAt:
                result = (lhs.capturedAt ?? lhs.importedAt) == (rhs.capturedAt ?? rhs.importedAt)
                    ? lhs.id.uuidString < rhs.id.uuidString
                    : (lhs.capturedAt ?? lhs.importedAt) < (rhs.capturedAt ?? rhs.importedAt)
            case .filename:
                let lhsName = lhs.originalFilename ?? ""
                let rhsName = rhs.originalFilename ?? ""
                result = lhsName == rhsName
                    ? lhs.id.uuidString < rhs.id.uuidString
                    : lhsName.localizedStandardCompare(rhsName) == .orderedAscending
            case .importedAt:
                result = lhs.importedAt == rhs.importedAt
                    ? lhs.id.uuidString < rhs.id.uuidString
                    : lhs.importedAt < rhs.importedAt
            }
            return result
        }
        return ascending ? values : Array(values.reversed())
    }

    public func occurrenceCount(of assetID: UUID, in albumID: UUID) async throws -> Int {
        let album = try await album(id: albumID)
        return DomainValidator.occurrenceCount(of: assetID, in: album)
    }

    public func sessionState(for albumID: UUID) -> AlbumSessionState {
        AlbumSessionState(
            canUndo: !(undoStacks[albumID] ?? []).isEmpty,
            canRedo: !(redoStacks[albumID] ?? []).isEmpty,
            hasCompatibleClipboard: clipboard?.sourceAlbumID == albumID
        )
    }

    public func canUndo(albumID: UUID) -> Bool { !(undoStacks[albumID] ?? []).isEmpty }
    public func canRedo(albumID: UUID) -> Bool { !(redoStacks[albumID] ?? []).isEmpty }
    public func canUndoLibrary() -> Bool { !libraryUndoStack.isEmpty }
    public func canRedoLibrary() -> Bool { !libraryRedoStack.isEmpty }
    public func clipboardPayload() -> ElementClipboardPayload? { clipboard }

    public func catalogBlob(
        for reference: CatalogResourceReference
    ) async throws -> AssetBlobIndexEntry {
        try DomainValidator.validate(reference)
        guard let descriptor = BuiltInCatalogRegistry.descriptor(
            id: reference.catalogID,
            version: reference.catalogVersion
        ), case let .asset(expectedHash, expectedMIMEType, expectedByteCount) = descriptor.payload,
              let entry = try await repository.load().blobIndex.first(where: {
                  $0.contentHash == expectedHash
              }),
              entry.byteCount == expectedByteCount,
              entry.detectedContentType.lowercased() == expectedMIMEType.lowercased(),
              entry.state == .available else {
            throw DomainValidationError.invalidCatalogReference(reference.catalogID)
        }
        return entry
    }

    // MARK: Album lifecycle

    /// Registers already verified content-addressed catalog blobs in one local
    /// transaction. Repeating `commandID` returns the same indexed entries.
    @discardableResult
    public func registerCatalogBlobs(
        _ entries: [AssetBlobIndexEntry],
        commandID: UUID = UUID()
    ) async throws -> [AssetBlobIndexEntry] {
        guard !entries.isEmpty else { return [] }
        guard Set(entries.map(\.contentHash)).count == entries.count else {
            throw DomainValidationError.duplicateIdentifier("blob catalogue")
        }
        for entry in entries { try validateCatalogBlobEntry(entry) }

        return try await serialisedDurableMutation {
            var state = try await repository.load()
            if state.appliedCommandIDs.contains(commandID) {
                let indexed = entries.compactMap { requested in
                    state.blobIndex.first { $0.contentHash == requested.contentHash }
                }
                guard indexed.count == entries.count else {
                    throw DomainValidationError.persistenceFailure(
                        "résultat du bootstrap catalogue introuvable"
                    )
                }
                return indexed
            }
            for entry in entries {
                if let existing = state.blobIndex.first(where: {
                    $0.contentHash == entry.contentHash
                }) {
                    guard existing.byteCount == entry.byteCount,
                          existing.detectedContentType.lowercased()
                            == entry.detectedContentType.lowercased() else {
                        throw DomainValidationError.invalidBlobIndex(entry.contentHash)
                    }
                } else {
                    state.blobIndex.append(entry)
                }
            }
            recomputeBlobReferenceCounts(in: &state)
            try await commit(&state, commandID: commandID)
            return entries.compactMap { requested in
                state.blobIndex.first { $0.contentHash == requested.contentHash }
            }
        }
    }

    @discardableResult
    public func createAlbum(
        named proposedName: String,
        id: UUID = UUID(),
        firstPageID: UUID = UUID(),
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        let name = try DomainValidator.trimmedAlbumName(proposedName)
        return try await serialisedDurableMutation {
            var state = try await repository.load()
            if state.appliedCommandIDs.contains(commandID) {
                guard let existing = state.album(id: id) else {
                    throw DomainValidationError.persistenceFailure(
                        "commande déjà appliquée sans album cible"
                    )
                }
                return existing
            }
            let album = AlbumSnapshot(
                id: id,
                name: name,
                firstPageID: firstPageID,
                createdAt: now
            )
            state.albums.append(album)
            try await commit(&state, commandID: commandID)
            return album
        }
    }

    @discardableResult
    public func renameAlbum(
        _ albumID: UUID,
        to proposedName: String,
        history: AlbumRenameHistory,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        let name = try DomainValidator.trimmedAlbumName(proposedName)
        return try await mutateAlbum(
            albumID,
            label: "Renommer l’album",
            history: history == .editor ? .editor : .library,
            now: now,
            commandID: commandID
        ) { album, _ in album.name = name }
    }

    @discardableResult
    public func moveAlbumToTrash(
        _ albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await serialisedDurableMutation {
            let preflight = try await repository.load()
            if preflight.appliedCommandIDs.contains(commandID) {
                guard let existing = preflight.album(id: albumID) else {
                    throw DomainValidationError.albumNotFound(albumID)
                }
                return existing
            }
            let mutationID = UUID()
            guard await editLeases.beginLibraryMutation(
                albumID: albumID,
                mutationID: mutationID
            ) else {
                throw DomainValidationError.albumLibraryMutationBlocked(albumID)
            }
            do {
                let album = try await performMoveAlbumToTrash(
                    albumID,
                    now: now,
                    commandID: commandID
                )
                await editLeases.completeLibraryMutation(
                    albumID: albumID,
                    mutationID: mutationID
                )
                return album
            } catch {
                await editLeases.cancelLibraryMutation(
                    albumID: albumID,
                    mutationID: mutationID
                )
                throw error
            }
        }
    }

    private func performMoveAlbumToTrash(
        _ albumID: UUID,
        now: Date,
        commandID: UUID
    ) async throws -> AlbumSnapshot {
        var state = try await repository.load()
        if state.appliedCommandIDs.contains(commandID) {
            guard let existing = state.album(id: albumID) else {
                throw DomainValidationError.albumNotFound(albumID)
            }
            return existing
        }
        guard let index = state.albums.firstIndex(where: { $0.id == albumID }) else {
            throw DomainValidationError.albumNotFound(albumID)
        }
        guard !state.albums[index].isTrashed else {
            throw DomainValidationError.albumIsTrashed(albumID)
        }
        state.albums[index].trashedAt = now
        state.albums[index].updatedAt = now
        try await commit(&state, commandID: commandID)
        clearHistories(albumID: albumID)
        return state.albums[index]
    }

    @discardableResult
    public func restoreAlbum(
        _ albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await serialisedDurableMutation {
            try await performRestoreAlbum(albumID, now: now, commandID: commandID)
        }
    }

    private func performRestoreAlbum(
        _ albumID: UUID,
        now: Date,
        commandID: UUID
    ) async throws -> AlbumSnapshot {
        var state = try await repository.load()
        if state.appliedCommandIDs.contains(commandID) {
            guard let existing = state.album(id: albumID) else {
                throw DomainValidationError.albumNotFound(albumID)
            }
            return existing
        }
        guard let index = state.albums.firstIndex(where: { $0.id == albumID }) else {
            throw DomainValidationError.albumNotFound(albumID)
        }
        guard state.albums[index].isTrashed else {
            throw DomainValidationError.albumIsNotTrashed(albumID)
        }
        state.albums[index].trashedAt = nil
        state.albums[index].updatedAt = now
        try await commit(&state, commandID: commandID)
        return state.albums[index]
    }

    public func permanentlyDeleteAlbum(
        _ albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws {
        try await serialisedDurableMutation {
            try await performPermanentAlbumDeletion(
                albumID,
                now: now,
                commandID: commandID
            )
        }
    }

    private func performPermanentAlbumDeletion(
        _ albumID: UUID,
        now: Date,
        commandID: UUID
    ) async throws {
        var state = try await repository.load()
        if state.appliedCommandIDs.contains(commandID)
            || state.albumDeletionTombstones.contains(where: {
                $0.albumID == albumID && $0.deletionCommandID == commandID
            }) {
            return
        }
        guard let album = state.album(id: albumID) else {
            throw DomainValidationError.albumNotFound(albumID)
        }
        guard album.isTrashed else {
            throw DomainValidationError.albumIsNotTrashed(albumID)
        }
        let tombstone = try makeAlbumDeletionTombstone(
            album: album,
            in: state,
            deletedAt: now,
            reason: .userConfirmed,
            commandID: commandID
        )
        state.albumDeletionTombstones.append(tombstone)
        state.albums.removeAll { $0.id == albumID }
        state.photoAssets.removeAll { $0.albumID == albumID }
        recomputeBlobReferenceCounts(in: &state)
        try await commit(&state, commandID: commandID)
        clearHistories(albumID: albumID)
    }

    @discardableResult
    public func purgeExpiredTrashedAlbums(
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> Int {
        try await serialisedDurableMutation {
            try await performPurgeExpiredTrashedAlbums(
                now: now,
                commandID: commandID
            )
        }
    }

    private func performPurgeExpiredTrashedAlbums(
        now: Date,
        commandID: UUID
    ) async throws -> Int {
        var state = try await repository.load()
        let durableReplayCount = state.albumDeletionTombstones.filter {
            $0.deletionCommandID == commandID && $0.reason == .retentionExpired
        }.count
        if durableReplayCount > 0 { return durableReplayCount }
        if state.appliedCommandIDs.contains(commandID) {
            return 0
        }
        let expiredAlbums = state.albums.filter { album in
            guard let trashedAt = album.trashedAt,
                  now.timeIntervalSince(trashedAt) >= AlbumDeletionTombstone.recoveryDuration else {
                return false
            }
            return true
        }.sorted { uuidByteOrder($0.id, $1.id) }
        let expired = Set(expiredAlbums.map(\.id))
        guard !expired.isEmpty else { return 0 }
        for album in expiredAlbums {
            state.albumDeletionTombstones.append(try makeAlbumDeletionTombstone(
                album: album,
                in: state,
                deletedAt: now,
                reason: .retentionExpired,
                commandID: commandID
            ))
        }
        state.albums.removeAll { expired.contains($0.id) }
        state.photoAssets.removeAll { expired.contains($0.albumID) }
        recomputeBlobReferenceCounts(in: &state)
        try await commit(&state, commandID: commandID)
        for id in expired { clearHistories(albumID: id) }
        return expired.count
    }

    /// Evaluates retention unconditionally at launch, then no less often than
    /// every 24 hours while the same service instance remains active. The last
    /// successful evaluation is deliberately session-local: a new launch must
    /// always evaluate again (3:ALB-023, 3:ALB-024).
    @discardableResult
    public func evaluateTrashExpiration(
        trigger: TrashExpirationTrigger,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> TrashExpirationEvaluation {
        try await serialisedDurableMutation {
            if trigger == .applicationActive,
               let previous = lastTrashExpirationEvaluationAt {
                let elapsed = now.timeIntervalSince(previous)
                guard elapsed < 0 || elapsed >= 24 * 60 * 60 else {
                    return TrashExpirationEvaluation(
                        didEvaluate: false,
                        purgedAlbumCount: 0
                    )
                }
            }

            let count = try await performPurgeExpiredTrashedAlbums(
                now: now,
                commandID: commandID
            )
            lastTrashExpirationEvaluationAt = now
            return TrashExpirationEvaluation(
                didEvaluate: true,
                purgedAlbumCount: count
            )
        }
    }

    // MARK: Pages and backgrounds

    @discardableResult
    public func addPage(
        to albumID: UUID,
        after activePageID: UUID,
        pageID: UUID = UUID(),
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(albumID, label: "Ajouter une page", now: now, commandID: commandID) {
            album, _ in
            guard let index = album.pages.firstIndex(where: { $0.id == activePageID }) else {
                throw DomainValidationError.pageNotFound(activePageID)
            }
            album.pages.insert(PageSnapshot(id: pageID), at: index + 1)
        }
    }

    @discardableResult
    public func deletePage(
        from albumID: UUID,
        pageID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(albumID, label: "Supprimer la page", now: now, commandID: commandID) {
            album, _ in
            guard album.pages.count > 1 else {
                throw DomainValidationError.cannotDeleteOnlyPage
            }
            guard let index = album.pages.firstIndex(where: { $0.id == pageID }) else {
                throw DomainValidationError.pageNotFound(pageID)
            }
            album.pages.remove(at: index)
            repairCover(in: &album)
        }
    }

    @discardableResult
    public func reorderPages(
        in albumID: UUID,
        orderedPageIDs: [UUID],
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(albumID, label: "Réorganiser les pages", now: now, commandID: commandID) {
            album, _ in
            guard orderedPageIDs.count == album.pages.count,
                  Set(orderedPageIDs) == Set(album.pages.map(\.id)) else {
                throw DomainValidationError.invalidPageOrder
            }
            let pages = Dictionary(uniqueKeysWithValues: album.pages.map { ($0.id, $0) })
            album.pages = orderedPageIDs.compactMap { pages[$0] }
        }
    }

    @discardableResult
    public func setBackground(
        _ background: BackgroundSelection,
        on pageID: UUID,
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try DomainValidator.validate(background)
        return try await mutateAlbum(albumID, label: "Changer le fond", now: now, commandID: commandID) {
            album, _ in
            let index = try pageIndex(pageID, in: album)
            album.pages[index].background = background
        }
    }

    @discardableResult
    public func applyBackgroundToAllPages(
        _ background: BackgroundSelection,
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try DomainValidator.validate(background)
        return try await mutateAlbum(albumID, label: "Appliquer le fond à toutes les pages", now: now, commandID: commandID) {
            album, _ in
            for index in album.pages.indices { album.pages[index].background = background }
        }
    }

    @discardableResult
    public func setCover(
        _ selection: CoverSelection,
        for albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID(),
        fromLibrary: Bool = false
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(
            albumID,
            label: "Choisir la couverture",
            history: fromLibrary ? .library : .editor,
            now: now,
            commandID: commandID
        ) { album, _ in
            if case let .pagePhoto(pageID, elementID) = selection {
                guard let page = album.page(id: pageID),
                      let frame = page.element(id: elementID)?.photoFrame,
                      frame.content != nil else {
                    throw DomainValidationError.elementNotFound(elementID)
                }
            }
            album.coverSelection = selection
        }
    }

    // MARK: Photo library and frames

    @discardableResult
    public func registerPhoto(
        _ metadata: PhotoAssetMetadata,
        blob: AssetBlobIndexEntry,
        displayDerivativeBlob: AssetBlobIndexEntry? = nil,
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await registerPhotos(
            [PhotoRegistration(
                metadata: metadata,
                blob: blob,
                displayDerivativeBlob: displayDerivativeBlob
            )],
            in: albumID,
            now: now,
            commandID: commandID
        )
    }

    /// 3:APL-002 / 3:PHO-007 / 3:PHO-019 — preserves the selection order of
    /// new content, ignores hashes already owned by this album and creates at
    /// most one undo item.
    @discardableResult
    public func registerPhotos(
        _ registrations: [PhotoRegistration],
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        guard !registrations.isEmpty else { return try await album(id: albumID) }
        for registration in registrations {
            try DomainValidator.validate(registration.metadata)
            try DomainValidator.validate(registration.blob)
            guard registration.metadata.contentHash == registration.blob.contentHash,
                  registration.metadata.byteCount == registration.blob.byteCount,
                  registration.metadata.mimeType.lowercased()
                    == registration.blob.detectedContentType.lowercased() else {
                throw DomainValidationError.invalidPhotoMetadata
            }
            switch (
                registration.metadata.displayDerivative,
                registration.displayDerivativeBlob
            ) {
            case let (.some(derivative), .some(blob)):
                try DomainValidator.validate(blob)
                guard derivative.contentHash == blob.contentHash,
                      derivative.byteCount == blob.byteCount,
                      derivative.mimeType.lowercased()
                        == blob.detectedContentType.lowercased() else {
                    throw DomainValidationError.invalidPhotoMetadata
                }
            case (nil, nil):
                break
            case (.some, nil), (nil, .some):
                throw DomainValidationError.invalidPhotoMetadata
            }
        }
        guard Set(registrations.map { $0.metadata.id }).count == registrations.count else {
            throw DomainValidationError.duplicateIdentifier("import photo")
        }
        return try await mutateAlbum(albumID, label: "Importer des photos", now: now, commandID: commandID) {
            album, state in
            var ownedContentHashes = Set(
                state.photoAssets(in: albumID).map(\.contentHash)
            )
            for registration in registrations {
                let metadata = registration.metadata
                let blob = registration.blob
                guard !state.photoAssets.contains(where: { $0.id == metadata.id }) else {
                    throw DomainValidationError.assetAlreadyBelongsToAlbum(metadata.id)
                }
                guard !ownedContentHashes.contains(metadata.contentHash) else {
                    continue
                }
                guard !album.photoAssetIDs.contains(metadata.id) else {
                    throw DomainValidationError.assetAlreadyBelongsToAlbum(metadata.id)
                }
                album.photoAssetIDs.append(metadata.id)
                state.photoAssets.append(PhotoAssetRecord(albumID: albumID, metadata: metadata))
                ownedContentHashes.insert(metadata.contentHash)
                if let index = state.blobIndex.firstIndex(where: { $0.contentHash == blob.contentHash }) {
                    guard state.blobIndex[index].byteCount == blob.byteCount,
                          state.blobIndex[index].detectedContentType == blob.detectedContentType else {
                        throw DomainValidationError.invalidBlobIndex(blob.contentHash)
                    }
                } else {
                    state.blobIndex.append(blob)
                }
                if let derivativeBlob = registration.displayDerivativeBlob {
                    if let index = state.blobIndex.firstIndex(where: {
                        $0.contentHash == derivativeBlob.contentHash
                    }) {
                        guard state.blobIndex[index].byteCount == derivativeBlob.byteCount,
                              state.blobIndex[index].detectedContentType.lowercased()
                                == derivativeBlob.detectedContentType.lowercased() else {
                            throw DomainValidationError.invalidBlobIndex(
                                derivativeBlob.contentHash
                            )
                        }
                    } else {
                        state.blobIndex.append(derivativeBlob)
                    }
                }
            }
            recomputeBlobReferenceCounts(in: &state)
        }
    }

    @discardableResult
    func reusePhotos(
        assetIDs: [UUID],
        from sourceAlbumID: UUID,
        to targetAlbumID: UUID,
        newAssetIDs: [UUID]? = nil,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> [PhotoAssetMetadata] {
        guard !assetIDs.isEmpty else { return [] }
        guard Set(assetIDs).count == assetIDs.count else {
            throw DomainValidationError.duplicateIdentifier("réutilisation photo")
        }
        let effectiveAssetIDs = newAssetIDs ?? assetIDs.map {
            deterministicReusedAssetID(commandID: commandID, sourceAssetID: $0)
        }
        guard effectiveAssetIDs.count == assetIDs.count,
              Set(effectiveAssetIDs).count == effectiveAssetIDs.count else {
            throw DomainValidationError.invalidPhotoMetadata
        }
        var created: [PhotoAssetMetadata] = []
        _ = try await mutateAlbum(targetAlbumID, label: "Réutiliser des photos", now: now, commandID: commandID) {
            target, state in
            guard sourceAlbumID != targetAlbumID,
                  let source = state.album(id: sourceAlbumID), !source.isTrashed else {
                throw DomainValidationError.albumNotFound(sourceAlbumID)
            }
            let targetHashes = Set(state.photoAssets(in: targetAlbumID).map(\.contentHash))
            for (index, sourceID) in assetIDs.enumerated() {
                guard source.photoAssetIDs.contains(sourceID),
                      let sourceMetadata = state.photoAsset(id: sourceID) else {
                    throw DomainValidationError.assetNotFound(sourceID)
                }
                guard !targetHashes.contains(sourceMetadata.contentHash),
                      !created.contains(where: { $0.contentHash == sourceMetadata.contentHash }) else {
                    throw DomainValidationError.assetAlreadyBelongsToAlbum(sourceID)
                }
                let metadata = sourceMetadata.reused(
                    id: effectiveAssetIDs[index],
                    importedAt: now
                )
                target.photoAssetIDs.append(metadata.id)
                state.photoAssets.append(PhotoAssetRecord(albumID: targetAlbumID, metadata: metadata))
                created.append(metadata)
            }
            recomputeBlobReferenceCounts(in: &state)
        }
        if created.count == effectiveAssetIDs.count { return created }

        // `mutateAlbum` deliberately skips the closure when this command was
        // already committed. Resolve the original result instead of returning
        // an empty or newly generated list on retry (3:LOC-011).
        let state = try await repository.load()
        let records = Dictionary(uniqueKeysWithValues: state.photoAssets
            .filter { $0.albumID == targetAlbumID }
            .map { ($0.id, $0.metadata) })
        let replayed = effectiveAssetIDs.compactMap { records[$0] }
        guard replayed.count == effectiveAssetIDs.count else {
            throw DomainValidationError.persistenceFailure(
                "résultat de réutilisation idempotente introuvable"
            )
        }
        return replayed
    }

    @discardableResult
    public func removePhotoAsset(
        _ assetID: UUID,
        from albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(albumID, label: "Supprimer de cet album", now: now, commandID: commandID) {
            album, state in
            guard album.photoAssetIDs.contains(assetID) else {
                throw DomainValidationError.assetNotFound(assetID)
            }
            let count = DomainValidator.occurrenceCount(of: assetID, in: album)
            guard count == 0 else {
                throw DomainValidationError.assetIsUsed(assetID, count: count)
            }
            album.photoAssetIDs.removeAll { $0 == assetID }
            state.photoAssets.removeAll { $0.id == assetID && $0.albumID == albumID }
            recomputeBlobReferenceCounts(in: &state)
        }
    }

    @discardableResult
    public func addPhotoFrame(
        to pageID: UUID,
        in albumID: UUID,
        assetID: UUID? = nil,
        center: GeometryPoint = GeometryPoint(x: 0.5, y: 0.5),
        elementID: UUID = UUID(),
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(albumID, label: "Ajouter un cadre photo", now: now, commandID: commandID) {
            album, state in
            let index = try pageIndex(pageID, in: album)
            let metadata = assetID.flatMap { state.photoAsset(id: $0) }
            if assetID != nil && metadata == nil { throw DomainValidationError.assetNotFound(assetID!) }
            let geometry: ElementGeometry
            if let metadata {
                geometry = try PhotoCropGeometry.initialFrameGeometry(
                    metadata: metadata,
                    centerX: center.x,
                    centerY: center.y,
                    order: nextOrder(in: album.pages[index])
                )
            } else {
                geometry = ElementGeometry(
                    centerX: min(1, max(0, center.x)),
                    centerY: min(1, max(0, center.y)),
                    order: nextOrder(in: album.pages[index])
                )
            }
            let frame = PhotoFrameElement(
                id: elementID,
                geometry: geometry,
                content: assetID.map { PhotoPlacement(assetID: $0) }
            )
            album.pages[index].elements.append(.photo(frame))
            album.pages[index].accessibilityOrder.append(elementID)
            if album.pages[index].layout.isAutoLayoutEnabled {
                guard assetID != nil else {
                    throw DomainValidationError.invalidLayoutState
                }
                try recomposeAutomaticPage(
                    &album.pages[index],
                    albumID: albumID,
                    state: state
                )
            } else {
                setFreeLayout(&album.pages[index])
            }
        }
    }

    @discardableResult
    public func fillPhotoFrame(
        _ elementID: UUID,
        with assetID: UUID,
        on pageID: UUID,
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(albumID, label: "Remplacer la photo", now: now, commandID: commandID) {
            album, state in
            guard album.photoAssetIDs.contains(assetID), state.photoAsset(id: assetID) != nil else {
                throw DomainValidationError.assetNotFound(assetID)
            }
            let page = try pageIndex(pageID, in: album)
            let element = try elementIndex(elementID, in: album.pages[page])
            guard var frame = album.pages[page].elements[element].photoFrame else {
                throw DomainValidationError.elementNotFound(elementID)
            }
            frame.content = PhotoPlacement(assetID: assetID)
            album.pages[page].elements[element] = .photo(frame)
            if album.pages[page].layout.isAutoLayoutEnabled {
                try recomposeAutomaticPage(
                    &album.pages[page],
                    albumID: albumID,
                    state: state
                )
            }
        }
    }

    @discardableResult
    public func removePhotoFromFrame(
        _ elementID: UUID,
        on pageID: UUID,
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(albumID, label: "Retirer la photo", now: now, commandID: commandID) {
            album, state in
            let page = try pageIndex(pageID, in: album)
            let element = try elementIndex(elementID, in: album.pages[page])
            guard var frame = album.pages[page].elements[element].photoFrame else {
                throw DomainValidationError.elementNotFound(elementID)
            }
            if album.pages[page].layout.isAutoLayoutEnabled {
                album.pages[page].elements.remove(at: element)
                album.pages[page].accessibilityOrder.removeAll { $0 == elementID }
                try recomposeAutomaticPage(
                    &album.pages[page],
                    albumID: albumID,
                    state: state
                )
            } else {
                frame.content = nil
                album.pages[page].elements[element] = .photo(frame)
            }
            repairCover(in: &album)
        }
    }

    // MARK: Layout templates and automatic composition

    @discardableResult
    public func applyLayoutTemplate(
        id templateID: String,
        version templateVersion: Int,
        to pageID: UUID,
        in albumID: UUID,
        confirmsPhotoRemoval: Bool = false,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        guard let template = BuiltInLayoutTemplateCatalog.template(
            id: templateID,
            version: templateVersion
        ), template.isActive else {
            throw DomainValidationError.invalidTemplate(
                "\(templateID)#\(templateVersion)"
            )
        }
        return try await mutateAlbum(
            albumID,
            label: "Appliquer une mise en page",
            now: now,
            commandID: commandID
        ) { album, _ in
            let page = try pageIndex(pageID, in: album)
            album.pages[page] = try LayoutTemplateEngine.apply(
                template,
                to: album.pages[page],
                confirmsPhotoRemoval: confirmsPhotoRemoval
            )
        }
    }

    @discardableResult
    public func setAutomaticLayoutEnabled(
        _ isEnabled: Bool,
        on pageID: UUID,
        in albumID: UUID,
        confirmsReplacement: Bool = false,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(
            albumID,
            label: isEnabled
                ? "Activer la mise en page auto"
                : "Désactiver la mise en page auto",
            now: now,
            commandID: commandID
        ) { album, state in
            let page = try pageIndex(pageID, in: album)
            guard album.pages[page].layout.isAutoLayoutEnabled != isEnabled else {
                return
            }
            if isEnabled {
                let hasPhotoFrames = album.pages[page].elements.contains {
                    $0.photoFrame != nil
                }
                guard !hasPhotoFrames || confirmsReplacement else {
                    throw DomainValidationError.invalidTemplate(
                        "confirmation Auto requise"
                    )
                }
                try recomposeAutomaticPage(
                    &album.pages[page],
                    albumID: albumID,
                    state: state
                )
            } else {
                album.pages[page].layout.isAutoLayoutEnabled = false
            }
        }
    }

    @discardableResult
    public func setAutoLayoutDensity(
        _ density: AutoLayoutDensity,
        on pageID: UUID,
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(
            albumID,
            label: "Changer la densité automatique",
            now: now,
            commandID: commandID
        ) { album, state in
            let page = try pageIndex(pageID, in: album)
            guard album.pages[page].layout.density != density else { return }
            album.pages[page].layout.density = density
            if album.pages[page].layout.isAutoLayoutEnabled {
                try recomposeAutomaticPage(
                    &album.pages[page],
                    albumID: albumID,
                    state: state
                )
            }
        }
    }

    @discardableResult
    public func updatePhotoPlacement(
        _ placement: PhotoPlacement,
        elementID: UUID,
        on pageID: UUID,
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try DomainValidator.validate(placement)
        return try await mutateAlbum(albumID, label: "Recadrer la photo", now: now, commandID: commandID) {
            album, _ in
            let page = try pageIndex(pageID, in: album)
            let element = try elementIndex(elementID, in: album.pages[page])
            guard var frame = album.pages[page].elements[element].photoFrame,
                  frame.content?.assetID == placement.assetID else {
                throw DomainValidationError.elementNotFound(elementID)
            }
            frame.content = placement
            album.pages[page].elements[element] = .photo(frame)
        }
    }

    @discardableResult
    public func rotatePhotoContent(
        elementID: UUID,
        on pageID: UUID,
        in albumID: UUID,
        quarterTurnDelta: Int,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(albumID, label: "Pivoter la photo", now: now, commandID: commandID) {
            album, _ in
            let page = try pageIndex(pageID, in: album)
            let element = try elementIndex(elementID, in: album.pages[page])
            guard var frame = album.pages[page].elements[element].photoFrame,
                  var placement = frame.content else {
                throw DomainValidationError.elementNotFound(elementID)
            }
            placement.quarterTurns = ((placement.quarterTurns + quarterTurnDelta) % 4 + 4) % 4
            frame.content = placement
            album.pages[page].elements[element] = .photo(frame)
        }
    }

    @discardableResult
    public func flipPhotoContent(
        elementID: UUID,
        on pageID: UUID,
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(albumID, label: "Retourner la photo", now: now, commandID: commandID) {
            album, _ in
            let page = try pageIndex(pageID, in: album)
            let element = try elementIndex(elementID, in: album.pages[page])
            guard var frame = album.pages[page].elements[element].photoFrame,
                  var placement = frame.content else {
                throw DomainValidationError.elementNotFound(elementID)
            }
            placement.flippedHorizontally.toggle()
            frame.content = placement
            album.pages[page].elements[element] = .photo(frame)
        }
    }

    // MARK: Elements and clipboard

    @discardableResult
    public func updateElementGeometry(
        _ geometry: ElementGeometry,
        elementID: UUID,
        on pageID: UUID,
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        var normalized = geometry
        normalized.centerX = min(1, max(0, normalized.centerX))
        normalized.centerY = min(1, max(0, normalized.centerY))
        normalized.rotationRadians = try DomainValidator.normalizedRotation(normalized.rotationRadians)
        try DomainValidator.validate(normalized)
        return try await mutateAlbum(albumID, label: "Transformer l’élément", now: now, commandID: commandID) {
            album, _ in
            let page = try pageIndex(pageID, in: album)
            let element = try elementIndex(elementID, in: album.pages[page])
            switch album.pages[page].elements[element] {
            case .photo:
                album.pages[page].elements[element].geometry = normalized
                setFreeLayout(&album.pages[page])
            case var .text(text):
                text.geometry = normalized
                text.sourceTemplateSlotID = nil
                album.pages[page].elements[element] = .text(text)
            case .sticker:
                album.pages[page].elements[element].geometry = normalized
            }
        }
    }

    @discardableResult
    public func moveElementDepth(
        _ move: ElementDepthMove,
        elementID: UUID,
        on pageID: UUID,
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(albumID, label: "Changer la profondeur", now: now, commandID: commandID) {
            album, _ in
            let pageIndexValue = try pageIndex(pageID, in: album)
            var ordered = album.pages[pageIndexValue].elements.sorted(by: PageElement.visualOrder)
            guard let current = ordered.firstIndex(where: { $0.id == elementID }) else {
                throw DomainValidationError.elementNotFound(elementID)
            }
            let destination: Int
            switch move {
            case .front: destination = ordered.count - 1
            case .forward: destination = min(ordered.count - 1, current + 1)
            case .backward: destination = max(0, current - 1)
            case .back: destination = 0
            }
            guard destination != current else { return }
            let element = ordered.remove(at: current)
            ordered.insert(element, at: destination)
            for index in ordered.indices {
                var geometry = ordered[index].geometry
                geometry.order = Int64(index + 1) * AlbumPhotoConstants.elementOrderStep
                ordered[index].geometry = geometry
            }
            album.pages[pageIndexValue].elements = ordered
        }
    }

    @discardableResult
    public func deleteElement(
        _ elementID: UUID,
        on pageID: UUID,
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(albumID, label: "Supprimer l’élément", now: now, commandID: commandID) {
            album, state in
            let page = try pageIndex(pageID, in: album)
            let element = try elementIndex(elementID, in: album.pages[page])
            let removed = album.pages[page].elements[element]
            album.pages[page].elements.remove(at: element)
            album.pages[page].accessibilityOrder.removeAll { $0 == elementID }
            if album.pages[page].layout.isAutoLayoutEnabled,
               removed.photoFrame != nil {
                try recomposeAutomaticPage(
                    &album.pages[page],
                    albumID: albumID,
                    state: state
                )
            } else if !album.pages[page].layout.isAutoLayoutEnabled,
                      removed.photoFrame != nil || removed.textBox != nil {
                setFreeLayout(&album.pages[page])
            }
            repairCover(in: &album)
        }
    }

    @discardableResult
    public func duplicateElement(
        _ elementID: UUID,
        on pageID: UUID,
        in albumID: UUID,
        newElementID: UUID = UUID(),
        offsetNormalized: GeometryPoint = GeometryPoint(
            x: 12 / AlbumPhotoConstants.canonicalPageWidth,
            y: 12 / AlbumPhotoConstants.canonicalPageHeight
        ),
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await mutateAlbum(albumID, label: "Dupliquer l’élément", now: now, commandID: commandID) {
            album, state in
            let page = try pageIndex(pageID, in: album)
            let element = try elementIndex(elementID, in: album.pages[page])
            var copy = album.pages[page].elements[element].replacingID(with: newElementID)
            if album.pages[page].layout.isAutoLayoutEnabled,
               let frame = copy.photoFrame,
               frame.content == nil {
                throw DomainValidationError.invalidLayoutState
            }
            var geometry = copy.geometry
            geometry.centerX = min(1, max(0, geometry.centerX + offsetNormalized.x))
            geometry.centerY = min(1, max(0, geometry.centerY + offsetNormalized.y))
            copy.geometry = geometry
            insertElement(
                copy,
                above: elementID,
                in: &album.pages[page]
            )
            if album.pages[page].layout.isAutoLayoutEnabled,
               copy.photoFrame != nil {
                try recomposeAutomaticPage(
                    &album.pages[page],
                    albumID: albumID,
                    state: state
                )
            } else if copy.photoFrame != nil || copy.textBox != nil,
                      !album.pages[page].layout.isAutoLayoutEnabled {
                setFreeLayout(&album.pages[page])
            }
        }
    }

    public func copyElement(
        _ elementID: UUID,
        on pageID: UUID,
        in albumID: UUID
    ) async throws {
        try await serialisedDurableMutation {
            let state = try await repository.load()
            guard let album = state.album(id: albumID), !album.isTrashed else {
                throw DomainValidationError.albumNotFound(albumID)
            }
            guard let page = album.page(id: pageID),
                  let element = page.element(id: elementID) else {
                throw DomainValidationError.elementNotFound(elementID)
            }
            let metadata = element.photoFrame?.content.flatMap {
                state.photoAsset(id: $0.assetID)
            }
            replaceClipboard(with: ElementClipboardPayload(
                sourceAlbumID: albumID,
                sourcePageID: pageID,
                element: element,
                photoMetadata: metadata
            ))
        }
    }

    @discardableResult
    public func cutElement(
        _ elementID: UUID,
        on pageID: UUID,
        in albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        let initialClipboardMutationVersion = clipboardMutationVersion
        var committedPayload: ElementClipboardPayload?
        let album = try await mutateAlbum(
            albumID,
            label: "Couper l’élément",
            now: now,
            commandID: commandID
        ) {
            album, state in
            let page = try pageIndex(pageID, in: album)
            let element = try elementIndex(elementID, in: album.pages[page])
            let removedElement = album.pages[page].elements[element]
            committedPayload = ElementClipboardPayload(
                sourceAlbumID: albumID,
                sourcePageID: pageID,
                element: removedElement,
                photoMetadata: removedElement.photoFrame?.content.flatMap {
                    state.photoAsset(id: $0.assetID)
                }
            )
            album.pages[page].elements.remove(at: element)
            album.pages[page].accessibilityOrder.removeAll { $0 == elementID }
            if album.pages[page].layout.isAutoLayoutEnabled,
               removedElement.photoFrame != nil {
                try recomposeAutomaticPage(
                    &album.pages[page],
                    albumID: albumID,
                    state: state
                )
            } else if !album.pages[page].layout.isAutoLayoutEnabled,
                      removedElement.photoFrame != nil || removedElement.textBox != nil {
                setFreeLayout(&album.pages[page])
            }
            repairCover(in: &album)
        }
        // `mutateAlbum` returns only after the transaction is durable. A
        // failure therefore leaves the previous clipboard untouched, while a
        // retry of an already-applied command does not try to find the element
        // that was removed by the first invocation (3:CLP-002, 3:ARC-007).
        // If another clipboard operation completed across a repository await,
        // its newer session value wins instead of being overwritten here.
        // The clipboard remains session-local: a service relaunch closes the
        // editing session and intentionally does not reconstruct this payload.
        if let committedPayload,
           clipboardMutationVersion == initialClipboardMutationVersion {
            replaceClipboard(with: committedPayload)
        }
        return album
    }

    @discardableResult
    public func pasteElement(
        on pageID: UUID,
        in albumID: UUID,
        newElementID: UUID = UUID(),
        offsetNormalized: GeometryPoint = GeometryPoint(
            x: 12 / AlbumPhotoConstants.canonicalPageWidth,
            y: 12 / AlbumPhotoConstants.canonicalPageHeight
        ),
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        return try await mutateAlbum(albumID, label: "Coller l’élément", now: now, commandID: commandID) {
            album, state in
            guard let payload = clipboard,
                  payload.version == 1,
                  payload.sourceAlbumID == albumID else {
                throw DomainValidationError.invalidClipboard
            }
            let page = try pageIndex(pageID, in: album)
            var copy = payload.element.replacingID(with: newElementID)
            if album.pages[page].layout.isAutoLayoutEnabled,
               let frame = copy.photoFrame,
               frame.content == nil {
                throw DomainValidationError.invalidLayoutState
            }
            if var frame = copy.photoFrame, let sourcePlacement = frame.content {
                guard let metadata = payload.photoMetadata else {
                    throw DomainValidationError.invalidClipboard
                }
                let targetAssetID = sourcePlacement.assetID
                if !album.photoAssetIDs.contains(targetAssetID) {
                    album.photoAssetIDs.append(targetAssetID)
                    state.photoAssets.append(PhotoAssetRecord(albumID: albumID, metadata: metadata))
                }
                frame.content = PhotoPlacement(
                    assetID: targetAssetID,
                    nativeScale: sourcePlacement.nativeScale,
                    focalX: sourcePlacement.focalX,
                    focalY: sourcePlacement.focalY,
                    quarterTurns: sourcePlacement.quarterTurns,
                    flippedHorizontally: sourcePlacement.flippedHorizontally,
                    accessibilityDescription: sourcePlacement.accessibilityDescription
                )
                copy = .photo(frame)
            }
            var geometry = copy.geometry
            geometry.centerX = min(1, max(0, geometry.centerX + offsetNormalized.x))
            geometry.centerY = min(1, max(0, geometry.centerY + offsetNormalized.y))
            copy.geometry = geometry
            let samePageSource = payload.sourceAlbumID == albumID
                && payload.sourcePageID == pageID
                && album.pages[page].element(id: payload.element.id) != nil
            insertElement(
                copy,
                above: samePageSource ? payload.element.id : nil,
                in: &album.pages[page]
            )
            if album.pages[page].layout.isAutoLayoutEnabled,
               copy.photoFrame != nil {
                try recomposeAutomaticPage(
                    &album.pages[page],
                    albumID: albumID,
                    state: state
                )
            } else if copy.photoFrame != nil || copy.textBox != nil,
                      !album.pages[page].layout.isAutoLayoutEnabled {
                setFreeLayout(&album.pages[page])
            }
            recomputeBlobReferenceCounts(in: &state)
        }
    }

    // MARK: Undo, redo, save

    @discardableResult
    public func undo(
        albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await serialisedDurableMutation {
            let current = try await repository.load()
            if current.appliedCommandIDs.contains(commandID) {
                guard let album = current.album(id: albumID) else {
                    throw DomainValidationError.albumNotFound(albumID)
                }
                return album
            }
            guard var stack = undoStacks[albumID], let record = stack.popLast() else {
                throw DomainValidationError.nothingToUndo
            }
            do {
                let album = try await restoreBundle(
                    record.before,
                    now: now,
                    commandID: commandID
                )
                undoStacks[albumID] = stack
                redoStacks[albumID, default: []].append(record)
                return album
            } catch {
                undoStacks[albumID] = stack + [record]
                throw error
            }
        }
    }

    @discardableResult
    public func redo(
        albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await serialisedDurableMutation {
            let current = try await repository.load()
            if current.appliedCommandIDs.contains(commandID) {
                guard let album = current.album(id: albumID) else {
                    throw DomainValidationError.albumNotFound(albumID)
                }
                return album
            }
            guard var stack = redoStacks[albumID], let record = stack.popLast() else {
                throw DomainValidationError.nothingToRedo
            }
            do {
                let album = try await restoreBundle(
                    record.after,
                    now: now,
                    commandID: commandID
                )
                redoStacks[albumID] = stack
                undoStacks[albumID, default: []].append(record)
                return album
            } catch {
                redoStacks[albumID] = stack + [record]
                throw error
            }
        }
    }

    @discardableResult
    public func undoLibrary(
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await serialisedDurableMutation {
            try await performUndoLibrary(now: now, commandID: commandID)
        }
    }

    private func performUndoLibrary(
        now: Date,
        commandID: UUID
    ) async throws -> AlbumSnapshot {
        let current = try await repository.load()
        if current.appliedCommandIDs.contains(commandID) {
            guard let targetID = libraryReplayAlbumIDs[commandID],
                  let album = current.album(id: targetID) else {
                throw DomainValidationError.persistenceFailure(
                    "résultat d’annulation bibliothèque introuvable"
                )
            }
            return album
        }
        guard let candidate = libraryUndoStack.last else {
            throw DomainValidationError.nothingToUndo
        }
        let albumID = candidate.before.album.id
        let mutationID = UUID()
        guard await editLeases.beginLibraryMutation(
            albumID: albumID,
            mutationID: mutationID
        ) else {
            throw DomainValidationError.albumLibraryMutationBlocked(albumID)
        }
        do {
            guard let record = libraryUndoStack.popLast() else {
                throw DomainValidationError.nothingToUndo
            }
            guard record.id == candidate.id else {
                libraryUndoStack.append(record)
                throw DomainValidationError.persistenceFailure(
                    "pile d’annulation bibliothèque modifiée pendant la transaction"
                )
            }
            do {
                let album = try await restoreBundle(
                    record.before,
                    now: now,
                    commandID: commandID
                )
                libraryRedoStack.append(record)
                libraryReplayAlbumIDs[commandID] = album.id
                await editLeases.completeLibraryMutation(
                    albumID: albumID,
                    mutationID: mutationID
                )
                return album
            } catch {
                libraryUndoStack.append(record)
                throw error
            }
        } catch {
            await editLeases.cancelLibraryMutation(
                albumID: albumID,
                mutationID: mutationID
            )
            throw error
        }
    }

    @discardableResult
    public func redoLibrary(
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> AlbumSnapshot {
        try await serialisedDurableMutation {
            try await performRedoLibrary(now: now, commandID: commandID)
        }
    }

    private func performRedoLibrary(
        now: Date,
        commandID: UUID
    ) async throws -> AlbumSnapshot {
        let current = try await repository.load()
        if current.appliedCommandIDs.contains(commandID) {
            guard let targetID = libraryReplayAlbumIDs[commandID],
                  let album = current.album(id: targetID) else {
                throw DomainValidationError.persistenceFailure(
                    "résultat de rétablissement bibliothèque introuvable"
                )
            }
            return album
        }
        guard let candidate = libraryRedoStack.last else {
            throw DomainValidationError.nothingToRedo
        }
        let albumID = candidate.before.album.id
        let mutationID = UUID()
        guard await editLeases.beginLibraryMutation(
            albumID: albumID,
            mutationID: mutationID
        ) else {
            throw DomainValidationError.albumLibraryMutationBlocked(albumID)
        }
        do {
            guard let record = libraryRedoStack.popLast() else {
                throw DomainValidationError.nothingToRedo
            }
            guard record.id == candidate.id else {
                libraryRedoStack.append(record)
                throw DomainValidationError.persistenceFailure(
                    "pile de rétablissement bibliothèque modifiée pendant la transaction"
                )
            }
            do {
                let album = try await restoreBundle(
                    record.after,
                    now: now,
                    commandID: commandID
                )
                libraryUndoStack.append(record)
                libraryReplayAlbumIDs[commandID] = album.id
                await editLeases.completeLibraryMutation(
                    albumID: albumID,
                    mutationID: mutationID
                )
                return album
            } catch {
                libraryRedoStack.append(record)
                throw error
            }
        } catch {
            await editLeases.cancelLibraryMutation(
                albumID: albumID,
                mutationID: mutationID
            )
            throw error
        }
    }

    public func save() async throws {
        try await serialisedDurableMutation {
            try await repository.flush()
        }
    }

    /// Ends the library-only undo session. The stacks and replay map are
    /// released only after the repository confirms a durable flush
    /// (3:APP-005, 3:UND-012).
    public func closeLibrarySession() async throws {
        try await serialisedDurableMutation {
            try await performCloseLibrarySession()
        }
    }

    private func performCloseLibrarySession() async throws {
        guard await editLeases.beginClosingLibrarySession() else {
            throw DomainValidationError.librarySessionBusy
        }
        let retainedUndo = libraryUndoStack
        let retainedRedo = libraryRedoStack
        let retainedReplay = libraryReplayAlbumIDs
        do {
            try await repository.flush()
            libraryUndoStack.removeAll(keepingCapacity: false)
            libraryRedoStack.removeAll(keepingCapacity: false)
            libraryReplayAlbumIDs.removeAll(keepingCapacity: false)
            var state = try await repository.load()
            let retainedIndex = state.blobIndex
            recomputeBlobReferenceCounts(in: &state)
            if state.blobIndex != retainedIndex {
                try await commit(&state, commandID: UUID())
            }
            await editLeases.completeClosingLibrarySession()
        } catch {
            libraryUndoStack = retainedUndo
            libraryRedoStack = retainedRedo
            libraryReplayAlbumIDs = retainedReplay
            await editLeases.cancelClosingLibrarySession()
            throw error
        }
    }

    @discardableResult
    public func closeEditingSession(albumID: UUID, sceneID: UUID) async throws -> Bool {
        try await serialisedDurableMutation {
            try await performCloseEditingSession(albumID: albumID, sceneID: sceneID)
        }
    }

    private func performCloseEditingSession(
        albumID: UUID,
        sceneID: UUID
    ) async throws -> Bool {
        guard await editLeases.beginClosing(albumID: albumID, sceneID: sceneID) else {
            return false
        }
        do {
            try await repository.flush()
            undoStacks[albumID] = nil
            redoStacks[albumID] = nil
            if clipboard?.sourceAlbumID == albumID { replaceClipboard(with: nil) }
            await editLeases.completeClosing(albumID: albumID, sceneID: sceneID)
            return true
        } catch {
            await editLeases.cancelClosing(albumID: albumID, sceneID: sceneID)
            throw error
        }
    }

    // MARK: Private transaction helpers

    private enum HistoryDestination { case editor, library, none }

    private func serialisedDurableMutation<T: Sendable>(
        _ operation: () async throws -> T
    ) async throws -> T {
        await durableMutationSerialiser.enter()
        do {
            let value = try await operation()
            await durableMutationSerialiser.leave()
            return value
        } catch {
            await durableMutationSerialiser.leave()
            throw error
        }
    }

    private func mutateAlbum(
        _ albumID: UUID,
        label: String,
        history: HistoryDestination = .editor,
        now: Date,
        commandID: UUID,
        mutation: (inout AlbumSnapshot, inout LocalLibrarySnapshot) throws -> Void
    ) async throws -> AlbumSnapshot {
        guard history == .library else {
            return try await serialisedDurableMutation {
                try await performAlbumMutation(
                    albumID,
                    label: label,
                    history: history,
                    now: now,
                    commandID: commandID,
                    mutation: mutation
                )
            }
        }

        return try await serialisedDurableMutation {
            // Idempotent retries resolve before lease arbitration, but inside
            // the same FIFO envelope as the first execution (3:ARC-007).
            let preflight = try await repository.load()
            if preflight.appliedCommandIDs.contains(commandID) {
                guard let album = preflight.album(id: albumID) else {
                    throw DomainValidationError.albumNotFound(albumID)
                }
                return album
            }

            let mutationID = UUID()
            guard await editLeases.beginLibraryMutation(
                albumID: albumID,
                mutationID: mutationID
            ) else {
                throw DomainValidationError.albumLibraryMutationBlocked(albumID)
            }
            do {
                let album = try await performAlbumMutation(
                    albumID,
                    label: label,
                    history: history,
                    now: now,
                    commandID: commandID,
                    mutation: mutation
                )
                await editLeases.completeLibraryMutation(
                    albumID: albumID,
                    mutationID: mutationID
                )
                return album
            } catch {
                await editLeases.cancelLibraryMutation(
                    albumID: albumID,
                    mutationID: mutationID
                )
                throw error
            }
        }
    }

    private func performAlbumMutation(
        _ albumID: UUID,
        label: String,
        history: HistoryDestination,
        now: Date,
        commandID: UUID,
        mutation: (inout AlbumSnapshot, inout LocalLibrarySnapshot) throws -> Void
    ) async throws -> AlbumSnapshot {
        var state = try await repository.load()
        guard let original = state.album(id: albumID) else {
            throw DomainValidationError.albumNotFound(albumID)
        }
        if state.appliedCommandIDs.contains(commandID) { return original }
        guard !original.isTrashed else {
            throw DomainValidationError.albumIsTrashed(albumID)
        }
        let before = bundle(albumID: albumID, in: state)
        var album = original
        try mutation(&album, &state)
        let proposed = AlbumStateBundle(
            album: album,
            assets: state.photoAssets.filter { $0.albumID == albumID }
        )
        // A semantic no-op does not touch updatedAt, revision or either undo
        // stack (3:DAT-002).
        if proposed == before { return original }
        album.updatedAt = now
        guard let albumIndex = state.albums.firstIndex(where: { $0.id == albumID }) else {
            throw DomainValidationError.albumNotFound(albumID)
        }
        state.albums[albumIndex] = album
        recomputeBlobReferenceCounts(
            in: &state,
            additionalRecoverableBundles: history == .none ? [] : [before]
        )
        try await commit(&state, commandID: commandID)
        let after = bundle(albumID: albumID, in: state)
        let record = ReversibleAlbumCommand(
            id: commandID,
            label: label,
            before: before,
            after: after
        )
        switch history {
        case .editor:
            undoStacks[albumID, default: []].append(record)
            redoStacks[albumID] = []
        case .library:
            libraryUndoStack.append(record)
            libraryRedoStack = []
        case .none:
            break
        }
        return album
    }

    private func restoreBundle(
        _ value: AlbumStateBundle,
        now: Date,
        commandID: UUID
    ) async throws -> AlbumSnapshot {
        var state = try await repository.load()
        if state.appliedCommandIDs.contains(commandID) {
            guard let album = state.album(id: value.album.id) else {
                throw DomainValidationError.albumNotFound(value.album.id)
            }
            return album
        }
        guard let index = state.albums.firstIndex(where: { $0.id == value.album.id }) else {
            throw DomainValidationError.albumNotFound(value.album.id)
        }
        var album = value.album
        album.updatedAt = now
        state.albums[index] = album
        state.photoAssets.removeAll { $0.albumID == album.id }
        state.photoAssets.append(contentsOf: value.assets)
        recomputeBlobReferenceCounts(in: &state)
        try await commit(&state, commandID: commandID)
        return album
    }

    private func commit(_ state: inout LocalLibrarySnapshot, commandID: UUID) async throws {
        if state.appliedCommandIDs.contains(commandID) { return }
        let expectedRevision = state.revision
        state.revision += 1
        state.appliedCommandIDs.append(commandID)
        if state.appliedCommandIDs.count > 4_096 {
            state.appliedCommandIDs.removeFirst(state.appliedCommandIDs.count - 4_096)
        }
        try DomainValidator.validate(state)
        try await repository.commit(PersistedTransaction(
            commandID: commandID,
            expectedRevision: expectedRevision,
            resultingSnapshot: state
        ))
    }

    private func bundle(albumID: UUID, in state: LocalLibrarySnapshot) -> AlbumStateBundle {
        AlbumStateBundle(
            album: state.album(id: albumID)!,
            assets: state.photoAssets.filter { $0.albumID == albumID }
        )
    }

    private func replaceClipboard(with value: ElementClipboardPayload?) {
        clipboardMutationVersion &+= 1
        clipboard = value
    }

    /// Rebuilds the persisted safety ledger from active metadata plus every
    /// recoverable in-memory command/clipboard reference known to this service.
    /// `additionalRecoverableBundles` covers the command being committed before
    /// it is appended to its undo stack (3:DAT-017, 3:LOC-008).
    private func recomputeBlobReferenceCounts(
        in state: inout LocalLibrarySnapshot,
        additionalRecoverableBundles: [AlbumStateBundle] = []
    ) {
        var counts: [String: Int] = [:]
        for asset in state.photoAssets {
            for hash in asset.metadata.durableContentHashes {
                counts[hash, default: 0] += 1
            }
        }

        let editorCommands = undoStacks.values.flatMap { $0 }
            + redoStacks.values.flatMap { $0 }
        let commands = editorCommands + libraryUndoStack + libraryRedoStack
        let recoverableBundles = commands.flatMap { [$0.before, $0.after] }
            + additionalRecoverableBundles
        for bundle in recoverableBundles {
            for asset in bundle.assets {
                for hash in asset.metadata.durableContentHashes {
                    counts[hash, default: 0] += 1
                }
            }
        }
        if let metadata = clipboard?.photoMetadata {
            for hash in metadata.durableContentHashes {
                counts[hash, default: 0] += 1
            }
        }

        // A shipped registry entry is itself a durable reference. Keeping this
        // baseline separate from album occurrences prevents a later album
        // command from making a bootstrapped fallback look purgeable.
        for descriptor in BuiltInCatalogRegistry.entries {
            if case let .asset(contentHash, _, _) = descriptor.payload {
                counts[contentHash, default: 0] += 1
            }
        }
        for index in state.blobIndex.indices {
            state.blobIndex[index].referenceCount = counts[
                state.blobIndex[index].contentHash
            ] ?? 0
            state.blobIndex[index].state = state.blobIndex[index].referenceCount == 0
                ? .orphaned : .available
        }
    }

    private func clearHistories(albumID: UUID) {
        undoStacks[albumID] = nil
        redoStacks[albumID] = nil
        libraryUndoStack.removeAll { $0.before.album.id == albumID }
        libraryRedoStack.removeAll { $0.before.album.id == albumID }
        if clipboard?.sourceAlbumID == albumID { replaceClipboard(with: nil) }
    }
}

// MARK: - Pure private helpers

private func albumRecencyOrder(_ lhs: AlbumSnapshot, _ rhs: AlbumSnapshot) -> Bool {
    guard lhs.updatedAt == rhs.updatedAt else { return lhs.updatedAt > rhs.updatedAt }
    let localizedNameOrder = lhs.name.localizedCompare(rhs.name)
    guard localizedNameOrder == .orderedSame else {
        return localizedNameOrder == .orderedAscending
    }
    return uuidByteOrder(lhs.id, rhs.id)
}

private func uuidByteOrder(_ lhs: UUID, _ rhs: UUID) -> Bool {
    let lhsValue = lhs.uuid
    let rhsValue = rhs.uuid
    let lhsBytes = [
        lhsValue.0, lhsValue.1, lhsValue.2, lhsValue.3,
        lhsValue.4, lhsValue.5, lhsValue.6, lhsValue.7,
        lhsValue.8, lhsValue.9, lhsValue.10, lhsValue.11,
        lhsValue.12, lhsValue.13, lhsValue.14, lhsValue.15
    ]
    let rhsBytes = [
        rhsValue.0, rhsValue.1, rhsValue.2, rhsValue.3,
        rhsValue.4, rhsValue.5, rhsValue.6, rhsValue.7,
        rhsValue.8, rhsValue.9, rhsValue.10, rhsValue.11,
        rhsValue.12, rhsValue.13, rhsValue.14, rhsValue.15
    ]
    return lhsBytes.lexicographicallyPrecedes(rhsBytes)
}

private func makeAlbumDeletionTombstone(
    album: AlbumSnapshot,
    in state: LocalLibrarySnapshot,
    deletedAt: Date,
    reason: AlbumDeletionReason,
    commandID: UUID
) throws -> AlbumDeletionTombstone {
    guard let trashedAt = album.trashedAt else {
        throw DomainValidationError.albumIsNotTrashed(album.id)
    }
    let tombstone = AlbumDeletionTombstone(
        albumID: album.id,
        trashedAt: trashedAt,
        deletedAt: deletedAt,
        reason: reason,
        albumLogicalHash: try AlbumLogicalFingerprint.hash(
            album: album,
            photoAssets: state.photoAssets(in: album.id)
        ),
        deletionCommandID: commandID
    )
    try DomainValidator.validate(tombstone)
    return tombstone
}

private func pageIndex(_ pageID: UUID, in album: AlbumSnapshot) throws -> Int {
    guard let index = album.pages.firstIndex(where: { $0.id == pageID }) else {
        throw DomainValidationError.pageNotFound(pageID)
    }
    return index
}

private func elementIndex(_ elementID: UUID, in page: PageSnapshot) throws -> Int {
    guard let index = page.elements.firstIndex(where: { $0.id == elementID }) else {
        throw DomainValidationError.elementNotFound(elementID)
    }
    return index
}

private func nextOrder(in page: PageSnapshot) -> Int64 {
    (page.elements.map { $0.geometry.order }.max() ?? 0) + AlbumPhotoConstants.elementOrderStep
}

private func setFreeLayout(_ page: inout PageSnapshot) {
    page.layout.isAutoLayoutEnabled = false
    page.layout.photoMode = .free
    page.layout.templateID = nil
    page.layout.templateVersion = nil
    for index in page.elements.indices {
        switch page.elements[index] {
        case var .photo(frame):
            frame.sourceTemplateSlotID = nil
            page.elements[index] = .photo(frame)
        case var .text(text):
            text.sourceTemplateSlotID = nil
            page.elements[index] = .text(text)
        case .sticker:
            break
        }
    }
}

private func recomposeAutomaticPage(
    _ page: inout PageSnapshot,
    albumID: UUID,
    state: LocalLibrarySnapshot
) throws {
    let metadataByAssetID = Dictionary(uniqueKeysWithValues: state.photoAssets
        .filter { $0.albumID == albumID }
        .map { ($0.id, $0.metadata) })
    page = try AutoLayoutEngine.recompose(
        page: page,
        metadataByAssetID: metadataByAssetID,
        templates: BuiltInLayoutTemplateCatalog.active
    )
}

private func insertElement(
    _ element: PageElement,
    above sourceElementID: UUID?,
    in page: inout PageSnapshot
) {
    var ordered = page.elements.sorted(by: PageElement.visualOrder)
    let insertionIndex: Int
    if let sourceElementID,
       let sourceIndex = ordered.firstIndex(where: { $0.id == sourceElementID }) {
        insertionIndex = sourceIndex + 1
    } else {
        insertionIndex = ordered.count
    }
    ordered.insert(element, at: insertionIndex)
    for index in ordered.indices {
        var geometry = ordered[index].geometry
        geometry.order = Int64(index + 1) * AlbumPhotoConstants.elementOrderStep
        ordered[index].geometry = geometry
    }
    page.elements = ordered

    if let sourceElementID,
       let sourceIndex = page.accessibilityOrder.firstIndex(of: sourceElementID) {
        page.accessibilityOrder.insert(element.id, at: sourceIndex + 1)
    } else {
        page.accessibilityOrder.append(element.id)
    }
}

private func repairCover(in album: inout AlbumSnapshot) {
    if case .pagePhoto = album.coverSelection,
       album.resolvedCoverOccurrence != album.coverSelection {
        album.coverSelection = .automatic
    }
}

private func validateCatalogBlobEntry(_ entry: AssetBlobIndexEntry) throws {
    try DomainValidator.validate(entry)
    guard let descriptor = BuiltInCatalogRegistry.entries.first(where: {
        if case let .asset(hash, _, _) = $0.payload { return hash == entry.contentHash }
        return false
    }), case let .asset(expectedHash, expectedMIMEType, expectedByteCount) = descriptor.payload,
          entry.contentHash == expectedHash,
          entry.byteCount == expectedByteCount,
          entry.detectedContentType.lowercased() == expectedMIMEType.lowercased(),
          entry.relativePath == "Assets/sha256-\(expectedHash)" else {
        throw DomainValidationError.invalidBlobIndex(entry.contentHash)
    }
}

/// Stable UUID derived from the idempotency key and source identity. This is
/// only used when a caller does not inject destination IDs itself.
private func deterministicReusedAssetID(commandID: UUID, sourceAssetID: UUID) -> UUID {
    let seed = Data((
        commandID.uuidString.lowercased() + ":" + sourceAssetID.uuidString.lowercased()
    ).utf8)
    var bytes = Array(SHA256.digest(seed).prefix(16))
    bytes[6] = (bytes[6] & 0x0f) | 0x50
    bytes[8] = (bytes[8] & 0x3f) | 0x80
    return UUID(uuid: (
        bytes[0], bytes[1], bytes[2], bytes[3],
        bytes[4], bytes[5], bytes[6], bytes[7],
        bytes[8], bytes[9], bytes[10], bytes[11],
        bytes[12], bytes[13], bytes[14], bytes[15]
    ))
}
