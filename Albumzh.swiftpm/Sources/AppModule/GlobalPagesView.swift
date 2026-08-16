import AlbumPhotoCore
import CoreTransferable
import SwiftUI
import UniformTypeIdentifiers

private extension UTType {
    static let albumPage = UTType(exportedAs: "com.albumphoto.canvas.page")
}

private struct PageDragPayload: Codable, Transferable, Sendable {
    let pageID: UUID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .albumPage)
    }
}

private struct PageDeletionRequest: Identifiable {
    let pageID: UUID
    let pageNumber: Int
    var id: UUID { pageID }
}

private struct InsertionPulse: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isBright = false

    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion ? 1 : (isBright ? 1 : 0.3))
            .animation(
                reduceMotion
                    ? nil
                    : .easeInOut(duration: 0.55).repeatForever(autoreverses: true),
                value: isBright
            )
            .onAppear { isBright = true }
    }
}

struct GlobalPagesView: View {
    @ObservedObject var model: EditorViewModel

    @State private var deletionRequest: PageDeletionRequest?
    @State private var insertionTargetPageID: UUID?
    @State private var isTerminalDropTargeted = false

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 260), spacing: 20)
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Vue globale")
                    .font(.headline)
                Spacer()
                Button("Ajouter une page", systemImage: "rectangle.stack.badge.plus") {
                    Task { await model.addPage() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(model.isReadOnly)
            }
            .padding()

            if let album = model.album {
                ScrollView {
                    VStack(spacing: 14) {
                        LazyVGrid(columns: columns, spacing: 22) {
                            ForEach(Array(album.pages.enumerated()), id: \.element.id) { index, page in
                                pageCard(page, number: index + 1, album: album)
                            }
                        }
                        terminalDropZone(album)
                    }
                    .padding()
                }
            } else {
                ProgressView("Chargement des pages…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .alert(item: $deletionRequest) { request in
            Alert(
                title: Text("Supprimer la page \(request.pageNumber) ?"),
                message: Text(
                    "Tous les cadres présents sur cette page seront retirés. Les photos originales resteront dans l’album."
                ),
                primaryButton: .destructive(Text("Supprimer")) {
                    Task { await model.deletePage(request.pageID) }
                },
                secondaryButton: .cancel(Text("Annuler"))
            )
        }
    }

    private func terminalDropZone(_ album: AlbumSnapshot) -> some View {
        Label("Déposer ici pour placer en dernière position", systemImage: "arrow.down.to.line")
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(
                .secondary.opacity(0.08),
                in: RoundedRectangle(cornerRadius: 10)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.secondary.opacity(0.35), style: StrokeStyle(dash: [6, 5]))
            }
            .overlay(alignment: .top) {
                if isTerminalDropTargeted {
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(height: 4)
                        .padding(.horizontal, 8)
                        .modifier(InsertionPulse())
                }
            }
            .dropDestination(
                for: PageDragPayload.self,
                action: { payloads, _ in
                    guard let source = payloads.first?.pageID,
                          !model.isReadOnly,
                          album.pages.last?.id != source,
                          album.pages.contains(where: { $0.id == source }) else {
                        return false
                    }
                    Task { await model.movePageToEnd(source) }
                    return true
                },
                isTargeted: { isTerminalDropTargeted = $0 }
            )
            .accessibilityHint("Accepte une page glissée pour la déplacer après toutes les autres.")
    }

    private func pageCard(
        _ page: PageSnapshot,
        number: Int,
        album: AlbumSnapshot
    ) -> some View {
        let isActive = page.id == model.activePageID
        let emptyFrameCount = page.elements.filter {
            $0.photoFrame?.content == nil && $0.photoFrame != nil
        }.count
        let qualityWarnings = page.elements.compactMap { element in
            photoQuality(for: element.photoFrame?.content)
        }.filter { $0 != .ok }

        return Button {
            model.showPage(page.id)
            model.presentationMode = .page
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                PageCompositionView(
                    page: page,
                    assets: Dictionary(
                        uniqueKeysWithValues: model.photos.map { ($0.id, $0) }
                    ),
                    imageCache: model.imageCache,
                    purpose: .thumbnail,
                    pageNumber: number
                )
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            isActive ? Color.accentColor : .secondary.opacity(0.35),
                            lineWidth: isActive ? 3 : 1
                        )
                }
                .shadow(color: .black.opacity(0.12), radius: 4, y: 2)

                HStack {
                    Label("Page \(number)", systemImage: "rectangle.portrait")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    if emptyFrameCount > 0 {
                        Label(
                            "\(emptyFrameCount) cadre(s) vide(s)",
                            systemImage: "exclamationmark.square"
                        )
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.orange)
                    }
                    if qualityWarnings.contains(.insufficient) {
                        Label("Qualité photo insuffisante", systemImage: "exclamationmark.triangle.fill")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.red)
                    } else if qualityWarnings.contains(.acceptable) {
                        Label("Qualité photo acceptable", systemImage: "exclamationmark.circle.fill")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.orange)
                    }
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Poignée de réorganisation")
                }
            }
        }
        .buttonStyle(.plain)
        .draggable(PageDragPayload(pageID: page.id))
        .overlay(alignment: .leading) {
            if insertionTargetPageID == page.id {
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: 5)
                    .padding(.vertical, 4)
                    .modifier(InsertionPulse())
            }
        }
        .dropDestination(
            for: PageDragPayload.self,
            action: { payloads, _ in
                guard let source = payloads.first?.pageID,
                      !model.isReadOnly,
                      source != page.id,
                      album.pages.contains(where: { $0.id == source }) else {
                    return false
                }
                Task { await model.movePage(source, before: page.id) }
                return true
            },
            isTargeted: { targeted in
                if targeted {
                    insertionTargetPageID = page.id
                } else if insertionTargetPageID == page.id {
                    insertionTargetPageID = nil
                }
            }
        )
        .contextMenu {
            Button("Déplacer avant", systemImage: "arrow.up") {
                Task { await model.movePageByOffset(page.id, delta: -1) }
            }
            .disabled(number == 1 || model.isReadOnly)

            Button("Déplacer après", systemImage: "arrow.down") {
                Task { await model.movePageByOffset(page.id, delta: 1) }
            }
            .disabled(number == album.pages.count || model.isReadOnly)

            Divider()

            Button("Supprimer la page", systemImage: "trash", role: .destructive) {
                deletionRequest = PageDeletionRequest(
                    pageID: page.id,
                    pageNumber: number
                )
            }
            .disabled(album.pages.count == 1 || model.isReadOnly)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(pageAccessibilityLabel(
            number: number,
            emptyFrameCount: emptyFrameCount,
            qualityWarnings: qualityWarnings
        ))
        .accessibilityHint("Ouvre cette page en édition")
        .accessibilityAction(named: "Déplacer avant") {
            guard number > 1, !model.isReadOnly else { return }
            Task { await model.movePageByOffset(page.id, delta: -1) }
        }
        .accessibilityAction(named: "Déplacer après") {
            guard number < album.pages.count, !model.isReadOnly else { return }
            Task { await model.movePageByOffset(page.id, delta: 1) }
        }
        .accessibilityAction(named: "Supprimer la page") {
            guard album.pages.count > 1, !model.isReadOnly else { return }
            deletionRequest = PageDeletionRequest(
                pageID: page.id,
                pageNumber: number
            )
        }
    }

    private func pageAccessibilityLabel(
        number: Int,
        emptyFrameCount: Int,
        qualityWarnings: [PhotoQualityState]
    ) -> String {
        var value = "Page \(number)"
        if emptyFrameCount > 0 {
            value += ", \(emptyFrameCount) cadre(s) photo vide(s)"
        }
        if qualityWarnings.contains(.insufficient) {
            value += ", qualité photo insuffisante"
        } else if qualityWarnings.contains(.acceptable) {
            value += ", qualité photo acceptable"
        }
        return value
    }

    private func photoQuality(for placement: PhotoPlacement?) -> PhotoQualityState? {
        guard let placement else { return nil }
        return DefaultPhotoQualityPolicy.state(for: placement)
    }
}
