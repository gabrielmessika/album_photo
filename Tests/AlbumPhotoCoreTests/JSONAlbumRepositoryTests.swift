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

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }
}
