import Foundation

/// Errors emitted by the public, platform-independent shape renderer.
public enum CatalogShapeRendererError: Error, Sendable, Equatable {
    case unsupportedRendererID(String)
    case invalidDimensions(width: Int, height: Int)
    case nonFiniteCoordinate
}

/// A deterministic one-bit mask. `true` means that the sample is inside the
/// non-zero-filled shape. Rows are stored from top to bottom.
public struct CatalogMonochromeMask: Sendable, Equatable {
    public let width: Int
    public let height: Int
    public let samples: [Bool]

    public init(width: Int, height: Int, samples: [Bool]) throws {
        let sampleCount = width.multipliedReportingOverflow(by: height)
        guard width > 0,
              height > 0,
              !sampleCount.overflow,
              samples.count == sampleCount.partialValue else {
            throw CatalogShapeRendererError.invalidDimensions(width: width, height: height)
        }
        self.width = width
        self.height = height
        self.samples = samples
    }

    public subscript(x: Int, y: Int) -> Bool {
        samples[y * width + x]
    }

    /// Stable Netpbm P1 encoding used by the version-1 golden masks.
    public var portableBitmapASCII: String {
        var lines = ["P1", "\(width) \(height)"]
        lines.reserveCapacity(height + 2)
        for y in 0..<height {
            let row = (0..<width).map { self[$0, y] ? "1" : "0" }
            lines.append(row.joined(separator: " "))
        }
        return lines.joined(separator: "\n") + "\n"
    }
}

/// Pure-Swift implementation of the six public `SHR-012` renderer contracts.
/// It has no dependency on SwiftUI, CoreGraphics or an Apple-only framework.
public enum CatalogShapeRenderer {
    public static let supportedRendererIDs: Set<String> = [
        "shape.rectangle",
        "shape.roundedRectangle",
        "shape.circle",
        "shape.oval",
        "shape.heart",
        "shape.star"
    ]

    /// Rasterizes at pixel centres. The element dimensions are the requested
    /// mask dimensions, so radius rules based on `min(width, height)` remain
    /// correct for non-square elements.
    public static func rasterize(
        rendererID: String,
        width: Int,
        height: Int
    ) throws -> CatalogMonochromeMask {
        guard width > 0, height > 0 else {
            throw CatalogShapeRendererError.invalidDimensions(width: width, height: height)
        }
        let sampleCount = width.multipliedReportingOverflow(by: height)
        guard !sampleCount.overflow else {
            throw CatalogShapeRendererError.invalidDimensions(width: width, height: height)
        }
        guard supportedRendererIDs.contains(rendererID) else {
            throw CatalogShapeRendererError.unsupportedRendererID(rendererID)
        }

        var samples: [Bool] = []
        samples.reserveCapacity(sampleCount.partialValue)
        for y in 0..<height {
            for x in 0..<width {
                samples.append(try contains(
                    rendererID: rendererID,
                    normalizedX: (Double(x) + 0.5) / Double(width),
                    normalizedY: (Double(y) + 0.5) / Double(height),
                    elementWidth: Double(width),
                    elementHeight: Double(height)
                ))
            }
        }
        return try CatalogMonochromeMask(width: width, height: height, samples: samples)
    }

    /// Evaluates the non-zero fill at a normalized point. Coordinates use a
    /// top-left origin, x increasing rightward and y increasing downward.
    public static func contains(
        rendererID: String,
        normalizedX x: Double,
        normalizedY y: Double,
        elementWidth: Double,
        elementHeight: Double
    ) throws -> Bool {
        guard supportedRendererIDs.contains(rendererID) else {
            throw CatalogShapeRendererError.unsupportedRendererID(rendererID)
        }
        guard x.isFinite, y.isFinite, elementWidth.isFinite, elementHeight.isFinite else {
            throw CatalogShapeRendererError.nonFiniteCoordinate
        }
        guard elementWidth > 0, elementHeight > 0 else {
            // The public point API accepts Double dimensions. Do not convert a
            // finite but out-of-Int-range adversarial value, which could trap.
            throw CatalogShapeRendererError.invalidDimensions(width: 0, height: 0)
        }
        guard (0...1).contains(x), (0...1).contains(y) else { return false }

        switch rendererID {
        case "shape.rectangle":
            return true
        case "shape.roundedRectangle":
            return containsRoundedRectangle(
                x: x * elementWidth,
                y: y * elementHeight,
                width: elementWidth,
                height: elementHeight
            )
        case "shape.circle":
            let radius = 0.5 * min(elementWidth, elementHeight)
            let dx = x * elementWidth - elementWidth * 0.5
            let dy = y * elementHeight - elementHeight * 0.5
            return dx * dx + dy * dy <= radius * radius
        case "shape.oval":
            let dx = (x - 0.5) / 0.5
            let dy = (y - 0.5) / 0.5
            return dx * dx + dy * dy <= 1
        case "shape.heart":
            return nonZeroContains(point: Point(x: x, y: y), polygon: heartPolyline)
        case "shape.star":
            return nonZeroContains(point: Point(x: x, y: y), polygon: starPolygon)
        default:
            // The set check above makes this unreachable while preserving an
            // exhaustive defensive path if the registry evolves.
            throw CatalogShapeRendererError.unsupportedRendererID(rendererID)
        }
    }

    private struct Point: Sendable {
        let x: Double
        let y: Double
    }

    private struct Cubic: Sendable {
        let start: Point
        let control1: Point
        let control2: Point
        let end: Point

        func point(at t: Double) -> Point {
            let oneMinusT = 1 - t
            let a = oneMinusT * oneMinusT * oneMinusT
            let b = 3 * oneMinusT * oneMinusT * t
            let c = 3 * oneMinusT * t * t
            let d = t * t * t
            return Point(
                x: a * start.x + b * control1.x + c * control2.x + d * end.x,
                y: a * start.y + b * control1.y + c * control2.y + d * end.y
            )
        }
    }

    private static func containsRoundedRectangle(
        x: Double,
        y: Double,
        width: Double,
        height: Double
    ) -> Bool {
        let radius = 0.12 * min(width, height)
        if x >= radius && x <= width - radius { return true }
        if y >= radius && y <= height - radius { return true }
        let centreX = x < radius ? radius : width - radius
        let centreY = y < radius ? radius : height - radius
        let dx = x - centreX
        let dy = y - centreY
        return dx * dx + dy * dy <= radius * radius
    }

    /// A dense, deterministic flattening is used only for point sampling. The
    /// public geometry remains the exact six-cubic path published in the
    /// registry. 1,024 equal-t segments per cubic put the approximation far
    /// below a sample cell in the frozen 64×48 masks.
    private static let heartPolyline: [Point] = {
        let curves = [
            Cubic(
                start: Point(x: 0.50, y: 0.95),
                control1: Point(x: 0.44, y: 0.88),
                control2: Point(x: 0.08, y: 0.65),
                end: Point(x: 0.08, y: 0.34)
            ),
            Cubic(
                start: Point(x: 0.08, y: 0.34),
                control1: Point(x: 0.08, y: 0.15),
                control2: Point(x: 0.21, y: 0.05),
                end: Point(x: 0.36, y: 0.05)
            ),
            Cubic(
                start: Point(x: 0.36, y: 0.05),
                control1: Point(x: 0.44, y: 0.05),
                control2: Point(x: 0.49, y: 0.10),
                end: Point(x: 0.50, y: 0.17)
            ),
            Cubic(
                start: Point(x: 0.50, y: 0.17),
                control1: Point(x: 0.51, y: 0.10),
                control2: Point(x: 0.56, y: 0.05),
                end: Point(x: 0.64, y: 0.05)
            ),
            Cubic(
                start: Point(x: 0.64, y: 0.05),
                control1: Point(x: 0.79, y: 0.05),
                control2: Point(x: 0.92, y: 0.15),
                end: Point(x: 0.92, y: 0.34)
            ),
            Cubic(
                start: Point(x: 0.92, y: 0.34),
                control1: Point(x: 0.92, y: 0.65),
                control2: Point(x: 0.56, y: 0.88),
                end: Point(x: 0.50, y: 0.95)
            )
        ]
        let subdivisions = 1_024
        var points = [curves[0].start]
        points.reserveCapacity(curves.count * subdivisions + 1)
        for curve in curves {
            for step in 1...subdivisions {
                points.append(curve.point(at: Double(step) / Double(subdivisions)))
            }
        }
        return points
    }()

    private static let starPolygon: [Point] = (0..<10).map { index in
        let angle = -Double.pi / 2 + Double(index) * Double.pi / 5
        let radius = index.isMultiple(of: 2) ? 0.5 : 0.22
        return Point(
            x: 0.5 + cos(angle) * radius,
            y: 0.5 + sin(angle) * radius
        )
    }

    private static func nonZeroContains(point: Point, polygon: [Point]) -> Bool {
        guard polygon.count >= 3 else { return false }
        var windingNumber = 0
        for index in polygon.indices {
            let start = polygon[index]
            let end = polygon[(index + 1) % polygon.count]
            if isOnSegment(point, start, end) { return true }
            if start.y <= point.y {
                if end.y > point.y && signedArea(start, end, point) > 0 {
                    windingNumber += 1
                }
            } else if end.y <= point.y && signedArea(start, end, point) < 0 {
                windingNumber -= 1
            }
        }
        return windingNumber != 0
    }

    private static func signedArea(_ a: Point, _ b: Point, _ point: Point) -> Double {
        (b.x - a.x) * (point.y - a.y) - (point.x - a.x) * (b.y - a.y)
    }

    private static func isOnSegment(_ point: Point, _ a: Point, _ b: Point) -> Bool {
        let epsilon = 1e-12
        guard abs(signedArea(a, b, point)) <= epsilon else { return false }
        return point.x >= min(a.x, b.x) - epsilon
            && point.x <= max(a.x, b.x) + epsilon
            && point.y >= min(a.y, b.y) - epsilon
            && point.y <= max(a.y, b.y) + epsilon
    }
}
