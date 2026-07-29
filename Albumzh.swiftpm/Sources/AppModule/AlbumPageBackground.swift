import AlbumPhotoCore
import SwiftUI

struct AlbumPageBackground: View {
    let backgroundID: String

    var body: some View {
        // BG-008: an unknown or legacy identifier falls back to the default
        // visual theme without changing the stored diagnostic value.
        ClassicSpiralPageBackground()
            .accessibilityLabel("Fond Album classique à spirales")
    }
}

private struct ClassicSpiralPageBackground: View {
    private let paper = Color(red: 0.96, green: 0.91, blue: 0.78)
    private let paperEdge = Color(red: 0.76, green: 0.60, blue: 0.38)
    private let binding = Color(red: 0.28, green: 0.20, blue: 0.14)

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [paperEdge, paper, paper],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Rectangle()
                    .fill(binding.opacity(0.18))
                    .frame(width: 24)

                VStack {
                    ForEach(0..<9, id: \.self) { _ in
                        HStack(spacing: 0) {
                            Capsule()
                                .fill(binding)
                                .frame(width: 28, height: 4)
                                .offset(x: -9)
                            Circle()
                                .fill(binding.opacity(0.75))
                                .frame(width: 8, height: 8)
                                .offset(x: -5)
                        }
                        if geometry.size.height > 200 {
                            Spacer(minLength: 4)
                        }
                    }
                }
                .padding(.vertical, 14)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
