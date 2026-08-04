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
        #expect(album.backgroundID == "album.classicSpiral")
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

    @Test("PAG-002 insère une page après la page active")
    func addsPageAfterActivePage() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let firstPageID = UUID()
        let secondPageID = UUID()
        let thirdPageID = UUID()
        let album = try await service.createAlbum(
            named: "Guatemala",
            firstPageID: firstPageID
        )
        let withSecondPage = try await service.addPage(
            to: album.id,
            after: firstPageID,
            pageID: secondPageID
        )

        let withInsertedPage = try await service.addPage(
            to: album.id,
            after: firstPageID,
            pageID: thirdPageID
        )

        #expect(withSecondPage.pages.map(\.id) == [firstPageID, secondPageID])
        #expect(
            withInsertedPage.pages.map(\.id)
                == [firstPageID, thirdPageID, secondPageID]
        )
    }

    @Test("PAG-002 refuse une page active étrangère à l’album")
    func rejectsUnknownActivePage() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let album = try await service.createAlbum(named: "Guatemala")

        await #expect(throws: AlbumValidationError.pageNotFound) {
            try await service.addPage(to: album.id, after: UUID())
        }
    }

    @Test("ALB-007 et ALB-011 renomment avec un nom nettoyé")
    func renamesAlbum() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let album = try await service.createAlbum(named: "Guatemala")

        let renamed = try await service.renameAlbum(
            album.id,
            to: "  Voyage  ",
            now: Date(timeIntervalSince1970: 2_000)
        )

        #expect(renamed.name == "Voyage")
        #expect(renamed.updatedAt == Date(timeIntervalSince1970: 2_000))
        #expect(try await service.albums().map(\.name) == ["Voyage"])
    }

    @Test("ALB-019 interdit de renommer un album dans la corbeille")
    func rejectsRenamingTrashedAlbum() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let album = try await service.createAlbum(named: "Guatemala")
        _ = try await service.moveAlbumToTrash(album.id)

        await #expect(throws: AlbumValidationError.albumIsTrashed) {
            try await service.renameAlbum(album.id, to: "Voyage")
        }
    }

    @Test("ACPT-102 masque puis restaure un album sans perte")
    func trashesAndRestoresAlbum() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let album = try await service.createAlbum(named: "Guatemala")
        let page = album.pages[0]
        let trashedAt = Date(timeIntervalSince1970: 3_000)

        let trashed = try await service.moveAlbumToTrash(
            album.id,
            now: trashedAt
        )

        #expect(trashed.trashedAt == trashedAt)
        #expect(try await service.albums().isEmpty)
        #expect(try await service.trashedAlbums().map(\.id) == [album.id])

        let restored = try await service.restoreAlbum(
            album.id,
            now: Date(timeIntervalSince1970: 4_000)
        )

        #expect(restored.trashedAt == nil)
        #expect(restored.pages == [page])
        #expect(try await service.albums().map(\.id) == [album.id])
        #expect(try await service.trashedAlbums().isEmpty)
    }

    @Test("ALB-018 supprime définitivement uniquement depuis la corbeille")
    func permanentlyDeletesTrashedAlbum() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let active = try await service.createAlbum(named: "Actif")
        let trashed = try await service.createAlbum(named: "À supprimer")
        _ = try await service.moveAlbumToTrash(trashed.id)

        await #expect(throws: AlbumValidationError.albumIsNotTrashed) {
            try await service.permanentlyDeleteAlbum(active.id)
        }
        try await service.permanentlyDeleteAlbum(trashed.id)

        #expect(try await service.albums().map(\.id) == [active.id])
        #expect(try await service.trashedAlbums().isEmpty)
    }

    @Test("ALB-023 et ALB-024 expirent après trente périodes de 24 heures")
    func purgesOnlyExpiredTrashedAlbums() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let now = Date(timeIntervalSince1970: 4_000_000)
        let expired = try await service.createAlbum(named: "Expiré")
        let retained = try await service.createAlbum(named: "Conservé")
        _ = try await service.moveAlbumToTrash(
            expired.id,
            now: now.addingTimeInterval(-(30 * 24 * 60 * 60))
        )
        _ = try await service.moveAlbumToTrash(
            retained.id,
            now: now.addingTimeInterval(-(30 * 24 * 60 * 60) + 1)
        )

        #expect(try await service.purgeExpiredTrashedAlbums(now: now) == 1)
        #expect(try await service.trashedAlbums().map(\.id) == [retained.id])
    }

    @Test("PAG-007 protège la dernière page")
    func refusesToDeleteOnlyPage() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let album = try await service.createAlbum(named: "Guatemala")

        await #expect(throws: AlbumValidationError.cannotDeleteOnlyPage) {
            try await service.deletePage(
                from: album.id,
                pageID: album.pages[0].id
            )
        }
    }

    @Test("PAG-006 et PAG-010 suppriment la page demandée")
    func deletesRequestedPage() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let firstPageID = UUID()
        let secondPageID = UUID()
        let album = try await service.createAlbum(
            named: "Guatemala",
            firstPageID: firstPageID
        )
        _ = try await service.addPage(
            to: album.id,
            after: firstPageID,
            pageID: secondPageID
        )

        let updated = try await service.deletePage(
            from: album.id,
            pageID: firstPageID
        )

        #expect(updated.pages.map(\.id) == [secondPageID])
    }

    @Test("PAG-004 et PAG-005 enregistrent un ordre complet valide")
    func reordersPages() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let firstPageID = UUID()
        let secondPageID = UUID()
        let thirdPageID = UUID()
        let album = try await service.createAlbum(
            named: "Guatemala",
            firstPageID: firstPageID
        )
        _ = try await service.addPage(
            to: album.id,
            after: firstPageID,
            pageID: secondPageID
        )
        _ = try await service.addPage(
            to: album.id,
            after: secondPageID,
            pageID: thirdPageID
        )

        let reordered = try await service.reorderPages(
            in: album.id,
            orderedPageIDs: [thirdPageID, firstPageID, secondPageID]
        )

        #expect(
            reordered.pages.map(\.id)
                == [thirdPageID, firstPageID, secondPageID]
        )
        await #expect(throws: AlbumValidationError.invalidPageOrder) {
            try await service.reorderPages(
                in: album.id,
                orderedPageIDs: [firstPageID]
            )
        }
    }

    @Test("BG-001 à BG-004 fournissent le catalogue normatif")
    func providesBackgroundCatalog() {
        #expect(
            BackgroundCatalog.themes.map(\.id)
                == [
                    "album.classicSpiral",
                    "album.travelKraft",
                    "album.minimalDark"
                ]
        )
        #expect(BackgroundCatalog.themes.map(\.localizedName).count == 3)
        #expect(
            BackgroundCatalog.theme(id: "inconnu").id
                == Album.classicSpiralBackgroundID
        )
    }

    @Test("BG-005 et DSP-002 enregistrent les préférences d’album")
    func changesBackgroundAndDisplayMode() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let album = try await service.createAlbum(named: "Guatemala")

        let themed = try await service.changeBackground(
            of: album.id,
            to: "album.minimalDark"
        )
        let singlePage = try await service.changeDisplayMode(
            of: album.id,
            to: .singlePage
        )

        #expect(themed.backgroundID == "album.minimalDark")
        #expect(singlePage.preferredDisplayMode == .singlePage)
        #expect(try await service.albums().first?.backgroundID == "album.minimalDark")
    }

    @Test("COV-001 à COV-005 suivent une occurrence de média")
    func managesMediaCoverOccurrence() async throws {
        let repository = InMemoryAlbumRepository()
        let service = AlbumService(repository: repository)
        let album = try await service.createAlbum(named: "Guatemala")
        let assetID = UUID()
        let withMedia = try await service.setMedia(assetID: assetID, on: album.pages[0].id, in: album.id)
        #expect(withMedia.resolvedCoverOccurrence == .pageMedia(pageID: album.pages[0].id, assetID: assetID))
        let manual = try await service.changeCover(of: album.id, to: .pageMedia(pageID: album.pages[0].id, assetID: assetID))
        #expect(manual.coverSelection == .pageMedia(pageID: album.pages[0].id, assetID: assetID))
        let removed = try await service.removeMedia(from: album.pages[0].id, in: album.id)
        #expect(removed.coverSelection == .automatic)
        #expect(removed.resolvedCoverOccurrence == nil)
    }
}

private actor InMemoryAlbumRepository: AlbumRepository {
    private var albums: [Album] = []
    private(set) var savedAlbum: Album?

    func loadAlbums() -> [Album] {
        albums
    }

    func save(_ album: Album, commandID: UUID) {
        if let index = albums.firstIndex(where: { $0.id == album.id }) {
            albums[index] = album
        } else {
            albums.append(album)
        }
        savedAlbum = album
    }

    func deleteAlbum(id: UUID) {
        albums.removeAll { $0.id == id }
    }
}
