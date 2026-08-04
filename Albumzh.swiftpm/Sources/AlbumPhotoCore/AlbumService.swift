import Foundation

public enum AlbumValidationError: Error, Equatable {
    case emptyName
    case albumNotFound
    case pageNotFound
    case albumIsTrashed
    case cannotDeleteOnlyPage
    case invalidPageOrder
    case albumIsNotTrashed
}

public struct AlbumService: Sendable {
    private let repository: any AlbumRepository

    public init(repository: any AlbumRepository) {
        self.repository = repository
    }

    public func albums() async throws -> [Album] {
        try await repository.loadAlbums()
            .filter { $0.trashedAt == nil }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    public func trashedAlbums() async throws -> [Album] {
        try await repository.loadAlbums()
            .filter { $0.trashedAt != nil }
            .sorted {
                ($0.trashedAt ?? .distantPast) > ($1.trashedAt ?? .distantPast)
            }
    }

    public func createAlbum(
        named proposedName: String,
        now: Date = Date(),
        id: UUID = UUID(),
        firstPageID: UUID = UUID(),
        commandID: UUID = UUID()
    ) async throws -> Album {
        let name = proposedName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw AlbumValidationError.emptyName
        }

        let album = Album(
            id: id,
            name: name,
            createdAt: now,
            firstPageID: firstPageID
        )
        try await repository.save(album, commandID: commandID)
        return album
    }

    public func addPage(
        to albumID: UUID,
        after activePageID: UUID,
        now: Date = Date(),
        pageID: UUID = UUID(),
        commandID: UUID = UUID()
    ) async throws -> Album {
        let storedAlbums = try await repository.loadAlbums()
        guard var album = storedAlbums.first(where: { $0.id == albumID }) else {
            throw AlbumValidationError.albumNotFound
        }
        guard album.trashedAt == nil else {
            throw AlbumValidationError.albumIsTrashed
        }
        guard let activeIndex = album.pages.firstIndex(
            where: { $0.id == activePageID }
        ) else {
            throw AlbumValidationError.pageNotFound
        }

        album.pages.insert(Page(id: pageID), at: activeIndex + 1)
        album.updatedAt = now
        try await repository.save(album, commandID: commandID)
        return album
    }

    public func deletePage(
        from albumID: UUID,
        pageID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> Album {
        var album = try await editableAlbum(id: albumID)
        guard album.pages.count > 1 else {
            throw AlbumValidationError.cannotDeleteOnlyPage
        }
        guard let index = album.pages.firstIndex(where: { $0.id == pageID }) else {
            throw AlbumValidationError.pageNotFound
        }

        album.pages.remove(at: index)
        album.updatedAt = now
        try await repository.save(album, commandID: commandID)
        return album
    }

    public func reorderPages(
        in albumID: UUID,
        orderedPageIDs: [UUID],
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> Album {
        var album = try await editableAlbum(id: albumID)
        let existingIDs = album.pages.map(\.id)
        guard
            orderedPageIDs.count == existingIDs.count,
            Set(orderedPageIDs) == Set(existingIDs)
        else {
            throw AlbumValidationError.invalidPageOrder
        }

        let pagesByID = Dictionary(uniqueKeysWithValues: album.pages.map { ($0.id, $0) })
        album.pages = orderedPageIDs.compactMap { pagesByID[$0] }
        album.updatedAt = now
        try await repository.save(album, commandID: commandID)
        return album
    }

    public func applyEditorSnapshot(
        _ snapshot: Album,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> Album {
        _ = try await editableAlbum(id: snapshot.id)
        guard !snapshot.pages.isEmpty else {
            throw AlbumValidationError.cannotDeleteOnlyPage
        }
        guard Set(snapshot.pages.map(\.id)).count == snapshot.pages.count else {
            throw AlbumValidationError.invalidPageOrder
        }

        var restored = snapshot
        restored.updatedAt = now
        try await repository.save(restored, commandID: commandID)
        return restored
    }

    public func changeBackground(
        of albumID: UUID,
        to backgroundID: String,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> Album {
        var album = try await editableAlbum(id: albumID)
        album.backgroundID = BackgroundCatalog.theme(id: backgroundID).id
        album.updatedAt = now
        try await repository.save(album, commandID: commandID)
        return album
    }

    public func changeDisplayMode(
        of albumID: UUID,
        to displayMode: DisplayMode,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> Album {
        var album = try await editableAlbum(id: albumID)
        album.preferredDisplayMode = displayMode
        album.updatedAt = now
        try await repository.save(album, commandID: commandID)
        return album
    }

    public func setMedia(assetID: UUID, on pageID: UUID, in albumID: UUID, now: Date = Date(), commandID: UUID = UUID()) async throws -> Album {
        var album = try await editableAlbum(id: albumID)
        guard let index = album.pages.firstIndex(where: { $0.id == pageID }) else { throw AlbumValidationError.pageNotFound }
        album.pages[index].mediaPlacement = MediaPlacement(assetID: assetID)
        album.updatedAt = now
        try await repository.save(album, commandID: commandID)
        return album
    }

    public func removeMedia(from pageID: UUID, in albumID: UUID, now: Date = Date(), commandID: UUID = UUID()) async throws -> Album {
        var album = try await editableAlbum(id: albumID)
        guard let index = album.pages.firstIndex(where: { $0.id == pageID }) else { throw AlbumValidationError.pageNotFound }
        let removed = album.pages[index].mediaPlacement?.assetID
        album.pages[index].mediaPlacement = nil
        if album.coverSelection == .pageMedia(pageID: pageID, assetID: removed ?? UUID()) { album.coverSelection = .automatic }
        album.updatedAt = now
        try await repository.save(album, commandID: commandID)
        return album
    }

    public func changeCover(of albumID: UUID, to selection: CoverSelection, now: Date = Date(), commandID: UUID = UUID()) async throws -> Album {
        var album = try await editableAlbum(id: albumID)
        if case let .pageMedia(pageID, assetID) = selection {
            guard album.pages.contains(where: { $0.id == pageID && $0.mediaPlacement?.assetID == assetID }) else { throw AlbumValidationError.pageNotFound }
        }
        album.coverSelection = selection
        album.updatedAt = now
        try await repository.save(album, commandID: commandID)
        return album
    }

    public func renameAlbum(
        _ albumID: UUID,
        to proposedName: String,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> Album {
        let name = proposedName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw AlbumValidationError.emptyName
        }

        var album = try await editableAlbum(id: albumID)
        album.name = name
        album.updatedAt = now
        try await repository.save(album, commandID: commandID)
        return album
    }

    public func moveAlbumToTrash(
        _ albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> Album {
        var album = try await editableAlbum(id: albumID)
        album.trashedAt = now
        album.updatedAt = now
        try await repository.save(album, commandID: commandID)
        return album
    }

    public func restoreAlbum(
        _ albumID: UUID,
        now: Date = Date(),
        commandID: UUID = UUID()
    ) async throws -> Album {
        let storedAlbums = try await repository.loadAlbums()
        guard var album = storedAlbums.first(where: { $0.id == albumID }) else {
            throw AlbumValidationError.albumNotFound
        }
        guard album.trashedAt != nil else {
            return album
        }

        album.trashedAt = nil
        album.updatedAt = now
        try await repository.save(album, commandID: commandID)
        return album
    }

    public func permanentlyDeleteAlbum(_ albumID: UUID) async throws {
        let storedAlbums = try await repository.loadAlbums()
        guard let album = storedAlbums.first(where: { $0.id == albumID }) else {
            throw AlbumValidationError.albumNotFound
        }
        guard album.trashedAt != nil else {
            throw AlbumValidationError.albumIsNotTrashed
        }
        try await repository.deleteAlbum(id: albumID)
    }

    @discardableResult
    public func purgeExpiredTrashedAlbums(now: Date = Date()) async throws -> Int {
        let retention: TimeInterval = 30 * 24 * 60 * 60
        let expired = try await repository.loadAlbums().filter { album in
            guard let trashedAt = album.trashedAt else { return false }
            return now.timeIntervalSince(trashedAt) >= retention
        }
        for album in expired {
            try await repository.deleteAlbum(id: album.id)
        }
        return expired.count
    }

    private func editableAlbum(id albumID: UUID) async throws -> Album {
        let storedAlbums = try await repository.loadAlbums()
        guard let album = storedAlbums.first(where: { $0.id == albumID }) else {
            throw AlbumValidationError.albumNotFound
        }
        guard album.trashedAt == nil else {
            throw AlbumValidationError.albumIsTrashed
        }
        return album
    }
}
