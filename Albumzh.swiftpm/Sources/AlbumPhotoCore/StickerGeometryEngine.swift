import Foundation

public enum StickerGeometryEngine {
    /// 3:STK-005 / 3:STK-023 — 0.20 of the 2,400-unit short page edge,
    /// preserving the decoded payload aspect ratio on the 2,400 × 3,000 page.
    public static func initialGeometry(
        intrinsicAspectRatio: Double,
        center: GeometryPoint = GeometryPoint(x: 0.5, y: 0.5),
        order: Int64 = 0
    ) throws -> ElementGeometry {
        guard intrinsicAspectRatio.isFinite, intrinsicAspectRatio > 0 else {
            throw DomainValidationError.invalidSticker
        }
        let maximumCanonicalDimension = 0.20 * min(
            AlbumPhotoConstants.canonicalPageWidth,
            AlbumPhotoConstants.canonicalPageHeight
        )
        let canonicalWidth: Double
        let canonicalHeight: Double
        if intrinsicAspectRatio >= 1 {
            canonicalWidth = maximumCanonicalDimension
            canonicalHeight = maximumCanonicalDimension / intrinsicAspectRatio
        } else {
            canonicalHeight = maximumCanonicalDimension
            canonicalWidth = maximumCanonicalDimension * intrinsicAspectRatio
        }
        let geometry = ElementGeometry(
            centerX: min(1, max(0, center.x)),
            centerY: min(1, max(0, center.y)),
            width: canonicalWidth / AlbumPhotoConstants.canonicalPageWidth,
            height: canonicalHeight / AlbumPhotoConstants.canonicalPageHeight,
            rotationRadians: 0,
            order: order
        )
        try DomainValidator.validate(geometry)
        return geometry
    }

    /// 3:STK-007 / 3:STK-015 — first fits the new aspect ratio inside the
    /// previous unrotated bounds, then enlarges uniformly only if either
    /// physical dimension would fall below 0.05 of the short page edge.
    public static func replacementGeometry(
        from geometry: ElementGeometry,
        intrinsicAspectRatio: Double
    ) throws -> ElementGeometry {
        guard intrinsicAspectRatio.isFinite, intrinsicAspectRatio > 0 else {
            throw DomainValidationError.invalidSticker
        }
        let normalizedRatio = intrinsicAspectRatio
            * AlbumPhotoConstants.canonicalPageHeight
            / AlbumPhotoConstants.canonicalPageWidth
        var width: Double
        var height: Double
        if geometry.width / geometry.height > normalizedRatio {
            height = geometry.height
            width = height * normalizedRatio
        } else {
            width = geometry.width
            height = width / normalizedRatio
        }

        let minimumCanonicalDimension = 0.05 * min(
            AlbumPhotoConstants.canonicalPageWidth,
            AlbumPhotoConstants.canonicalPageHeight
        )
        let minimumWidth = minimumCanonicalDimension
            / AlbumPhotoConstants.canonicalPageWidth
        // The shared ELM geometry contract currently enforces 0.05 on both
        // normalized axes, which is stricter than 120 canonical units on the
        // long page edge. Respect that common lower bound as well.
        let minimumHeight = max(
            minimumCanonicalDimension / AlbumPhotoConstants.canonicalPageHeight,
            0.05
        )
        let scale = max(1, minimumWidth / width, minimumHeight / height)

        var result = geometry
        result.width = width * scale
        result.height = height * scale
        try DomainValidator.validate(result)
        return result
    }
}
