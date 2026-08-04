import AlbumPhotoCore
import SwiftUI

@main
struct MyApp: App {
    private let service: AlbumService
    private let assetStore: MediaAssetStore

    init() {
        let applicationSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        let root = applicationSupport.appendingPathComponent(
                "AlbumPhoto",
                isDirectory: true
            )
        let repository = JSONAlbumRepository(directoryURL: root)
        service = AlbumService(repository: repository)
        assetStore = MediaAssetStore(directory: root.appendingPathComponent("assets"))
    }

    var body: some Scene {
        WindowGroup {
            LibraryView(service: service, assetStore: assetStore)
        }
    }
}
