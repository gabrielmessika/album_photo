import AlbumPhotoCore
import SwiftUI

struct AlbumSpreadView: View {
    let model: AlbumEditorViewModel

    var body: some View {
        GeometryReader { geometry in
            let pages = model.visiblePages(availableWidth: geometry.size.width)
            HStack(spacing: 18) {
                ForEach(pages) { page in
                    Button {
                        model.activePageID = page.id
                    } label: {
                        AlbumPageBackground(backgroundID: model.album.backgroundID)
                            .aspectRatio(4 / 5, contentMode: .fit)
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
                            model.goNext()
                        } else {
                            model.goPrevious()
                        }
                    }
            )
        }
        .frame(minHeight: 280)
    }
}
