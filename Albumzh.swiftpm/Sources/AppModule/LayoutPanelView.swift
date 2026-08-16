import AlbumPhotoCore
import SwiftUI

struct LayoutPanelView: View {
    @ObservedObject var model: EditorViewModel

    @State private var selectedCount = 1
    @State private var includesText = false

    private let columns = [GridItem(.adaptive(minimum: 104), spacing: 12)]

    private var filteredTemplates: [LayoutTemplateDefinition] {
        model.layoutTemplates.filter { template in
            let countMatches = selectedCount == 7
                ? template.photoSlots.count >= 7
                : template.photoSlots.count == selectedCount
            return countMatches
                && (template.textSlots.isEmpty != includesText)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mises en page")
                    .font(.headline)
                Spacer()
                Button("Aide", systemImage: "questionmark.circle") {
                    model.helpContext = .layouts
                }
                .labelStyle(.iconOnly)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("Nombre de photos")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(1...7, id: \.self) { count in
                            Button(count == 7 ? "7+" : "\(count)") {
                                selectedCount = count
                            }
                            .buttonStyle(.bordered)
                            .tint(selectedCount == count ? Color.accentColor : Color.gray)
                            .accessibilityValue(
                                selectedCount == count ? "Sélectionné" : ""
                            )
                        }
                    }
                }
            }

            Picker("Zone de texte", selection: $includesText) {
                Text("Sans texte").tag(false)
                Text("Avec texte").tag(true)
            }
            .pickerStyle(.segmented)

            Picker(
                "Densité auto",
                selection: Binding(
                    get: { model.activePage?.layout.density ?? .balanced },
                    set: { density in
                        Task { await model.setAutoLayoutDensity(density) }
                    }
                )
            ) {
                Text("Aérée").tag(AutoLayoutDensity.airy)
                Text("Équilibrée").tag(AutoLayoutDensity.balanced)
                Text("Dense").tag(AutoLayoutDensity.dense)
            }
            .pickerStyle(.segmented)
            .disabled(model.isReadOnly)
            .accessibilityHint(
                model.activePage?.layout.isAutoLayoutEnabled == true
                    ? "Réorganise immédiatement les cadres photo."
                    : "Sera utilisée à la prochaine activation d’Auto."
            )

            if includesText {
                Label(
                    "Ces variantes seront activées avec l’éditeur de texte du prochain incrément.",
                    systemImage: "textformat"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredTemplates) { template in
                        templateButton(template)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
            }
        }
        .padding(12)
        .onAppear { selectCurrentPhotoCount() }
        .onChange(of: model.activePageID) { _, _ in
            selectCurrentPhotoCount()
        }
        .onChange(of: model.activePage?.elements.compactMap(\.photoFrame).count) {
            _, _ in
            selectCurrentPhotoCount()
        }
    }

    private func templateButton(
        _ template: LayoutTemplateDefinition
    ) -> some View {
        let key = LayoutTemplateKey(id: template.id, version: template.version)
        let isSelected = model.currentLayoutTemplateKey == key
        return Button {
            Task { await model.requestLayoutTemplate(template) }
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                LayoutTemplateThumbnail(template: template)
                    .aspectRatio(4.0 / 5.0, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected
                                    ? Color.accentColor
                                    : .secondary.opacity(0.35),
                                lineWidth: isSelected ? 3 : 1
                            )
                    }
                    .overlay(alignment: .topTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.white, Color.accentColor)
                                .padding(5)
                        }
                    }

                Text(templateName(template))
                    .font(.caption)
                    .lineLimit(2)
            }
        }
        .buttonStyle(.plain)
        .disabled(model.isReadOnly || !template.textSlots.isEmpty)
        .accessibilityLabel(templateAccessibilityLabel(template))
        .accessibilityValue(isSelected ? "Sélectionné" : "")
        .accessibilityHint(
            template.textSlots.isEmpty
                ? "Applique cette mise en page à la page active"
                : "Disponible avec l’éditeur de texte du prochain incrément"
        )
    }

    private func selectCurrentPhotoCount() {
        guard let count = model.activePage?.elements.compactMap(\.photoFrame).count,
              count > 0 else { return }
        selectedCount = min(7, count)
    }

    private func templateName(_ template: LayoutTemplateDefinition) -> String {
        if template.id.hasSuffix("caption-a") { return "Avec texte A" }
        if template.id.hasSuffix("caption-b") { return "Avec texte B" }
        if template.id.hasSuffix("grid-a") { return "Grille A" }
        if template.id.hasSuffix("grid-b") { return "Grille B" }
        return template.localizedNameKey
    }

    private func templateAccessibilityLabel(
        _ template: LayoutTemplateDefinition
    ) -> String {
        let photos = template.photoSlots.count
        let text = template.textSlots.isEmpty
            ? "sans zone de texte"
            : "avec une zone de texte"
        return "\(templateName(template)), \(photos) photo\(photos > 1 ? "s" : ""), \(text)"
    }
}

private struct LayoutTemplateThumbnail: View {
    let template: LayoutTemplateDefinition

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(uiColor: .secondarySystemBackground)

                ForEach(template.slots) { slot in
                    slotView(slot)
                        .frame(
                            width: proxy.size.width * slot.geometry.width,
                            height: proxy.size.height * slot.geometry.height
                        )
                        .rotationEffect(.radians(slot.geometry.rotationRadians))
                        .position(
                            x: proxy.size.width * slot.geometry.centerX,
                            y: proxy.size.height * slot.geometry.centerY
                        )
                }
            }
        }
        .background(Color.white)
    }

    @ViewBuilder
    private func slotView(_ slot: LayoutSlotDefinition) -> some View {
        switch slot.kind {
        case .photo:
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.accentColor.opacity(0.18))
                .overlay {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.accentColor.opacity(0.65), lineWidth: 1)
                }
                .overlay {
                    Image(systemName: "photo")
                        .font(.caption2)
                        .foregroundStyle(Color.accentColor)
                }
        case .text:
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.primary.opacity(0.07))
                .overlay {
                    Image(systemName: "text.aligncenter")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
        }
    }
}
