import AlbumPhotoCore
import CoreTransferable
import Foundation
import ImageIO
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import UIKit

/// Source unique des ressources appartenant à la cible Swift Package.
/// Les catalogues d’assets sont compilés dans le bundle de module, qui peut
/// être distinct du bundle principal de l’application.
enum AppModuleResources {
    static let bundle = Bundle.module
}

enum ApplePhotoImportError: LocalizedError, Equatable {
    case inaccessibleFile
    case undecodableImage
    case animatedImage
    case unsupportedFormat
    case imageTooLarge
    case invalidDimensions
    case insufficientStorage

    var errorDescription: String? {
        switch self {
        case .inaccessibleFile:
            return "Le fichier sélectionné n’est plus accessible."
        case .undecodableImage:
            return "Cette photo ne peut pas être décodée."
        case .animatedImage:
            return "Seules les photos statiques sont prises en charge."
        case .unsupportedFormat:
            return "Ce format de photo n’est pas pris en charge."
        case .imageTooLarge:
            return "Cette image dépasse la limite de sécurité de 200 mégapixels."
        case .invalidDimensions:
            return "Les dimensions de cette photo sont invalides."
        case .insufficientStorage:
            return "L’espace libre est insuffisant. Libérez de l’espace avant de réessayer l’import."
        }
    }
}

enum BundledCatalogResourceError: LocalizedError {
    case missing(String)

    var errorDescription: String? {
        switch self {
        case let .missing(name):
            return "La ressource intégrée \(name) est absente du bundle."
        }
    }
}

/// Charge les octets source exacts : ils sont validés par taille et SHA-256
/// dans AlbumPhotoCore avant d’être ajoutés à l’index local du catalogue.
@MainActor
enum BundledBackgroundResources {
    private static let resources: [(String, String, String)] = [
        ("album.classicSpiral", "album-classic-spiral-v1", "AlbumClassicSpiralData"),
        ("album.travelKraft", "album-travel-kraft-v1", "AlbumTravelKraftData"),
        ("album.minimalDark", "album-minimal-dark-v1", "AlbumMinimalDarkData")
    ]

    static func bootstrapInputs(
        catalogIDs: Set<String>? = nil,
        bundle: Bundle = AppModuleResources.bundle
    ) -> [CatalogResourceBootstrapInput] {
        resources.compactMap { catalogID, filename, dataAssetName in
            guard catalogIDs?.contains(catalogID) ?? true else { return nil }
            let data: Data?
            if let url = bundle.url(forResource: filename, withExtension: "png") {
                data = try? Data(contentsOf: url, options: [.mappedIfSafe])
            } else if let asset = NSDataAsset(name: dataAssetName, bundle: bundle) {
                data = asset.data
            } else {
                data = nil
            }
            guard let data else { return nil }
            return CatalogResourceBootstrapInput(
                catalogID: catalogID,
                data: data,
                detectedContentType: "image/png"
            )
        }
    }
}

@MainActor
enum AppleFeedback {
    private static let selection = UISelectionFeedbackGenerator()

    static func snapped() {
        selection.selectionChanged()
        selection.prepare()
    }
}

struct PreparedPhotoImport: Sendable {
    let metadata: PhotoAssetMetadata
    let blob: AssetBlobIndexEntry
    let displayDerivativeBlob: AssetBlobIndexEntry?
}

/// Adaptateur Apple unique pour l’inspection ImageIO et le dépôt adressé par
/// contenu. Aucun type UIKit ne traverse cette frontière d’acteur.
actor AppleMediaStore {
    private let blobs: ContentAddressedAssetStore
    private let derivativesDirectoryURL: URL

    init(
        blobs: ContentAddressedAssetStore,
        derivativesDirectoryURL: URL
    ) {
        self.blobs = blobs
        self.derivativesDirectoryURL = derivativesDirectoryURL
    }

    func prepareImport(
        at sourceURL: URL,
        source photoSource: PhotoSource,
        originalFilename: String? = nil
    ) async throws -> PreparedPhotoImport {
        let attributes = try FileManager.default.attributesOfItem(
            atPath: sourceURL.path
        )
        let sourceByteCount = (attributes[.size] as? NSNumber)?.int64Value ?? 0
        try ensureStorageCapacity(forByteCount: sourceByteCount)
        let inspected = try Self.inspect(url: sourceURL)
        let blob = try await blobs.importFile(
            at: sourceURL,
            detectedContentType: inspected.mimeType
        )
        let derivativeResult: (
            metadata: PhotoDisplayDerivative,
            blob: AssetBlobIndexEntry
        )?
        if DomainValidator.isRAWMIMEType(inspected.mimeType) {
            let original = try await blobs.data(for: blob.contentHash)
            let rendered = try Self.makeDisplayPNG(
                from: original,
                maximumPixelSize: 2_048
            )
            let derivativeBlob = try await blobs.store(
                data: rendered.data,
                detectedContentType: "image/png"
            )
            derivativeResult = (
                PhotoDisplayDerivative(
                    contentHash: derivativeBlob.contentHash,
                    pixelWidth: rendered.width,
                    pixelHeight: rendered.height,
                    byteCount: derivativeBlob.byteCount
                ),
                derivativeBlob
            )
        } else {
            derivativeResult = nil
        }
        let metadata = PhotoAssetMetadata(
            contentHash: blob.contentHash,
            mimeType: inspected.mimeType,
            originalFilename: originalFilename ?? sourceURL.lastPathComponent,
            pixelWidth: inspected.orientedWidth,
            pixelHeight: inspected.orientedHeight,
            byteCount: blob.byteCount,
            colorSpaceName: inspected.colorSpaceName,
            isHDR: inspected.isHDR,
            source: photoSource,
            capturedAt: inspected.capturedAt,
            displayDerivative: derivativeResult?.metadata
        )
        try DomainValidator.validate(metadata)

        if let storedURL = await blobs.url(for: blob.contentHash) {
            try? FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: storedURL.path
            )
        }
        if let derivativeResult,
           let storedURL = await blobs.url(for: derivativeResult.blob.contentHash) {
            try? FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: storedURL.path
            )
        }
        // APL-007 : la miniature orientée est un cache régénérable. Pour un
        // RAW, elle est décodée depuis le dérivé PNG immuable de FMT-002.
        _ = try await displayData(
            for: derivativeResult?.blob.contentHash ?? blob.contentHash,
            maximumPixelSize: 2_048
        )
        return PreparedPhotoImport(
            metadata: metadata,
            blob: blob,
            displayDerivativeBlob: derivativeResult?.blob
        )
    }

    func prepareForLaunch() async throws {
        try await blobs.cleanStaging()
        let temporaryDirectory = FileManager.default.temporaryDirectory
        if let entries = try? FileManager.default.contentsOfDirectory(
            at: temporaryDirectory,
            includingPropertiesForKeys: nil
        ) {
            for entry in entries
            where entry.lastPathComponent.hasPrefix(PickedPhotoFile.temporaryPrefix) {
                try? FileManager.default.removeItem(at: entry)
            }
        }
    }

    func ensureStorageCapacity(forByteCount byteCount: Int64) throws {
        guard byteCount >= 0 else { throw ApplePhotoImportError.inaccessibleFile }
        guard let support = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw ApplePhotoImportError.inaccessibleFile
        }
        let values = try support.resourceValues(
            forKeys: [.volumeAvailableCapacityForImportantUsageKey]
        )
        guard let available = values.volumeAvailableCapacityForImportantUsage else {
            throw ApplePhotoImportError.insufficientStorage
        }
        let reserve: Int64 = 512 * 1_024 * 1_024
        let required = byteCount > (Int64.max - reserve) / 2
            ? Int64.max : byteCount * 2 + reserve
        guard available > required else {
            throw ApplePhotoImportError.insufficientStorage
        }
    }

    func data(for contentHash: String) async throws -> Data {
        try await blobs.data(for: contentHash)
    }

    func contains(_ contentHash: String) async -> Bool {
        await blobs.contains(contentHash)
    }

    /// A file merely existing at the content-addressed path is not sufficient
    /// for inter-album reuse. Read through the verifying store and compare the
    /// durable byte count before presenting it as selectable (3:PHO-016).
    func verifyPhysicalBlob(
        contentHash: String,
        expectedByteCount: Int64
    ) async -> Bool {
        do {
            _ = try await blobs.verifyPhysicalBlob(
                contentHash: contentHash,
                expectedByteCount: expectedByteCount
            )
            return true
        } catch {
            return false
        }
    }

    func displayData(
        for contentHash: String,
        maximumPixelSize: Int
    ) async throws -> Data {
        let derivativeURL = derivativesDirectoryURL.appendingPathComponent(
            "\(contentHash)-\(max(64, maximumPixelSize)).png"
        )
        if let cached = try? Data(contentsOf: derivativeURL),
           UIImage(data: cached) != nil {
            return cached
        }
        let original = try await blobs.data(for: contentHash)
        let rendered = try Self.makeDisplayPNG(
            from: original,
            maximumPixelSize: maximumPixelSize
        )
        let data = rendered.data
        do {
            try FileManager.default.createDirectory(
                at: derivativesDirectoryURL,
                withIntermediateDirectories: true
            )
            try data.write(to: derivativeURL, options: .atomic)
            try? FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: derivativeURL.path
            )
        } catch {
            // Les variantes de taille ultérieures restent des caches
            // régénérables et ne rendent pas l’original indisponible.
        }
        return data
    }

    private static func makeDisplayPNG(
        from original: Data,
        maximumPixelSize: Int
    ) throws -> (data: Data, width: Int, height: Int) {
        guard let source = CGImageSourceCreateWithData(
            original as CFData,
            [kCGImageSourceShouldCache: false] as CFDictionary
        ) else {
            throw ApplePhotoImportError.undecodableImage
        }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: max(64, maximumPixelSize),
            kCGImageSourceShouldCacheImmediately: true
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(
            source,
            0,
            options as CFDictionary
        ) else {
            throw ApplePhotoImportError.undecodableImage
        }
        return (
            try colorManagedPNGData(from: image),
            image.width,
            image.height
        )
    }

    private static func colorManagedPNGData(from image: CGImage) throws -> Data {
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            output,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            throw ApplePhotoImportError.undecodableImage
        }
        // ImageIO conserve l’espace colorimétrique du CGImage produit par le
        // décodage et la transformation EXIF publics.
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw ApplePhotoImportError.undecodableImage
        }
        return output as Data
    }

    private struct Inspection {
        let mimeType: String
        let orientedWidth: Int
        let orientedHeight: Int
        let colorSpaceName: String?
        let isHDR: Bool
        let capturedAt: Date?
    }

    private static func inspect(url: URL) throws -> Inspection {
        let declaredType = try? url.resourceValues(
            forKeys: [.contentTypeKey]
        ).contentType
        if declaredType?.conforms(to: .audiovisualContent) == true {
            throw ApplePhotoImportError.animatedImage
        }
        guard FileManager.default.isReadableFile(atPath: url.path),
              let source = CGImageSourceCreateWithURL(
                  url as CFURL,
                  [kCGImageSourceShouldCache: false] as CFDictionary
              ),
              let typeIdentifier = CGImageSourceGetType(source) as String?,
              let type = UTType(typeIdentifier) else {
            throw ApplePhotoImportError.undecodableImage
        }

        let preferredMIMEType = type.preferredMIMEType?.lowercased() ?? ""
        let isDecodableRAW = type.conforms(to: .rawImage)
        let mimeType = isDecodableRAW ? "image/x-raw" : preferredMIMEType
        let acceptedMIMETypes: Set<String> = [
            "image/jpeg", "image/png", "image/heic", "image/heif", "image/tiff"
        ]
        guard type.conforms(to: .image),
              acceptedMIMETypes.contains(mimeType) || isDecodableRAW,
              !mimeType.isEmpty else {
            throw ApplePhotoImportError.unsupportedFormat
        }
        if type.conforms(to: .gif) || CGImageSourceGetCount(source) != 1 {
            throw ApplePhotoImportError.animatedImage
        }

        guard let properties = CGImageSourceCopyPropertiesAtIndex(
            source,
            0,
            nil
        ) as? [CFString: Any],
              let rawWidth = properties[kCGImagePropertyPixelWidth] as? NSNumber,
              let rawHeight = properties[kCGImagePropertyPixelHeight] as? NSNumber else {
            throw ApplePhotoImportError.invalidDimensions
        }
        let width = rawWidth.intValue
        let height = rawHeight.intValue
        guard width > 0, height > 0 else {
            throw ApplePhotoImportError.invalidDimensions
        }
        guard Double(width) * Double(height) <= 200_000_000 else {
            throw ApplePhotoImportError.imageTooLarge
        }

        let orientationValue = (properties[kCGImagePropertyOrientation] as? NSNumber)?.intValue ?? 1
        let swapsAxes = [5, 6, 7, 8].contains(orientationValue)
        let orientedWidth = swapsAxes ? height : width
        let orientedHeight = swapsAxes ? width : height
        let colorSpace = properties[kCGImagePropertyColorModel] as? String
        let capturedAt = captureDate(from: properties)
        let isHDR = CGImageSourceCopyAuxiliaryDataInfoAtIndex(
            source,
            0,
            kCGImageAuxiliaryDataTypeHDRGainMap
        ) != nil
        return Inspection(
            mimeType: mimeType,
            orientedWidth: orientedWidth,
            orientedHeight: orientedHeight,
            colorSpaceName: colorSpace,
            isHDR: isHDR,
            capturedAt: capturedAt
        )
    }

    private static func captureDate(from properties: [CFString: Any]) -> Date? {
        guard let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any],
              let value = exif[kCGImagePropertyExifDateTimeOriginal] as? String else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return formatter.date(from: value)
    }
}

/// `PhotosPickerItem` fournit un fichier temporaire. Il est copié immédiatement
/// afin qu’aucune URL de sécurité éphémère ne devienne une dépendance métier.
struct PickedPhotoFile: Transferable, Sendable {
    static let temporaryPrefix = "album-photo-picker-"

    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .image) { received in
            let destination = FileManager.default.temporaryDirectory
                .appendingPathComponent(
                    "\(temporaryPrefix)\(UUID().uuidString.lowercased())"
                )
            do {
                try FileManager.default.copyItem(at: received.file, to: destination)
                return PickedPhotoFile(url: destination)
            } catch {
                try? FileManager.default.removeItem(at: destination)
                throw error
            }
        }
    }
}

extension UTType {
    static let albumPhotoAsset = UTType(
        exportedAs: "com.albumphoto.canvas.photo-asset"
    )
}

/// Payload local et typé : une chaîne arbitraire déposée depuis une autre app
/// ne peut jamais être interprétée comme l’identifiant d’une photo de l’album.
struct PhotoAssetDragPayload: Codable, Transferable, Sendable {
    let assetID: UUID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .albumPhotoAsset)
    }
}

/// Pont UIKit unifié pour le zoom et le déplacement du viewport. Pan et pinch
/// partagent une origine et peuvent reconnaître simultanément ; aucun des deux
/// ne gagne arbitrairement la séquence à deux doigts (3:ZOM-003...3:ZOM-005).
struct TwoFingerCanvasGestureBridge: UIViewRepresentable {
    var isEnabled: Bool
    var shouldBegin: (CGPoint) -> Bool
    var onBegan: (CGPoint) -> Void
    var onChanged: (CGSize, Double, CGPoint) -> Void
    var onEnded: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            isEnabled: isEnabled,
            shouldBegin: shouldBegin,
            onBegan: onBegan,
            onChanged: onChanged,
            onEnded: onEnded
        )
    }

    func makeUIView(context: Context) -> GestureAttachmentView {
        let view = GestureAttachmentView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.coordinator = context.coordinator
        return view
    }

    func updateUIView(_ view: GestureAttachmentView, context: Context) {
        context.coordinator.isEnabled = isEnabled
        context.coordinator.shouldBegin = shouldBegin
        context.coordinator.onBegan = onBegan
        context.coordinator.onChanged = onChanged
        context.coordinator.onEnded = onEnded
        context.coordinator.panGesture.isEnabled = isEnabled
        context.coordinator.pinchGesture.isEnabled = isEnabled
        view.requestAttachment()
    }

    static func dismantleUIView(
        _ view: GestureAttachmentView,
        coordinator: Coordinator
    ) {
        coordinator.detach()
    }

    final class GestureAttachmentView: UIView {
        weak var coordinator: Coordinator?

        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            requestAttachment()
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            requestAttachment()
        }

        func requestAttachment() {
            guard window != nil else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self, let host = self.superview else { return }
                self.coordinator?.attach(to: host)
            }
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var isEnabled: Bool
        var shouldBegin: (CGPoint) -> Bool
        var onBegan: (CGPoint) -> Void
        var onChanged: (CGSize, Double, CGPoint) -> Void
        var onEnded: () -> Void
        weak var hostView: UIView?
        private var isTransforming = false
        private var anchor = CGPoint.zero
        private var lastTranslation = CGSize.zero
        private var lastMagnification = 1.0

        lazy var panGesture: UIPanGestureRecognizer = {
            let value = UIPanGestureRecognizer(
                target: self,
                action: #selector(handlePan(_:))
            )
            value.minimumNumberOfTouches = 2
            value.maximumNumberOfTouches = 2
            value.cancelsTouchesInView = true
            value.delaysTouchesBegan = false
            value.delaysTouchesEnded = false
            value.delegate = self
            return value
        }()

        lazy var pinchGesture: UIPinchGestureRecognizer = {
            let value = UIPinchGestureRecognizer(
                target: self,
                action: #selector(handlePinch(_:))
            )
            value.cancelsTouchesInView = true
            value.delaysTouchesBegan = false
            value.delaysTouchesEnded = false
            value.delegate = self
            return value
        }()

        init(
            isEnabled: Bool,
            shouldBegin: @escaping (CGPoint) -> Bool,
            onBegan: @escaping (CGPoint) -> Void,
            onChanged: @escaping (CGSize, Double, CGPoint) -> Void,
            onEnded: @escaping () -> Void
        ) {
            self.isEnabled = isEnabled
            self.shouldBegin = shouldBegin
            self.onBegan = onBegan
            self.onChanged = onChanged
            self.onEnded = onEnded
        }

        func attach(to host: UIView) {
            guard hostView !== host else { return }
            detach()
            host.addGestureRecognizer(panGesture)
            host.addGestureRecognizer(pinchGesture)
            hostView = host
        }

        func detach() {
            hostView?.removeGestureRecognizer(panGesture)
            hostView?.removeGestureRecognizer(pinchGesture)
            hostView = nil
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard isEnabled, let hostView else { return false }
            if isTransforming { return true }
            return shouldBegin(gestureRecognizer.location(in: hostView))
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            (gestureRecognizer === panGesture && otherGestureRecognizer === pinchGesture)
                || (gestureRecognizer === pinchGesture && otherGestureRecognizer === panGesture)
        }

        @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
            guard let hostView else { return }
            switch sender.state {
            case .began:
                beginIfNeeded(at: sender.location(in: hostView))
            case .changed:
                let value = sender.translation(in: hostView)
                lastTranslation = CGSize(width: value.x, height: value.y)
                emitChange()
            case .ended, .cancelled, .failed:
                finishIfNeeded()
            default:
                break
            }
        }

        @objc private func handlePinch(_ sender: UIPinchGestureRecognizer) {
            guard let hostView else { return }
            switch sender.state {
            case .began:
                beginIfNeeded(at: sender.location(in: hostView))
            case .changed:
                lastMagnification = Double(sender.scale)
                emitChange()
            case .ended, .cancelled, .failed:
                finishIfNeeded()
            default:
                break
            }
        }

        private func beginIfNeeded(at location: CGPoint) {
            guard !isTransforming else { return }
            isTransforming = true
            anchor = location
            lastTranslation = .zero
            lastMagnification = 1
            onBegan(location)
        }

        private func emitChange() {
            guard isTransforming else { return }
            onChanged(lastTranslation, lastMagnification, anchor)
        }

        private func finishIfNeeded() {
            let panIsActive = panGesture.state == .began || panGesture.state == .changed
            let pinchIsActive = pinchGesture.state == .began || pinchGesture.state == .changed
            guard isTransforming, !panIsActive, !pinchIsActive else { return }
            isTransforming = false
            onEnded()
            lastTranslation = .zero
            lastMagnification = 1
        }
    }
}

@MainActor
final class PhotoImageCache {
    private let cache = NSCache<NSString, UIImage>()
    private let coverCache = NSCache<NSString, UIImage>()
    private let mediaStore: AppleMediaStore

    init(mediaStore: AppleMediaStore) {
        self.mediaStore = mediaStore
        cache.countLimit = 80
        cache.totalCostLimit = 96 * 1_024 * 1_024
        coverCache.countLimit = 100
        coverCache.totalCostLimit = 48 * 1_024 * 1_024
    }

    func cachedImage(
        for metadata: PhotoAssetMetadata,
        maximumPixelSize: Int
    ) -> UIImage? {
        let displayHash = metadata.displayDerivative?.contentHash
            ?? metadata.contentHash
        return cache.object(
            forKey: "\(displayHash)-\(maximumPixelSize)" as NSString
        )
    }

    func image(
        for metadata: PhotoAssetMetadata,
        maximumPixelSize: Int
    ) async -> UIImage? {
        let displayHash = metadata.displayDerivative?.contentHash
            ?? metadata.contentHash
        let key = "\(displayHash)-\(maximumPixelSize)" as NSString
        if let value = cachedImage(
            for: metadata,
            maximumPixelSize: maximumPixelSize
        ) { return value }
        guard let data = try? await mediaStore.displayData(
            for: displayHash,
            maximumPixelSize: maximumPixelSize
        ), let value = UIImage(data: data) else {
            return nil
        }
        cache.setObject(value, forKey: key, cost: data.count)
        return value
    }

    func catalogImage(
        for contentHash: String,
        maximumPixelSize: Int
    ) async -> UIImage? {
        let key = "catalog-\(contentHash)-\(maximumPixelSize)" as NSString
        if let value = cachedCatalogImage(
            for: contentHash,
            maximumPixelSize: maximumPixelSize
        ) { return value }
        guard let data = try? await mediaStore.displayData(
            for: contentHash,
            maximumPixelSize: maximumPixelSize
        ),
              let value = UIImage(data: data) else {
            return nil
        }
        cache.setObject(value, forKey: key, cost: data.count)
        return value
    }

    func cachedCatalogImage(
        for contentHash: String,
        maximumPixelSize: Int
    ) -> UIImage? {
        cache.object(
            forKey: "catalog-\(contentHash)-\(maximumPixelSize)" as NSString
        )
    }

    func coverImage(forKey key: String) -> UIImage? {
        coverCache.object(forKey: key as NSString)
    }

    func storeCoverImage(_ image: UIImage, forKey key: String) {
        let pixels = max(1, Int(image.size.width * image.scale))
            * max(1, Int(image.size.height * image.scale))
        coverCache.setObject(
            image,
            forKey: key as NSString,
            cost: pixels * 4
        )
    }
}

struct StoredPhotoImage: View {
    let metadata: PhotoAssetMetadata
    let cache: PhotoImageCache
    var maximumPixelSize = 1_600

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let resolvedImage = image ?? cache.cachedImage(
                for: metadata,
                maximumPixelSize: maximumPixelSize
            ) {
                Image(uiImage: resolvedImage)
                    .resizable()
                    .interpolation(.high)
            } else {
                ZStack {
                    Color.secondary.opacity(0.12)
                    ProgressView()
                }
            }
        }
        .task(id: "\(metadata.displayDerivative?.contentHash ?? metadata.contentHash)-\(maximumPixelSize)") {
            image = await cache.image(
                for: metadata,
                maximumPixelSize: maximumPixelSize
            )
        }
        .accessibilityHidden(true)
    }
}

/// Rendu des mêmes octets PNG que ceux validés et copiés dans le content
/// store. Les Data Sets sont la source bundle unique du catalogue de fonds.
struct BundledBackgroundImage: View {
    let dataAssetName: String
    let fallbackContentHash: String?
    let cache: PhotoImageCache?
    var maximumPixelSize = 2_048

    @State private var renderedImage: UIImage?
    private static let validatedDataCache = NSCache<NSString, NSData>()

    var body: some View {
        Group {
            if let resolvedImage = renderedImage ?? immediatelyAvailableImage {
                Image(uiImage: resolvedImage)
                    .resizable()
                    .interpolation(.high)
            } else {
                Color.white
            }
        }
        .task(id: "\(dataAssetName)|\(fallbackContentHash ?? "")|\(maximumPixelSize)") {
            renderedImage = nil
            if let fallbackContentHash, let cache,
               let stored = await cache.catalogImage(
                   for: fallbackContentHash,
                   maximumPixelSize: maximumPixelSize
               ) {
                renderedImage = stored
                return
            }
            if let bundled = await Self.validatedBundledImage(
                named: dataAssetName,
                expectedHash: fallbackContentHash,
                maximumPixelSize: maximumPixelSize
            ) {
                renderedImage = bundled
                return
            }

            let defaultTheme = BackgroundCatalog.defaultTheme
            if let defaultHash = defaultTheme.fallbackContentHash,
               defaultHash != fallbackContentHash,
               let cache,
               let storedDefault = await cache.catalogImage(
                   for: defaultHash,
                   maximumPixelSize: maximumPixelSize
               ) {
                renderedImage = storedDefault
                return
            }
            renderedImage = await Self.validatedBundledImage(
                named: "AlbumClassicSpiralData",
                expectedHash: defaultTheme.fallbackContentHash,
                maximumPixelSize: maximumPixelSize
            )
        }
    }

    private var immediatelyAvailableImage: UIImage? {
        if let fallbackContentHash, let cache,
           let stored = cache.cachedCatalogImage(
               for: fallbackContentHash,
               maximumPixelSize: maximumPixelSize
           ) {
            return stored
        }
        let defaultTheme = BackgroundCatalog.defaultTheme
        if let defaultHash = defaultTheme.fallbackContentHash,
           let cache,
           let storedDefault = cache.cachedCatalogImage(
               for: defaultHash,
               maximumPixelSize: maximumPixelSize
           ) {
            return storedDefault
        }
        return nil
    }

    @MainActor
    private static func validatedBundledImage(
        named name: String,
        expectedHash: String?,
        maximumPixelSize: Int
    ) async -> UIImage? {
        guard let expectedHash else { return nil }
        let cacheKey = "\(name)-\(expectedHash)" as NSString
        let data: Data
        if let cached = validatedDataCache.object(forKey: cacheKey) {
            data = cached as Data
        } else {
            guard let asset = NSDataAsset(
                name: name,
                bundle: AppModuleResources.bundle
            ),
              let descriptor = BuiltInCatalogRegistry.entries.first(where: { entry in
                  guard case let .asset(hash, mimeType, byteCount) = entry.payload else {
                      return false
                  }
                  return hash == expectedHash
                      && mimeType == "image/png"
                      && byteCount == Int64(asset.data.count)
              }), case let .asset(hash, _, _) = descriptor.payload else { return nil }
            let candidate = asset.data
            let digest = await Task.detached(priority: .utility) {
                SHA256.hexDigest(candidate)
            }.value
            guard digest == hash else { return nil }
            validatedDataCache.setObject(candidate as NSData, forKey: cacheKey)
            data = candidate
        }
        guard let image = UIImage(data: data) else { return nil }
        let longest = max(image.size.width, image.size.height)
        guard longest > CGFloat(maximumPixelSize) else { return image }
        let ratio = CGFloat(maximumPixelSize) / longest
        return image.preparingThumbnail(of: CGSize(
            width: max(1, image.size.width * ratio),
            height: max(1, image.size.height * ratio)
        ))
    }
}

/// Toutes les références PhotosUI et `fileImporter` restent dans ce fichier
/// adaptateur afin d’éviter les imports UIKit/ImageIO dispersés qui avaient
/// cassé les builds du prototype 2.1.
struct ApplePhotoImportControls: View {
    @ObservedObject var model: EditorViewModel

    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var showsFileImporter = false
    @State private var isLoadingPickerItems = false
    @State private var failedPickerItems: [PhotosPickerItem] = []
    @State private var pickerTransferCompleted = 0
    @State private var pickerTransferTotal = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: nil,
                selectionBehavior: .ordered,
                matching: .images,
                preferredItemEncoding: .current
            ) {
                Label("Photothèque", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .disabled(
                model.isImportTaskRunning || model.importProgress != nil || model.isReadOnly
            )

            Button {
                showsFileImporter = true
            } label: {
                Label("Fichiers", systemImage: "folder")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .disabled(
                model.isImportTaskRunning || model.importProgress != nil || model.isReadOnly
            )

            if isLoadingPickerItems, pickerTransferTotal > 0 {
                ProgressView(
                    value: Double(pickerTransferCompleted),
                    total: Double(pickerTransferTotal)
                ) {
                    Text("Préparation depuis Photothèque")
                } currentValueLabel: {
                    Text("\(pickerTransferCompleted) sur \(pickerTransferTotal)")
                }
                if pickerTransferCompleted < pickerTransferTotal {
                    Label(
                        "Sélection \(pickerTransferCompleted + 1) en cours",
                        systemImage: "arrow.down.circle"
                    )
                    .font(.caption)
                }
            }

            if model.isImportTaskRunning || model.importProgress != nil {
                Button("Annuler l’import", systemImage: "xmark.circle") {
                    model.cancelImportTask()
                }
                .accessibilityHint(
                    "Interrompt l’opération après la copie en cours et nettoie ses fichiers temporaires."
                )
            }

            if !failedPickerItems.isEmpty {
                Button(
                    "Réessayer \(failedPickerItems.count) sélection(s) interrompue(s)",
                    systemImage: "arrow.clockwise"
                ) {
                    let pending = failedPickerItems
                    model.startImportTask { await loadPickerItems(pending) }
                }
                .disabled(model.isImportTaskRunning || model.isReadOnly)
                .accessibilityHint("Réessaie uniquement les éléments qui n’ont pas pu être lus")
            }
        }
        .buttonStyle(.bordered)
        .fileImporter(
            isPresented: $showsFileImporter,
            // APL-002 — le sélecteur système est limité aux images. L’adaptateur
            // conserve néanmoins son inspection défensive des octets reçus.
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            guard case let .success(urls) = result else {
                if case let .failure(error) = result {
                    model.errorMessage = error.localizedDescription
                }
                return
            }
            model.startImportTask {
                await model.importFiles(
                    urls,
                    source: .files,
                    usesSecurityScope: true
                )
            }
        }
        .onChange(of: pickerItems) { _, items in
            guard !items.isEmpty else { return }
            model.startImportTask { await loadPickerItems(items) }
        }
        .onDisappear {
            model.cancelImportTask()
        }
    }

    @MainActor
    private func loadPickerItems(_ items: [PhotosPickerItem]) async {
        isLoadingPickerItems = true
        pickerTransferCompleted = 0
        pickerTransferTotal = items.count
        defer {
            pickerItems = []
            isLoadingPickerItems = false
            pickerTransferCompleted = 0
            pickerTransferTotal = 0
        }
        var failures: [PhotosPickerItem] = []
        await model.importPickedFiles {
            var files: [PickedPhotoFile] = []
            for item in items {
                guard !Task.isCancelled else { break }
                do {
                    guard let file = try await item.loadTransferable(
                        type: PickedPhotoFile.self
                    ) else {
                        failures.append(item)
                        pickerTransferCompleted += 1
                        continue
                    }
                    files.append(file)
                } catch {
                    if !Task.isCancelled { failures.append(item) }
                }
                pickerTransferCompleted += 1
            }
            return files
        }
        failedPickerItems = Task.isCancelled ? [] : failures
        if !Task.isCancelled, !failures.isEmpty {
            model.errorMessage = "\(failures.count) sélection(s) sont interrompues. Utilisez Réessayer pour traiter uniquement ces erreurs."
        }
    }
}
