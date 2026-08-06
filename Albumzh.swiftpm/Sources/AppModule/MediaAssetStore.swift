import AlbumPhotoCore
import Foundation
import SwiftUI
import UIKit

final class MediaAssetStore: @unchecked Sendable {
    let directory: URL
    init(directory: URL) { self.directory = directory }
    func importData(_ data: Data) throws -> UUID {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let id = UUID()
        try data.write(to: url(for: id), options: .atomic)
        return id
    }
    func url(for id: UUID) -> URL { directory.appendingPathComponent(id.uuidString) }
    func image(for id: UUID) -> UIImage? {
        UIImage(contentsOfFile: url(for: id).path)
    }
}

struct StoredImageView: View {
    let assetID: UUID
    let store: MediaAssetStore
    var body: some View {
        if let image = store.image(for: assetID) {
            Image(uiImage: image).resizable().scaledToFill()
        } else { Color.secondary.opacity(0.2) }
    }
}

struct PlacedMediaView: View {
    let placement: MediaPlacement
    let store: MediaAssetStore

    var body: some View {
        GeometryReader { geometry in
            if let image = store.image(for: placement.assetID) {
                let frameSize = geometry.size
                let imageRatio = image.size.width / max(1, image.size.height)
                let frameRatio = frameSize.width / max(1, frameSize.height)
                let baseWidth = imageRatio > frameRatio
                    ? frameSize.height * imageRatio
                    : frameSize.width
                let baseHeight = imageRatio > frameRatio
                    ? frameSize.height
                    : frameSize.width / max(0.001, imageRatio)
                let renderedWidth = baseWidth * placement.normalizedScale
                let renderedHeight = baseHeight * placement.normalizedScale
                let maximumX = max(0, (renderedWidth - frameSize.width) / 2)
                let maximumY = max(0, (renderedHeight - frameSize.height) / 2)

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameSize.width, height: frameSize.height)
                    .scaleEffect(placement.normalizedScale)
                    .offset(
                        x: placement.normalizedOffsetX * maximumX,
                        y: placement.normalizedOffsetY * maximumY
                    )
            } else {
                Color.secondary.opacity(0.2)
            }
        }
        .clipped()
    }
}

struct PageThumbnailView: View {
    let page: Page
    let backgroundID: String
    let assetStore: MediaAssetStore

    var body: some View {
        AlbumPageBackground(backgroundID: backgroundID)
            .aspectRatio(4 / 5, contentMode: .fit)
            .overlay {
                if let placement = page.mediaPlacement {
                    PlacedMediaView(placement: placement, store: assetStore)
                        .padding(4)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
