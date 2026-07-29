import Foundation
import Testing
@testable import AlbumPhotoCore

@Suite("ACPT-100 — création locale durable")
struct AlbumServiceTests {
    @Test("ALB-011 refuse un nom vide après nettoyage")
    func rejectsBlankName() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)

        await #expect(throws: AlbumValidationError.emptyName) {
            try await service.createAlbum(named: " \n ")
        }
    }

    @Test("ALB-012 autorise deux noms identiques")
    func acceptsDuplicateNames() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)

        _ = try await service.createAlbum(named: "Guatemala")
        _ = try await service.createAlbum(named: "Guatemala")

        #expect(try await service.albums().count == 2)
    }

    @Test("ALB-013 à ALB-016 appliquent les valeurs initiales")
    func createsExpectedInitialAlbum() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let date = Date(timeIntervalSince1970: 1_000)

        let album = try await service.createAlbum(named: "  Guatemala  ", now: date)

        #expect(album.name == "Guatemala")
        #expect(album.pages.count == 1)
        #expect(album.backgroundID == Album.classicSpiralBackgroundID)
        #expect(album.preferredDisplayMode == .doublePage)
        #expect(album.createdAt == date)
        #expect(await repository.savedAlbum?.id == album.id)
    }

    @Test("ALB-003 trie les albums actifs par modification décroissante")
    func sortsActiveAlbums() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        _ = try await service.createAlbum(
            named: "Ancien",
            now: Date(timeIntervalSince1970: 100)
        )
        _ = try await service.createAlbum(
            named: "Récent",
            now: Date(timeIntervalSince1970: 200)
        )

        #expect(try await service.albums().map(\.name) == ["Récent", "Ancien"])
    }
}

private actor InMemoryAlbumRepository: AlbumRepository {
    private var albums: [Album] = []
    private(set) var savedAlbum: Album?

    func loadAlbums() -> [Album] {
        albums
    }

    func save(_ album: Album, commandID: UUID) {
        albums.append(album)
        savedAlbum = album
    }
}
