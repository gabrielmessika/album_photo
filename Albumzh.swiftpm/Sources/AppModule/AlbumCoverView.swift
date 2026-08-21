import AlbumPhotoCore
import SwiftUI
import UIKit

struct AlbumCoverView: View {
    let album: AlbumSnapshot
    let library: LocalLibrarySnapshot
    let imageCache: PhotoImageCache

    @State private var cachedCover: UIImage?
    @State private var cachedCoverKey: String?

    var body: some View {
        GeometryReader { geometry in
            if let image = imageCache.coverImage(forKey: coverCacheKey)
                ?? (cachedCoverKey == coverCacheKey ? cachedCover : nil) {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            } else {
                liveCover(size: geometry.size)
            }
        }
        .aspectRatio(4.0 / 3.0, contentMode: .fit)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Couverture de l’album \(album.name)")
        .task(id: coverCacheKey) {
            await renderAndCacheCover()
        }
    }

    @ViewBuilder
    private func liveCover(size: CGSize) -> some View {
        ZStack {
            if let occurrence = resolvedOccurrence,
               let page = album.page(id: occurrence.pageID),
               let element = page.element(id: occurrence.elementID) {
                let crop = coverCrop(around: element.geometry)
                let renderedWidth = size.width / CGFloat(crop.width)
                let renderedHeight = renderedWidth * 5 / 4
                PageCompositionView(
                    page: page,
                    assets: assetMap,
                    imageCache: imageCache,
                    purpose: .thumbnail,
                    pageNumber: album.pages.firstIndex(where: { $0.id == page.id })
                        .map { $0 + 1 }
                )
                .frame(
                    width: renderedWidth,
                    height: renderedHeight
                )
                .position(
                    x: size.width / 2 + CGFloat(0.5 - crop.centerX) * renderedWidth,
                    y: size.height / 2 + CGFloat(0.5 - crop.centerY) * renderedHeight
                )
            } else {
                AlbumPageBackground(
                    selection: album.pages.first?.background ?? .classicSpiral,
                    imageCache: imageCache
                )
                Text(album.name)
                    .font(.title3.bold())
                    .foregroundStyle(fallbackTitleColor)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }

    private var coverCacheKey: String {
        if let fingerprint = try? AlbumLogicalFingerprint.hash(
            album: album,
            photoAssets: Array(assetMap.values)
        ) {
            return "cover-480x360-v2-\(fingerprint)"
        }
        return "cover-480x360-v2-\(album.id.uuidString)-\(album.updatedAt.timeIntervalSince1970)"
    }

    @MainActor
    private func renderAndCacheCover() async {
        cachedCover = nil
        cachedCoverKey = coverCacheKey
        if let cached = imageCache.coverImage(forKey: coverCacheKey) {
            cachedCover = cached
            return
        }

        await preloadCoverResources()
        guard !Task.isCancelled else { return }

        let size = CGSize(width: 480, height: 360)
        let renderer = ImageRenderer(
            content: liveCover(size: size)
        )
        renderer.proposedSize = ProposedViewSize(width: size.width, height: size.height)
        renderer.scale = 1
        guard let image = renderer.uiImage, !Task.isCancelled else { return }
        imageCache.storeCoverImage(image, forKey: coverCacheKey)
        cachedCover = image
    }

    @MainActor
    private func preloadCoverResources() async {
        let page: PageSnapshot?
        if let occurrence = resolvedOccurrence {
            page = album.page(id: occurrence.pageID)
        } else {
            page = album.pages.first
        }

        if let page {
            for element in page.orderedElements {
                switch element {
                case let .photo(frame):
                    if let placement = frame.content,
                       let metadata = assetMap[placement.assetID] {
                        _ = await imageCache.image(for: metadata, maximumPixelSize: 480)
                    }
                    if let reference = frame.decorativeFrame,
                       let definition = BuiltInDecorativeFrameCatalog.definition(
                           id: reference.catalogID,
                           version: reference.catalogVersion
                       ), definition.reference == reference {
                        _ = await CatalogAssetImageLoader.image(
                            dataAssetName: definition.dataAssetName,
                            contentHash: definition.contentHash,
                            cache: imageCache,
                            maximumPixelSize: 480
                        )
                    }
                case let .sticker(sticker):
                    if let definition = BuiltInStickerCatalog.definition(
                        id: sticker.resource.catalogID,
                        version: sticker.resource.catalogVersion
                    ), definition.reference == sticker.resource {
                        _ = await CatalogAssetImageLoader.image(
                            dataAssetName: definition.dataAssetName,
                            contentHash: definition.contentHash,
                            cache: imageCache,
                            maximumPixelSize: 320
                        )
                    }
                case .text:
                    break
                }
            }
            if case let .catalog(reference) = page.background,
               let hash = reference.fallbackContentHash {
                _ = await imageCache.catalogImage(
                    for: hash,
                    maximumPixelSize: 480
                )
            }
        }

        if let defaultHash = BackgroundCatalog.defaultTheme.fallbackContentHash {
            _ = await imageCache.catalogImage(
                for: defaultHash,
                maximumPixelSize: 480
            )
        }
    }

    private var resolvedOccurrence: (pageID: UUID, elementID: UUID)? {
        guard case let .pagePhoto(pageID, elementID)? = album.resolvedCoverOccurrence else {
            return nil
        }
        return (pageID, elementID)
    }

    private var assetMap: [UUID: PhotoAssetMetadata] {
        Dictionary(
            uniqueKeysWithValues: library.photoAssets
                .filter { $0.albumID == album.id }
                .map { ($0.metadata.id, $0.metadata) }
        )
    }

    private struct CoverCrop {
        let centerX: Double
        let centerY: Double
        let width: Double
    }

    private func coverCrop(around geometry: ElementGeometry) -> CoverCrop {
        // Une fenêtre 4:3 dans la page 4:5 a un rapport normalisé 5:3.
        let width = min(
            1,
            max(0.55, max(geometry.width * 1.2, geometry.height * 5 / 3 * 1.2))
        )
        let height = width * 3 / 5
        return CoverCrop(
            centerX: min(1 - width / 2, max(width / 2, geometry.centerX)),
            centerY: min(1 - height / 2, max(height / 2, geometry.centerY)),
            width: width
        )
    }

    private var fallbackTitleColor: Color {
        guard let background = album.pages.first?.background else { return .black }
        switch background {
        case .none:
            return .black
        case let .solid(color):
            let luminance = 0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue
            return luminance > 0.5 ? .black : .white
        case let .catalog(reference):
            return BackgroundCatalog.theme(id: reference.catalogID)?.textContrastHint == .lightText
                ? .white : .black
        }
    }
}

struct CoverPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appModel: AppModel

    let albumID: UUID

    private var album: AlbumSnapshot? { appModel.album(id: albumID) }

    var body: some View {
        NavigationStack {
            Group {
                if let album {
                    ScrollView {
                        VStack(spacing: 18) {
                            AlbumCoverView(
                                album: album,
                                library: appModel.librarySnapshot,
                                imageCache: appModel.imageCache
                            )
                            .frame(maxWidth: 420)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.16), radius: 8, y: 3)

                            LazyVStack(spacing: 10) {
                                occurrenceButton(
                                    title: "Automatique — première photo placée",
                                    symbol: "wand.and.stars",
                                    selection: .automatic,
                                    album: album,
                                    page: nil
                                )

                                ForEach(coverOccurrences(in: album), id: \.elementID) { occurrence in
                                    occurrenceButton(
                                        title: "Page \(occurrence.pageNumber) — photo \(occurrence.photoNumber)",
                                        symbol: "photo",
                                        selection: .pagePhoto(
                                            pageID: occurrence.page.id,
                                            elementID: occurrence.elementID
                                        ),
                                        album: album,
                                        page: occurrence.page
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    ProgressView("Chargement de la couverture…")
                }
            }
            .navigationTitle("Choisir la couverture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Terminé") { dismiss() }
                }
            }
        }
    }

    private func occurrenceButton(
        title: String,
        symbol: String,
        selection: CoverSelection,
        album: AlbumSnapshot,
        page: PageSnapshot?
    ) -> some View {
        Button {
            Task { _ = await appModel.setCover(selection, albumID: albumID) }
        } label: {
            HStack(spacing: 12) {
                if let page {
                    PageCompositionView(
                        page: page,
                        assets: Dictionary(
                            uniqueKeysWithValues: appModel.librarySnapshot.photoAssets
                                .filter { $0.albumID == albumID }
                                .map { ($0.metadata.id, $0.metadata) }
                        ),
                        imageCache: appModel.imageCache,
                        purpose: .thumbnail,
                        pageNumber: album.pages.firstIndex(where: { $0.id == page.id })
                            .map { $0 + 1 }
                    )
                    .frame(width: 48, height: 60)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    Image(systemName: symbol)
                        .frame(width: 48, height: 48)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                }

                Text(title)
                    .multilineTextAlignment(.leading)
                Spacer()
                if album.coverSelection == selection {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                        .accessibilityLabel("Sélectionnée")
                }
            }
            .padding(10)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Utilise cette occurrence déjà placée comme couverture")
    }

    private struct CoverOccurrence {
        let page: PageSnapshot
        let pageNumber: Int
        let elementID: UUID
        let photoNumber: Int
    }

    private func coverOccurrences(in album: AlbumSnapshot) -> [CoverOccurrence] {
        var result: [CoverOccurrence] = []
        for (pageIndex, page) in album.pages.enumerated() {
            var photoNumber = 0
            for element in page.orderedElements where element.photoFrame?.content != nil {
                photoNumber += 1
                result.append(CoverOccurrence(
                    page: page,
                    pageNumber: pageIndex + 1,
                    elementID: element.id,
                    photoNumber: photoNumber
                ))
            }
        }
        return result
    }
}
