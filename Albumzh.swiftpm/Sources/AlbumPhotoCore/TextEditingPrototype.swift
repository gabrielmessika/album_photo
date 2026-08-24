import Foundation

public struct TextSelectionRange: Codable, Sendable, Equatable, Hashable {
    public var lowerBound: Int
    public var upperBound: Int

    public init(lowerBound: Int, upperBound: Int) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }

    public var isInsertionPoint: Bool { lowerBound == upperBound }
}

public struct TextCharacterStylePatch: Codable, Sendable, Equatable, Hashable {
    public var fontID: String?
    public var relativeFontSize: Double?
    public var weight: TextWeightValue?
    public var isItalic: Bool?
    public var color: SRGBAColor?

    public init(
        fontID: String? = nil,
        relativeFontSize: Double? = nil,
        weight: TextWeightValue? = nil,
        isItalic: Bool? = nil,
        color: SRGBAColor? = nil
    ) {
        self.fontID = fontID
        self.relativeFontSize = relativeFontSize
        self.weight = weight
        self.isItalic = isItalic
        self.color = color
    }
}

public struct TextParagraphStylePatch: Codable, Sendable, Equatable, Hashable {
    public var alignment: TextAlignmentValue?
    public var lineSpacing: Double?

    public init(alignment: TextAlignmentValue? = nil, lineSpacing: Double? = nil) {
        self.alignment = alignment
        self.lineSpacing = lineSpacing
    }
}

/// Platform adapters convert an attributed paste to this plain-text shape.
/// `supportedStyle` is retained for source compatibility but deliberately
/// ignored: pasted characters adopt the local insertion style (3:TBX-007).
public struct TextPastePrototypePayload: Codable, Sendable, Equatable, Hashable {
    public var text: String
    public var supportedStyle: TextCharacterStylePatch
    public var discardedAttributeNames: [String]
    public var containsAttachment: Bool

    public init(
        text: String,
        supportedStyle: TextCharacterStylePatch = TextCharacterStylePatch(),
        discardedAttributeNames: [String] = [],
        containsAttachment: Bool = false
    ) {
        self.text = text
        self.supportedStyle = supportedStyle
        self.discardedAttributeNames = discardedAttributeNames
        self.containsAttachment = containsAttachment
    }
}

public enum TextEditingPrototype {
    /// 3:TBX-007 — shared allow-list used by platform paste adapters and the
    /// durable model boundary. Tabs and line feeds are the only controls kept.
    public static func sanitizedPlainText(
        _ text: String,
        maximumCharacters: Int = 1_000
    ) -> String {
        var scalars = String.UnicodeScalarView()
        for scalar in text.unicodeScalars {
            if scalar.value == 0xfffc { continue }
            if scalar.value < 0x20 && scalar.value != 0x09 && scalar.value != 0x0a {
                continue
            }
            scalars.append(scalar)
        }
        return String(String(scalars).prefix(maximumCharacters))
    }

    /// Applies character attributes to a partial Swift-Character selection and
    /// splits runs only at the selection boundaries.
    public static func applying(
        _ patch: TextCharacterStylePatch,
        to content: TextBoxContent,
        selection: TextSelectionRange
    ) throws -> TextBoxContent {
        try validate(selection, characterCount: content.plainText.count)
        guard !selection.isInsertionPoint else { return content }
        var result = content
        var cursor = 0
        for paragraphIndex in result.paragraphs.indices {
            var replacement: [TextRun] = []
            for run in result.paragraphs[paragraphIndex].runs {
                let characters = Array(run.text)
                let start = cursor
                let end = cursor + characters.count
                let selectedStart = max(start, selection.lowerBound)
                let selectedEnd = min(end, selection.upperBound)
                if selectedStart >= selectedEnd {
                    replacement.append(run)
                } else {
                    appendRun(run, characters: characters,
                              range: 0..<(selectedStart - start), patch: nil, to: &replacement)
                    appendRun(run, characters: characters,
                              range: (selectedStart - start)..<(selectedEnd - start),
                              patch: patch, to: &replacement)
                    appendRun(run, characters: characters,
                              range: (selectedEnd - start)..<characters.count,
                              patch: nil, to: &replacement)
                }
                cursor = end
            }
            result.paragraphs[paragraphIndex].runs = replacement
            if paragraphIndex < result.paragraphs.count - 1 { cursor += 1 }
        }
        try DomainValidator.validate(TextBoxElement(content: result))
        return result
    }

    /// A collapsed selection changes typing defaults without rewriting text.
    public static func typingDefaults(
        applying patch: TextCharacterStylePatch,
        to current: TextStyleDefaults
    ) throws -> TextStyleDefaults {
        var result = current
        if let value = patch.fontID { result.fontID = value }
        if let value = patch.relativeFontSize { result.relativeFontSize = value }
        if let value = patch.weight { result.weight = value }
        if let value = patch.isItalic { result.isItalic = value }
        if let value = patch.color { result.color = value }
        try DomainValidator.validate(result)
        return result
    }

    public static func applying(
        _ patch: TextParagraphStylePatch,
        to content: TextBoxContent,
        selection: TextSelectionRange
    ) throws -> TextBoxContent {
        try validate(selection, characterCount: content.plainText.count)
        if let spacing = patch.lineSpacing,
           !spacing.isFinite || !(0.8...2).contains(spacing) {
            throw DomainValidationError.invalidText
        }
        var result = content
        var cursor = 0
        for index in result.paragraphs.indices {
            let count = result.paragraphs[index].runs.reduce(0) { $0 + $1.text.count }
            let start = cursor
            let end = cursor + count
            let touched: Bool
            if selection.isInsertionPoint {
                touched = selection.lowerBound >= start
                    && (selection.lowerBound <= end || index == result.paragraphs.count - 1)
            } else {
                touched = max(start, selection.lowerBound) < min(end + 1, selection.upperBound)
            }
            if touched {
                if let value = patch.alignment { result.paragraphs[index].alignment = value }
                if let value = patch.lineSpacing { result.paragraphs[index].lineSpacing = value }
            }
            cursor = end + (index < result.paragraphs.count - 1 ? 1 : 0)
        }
        try DomainValidator.validate(TextBoxElement(content: result))
        return result
    }

    /// URLs remain plain text; attachment placeholders, source formatting and
    /// unmodeled control characters are removed. Pasted characters use the
    /// local typing style at the insertion point (3:TBX-007).
    public static func filteredPaste(
        _ payload: TextPastePrototypePayload,
        typingDefaults: TextStyleDefaults,
        maximumCharacters: Int = 1_000
    ) throws -> TextBoxContent {
        let sanitized = sanitizedPlainText(
            payload.text,
            maximumCharacters: maximumCharacters
        )
        let style = typingDefaults
        let paragraphs = sanitized.split(separator: "\n", omittingEmptySubsequences: false).map {
            TextParagraph(
                alignment: style.alignment,
                lineSpacing: style.lineSpacing,
                runs: [TextRun(text: String($0), style: style)]
            )
        }
        let result = TextBoxContent(paragraphs: paragraphs)
        try DomainValidator.validate(TextBoxElement(content: result, typingDefaults: style))
        return result
    }

    public static func resized(
        _ element: TextBoxElement,
        to geometry: ElementGeometry
    ) throws -> TextBoxElement {
        try DomainValidator.validate(geometry)
        var result = element
        result.geometry = geometry
        result.usesAutomaticHeight = false
        try DomainValidator.validate(result)
        return result
    }

    private static func validate(_ selection: TextSelectionRange, characterCount: Int) throws {
        guard selection.lowerBound >= 0,
              selection.upperBound >= selection.lowerBound,
              selection.upperBound <= characterCount else {
            throw DomainValidationError.invalidText
        }
    }

    private static func appendRun(
        _ source: TextRun,
        characters: [Character],
        range: Range<Int>,
        patch: TextCharacterStylePatch?,
        to output: inout [TextRun]
    ) {
        guard !range.isEmpty else { return }
        var run = source
        run.text = String(characters[range])
        if let patch {
            if let value = patch.fontID { run.fontID = value }
            if let value = patch.relativeFontSize { run.relativeFontSize = value }
            if let value = patch.weight { run.weight = value }
            if let value = patch.isItalic { run.isItalic = value }
            if let value = patch.color { run.color = value }
        }
        output.append(run)
    }
}

/// Pure serializable undo prototype, independent of SwiftUI/AttributedString.
public struct TextEditingPrototypeSession: Codable, Sendable, Equatable {
    public private(set) var original: TextBoxElement
    public private(set) var current: TextBoxElement
    public private(set) var undoStack: [TextBoxElement]
    public private(set) var redoStack: [TextBoxElement]

    public init(element: TextBoxElement) {
        self.original = element
        self.current = element
        self.undoStack = []
        self.redoStack = []
    }

    public mutating func commit(_ element: TextBoxElement) throws {
        try DomainValidator.validate(element)
        guard element != current else { return }
        undoStack.append(current)
        current = element
        redoStack.removeAll()
    }

    @discardableResult
    public mutating func undo() throws -> TextBoxElement {
        guard let previous = undoStack.popLast() else {
            throw DomainValidationError.nothingToUndo
        }
        redoStack.append(current)
        current = previous
        return current
    }

    @discardableResult
    public mutating func redo() throws -> TextBoxElement {
        guard let next = redoStack.popLast() else {
            throw DomainValidationError.nothingToRedo
        }
        undoStack.append(current)
        current = next
        return current
    }

    public mutating func cancel() {
        current = original
        undoStack.removeAll()
        redoStack.removeAll()
    }
}
