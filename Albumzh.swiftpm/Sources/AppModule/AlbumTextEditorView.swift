import AlbumPhotoCore
import Foundation
import SwiftUI

struct TextEditingRequest: Identifiable, Equatable {
    let pageID: UUID
    let original: TextBoxElement
    let isNew: Bool

    var id: UUID { original.id }
}

private struct AlbumParagraphStyleValue: Codable, Sendable, Equatable, Hashable {
    var alignment: TextAlignmentValue
    var lineSpacing: Double
}

private struct AlbumTextStyleAttribute: CodableAttributedStringKey {
    typealias Value = TextStyleDefaults
    static let name = "AlbumZH.TextStyle"
    static let inheritedByAddedText = true
}

private struct AlbumParagraphStyleAttribute: CodableAttributedStringKey {
    typealias Value = AlbumParagraphStyleValue
    static let name = "AlbumZH.ParagraphStyle"
    static let inheritedByAddedText = true
    static let runBoundaries: AttributedString.AttributeRunBoundaries? = .paragraph
}

private extension AttributeScopes {
    struct AlbumTextAttributes: AttributeScope {
        let font: AttributeScopes.SwiftUIAttributes.FontAttribute
        let foregroundColor: AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute
        let alignment: AttributeScopes.CoreTextAttributes.TextAlignmentAttribute
        let lineHeight: AttributeScopes.CoreTextAttributes.LineHeightAttribute
        let albumTextStyle: AlbumTextStyleAttribute
        let albumParagraphStyle: AlbumParagraphStyleAttribute
    }
}

private extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(
        dynamicMember keyPath: KeyPath<AttributeScopes.AlbumTextAttributes, T>
    ) -> T {
        self[T.self]
    }
}

private struct AlbumTextFormattingDefinition: AttributedTextFormattingDefinition {
    typealias Scope = AttributeScopes.AlbumTextAttributes

    var body: some AttributedTextFormattingDefinition<Scope> {
        NormalizeAlbumCharacterStyle()
        NormalizeAlbumParagraphStyle()
    }
}

private struct NormalizeAlbumCharacterStyle: AttributedTextValueConstraint {
    typealias Scope = AlbumTextFormattingDefinition.Scope
    typealias AttributeKey = AlbumTextStyleAttribute

    func constrain(_ container: inout Attributes) {
        let style = container.albumTextStyle ?? TextStyleDefaults()
        container.albumTextStyle = style
        container.font = AlbumTextAttributedBridge.font(
            for: style,
            pageHeight: AlbumPhotoConstants.canonicalPageHeight
        )
        container.foregroundColor = style.color.swiftUIColor
    }
}

private struct NormalizeAlbumParagraphStyle: AttributedTextValueConstraint {
    typealias Scope = AlbumTextFormattingDefinition.Scope
    typealias AttributeKey = AlbumParagraphStyleAttribute

    func constrain(_ container: inout Attributes) {
        let defaults = container.albumTextStyle ?? TextStyleDefaults()
        let style = container.albumParagraphStyle ?? AlbumParagraphStyleValue(
            alignment: defaults.alignment,
            lineSpacing: defaults.lineSpacing
        )
        container.albumParagraphStyle = style
        container.alignment = AlbumTextAttributedBridge.attributedAlignment(style.alignment)
        container.lineHeight = .multiple(factor: CGFloat(style.lineSpacing))
    }
}

enum AlbumTextAttributedBridge {
    static func attributedString(
        from content: TextBoxContent,
        defaults: TextStyleDefaults,
        pageHeight: Double
    ) -> AttributedString {
        var result = AttributedString()
        for paragraphIndex in content.paragraphs.indices {
            let paragraph = content.paragraphs[paragraphIndex]
            let paragraphStart = result.endIndex
            if paragraph.runs.isEmpty, paragraphIndex < content.paragraphs.count - 1 {
                result += styledRun("\n", style: defaults, pageHeight: pageHeight)
            } else {
                for run in paragraph.runs {
                    result += styledRun(
                        run.text,
                        style: style(from: run, paragraph: paragraph),
                        pageHeight: pageHeight
                    )
                }
                if paragraphIndex < content.paragraphs.count - 1 {
                    let newlineStyle = paragraph.runs.last.map {
                        style(from: $0, paragraph: paragraph)
                    } ?? defaults
                    result += styledRun("\n", style: newlineStyle, pageHeight: pageHeight)
                }
            }
            let paragraphEnd = result.endIndex
            if paragraphStart < paragraphEnd {
                let range = paragraphStart..<paragraphEnd
                result[range].albumParagraphStyle = AlbumParagraphStyleValue(
                    alignment: paragraph.alignment,
                    lineSpacing: paragraph.lineSpacing
                )
                result[range].alignment = attributedAlignment(paragraph.alignment)
                result[range].lineHeight = .multiple(factor: CGFloat(paragraph.lineSpacing))
            }
        }
        return result
    }

    static func content(
        from text: AttributedString,
        defaults: TextStyleDefaults
    ) -> TextBoxContent {
        var paragraphs: [TextParagraph] = []
        var current = TextParagraph(
            alignment: defaults.alignment,
            lineSpacing: defaults.lineSpacing
        )

        for run in text.runs {
            let style = run[AlbumTextStyleAttribute.self] ?? defaults
            let paragraphStyle = run[AlbumParagraphStyleAttribute.self]
                ?? AlbumParagraphStyleValue(
                    alignment: style.alignment,
                    lineSpacing: style.lineSpacing
                )
            let value = String(text.characters[run.range])
            let pieces = value.split(separator: "\n", omittingEmptySubsequences: false)
            for pieceIndex in pieces.indices {
                current.alignment = paragraphStyle.alignment
                current.lineSpacing = paragraphStyle.lineSpacing
                let piece = String(pieces[pieceIndex])
                if !piece.isEmpty {
                    appendRun(piece, style: style, to: &current.runs)
                }
                if pieceIndex < pieces.count - 1 {
                    paragraphs.append(current)
                    current = TextParagraph(
                        alignment: paragraphStyle.alignment,
                        lineSpacing: paragraphStyle.lineSpacing
                    )
                }
            }
        }
        paragraphs.append(current)
        return TextBoxContent(paragraphs: paragraphs)
    }

    static func typingAttributes(
        for style: TextStyleDefaults,
        pageHeight: Double
    ) -> AttributeContainer {
        var attributes = AttributeContainer()
        attributes.albumTextStyle = style
        attributes.albumParagraphStyle = AlbumParagraphStyleValue(
            alignment: style.alignment,
            lineSpacing: style.lineSpacing
        )
        attributes.font = font(for: style, pageHeight: pageHeight)
        attributes.foregroundColor = style.color.swiftUIColor
        attributes.alignment = attributedAlignment(style.alignment)
        attributes.lineHeight = .multiple(factor: CGFloat(style.lineSpacing))
        return attributes
    }

    static func font(for style: TextStyleDefaults, pageHeight: Double) -> Font {
        let design: Font.Design
        switch BuiltInTextFontCatalog.definition(id: style.fontID)?.design ?? .standard {
        case .standard: design = .default
        case .serif: design = .serif
        case .rounded: design = .rounded
        case .monospaced: design = .monospaced
        }
        return Font.system(
            size: CGFloat(max(1, style.relativeFontSize * pageHeight)),
            weight: style.weight == .bold ? .bold : .regular,
            design: design
        )
        .italic(style.isItalic)
    }

    private static func styledRun(
        _ text: String,
        style: TextStyleDefaults,
        pageHeight: Double
    ) -> AttributedString {
        var value = AttributedString(text)
        value.albumTextStyle = style
        value.font = font(for: style, pageHeight: pageHeight)
        value.foregroundColor = style.color.swiftUIColor
        return value
    }

    private static func style(
        from run: TextRun,
        paragraph: TextParagraph
    ) -> TextStyleDefaults {
        TextStyleDefaults(
            fontID: run.fontID,
            relativeFontSize: run.relativeFontSize,
            weight: run.weight,
            isItalic: run.isItalic,
            color: run.color,
            alignment: paragraph.alignment,
            lineSpacing: paragraph.lineSpacing
        )
    }

    private static func appendRun(
        _ text: String,
        style: TextStyleDefaults,
        to runs: inout [TextRun]
    ) {
        if let last = runs.last,
           last.fontID == style.fontID,
           last.relativeFontSize == style.relativeFontSize,
           last.weight == style.weight,
           last.isItalic == style.isItalic,
           last.color == style.color {
            runs[runs.count - 1].text += text
        } else {
            runs.append(TextRun(text: text, style: style))
        }
    }

    fileprivate static func attributedAlignment(
        _ alignment: TextAlignmentValue
    ) -> AttributedString.TextAlignment {
        switch alignment {
        case .leading: .left
        case .center: .center
        case .trailing: .right
        // SwiftUI iOS 26 exposes no justified case. Existing persisted values
        // stay intact in the domain and use a leading editing preview until a
        // documented public rendering solution is available (3:TXA-001...003).
        case .justified: .left
        }
    }
}

struct AlbumTextEditorView: View {
    private static let placeholder = "Votre texte"
    private static let referenceHeight = AlbumPhotoConstants.canonicalPageHeight

    let request: TextEditingRequest
    let onCancel: () -> Void
    let onCommit: (TextBoxContent, TextStyleDefaults, Double) -> Void

    @State private var text: AttributedString
    @State private var selection: AttributedTextSelection
    @State private var typingDefaults: TextStyleDefaults
    @State private var opacity: Double
    @State private var showsCharacterLimit = false
    @FocusState private var editorIsFocused: Bool

    init(
        request: TextEditingRequest,
        onCancel: @escaping () -> Void,
        onCommit: @escaping (TextBoxContent, TextStyleDefaults, Double) -> Void
    ) {
        self.request = request
        self.onCancel = onCancel
        self.onCommit = onCommit
        let defaults = request.original.typingDefaults
        let source = request.original.content.plainText.isEmpty
            ? TextBoxContent(paragraphs: [TextParagraph(
                alignment: defaults.alignment,
                lineSpacing: defaults.lineSpacing,
                runs: [TextRun(text: Self.placeholder, style: defaults)]
            )])
            : request.original.content
        let attributed = AlbumTextAttributedBridge.attributedString(
            from: source,
            defaults: defaults,
            pageHeight: Self.referenceHeight
        )
        _text = State(initialValue: attributed)
        _selection = State(initialValue: AttributedTextSelection())
        _typingDefaults = State(initialValue: defaults)
        _opacity = State(initialValue: request.original.opacity)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextEditor(text: $text, selection: $selection)
                    .attributedTextFormattingDefinition(AlbumTextFormattingDefinition())
                    .textInputFormattingControlVisibility(.hidden, for: .all)
                    .focused($editorIsFocused)
                    .scrollDismissesKeyboard(.interactively)
                    .padding(12)
                    .accessibilityLabel("Contenu de la zone de texte")
                    .onChange(of: text) { oldValue, newValue in
                        guard newValue.characters.count > 1_000 else { return }
                        let limited = limitedText(oldValue: oldValue, newValue: newValue)
                        text = limited.value
                        selection = AttributedTextSelection(
                            insertionPoint: text.characters.index(
                                text.startIndex,
                                offsetBy: limited.insertionOffset
                            ),
                            typingAttributes: AlbumTextAttributedBridge.typingAttributes(
                                for: typingDefaults,
                                pageHeight: Self.referenceHeight
                            )
                        )
                        showsCharacterLimit = true
                    }

                Divider()

                formattingBar

                HStack {
                    Text("\(text.characters.count) / 1 000 caractères")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Label(
                        "Les liens et pièces jointes collés sont convertis en texte.",
                        systemImage: "doc.plaintext"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .navigationTitle(request.isNew ? "Ajouter du texte" : "Modifier le texte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Terminer") { commit() }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            if request.original.content.plainText.isEmpty {
                selection = AttributedTextSelection(range: text.startIndex..<text.endIndex)
            } else {
                selection = AttributedTextSelection(
                    insertionPoint: text.endIndex,
                    typingAttributes: AlbumTextAttributedBridge.typingAttributes(
                        for: typingDefaults,
                        pageHeight: Self.referenceHeight
                    )
                )
            }
            editorIsFocused = true
        }
        .alert("Limite atteinte", isPresented: $showsCharacterLimit) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Une zone de texte est limitée à 1 000 caractères.")
        }
    }

    private var formattingBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                fontMenu
                sizeMenu

                Button("Gras", systemImage: "bold") {
                    applyCharacterStyle { $0.weight = $0.weight == .bold ? .regular : .bold }
                }
                .tint(currentStyle.weight == .bold ? Color.accentColor : nil)

                Button("Italique", systemImage: "italic") {
                    applyCharacterStyle { $0.isItalic.toggle() }
                }
                .tint(currentStyle.isItalic ? Color.accentColor : nil)

                colorMenu
                alignmentMenu
                lineSpacingMenu
                opacityMenu
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    private var fontMenu: some View {
        Menu("Police", systemImage: "textformat") {
            ForEach(BuiltInTextFontCatalog.manifest) { font in
                Button(font.localizedName) {
                    applyCharacterStyle { $0.fontID = font.id }
                }
            }
        }
        .accessibilityLabel("Police du texte")
    }

    private var sizeMenu: some View {
        Menu("Taille", systemImage: "textformat.size") {
            ForEach([8, 12, 18, 24, 36, 48, 72, 96], id: \.self) { points in
                Button("\(points) points") {
                    applyCharacterStyle {
                        $0.relativeFontSize = Double(points) / Self.referenceHeight
                    }
                }
            }
        }
        .accessibilityLabel("Taille du texte")
    }

    private var colorMenu: some View {
        Menu("Couleur", systemImage: "paintpalette") {
            colorButton("Noir", color: .black)
            colorButton("Blanc", color: .white)
            colorButton("Rouge", color: SRGBAColor(red: 0.85, green: 0.12, blue: 0.12))
            colorButton("Orange", color: SRGBAColor(red: 0.95, green: 0.45, blue: 0.05))
            colorButton("Vert", color: SRGBAColor(red: 0.12, green: 0.55, blue: 0.24))
            colorButton("Bleu", color: SRGBAColor(red: 0.10, green: 0.35, blue: 0.90))
        }
        .accessibilityLabel("Couleur du texte")
    }

    private func colorButton(_ title: String, color: SRGBAColor) -> some View {
        Button {
            applyCharacterStyle { $0.color = color }
        } label: {
            Label(title, systemImage: "circle.fill")
                .foregroundStyle(color.swiftUIColor)
        }
    }

    private var alignmentMenu: some View {
        Menu("Alignement", systemImage: "text.alignleft") {
            Button("Gauche", systemImage: "text.alignleft") {
                applyParagraphStyle(alignment: .leading)
            }
            Button("Centré", systemImage: "text.aligncenter") {
                applyParagraphStyle(alignment: .center)
            }
            Button("Droite", systemImage: "text.alignright") {
                applyParagraphStyle(alignment: .trailing)
            }
        }
        .accessibilityLabel("Alignement des paragraphes")
    }

    private var lineSpacingMenu: some View {
        Menu("Interligne", systemImage: "line.3.horizontal") {
            ForEach([0.8, 1, 1.2, 1.5, 2], id: \.self) { spacing in
                Button(spacing.formatted(.number.precision(.fractionLength(1)))) {
                    applyParagraphStyle(lineSpacing: spacing)
                }
            }
        }
        .accessibilityLabel("Interligne des paragraphes")
    }

    private var opacityMenu: some View {
        Menu("Opacité", systemImage: "circle.lefthalf.filled") {
            ForEach([0.1, 0.25, 0.5, 0.75, 1], id: \.self) { value in
                Button(value.formatted(.percent.precision(.fractionLength(0)))) {
                    opacity = value
                }
            }
        }
        .accessibilityLabel("Opacité de la zone de texte")
        .accessibilityValue(opacity.formatted(.percent.precision(.fractionLength(0))))
    }

    private var currentStyle: TextStyleDefaults {
        selection.typingAttributes(in: text)[AlbumTextStyleAttribute.self]
            ?? typingDefaults
    }

    private var selectionIsInsertionPoint: Bool {
        if case .insertionPoint = selection.indices(in: text) { return true }
        return false
    }

    private func applyCharacterStyle(
        _ update: (inout TextStyleDefaults) -> Void
    ) {
        text.transformAttributes(in: &selection) { attributes in
            var style = attributes[AlbumTextStyleAttribute.self] ?? typingDefaults
            update(&style)
            attributes[AlbumTextStyleAttribute.self] = style
            attributes.font = AlbumTextAttributedBridge.font(
                for: style,
                pageHeight: Self.referenceHeight
            )
            attributes.foregroundColor = style.color.swiftUIColor
        }
        if selectionIsInsertionPoint { update(&typingDefaults) }
    }

    private func applyParagraphStyle(
        alignment: TextAlignmentValue? = nil,
        lineSpacing: Double? = nil
    ) {
        text.transformAttributes(in: &selection) { attributes in
            let current = attributes[AlbumParagraphStyleAttribute.self]
                ?? AlbumParagraphStyleValue(
                    alignment: typingDefaults.alignment,
                    lineSpacing: typingDefaults.lineSpacing
                )
            let changed = AlbumParagraphStyleValue(
                alignment: alignment ?? current.alignment,
                lineSpacing: lineSpacing ?? current.lineSpacing
            )
            attributes[AlbumParagraphStyleAttribute.self] = changed
            attributes.alignment = AlbumTextAttributedBridge.attributedAlignment(
                changed.alignment
            )
            attributes.lineHeight = .multiple(factor: CGFloat(changed.lineSpacing))
        }
        if selectionIsInsertionPoint {
            if let alignment { typingDefaults.alignment = alignment }
            if let lineSpacing { typingDefaults.lineSpacing = lineSpacing }
        }
    }

    private func commit() {
        let keepsPlaceholder = request.original.content.plainText.isEmpty
            && String(text.characters) == Self.placeholder
        let content = keepsPlaceholder
            ? TextBoxContent()
            : AlbumTextAttributedBridge.content(from: text, defaults: typingDefaults)
        onCommit(content, typingDefaults, opacity)
    }

    private func limitedText(
        oldValue: AttributedString,
        newValue: AttributedString
    ) -> (value: AttributedString, insertionOffset: Int) {
        let oldCharacters = Array(oldValue.characters)
        let newCharacters = Array(newValue.characters)
        var prefixCount = 0
        while prefixCount < min(oldCharacters.count, newCharacters.count),
              oldCharacters[prefixCount] == newCharacters[prefixCount] {
            prefixCount += 1
        }

        var suffixCount = 0
        while suffixCount < oldCharacters.count - prefixCount,
              suffixCount < newCharacters.count - prefixCount,
              oldCharacters[oldCharacters.count - 1 - suffixCount]
                == newCharacters[newCharacters.count - 1 - suffixCount] {
            suffixCount += 1
        }

        let replacedCount = oldCharacters.count - prefixCount - suffixCount
        let insertedCount = newCharacters.count - prefixCount - suffixCount
        let unchangedCount = oldCharacters.count - replacedCount
        let acceptedInsertedCount = max(0, min(insertedCount, 1_000 - unchangedCount))

        var result = newValue
        let acceptedEnd = result.characters.index(
            result.startIndex,
            offsetBy: prefixCount + acceptedInsertedCount
        )
        let insertedEnd = result.characters.index(
            result.startIndex,
            offsetBy: prefixCount + insertedCount
        )
        if acceptedEnd < insertedEnd {
            result.removeSubrange(acceptedEnd..<insertedEnd)
        }
        return (result, prefixCount + acceptedInsertedCount)
    }
}
