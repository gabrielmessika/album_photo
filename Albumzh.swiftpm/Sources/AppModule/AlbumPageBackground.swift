import AlbumPhotoCore
import SwiftUI

struct AlbumPageBackground: View {
    let backgroundID: String
    var showsLeadingBinding = true

    var body: some View {
        switch BackgroundCatalog.theme(id: backgroundID).id {
        case "album.travelKraft":
            TexturedPageBackground(
                colors: [.brown.opacity(0.75), .orange.opacity(0.28)],
                label: "Fond Carnet de voyage"
            )
        case "album.minimalDark":
            TexturedPageBackground(
                colors: [.black, Color(red: 0.12, green: 0.15, blue: 0.22)],
                label: "Fond Nuit minimaliste"
            )
        default:
            ClassicSpiralPageBackground(showsLeadingBinding: showsLeadingBinding)
                .accessibilityLabel("Fond Album classique à spirales")
        }
    }
}

private struct TexturedPageBackground: View {
    let colors: [Color]
    let label: String

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.15))
            }
            .accessibilityLabel(label)
    }
}

private struct ClassicSpiralPageBackground: View {
    private let paper = Color(red: 0.96, green: 0.91, blue: 0.78)
    private let paperEdge = Color(red: 0.76, green: 0.60, blue: 0.38)
    let showsLeadingBinding: Bool

    var body: some View {
        GeometryReader { geometry in
            let bindingWidth = min(38, max(8, geometry.size.width * 0.14))
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [paperEdge, paper, paper],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                if showsLeadingBinding {
                    SpiralBindingView()
                        .frame(width: bindingWidth)
                        .offset(x: -bindingWidth * 0.2)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct SpiralBindingView: View {
    private let metal = Color(red: 0.18, green: 0.18, blue: 0.2)

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ForEach(0..<12, id: \.self) { _ in
                    Capsule()
                        .stroke(metal, lineWidth: 3)
                        .background(Capsule().fill(.black.opacity(0.08)))
                        .frame(width: 38, height: 10)
                    if geometry.size.height > 220 {
                        Spacer(minLength: 3)
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .accessibilityHidden(true)
    }
}
