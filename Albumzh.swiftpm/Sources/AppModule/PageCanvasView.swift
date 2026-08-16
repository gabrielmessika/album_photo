import AlbumPhotoCore
import SwiftUI

enum PageRenderPurpose: Equatable {
    case editor
    case thumbnail
    case preview

    var showsEmptyFrames: Bool { self == .editor }
}

struct PageCompositionView: View {
    let page: PageSnapshot
    let assets: [UUID: PhotoAssetMetadata]
    let imageCache: PhotoImageCache
    let purpose: PageRenderPurpose
    var pageNumber: Int?
    var geometryOverride: (UUID, ElementGeometry)?
    var placementOverride: (UUID, PhotoPlacement)?

    init(
        page: PageSnapshot,
        assets: [UUID: PhotoAssetMetadata],
        imageCache: PhotoImageCache,
        purpose: PageRenderPurpose,
        pageNumber: Int? = nil,
        geometryOverride: (UUID, ElementGeometry)? = nil,
        placementOverride: (UUID, PhotoPlacement)? = nil
    ) {
        self.page = page
        self.assets = assets
        self.imageCache = imageCache
        self.purpose = purpose
        self.pageNumber = pageNumber
        self.geometryOverride = geometryOverride
        self.placementOverride = placementOverride
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AlbumPageBackground(
                    selection: page.background,
                    imageCache: imageCache
                )

                ForEach(Array(page.orderedElements.enumerated()), id: \.element.id) {
                    index, element in
                    elementView(
                        element,
                        pageSize: geometry.size,
                        visualIndex: index + 1,
                        visualCount: page.elements.count
                    )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
            // Thumbnails are a single navigation target, while editor and
            // preview must expose every photo frame independently to VoiceOver.
            .accessibilityElement(children: purpose == .thumbnail ? .combine : .contain)
        }
        .aspectRatio(4.0 / 5.0, contentMode: .fit)
    }

    @ViewBuilder
    private func elementView(
        _ element: PageElement,
        pageSize: CGSize,
        visualIndex: Int,
        visualCount: Int
    ) -> some View {
        let elementGeometry = geometryOverride?.0 == element.id
            ? geometryOverride!.1
            : element.geometry
        switch element {
        case let .photo(frame):
            if frame.content != nil || purpose.showsEmptyFrames {
                PhotoFrameRenderView(
                    frame: frame,
                    geometry: elementGeometry,
                    placementOverride: placementOverride?.0 == frame.id
                        ? placementOverride?.1 : nil,
                    metadata: frame.content.flatMap { assets[$0.assetID] },
                    imageCache: imageCache,
                    purpose: purpose,
                    pageNumber: pageNumber,
                    visualIndex: visualIndex,
                    visualCount: visualCount
                )
                .frame(
                    width: max(1, elementGeometry.width * pageSize.width),
                    height: max(1, elementGeometry.height * pageSize.height)
                )
                .rotationEffect(.radians(elementGeometry.rotationRadians))
                .position(
                    x: elementGeometry.centerX * pageSize.width,
                    y: elementGeometry.centerY * pageSize.height
                )
            }
        case let .text(text):
            if !text.content.plainText.isEmpty {
                Text(text.content.plainText)
                    .font(.system(size: max(5, text.typingDefaults.relativeFontSize * pageSize.height)))
                    .foregroundStyle(text.typingDefaults.color.swiftUIColor.opacity(text.opacity))
                    .multilineTextAlignment(.center)
                    .frame(
                        width: elementGeometry.width * pageSize.width,
                        height: elementGeometry.height * pageSize.height
                    )
                    .rotationEffect(.radians(elementGeometry.rotationRadians))
                    .position(
                        x: elementGeometry.centerX * pageSize.width,
                        y: elementGeometry.centerY * pageSize.height
                    )
            }
        case .sticker:
            if purpose == .editor {
                Image(systemName: "face.smiling")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
                    .frame(
                        width: elementGeometry.width * pageSize.width,
                        height: elementGeometry.height * pageSize.height
                    )
                    .rotationEffect(.radians(elementGeometry.rotationRadians))
                    .position(
                        x: elementGeometry.centerX * pageSize.width,
                        y: elementGeometry.centerY * pageSize.height
                    )
            }
        }
    }
}

private struct PhotoFrameRenderView: View {
    let frame: PhotoFrameElement
    let geometry: ElementGeometry
    let placementOverride: PhotoPlacement?
    let metadata: PhotoAssetMetadata?
    let imageCache: PhotoImageCache
    let purpose: PageRenderPurpose
    let pageNumber: Int?
    let visualIndex: Int
    let visualCount: Int

    private var placement: PhotoPlacement? {
        placementOverride ?? frame.content
    }

    var body: some View {
        GeometryReader { frameGeometry in
            ZStack {
                if let placement, let metadata,
                   let render = try? PhotoCropGeometry.renderGeometry(
                       placement: placement,
                       metadata: metadata,
                       frameGeometry: geometry
                   ) {
                    let unitX = frameGeometry.size.width / render.frameSize.width
                    let unitY = frameGeometry.size.height / render.frameSize.height
                    let baseWidth = Double(metadata.pixelWidth)
                        * placement.nativeScale * unitX
                    let baseHeight = Double(metadata.pixelHeight)
                        * placement.nativeScale * unitY
                    let renderedCenterX = render.photoRectInFrame.midX * unitX
                    let renderedCenterY = render.photoRectInFrame.midY * unitY

                    StoredPhotoImage(
                        metadata: metadata,
                        cache: imageCache,
                        maximumPixelSize: purpose == .thumbnail ? 480 : 2_048
                    )
                    .frame(width: max(1, baseWidth), height: max(1, baseHeight))
                    .rotationEffect(.degrees(Double(placement.quarterTurns) * 90))
                    .scaleEffect(
                        x: placement.flippedHorizontally ? -1 : 1,
                        y: 1,
                        anchor: .center
                    )
                    .position(x: renderedCenterX, y: renderedCenterY)
                } else if purpose.showsEmptyFrames {
                    EmptyPhotoFrameView()
                }
            }
            .frame(width: frameGeometry.size.width, height: frameGeometry.size.height)
            .clipShape(Rectangle())
            .overlay {
                if frame.border.width > 0 {
                    Rectangle()
                        .strokeBorder(
                            frame.border.color.swiftUIColor,
                            lineWidth: max(
                                1,
                                frame.border.width
                                    * min(frameGeometry.size.width, frameGeometry.size.height)
                            )
                        )
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        let page = pageNumber.map { ", page \($0)" } ?? ""
        let position = approximatePosition
        let depth = visualCount > 1 ? ", plan \(visualIndex) sur \(visualCount)" : ""
        guard let placement else {
            return "Cadre photo vide\(page), \(position)\(depth), Ajouter une photo"
        }
        let description = placement.accessibilityDescription?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let prefix: String
        if let description, !description.isEmpty {
            prefix = "Photo\(page), \(description)"
        } else {
            prefix = "Photo\(page)"
        }
        return "\(prefix), \(position)\(depth)"
    }

    private var approximatePosition: String {
        let horizontal = geometry.centerX < 1.0 / 3.0
            ? "à gauche" : geometry.centerX > 2.0 / 3.0 ? "à droite" : "au centre"
        let vertical = geometry.centerY < 1.0 / 3.0
            ? "en haut" : geometry.centerY > 2.0 / 3.0 ? "en bas" : "au milieu"
        if horizontal == "au centre", vertical == "au milieu" { return "au centre" }
        return "\(vertical), \(horizontal)"
    }
}

private struct EmptyPhotoFrameView: View {
    var body: some View {
        ZStack {
            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.gray.opacity(0.10)))
                let spacing: CGFloat = 12
                var x: CGFloat = -size.height
                while x < size.width {
                    var line = Path()
                    line.move(to: CGPoint(x: x, y: size.height))
                    line.addLine(to: CGPoint(x: x + size.height, y: 0))
                    context.stroke(line, with: .color(.gray.opacity(0.20)), lineWidth: 1)
                    x += spacing
                }
            }
            VStack(spacing: 5) {
                Image(systemName: "photo.badge.plus")
                    .font(.title2)
                Text("Ajouter une photo")
                    .font(.caption2.weight(.semibold))
                    .minimumScaleFactor(0.65)
            }
            .foregroundStyle(.secondary)
            .padding(4)
        }
        .overlay {
            Rectangle()
                .stroke(.secondary.opacity(0.55), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
        }
    }
}

struct EditablePageCanvas: View {
    @ObservedObject var model: EditorViewModel

    @State private var canvasTransformStart: CanvasViewportState?
    @State private var canvasTransformAnchor = GeometryPoint(x: 0.5, y: 0.5)
    @State private var swipeEligible = false

    var body: some View {
        GeometryReader { workspace in
            if let page = model.activePage {
                let fitted = fittedPageSize(in: workspace.size)
                let pageSize = CGSize(
                    width: fitted.width * model.viewport.zoom,
                    height: fitted.height * model.viewport.zoom
                )
                let pageOffset = CGSize(
                    width: (0.5 - model.viewport.centerX) * pageSize.width,
                    height: (0.5 - model.viewport.centerY) * pageSize.height
                )
                ZStack {
                    workspaceBackground

                    interactivePage(
                        page,
                        pageSize: pageSize
                    )
                    .id(page.id)
                    .offset(pageOffset)

                    if model.cropDraft == nil {
                        TwoFingerCanvasGestureBridge(
                            isEnabled: model.interaction == .idle
                                || canvasTransformStart != nil,
                            shouldBegin: { location in
                                canTransformCanvas(
                                    from: location,
                                    page: page,
                                    pageSize: pageSize,
                                    pageOffset: pageOffset,
                                    workspaceSize: workspace.size
                                )
                            },
                            onBegan: { location in
                                swipeEligible = false
                                canvasTransformStart = model.viewport
                                canvasTransformAnchor = normalizedCanvasPoint(
                                    location,
                                    pageSize: pageSize,
                                    pageOffset: pageOffset,
                                    workspaceSize: workspace.size
                                )
                                model.interaction = .zoomingCanvas
                            },
                            onChanged: { translation, magnification, _ in
                                guard let start = canvasTransformStart else { return }
                                model.transformCanvas(
                                    from: start,
                                    magnification: magnification,
                                    translation: translation,
                                    anchor: canvasTransformAnchor,
                                    fittedPageSize: fitted,
                                    viewportSize: workspace.size
                                )
                            },
                            onEnded: {
                                canvasTransformStart = nil
                                if model.interaction == .zoomingCanvas {
                                    model.interaction = .idle
                                }
                            }
                        )
                        .frame(
                            width: workspace.size.width,
                            height: workspace.size.height
                        )
                    }
                }
                .frame(width: workspace.size.width, height: workspace.size.height)
                .clipped()
                .onAppear {
                    model.recordRenderedPageSize(
                        pageSize,
                        viewportSize: workspace.size,
                        pageID: page.id
                    )
                }
                .onChange(of: pageSize) { _, newSize in
                    model.recordRenderedPageSize(
                        newSize,
                        viewportSize: workspace.size,
                        pageID: page.id
                    )
                }
                .onChange(of: model.activePageID) { _, _ in
                    swipeEligible = false
                    canvasTransformStart = nil
                }
            } else {
                ProgressView("Chargement de la page…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minHeight: 260)
    }

    @ViewBuilder
    private var workspaceBackground: some View {
        if model.cropDraft == nil {
            Color.secondary.opacity(0.08)
                .contentShape(Rectangle())
                .onTapGesture { model.select(elementID: nil) }
        } else {
            Color.secondary.opacity(0.08)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func interactivePage(
        _ page: PageSnapshot,
        pageSize: CGSize
    ) -> some View {
        if model.cropDraft == nil {
            pageSurface(page, pageSize: pageSize)
                .gesture(selectionTapGesture(page: page, pageSize: pageSize))
                .simultaneousGesture(pageSwipeGesture(page: page, pageSize: pageSize))
                .contextMenu {
                    Menu("Sélectionner un élément", systemImage: "cursorarrow.click.2") {
                        ForEach(Array(page.orderedElements.reversed())) { element in
                            Button(model.elementSelectionLabel(element)) {
                                model.select(elementID: element.id)
                            }
                        }
                    }
                }
                .dropDestination(for: PhotoAssetDragPayload.self) { payloads, location in
                    guard let payload = payloads.first,
                          !model.isReadOnly,
                          model.photos.contains(where: { $0.id == payload.assetID }) else {
                        return false
                    }
                    let point = normalizedPoint(location, pageSize: pageSize)
                    let targetFrame = CanvasHitTesting.overlappingElements(
                        at: point,
                        in: page
                    ).compactMap(\.photoFrame).first
                    model.select(elementID: targetFrame?.id)
                    Task { await model.placePhoto(payload.assetID, center: point) }
                    return true
                }
        } else {
            // Aucun recognizer de sélection, navigation, zoom canevas ou dépôt
            // ne reste monté pendant le recadrage.
            pageSurface(page, pageSize: pageSize)
        }
    }

    private func pageSurface(
        _ page: PageSnapshot,
        pageSize: CGSize
    ) -> some View {
        ZStack {
            PageCompositionView(
                page: page,
                assets: Dictionary(
                    uniqueKeysWithValues: model.photos.map { ($0.id, $0) }
                ),
                imageCache: model.imageCache,
                purpose: .editor,
                pageNumber: model.activePageIndex + 1,
                geometryOverride: geometryOverride,
                placementOverride: placementOverride
            )

            if let draft = model.cropDraft,
               let frame = page.element(id: draft.elementID)?.photoFrame {
                CropDimmingOverlay(
                    geometry: frame.geometry,
                    pageSize: pageSize
                )
                CropGestureOverlay(
                    model: model,
                    geometry: frame.geometry,
                    pageSize: pageSize
                )
            }

            SnapGuidesOverlay(guides: model.snapGuides)
        }
        .frame(width: pageSize.width, height: pageSize.height)
        .background(Color.white)
        .clipShape(Rectangle())
        .contentShape(Rectangle())
        // The composition is clipped to the page, but selection controls are
        // applied afterwards so full-page and edge-aligned frames keep their
        // external rotation handle and 44pt+ touch halos visible and hittable.
        .overlay {
            if let selected = model.selectedElement,
               model.cropDraft == nil {
                SelectionOverlay(
                    model: model,
                    element: selected,
                    geometry: displayedGeometry(for: selected),
                    pageSize: pageSize
                )
            }
        }
        .shadow(color: .black.opacity(0.18), radius: 8, y: 3)
        .accessibilityElement(children: .contain)
        .coordinateSpace(name: "pageCanvas")
        .accessibilityLabel(pageAccessibilityLabel(page))
    }

    private var geometryOverride: (UUID, ElementGeometry)? {
        guard let id = model.selectedElementID, let geometry = model.geometryDraft else {
            return nil
        }
        return (id, geometry)
    }

    private var placementOverride: (UUID, PhotoPlacement)? {
        guard let draft = model.cropDraft else { return nil }
        return (draft.elementID, draft.placement)
    }

    private func displayedGeometry(for element: PageElement) -> ElementGeometry {
        if element.id == model.selectedElementID, let value = model.geometryDraft {
            return value
        }
        return element.geometry
    }

    private func fittedPageSize(in available: CGSize) -> CGSize {
        let padding: CGFloat = 24
        let width = max(1, available.width - padding * 2)
        let height = max(1, available.height - padding * 2)
        let fittedWidth = min(width, height * 4 / 5)
        return CGSize(width: fittedWidth, height: fittedWidth * 5 / 4)
    }

    private func normalizedPoint(_ location: CGPoint, pageSize: CGSize) -> GeometryPoint {
        GeometryPoint(
            x: min(1, max(0, location.x / pageSize.width)),
            y: min(1, max(0, location.y / pageSize.height))
        )
    }

    private func canTransformCanvas(
        from location: CGPoint,
        page: PageSnapshot,
        pageSize: CGSize,
        pageOffset: CGSize,
        workspaceSize: CGSize
    ) -> Bool {
        guard model.cropDraft == nil,
              model.interaction == .idle || canvasTransformStart != nil else {
            return false
        }
        let pageOrigin = CGPoint(
            x: (workspaceSize.width - pageSize.width) / 2 + pageOffset.width,
            y: (workspaceSize.height - pageSize.height) / 2 + pageOffset.height
        )
        let local = CGPoint(
            x: location.x - pageOrigin.x,
            y: location.y - pageOrigin.y
        )
        guard local.x >= 0, local.y >= 0,
              local.x <= pageSize.width, local.y <= pageSize.height else {
            return false
        }
        let hitElementID = CanvasHitTesting.topmostElement(
            at: normalizedPoint(local, pageSize: pageSize),
            in: page
        )?.id
        return CanvasGestureArbitration.shouldTransformViewport(
            hitElementID: hitElementID,
            selectedElementID: model.selectedElementID
        )
    }

    private func normalizedCanvasPoint(
        _ location: CGPoint,
        pageSize: CGSize,
        pageOffset: CGSize,
        workspaceSize: CGSize
    ) -> GeometryPoint {
        let origin = CGPoint(
            x: (workspaceSize.width - pageSize.width) / 2 + pageOffset.width,
            y: (workspaceSize.height - pageSize.height) / 2 + pageOffset.height
        )
        return normalizedPoint(
            CGPoint(x: location.x - origin.x, y: location.y - origin.y),
            pageSize: pageSize
        )
    }

    private func selectionTapGesture(
        page: PageSnapshot,
        pageSize: CGSize
    ) -> some Gesture {
        SpatialTapGesture()
            .onEnded { value in
                guard model.cropDraft == nil else { return }
                let point = normalizedPoint(value.location, pageSize: pageSize)
                model.select(
                    elementID: CanvasHitTesting.topmostElement(at: point, in: page)?.id
                )
            }
    }

    private func pageSwipeGesture(
        page: PageSnapshot,
        pageSize: CGSize
    ) -> some Gesture {
        DragGesture(minimumDistance: 18, coordinateSpace: .local)
            .onChanged { value in
                guard model.cropDraft == nil else {
                    swipeEligible = false
                    return
                }
                if value.translation == .zero || !swipeEligible {
                    let point = normalizedPoint(value.startLocation, pageSize: pageSize)
                    swipeEligible = CanvasHitTesting.topmostElement(at: point, in: page) == nil
                        && model.interaction == .idle
                }
            }
            .onEnded { value in
                defer { swipeEligible = false }
                guard swipeEligible else { return }
                model.navigateBySwipe(
                    translation: value.translation,
                    pageWidth: pageSize.width
                )
            }
    }

    private func pageAccessibilityLabel(_ page: PageSnapshot) -> String {
        let frames = page.elements.filter { $0.photoFrame != nil }
        let empty = frames.filter { $0.photoFrame?.content == nil }
        let textCount = page.elements.filter { $0.textBox != nil }.count
        let stickerCount = page.elements.filter { $0.sticker != nil }.count
        let qualityStates = frames.compactMap { frame -> PhotoQualityState? in
            guard let placement = frame.photoFrame?.content else { return nil }
            return DefaultPhotoQualityPolicy.state(for: placement)
        }
        let acceptableCount = qualityStates.filter { $0 == .acceptable }.count
        let insufficientCount = qualityStates.filter { $0 == .insufficient }.count
        let qualitySummary: String
        if acceptableCount == 0, insufficientCount == 0 {
            qualitySummary = "aucune alerte qualité"
        } else {
            qualitySummary = "alertes qualité : \(insufficientCount) insuffisantes, "
                + "\(acceptableCount) acceptables"
        }
        return "Page \(model.activePageIndex + 1) sur \(model.album?.pages.count ?? 1), "
            + "\(frames.count) cadres photo dont \(empty.count) vides, "
            + "\(textCount) zones de texte, \(stickerCount) stickers, "
            + qualitySummary
    }
}

private struct CropDimmingOverlay: View {
    let geometry: ElementGeometry
    let pageSize: CGSize

    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.addRect(CGRect(origin: .zero, size: size))

            let frameSize = CGSize(
                width: geometry.width * pageSize.width,
                height: geometry.height * pageSize.height
            )
            var transform = CGAffineTransform(
                translationX: geometry.centerX * pageSize.width,
                y: geometry.centerY * pageSize.height
            )
            transform = transform.rotated(by: geometry.rotationRadians)
            path.addRect(
                CGRect(
                    x: -frameSize.width / 2,
                    y: -frameSize.height / 2,
                    width: frameSize.width,
                    height: frameSize.height
                ),
                transform: transform
            )
            context.fill(
                path,
                with: .color(.black.opacity(0.48)),
                style: FillStyle(eoFill: true)
            )
        }
        .frame(width: pageSize.width, height: pageSize.height)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct SelectionOverlay: View {
    @ObservedObject var model: EditorViewModel
    let element: PageElement
    let geometry: ElementGeometry
    let pageSize: CGSize

    /// Réserve l’intégralité des cibles tactiles autour du cadre sans modifier
    /// son centre ni mettre le halo transparent au hit-testing.
    private let interactionHalo: CGFloat = 64

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .gesture(moveGesture)
                .simultaneousGesture(twoFingerTransformGesture)
                .onTapGesture(count: 2) {
                    if element.photoFrame?.content != nil { model.beginCrop() }
                }
                .frame(width: overlaySize.width, height: overlaySize.height)

            Rectangle()
                .stroke(Color.accentColor, lineWidth: 2)
                .frame(width: overlaySize.width, height: overlaySize.height)
                .allowsHitTesting(false)

            ForEach(ResizeHandle.allCases) { handle in
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                    .frame(width: 22, height: 22)
                    .offset(desiredHandleOffset(handle))
                    .allowsHitTesting(false)

                Circle()
                    .fill(handleUsesFallback(handle) ? Color.white : Color.clear)
                    .overlay {
                        if handleUsesFallback(handle) {
                            Circle().stroke(
                                Color.accentColor,
                                style: StrokeStyle(lineWidth: 2, dash: [3, 2])
                            )
                        }
                    }
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle().inset(by: -11))
                    .gesture(resizeGesture(for: handle))
                    .offset(handleOffset(handle))
                    .accessibilityLabel(handle.accessibilityLabel)
                    .accessibilityHint(
                        handleUsesFallback(handle)
                            ? "Cible de secours visible ; la bordure réelle sort de la fenêtre"
                            : "Faites glisser pour redimensionner le cadre"
                    )
            }

            Rectangle()
                .fill(Color.accentColor)
                .frame(width: 2, height: 18)
                .offset(y: -overlaySize.height / 2 - 9)
                .allowsHitTesting(false)

            Circle()
                .fill(Color.white)
                .overlay {
                    Image(systemName: "rotate.right")
                        .font(.caption.bold())
                }
                .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                .frame(width: 34, height: 34)
                .offset(desiredRotationHandleOffset)
                .allowsHitTesting(false)

            Circle()
                .fill(rotationHandleIsInset ? Color.white : Color.clear)
                .overlay {
                    if rotationHandleIsInset {
                        Image(systemName: "rotate.right")
                            .font(.caption.bold())
                        Circle().stroke(
                            Color.accentColor,
                            style: StrokeStyle(lineWidth: 2, dash: [3, 2])
                        )
                    }
                }
                .frame(width: 34, height: 34)
                .contentShape(Rectangle().inset(by: -8))
                .gesture(rotationGesture)
                .offset(rotationHandleOffset)
                .accessibilityLabel("Rotation du cadre")
                .accessibilityHint(
                    rotationHandleIsInset
                        ? "Poignée placée dans la page pour rester accessible"
                        : "Faites glisser pour tourner le cadre"
                )
        }
        .frame(width: hitTargetSize.width, height: hitTargetSize.height)
        .rotationEffect(.radians(geometry.rotationRadians))
        .position(
            x: geometry.centerX * pageSize.width,
            y: geometry.centerY * pageSize.height
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(selectionAccessibilityLabel)
        .accessibilityAction(named: "Déplacer à gauche") {
            Task { await model.adjustSelectedGeometry(deltaX: -0.01) }
        }
        .accessibilityAction(named: "Déplacer à droite") {
            Task { await model.adjustSelectedGeometry(deltaX: 0.01) }
        }
        .accessibilityAction(named: "Agrandir") {
            Task {
                await model.adjustSelectedGeometry(
                    deltaWidth: 0.05,
                    deltaHeight: 0.05
                )
            }
        }
        .accessibilityAction(named: "Réduire") {
            Task {
                await model.adjustSelectedGeometry(
                    deltaWidth: -0.05,
                    deltaHeight: -0.05
                )
            }
        }
    }

    private var overlaySize: CGSize {
        CGSize(
            width: max(1, geometry.width * pageSize.width),
            height: max(1, geometry.height * pageSize.height)
        )
    }

    private var selectionAccessibilityLabel: String {
        let pageNumber = model.activePageIndex + 1
        let prefix: String
        switch element {
        case let .photo(frame):
            if let placement = frame.content {
                let description = placement.accessibilityDescription?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if let description, !description.isEmpty {
                    prefix = "Photo, page \(pageNumber), \(description)"
                } else {
                    prefix = "Photo, page \(pageNumber)"
                }
            } else {
                prefix = "Cadre photo vide, page \(pageNumber)"
            }
        case let .text(text):
            prefix = "Texte, page \(pageNumber), \(text.content.plainText)"
        case let .sticker(sticker):
            prefix = "Sticker, page \(pageNumber), \(sticker.resource.catalogID)"
        }
        let ordered = model.activePage?.orderedElements ?? []
        let depth = ordered.firstIndex(where: { $0.id == element.id }).map {
            ", plan \($0 + 1) sur \(ordered.count)"
        } ?? ""
        return "\(prefix), \(approximatePosition)\(depth)"
    }

    private var approximatePosition: String {
        let horizontal = geometry.centerX < 1.0 / 3.0
            ? "à gauche" : geometry.centerX > 2.0 / 3.0 ? "à droite" : "au centre"
        let vertical = geometry.centerY < 1.0 / 3.0
            ? "en haut" : geometry.centerY > 2.0 / 3.0 ? "en bas" : "au milieu"
        if horizontal == "au centre", vertical == "au milieu" { return "au centre" }
        return "\(vertical), \(horizontal)"
    }

    private var hitTargetSize: CGSize {
        CGSize(
            width: overlaySize.width + interactionHalo * 2,
            height: overlaySize.height + interactionHalo * 2
        )
    }

    private func handleOffset(_ handle: ResizeHandle) -> CGSize {
        return clampedControlOffset(
            desiredHandleOffset(handle),
            // A 44pt square needs 31.2pt at a 45° rotation.
            safeInset: 32
        )
    }

    private func desiredHandleOffset(_ handle: ResizeHandle) -> CGSize {
        let local = handle.position(in: overlaySize)
        return CGSize(
            width: local.x - overlaySize.width / 2,
            height: local.y - overlaySize.height / 2
        )
    }

    private func handleUsesFallback(_ handle: ResizeHandle) -> Bool {
        let desired = desiredHandleOffset(handle)
        let resolved = handleOffset(handle)
        return abs(resolved.width - desired.width) > 0.5
            || abs(resolved.height - desired.height) > 0.5
    }

    private var desiredRotationHandleOffset: CGSize {
        CGSize(width: 0, height: -overlaySize.height / 2 - 35)
    }

    private var rotationHandleOffset: CGSize {
        // The 50pt rotation target needs 35.4pt at a 45° rotation.
        clampedControlOffset(desiredRotationHandleOffset, safeInset: 36)
    }

    private var rotationHandleIsInset: Bool {
        let resolved = rotationHandleOffset
        let desired = desiredRotationHandleOffset
        return abs(resolved.width - desired.width) > 0.5
            || abs(resolved.height - desired.height) > 0.5
    }

    /// Keeps the complete 44pt/50pt interaction target inside the page when a
    /// selected frame touches or crosses an edge. Offsets are clamped in page
    /// coordinates, then transformed back to the rotating overlay's local
    /// coordinates so the guarantee also holds for rotated frames.
    private func clampedControlOffset(
        _ local: CGSize,
        safeInset: CGFloat
    ) -> CGSize {
        let angle = CGFloat(geometry.rotationRadians)
        let cosine = cos(angle)
        let sine = sin(angle)
        let rotatedX = local.width * cosine - local.height * sine
        let rotatedY = local.width * sine + local.height * cosine
        let centerX = CGFloat(geometry.centerX) * pageSize.width
        let centerY = CGFloat(geometry.centerY) * pageSize.height
        let globalX = centerX + rotatedX
        let globalY = centerY + rotatedY
        let horizontalInset = min(safeInset, pageSize.width / 2)
        let verticalInset = min(safeInset, pageSize.height / 2)
        let clampedX = min(
            pageSize.width - horizontalInset,
            max(horizontalInset, globalX)
        )
        let clampedY = min(
            pageSize.height - verticalInset,
            max(verticalInset, globalY)
        )
        let deltaX = clampedX - globalX
        let deltaY = clampedY - globalY
        return CGSize(
            width: local.width + deltaX * cosine + deltaY * sine,
            height: local.height - deltaX * sine + deltaY * cosine
        )
    }

    private var moveGesture: some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .named("pageCanvas"))
            .onChanged { value in
                if model.interaction == .idle {
                    model.beginGeometryGesture(
                        elementID: element.id,
                        kind: .movingElement(element.id)
                    )
                }
                guard model.interaction == .movingElement(element.id) else { return }
                model.updateMove(translation: value.translation, pageSize: pageSize)
            }
            .onEnded { _ in
                if model.endGeometryGestureStreamIfSuppressed() { return }
                guard model.interaction == .movingElement(element.id) else { return }
                Task { await model.commitGeometryGesture() }
            }
    }

    private func resizeGesture(for handle: ResizeHandle) -> some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .named("pageCanvas"))
            .onChanged { value in
                if model.interaction == .idle {
                    model.beginGeometryGesture(
                        elementID: element.id,
                        kind: .resizingElement(element.id)
                    )
                }
                guard model.interaction == .resizingElement(element.id) else { return }
                model.updateResize(
                    translation: value.translation,
                    pageSize: pageSize,
                    horizontalSign: handle.horizontalSign,
                    verticalSign: handle.verticalSign
                )
            }
            .onEnded { _ in
                if model.endGeometryGestureStreamIfSuppressed() { return }
                guard model.interaction == .resizingElement(element.id) else { return }
                Task { await model.commitGeometryGesture() }
            }
    }

    private var rotationGesture: some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .named("pageCanvas"))
            .onChanged { value in
                if model.interaction == .idle {
                    model.beginGeometryGesture(
                        elementID: element.id,
                        kind: .rotatingElement(element.id)
                    )
                }
                guard model.interaction == .rotatingElement(element.id) else { return }
                model.updateRotation(location: value.location, pageSize: pageSize)
            }
            .onEnded { _ in
                if model.endGeometryGestureStreamIfSuppressed() { return }
                guard model.interaction == .rotatingElement(element.id) else { return }
                Task { await model.commitGeometryGesture() }
            }
    }

    private var twoFingerTransformGesture: some Gesture {
        MagnificationGesture(minimumScaleDelta: 0.005)
            .simultaneously(with: RotationGesture(minimumAngleDelta: .degrees(0.5)))
            .onChanged { value in
                model.beginTwoFingerTransform(elementID: element.id)
                guard model.interaction == .resizingElement(element.id) else { return }
                model.updateTwoFingerTransform(
                    elementID: element.id,
                    magnification: Double(value.first ?? 1),
                    rotationRadians: value.second?.radians ?? 0
                )
            }
            .onEnded { _ in
                if model.endGeometryGestureStreamIfSuppressed() { return }
                guard model.interaction == .resizingElement(element.id) else { return }
                Task { await model.commitGeometryGesture() }
            }
    }
}

private enum ResizeHandle: String, CaseIterable, Identifiable {
    case topLeading, top, topTrailing, leading, trailing, bottomLeading, bottom, bottomTrailing

    var id: String { rawValue }

    var horizontalSign: Double {
        switch self {
        case .topLeading, .leading, .bottomLeading: -1
        case .top, .bottom: 0
        default: 1
        }
    }

    var verticalSign: Double {
        switch self {
        case .topLeading, .top, .topTrailing: -1
        case .leading, .trailing: 0
        default: 1
        }
    }

    var accessibilityLabel: String {
        "Redimensionner, poignée \(rawValue)"
    }

    func position(in size: CGSize) -> CGPoint {
        CGPoint(
            x: horizontalSign < 0 ? 0 : horizontalSign > 0 ? size.width : size.width / 2,
            y: verticalSign < 0 ? 0 : verticalSign > 0 ? size.height : size.height / 2
        )
    }
}

private struct CropGestureOverlay: View {
    @ObservedObject var model: EditorViewModel
    let geometry: ElementGeometry
    let pageSize: CGSize

    @State private var magnifying = false
    @State private var dragging = false

    var body: some View {
        Rectangle()
            .fill(.clear)
            .contentShape(Rectangle())
            .overlay {
                Rectangle()
                    .strokeBorder(
                        Color.yellow,
                        style: StrokeStyle(lineWidth: 2, dash: [7, 5])
                    )
                    .allowsHitTesting(false)
            }
            .frame(width: frameSize.width, height: frameSize.height)
            .rotationEffect(.radians(geometry.rotationRadians))
            .position(
                x: geometry.centerX * pageSize.width,
                y: geometry.centerY * pageSize.height
            )
            .simultaneousGesture(
                MagnifyGesture(minimumScaleDelta: 0.005)
                    .onChanged { value in
                        if !magnifying {
                            magnifying = true
                            model.startCropGesture()
                        }
                        model.updateCropScale(magnification: value.magnification)
                    }
                    .onEnded { _ in
                        magnifying = false
                        if !dragging { model.endCropGesture() }
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        if !dragging {
                            dragging = true
                            if !magnifying { model.startCropGesture() }
                        }
                        model.updateCropTranslation(value.translation, frameSize: frameSize)
                    }
                    .onEnded { _ in
                        dragging = false
                        if !magnifying { model.endCropGesture() }
                    }
            )
            .accessibilityLabel("Recadrage de la photo")
            .accessibilityHint("Glissez la photo ou utilisez le contrôle Zoom photo")
    }

    private var frameSize: CGSize {
        CGSize(
            width: geometry.width * pageSize.width,
            height: geometry.height * pageSize.height
        )
    }
}

private struct SnapGuidesOverlay: View {
    let guides: [SnapGuide]

    var body: some View {
        GeometryReader { geometry in
            ForEach(Array(guides.enumerated()), id: \.offset) { _, guide in
                if guide.axis == .vertical {
                    Rectangle()
                        .fill(Color.cyan)
                        .frame(width: 1)
                        .position(
                            x: guide.normalizedPosition * geometry.size.width,
                            y: geometry.size.height / 2
                        )
                } else {
                    Rectangle()
                        .fill(Color.cyan)
                        .frame(height: 1)
                        .position(
                            x: geometry.size.width / 2,
                            y: guide.normalizedPosition * geometry.size.height
                        )
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct CanvasZoomControls: View {
    @ObservedObject var model: EditorViewModel

    var body: some View {
        HStack(spacing: 6) {
            Button("Zoom arrière", systemImage: "minus.magnifyingglass") {
                model.zoomCanvasOut()
            }
            .labelStyle(.iconOnly)
            .disabled(model.viewport.zoom <= 0.5 || model.cropDraft != nil)

            Button("Ajuster", systemImage: "arrow.up.left.and.arrow.down.right") {
                model.fitCanvas()
            }
            .labelStyle(.iconOnly)
            .disabled(model.viewport == .fitted || model.cropDraft != nil)

            Text(model.viewport.zoom, format: .percent.precision(.fractionLength(0)))
                .font(.caption.monospacedDigit())
                .frame(minWidth: 48)
                .accessibilityLabel("Zoom du canevas")

            Button("Zoom avant", systemImage: "plus.magnifyingglass") {
                model.zoomCanvasIn()
            }
            .labelStyle(.iconOnly)
            .disabled(model.viewport.zoom >= 4 || model.cropDraft != nil)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
}
