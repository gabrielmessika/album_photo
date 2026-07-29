import Foundation

public enum AlbumValidationError: Error, Equatable {
    case emptyName
    case albumNotFound
    case pageNotFound
    case albumIsTrashed
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
}
