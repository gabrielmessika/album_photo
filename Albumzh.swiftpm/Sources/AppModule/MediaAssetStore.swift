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
}

struct StoredImageView: View {
    let assetID: UUID
    let store: MediaAssetStore
    var body: some View {
        if let image = UIImage(contentsOfFile: store.url(for: assetID).path) {
            Image(uiImage: image).resizable().scaledToFill()
        } else { Color.secondary.opacity(0.2) }
    }
}

struct PlacedMediaView: View {
    let placement: MediaPlacement
    let store: MediaAssetStore

    var body: some View {
        GeometryReader { geometry in
            StoredImageView(assetID: placement.assetID, store: store)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .scaleEffect(placement.normalizedScale)
                .offset(
                    x: placement.normalizedOffsetX
                        * geometry.size.width * 0.2
                        * (placement.normalizedScale - 1),
                    y: placement.normalizedOffsetY
                        * geometry.size.height * 0.2
                        * (placement.normalizedScale - 1)
                )
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
