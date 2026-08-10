import Foundation

@main
enum ShapeGoldenGenerator {
    private static let rendererIDs = [
        "shape.rectangle",
        "shape.roundedRectangle",
        "shape.circle",
        "shape.oval",
        "shape.heart",
        "shape.star"
    ]

    static func main() throws {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let outputDirectory = root.appendingPathComponent(
            "docs/golden/shape-masks-v1",
            isDirectory: true
        )
        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )

        for rendererID in rendererIDs {
            let mask = try CatalogShapeRenderer.rasterize(
                rendererID: rendererID,
                width: 64,
                height: 48
            )
            let filename = rendererID.replacingOccurrences(of: ".", with: "-") + ".pbm"
            let data = Data(mask.portableBitmapASCII.utf8)
            try data.write(to: outputDirectory.appendingPathComponent(filename), options: .atomic)
        }
    }
}
