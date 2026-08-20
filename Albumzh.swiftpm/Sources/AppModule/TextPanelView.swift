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
                Button {
                    Task {
                        await model.applySelectedTextCharacterStyle(
                            TextCharacterStylePatch(
                                weight: text.typingDefaults.weight == .bold
                                    ? .regular : .bold
                            )
                        )
                    }
                } label: {
                    AlbumTextToggleLabel(
                        title: "Gras",
                        systemImage: "bold",
                        isSelected: text.typingDefaults.weight == .bold
                    )
                }
                .tint(text.typingDefaults.weight == .bold ? Color.accentColor : nil)

                Button {
                    Task {
                        await model.applySelectedTextCharacterStyle(
                            TextCharacterStylePatch(
                                isItalic: !text.typingDefaults.isItalic
                            )
                        )
                    }
                } label: {
                    AlbumTextToggleLabel(
                        title: "Italique",
                        systemImage: "italic",
                        isSelected: text.typingDefaults.isItalic
                    )
                }
                .tint(text.typingDefaults.isItalic ? Color.accentColor : nil)
            }

            colorControls
            alignmentMenu(text)
            lineSpacingMenu(text)
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
                Button {
                    Task {
                        await model.applySelectedTextCharacterStyle(
                            TextCharacterStylePatch(fontID: font.id)
                        )
                    }
                } label: {
                    AlbumTextMenuChoiceLabel(
                        title: font.localizedName,
                        isSelected: text.typingDefaults.fontID == font.id
                    )
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
                Button {
                    Task {
                        await model.applySelectedTextCharacterStyle(
                            TextCharacterStylePatch(
                                relativeFontSize: Double(points)
                                    / AlbumPhotoConstants.canonicalPageHeight
                            )
                        )
                    }
                } label: {
                    AlbumTextMenuChoiceLabel(
                        title: "\(points) points",
                        isSelected: currentPoints == points
                    )
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
                    let isSelected = text.typingDefaults.color == option.color
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
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.tint)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .padding(4)
                        .background(
                            isSelected ? Color.accentColor.opacity(0.12) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Couleur \(option.title)")
                    .accessibilityValue(isSelected ? "Sélectionnée" : "")
                }
            }
        }
    }

    private func alignmentMenu(_ text: TextBoxElement) -> some View {
        Menu {
            ForEach(AlbumTextAlignmentChoice.all) { choice in
                Button {
                    applyParagraph(TextParagraphStylePatch(alignment: choice.value))
                } label: {
                    AlbumTextMenuChoiceLabel(
                        title: choice.title,
                        isSelected: text.typingDefaults.alignment == choice.value
                    )
                }
            }
        } label: {
            Label(
                "Alignement : \(alignmentName(text.typingDefaults.alignment))",
                systemImage: "text.alignleft"
            )
        }
    }

    private func lineSpacingMenu(_ text: TextBoxElement) -> some View {
        Menu {
            ForEach([0.8, 1, 1.2, 1.5, 2], id: \.self) { spacing in
                let title = spacing.formatted(.number.precision(.fractionLength(1)))
                Button {
                    applyParagraph(TextParagraphStylePatch(lineSpacing: spacing))
                } label: {
                    AlbumTextMenuChoiceLabel(
                        title: title,
                        isSelected: abs(text.typingDefaults.lineSpacing - spacing)
                            < 0.000_001
                    )
                }
            }
        } label: {
            Label(
                "Interligne : \(text.typingDefaults.lineSpacing.formatted(.number.precision(.fractionLength(1))))",
                systemImage: "line.3.horizontal"
            )
        }
    }

    private func opacityMenu(_ text: TextBoxElement) -> some View {
        Menu {
            ForEach([0.1, 0.25, 0.5, 0.75, 1], id: \.self) { value in
                let title = value.formatted(.percent.precision(.fractionLength(0)))
                Button {
                    Task { await model.setSelectedTextOpacity(value) }
                } label: {
                    AlbumTextMenuChoiceLabel(
                        title: title,
                        isSelected: abs(text.opacity - value) < 0.000_001
                    )
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

    private func alignmentName(_ alignment: TextAlignmentValue) -> String {
        AlbumTextAlignmentChoice.all.first { $0.value == alignment }?.title
            ?? "Justifié"
    }
}
