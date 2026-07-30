import AlbumPhotoCore
import SwiftUI

struct AlbumSpreadView: View {
    let model: AlbumEditorViewModel

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
                        Button {
                            model.activePageID = page.id
                        } label: {
                            AlbumPageBackground(
                                backgroundID: model.album.backgroundID,
                                showsLeadingBinding: isClassic && pages.count == 1
                            )
                            .aspectRatio(4 / 5, contentMode: .fit)
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
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Page \(pageNumber)")
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
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            let horizontal = abs(value.translation.width)
                            let vertical = abs(value.translation.height)
                            guard horizontal > vertical * 1.25 else { return }
                            if value.translation.width < 0 {
                                model.goPrevious()
                            } else {
                                model.goNext()
                            }
                        }
                )
        }
        .frame(minHeight: 280)
    }
}
