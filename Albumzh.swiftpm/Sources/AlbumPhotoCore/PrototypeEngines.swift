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
        makeID: @Sendable () -> UUID = { UUID() }
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
            let lhsOrder = orderedIDs[$0.id] ?? Int.max
            let rhsOrder = orderedIDs[$1.id] ?? Int.max
            if lhsOrder != rhsOrder { return lhsOrder < rhsOrder }
            return $0.id.uuidString < $1.id.uuidString
        }
        let texts = page.elements.compactMap(\.textBox).sorted {
            let lhsFilled = !$0.content.plainText.isEmpty
            let rhsFilled = !$1.content.plainText.isEmpty
            if lhsFilled != rhsFilled { return lhsFilled && !rhsFilled }
            let lhsOrder = orderedIDs[$0.id] ?? Int.max
            let rhsOrder = orderedIDs[$1.id] ?? Int.max
            if lhsOrder != rhsOrder { return lhsOrder < rhsOrder }
            return $0.id.uuidString < $1.id.uuidString
        }
        let stickers = page.elements.filter { $0.sticker != nil }

        var nextOrder = (page.elements.map { $0.geometry.order }.max() ?? 0)
            + AlbumPhotoConstants.elementOrderStep
        var resultingElements = stickers
        var addedIDs: [UUID] = []

        for (index, slot) in template.photoSlots.enumerated() {
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
        }

        for (index, slot) in template.textSlots.enumerated() {
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
                let defaults = slot.defaultTextStyle ?? TextStyleDefaults()
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

        let survivors = Set(resultingElements.map(\.id))
        page.elements = renumbered(resultingElements)
        page.accessibilityOrder = original.accessibilityOrder.filter { survivors.contains($0) }
            + addedIDs
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
        templates: [LayoutTemplateDefinition] = []
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
                return $0.id.uuidString < $1.id.uuidString
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
        }
        let nonphotos = page.elements.filter { $0.photoFrame == nil }
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

}

public enum TextPrototypeEngine {
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
        let text = content.plainText
        guard !text.isEmpty else { return false }
        let estimatedFontHeight = max(0.000_001, content.paragraphs.first?.runs.first?.relativeFontSize
            ?? TextStyleDefaults().relativeFontSize)
        let widthUnits = geometry.width * AlbumPhotoConstants.canonicalPageWidth
        let heightUnits = geometry.height * AlbumPhotoConstants.canonicalPageHeight
        let glyphWidth = estimatedFontHeight * AlbumPhotoConstants.canonicalPageHeight * averageGlyphWidthFactor
        let lineHeight = estimatedFontHeight * AlbumPhotoConstants.canonicalPageHeight
        let charactersPerLine = max(1, Int(widthUnits / max(1, glyphWidth)))
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).reduce(0) {
            $0 + max(1, Int(ceil(Double($1.count) / Double(charactersPerLine))))
        }
        return Double(lines) * lineHeight > heightUnits
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
