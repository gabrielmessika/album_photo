import Foundation

public enum DomainValidationError: Error, Sendable, Equatable, CustomStringConvertible {
    case unsupportedGeneration(String)
    case unsupportedSchema(Int)
    case emptyAlbumName
    case albumNotFound(UUID)
    case albumIsTrashed(UUID)
    case albumIsNotTrashed(UUID)
    case pageNotFound(UUID)
    case cannotDeleteOnlyPage
    case invalidPageOrder
    case elementNotFound(UUID)
    case assetNotFound(UUID)
    case assetAlreadyBelongsToAlbum(UUID)
    case assetIsUsed(UUID, count: Int)
    case duplicateIdentifier(String)
    case invalidGeometry
    case invalidPhotoPlacement
    case invalidPhotoMetadata
    case invalidBackground
    case invalidLayoutState
    case invalidTemplate(String)
    case invalidText
    case invalidSticker
    case invalidCatalogReference(String)
    case invalidBlobIndex(String)
    case invalidAlbumDeletionTombstone(UUID)
    case invalidClipboard
    case albumLibraryMutationBlocked(UUID)
    case librarySessionBusy
    case nothingToUndo
    case nothingToRedo
    case staleRevision(expected: UInt64, actual: UInt64)
    case persistenceFailure(String)
    case injectedFailure(String)

    public var description: String {
        switch self {
        case let .unsupportedGeneration(value): "Génération non prise en charge : \(value)"
        case let .unsupportedSchema(value): "Schéma non pris en charge : \(value)"
        case .emptyAlbumName: "Le nom de l’album est obligatoire."
        case let .albumNotFound(id): "Album introuvable : \(id)"
        case let .albumIsTrashed(id): "L’album est dans la corbeille : \(id)"
        case let .albumIsNotTrashed(id): "L’album n’est pas dans la corbeille : \(id)"
        case let .pageNotFound(id): "Page introuvable : \(id)"
        case .cannotDeleteOnlyPage: "La dernière page ne peut pas être supprimée."
        case .invalidPageOrder: "L’ordre des pages est incomplet ou invalide."
        case let .elementNotFound(id): "Élément introuvable : \(id)"
        case let .assetNotFound(id): "Photo introuvable : \(id)"
        case let .assetAlreadyBelongsToAlbum(id): "La photo appartient déjà à l’album : \(id)"
        case let .assetIsUsed(id, count): "La photo \(id) est utilisée \(count) fois."
        case let .duplicateIdentifier(id): "Identifiant dupliqué : \(id)"
        case .invalidGeometry: "Géométrie invalide."
        case .invalidPhotoPlacement: "Cadrage photo invalide."
        case .invalidPhotoMetadata: "Métadonnées photo invalides."
        case .invalidBackground: "Fond invalide."
        case .invalidLayoutState: "État de mise en page invalide."
        case let .invalidTemplate(value): "Modèle invalide : \(value)"
        case .invalidText: "Zone de texte invalide."
        case .invalidSticker: "Sticker invalide."
        case let .invalidCatalogReference(value): "Ressource de catalogue invalide : \(value)"
        case let .invalidBlobIndex(value): "Entrée de dépôt invalide : \(value)"
        case let .invalidAlbumDeletionTombstone(id):
            "Tombstone de suppression d’album invalide : \(id)"
        case .invalidClipboard: "Le presse-papiers ne contient aucun élément compatible."
        case let .albumLibraryMutationBlocked(id):
            "La bibliothèque ne peut pas modifier l’album pendant sa session d’édition : \(id)"
        case .librarySessionBusy:
            "La session bibliothèque termine une opération en cours."
        case .nothingToUndo: "Aucune action à annuler."
        case .nothingToRedo: "Aucune action à rétablir."
        case let .staleRevision(expected, actual): "Révision attendue \(expected), obtenue \(actual)."
        case let .persistenceFailure(value): "Échec de persistance : \(value)"
        case let .injectedFailure(value): "Interruption injectée : \(value)"
        }
    }
}

public enum DomainValidator {
    private static let identifierPattern = try! NSRegularExpression(
        pattern: "^[a-z0-9][a-z0-9._-]{0,63}$"
    )
    private static let catalogIdentifierPattern = try! NSRegularExpression(
        pattern: "^[a-z][A-Za-z0-9._-]{0,63}$"
    )
    private static let sha256Pattern = try! NSRegularExpression(
        pattern: "^[0-9a-f]{64}$"
    )

    /// Stable persisted MIME vocabulary. ImageIO is responsible for proving
    /// that an import is a decodable static image; every RAW subtype is then
    /// normalized to `image/x-raw` so a future camera format does not require
    /// a store migration (3:FMT-001...3:FMT-007, 3:DAT-043).
    public static let acceptedPhotoMIMETypes: Set<String> = [
        "image/jpeg", "image/png", "image/heic", "image/heif", "image/tiff",
        "image/x-raw",
        // Legacy subtype values remain readable for already persisted data.
        "image/x-adobe-dng", "image/x-canon-cr2", "image/x-canon-crw",
        "image/x-epson-erf", "image/x-fuji-raf", "image/x-kodak-dcr",
        "image/x-kodak-k25", "image/x-kodak-kdc", "image/x-minolta-mrw",
        "image/x-nikon-nef", "image/x-olympus-orf",
        "image/x-panasonic-raw", "image/x-panasonic-rw2",
        "image/x-pentax-pef", "image/x-sigma-x3f", "image/x-sony-arw",
        "image/x-sony-sr2", "image/x-sony-srf"
    ]

    private static let rawPhotoMIMETypes: Set<String> = [
        "image/x-raw", "image/x-adobe-dng", "image/x-canon-cr2",
        "image/x-canon-crw", "image/x-epson-erf", "image/x-fuji-raf",
        "image/x-kodak-dcr", "image/x-kodak-k25", "image/x-kodak-kdc",
        "image/x-minolta-mrw", "image/x-nikon-nef", "image/x-olympus-orf",
        "image/x-panasonic-raw", "image/x-panasonic-rw2", "image/x-pentax-pef",
        "image/x-sigma-x3f", "image/x-sony-arw", "image/x-sony-sr2",
        "image/x-sony-srf"
    ]

    public static func isRAWMIMEType(_ value: String) -> Bool {
        rawPhotoMIMETypes.contains(value.lowercased())
    }

    public static func trimmedAlbumName(_ value: String) throws -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw DomainValidationError.emptyAlbumName }
        return trimmed
    }

    public static func validate(_ snapshot: LocalLibrarySnapshot) throws {
        guard snapshot.modelGeneration == AlbumModelVersion.generation else {
            throw DomainValidationError.unsupportedGeneration(snapshot.modelGeneration)
        }
        guard snapshot.schemaVersion == AlbumModelVersion.schemaVersion else {
            throw DomainValidationError.unsupportedSchema(snapshot.schemaVersion)
        }
        try unique(snapshot.albums.map(\.id), label: "album")
        try unique(snapshot.photoAssets.map(\.id), label: "asset")
        try unique(snapshot.blobIndex.map(\.contentHash), label: "blob")
        try unique(snapshot.albumDeletionTombstones.map(\.albumID), label: "tombstone album")
        try unique(snapshot.appliedCommandIDs, label: "commande")

        let liveAlbumIDs = Set(snapshot.albums.map(\.id))
        for tombstone in snapshot.albumDeletionTombstones {
            try validate(tombstone)
            guard !liveAlbumIDs.contains(tombstone.albumID),
                  !snapshot.photoAssets.contains(where: { $0.albumID == tombstone.albumID }) else {
                throw DomainValidationError.invalidAlbumDeletionTombstone(tombstone.albumID)
            }
        }

        let recordsByID = Dictionary(uniqueKeysWithValues: snapshot.photoAssets.map { ($0.id, $0) })
        let blobByHash = Dictionary(uniqueKeysWithValues: snapshot.blobIndex.map { ($0.contentHash, $0) })

        for record in snapshot.photoAssets {
            try validate(record.metadata)
            guard record.albumID == snapshot.albums.first(where: {
                $0.photoAssetIDs.contains(record.id)
            })?.id else {
                throw DomainValidationError.invalidPhotoMetadata
            }
            guard let blob = blobByHash[record.metadata.contentHash],
                  blob.byteCount == record.metadata.byteCount,
                  blob.detectedContentType.lowercased()
                    == record.metadata.mimeType.lowercased() else {
                throw DomainValidationError.invalidBlobIndex(record.metadata.contentHash)
            }
            if let derivative = record.metadata.displayDerivative {
                guard let blob = blobByHash[derivative.contentHash],
                      blob.byteCount == derivative.byteCount,
                      blob.detectedContentType.lowercased()
                        == derivative.mimeType.lowercased() else {
                    throw DomainValidationError.invalidBlobIndex(derivative.contentHash)
                }
            }
        }
        for blob in snapshot.blobIndex { try validate(blob) }

        var allOwnedAssetIDs = Set<UUID>()
        for album in snapshot.albums {
            try validate(album, recordsByID: recordsByID)
            for reference in catalogReferences(in: album) {
                guard let descriptor = BuiltInCatalogRegistry.descriptor(
                    id: reference.catalogID,
                    version: reference.catalogVersion
                ) else {
                    throw DomainValidationError.invalidCatalogReference(reference.catalogID)
                }
                if case let .asset(expectedHash, expectedMIMEType, expectedByteCount)
                    = descriptor.payload {
                    guard let blob = blobByHash[expectedHash],
                          blob.byteCount == expectedByteCount,
                          blob.detectedContentType.lowercased()
                            == expectedMIMEType.lowercased(),
                          blob.state == .available else {
                        throw DomainValidationError.invalidBlobIndex(expectedHash)
                    }
                }
            }
            for id in album.photoAssetIDs {
                guard allOwnedAssetIDs.insert(id).inserted else {
                    throw DomainValidationError.duplicateIdentifier(id.uuidString)
                }
            }
        }
    }

    public static func validate(
        _ album: AlbumSnapshot,
        recordsByID: [UUID: PhotoAssetRecord]
    ) throws {
        guard album.modelGeneration == AlbumModelVersion.generation else {
            throw DomainValidationError.unsupportedGeneration(album.modelGeneration)
        }
        guard album.schemaVersion == AlbumModelVersion.schemaVersion else {
            throw DomainValidationError.unsupportedSchema(album.schemaVersion)
        }
        _ = try trimmedAlbumName(album.name)
        guard !album.pages.isEmpty else { throw DomainValidationError.cannotDeleteOnlyPage }
        try unique(album.pages.map(\.id), label: "page")
        try unique(album.photoAssetIDs, label: "asset album")
        for assetID in album.photoAssetIDs {
            guard let record = recordsByID[assetID], record.albumID == album.id else {
                throw DomainValidationError.assetNotFound(assetID)
            }
        }
        for page in album.pages {
            try validate(page, validAssetIDs: Set(album.photoAssetIDs))
        }
        if case let .pagePhoto(pageID, elementID) = album.coverSelection {
            guard let page = album.pages.first(where: { $0.id == pageID }),
                  let frame = page.element(id: elementID)?.photoFrame,
                  frame.content != nil else {
                throw DomainValidationError.elementNotFound(elementID)
            }
        }
    }

    public static func validate(_ page: PageSnapshot, validAssetIDs: Set<UUID>) throws {
        try validate(page.background)
        try validate(page.layout)
        try unique(page.elements.map(\.id), label: "élément")
        try unique(page.accessibilityOrder, label: "ordre accessibilité")
        guard Set(page.elements.map(\.id)) == Set(page.accessibilityOrder) else {
            throw DomainValidationError.invalidPageOrder
        }
        try unique(page.elements.map { $0.geometry.order }, label: "ordre visuel")
        for element in page.elements {
            try validate(element.geometry)
            switch element {
            case let .photo(frame):
                try validate(frame, validAssetIDs: validAssetIDs)
            case let .text(text):
                try validate(text)
            case let .sticker(sticker):
                try validate(sticker)
            }
        }
        try validateTemplateProvenance(page)
    }

    public static func validate(_ geometry: ElementGeometry) throws {
        guard geometry.centerX.isFinite, geometry.centerY.isFinite,
              geometry.width.isFinite, geometry.height.isFinite,
              geometry.rotationRadians.isFinite,
              (0...1).contains(geometry.centerX),
              (0...1).contains(geometry.centerY),
              geometry.width >= 0.05,
              geometry.height >= 0.05,
              geometry.rotationRadians >= -.pi,
              geometry.rotationRadians < .pi else {
            throw DomainValidationError.invalidGeometry
        }
    }

    public static func normalizedRotation(_ radians: Double) throws -> Double {
        guard radians.isFinite else { throw DomainValidationError.invalidGeometry }
        var result = radians.truncatingRemainder(dividingBy: 2 * .pi)
        if result < -.pi { result += 2 * .pi }
        if result >= .pi { result -= 2 * .pi }
        return result == -0 ? 0 : result
    }

    public static func validate(_ placement: PhotoPlacement) throws {
        guard placement.nativeScale.isFinite,
              placement.nativeScale > 0,
              placement.nativeScale <= AlbumPhotoConstants.maximumNativeScale,
              placement.focalX.isFinite, placement.focalY.isFinite,
              (0...1).contains(placement.focalX),
              (0...1).contains(placement.focalY),
              (0...3).contains(placement.quarterTurns),
              (placement.accessibilityDescription?.count ?? 0) <= 500 else {
            throw DomainValidationError.invalidPhotoPlacement
        }
    }

    public static func validate(_ metadata: PhotoAssetMetadata) throws {
        guard isSHA256(metadata.contentHash),
              acceptedPhotoMIMETypes.contains(metadata.mimeType.lowercased()),
              metadata.pixelWidth > 0, metadata.pixelHeight > 0,
              metadata.byteCount > 0,
              Double(metadata.pixelWidth) * Double(metadata.pixelHeight) <= 200_000_000 else {
            throw DomainValidationError.invalidPhotoMetadata
        }
        if isRAWMIMEType(metadata.mimeType) {
            guard let derivative = metadata.displayDerivative else {
                throw DomainValidationError.invalidPhotoMetadata
            }
            try validate(derivative)
            guard derivative.contentHash != metadata.contentHash else {
                throw DomainValidationError.invalidPhotoMetadata
            }
        } else if metadata.displayDerivative != nil {
            throw DomainValidationError.invalidPhotoMetadata
        }
    }

    public static func validate(_ derivative: PhotoDisplayDerivative) throws {
        guard isSHA256(derivative.contentHash),
              derivative.mimeType.lowercased() == "image/png",
              derivative.pixelWidth > 0,
              derivative.pixelHeight > 0,
              derivative.byteCount > 0,
              Double(derivative.pixelWidth) * Double(derivative.pixelHeight)
                <= 200_000_000 else {
            throw DomainValidationError.invalidPhotoMetadata
        }
    }

    public static func validate(_ tombstone: AlbumDeletionTombstone) throws {
        let trashedReference = tombstone.trashedAt.timeIntervalSinceReferenceDate
        let deletedReference = tombstone.deletedAt.timeIntervalSinceReferenceDate
        let elapsed = tombstone.deletedAt.timeIntervalSince(tombstone.trashedAt)
        guard trashedReference.isFinite,
              deletedReference.isFinite,
              elapsed.isFinite,
              elapsed >= 0,
              isSHA256(tombstone.albumLogicalHash) else {
            throw DomainValidationError.invalidAlbumDeletionTombstone(tombstone.albumID)
        }
        if tombstone.reason == .retentionExpired,
           elapsed < AlbumDeletionTombstone.recoveryDuration {
            throw DomainValidationError.invalidAlbumDeletionTombstone(tombstone.albumID)
        }
    }

    public static func validate(_ frame: PhotoFrameElement, validAssetIDs: Set<UUID>) throws {
        try validate(frame.mask.shape)
        guard BuiltInCatalogRegistry.descriptor(
            id: frame.mask.shape.catalogID,
            version: frame.mask.shape.catalogVersion
        )?.category == .shape else {
            throw DomainValidationError.invalidCatalogReference(frame.mask.shape.catalogID)
        }
        guard frame.border.width.isFinite,
              (0...0.03).contains(frame.border.width) else {
            throw DomainValidationError.invalidGeometry
        }
        try validate(frame.border.color, requiresOpaque: true)
        if let decorativeFrame = frame.decorativeFrame {
            try validate(decorativeFrame)
            guard BuiltInCatalogRegistry.descriptor(
                id: decorativeFrame.catalogID,
                version: decorativeFrame.catalogVersion
            )?.category == .decorativeFrame else {
                throw DomainValidationError.invalidCatalogReference(decorativeFrame.catalogID)
            }
        }
        if let content = frame.content {
            try validate(content)
            guard validAssetIDs.contains(content.assetID) else {
                throw DomainValidationError.assetNotFound(content.assetID)
            }
        }
    }

    public static func validate(_ background: BackgroundSelection) throws {
        switch background {
        case .none:
            return
        case let .solid(color):
            try validate(color, requiresOpaque: true)
        case let .catalog(reference):
            try validate(reference)
            guard BuiltInCatalogRegistry.descriptor(
                id: reference.catalogID,
                version: reference.catalogVersion
            )?.category == .background else {
                throw DomainValidationError.invalidBackground
            }
        }
    }

    public static func validate(_ color: SRGBAColor, requiresOpaque: Bool = false) throws {
        let values = [color.red, color.green, color.blue, color.alpha]
        guard values.allSatisfy({ $0.isFinite && (0...1).contains($0) }),
              !requiresOpaque || color.alpha == 1 else {
            throw DomainValidationError.invalidBackground
        }
    }

    public static func validate(_ layout: PageLayoutState) throws {
        switch layout.photoMode {
        case .template:
            guard layout.templateID != nil, layout.templateVersion != nil,
                  !layout.isAutoLayoutEnabled else {
                throw DomainValidationError.invalidLayoutState
            }
        case .free:
            guard layout.templateID == nil, layout.templateVersion == nil,
                  !layout.isAutoLayoutEnabled else {
                throw DomainValidationError.invalidLayoutState
            }
        case .automatic:
            guard layout.templateID == nil, layout.templateVersion == nil else {
                throw DomainValidationError.invalidLayoutState
            }
        }
        if layout.isAutoLayoutEnabled && layout.photoMode != .automatic {
            throw DomainValidationError.invalidLayoutState
        }
    }

    public static func validate(_ text: TextBoxElement) throws {
        let allowedFontSize = (8.0 / AlbumPhotoConstants.canonicalPageHeight)...(96.0 / AlbumPhotoConstants.canonicalPageHeight)
        guard text.opacity.isFinite, (0.1...1).contains(text.opacity),
              text.content.plainText.count <= 1_000 else {
            throw DomainValidationError.invalidText
        }
        try validate(text.typingDefaults)
        for paragraph in text.content.paragraphs {
            guard paragraph.lineSpacing.isFinite,
                  (0.8...2).contains(paragraph.lineSpacing) else {
                throw DomainValidationError.invalidText
            }
            for run in paragraph.runs {
                guard !run.fontID.isEmpty,
                      run.relativeFontSize.isFinite,
                      allowedFontSize.contains(run.relativeFontSize) else {
                    throw DomainValidationError.invalidText
                }
                try validate(run.color)
            }
        }
    }

    public static func validate(_ style: TextStyleDefaults) throws {
        let allowedFontSize = (8.0 / AlbumPhotoConstants.canonicalPageHeight)...(96.0 / AlbumPhotoConstants.canonicalPageHeight)
        guard !style.fontID.isEmpty,
              style.relativeFontSize.isFinite,
              allowedFontSize.contains(style.relativeFontSize),
              style.lineSpacing.isFinite, (0.8...2).contains(style.lineSpacing) else {
            throw DomainValidationError.invalidText
        }
        try validate(style.color)
    }

    public static func validate(_ sticker: StickerElement) throws {
        try validate(sticker.resource)
        guard BuiltInCatalogRegistry.descriptor(
            id: sticker.resource.catalogID,
            version: sticker.resource.catalogVersion
        )?.category == .sticker,
              sticker.opacity.isFinite, (0.1...1).contains(sticker.opacity) else {
            throw DomainValidationError.invalidSticker
        }
    }

    public static func validate(_ reference: CatalogResourceReference) throws {
        guard isCatalogIdentifier(reference.catalogID), reference.catalogVersion > 0,
              reference.fallbackContentHash == nil || isSHA256(reference.fallbackContentHash!) else {
            throw DomainValidationError.invalidCatalogReference(reference.catalogID)
        }
        guard let descriptor = BuiltInCatalogRegistry.descriptor(
            id: reference.catalogID,
            version: reference.catalogVersion
        ) else {
            throw DomainValidationError.invalidCatalogReference(reference.catalogID)
        }
        switch descriptor.payload {
        case let .asset(contentHash, mimeType, byteCount):
            guard !mimeType.isEmpty, byteCount > 0 else {
                throw DomainValidationError.invalidCatalogReference(reference.catalogID)
            }
            guard reference.fallbackContentHash == contentHash else {
                throw DomainValidationError.invalidCatalogReference(reference.catalogID)
            }
        case .nativeVector:
            guard reference.fallbackContentHash == nil else {
                throw DomainValidationError.invalidCatalogReference(reference.catalogID)
            }
        }
        if descriptor.category == .shape && reference.fallbackContentHash != nil {
            throw DomainValidationError.invalidCatalogReference(reference.catalogID)
        }
    }

    public static func validate(_ blob: AssetBlobIndexEntry) throws {
        guard isSHA256(blob.contentHash),
              !blob.relativePath.isEmpty,
              !blob.relativePath.hasPrefix("/"),
              !blob.relativePath.split(separator: "/").contains(".."),
              blob.byteCount > 0,
              !blob.detectedContentType.isEmpty,
              blob.referenceCount >= 0 else {
            throw DomainValidationError.invalidBlobIndex(blob.contentHash)
        }
    }

    public static func validate(_ template: LayoutTemplateDefinition) throws {
        guard isIdentifier(template.id), template.version > 0,
              !template.localizedNameKey.isEmpty, !template.slots.isEmpty else {
            throw DomainValidationError.invalidTemplate(template.id)
        }
        try unique(template.slots.map(\.id), label: "slot")
        let orders = template.slots.map(\.readingOrder).sorted()
        guard orders == Array(0..<template.slots.count) else {
            throw DomainValidationError.invalidTemplate(template.id)
        }
        for slot in template.slots {
            guard isIdentifier(slot.id) else {
                throw DomainValidationError.invalidTemplate(slot.id)
            }
            let geometry = slot.geometry.elementGeometry(order: 0)
            try validate(geometry)
            switch slot.kind {
            case .photo:
                guard slot.defaultTextStyle == nil else {
                    throw DomainValidationError.invalidTemplate(slot.id)
                }
            case .text:
                guard slot.defaultPhotoStyle == nil else {
                    throw DomainValidationError.invalidTemplate(slot.id)
                }
            }
        }
    }

    public static func occurrenceCount(of assetID: UUID, in album: AlbumSnapshot) -> Int {
        album.pages.reduce(into: 0) { result, page in
            result += page.elements.reduce(into: 0) { count, element in
                if element.photoFrame?.content?.assetID == assetID { count += 1 }
            }
        }
    }

    private static func validateTemplateProvenance(_ page: PageSnapshot) throws {
        let slotIDs = page.elements.compactMap { element -> String? in
            switch element {
            case let .photo(frame): frame.sourceTemplateSlotID
            case let .text(text): text.sourceTemplateSlotID
            case .sticker: nil
            }
        }
        try unique(slotIDs, label: "provenance slot")
        if page.layout.photoMode != .template && !slotIDs.isEmpty {
            throw DomainValidationError.invalidLayoutState
        }
    }

    private static func catalogReferences(
        in album: AlbumSnapshot
    ) -> [CatalogResourceReference] {
        album.pages.flatMap { page -> [CatalogResourceReference] in
            var references: [CatalogResourceReference] = []
            if case let .catalog(reference) = page.background {
                references.append(reference)
            }
            for element in page.elements {
                switch element {
                case let .photo(frame):
                    references.append(frame.mask.shape)
                    if let decorative = frame.decorativeFrame {
                        references.append(decorative)
                    }
                case let .sticker(sticker):
                    references.append(sticker.resource)
                case .text:
                    break
                }
            }
            return references
        }
    }

    private static func isIdentifier(_ value: String) -> Bool {
        identifierPattern.firstMatch(
            in: value,
            range: NSRange(value.startIndex..., in: value)
        ) != nil
    }

    private static func isCatalogIdentifier(_ value: String) -> Bool {
        catalogIdentifierPattern.firstMatch(
            in: value,
            range: NSRange(value.startIndex..., in: value)
        ) != nil
    }

    private static func isSHA256(_ value: String) -> Bool {
        sha256Pattern.firstMatch(
            in: value,
            range: NSRange(value.startIndex..., in: value)
        ) != nil
    }

    private static func unique<T: Hashable>(_ values: [T], label: String) throws {
        guard Set(values).count == values.count else {
            throw DomainValidationError.duplicateIdentifier(label)
        }
    }
}
