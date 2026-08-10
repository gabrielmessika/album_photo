import Foundation

public struct AlbumPhotoStorageRoot: Sendable, Equatable, Hashable {
    public let url: URL

    fileprivate init(url: URL) {
        self.url = url
    }
}

private struct AlbumPhotoStorageMarker: Codable {
    let modelGeneration: String
    let schemaVersion: Int
}

/// Creates the entire generation-3 root off to the side, including its valid
/// empty snapshot, then publishes it with one same-volume rename (3:LOC-029
/// ...3:LOC-031). No sibling other than the exact V1 target/temp name is read.
public enum AlbumPhotoRootInitializer {
    public static let directoryName = "AlbumPhotoCanvasV1"
    private static let markerName = ".album-photo-canvas-v1-ready"
    private static let requiredDirectories = [
        "Database", "Assets", "Thumbnails", "Journal", "Staging",
        "Revisions", "Trash", "Exports", "TemporaryImports"
    ]

    public static func initialize(
        applicationSupportURL: URL,
        fileManager: FileManager = .default,
        faultInjector: any PersistenceFaultInjector = NoPersistenceFaults()
    ) throws -> AlbumPhotoStorageRoot {
        try fileManager.createDirectory(
            at: applicationSupportURL,
            withIntermediateDirectories: true
        )
        let target = applicationSupportURL.appendingPathComponent(
            directoryName,
            isDirectory: true
        )
        if fileManager.fileExists(atPath: target.path) {
            try validatePublishedRoot(target, fileManager: fileManager)
            return AlbumPhotoStorageRoot(url: target)
        }

        let temporary = applicationSupportURL.appendingPathComponent(
            ".\(directoryName)-initializing-\(UUID().uuidString.lowercased())",
            isDirectory: true
        )
        var published = false
        defer {
            if !published, fileManager.fileExists(atPath: temporary.path) {
                try? fileManager.removeItem(at: temporary)
            }
        }
        try fileManager.createDirectory(at: temporary, withIntermediateDirectories: false)
        for name in requiredDirectories {
            try fileManager.createDirectory(
                at: temporary.appendingPathComponent(name, isDirectory: true),
                withIntermediateDirectories: false
            )
        }
        let snapshotURL = temporary.appendingPathComponent("Database/library-v1.json")
        try CanonicalJSON.encode(LocalLibrarySnapshot.empty).write(
            to: snapshotURL,
            options: .atomic
        )
        try CanonicalJSON.encode(AlbumPhotoStorageMarker(
            modelGeneration: AlbumModelVersion.generation,
            schemaVersion: AlbumModelVersion.schemaVersion
        )).write(
            to: temporary.appendingPathComponent(markerName),
            options: .atomic
        )
        try validatePublishedRoot(temporary, fileManager: fileManager)
        try faultInjector.hit(.afterGenerationRootPrepared)
        do {
            try fileManager.moveItem(at: temporary, to: target)
            published = true
        } catch {
            // A concurrent scene/process may have won the atomic rename.
            if fileManager.fileExists(atPath: target.path) {
                try validatePublishedRoot(target, fileManager: fileManager)
                return AlbumPhotoStorageRoot(url: target)
            }
            throw error
        }
        try faultInjector.hit(.afterGenerationRootPublish)
        return AlbumPhotoStorageRoot(url: target)
    }

    public static func validate(_ root: AlbumPhotoStorageRoot) throws {
        try validatePublishedRoot(root.url, fileManager: .default)
    }

    private static func validatePublishedRoot(
        _ root: URL,
        fileManager: FileManager
    ) throws {
        guard fileManager.fileExists(atPath: root.appendingPathComponent(markerName).path) else {
            throw DomainValidationError.persistenceFailure(
                "racine 3.0 incomplète : marqueur absent"
            )
        }
        for name in requiredDirectories where !fileManager.fileExists(
            atPath: root.appendingPathComponent(name, isDirectory: true).path
        ) {
            throw DomainValidationError.persistenceFailure(
                "racine 3.0 incomplète : \(name) absent"
            )
        }
        let marker = try JSONDecoder.albumPhotoDecoder.decode(
            AlbumPhotoStorageMarker.self,
            from: Data(contentsOf: root.appendingPathComponent(markerName))
        )
        guard marker.modelGeneration == AlbumModelVersion.generation,
              marker.schemaVersion == AlbumModelVersion.schemaVersion else {
            throw DomainValidationError.unsupportedGeneration(marker.modelGeneration)
        }
        let snapshot = try JSONDecoder.albumPhotoDecoder.decode(
            LocalLibrarySnapshot.self,
            from: Data(contentsOf: root.appendingPathComponent("Database/library-v1.json"))
        )
        try DomainValidator.validate(snapshot)
    }
}
