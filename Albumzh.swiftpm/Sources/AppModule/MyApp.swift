import AlbumPhotoCore
import Foundation
import SwiftUI

@main
@MainActor
struct MyApp: App {
    @StateObject private var container = ApplicationContainer()

    var body: some Scene {
        WindowGroup {
            if let model = container.model {
                LibraryView()
                    .environmentObject(model)
            } else {
                ApplicationInitializationFailureView(
                    message: container.failureMessage
                        ?? "Le stockage local de l’application est indisponible."
                )
            }
        }
    }
}

@MainActor
private final class ApplicationContainer: ObservableObject {
    let model: AppModel?
    let failureMessage: String?

    init() {
        do {
            guard let support = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first else {
                throw ApplicationInitializationError.applicationSupportUnavailable
            }
            let storageRoot = try AlbumPhotoRootInitializer.initialize(
                applicationSupportURL: support
            )
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: storageRoot.url.path
            )

            let repository = TransactionalJSONLibraryRepository(
                storageRoot: storageRoot
            )
            let blobs = ContentAddressedAssetStore(storageRoot: storageRoot)
            let service = AlbumApplicationService(repository: repository)
            let mediaStore = AppleMediaStore(
                blobs: blobs,
                derivativesDirectoryURL: storageRoot.url.appendingPathComponent(
                    "Thumbnails",
                    isDirectory: true
                )
            )
            let catalogBootstrap = CatalogResourceBootstrapService(
                assetStore: blobs,
                applicationService: service
            )
            let photoReuseCoordinator = VerifiedPhotoReuseCoordinator(
                assetStore: blobs,
                applicationService: service
            )
            self.model = AppModel(
                service: service,
                mediaStore: mediaStore,
                catalogBootstrap: catalogBootstrap,
                photoReuseCoordinator: photoReuseCoordinator
            )
            self.failureMessage = nil
        } catch {
            self.model = nil
            self.failureMessage = error.localizedDescription
        }
    }
}

private enum ApplicationInitializationError: LocalizedError {
    case applicationSupportUnavailable

    var errorDescription: String? {
        "Le dossier Application Support est indisponible. L’application ne crée aucune donnée temporaire afin de préserver l’intégrité de vos albums."
    }
}

private struct ApplicationInitializationFailureView: View {
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label("Stockage local indisponible", systemImage: "externaldrive.badge.xmark")
        } description: {
            Text(message)
        } actions: {
            Text("Libérez de l’espace ou redémarrez l’appareil, puis relancez l’application.")
                .font(.caption)
        }
        .padding()
    }
}
