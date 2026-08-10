import AlbumPhotoCore
import SwiftUI

private struct ApplyBackgroundToAllRequest: Identifiable {
    let selection: BackgroundSelection
    let pageCount: Int
    let id = UUID()
}

struct BackgroundPickerView: View {
    @ObservedObject var model: EditorViewModel

    @State private var applyToAllRequest: ApplyBackgroundToAllRequest?

    private let columns = [GridItem(.adaptive(minimum: 92), spacing: 12)]
    private let solidColors: [(String, SRGBAColor)] = [
        ("Blanc cassé", SRGBAColor(red: 0.97, green: 0.95, blue: 0.90)),
        ("Sable", SRGBAColor(red: 0.88, green: 0.78, blue: 0.62)),
        ("Rose poudré", SRGBAColor(red: 0.91, green: 0.73, blue: 0.75)),
        ("Bleu brume", SRGBAColor(red: 0.70, green: 0.82, blue: 0.88)),
        ("Vert sauge", SRGBAColor(red: 0.67, green: 0.75, blue: 0.66)),
        ("Anthracite", SRGBAColor(red: 0.14, green: 0.15, blue: 0.17))
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Fonds de page")
                    .font(.headline)
                Spacer()
                Button("Aide", systemImage: "questionmark.circle") {
                    model.helpContext = .backgrounds
                }
                .labelStyle(.iconOnly)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    section("Essentiels") {
                        backgroundGrid([
                            ("Aucun", BackgroundSelection.none)
                        ])
                    }

                    section("Couleurs unies") {
                        backgroundGrid(
                            solidColors.map { ($0.0, .solid($0.1)) }
                        )
                    }

                    section("Motifs intégrés") {
                        backgroundGrid(
                            BackgroundCatalog.themes.map {
                                ($0.localizedName, .catalog($0.reference))
                            }
                        )
                    }
                }
                .padding(.vertical, 2)
            }

            Button("Appliquer à toutes les pages", systemImage: "rectangle.stack.fill") {
                guard let selection = model.activePage?.background,
                      let pageCount = model.album?.pages.count else { return }
                applyToAllRequest = ApplyBackgroundToAllRequest(
                    selection: selection,
                    pageCount: pageCount
                )
            }
            .buttonStyle(.bordered)
            .disabled(model.isReadOnly || model.album == nil)
        }
        .padding(12)
        .alert(item: $applyToAllRequest) { request in
            Alert(
                title: Text("Appliquer ce fond partout ?"),
                message: Text(
                    "Le fond sera appliqué aux \(request.pageCount) pages. Les photos et leur disposition resteront inchangées."
                ),
                primaryButton: .default(Text("Appliquer")) {
                    Task {
                        await model.setBackground(
                            request.selection,
                            allPages: true
                        )
                    }
                },
                secondaryButton: .cancel(Text("Annuler"))
            )
        }
    }

    @ViewBuilder
    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            content()
        }
    }

    private func backgroundGrid(
        _ values: [(String, BackgroundSelection)]
    ) -> some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                let isSelected = model.activePage?.background == value.1
                Button {
                    Task { await model.setBackground(value.1, allPages: false) }
                } label: {
                    VStack(alignment: .leading, spacing: 5) {
                        AlbumPageBackground(
                            selection: value.1,
                            imageCache: model.imageCache
                        )
                            .aspectRatio(4.0 / 5.0, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        isSelected ? Color.accentColor : .secondary.opacity(0.35),
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
                        Text(value.0)
                            .font(.caption)
                            .lineLimit(2)
                    }
                }
                .buttonStyle(.plain)
                .disabled(model.isReadOnly)
                .accessibilityLabel(value.0)
                .accessibilityValue(isSelected ? "Sélectionné" : "")
                .accessibilityHint("Applique immédiatement ce fond à la page active")
            }
        }
    }
}
