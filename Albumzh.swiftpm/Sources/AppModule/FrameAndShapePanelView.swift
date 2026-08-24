import AlbumPhotoCore
import SwiftUI

private struct PhotoShapeChoice: Identifiable {
    let id: String
    let title: String
    let symbol: String

    static let all = [
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

private struct PhotoBorderThicknessChoice: Identifiable {
    let title: String
    let width: Double

    var id: Double { width }

    static let all = [
        PhotoBorderThicknessChoice(title: "Fin", width: 0.01),
        PhotoBorderThicknessChoice(title: "Moyen", width: 0.02),
        PhotoBorderThicknessChoice(title: "Épais", width: 0.03)
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
                    decorationSection(frame)
                    Divider()
                    borderSection(frame)
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
                        "Les cadres décoratifs et les contours s’appliquent aux cadres photo."
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

    private func decorationSection(_ frame: PhotoFrameElement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cadre décoratif")
                .font(.headline)

            Text("Une forme ou un motif à la fois")
                .font(.caption)
                .foregroundStyle(.secondary)

            noneDecorationButton(frame)

            Text("Formes")
                .font(.subheadline.weight(.semibold))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 74))], spacing: 8) {
                ForEach(PhotoShapeChoice.all) { choice in
                    shapeButton(choice, frame: frame)
                }
            }

            Text("Bordures et motifs")
                .font(.subheadline.weight(.semibold))
                .padding(.top, 4)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 82))], spacing: 8) {
                ForEach(BuiltInDecorativeFrameCatalog.definitions) { definition in
                    decorativeFrameButton(definition, frame: frame)
                }
            }
        }
    }

    private func noneDecorationButton(_ frame: PhotoFrameElement) -> some View {
        let selected = frame.mask.shape == .rectangleShape
            && frame.decorativeFrame == nil
        return Button {
            Task {
                await model.applySelectedPhotoMask(.rectangleShape, scope: scope)
            }
        } label: {
            Label(
                "Aucun",
                systemImage: selected ? "checkmark.circle.fill" : "square.slash"
            )
            .frame(maxWidth: .infinity, minHeight: 36)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("Aucun cadre décoratif")
        .accessibilityValue(selected ? "Sélectionné" : "")
    }

    private func shapeButton(
        _ choice: PhotoShapeChoice,
        frame: PhotoFrameElement
    ) -> some View {
        let selected = frame.decorativeFrame == nil
            && frame.mask.shape.catalogID == choice.id
        return Button {
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
        .accessibilityLabel("Cadre décoratif, forme \(choice.title)")
        .accessibilityValue(selected ? "Sélectionnée" : "")
    }

    private func borderSection(_ frame: PhotoFrameElement) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Contour")
                .font(.headline)

            Text("Épaisseur")
                .font(.subheadline.weight(.semibold))

            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: 100), spacing: 8),
                    GridItem(.flexible(minimum: 100), spacing: 8)
                ],
                spacing: 8
            ) {
                borderThicknessButton(
                    title: "Aucun",
                    width: 0,
                    color: frame.border.color
                )
                ForEach(PhotoBorderThicknessChoice.all) { choice in
                    borderThicknessButton(
                        title: choice.title,
                        width: choice.width,
                        color: frame.border.color
                    )
                }
            }

            Text("Couleur")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(borderWidth == 0 ? .secondary : .primary)

            HStack(spacing: 10) {
                ForEach(AlbumTextColorOption.all) { option in
                    let selected = borderWidth > 0 && frame.border.color == option.color
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
            .disabled(borderWidth == 0)
            .opacity(borderWidth == 0 ? 0.45 : 1)
            .accessibilityHint(
                borderWidth == 0
                    ? "Choisissez d’abord Fin, Moyen ou Épais."
                    : "Choisit la couleur du contour."
            )
        }
    }

    private func applyBorder(width: Double, color: SRGBAColor) {
        borderWidth = width
        Task {
            await model.applySelectedPhotoBorder(
                width == 0 ? PhotoBorder() : PhotoBorder(width: width, color: color),
                scope: scope
            )
        }
    }

    private func borderThicknessButton(
        title: String,
        width: Double,
        color: SRGBAColor
    ) -> some View {
        let selected = abs(borderWidth - width) < 0.000_001
        return Button {
            applyBorder(width: width, color: color)
        } label: {
            Label(
                title,
                systemImage: selected ? "checkmark.circle.fill" : "circle"
            )
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .frame(maxWidth: .infinity, minHeight: 32)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("Contour \(title)")
        .accessibilityValue(selected ? "Sélectionné" : "")
    }

    private func decorativeFrameButton(
        _ definition: DecorativeFrameCatalogDefinition,
        frame: PhotoFrameElement
    ) -> some View {
        let selected = frame.decorativeFrame == definition.reference
        let title = definition.localizedName
        return Button {
            Task {
                await model.applySelectedDecorativeFrame(
                    definition.reference,
                    scope: scope
                )
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
                .aspectRatio(1, contentMode: .fit)
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
