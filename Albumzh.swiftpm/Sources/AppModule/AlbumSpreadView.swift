import AlbumPhotoCore
import SwiftUI

struct AlbumSpreadView: View {
    let model: AlbumEditorViewModel
    let assetStore: MediaAssetStore
    @State private var cropStartScale: Double?
    @State private var cropStartOffsetX: Double?
    @State private var cropStartOffsetY: Double?

    var body: some View {
        GeometryReader { geometry in
            let pages = model.visiblePages(availableWidth: geometry.size.width)
            let isClassic = BackgroundCatalog.theme(
                id: model.album.backgroundID
            ).id == Album.classicSpiralBackgroundID
            ZStack {
                HStack(spacing: pages.count == 2 ? 6 : 18) {
                    ForEach(pages) { page in
                        let pageNumber = (
                            model.album.pages.firstIndex(where: { $0.id == page.id }) ?? 0
                        ) + 1
                        let displayedPlacement = model.isCropping
                            && page.id == model.activePageID
                            ? model.cropDraft
                            : page.mediaPlacement
                        ZStack(alignment: .topTrailing) {
                            AlbumPageBackground(
                                backgroundID: model.album.backgroundID,
                                showsLeadingBinding: isClassic && pages.count == 1
                            )
                            .aspectRatio(4 / 5, contentMode: .fit)
                            .overlay {
                                if let placement = displayedPlacement {
                                    PlacedMediaView(placement: placement, store: assetStore)
                                        .padding(12)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .overlay(alignment: .bottomTrailing) {
                                Text("Page \(pageNumber)")
                                    .font(.caption.bold())
                                    .padding(7)
                                    .foregroundStyle(
                                        model.album.backgroundID == "album.minimalDark"
                                            ? .white : .black
                                    )
                                    .background(
                                        model.album.backgroundID == "album.minimalDark"
                                            ? Color.black.opacity(0.7)
                                            : Color.white.opacity(0.82),
                                        in: Capsule()
                                    )
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        model.activePageID == page.id
                                            ? Color.accentColor : .clear,
                                        lineWidth: 4
                                    )
                            }
                            .shadow(radius: 3)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            if !model.isCropping && page.mediaPlacement != nil {
                                Button("Recadrer page \(pageNumber)", systemImage: "crop") {
                                    model.beginCropping(pageID: page.id)
                                }
                                .labelStyle(.iconOnly)
                                .buttonStyle(.borderedProminent)
                                .padding(10)
                            }

                            if model.isCropping && page.id == model.activePageID {
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        Color.yellow,
                                        style: StrokeStyle(lineWidth: 2, dash: [7, 5])
                                    )
                                    .padding(12)
                                    .allowsHitTesting(false)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard !model.isCropping else { return }
                            model.activePageID = page.id
                        }
                        .accessibilityLabel("Page \(pageNumber)")
                        .simultaneousGesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    guard model.isCropping,
                                          page.id == model.activePageID,
                                          let draft = model.cropDraft else { return }
                                    if cropStartScale == nil {
                                        cropStartScale = draft.normalizedScale
                                    }
                                    model.updateCrop(
                                        scale: (cropStartScale ?? 1) * value.magnification
                                    )
                                }
                                .onEnded { _ in cropStartScale = nil },
                            including: model.isCropping ? .all : .none
                        )
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 1)
                                .onChanged { value in
                                    guard model.isCropping,
                                          page.id == model.activePageID,
                                          let draft = model.cropDraft else { return }
                                    if cropStartOffsetX == nil {
                                        cropStartOffsetX = draft.normalizedOffsetX
                                        cropStartOffsetY = draft.normalizedOffsetY
                                    }
                                    let width = max(1, geometry.size.width * 0.35)
                                    let height = max(1, geometry.size.height * 0.35)
                                    model.updateCrop(
                                        offsetX: (cropStartOffsetX ?? 0)
                                            + value.translation.width / width,
                                        offsetY: (cropStartOffsetY ?? 0)
                                            + value.translation.height / height
                                    )
                                }
                                .onEnded { _ in
                                    cropStartOffsetX = nil
                                    cropStartOffsetY = nil
                                },
                            including: model.isCropping ? .all : .none
                        )
                    }
                }

                if isClassic && pages.count == 2 {
                    SpiralBindingView()
                        .frame(width: 42)
                        .padding(.vertical, 10)
                }
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .highPriorityGesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            guard !model.isCropping else { return }
                            let horizontal = abs(value.translation.width)
                            let vertical = abs(value.translation.height)
                            guard horizontal > vertical * 1.25 else { return }
                            model.navigateBySwipe(
                                towardNext: value.translation.width < 0,
                                availableWidth: geometry.size.width
                            )
                        }
                )
        }
        .frame(minHeight: 280)
    }
}
