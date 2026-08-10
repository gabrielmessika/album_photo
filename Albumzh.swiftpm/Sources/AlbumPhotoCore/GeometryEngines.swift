import Foundation

public struct GeometryPoint: Codable, Sendable, Equatable, Hashable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct GeometrySize: Codable, Sendable, Equatable, Hashable {
    public var width: Double
    public var height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

public struct GeometryRect: Codable, Sendable, Equatable, Hashable {
    public var minX: Double
    public var minY: Double
    public var width: Double
    public var height: Double

    public init(minX: Double, minY: Double, width: Double, height: Double) {
        self.minX = minX
        self.minY = minY
        self.width = width
        self.height = height
    }

    public var maxX: Double { minX + width }
    public var maxY: Double { minY + height }
    public var midX: Double { minX + width / 2 }
    public var midY: Double { minY + height / 2 }
}

public struct PhotoRenderGeometry: Sendable, Equatable {
    public let frameSize: GeometrySize
    public let renderedPhotoSize: GeometrySize
    public let transformedFocalPoint: GeometryPoint
    public let photoRectInFrame: GeometryRect

    public init(
        frameSize: GeometrySize,
        renderedPhotoSize: GeometrySize,
        transformedFocalPoint: GeometryPoint,
        photoRectInFrame: GeometryRect
    ) {
        self.frameSize = frameSize
        self.renderedPhotoSize = renderedPhotoSize
        self.transformedFocalPoint = transformedFocalPoint
        self.photoRectInFrame = photoRectInFrame
    }
}

public enum PhotoCropGeometry {
    public static func orientedPixelSize(
        metadata: PhotoAssetMetadata,
        quarterTurns: Int
    ) throws -> GeometrySize {
        guard metadata.pixelWidth > 0, metadata.pixelHeight > 0 else {
            throw DomainValidationError.invalidPhotoMetadata
        }
        let turns = ((quarterTurns % 4) + 4) % 4
        if turns.isMultiple(of: 2) {
            return GeometrySize(
                width: Double(metadata.pixelWidth),
                height: Double(metadata.pixelHeight)
            )
        }
        return GeometrySize(
            width: Double(metadata.pixelHeight),
            height: Double(metadata.pixelWidth)
        )
    }

    public static func canonicalFrameSize(for geometry: ElementGeometry) throws -> GeometrySize {
        try DomainValidator.validate(geometry)
        return GeometrySize(
            width: geometry.width * AlbumPhotoConstants.canonicalPageWidth,
            height: geometry.height * AlbumPhotoConstants.canonicalPageHeight
        )
    }

    /// 3:CRP-004 / 3:DAT-006 — dynamic lower bound in the local rectangular frame.
    public static func minimumNativeScale(
        metadata: PhotoAssetMetadata,
        frameGeometry: ElementGeometry,
        quarterTurns: Int
    ) throws -> Double {
        let frame = try canonicalFrameSize(for: frameGeometry)
        let photo = try orientedPixelSize(metadata: metadata, quarterTurns: quarterTurns)
        let fit = min(frame.width / photo.width, frame.height / photo.height)
        guard fit.isFinite, fit > 0 else {
            throw DomainValidationError.invalidPhotoPlacement
        }
        return min(1, fit)
    }

    /// Keeps an already persisted smaller scale valid when a later frame change
    /// raises the freshly calculated minimum (3:CRP-007).
    public static func sessionMinimumNativeScale(
        entryNativeScale: Double,
        metadata: PhotoAssetMetadata,
        frameGeometry: ElementGeometry,
        quarterTurns: Int
    ) throws -> Double {
        guard entryNativeScale.isFinite, entryNativeScale > 0,
              entryNativeScale <= AlbumPhotoConstants.maximumNativeScale else {
            throw DomainValidationError.invalidPhotoPlacement
        }
        return min(
            entryNativeScale,
            try minimumNativeScale(
                metadata: metadata,
                frameGeometry: frameGeometry,
                quarterTurns: quarterTurns
            )
        )
    }

    public static func clampScale(_ scale: Double, sessionMinimum: Double) throws -> Double {
        guard scale.isFinite, sessionMinimum.isFinite, sessionMinimum > 0,
              sessionMinimum <= AlbumPhotoConstants.maximumNativeScale else {
            throw DomainValidationError.invalidPhotoPlacement
        }
        return min(
            AlbumPhotoConstants.maximumNativeScale,
            max(sessionMinimum, scale)
        )
    }

    public static func transformedFocalPoint(
        x: Double,
        y: Double,
        quarterTurns: Int,
        flippedHorizontally: Bool
    ) throws -> GeometryPoint {
        guard x.isFinite, y.isFinite, (0...1).contains(x), (0...1).contains(y) else {
            throw DomainValidationError.invalidPhotoPlacement
        }
        let turns = ((quarterTurns % 4) + 4) % 4
        var result: GeometryPoint
        switch turns {
        case 0: result = GeometryPoint(x: x, y: y)
        case 1: result = GeometryPoint(x: 1 - y, y: x)
        case 2: result = GeometryPoint(x: 1 - x, y: 1 - y)
        default: result = GeometryPoint(x: y, y: 1 - x)
        }
        if flippedHorizontally { result.x = 1 - result.x }
        return result
    }

    public static func renderGeometry(
        placement: PhotoPlacement,
        metadata: PhotoAssetMetadata,
        frameGeometry: ElementGeometry
    ) throws -> PhotoRenderGeometry {
        try DomainValidator.validate(placement)
        let frame = try canonicalFrameSize(for: frameGeometry)
        let pixels = try orientedPixelSize(
            metadata: metadata,
            quarterTurns: placement.quarterTurns
        )
        let rendered = GeometrySize(
            width: pixels.width * placement.nativeScale,
            height: pixels.height * placement.nativeScale
        )
        let focal = try transformedFocalPoint(
            x: placement.focalX,
            y: placement.focalY,
            quarterTurns: placement.quarterTurns,
            flippedHorizontally: placement.flippedHorizontally
        )
        let rect = GeometryRect(
            minX: frame.width / 2 - focal.x * rendered.width,
            minY: frame.height / 2 - focal.y * rendered.height,
            width: rendered.width,
            height: rendered.height
        )
        return PhotoRenderGeometry(
            frameSize: frame,
            renderedPhotoSize: rendered,
            transformedFocalPoint: focal,
            photoRectInFrame: rect
        )
    }

    public static func initialFrameGeometry(
        metadata: PhotoAssetMetadata,
        centerX: Double = 0.5,
        centerY: Double = 0.5,
        order: Int64 = AlbumPhotoConstants.elementOrderStep
    ) throws -> ElementGeometry {
        try DomainValidator.validate(metadata)
        guard centerX.isFinite, centerY.isFinite else {
            throw DomainValidationError.invalidGeometry
        }
        let maximumCanonicalWidth = 0.45 * AlbumPhotoConstants.canonicalPageWidth
        let maximumCanonicalHeight = 0.45 * AlbumPhotoConstants.canonicalPageHeight
        let aspect = Double(metadata.pixelWidth) / Double(metadata.pixelHeight)
        var width = maximumCanonicalWidth
        var height = width / aspect
        if height > maximumCanonicalHeight {
            height = maximumCanonicalHeight
            width = height * aspect
        }
        return ElementGeometry(
            centerX: min(1, max(0, centerX)),
            centerY: min(1, max(0, centerY)),
            width: max(0.05, width / AlbumPhotoConstants.canonicalPageWidth),
            height: max(0.05, height / AlbumPhotoConstants.canonicalPageHeight),
            rotationRadians: 0,
            order: order
        )
    }

    public static func focalPoint(
        fromTranslation translation: GeometryPoint,
        start: GeometryPoint,
        renderedPhotoSize: GeometrySize
    ) throws -> GeometryPoint {
        guard renderedPhotoSize.width > 0, renderedPhotoSize.height > 0,
              translation.x.isFinite, translation.y.isFinite,
              start.x.isFinite, start.y.isFinite else {
            throw DomainValidationError.invalidPhotoPlacement
        }
        return GeometryPoint(
            x: min(1, max(0, start.x - translation.x / renderedPhotoSize.width)),
            y: min(1, max(0, start.y - translation.y / renderedPhotoSize.height))
        )
    }
}

public enum PhotoQualityState: String, Codable, Sendable, Equatable, Hashable {
    case ok
    case acceptable
    case insufficient
}

public enum PhotoQualityEngine {
    public static func pixelsPerInch(
        nativeScale: Double,
        canvasWidthInches: Double,
        canvasHeightInches: Double
    ) throws -> Double {
        guard nativeScale.isFinite, nativeScale > 0,
              canvasWidthInches.isFinite, canvasWidthInches > 0,
              canvasHeightInches.isFinite, canvasHeightInches > 0 else {
            throw DomainValidationError.invalidPhotoPlacement
        }
        return min(
            AlbumPhotoConstants.canonicalPageWidth / (nativeScale * canvasWidthInches),
            AlbumPhotoConstants.canonicalPageHeight / (nativeScale * canvasHeightInches)
        )
    }

    public static func state(for pixelsPerInch: Double) throws -> PhotoQualityState {
        guard pixelsPerInch.isFinite, pixelsPerInch >= 0 else {
            throw DomainValidationError.invalidPhotoPlacement
        }
        if pixelsPerInch >= 300 { return .ok }
        if pixelsPerInch >= 150 { return .acceptable }
        return .insufficient
    }
}

// MARK: - Hit testing and snapping prototype (3:ELM-001 to 3:ELM-007)

public enum CanvasHitTesting {
    public static func contains(
        normalizedPoint: GeometryPoint,
        geometry: ElementGeometry
    ) -> Bool {
        // Rotation lives in the canonical page coordinate system. Rotating
        // raw normalized x/y would distort hit regions on the 4:5 page.
        let dx = (normalizedPoint.x - geometry.centerX)
            * AlbumPhotoConstants.canonicalPageWidth
        let dy = (normalizedPoint.y - geometry.centerY)
            * AlbumPhotoConstants.canonicalPageHeight
        let cosine = cos(-geometry.rotationRadians)
        let sine = sin(-geometry.rotationRadians)
        let localX = dx * cosine - dy * sine
        let localY = dx * sine + dy * cosine
        return abs(localX) <= geometry.width * AlbumPhotoConstants.canonicalPageWidth / 2
            && abs(localY) <= geometry.height * AlbumPhotoConstants.canonicalPageHeight / 2
    }

    public static func topmostElement(
        at normalizedPoint: GeometryPoint,
        in page: PageSnapshot
    ) -> PageElement? {
        page.elements
            .filter { contains(normalizedPoint: normalizedPoint, geometry: $0.geometry) }
            .sorted(by: PageElement.visualOrder)
            .last
    }

    public static func overlappingElements(
        at normalizedPoint: GeometryPoint,
        in page: PageSnapshot
    ) -> [PageElement] {
        page.elements
            .filter { contains(normalizedPoint: normalizedPoint, geometry: $0.geometry) }
            .sorted(by: PageElement.visualOrder)
            .reversed()
    }
}

public enum SnapAxis: String, Codable, Sendable, Equatable, Hashable {
    case horizontal
    case vertical
}

public struct SnapGuide: Codable, Sendable, Equatable, Hashable {
    public let axis: SnapAxis
    public let normalizedPosition: Double

    public init(axis: SnapAxis, normalizedPosition: Double) {
        self.axis = axis
        self.normalizedPosition = normalizedPosition
    }
}

public struct SnapResult: Sendable, Equatable {
    public let geometry: ElementGeometry
    public let guides: [SnapGuide]

    public init(geometry: ElementGeometry, guides: [SnapGuide]) {
        self.geometry = geometry
        self.guides = guides
    }

    public var didSnap: Bool { !guides.isEmpty }
}

public enum CanvasSnapEngine {
    public static func snap(
        moving: ElementGeometry,
        otherElements: [ElementGeometry],
        pageSizePoints: GeometrySize,
        thresholdPoints: Double = 6
    ) -> SnapResult {
        guard pageSizePoints.width > 0, pageSizePoints.height > 0 else {
            return SnapResult(geometry: moving, guides: [])
        }
        let xThreshold = thresholdPoints / pageSizePoints.width
        let yThreshold = thresholdPoints / pageSizePoints.height
        var xCandidates = [0.0, 0.5, 1.0]
        var yCandidates = [0.0, 0.5, 1.0]
        for geometry in otherElements {
            xCandidates += [
                geometry.centerX - geometry.width / 2,
                geometry.centerX,
                geometry.centerX + geometry.width / 2
            ]
            yCandidates += [
                geometry.centerY - geometry.height / 2,
                geometry.centerY,
                geometry.centerY + geometry.height / 2
            ]
        }

        var result = moving
        var guides: [SnapGuide] = []
        let movingX = [
            moving.centerX - moving.width / 2,
            moving.centerX,
            moving.centerX + moving.width / 2
        ]
        let movingY = [
            moving.centerY - moving.height / 2,
            moving.centerY,
            moving.centerY + moving.height / 2
        ]

        if let match = closestPair(moving: movingX, targets: xCandidates, threshold: xThreshold) {
            result.centerX += match.target - match.moving
            guides.append(SnapGuide(axis: .vertical, normalizedPosition: match.target))
        }
        if let match = closestPair(moving: movingY, targets: yCandidates, threshold: yThreshold) {
            result.centerY += match.target - match.moving
            guides.append(SnapGuide(axis: .horizontal, normalizedPosition: match.target))
        }
        result.centerX = min(1, max(0, result.centerX))
        result.centerY = min(1, max(0, result.centerY))
        return SnapResult(geometry: result, guides: guides)
    }

    private static func closestPair(
        moving: [Double],
        targets: [Double],
        threshold: Double
    ) -> (moving: Double, target: Double)? {
        var best: (moving: Double, target: Double, distance: Double)?
        for source in moving {
            for target in targets {
                let distance = abs(source - target)
                // The 6 pt threshold is inclusive. Conversion to normalized
                // coordinates can put the mathematical boundary a few ulps
                // above `threshold` (for example, 0.006000000000000005).
                let tolerance = max(1e-12, threshold.ulp * 8)
                if distance <= threshold + tolerance
                    && (best == nil || distance < best!.distance) {
                    best = (source, target, distance)
                }
            }
        }
        return best.map { ($0.moving, $0.target) }
    }
}

// MARK: - Per-window canvas zoom (3:ZOM-001 to 3:ZOM-007)

public struct CanvasViewportState: Codable, Sendable, Equatable, Hashable {
    public var zoom: Double
    public var centerX: Double
    public var centerY: Double

    public init(zoom: Double = 1, centerX: Double = 0.5, centerY: Double = 0.5) {
        self.zoom = min(4, max(0.5, zoom))
        self.centerX = min(1, max(0, centerX))
        self.centerY = min(1, max(0, centerY))
    }

    public static let fitted = CanvasViewportState()
}

public enum CanvasZoomEngine {
    public static let steps = [0.5, 0.75, 1, 1.25, 1.5, 2, 3, 4]

    public static func nextStep(after zoom: Double) -> Double {
        steps.first(where: { $0 > zoom + 0.000_001 }) ?? 4
    }

    public static func previousStep(before zoom: Double) -> Double {
        steps.last(where: { $0 < zoom - 0.000_001 }) ?? 0.5
    }

    public static func pinched(_ state: CanvasViewportState, magnification: Double) -> CanvasViewportState {
        pinched(
            state,
            magnification: magnification,
            anchorNormalized: GeometryPoint(x: state.centerX, y: state.centerY)
        )
    }

    public static func pinched(
        _ state: CanvasViewportState,
        magnification: Double,
        anchorNormalized: GeometryPoint
    ) -> CanvasViewportState {
        guard magnification.isFinite, magnification > 0,
              anchorNormalized.x.isFinite, anchorNormalized.y.isFinite else {
            return state
        }
        let newZoom = min(4, max(0.5, state.zoom * magnification))
        let ratio = state.zoom / newZoom
        let anchor = GeometryPoint(
            x: min(1, max(0, anchorNormalized.x)),
            y: min(1, max(0, anchorNormalized.y))
        )
        return CanvasViewportState(
            zoom: newZoom,
            centerX: anchor.x + (state.centerX - anchor.x) * ratio,
            centerY: anchor.y + (state.centerY - anchor.y) * ratio
        )
    }

    /// Source-compatible spelling retained for the SwiftUI adapter.
    public static func pinched(
        _ state: CanvasViewportState,
        magnification: Double,
        anchor: GeometryPoint
    ) -> CanvasViewportState {
        pinched(
            state,
            magnification: magnification,
            anchorNormalized: anchor
        )
    }

    public static func panned(
        _ state: CanvasViewportState,
        translationPoints: GeometryPoint,
        fittedPageSizePoints: GeometrySize,
        viewportSizePoints: GeometrySize
    ) -> CanvasViewportState {
        guard fittedPageSizePoints.width > 0, fittedPageSizePoints.height > 0,
              viewportSizePoints.width > 0, viewportSizePoints.height > 0 else {
            return state
        }
        let displayedWidth = fittedPageSizePoints.width * state.zoom
        let displayedHeight = fittedPageSizePoints.height * state.zoom
        let proposedX = state.centerX - translationPoints.x / displayedWidth
        let proposedY = state.centerY - translationPoints.y / displayedHeight
        return CanvasViewportState(
            zoom: state.zoom,
            centerX: constrainedCenter(
                proposedX,
                displayedPageLength: displayedWidth,
                viewportLength: viewportSizePoints.width
            ),
            centerY: constrainedCenter(
                proposedY,
                displayedPageLength: displayedHeight,
                viewportLength: viewportSizePoints.height
            )
        )
    }

    private static func constrainedCenter(
        _ proposed: Double,
        displayedPageLength: Double,
        viewportLength: Double
    ) -> Double {
        guard displayedPageLength > viewportLength else { return 0.5 }
        let visibleHalfSpan = viewportLength / (2 * displayedPageLength)
        return min(1 - visibleHalfSpan, max(visibleHalfSpan, proposed))
    }
}
