public struct CatalogPixelBounds: Sendable, Equatable, Hashable {
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int

    public init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

/// Pure alpha-mask geometry shared by the Apple renderer and Linux tests.
public enum DecorativeFrameAlphaGeometry {
    /// Returns the largest fully transparent rectangle containing the centre
    /// pixel. A row contributes only its contiguous transparent run through
    /// that centre, so irregular opaque decorations can never leak inside the
    /// returned aperture (3:SHR-013).
    public static func centralTransparentBounds(
        alphaValues: [UInt8],
        pixelWidth: Int,
        pixelHeight: Int,
        maximumTransparentAlpha: UInt8 = 8
    ) -> CatalogPixelBounds? {
        guard pixelWidth > 0, pixelHeight > 0,
              alphaValues.count == pixelWidth * pixelHeight else { return nil }

        let centerX = pixelWidth / 2
        let centerY = pixelHeight / 2
        func alpha(x: Int, y: Int) -> UInt8 {
            alphaValues[y * pixelWidth + x]
        }
        guard alpha(x: centerX, y: centerY) <= maximumTransparentAlpha else {
            return nil
        }

        var rowLeft = [Int](repeating: -1, count: pixelHeight)
        var rowRight = [Int](repeating: -1, count: pixelHeight)
        for y in 0..<pixelHeight
            where alpha(x: centerX, y: y) <= maximumTransparentAlpha {
            var left = centerX
            var right = centerX
            while left > 0,
                  alpha(x: left - 1, y: y) <= maximumTransparentAlpha {
                left -= 1
            }
            while right + 1 < pixelWidth,
                  alpha(x: right + 1, y: y) <= maximumTransparentAlpha {
                right += 1
            }
            rowLeft[y] = left
            rowRight[y] = right
        }

        var best = CatalogPixelBounds(x: centerX, y: centerY, width: 1, height: 1)
        var upperLeft = 0
        var upperRight = pixelWidth - 1
        for top in stride(from: centerY, through: 0, by: -1) {
            guard rowLeft[top] >= 0 else { break }
            upperLeft = max(upperLeft, rowLeft[top])
            upperRight = min(upperRight, rowRight[top])
            guard upperLeft <= upperRight else { break }

            var candidateLeft = upperLeft
            var candidateRight = upperRight
            for bottom in centerY..<pixelHeight {
                guard rowLeft[bottom] >= 0 else { break }
                candidateLeft = max(candidateLeft, rowLeft[bottom])
                candidateRight = min(candidateRight, rowRight[bottom])
                guard candidateLeft <= candidateRight else { break }
                let candidate = CatalogPixelBounds(
                    x: candidateLeft,
                    y: top,
                    width: candidateRight - candidateLeft + 1,
                    height: bottom - top + 1
                )
                if candidate.width * candidate.height > best.width * best.height {
                    best = candidate
                }
            }
        }
        return best
    }
}
