import Foundation

public enum TemplateApplicationDisposition: Sendable, Equatable {
    case ready
    case requiresPhotoRemovalConfirmation(count: Int)
    case disabledBecauseTextWouldBeRemoved(count: Int)
}

public struct TemplateApplicationPreview: Sendable, Equatable {
    public let disposition: TemplateApplicationDisposition
    public let templateID: String
    public let templateVersion: Int

    public init(
        disposition: TemplateApplicationDisposition,
        templateID: String,
        templateVersion: Int
    ) {
        self.disposition = disposition
        self.templateID = templateID
        self.templateVersion = templateVersion
    }
}

public enum LayoutTemplateEngine {
    public static func validateCatalog(_ templates: [LayoutTemplateDefinition]) throws {
        guard !templates.isEmpty else {
            throw DomainValidationError.invalidTemplate("catalogue vide")
        }
        var keys = Set<String>()
        var activeIDs = Set<String>()
        for template in templates {
            try DomainValidator.validate(template)
            let key = "\(template.id)#\(template.version)"
            guard keys.insert(key).inserted else {
                throw DomainValidationError.invalidTemplate(key)
            }
            if template.isActive && !activeIDs.insert(template.id).inserted {
                throw DomainValidationError.invalidTemplate("version active dupliquée \(template.id)")
            }
        }
    }

    public static func preview(
        applying template: LayoutTemplateDefinition,
        to page: PageSnapshot
    ) -> TemplateApplicationPreview {
        let frames = page.elements.compactMap(\.photoFrame)
        let nonemptyTextCount = page.elements.compactMap(\.textBox).filter {
            !$0.content.plainText.isEmpty
        }.count
        let photoRemoval = max(0, frames.filter { $0.content != nil }.count - template.photoSlots.count)
        let textRemoval = max(0, nonemptyTextCount - template.textSlots.count)
        let disposition: TemplateApplicationDisposition
        if textRemoval > 0 {
            disposition = .disabledBecauseTextWouldBeRemoved(count: textRemoval)
        } else if photoRemoval > 0 {
            disposition = .requiresPhotoRemovalConfirmation(count: photoRemoval)
        } else {
            disposition = .ready
        }
        return TemplateApplicationPreview(
            disposition: disposition,
            templateID: template.id,
            templateVersion: template.version
        )
    }

    /// Pure model application prototype for 3:TPL-004...3:TPL-023.
    public static func apply(
        _ template: LayoutTemplateDefinition,
        to original: PageSnapshot,
        confirmsPhotoRemoval: Bool,
        makeID: () -> UUID = { UUID() }
    ) throws -> PageSnapshot {
        try DomainValidator.validate(template)
        let preview = preview(applying: template, to: original)
        switch preview.disposition {
        case .disabledBecauseTextWouldBeRemoved:
            throw DomainValidationError.invalidTemplate("du texte serait retiré")
        case .requiresPhotoRemovalConfirmation where !confirmsPhotoRemoval:
            throw DomainValidationError.invalidTemplate("confirmation requise")
        default:
            break
        }

        var page = original
        let orderedIDs = Dictionary(uniqueKeysWithValues: page.accessibilityOrder.enumerated().map {
            ($0.element, $0.offset)
        })
        let photos = page.elements.compactMap(\.photoFrame).sorted {
            let lhsFilled = $0.content != nil
            let rhsFilled = $1.content != nil
            if lhsFilled != rhsFilled { return lhsFilled && !rhsFilled }
            return baseOrder(
                lhsID: $0.id,
                lhsGeometry: $0.geometry,
                rhsID: $1.id,
                rhsGeometry: $1.geometry,
                accessibilityIndex: orderedIDs
            )
        }
        let texts = page.elements.compactMap(\.textBox).sorted {
            let lhsFilled = !$0.content.plainText.isEmpty
            let rhsFilled = !$1.content.plainText.isEmpty
            if lhsFilled != rhsFilled { return lhsFilled && !rhsFilled }
            return baseOrder(
                lhsID: $0.id,
                lhsGeometry: $0.geometry,
                rhsID: $1.id,
                rhsGeometry: $1.geometry,
                accessibilityIndex: orderedIDs
            )
        }
        let stickers = page.elements.filter { $0.sticker != nil }

        var nextOrder = (page.elements.map { $0.geometry.order }.max() ?? 0)
            + AlbumPhotoConstants.elementOrderStep
        var resultingElements = stickers
        var addedIDs: [UUID] = []
        let photoSlots = template.photoSlots
        let textSlots = template.textSlots
        let photoIndices = Dictionary(uniqueKeysWithValues: photoSlots.enumerated().map {
            ($0.element.id, $0.offset)
        })
        let textIndices = Dictionary(uniqueKeysWithValues: textSlots.enumerated().map {
            ($0.element.id, $0.offset)
        })
        let orderedSlots = template.slots.sorted(by: LayoutTemplateEngine.slotOrder)

        for slot in orderedSlots {
            switch slot.kind {
            case .photo:
                let index = photoIndices[slot.id]!
                if index < photos.count {
                    var frame = photos[index]
                    frame.geometry.centerX = slot.geometry.centerX
                    frame.geometry.centerY = slot.geometry.centerY
                    frame.geometry.width = slot.geometry.width
                    frame.geometry.height = slot.geometry.height
                    frame.geometry.rotationRadians = slot.geometry.rotationRadians
                    frame.sourceTemplateSlotID = slot.id
                    resultingElements.append(.photo(frame))
                } else {
                    let id = makeID()
                    let defaults = slot.defaultPhotoStyle ?? PhotoFrameStyleDefaults()
                    let frame = PhotoFrameElement(
                        id: id,
                        geometry: slot.geometry.elementGeometry(order: nextOrder),
                        sourceTemplateSlotID: slot.id,
                        content: nil,
                        mask: PhotoMask(shape: defaults.mask),
                        border: defaults.border,
                        decorativeFrame: defaults.decorativeFrame
                    )
                    nextOrder += AlbumPhotoConstants.elementOrderStep
                    resultingElements.append(.photo(frame))
                    addedIDs.append(id)
                }
            case .text:
                let index = textIndices[slot.id]!
                if index < texts.count {
                    var text = texts[index]
                    text.geometry.centerX = slot.geometry.centerX
                    text.geometry.centerY = slot.geometry.centerY
                    text.geometry.width = slot.geometry.width
                    text.geometry.height = slot.geometry.height
                    text.geometry.rotationRadians = slot.geometry.rotationRadians
                    text.sourceTemplateSlotID = slot.id
                    resultingElements.append(.text(text))
                } else {
                    let id = makeID()
                    var defaults = slot.defaultTextStyle ?? TextStyleDefaults()
                    if slot.defaultTextStyle == nil {
                        defaults.color = TextInitialStyleEngine.color(for: page.background)
                    }
                    let text = TextBoxElement(
                        id: id,
                        geometry: slot.geometry.elementGeometry(order: nextOrder),
                        sourceTemplateSlotID: slot.id,
                        typingDefaults: defaults
                    )
                    nextOrder += AlbumPhotoConstants.elementOrderStep
                    resultingElements.append(.text(text))
                    addedIDs.append(id)
                }
            }
        }

        let survivors = Set(resultingElements.map(\.id))
        let addedIDSet = Set(addedIDs)
        let existingAccessibilityIDs = Set(original.accessibilityOrder)
        let recoveredExistingIDs = resultingElements
            .filter {
                !addedIDSet.contains($0.id) && !existingAccessibilityIDs.contains($0.id)
            }
            .sorted(by: PageElement.visualOrder)
            .map(\.id)
        page.elements = addedIDs.isEmpty ? resultingElements : renumbered(resultingElements)
        page.accessibilityOrder = original.accessibilityOrder.filter { survivors.contains($0) }
            + recoveredExistingIDs + addedIDs
        page.layout = PageLayoutState(
            isAutoLayoutEnabled: false,
            photoMode: .template,
            templateID: template.id,
            templateVersion: template.version,
            density: page.layout.density
        )
        return page
    }

    public static func compatibleWithDice(
        _ template: LayoutTemplateDefinition,
        page: PageSnapshot
    ) -> Bool {
        template.isActive
            && template.photoSlots.count == page.elements.compactMap(\.photoFrame).count
            && template.textSlots.count == page.elements.compactMap(\.textBox).count
    }

    private static func renumbered(_ elements: [PageElement]) -> [PageElement] {
        elements.sorted(by: PageElement.visualOrder).enumerated().map { index, element in
            var element = element
            var geometry = element.geometry
            geometry.order = Int64(index + 1) * AlbumPhotoConstants.elementOrderStep
            element.geometry = geometry
            return element
        }
    }

    private static func slotOrder(
        _ lhs: LayoutSlotDefinition,
        _ rhs: LayoutSlotDefinition
    ) -> Bool {
        if lhs.readingOrder != rhs.readingOrder {
            return lhs.readingOrder < rhs.readingOrder
        }
        return lhs.id.utf8.lexicographicallyPrecedes(rhs.id.utf8)
    }

    private static func baseOrder(
        lhsID: UUID,
        lhsGeometry: ElementGeometry,
        rhsID: UUID,
        rhsGeometry: ElementGeometry,
        accessibilityIndex: [UUID: Int]
    ) -> Bool {
        switch (accessibilityIndex[lhsID], accessibilityIndex[rhsID]) {
        case let (.some(lhs), .some(rhs)) where lhs != rhs:
            return lhs < rhs
        case (.some, .none):
            return true
        case (.none, .some):
            return false
        default:
            if lhsGeometry.order != rhsGeometry.order {
                return lhsGeometry.order < rhsGeometry.order
            }
            return uuidBytes(lhsID).lexicographicallyPrecedes(uuidBytes(rhsID))
        }
    }

    private static func uuidBytes(_ value: UUID) -> [UInt8] {
        var bytes = value.uuid
        return withUnsafeBytes(of: &bytes) { Array($0) }
    }
}

public struct LayoutTemplateKey: Codable, Sendable, Equatable, Hashable, Comparable {
    public let id: String
    public let version: Int

    public init(id: String, version: Int) {
        self.id = id
        self.version = version
    }

    public static func < (lhs: LayoutTemplateKey, rhs: LayoutTemplateKey) -> Bool {
        lhs.id == rhs.id ? lhs.version < rhs.version : lhs.id < rhs.id
    }
}

public struct LayoutShuffleBag: Sendable, Equatable {
    private var compatibilitySignature: [LayoutTemplateKey] = []
    private var lastExternalCurrent: LayoutTemplateKey?
    public private(set) var remaining: [LayoutTemplateKey] = []

    public init() {}

    public mutating func reset() {
        compatibilitySignature = []
        lastExternalCurrent = nil
        remaining = []
    }

    public mutating func choose<R: RandomNumberGenerator>(
        compatible: [LayoutTemplateDefinition],
        current: LayoutTemplateKey?,
        using generator: inout R
    ) -> LayoutTemplateKey? {
        let signature = compatible
            .filter(\.isActive)
            .map { LayoutTemplateKey(id: $0.id, version: $0.version) }
            .sorted()
        guard signature.count > 1 || (signature.count == 1 && signature[0] != current) else {
            reset()
            return nil
        }
        if signature != compatibilitySignature || current != lastExternalCurrent || remaining.isEmpty {
            compatibilitySignature = signature
            remaining = signature.filter { $0 != current }
        }
        guard !remaining.isEmpty else { return nil }
        let index = Int.random(in: 0..<remaining.count, using: &generator)
        let selected = remaining.remove(at: index)
        lastExternalCurrent = selected
        return selected
    }
}

private struct AutoLayoutCandidate {
    let geometries: [ElementGeometry]
    let orientationPenalty: Double
    let surfacePenalty: Double
    let unused: Int
    let rows: Int
    let columns: Int
}

public enum AutoLayoutEngine {
    public static func geometries(
        count: Int,
        density: AutoLayoutDensity,
        photoAspectRatios: [Double] = [],
        templates: [LayoutTemplateDefinition] = []
    ) throws -> [ElementGeometry] {
        guard count >= 0, count <= 20 else {
            throw DomainValidationError.invalidLayoutState
        }
        guard count > 0 else { return [] }
        let target: Double
        switch density {
        case .airy: target = 0.55
        case .balanced: target = 0.70
        case .dense: target = 0.85
        }

        let exactTemplates = templates.filter {
            $0.isActive && $0.photoSlots.count == count
        }
        if !exactTemplates.isEmpty {
            let scored = try exactTemplates.map { candidate -> (
                template: LayoutTemplateDefinition,
                orientation: Double,
                surface: Double
            ) in
                try DomainValidator.validate(candidate)
                let slots = candidate.photoSlots
                let orientation = slots.indices.reduce(0.0) { result, index in
                    let slot = slots[index]
                    let slotRatio = (slot.geometry.width * 4)
                        / (slot.geometry.height * 5)
                    let photoRatio = index < photoAspectRatios.count
                        && photoAspectRatios[index].isFinite
                        && photoAspectRatios[index] > 0
                        ? photoAspectRatios[index] : slotRatio
                    return result + abs(log2(photoRatio / slotRatio))
                }
                let surface = slots.reduce(0.0) {
                    $0 + $1.geometry.width * $1.geometry.height
                }
                return (candidate, quantized(orientation), quantized(abs(surface - target)))
            }
            let winner = scored.min { lhs, rhs in
                if lhs.orientation != rhs.orientation {
                    return lhs.orientation < rhs.orientation
                }
                if lhs.surface != rhs.surface { return lhs.surface < rhs.surface }
                if lhs.template.id != rhs.template.id {
                    return lhs.template.id < rhs.template.id
                }
                return lhs.template.version < rhs.template.version
            }!
            return winner.template.photoSlots.enumerated().map { index, slot in
                slot.geometry.elementGeometry(
                    order: Int64(index + 1) * AlbumPhotoConstants.elementOrderStep
                )
            }
        }

        let spacing: Double
        switch density {
        case .airy: spacing = 0.04
        case .balanced: spacing = 0.025
        case .dense: spacing = 0.015
        }

        var candidates: [AutoLayoutCandidate] = []
        for rows in 1...count {
            let columns = Int(ceil(Double(count) / Double(rows)))
            if (rows - 1) * columns >= count { continue }
            let cellWidth = (1 - 2 * spacing - Double(columns - 1) * spacing) / Double(columns)
            let cellHeight = (1 - 2 * spacing - Double(rows - 1) * spacing) / Double(rows)
            guard cellWidth >= 0.05, cellHeight >= 0.05 else { continue }
            var values: [ElementGeometry] = []
            for index in 0..<count {
                let row = index / columns
                let column = index % columns
                let lastCount = count - (rows - 1) * columns
                let itemsInRow = row == rows - 1 ? lastCount : columns
                let left = row == rows - 1
                    ? spacing + Double(columns - itemsInRow) * (cellWidth + spacing) / 2
                    : spacing
                let centerX = left + (Double(column) + 0.5) * cellWidth + Double(column) * spacing
                let centerY = spacing + (Double(row) + 0.5) * cellHeight + Double(row) * spacing
                values.append(ElementGeometry(
                    centerX: centerX,
                    centerY: centerY,
                    width: cellWidth,
                    height: cellHeight,
                    order: Int64(index + 1) * AlbumPhotoConstants.elementOrderStep
                ))
            }
            let slotRatio = (cellWidth * 4) / (cellHeight * 5)
            let orientation = values.indices.reduce(0.0) { result, index in
                let photoRatio = index < photoAspectRatios.count && photoAspectRatios[index] > 0
                    ? photoAspectRatios[index] : slotRatio
                return result + abs(log2(photoRatio / slotRatio))
            }
            candidates.append(AutoLayoutCandidate(
                geometries: values,
                orientationPenalty: quantized(orientation),
                surfacePenalty: quantized(abs(Double(count) * cellWidth * cellHeight - target)),
                unused: rows * columns - count,
                rows: rows,
                columns: columns
            ))
        }
        guard let winner = candidates.min(by: { lhs, rhs in
            if lhs.orientationPenalty != rhs.orientationPenalty {
                return lhs.orientationPenalty < rhs.orientationPenalty
            }
            if lhs.surfacePenalty != rhs.surfacePenalty {
                return lhs.surfacePenalty < rhs.surfacePenalty
            }
            if lhs.unused != rhs.unused { return lhs.unused < rhs.unused }
            if lhs.rows != rhs.rows { return lhs.rows < rhs.rows }
            return lhs.columns < rhs.columns
        }) else {
            throw DomainValidationError.invalidLayoutState
        }
        return winner.geometries
    }

    public static func recompose(
        page original: PageSnapshot,
        metadataByAssetID: [UUID: PhotoAssetMetadata],
        templates: [LayoutTemplateDefinition] = [],
        initialCoverElementIDs: Set<UUID> = []
    ) throws -> PageSnapshot {
        var page = original
        let accessibilityIndex = Dictionary(uniqueKeysWithValues: page.accessibilityOrder.enumerated().map {
            ($0.element, $0.offset)
        })
        var frames = page.elements.compactMap(\.photoFrame)
            .filter { $0.content != nil }
            .sorted {
                let lhs = accessibilityIndex[$0.id] ?? Int.max
                let rhs = accessibilityIndex[$1.id] ?? Int.max
                if lhs != rhs { return lhs < rhs }
                if $0.geometry.order != $1.geometry.order {
                    return $0.geometry.order < $1.geometry.order
                }
                return uuidBytes($0.id).lexicographicallyPrecedes(uuidBytes($1.id))
            }
        let aspects = try frames.map { frame -> Double in
            guard let placement = frame.content,
                  let metadata = metadataByAssetID[placement.assetID] else {
                throw DomainValidationError.assetNotFound(
                    frame.content?.assetID ?? UUID()
                )
            }
            let size = try PhotoCropGeometry.orientedPixelSize(
                metadata: metadata,
                quarterTurns: placement.quarterTurns
            )
            return size.width / size.height
        }
        let geometries = try geometries(
            count: frames.count,
            density: page.layout.density,
            photoAspectRatios: aspects,
            templates: templates
        )
        for index in frames.indices {
            frames[index].geometry.centerX = geometries[index].centerX
            frames[index].geometry.centerY = geometries[index].centerY
            frames[index].geometry.width = geometries[index].width
            frames[index].geometry.height = geometries[index].height
            frames[index].geometry.rotationRadians = 0
            frames[index].sourceTemplateSlotID = nil
            if initialCoverElementIDs.contains(frames[index].id),
               let assetID = frames[index].content?.assetID,
               let metadata = metadataByAssetID[assetID] {
                frames[index].content = try PhotoCropGeometry.initialPlacement(
                    assetID: assetID,
                    metadata: metadata,
                    frameGeometry: frames[index].geometry
                )
            }
        }
        let nonphotos = page.elements.compactMap { element -> PageElement? in
            switch element {
            case .photo:
                return nil
            case var .text(text):
                text.sourceTemplateSlotID = nil
                return .text(text)
            case .sticker:
                return element
            }
        }
        page.elements = nonphotos + frames.map(PageElement.photo)
        let survivors = Set(page.elements.map(\.id))
        page.accessibilityOrder = page.accessibilityOrder.filter { survivors.contains($0) }
        page.layout.isAutoLayoutEnabled = true
        page.layout.photoMode = .automatic
        page.layout.templateID = nil
        page.layout.templateVersion = nil
        return page
    }

    private static func quantized(_ value: Double) -> Double {
        floor(value * 1_000_000 + 0.5) / 1_000_000
    }

    private static func uuidBytes(_ value: UUID) -> [UInt8] {
        var bytes = value.uuid
        return withUnsafeBytes(of: &bytes) { Array($0) }
    }

}

public struct AlbumFillPlan: Sendable, Equatable, Identifiable {
    public let albumID: UUID
    public let density: AutoLayoutDensity
    public let photoGroups: [[UUID]]
    public let reusablePageIDs: [UUID]
    public let emptyPhotoFrameCount: Int

    public var id: UUID { albumID }
    public var photoCount: Int { photoGroups.reduce(0) { $0 + $1.count } }
    public var reusedPageCount: Int { reusablePageIDs.count }
    public var createdPageCount: Int { photoGroups.count - reusablePageIDs.count }

    public init(
        albumID: UUID,
        density: AutoLayoutDensity,
        photoGroups: [[UUID]],
        reusablePageIDs: [UUID],
        emptyPhotoFrameCount: Int
    ) {
        self.albumID = albumID
        self.density = density
        self.photoGroups = photoGroups
        self.reusablePageIDs = reusablePageIDs
        self.emptyPhotoFrameCount = emptyPhotoFrameCount
    }
}

public enum AlbumFillEngine {
    public static func plan(
        album: AlbumSnapshot,
        metadataByAssetID: [UUID: PhotoAssetMetadata],
        density: AutoLayoutDensity
    ) throws -> AlbumFillPlan? {
        let albumIndexByAssetID = Dictionary(uniqueKeysWithValues:
            album.photoAssetIDs.enumerated().map { ($0.element, $0.offset) }
        )
        let usedAssetIDs = Set(album.pages.flatMap { page in
            page.elements.compactMap { $0.photoFrame?.content?.assetID }
        })
        let unusedPhotoIDs = try album.photoAssetIDs
            .filter { !usedAssetIDs.contains($0) }
            .map { assetID -> (id: UUID, metadata: PhotoAssetMetadata, index: Int) in
                guard let metadata = metadataByAssetID[assetID],
                      let index = albumIndexByAssetID[assetID] else {
                    throw DomainValidationError.assetNotFound(assetID)
                }
                return (assetID, metadata, index)
            }
            .sorted { lhs, rhs in
                let lhsDate = lhs.metadata.capturedAt ?? lhs.metadata.importedAt
                let rhsDate = rhs.metadata.capturedAt ?? rhs.metadata.importedAt
                if lhsDate != rhsDate { return lhsDate < rhsDate }
                if lhs.index != rhs.index { return lhs.index < rhs.index }
                return uuidBytes(lhs.id).lexicographicallyPrecedes(uuidBytes(rhs.id))
            }
            .map(\.id)
        guard !unusedPhotoIDs.isEmpty else { return nil }

        let capacity = albumFillCapacity(for: density)
        let groups = stride(from: 0, to: unusedPhotoIDs.count, by: capacity).map {
            Array(unusedPhotoIDs[$0..<min($0 + capacity, unusedPhotoIDs.count)])
        }
        let reusablePages = album.pages.filter { page in
            page.elements.compactMap(\.photoFrame).allSatisfy { $0.content == nil }
        }.prefix(groups.count)
        let reusablePageIDs = reusablePages.map(\.id)
        let emptyPhotoFrameCount = reusablePages.reduce(0) { count, page in
            count + page.elements.compactMap(\.photoFrame).filter { $0.content == nil }.count
        }
        return AlbumFillPlan(
            albumID: album.id,
            density: density,
            photoGroups: groups,
            reusablePageIDs: reusablePageIDs,
            emptyPhotoFrameCount: emptyPhotoFrameCount
        )
    }

    public static func apply(
        _ plan: AlbumFillPlan,
        to original: AlbumSnapshot,
        metadataByAssetID: [UUID: PhotoAssetMetadata],
        templates: [LayoutTemplateDefinition] = [],
        makePageID: () -> UUID = UUID.init,
        makeElementID: () -> UUID = UUID.init
    ) throws -> AlbumSnapshot {
        guard plan.albumID == original.id,
              let current = try self.plan(
                album: original,
                metadataByAssetID: metadataByAssetID,
                density: plan.density
              ),
              current == plan else {
            throw DomainValidationError.invalidLayoutState
        }

        var album = original
        for (groupIndex, photoIDs) in plan.photoGroups.enumerated() {
            let pageIndex: Int
            if groupIndex < plan.reusablePageIDs.count {
                guard let existingIndex = album.pages.firstIndex(where: {
                    $0.id == plan.reusablePageIDs[groupIndex]
                }) else {
                    throw DomainValidationError.invalidLayoutState
                }
                pageIndex = existingIndex
            } else {
                album.pages.append(PageSnapshot(id: makePageID()))
                pageIndex = album.pages.count - 1
            }

            var page = album.pages[pageIndex]
            let emptyFrameIDs = baseOrderedEmptyPhotoFrameIDs(in: page).reversed()
            for frameID in emptyFrameIDs {
                page.elements.removeAll { $0.id == frameID }
                page.accessibilityOrder.removeAll { $0 == frameID }
            }
            for elementIndex in page.elements.indices {
                guard var text = page.elements[elementIndex].textBox else { continue }
                text.sourceTemplateSlotID = nil
                page.elements[elementIndex] = .text(text)
            }

            page.layout = PageLayoutState(
                isAutoLayoutEnabled: true,
                photoMode: .automatic,
                density: plan.density
            )
            var order = (page.elements.map { $0.geometry.order }.max() ?? 0)
                + AlbumPhotoConstants.elementOrderStep
            var insertedElementIDs: Set<UUID> = []
            for assetID in photoIDs {
                guard metadataByAssetID[assetID] != nil else {
                    throw DomainValidationError.assetNotFound(assetID)
                }
                let elementID = makeElementID()
                page.elements.append(.photo(PhotoFrameElement(
                    id: elementID,
                    geometry: ElementGeometry(order: order),
                    content: PhotoPlacement(assetID: assetID)
                )))
                page.accessibilityOrder.append(elementID)
                insertedElementIDs.insert(elementID)
                order += AlbumPhotoConstants.elementOrderStep
            }
            album.pages[pageIndex] = try AutoLayoutEngine.recompose(
                page: page,
                metadataByAssetID: metadataByAssetID,
                templates: templates,
                initialCoverElementIDs: insertedElementIDs
            )
        }

        let validAssetIDs = Set(album.photoAssetIDs)
        for page in album.pages {
            try DomainValidator.validate(page, validAssetIDs: validAssetIDs)
        }
        return album
    }

    private static func albumFillCapacity(for density: AutoLayoutDensity) -> Int {
        switch density {
        case .airy: 2
        case .balanced: 4
        case .dense: 8
        }
    }

    private static func baseOrderedEmptyPhotoFrameIDs(in page: PageSnapshot) -> [UUID] {
        let accessibilityIndex = Dictionary(uniqueKeysWithValues:
            page.accessibilityOrder.enumerated().map { ($0.element, $0.offset) }
        )
        return page.elements.compactMap(\.photoFrame)
            .filter { $0.content == nil }
            .sorted { lhs, rhs in
                switch (accessibilityIndex[lhs.id], accessibilityIndex[rhs.id]) {
                case let (.some(lhsIndex), .some(rhsIndex)) where lhsIndex != rhsIndex:
                    return lhsIndex < rhsIndex
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                default:
                    if lhs.geometry.order != rhs.geometry.order {
                        return lhs.geometry.order < rhs.geometry.order
                    }
                    return uuidBytes(lhs.id).lexicographicallyPrecedes(uuidBytes(rhs.id))
                }
            }
            .map(\.id)
    }

    private static func uuidBytes(_ value: UUID) -> [UInt8] {
        var bytes = value.uuid
        return withUnsafeBytes(of: &bytes) { Array($0) }
    }
}

public enum TextPrototypeEngine {
    /// Converts the persisted canonical font value to the destination page
    /// scale. Existing albums keep their stored `relativeFontSize` unchanged.
    public static func renderedFontSize(
        relativeFontSize: Double,
        pageHeight: Double
    ) -> Double {
        relativeFontSize
            * pageHeight
            * AlbumPhotoConstants.canonicalUnitsPerTypographicPoint
    }

    public static func appending(
        _ text: String,
        to existing: String,
        maximumCharacters: Int = 1_000
    ) -> String {
        String((existing + text).prefix(maximumCharacters))
    }

    public static func overflows(
        content: TextBoxContent,
        geometry: ElementGeometry,
        averageGlyphWidthFactor: Double = 0.52
    ) -> Bool {
        requiredHeight(
            for: content,
            width: geometry.width,
            averageGlyphWidthFactor: averageGlyphWidthFactor
        ) > geometry.height + 0.000_001
    }

    public static func automaticallyFittedGeometry(
        for content: TextBoxContent,
        from geometry: ElementGeometry,
        averageGlyphWidthFactor: Double = 0.52
    ) -> ElementGeometry {
        var result = geometry
        let required = requiredHeight(
            for: content,
            width: geometry.width,
            averageGlyphWidthFactor: averageGlyphWidthFactor
        )
        result.height = min(1, max(geometry.height, required))
        result.centerY = min(1 - result.height / 2, max(result.height / 2, result.centerY))
        return result
    }

    public static func requiredHeight(
        for content: TextBoxContent,
        width: Double,
        averageGlyphWidthFactor: Double = 0.52
    ) -> Double {
        guard !content.plainText.isEmpty else { return 0 }
        let widthUnits = max(1, width * AlbumPhotoConstants.canonicalPageWidth)
        let heightUnits = content.paragraphs.reduce(0.0) { total, paragraph in
            let fallback = renderedFontSize(
                relativeFontSize: TextStyleDefaults().relativeFontSize,
                pageHeight: AlbumPhotoConstants.canonicalPageHeight
            )
            let maximumFontHeight = paragraph.runs.map {
                renderedFontSize(
                    relativeFontSize: $0.relativeFontSize,
                    pageHeight: AlbumPhotoConstants.canonicalPageHeight
                )
            }.max() ?? fallback
            let estimatedWidth = paragraph.runs.reduce(0.0) { partial, run in
                let fontHeight = renderedFontSize(
                    relativeFontSize: run.relativeFontSize,
                    pageHeight: AlbumPhotoConstants.canonicalPageHeight
                )
                return partial + Double(run.text.count) * fontHeight
                    * averageGlyphWidthFactor
            }
            let lineCount = max(1, Int(ceil(estimatedWidth / widthUnits)))
            return total + Double(lineCount) * maximumFontHeight * paragraph.lineSpacing
        }
        return heightUnits / AlbumPhotoConstants.canonicalPageHeight
    }
}

public enum TextInitialStyleEngine {
    /// Chooses the initial text color only; existing text is never passed to
    /// this function and therefore can never be recolored by a background.
    public static func color(for background: BackgroundSelection) -> SRGBAColor {
        switch background {
        case .none:
            return .black
        case let .solid(color):
            return relativeLuminance(color) > 0.179 ? .black : .white
        case let .catalog(reference):
            return BackgroundCatalog.theme(id: reference.catalogID)?.textContrastHint
                == .lightText ? .white : .black
        }
    }

    private static func relativeLuminance(_ color: SRGBAColor) -> Double {
        func linear(_ component: Double) -> Double {
            let bounded = min(1, max(0, component))
            return bounded <= 0.04045
                ? bounded / 12.92
                : pow((bounded + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(color.red)
            + 0.7152 * linear(color.green)
            + 0.0722 * linear(color.blue)
    }
}

public enum PageTurnDirection: String, Codable, Sendable, Equatable, Hashable {
    case previous
    case next
}

public enum PageTurnPhase: Sendable, Equatable {
    case idle
    case dragging(direction: PageTurnDirection, progress: Double)
    case settling(direction: PageTurnDirection, completes: Bool)
}

public struct PageTurnStateMachine: Sendable, Equatable {
    public private(set) var phase: PageTurnPhase = .idle

    public init() {}

    public mutating func update(
        horizontalTranslation: Double,
        verticalTranslation: Double,
        availableWidth: Double,
        canGoPrevious: Bool,
        canGoNext: Bool
    ) {
        if case .settling = phase { return }
        guard availableWidth > 0,
              abs(horizontalTranslation) > 1.25 * abs(verticalTranslation) else {
            phase = .idle
            return
        }
        let direction: PageTurnDirection = horizontalTranslation < 0 ? .next : .previous
        guard (direction == .next ? canGoNext : canGoPrevious) else {
            phase = .idle
            return
        }
        phase = .dragging(
            direction: direction,
            progress: min(1, abs(horizontalTranslation) / availableWidth)
        )
    }

    @discardableResult
    public mutating func end(velocity: Double = 0) -> PageTurnDirection? {
        guard case let .dragging(direction, progress) = phase else {
            phase = .idle
            return nil
        }
        let velocityCompletes: Bool
        switch direction {
        case .next: velocityCompletes = velocity < -600
        case .previous: velocityCompletes = velocity > 600
        }
        let completes = progress > 0.25 || velocityCompletes
        phase = .settling(direction: direction, completes: completes)
        return completes ? direction : nil
    }

    /// Button-driven transition prototype (3:ANI-005/008). The renderer owns
    /// perspective and uses this duration; a second command is ignored.
    @discardableResult
    public mutating func beginButtonTransition(
        direction: PageTurnDirection,
        canNavigate: Bool
    ) -> Bool {
        guard phase == .idle, canNavigate else { return false }
        phase = .settling(direction: direction, completes: true)
        return true
    }

    public static let buttonDurationSeconds = 0.35

    public mutating func finishAnimation() {
        phase = .idle
    }

    public mutating func cancel() {
        phase = .idle
    }
}
