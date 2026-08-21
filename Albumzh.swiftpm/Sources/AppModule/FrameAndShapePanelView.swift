import AlbumPhotoCore
import SwiftUI

private struct PhotoShapeChoice: Identifiable {
    let id: String
    let title: String
    let symbol: String

    static let all = [
        PhotoShapeChoice(
            id: "shape.rectangle",
            title: "Aucun (rectangle)",
            symbol: "rectangle"
        ),
        PhotoShapeChoice(
            id: "shape.roundedRectangle",
            title: "Rectangle arrondi",
            symbol: "rectangle.roundedtop"
        ),
        PhotoShapeChoice(id: "shape.circle", title: "Cercle", symbol: "circle"),
        PhotoShapeChoice(id: "shape.oval", title: "Ovale", symbol: "capsule"),
        PhotoShapeChoice(id: "shape.heart", title: "Cœur", symbol: "heart"),
        PhotoShapeChoice(id: "shape.star", title: "Étoile", symbol: "star")
    ]
}

struct FrameAndShapePanelView: View {
    @ObservedObject var model: EditorViewModel

    @State private var scope: PhotoFrameStyleApplicationScope = .selection
    @State private var borderWidth = 0.0

    var body: some View {
        ScrollView {
            if let frame = model.selectedPhotoFrame {
                VStack(alignment: .leading, spacing: 16) {
                    scopePicker
                    shapeSection(frame)
                    Divider()
                    borderSection(frame)
                    Divider()
                    decorativeFrameSection
                }
                .padding(12)
                .onAppear { borderWidth = frame.border.width }
                .onChange(of: frame.id) { _, _ in
                    borderWidth = frame.border.width
                }
                .onChange(of: frame.border.width) { _, newValue in
                    borderWidth = newValue
                }
            } else {
                ContentUnavailableView(
                    "Sélectionnez une photo",
                    systemImage: "rectangle.on.rectangle.slash",
                    description: Text(
                        "Les formes, contours et cadres décoratifs s’appliquent aux cadres photo."
                    )
                )
                .padding(12)
            }
        }
    }

    private var scopePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Portée")
                .font(.headline)
            Picker("Portée du style", selection: $scope) {
                Text("Sélection").tag(PhotoFrameStyleApplicationScope.selection)
                Text("Page").tag(PhotoFrameStyleApplicationScope.page)
                Text("Album").tag(PhotoFrameStyleApplicationScope.album)
            }
            .pickerStyle(.segmented)
            Text(model.photoFrameStyleScopeDescription(scope))
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel(model.photoFrameStyleScopeDescription(scope))
        }
    }

    private func shapeSection(_ frame: PhotoFrameElement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Forme")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 74))], spacing: 8) {
                ForEach(PhotoShapeChoice.all) { choice in
                    let selected = frame.mask.shape.catalogID == choice.id
                    Button {
                        Task {
                            await model.applySelectedPhotoMask(
                                CatalogResourceReference(catalogID: choice.id),
                                scope: scope
                            )
                        }
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: choice.symbol)
                                .font(.title2)
                            Text(choice.title)
                                .font(.caption2)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                            if selected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.tint)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 72)
                        .background(
                            selected ? Color.accentColor.opacity(0.12) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 9)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Forme \(choice.title)")
                    .accessibilityValue(selected ? "Sélectionnée" : "")
                }
            }
        }
    }

    private func borderSection(_ frame: PhotoFrameElement) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Contour")
                    .font(.headline)
                Spacer()
                Text(borderWidth, format: .percent.precision(.fractionLength(1)))
                    .font(.caption.monospacedDigit())
                Button("Aucun") {
                    borderWidth = 0
                    Task {
                        await model.applySelectedPhotoBorder(
                            PhotoBorder(),
                            scope: scope
                        )
                    }
                }
                .buttonStyle(.borderless)
                .disabled(borderWidth == 0)
            }
            Slider(
                value: $borderWidth,
                in: 0...0.03,
                step: 0.001,
                onEditingChanged: { isEditing in
                    guard !isEditing else { return }
                    Task {
                        await model.applySelectedPhotoBorder(
                            PhotoBorder(width: borderWidth, color: frame.border.color),
                            scope: scope
                        )
                    }
                }
            )
            .accessibilityLabel("Épaisseur du contour")
            .accessibilityValue(
                borderWidth.formatted(.percent.precision(.fractionLength(1)))
            )

            HStack(spacing: 10) {
                ForEach(AlbumTextColorOption.all) { option in
                    let selected = frame.border.color == option.color
                    Button {
                        Task {
                            await model.applySelectedPhotoBorder(
                                PhotoBorder(width: borderWidth, color: option.color),
                                scope: scope
                            )
                        }
                    } label: {
                        Circle()
                            .fill(option.color.swiftUIColor)
                            .frame(width: 32, height: 32)
                            .overlay {
                                Circle().stroke(
                                    selected ? Color.accentColor : .primary.opacity(0.3),
                                    lineWidth: selected ? 3 : 1
                                )
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Contour \(option.title)")
                    .accessibilityValue(selected ? "Sélectionné" : "")
                }
            }
        }
    }

    private var decorativeFrameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cadre décoratif")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 82))], spacing: 8) {
                decorativeFrameButton(nil)
                ForEach(BuiltInDecorativeFrameCatalog.definitions) { definition in
                    decorativeFrameButton(definition)
                }
            }
        }
    }

    private func decorativeFrameButton(
        _ definition: DecorativeFrameCatalogDefinition?
    ) -> some View {
        let selected = model.selectedPhotoFrame?.decorativeFrame == definition?.reference
        let title = definition?.localizedName ?? "Aucun"
        return Button {
            Task {
                await model.applySelectedDecorativeFrame(
                    definition?.reference,
                    scope: scope
                )
            }
        } label: {
            VStack(spacing: 5) {
                if let definition {
                    BundledCatalogImage(
                        dataAssetName: definition.dataAssetName,
                        contentHash: definition.contentHash,
                        cache: model.imageCache,
                        maximumPixelSize: 256
                    )
                    .scaledToFit()
                    .aspectRatio(1, contentMode: .fit)
                } else {
                    Image(systemName: "square.slash")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                }
                Text(title)
                    .font(.caption2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 28, alignment: .top)
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 92)
            .padding(5)
            .background(
                selected ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.05),
                in: RoundedRectangle(cornerRadius: 9)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Cadre décoratif \(title)")
        .accessibilityValue(selected ? "Sélectionné" : "")
    }
}

/// Public SwiftUI counterpart of the six deterministic SHR-012 masks.
struct AlbumCatalogShape: InsettableShape {
    let catalogID: String
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let bounds = rect.insetBy(dx: insetAmount, dy: insetAmount)
        guard bounds.width > 0, bounds.height > 0 else { return Path() }
        switch catalogID {
        case "shape.roundedRectangle":
            return Path(roundedRect: bounds, cornerRadius: 0.12 * min(
                bounds.width,
                bounds.height
            ))
        case "shape.circle":
            let side = min(bounds.width, bounds.height)
            return Path(ellipseIn: CGRect(
                x: bounds.midX - side / 2,
                y: bounds.midY - side / 2,
                width: side,
                height: side
            ))
        case "shape.oval":
            return Path(ellipseIn: bounds)
        case "shape.heart":
            return heartPath(in: bounds)
        case "shape.star":
            return starPath(in: bounds)
        default:
            return Path(bounds)
        }
    }

    func inset(by amount: CGFloat) -> AlbumCatalogShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    private func heartPath(in rect: CGRect) -> Path {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        return Path { path in
            path.move(to: point(0.50, 0.95))
            path.addCurve(
                to: point(0.08, 0.34),
                control1: point(0.44, 0.88),
                control2: point(0.08, 0.65)
            )
            path.addCurve(
                to: point(0.36, 0.05),
                control1: point(0.08, 0.15),
                control2: point(0.21, 0.05)
            )
            path.addCurve(
                to: point(0.50, 0.17),
                control1: point(0.44, 0.05),
                control2: point(0.49, 0.10)
            )
            path.addCurve(
                to: point(0.64, 0.05),
                control1: point(0.51, 0.10),
                control2: point(0.56, 0.05)
            )
            path.addCurve(
                to: point(0.92, 0.34),
                control1: point(0.79, 0.05),
                control2: point(0.92, 0.15)
            )
            path.addCurve(
                to: point(0.50, 0.95),
                control1: point(0.92, 0.65),
                control2: point(0.56, 0.88)
            )
            path.closeSubpath()
        }
    }

    private func starPath(in rect: CGRect) -> Path {
        Path { path in
            for index in 0..<10 {
                let angle = -CGFloat.pi / 2 + CGFloat(index) * CGFloat.pi / 5
                let radius: CGFloat = index.isMultiple(of: 2) ? 0.5 : 0.22
                let point = CGPoint(
                    x: rect.minX + (0.5 + cos(angle) * radius) * rect.width,
                    y: rect.minY + (0.5 + sin(angle) * radius) * rect.height
                )
                if index == 0 { path.move(to: point) }
                else { path.addLine(to: point) }
            }
            path.closeSubpath()
        }
    }
}
