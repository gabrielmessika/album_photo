import AlbumPhotoCore
import SwiftUI

struct StickerPanelView: View {
    @ObservedObject var model: EditorViewModel

    @AppStorage("albumPhoto.recentStickerCatalogIDs.v1")
    private var serializedRecentIDs = ""
    @State private var selectedCategory: StickerCatalogCategory?
    @State private var searchText = ""

    private let columns = [
        GridItem(.adaptive(minimum: 78, maximum: 112), spacing: 8, alignment: .top)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if model.stickerReplacementTargetID != nil {
                HStack(alignment: .top, spacing: 8) {
                    Label(
                        "Choisissez le sticker de remplacement",
                        systemImage: "arrow.triangle.2.circlepath"
                    )
                    .font(.subheadline.weight(.semibold))
                    Spacer(minLength: 4)
                    Button("Annuler le choix", systemImage: "xmark") {
                        model.cancelStickerReplacement()
                    }
                    .labelStyle(.iconOnly)
                    .accessibilityLabel("Annuler le remplacement du sticker")
                }
                .padding(11)
                .background(
                    Color.orange.opacity(0.28),
                    in: RoundedRectangle(cornerRadius: 10)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.orange, lineWidth: 2)
                }
                .accessibilityLabel(
                    "Mode de choix actif : choisissez le sticker de remplacement"
                )
                .accessibilityElement(children: .contain)
            }

            if model.stickerCountOnActivePage > 20 {
                Label(
                    "Cette page contient \(model.stickerCountOnActivePage) stickers. "
                        + "L’édition peut être moins fluide au-delà de 20.",
                    systemImage: "exclamationmark.triangle"
                )
                .font(.footnote)
                .foregroundStyle(.orange)
            }

            TextField("Rechercher par nom ou tag", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Rechercher un sticker")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryButton("Récents", symbol: "clock", category: nil)
                    ForEach(StickerCatalogCategory.allCases, id: \.self) { category in
                        categoryButton(
                            category.localizedName,
                            symbol: symbol(for: category),
                            category: category
                        )
                    }
                }
                .padding(.vertical, 1)
            }

            if visibleDefinitions.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "Aucun sticker récent" : "Aucun résultat",
                    systemImage: searchText.isEmpty ? "clock" : "magnifyingglass",
                    description: Text(
                        searchText.isEmpty
                            ? "Choisissez une catégorie pour utiliser votre premier sticker."
                            : "Essayez un autre nom ou tag."
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(visibleDefinitions) { definition in
                            stickerTile(definition)
                        }
                    }
                    .padding(.bottom, 12)
                }
            }
        }
        .padding(12)
    }

    private var recentIDs: [String] {
        serializedRecentIDs
            .split(separator: "\n")
            .map(String.init)
            .filter { BuiltInStickerCatalog.definition(id: $0) != nil }
    }

    private var visibleDefinitions: [StickerCatalogDefinition] {
        let query = folded(searchText.trimmingCharacters(in: .whitespacesAndNewlines))
        if !query.isEmpty {
            return BuiltInStickerCatalog.definitions.filter { definition in
                ([definition.localizedName] + definition.localizedTags)
                    .map(folded)
                    .contains { $0.contains(query) }
            }
        }
        if let selectedCategory {
            return BuiltInStickerCatalog.definitions.filter {
                $0.category == selectedCategory
            }
        }
        return recentIDs.compactMap { BuiltInStickerCatalog.definition(id: $0) }
    }

    private func folded(_ value: String) -> String {
        value.folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: Locale(identifier: "fr_FR")
        )
    }

    private func categoryButton(
        _ title: String,
        symbol: String,
        category: StickerCatalogCategory?
    ) -> some View {
        let isSelected = searchText.isEmpty && selectedCategory == category
        return Button {
            searchText = ""
            selectedCategory = category
        } label: {
            Label(title, systemImage: symbol)
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    isSelected
                        ? Color.accentColor.opacity(0.15)
                        : Color.secondary.opacity(0.08),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .accessibilityValue(isSelected ? "Sélectionnée" : "")
    }

    private func stickerTile(_ definition: StickerCatalogDefinition) -> some View {
        Button {
            Task {
                if await model.placeSticker(definition) {
                    recordRecent(definition.catalogID)
                }
            }
        } label: {
            VStack(spacing: 5) {
                BundledCatalogImage(
                    dataAssetName: definition.dataAssetName,
                    contentHash: definition.contentHash,
                    cache: model.imageCache,
                    maximumPixelSize: 256
                )
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 9))

                Text(definition.localizedName)
                    .font(.caption2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 28, alignment: .top)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .draggable(CanvasElementDragPayload.sticker(
            catalogID: definition.catalogID,
            catalogVersion: 1
        )) {
            BundledCatalogImage(
                dataAssetName: definition.dataAssetName,
                contentHash: definition.contentHash,
                cache: model.imageCache,
                maximumPixelSize: 192
            )
            .scaledToFit()
            .frame(width: 96, height: 96)
        }
        .accessibilityLabel("Sticker \(definition.localizedName)")
        .accessibilityHint(
            model.stickerReplacementTargetID == nil
                ? "Ajoute le sticker au centre. Vous pouvez aussi le faire glisser sur la page."
                : "Remplace le sticker sélectionné sans modifier sa transformation."
        )
    }

    private func recordRecent(_ catalogID: String) {
        var ids = recentIDs.filter { $0 != catalogID }
        ids.insert(catalogID, at: 0)
        serializedRecentIDs = ids.prefix(50).joined(separator: "\n")
    }

    private func symbol(for category: StickerCatalogCategory) -> String {
        switch category {
        case .travel: "map"
        case .transport: "car"
        case .nature: "leaf"
        case .weather: "cloud.sun"
        case .symbols: "star"
        }
    }
}
