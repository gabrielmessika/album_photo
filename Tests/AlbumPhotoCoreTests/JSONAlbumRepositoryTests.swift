import Foundation
import Testing
@testable import AlbumPhotoCore

@Suite("ACPT-100 — persistance après relance")
struct JSONAlbumRepositoryTests {
    @Test("APP-005 et LOC-011 conservent une commande validée")
    func persistsAcrossRepositoryInstances() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let firstRepository = JSONAlbumRepository(directoryURL: directory)
        let service = AlbumService(repository: firstRepository)
        let creationDate = Date(timeIntervalSince1970: 1_000)

        let created = try await service.createAlbum(
            named: "Guatemala",
            now: creationDate
        )

        let relaunchedRepository = JSONAlbumRepository(directoryURL: directory)
        let relaunchedService = AlbumService(repository: relaunchedRepository)
        let albums = try await relaunchedService.albums()

        #expect(albums == [created])
    }

    @Test("ACPT-100 retrouve l’album et ses deux pages après relance")
    func persistsAddedPageAcrossRepositoryInstances() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let service = AlbumService(
            repository: JSONAlbumRepository(directoryURL: directory)
        )
        let firstPageID = UUID()
        let secondPageID = UUID()
        let album = try await service.createAlbum(
            named: "Guatemala",
            now: Date(timeIntervalSince1970: 1_000),
            firstPageID: firstPageID
        )

        _ = try await service.addPage(
            to: album.id,
            after: firstPageID,
            now: Date(timeIntervalSince1970: 2_000),
            pageID: secondPageID
        )

        let relaunchedService = AlbumService(
            repository: JSONAlbumRepository(directoryURL: directory)
        )
        let relaunchedAlbum = try #require(
            await relaunchedService.albums().first
        )
        #expect(relaunchedAlbum.name == "Guatemala")
        #expect(relaunchedAlbum.backgroundID == Album.classicSpiralBackgroundID)
        #expect(relaunchedAlbum.pages.map(\.id) == [firstPageID, secondPageID])
    }

    @Test("ACPT-102 conserve la corbeille et la restauration après relance")
    func persistsTrashAndRestoreAcrossRepositoryInstances() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let service = AlbumService(
            repository: JSONAlbumRepository(directoryURL: directory)
        )
        let album = try await service.createAlbum(named: "Guatemala")
        _ = try await service.moveAlbumToTrash(
            album.id,
            now: Date(timeIntervalSince1970: 3_000)
        )

        let afterTrashRelaunch = AlbumService(
            repository: JSONAlbumRepository(directoryURL: directory)
        )
        #expect(try await afterTrashRelaunch.albums().isEmpty)
        #expect(try await afterTrashRelaunch.trashedAlbums().first?.id == album.id)

        _ = try await afterTrashRelaunch.restoreAlbum(album.id)
        let afterRestoreRelaunch = AlbumService(
            repository: JSONAlbumRepository(directoryURL: directory)
        )
        let restored = try #require(await afterRestoreRelaunch.albums().first)
        #expect(restored.id == album.id)
        #expect(restored.pages == album.pages)
        #expect(try await afterRestoreRelaunch.trashedAlbums().isEmpty)
    }

    @Test("ALB-018 conserve la suppression définitive après relance")
    func persistsPermanentDeletionAcrossRelaunch() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let service = AlbumService(
            repository: JSONAlbumRepository(directoryURL: directory)
        )
        let album = try await service.createAlbum(named: "Guatemala")
        _ = try await service.moveAlbumToTrash(album.id)
        try await service.permanentlyDeleteAlbum(album.id)

        let relaunchedService = AlbumService(
            repository: JSONAlbumRepository(directoryURL: directory)
        )
        #expect(try await relaunchedService.albums().isEmpty)
        #expect(try await relaunchedService.trashedAlbums().isEmpty)
    }

    @Test("ACPT-104 réorganise, supprime puis annule les deux actions")
    func persistsPageActionsAndUndoAcrossRelaunch() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let service = AlbumService(
            repository: JSONAlbumRepository(directoryURL: directory)
        )
        let pageIDs = (0..<5).map { _ in UUID() }
        var album = try await service.createAlbum(
            named: "Guatemala",
            firstPageID: pageIDs[0]
        )
        for pageID in pageIDs.dropFirst() {
            album = try await service.addPage(
                to: album.id,
                after: album.pages.last!.id,
                pageID: pageID
            )
        }
        let initialSnapshot = album

        let reordered = try await service.reorderPages(
            in: album.id,
            orderedPageIDs: [
                pageIDs[0],
                pageIDs[4],
                pageIDs[1],
                pageIDs[2],
                pageIDs[3]
            ]
        )
        let deleted = try await service.deletePage(
            from: album.id,
            pageID: pageIDs[4]
        )
        #expect(deleted.pages.map(\.id) == Array(pageIDs.dropLast()))

        let restoredDeletion = try await service.applyEditorSnapshot(reordered)
        #expect(restoredDeletion.pages.map(\.id) == reordered.pages.map(\.id))
        let restoredOrder = try await service.applyEditorSnapshot(initialSnapshot)
        #expect(restoredOrder.pages.map(\.id) == pageIDs)

        let relaunchedService = AlbumService(
            repository: JSONAlbumRepository(directoryURL: directory)
        )
        let relaunched = try #require(await relaunchedService.albums().first)
        #expect(relaunched.pages.map(\.id) == pageIDs)
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }
}
