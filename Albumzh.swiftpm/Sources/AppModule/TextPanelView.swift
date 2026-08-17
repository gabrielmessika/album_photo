import AlbumPhotoCore
import SwiftUI

struct TextPanelView: View {
    @ObservedObject var model: EditorViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 8) {
                    Button("Ajouter un texte", systemImage: "text.badge.plus") {
                        model.beginAddingText()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(model.isReadOnly)
                    .accessibilityHint(
                        "Crée une zone centrée au premier plan et ouvre le clavier."
                    )

                    Spacer(minLength: 0)

                    Button("Aide du texte", systemImage: "questionmark.circle") {
                        model.helpContext = .text
                    }
                    .labelStyle(.iconOnly)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                if model.selectedTextBox != nil {
                    Label(
                        "Les options du texte sélectionné sont disponibles dans l’inspecteur de l’élément.",
                        systemImage: "slider.horizontal.3"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                } else {
                    ContentUnavailableView(
                        "Aucun texte sélectionné",
                        systemImage: "textformat",
                        description: Text(
                            "Ajoutez une zone ou sélectionnez-en une sur la page pour afficher son contenu et ses options dans l’inspecteur."
                        )
                    )
                }
            }
            .padding(12)
        }
    }
}

struct TextElementInspectorView: View {
    @ObservedObject var model: EditorViewModel
    let text: TextBoxElement

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Texte à afficher")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(text.content.plainText.isEmpty ? "Zone vide" : text.content.plainText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                    .accessibilityLabel("Texte à afficher")
                    .accessibilityValue(
                        text.content.plainText.isEmpty ? "Zone vide" : text.content.plainText
                    )
            }

            Button("Modifier le texte et le format", systemImage: "text.cursor") {
                model.beginEditingSelectedText()
            }
            .buttonStyle(.borderedProminent)

            Text("Format de toute la zone")
                .font(.subheadline.weight(.semibold))

            fontMenu(text)
            sizeMenu(text)

            HStack(spacing: 8) {
                Button("Gras", systemImage: "bold") {
                    Task {
                        await model.applySelectedTextCharacterStyle(
                            TextCharacterStylePatch(
                                weight: text.typingDefaults.weight == .bold
                                    ? .regular : .bold
                            )
                        )
                    }
                }
                .tint(text.typingDefaults.weight == .bold ? Color.accentColor : nil)

                Button("Italique", systemImage: "italic") {
                    Task {
                        await model.applySelectedTextCharacterStyle(
                            TextCharacterStylePatch(
                                isItalic: !text.typingDefaults.isItalic
                            )
                        )
                    }
                }
                .tint(text.typingDefaults.isItalic ? Color.accentColor : nil)
            }

            colorControls
            alignmentMenu
            lineSpacingMenu
            opacityMenu(text)

            Text(
                "Ces réglages s’appliquent à toute la zone. Utilisez Modifier le texte et le format pour ne modifier qu’une sélection de caractères."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.bordered)
        .disabled(model.isReadOnly)
    }

    private func fontMenu(_ text: TextBoxElement) -> some View {
        Menu {
            ForEach(BuiltInTextFontCatalog.manifest) { font in
                Button(font.localizedName) {
                    Task {
                        await model.applySelectedTextCharacterStyle(
                            TextCharacterStylePatch(fontID: font.id)
                        )
                    }
                }
            }
        } label: {
            Label(
                "Police : \(fontName(text.typingDefaults.fontID))",
                systemImage: "textformat"
            )
        }
    }

    private func sizeMenu(_ text: TextBoxElement) -> some View {
        let currentPoints = Int(
            (text.typingDefaults.relativeFontSize
                * AlbumPhotoConstants.canonicalPageHeight).rounded()
        )
        return Menu {
            ForEach([8, 12, 18, 24, 36, 48, 72, 96], id: \.self) { points in
                Button("\(points) points") {
                    Task {
                        await model.applySelectedTextCharacterStyle(
                            TextCharacterStylePatch(
                                relativeFontSize: Double(points)
                                    / AlbumPhotoConstants.canonicalPageHeight
                            )
                        )
                    }
                }
            }
        } label: {
            Label("Taille : \(currentPoints) points", systemImage: "textformat.size")
        }
    }

    private var colorControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Couleur", systemImage: "paintpalette")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 76))], spacing: 8) {
                ForEach(AlbumTextColorOption.all) { option in
                    Button {
                        Task {
                            await model.applySelectedTextCharacterStyle(
                                TextCharacterStylePatch(color: option.color)
                            )
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(option.color.swiftUIColor)
                                .frame(width: 28, height: 28)
                                .overlay {
                                    Circle()
                                        .stroke(.primary.opacity(0.35), lineWidth: 1)
                                }
                            Text(option.title)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Couleur \(option.title)")
                }
            }
        }
    }

    private var alignmentMenu: some View {
        Menu("Alignement", systemImage: "text.alignleft") {
            Button("Gauche", systemImage: "text.alignleft") {
                applyParagraph(TextParagraphStylePatch(alignment: .leading))
            }
            Button("Centré", systemImage: "text.aligncenter") {
                applyParagraph(TextParagraphStylePatch(alignment: .center))
            }
            Button("Droite", systemImage: "text.alignright") {
                applyParagraph(TextParagraphStylePatch(alignment: .trailing))
            }
        }
    }

    private var lineSpacingMenu: some View {
        Menu("Interligne", systemImage: "line.3.horizontal") {
            ForEach([0.8, 1, 1.2, 1.5, 2], id: \.self) { spacing in
                Button(spacing.formatted(.number.precision(.fractionLength(1)))) {
                    applyParagraph(TextParagraphStylePatch(lineSpacing: spacing))
                }
            }
        }
    }

    private func opacityMenu(_ text: TextBoxElement) -> some View {
        Menu {
            ForEach([0.1, 0.25, 0.5, 0.75, 1], id: \.self) { value in
                Button(value.formatted(.percent.precision(.fractionLength(0)))) {
                    Task { await model.setSelectedTextOpacity(value) }
                }
            }
        } label: {
            Label(
                "Opacité : \(text.opacity.formatted(.percent.precision(.fractionLength(0))))",
                systemImage: "circle.lefthalf.filled"
            )
        }
    }

    private func applyParagraph(_ patch: TextParagraphStylePatch) {
        Task { await model.applySelectedTextParagraphStyle(patch) }
    }

    private func fontName(_ id: String) -> String {
        BuiltInTextFontCatalog.definition(id: id)?.localizedName ?? "Système"
    }
}
