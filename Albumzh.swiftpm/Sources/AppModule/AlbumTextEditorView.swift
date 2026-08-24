import AlbumPhotoCore
import Foundation
import SwiftUI
import UIKit

struct TextEditingRequest: Identifiable, Equatable {
    let sessionID: UUID
    let pageID: UUID
    let original: TextBoxElement
    let isNew: Bool
    let pageBackground: BackgroundSelection
    let previewPageHeight: Double

    var id: UUID { sessionID }
}

enum AlbumTextPresentationMetrics {
    static let fallbackPreviewPageHeight = 600.0
}

struct AlbumTextColorOption: Identifiable {
    let title: String
    let color: SRGBAColor

    var id: String { title }

    static let all: [AlbumTextColorOption] = [
        AlbumTextColorOption(title: "Noir", color: .black),
        AlbumTextColorOption(title: "Blanc", color: .white),
        AlbumTextColorOption(
            title: "Rouge",
            color: SRGBAColor(red: 0.85, green: 0.12, blue: 0.12)
        ),
        AlbumTextColorOption(
            title: "Orange",
            color: SRGBAColor(red: 0.95, green: 0.45, blue: 0.05)
        ),
        AlbumTextColorOption(
            title: "Vert",
            color: SRGBAColor(red: 0.12, green: 0.55, blue: 0.24)
        ),
        AlbumTextColorOption(
            title: "Bleu",
            color: SRGBAColor(red: 0.10, green: 0.35, blue: 0.90)
        )
    ]
}

struct AlbumTextColorLabel: View {
    let option: AlbumTextColorOption
    var isSelected = false

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(option.color.swiftUIColor)
                .frame(width: 20, height: 20)
                .overlay {
                    Circle()
                        .stroke(.primary.opacity(0.35), lineWidth: 1)
                }
            Text(option.title)
            Spacer(minLength: 8)
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }
        }
        .padding(.horizontal, 8)
        .background(
            isSelected ? Color.accentColor.opacity(0.12) : Color.clear,
            in: RoundedRectangle(cornerRadius: 8)
        )
        .accessibilityElement(children: .combine)
        .accessibilityValue(isSelected ? "Sélectionné" : "")
    }
}

struct AlbumTextMenuChoiceLabel: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(isSelected ? "Sélectionné" : "")
    }
}

struct AlbumTextToggleLabel: View {
    let title: String
    let systemImage: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Label(title, systemImage: systemImage)
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(isSelected ? "Sélectionné" : "Non sélectionné")
    }
}

struct AlbumTextAlignmentChoice: Identifiable {
    let title: String
    let value: TextAlignmentValue

    var id: TextAlignmentValue { value }

    static let all = [
        AlbumTextAlignmentChoice(title: "Gauche", value: .leading),
        AlbumTextAlignmentChoice(title: "Centré", value: .center),
        AlbumTextAlignmentChoice(title: "Droite", value: .trailing),
        AlbumTextAlignmentChoice(title: "Justifié", value: .justified)
    ]
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
    struct AlbumTextModelAttributes: AttributeScope {
        let albumTextStyle: AlbumTextStyleAttribute
        let albumParagraphStyle: AlbumParagraphStyleAttribute
    }

    struct AlbumTextAttributes: AttributeScope {
        let model: AlbumTextModelAttributes
        let font: AttributeScopes.SwiftUIAttributes.FontAttribute
        let foregroundColor: AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute
        let alignment: AttributeScopes.CoreTextAttributes.TextAlignmentAttribute
        let lineHeight: AttributeScopes.CoreTextAttributes.LineHeightAttribute
    }
}

private extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(
        dynamicMember keyPath: KeyPath<AttributeScopes.AlbumTextModelAttributes, T>
    ) -> T {
        self[T.self]
    }
}

private struct AlbumTextFormattingDefinition: AttributedTextFormattingDefinition {
    typealias Scope = AttributeScopes.AlbumTextAttributes
    let pageHeight: Double
    let fallbackStyle: TextStyleDefaults

    var body: some AttributedTextFormattingDefinition<Scope> {
        ApplyAlbumFont(pageHeight: pageHeight, fallbackStyle: fallbackStyle)
        ApplyAlbumForegroundColor(fallbackStyle: fallbackStyle)
        ApplyAlbumAlignment(fallbackStyle: fallbackStyle)
        ApplyAlbumLineHeight(fallbackStyle: fallbackStyle)
    }
}

private struct ApplyAlbumFont: AttributedTextValueConstraint {
    typealias Scope = AlbumTextFormattingDefinition.Scope
    typealias AttributeKey = AttributeScopes.SwiftUIAttributes.FontAttribute
    let pageHeight: Double
    let fallbackStyle: TextStyleDefaults

    func constrain(_ container: inout Attributes) {
        let style = container.albumTextStyle ?? fallbackStyle
        container.font = AlbumTextAttributedBridge.font(
            for: style,
            pageHeight: pageHeight
        )
    }
}

private struct ApplyAlbumForegroundColor: AttributedTextValueConstraint {
    typealias Scope = AlbumTextFormattingDefinition.Scope
    typealias AttributeKey = AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute
    let fallbackStyle: TextStyleDefaults

    func constrain(_ container: inout Attributes) {
        let style = container.albumTextStyle ?? fallbackStyle
        container.foregroundColor = style.color.swiftUIColor
    }
}

private struct ApplyAlbumAlignment: AttributedTextValueConstraint {
    typealias Scope = AlbumTextFormattingDefinition.Scope
    typealias AttributeKey = AttributeScopes.CoreTextAttributes.TextAlignmentAttribute
    let fallbackStyle: TextStyleDefaults

    func constrain(_ container: inout Attributes) {
        let defaults = container.albumTextStyle ?? fallbackStyle
        let style = container.albumParagraphStyle ?? AlbumParagraphStyleValue(
            alignment: defaults.alignment,
            lineSpacing: defaults.lineSpacing
        )
        container.alignment = AlbumTextAttributedBridge.attributedAlignment(style.alignment)
    }
}

private struct ApplyAlbumLineHeight: AttributedTextValueConstraint {
    typealias Scope = AlbumTextFormattingDefinition.Scope
    typealias AttributeKey = AttributeScopes.CoreTextAttributes.LineHeightAttribute
    let fallbackStyle: TextStyleDefaults

    func constrain(_ container: inout Attributes) {
        let defaults = container.albumTextStyle ?? fallbackStyle
        let style = container.albumParagraphStyle ?? AlbumParagraphStyleValue(
            alignment: defaults.alignment,
            lineSpacing: defaults.lineSpacing
        )
        container.lineHeight = AlbumTextAttributedBridge.attributedLineHeight(
            style.lineSpacing
        )
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
                result[range].lineHeight = attributedLineHeight(paragraph.lineSpacing)
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
            let value = TextEditingPrototype.sanitizedPlainText(
                String(text.characters[run.range])
            )
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
        attributes.lineHeight = attributedLineHeight(style.lineSpacing)
        return attributes
    }

    static func font(for style: TextStyleDefaults, pageHeight: Double) -> Font {
        let pointSize = CGFloat(max(
            1,
            TextPrototypeEngine.renderedFontSize(
                relativeFontSize: style.relativeFontSize,
                pageHeight: pageHeight
            )
        ))
        let fontDesign = BuiltInTextFontCatalog.definition(id: style.fontID)?.design
            ?? .standard
        let design: Font.Design
        switch fontDesign {
        case .standard: design = .default
        case .serif: design = .serif
        case .rounded: design = .rounded
        case .monospaced: design = .monospaced
        }

        if fontDesign == .rounded {
            let weight: UIFont.Weight = style.weight == .bold ? .bold : .regular
            let systemDescriptor = UIFont.systemFont(
                ofSize: pointSize,
                weight: weight
            ).fontDescriptor
            let roundedDescriptor = systemDescriptor.withDesign(.rounded)
                ?? systemDescriptor
            let matrix = CGAffineTransform(
                a: 1.12,
                b: 0,
                c: style.isItalic ? 0.22 : 0,
                d: 1,
                tx: 0,
                ty: 0
            )
            return Font(UIFont(
                descriptor: roundedDescriptor.withMatrix(matrix),
                size: pointSize
            ))
        }

        return Font.system(
            size: pointSize,
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
        // SwiftUI iOS 26 exposes no justified case. The editable surface keeps
        // a leading preview for this one value; the shared page renderer uses
        // public TextKit and renders the persisted paragraph as justified.
        case .justified: .left
        }
    }

    fileprivate static func attributedLineHeight(
        _ lineSpacing: Double
    ) -> AttributedString.LineHeight {
        // A factor of exactly 1 creates a point-size line box and can crop
        // descenders. The native normal metric includes ascent and descent;
        // explicit user spacing keeps the requested ratio.
        if abs(lineSpacing - 1) < 0.000_001 { return .normal }
        return .multiple(factor: CGFloat(lineSpacing))
    }
}

struct AlbumTextEditorView: View {
    private static let placeholder = "Votre texte"

    let request: TextEditingRequest
    let imageCache: PhotoImageCache
    let onCancel: () async -> Void
    let onCheckpoint: (TextBoxContent, TextStyleDefaults, Double) async -> Void
    let onCommit: (TextBoxContent, TextStyleDefaults, Double) async -> Void

    @State private var text: AttributedString
    @State private var selection: AttributedTextSelection
    @State private var typingDefaults: TextStyleDefaults
    @State private var opacity: Double
    @State private var showsCharacterLimit = false
    @State private var characterLimitRollback: AttributedString?
    @State private var showsColorPalette = false
    @State private var retainedSelection: AttributedTextSelection?
    @State private var retainedSelectionText: String?
    @State private var checkpointTask: Task<Void, Never>?
    @State private var isResolving = false
    @FocusState private var editorIsFocused: Bool

    init(
        request: TextEditingRequest,
        imageCache: PhotoImageCache,
        onCancel: @escaping () async -> Void,
        onCheckpoint: @escaping (
            TextBoxContent,
            TextStyleDefaults,
            Double
        ) async -> Void,
        onCommit: @escaping (
            TextBoxContent,
            TextStyleDefaults,
            Double
        ) async -> Void
    ) {
        self.request = request
        self.imageCache = imageCache
        self.onCancel = onCancel
        self.onCheckpoint = onCheckpoint
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
            pageHeight: request.previewPageHeight
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
                    .attributedTextFormattingDefinition(
                        AlbumTextFormattingDefinition(
                            pageHeight: request.previewPageHeight,
                            fallbackStyle: typingDefaults
                        )
                    )
                    .textInputFormattingControlVisibility(.hidden, for: .all)
                    .scrollContentBackground(.hidden)
                    .focused($editorIsFocused)
                    .scrollDismissesKeyboard(.interactively)
                    .padding(12)
                    .opacity(opacity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        AlbumPageBackground(
                            selection: request.pageBackground,
                            imageCache: imageCache,
                            maximumPixelSize: 1_200
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .allowsHitTesting(false)
                    }
                    .clipped()
                    .accessibilityLabel("Contenu de la zone de texte")
                    .onChange(of: text) { oldValue, newValue in
                        handleTextChange(oldValue: oldValue, newValue: newValue)
                    }
                    .onChange(of: typingDefaults) { _, _ in scheduleCheckpoint() }
                    .onChange(of: opacity) { _, _ in scheduleCheckpoint() }
                    .onChange(of: selection) { _, newValue in
                        if isInsertionPoint(newValue) {
                            if editorIsFocused {
                                retainedSelection = nil
                                retainedSelectionText = nil
                            }
                        } else {
                            retainSelection(newValue)
                        }
                    }

                Divider()

                formattingBar

                HStack {
                    Text("\(text.characters.count) / 1 000 caractères")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Label(
                        "Le contenu collé est converti en texte brut.",
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
                    Button("Annuler") { cancel() }
                        .disabled(isResolving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Terminer") { commit() }
                        .buttonStyle(.borderedProminent)
                        .disabled(isResolving)
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
                        pageHeight: request.previewPageHeight
                    )
                )
            }
            editorIsFocused = true
        }
        .onChange(of: editorIsFocused) { wasFocused, isFocused in
            if wasFocused, !isFocused {
                retainSelectionForFormatting()
                flushCheckpoint()
            } else if !wasFocused, isFocused, let retainedSelection = validRetainedSelection {
                selection = retainedSelection
            }
        }
        .onDisappear { checkpointTask?.cancel() }
        .alert("Limite atteinte", isPresented: $showsCharacterLimit) {
            Button("Annuler", role: .cancel) {
                restoreCharacterLimitRollback()
            }
            Button("Conserver 1 000 caractères") {
                characterLimitRollback = nil
                scheduleCheckpoint()
            }
        } message: {
            Text(
                "Une zone de texte est limitée à 1 000 caractères. "
                    + "Vous pouvez conserver le texte tronqué ou annuler la modification."
            )
        }
    }

    private var formattingBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                formattingScopeLabel("Sélection", systemImage: "character.cursor.ibeam")
                if !editorIsFocused, validRetainedSelection != nil {
                    Label("Sélection conservée", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                        .fixedSize()
                }
                fontMenu
                sizeMenu

                Button {
                    applyCharacterStyle { $0.weight = $0.weight == .bold ? .regular : .bold }
                } label: {
                    AlbumTextToggleLabel(
                        title: "Gras",
                        systemImage: "bold",
                        isSelected: currentStyle.weight == .bold
                    )
                }
                .tint(currentStyle.weight == .bold ? Color.accentColor : nil)

                Button {
                    applyCharacterStyle { $0.isItalic.toggle() }
                } label: {
                    AlbumTextToggleLabel(
                        title: "Italique",
                        systemImage: "italic",
                        isSelected: currentStyle.isItalic
                    )
                }
                .tint(currentStyle.isItalic ? Color.accentColor : nil)

                colorMenu
                formattingScopeDivider
                formattingScopeLabel("Paragraphe", systemImage: "paragraph")
                alignmentMenu
                lineSpacingMenu
                formattingScopeDivider
                formattingScopeLabel("Zone", systemImage: "rectangle.dashed")
                opacityMenu

                Button(
                    editorIsFocused ? "Masquer le clavier" : "Afficher le clavier",
                    systemImage: editorIsFocused
                        ? "keyboard.chevron.compact.down" : "keyboard"
                ) {
                    toggleKeyboard()
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    private func formattingScopeLabel(
        _ title: String,
        systemImage: String
    ) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .fixedSize()
    }

    private var formattingScopeDivider: some View {
        Divider()
            .frame(height: 32)
            .accessibilityHidden(true)
    }

    private var fontMenu: some View {
        Menu {
            ForEach(BuiltInTextFontCatalog.manifest) { font in
                Button {
                    applyCharacterStyle { $0.fontID = font.id }
                } label: {
                    AlbumTextMenuChoiceLabel(
                        title: font.localizedName,
                        isSelected: currentStyle.fontID == font.id
                    )
                }
            }
        } label: {
            Label("Police", systemImage: "textformat")
        }
        .accessibilityLabel("Police du texte")
        .accessibilityValue(currentFontName)
    }

    private var sizeMenu: some View {
        Menu {
            ForEach([8, 12, 18, 24, 36, 48, 72, 96], id: \.self) { points in
                Button {
                    applyCharacterStyle {
                        $0.relativeFontSize = Double(points)
                            / AlbumPhotoConstants.canonicalPageHeight
                    }
                } label: {
                    AlbumTextMenuChoiceLabel(
                        title: "\(points) points",
                        isSelected: currentFontSize == points
                    )
                }
            }
        } label: {
            Label("Taille", systemImage: "textformat.size")
        }
        .accessibilityLabel("Taille du texte")
        .accessibilityValue("\(currentFontSize) points")
    }

    private var colorMenu: some View {
        Button {
            retainSelectionForFormatting()
            showsColorPalette = true
        } label: {
            Label("Couleur", systemImage: "paintpalette")
        }
        .popover(isPresented: $showsColorPalette) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Couleur du texte")
                    .font(.headline)
                    .padding(.bottom, 4)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 6) {
                        ForEach(AlbumTextColorOption.all) { option in
                            Button {
                                applyCharacterStyle { $0.color = option.color }
                                showsColorPalette = false
                            } label: {
                                AlbumTextColorLabel(
                                    option: option,
                                    isSelected: currentStyle.color == option.color
                                )
                                    .frame(
                                        maxWidth: .infinity,
                                        minHeight: 44,
                                        alignment: .leading
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 320)
            }
            .padding(14)
            .frame(minWidth: 190)
            .presentationCompactAdaptation(.popover)
        }
        .accessibilityLabel("Couleur du texte")
        .accessibilityValue(currentColorName)
    }

    private var alignmentMenu: some View {
        Menu {
            ForEach(AlbumTextAlignmentChoice.all) { choice in
                Button {
                    applyParagraphStyle(alignment: choice.value)
                } label: {
                    AlbumTextMenuChoiceLabel(
                        title: choice.title,
                        isSelected: currentParagraphStyle.alignment == choice.value
                    )
                }
            }
        } label: {
            Label("Alignement", systemImage: "text.alignleft")
        }
        .accessibilityLabel("Alignement des paragraphes")
        .accessibilityValue(currentAlignmentName)
    }

    private var lineSpacingMenu: some View {
        Menu {
            ForEach([0.8, 1, 1.2, 1.5, 2], id: \.self) { spacing in
                let title = spacing.formatted(.number.precision(.fractionLength(1)))
                Button {
                    applyParagraphStyle(lineSpacing: spacing)
                } label: {
                    AlbumTextMenuChoiceLabel(
                        title: title,
                        isSelected: abs(currentParagraphStyle.lineSpacing - spacing)
                            < 0.000_001
                    )
                }
            }
        } label: {
            Label("Interligne", systemImage: "line.3.horizontal")
        }
        .accessibilityLabel("Interligne des paragraphes")
        .accessibilityValue(currentLineSpacingName)
    }

    private var opacityMenu: some View {
        Menu {
            ForEach([0.1, 0.25, 0.5, 0.75, 1], id: \.self) { value in
                let title = value.formatted(.percent.precision(.fractionLength(0)))
                Button {
                    opacity = value
                } label: {
                    AlbumTextMenuChoiceLabel(
                        title: title,
                        isSelected: abs(opacity - value) < 0.000_001
                    )
                }
            }
        } label: {
            Label("Opacité", systemImage: "circle.lefthalf.filled")
        }
        .accessibilityLabel("Opacité de la zone de texte")
        .accessibilityValue(currentOpacityName)
    }

    private var currentFontName: String {
        BuiltInTextFontCatalog.definition(id: currentStyle.fontID)?.localizedName
            ?? "Système"
    }

    private var currentFontSize: Int {
        Int((currentStyle.relativeFontSize
            * AlbumPhotoConstants.canonicalPageHeight).rounded())
    }

    private var currentColorName: String {
        AlbumTextColorOption.all.first { $0.color == currentStyle.color }?.title
            ?? "Personnalisée"
    }

    private var currentParagraphStyle: AlbumParagraphStyleValue {
        formattingSelection.typingAttributes(in: text)[AlbumParagraphStyleAttribute.self]
            ?? AlbumParagraphStyleValue(
                alignment: typingDefaults.alignment,
                lineSpacing: typingDefaults.lineSpacing
            )
    }

    private var currentAlignmentName: String {
        AlbumTextAlignmentChoice.all.first {
            $0.value == currentParagraphStyle.alignment
        }?.title
            ?? "Justifié"
    }

    private var currentLineSpacingName: String {
        currentParagraphStyle.lineSpacing.formatted(
            .number.precision(.fractionLength(1))
        )
    }

    private var currentOpacityName: String {
        opacity.formatted(.percent.precision(.fractionLength(0)))
    }

    private var currentStyle: TextStyleDefaults {
        formattingSelection.typingAttributes(in: text)[AlbumTextStyleAttribute.self]
            ?? typingDefaults
    }

    private var formattingSelection: AttributedTextSelection {
        if isInsertionPoint(selection), let retainedSelection = validRetainedSelection {
            return retainedSelection
        }
        return selection
    }

    private var validRetainedSelection: AttributedTextSelection? {
        guard retainedSelectionText == String(text.characters) else { return nil }
        return retainedSelection
    }

    private func isInsertionPoint(_ candidate: AttributedTextSelection) -> Bool {
        if case .insertionPoint = candidate.indices(in: text) { return true }
        return false
    }

    private func applyCharacterStyle(
        _ update: (inout TextStyleDefaults) -> Void
    ) {
        var targetSelection = formattingSelection
        let targetsTypingDefaults = isInsertionPoint(targetSelection)
        text.transformAttributes(in: &targetSelection) { attributes in
            var style = attributes[AlbumTextStyleAttribute.self] ?? typingDefaults
            update(&style)
            attributes[AlbumTextStyleAttribute.self] = style
            attributes.font = AlbumTextAttributedBridge.font(
                for: style,
                pageHeight: request.previewPageHeight
            )
            attributes.foregroundColor = style.color.swiftUIColor
        }
        if targetsTypingDefaults {
            update(&typingDefaults)
        } else {
            retainSelection(targetSelection)
            selection = targetSelection
        }
    }

    private func applyParagraphStyle(
        alignment: TextAlignmentValue? = nil,
        lineSpacing: Double? = nil
    ) {
        var targetSelection = formattingSelection
        let targetsTypingDefaults = isInsertionPoint(targetSelection)
        text.transformAttributes(in: &targetSelection) { attributes in
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
            attributes.lineHeight = AlbumTextAttributedBridge.attributedLineHeight(
                changed.lineSpacing
            )
        }
        if targetsTypingDefaults {
            if let alignment { typingDefaults.alignment = alignment }
            if let lineSpacing { typingDefaults.lineSpacing = lineSpacing }
        } else {
            retainSelection(targetSelection)
            selection = targetSelection
        }
    }

    private func retainSelectionForFormatting() {
        guard !isInsertionPoint(selection) else { return }
        retainSelection(selection)
    }

    private func retainSelection(_ candidate: AttributedTextSelection) {
        retainedSelection = candidate
        retainedSelectionText = String(text.characters)
    }

    private func toggleKeyboard() {
        if editorIsFocused {
            retainSelectionForFormatting()
            editorIsFocused = false
        } else {
            if let retainedSelection = validRetainedSelection {
                selection = retainedSelection
            }
            editorIsFocused = true
        }
    }

    private func commit() {
        guard !isResolving else { return }
        isResolving = true
        checkpointTask?.cancel()
        let values = checkpointValues
        Task { @MainActor in
            await onCommit(values.content, values.defaults, values.opacity)
            isResolving = false
        }
    }

    private func cancel() {
        guard !isResolving else { return }
        isResolving = true
        checkpointTask?.cancel()
        Task { @MainActor in
            await onCancel()
            isResolving = false
        }
    }

    private func restoreCharacterLimitRollback() {
        guard let rollback = characterLimitRollback else { return }
        checkpointTask?.cancel()
        characterLimitRollback = nil
        text = rollback
        selection = AttributedTextSelection(
            insertionPoint: text.endIndex,
            typingAttributes: AlbumTextAttributedBridge.typingAttributes(
                for: typingDefaults,
                pageHeight: request.previewPageHeight
            )
        )
    }

    private func handleTextChange(
        oldValue: AttributedString,
        newValue: AttributedString
    ) {
        let charactersChanged = String(oldValue.characters) != String(newValue.characters)
        if charactersChanged {
            retainedSelection = nil
            retainedSelectionText = nil
        }
        guard newValue.characters.count > 1_000 else {
            scheduleCheckpoint()
            return
        }
        if characterLimitRollback == nil {
            characterLimitRollback = oldValue
        }
        let limited = limitedText(oldValue: oldValue, newValue: newValue)
        text = limited.value
        selection = AttributedTextSelection(
            insertionPoint: text.characters.index(
                text.startIndex,
                offsetBy: limited.insertionOffset
            ),
            typingAttributes: AlbumTextAttributedBridge.typingAttributes(
                for: typingDefaults,
                pageHeight: request.previewPageHeight
            )
        )
        showsCharacterLimit = true
    }

    /// The task is replaced on every local change, so exactly one checkpoint
    /// survives 750 ms of inactivity (3:TBX-022).
    private func scheduleCheckpoint() {
        checkpointTask?.cancel()
        checkpointTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: 750_000_000)
            } catch {
                return
            }
            guard !Task.isCancelled, !isResolving else { return }
            await persistCheckpoint()
        }
    }

    private func flushCheckpoint() {
        checkpointTask?.cancel()
        checkpointTask = Task { @MainActor in
            guard !isResolving else { return }
            await persistCheckpoint()
        }
    }

    private func persistCheckpoint() async {
        let values = checkpointValues
        await onCheckpoint(values.content, values.defaults, values.opacity)
    }

    private var checkpointValues: (
        content: TextBoxContent,
        defaults: TextStyleDefaults,
        opacity: Double
    ) {
        let keepsPlaceholder = request.original.content.plainText.isEmpty
            && String(text.characters) == Self.placeholder
        return (
            keepsPlaceholder
                ? TextBoxContent()
                : AlbumTextAttributedBridge.content(from: text, defaults: typingDefaults),
            typingDefaults,
            opacity
        )
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
