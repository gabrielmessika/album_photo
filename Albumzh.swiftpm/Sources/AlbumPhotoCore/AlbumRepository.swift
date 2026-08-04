import Foundation

public protocol AlbumRepository: Sendable {
    func loadAlbums() async throws -> [Album]
    func save(_ album: Album, commandID: UUID) async throws
    func deleteAlbum(id: UUID) async throws
}

public enum AlbumRepositoryError: Error, Equatable {
    case unsupportedSchema(Int)
}

public actor JSONAlbumRepository: AlbumRepository {
    private struct Store: Codable {
        var schemaVersion: Int
        var albums: [Album]
    }

    private struct JournalEntry: Codable {
        var commandID: UUID
        var album: Album
    }

    private let directoryURL: URL
    private let storeURL: URL
    private let journalURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(directoryURL: URL) {
        self.directoryURL = directoryURL
        self.storeURL = directoryURL.appendingPathComponent("albums.json")
        self.journalURL = directoryURL.appendingPathComponent("journal.json")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func loadAlbums() throws -> [Album] {
        try ensureDirectory()
        var store = try readStore()

        if FileManager.default.fileExists(atPath: journalURL.path) {
            let entry = try decoder.decode(
                JournalEntry.self,
                from: Data(contentsOf: journalURL)
            )
            upsert(entry.album, into: &store.albums)
            try writeStore(store)
            try FileManager.default.removeItem(at: journalURL)
        }

        return store.albums
    }

    public func save(_ album: Album, commandID: UUID) throws {
        try ensureDirectory()

        let entry = JournalEntry(commandID: commandID, album: album)
        try encoder.encode(entry).write(to: journalURL, options: .atomic)

        var store = try readStore()
        upsert(album, into: &store.albums)
        try writeStore(store)
        try FileManager.default.removeItem(at: journalURL)
    }

    public func deleteAlbum(id: UUID) throws {
        try ensureDirectory()
        var store = try readStore()
        store.albums.removeAll { $0.id == id }
        try writeStore(store)
    }

    private func ensureDirectory() throws {
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
    }

    private func readStore() throws -> Store {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return Store(schemaVersion: Album.currentSchemaVersion, albums: [])
        }

        let store = try decoder.decode(Store.self, from: Data(contentsOf: storeURL))
        guard store.schemaVersion == Album.currentSchemaVersion else {
            throw AlbumRepositoryError.unsupportedSchema(store.schemaVersion)
        }
        return store
    }

    private func writeStore(_ store: Store) throws {
        try encoder.encode(store).write(to: storeURL, options: .atomic)
    }

    private func upsert(_ album: Album, into albums: inout [Album]) {
        if let index = albums.firstIndex(where: { $0.id == album.id }) {
            albums[index] = album
        } else {
            albums.append(album)
        }
    }
}
