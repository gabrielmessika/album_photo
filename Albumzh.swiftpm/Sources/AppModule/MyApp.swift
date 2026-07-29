import AlbumPhotoCore
import SwiftUI

@main
struct MyApp: App {
    private let service: AlbumService

    init() {
        let applicationSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        let repository = JSONAlbumRepository(
            directoryURL: applicationSupport.appendingPathComponent(
                "AlbumPhoto",
                isDirectory: true
            )
        )
        service = AlbumService(repository: repository)
    }

    var body: some Scene {
        WindowGroup {
            LibraryView(service: service)
        }
    }
}
