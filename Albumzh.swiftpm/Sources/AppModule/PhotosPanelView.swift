import AlbumPhotoCore
import SwiftUI

private struct PhotoDeletionRequest: Identifiable {
    let asset: PhotoAssetMetadata
    var id: UUID { asset.id }
}

struct PhotosPanelView: View {
    @ObservedObject var model: EditorViewModel

    @State private var showsSources = false
    @State private var showsOtherAlbums = false
    @State private var deletionRequest: PhotoDeletionRequest?

    private let columns = [
        GridItem(.adaptive(minimum: 92), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("Ajouter des photos", systemImage: "photo.badge.plus") {
                    showsSources = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    model.isImportTaskRunning || model.importProgress != nil || model.isReadOnly
                )

                Spacer()

                Button("Aide", systemImage: "questionmark.circle") {
                    model.helpContext = .photos
                }
                .labelStyle(.iconOnly)
            }

            HStack {
                Toggle(isOn: $model.hidesUsedPhotos) {
                    Label(
                        model.hidesUsedPhotos
                            ? "Afficher les photos utilisées"
                            : "Masquer les photos utilisées",
                        systemImage: model.hidesUsedPhotos ? "eye" : "eye.slash"
                    )
                }
                .toggleStyle(.button)

                Menu {
                    sortButton("Date de prise de vue", option: .capturedAt)
                    sortButton("Nom", option: .filename)
                    sortButton("Date d’import", option: .importedAt)
                    Divider()
                    Button(
                        model.sortsAscending ? "Ordre décroissant" : "Ordre croissant",
                        systemImage: "arrow.up.arrow.down"
                    ) {
                        model.sortsAscending.toggle()
                        Task { await model.reloadPhotos() }
                    }
                } label: {
                    Label("Trier", systemImage: "arrow.up.arrow.down")
                }
                .disabled(model.photos.count < 2)
            }
            .font(.caption)

            if let choice = model.photoChoiceMode {
                HStack(alignment: .top, spacing: 8) {
                    Label(choice.title, systemImage: "scope")
                        .font(.subheadline.weight(.semibold))
                    Spacer(minLength: 4)
                    Button("Annuler le choix", systemImage: "xmark") {
                        model.cancelPhotoChoice()
                    }
                    .labelStyle(.iconOnly)
                }
                .padding(9)
                .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
                .accessibilityElement(children: .contain)
            }

            if let progress = model.importProgress {
                PhotoImportProgressView(progress: progress)
            }

            if model.isImportTaskRunning {
                Button("Annuler l’import", systemImage: "xmark.circle") {
                    model.cancelImportTask()
                }
                .buttonStyle(.bordered)
                .accessibilityHint(
                    "Interrompt l’opération après la copie en cours et conserve les erreurs restant à reprendre."
                )
            }

            if !model.failedImports.isEmpty {
                VStack(alignment: .leading, spacing: 7) {
                    Label(
                        "\(model.failedImports.count) import(s) à reprendre",
                        systemImage: "exclamationmark.triangle"
                    )
                    .font(.subheadline.weight(.semibold))

                    ForEach(model.failedImports) { failure in
                        VStack(alignment: .leading, spacing: 1) {
                            Text(failure.url.lastPathComponent)
                                .font(.caption.weight(.medium))
                                .lineLimit(1)
                            Text("\(failure.status.rawValue) — \(failure.message)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .accessibilityElement(children: .combine)
                    }

                    HStack {
                        Button("Réessayer uniquement les erreurs", systemImage: "arrow.clockwise") {
                            model.startImportTask { await model.retryFailedImports() }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(model.isImportTaskRunning || model.isReadOnly)

                        Button("Ignorer") { model.discardFailedImports() }
                            .buttonStyle(.bordered)
                            .disabled(model.isImportTaskRunning)
                    }
                }
                .padding(10)
                .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            }

            if model.photos.isEmpty {
                ContentUnavailableView {
                    Label("Aucune photo", systemImage: "photo.on.rectangle")
                } description: {
                    Text("Importez des photos statiques pour les placer dans la page.")
                } actions: {
                    Button("Ajouter des photos") { showsSources = true }
                        .disabled(model.isImportTaskRunning || model.isReadOnly)
                }
            } else if model.visiblePhotos.isEmpty {
                ContentUnavailableView(
                    "Toutes les photos sont utilisées",
                    systemImage: "eye.slash",
                    description: Text("Affichez les photos utilisées pour les placer une nouvelle fois.")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(model.visiblePhotos) { asset in
                            PhotoPanelTile(
                                asset: asset,
                                occurrenceCount: model.occurrenceCount(of: asset.id),
                                cache: model.imageCache,
                                onPlace: {
                                    Task { await model.placePhoto(asset.id) }
                                },
                                onDelete: {
                                    deletionRequest = PhotoDeletionRequest(asset: asset)
                                }
                            )
                            .disabled(model.isReadOnly)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            Button("Ajouter un cadre vide", systemImage: "rectangle.dashed") {
                Task { await model.addEmptyPhotoFrame() }
            }
            .buttonStyle(.bordered)
            .disabled(model.isReadOnly)
        }
        .padding(12)
        .sheet(isPresented: $showsSources) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 14) {
                    ApplePhotoImportControls(model: model)

                    if let progress = model.importProgress {
                        PhotoImportProgressView(progress: progress)
                    }

                    Button {
                        showsSources = false
                        showsOtherAlbums = true
                    } label: {
                        Label("Depuis vos autres albums", systemImage: "rectangle.stack")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    .disabled(model.otherActiveAlbums.isEmpty || model.isReadOnly)

                    Spacer()
                }
                .padding()
                .navigationTitle("Ajouter des photos")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button("Fermer") { showsSources = false }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showsOtherAlbums) {
            OtherAlbumsPhotoPicker(model: model)
        }
        .onAppear { presentSourcesForEmptyChoiceIfNeeded() }
        .onChange(of: model.photoChoiceMode) { _, _ in
            presentSourcesForEmptyChoiceIfNeeded()
        }
        .alert(item: $deletionRequest) { request in
            Alert(
                title: Text(
                    "Supprimer « \(request.asset.originalFilename ?? "Photo") » de l’album ?"
                ),
                message: Text(
                    "La copie de cet album sera retirée. La photothèque Apple, Fichiers et les autres albums ne seront pas modifiés."
                ),
                primaryButton: .destructive(Text("Supprimer")) {
                    Task { await model.removePhotoAsset(request.asset.id) }
                },
                secondaryButton: .cancel(Text("Annuler"))
            )
        }
    }

    @ViewBuilder
    private func sortButton(_ title: String, option: PhotoSortOption) -> some View {
        Button {
            model.photoSort = option
            Task { await model.reloadPhotos() }
        } label: {
            if model.photoSort == option {
                Label(title, systemImage: "checkmark")
            } else {
                Text(title)
            }
        }
    }

    private func presentSourcesForEmptyChoiceIfNeeded() {
        guard model.photoChoiceMode != nil,
              model.photos.isEmpty,
              !model.isImportTaskRunning else { return }
        showsSources = true
    }
}

private struct PhotoImportProgressView: View {
    let progress: ImportProgressState

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ProgressView(value: progress.fraction) {
                Text("Progression globale")
            } currentValueLabel: {
                Text("\(progress.completed) sur \(progress.total)")
            }

            ForEach(progress.items) { item in
                HStack(spacing: 8) {
                    statusView(item.status)
                    Text(item.filename)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(statusLabel(item.status))
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
                .accessibilityElement(children: .combine)
            }

            HStack(spacing: 12) {
                Label("Import en cours", systemImage: "arrow.down.circle")
                if progress.waitingCount > 0 {
                    Label("\(progress.waitingCount) en attente", systemImage: "clock")
                }
                if progress.copiedCount > 0 {
                    Label(
                        "\(progress.copiedCount) copie(s) terminée(s)",
                        systemImage: "checkmark.circle"
                    )
                }
                if progress.failedCount > 0 {
                    Label(
                        "\(progress.failedCount) échec(s)",
                        systemImage: "exclamationmark.triangle"
                    )
                }
            }
            .font(.caption2)
        }
        .padding(8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func statusView(_ status: ImportFileProgressStatus) -> some View {
        switch status {
        case .waiting:
            Image(systemName: "clock")
                .foregroundStyle(.secondary)
        case .copying:
            ProgressView()
                .controlSize(.small)
        case .copied:
            Image(systemName: "checkmark.circle")
                .foregroundStyle(.green)
        case .failed:
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(.orange)
        }
    }

    private func statusLabel(_ status: ImportFileProgressStatus) -> String {
        switch status {
        case .waiting: "En attente"
        case .copying: "Copie en cours"
        case .copied: "Copie terminée"
        case .failed: "Échec"
        }
    }
}

private struct PhotoPanelTile: View {
    let asset: PhotoAssetMetadata
    let occurrenceCount: Int
    let cache: PhotoImageCache
    let onPlace: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onPlace) {
            VStack(alignment: .leading, spacing: 5) {
                ZStack(alignment: .topTrailing) {
                    squareThumbnail(maximumPixelSize: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text("×\(occurrenceCount)")
                        .font(.caption2.bold().monospacedDigit())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.regularMaterial, in: Capsule())
                        .padding(5)
                        .accessibilityLabel("Utilisée \(occurrenceCount) fois")
                }

                Text(asset.originalFilename ?? "Photo")
                    .font(.caption2)
                    .lineLimit(1)
                Label("Disponible", systemImage: "checkmark.circle")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .draggable(PhotoAssetDragPayload(assetID: asset.id)) {
            StoredPhotoImage(
                metadata: asset,
                cache: cache,
                maximumPixelSize: 240
            )
            .scaledToFill()
            .frame(width: 96, height: 96)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .contextMenu {
            Button("Placer sur la page", systemImage: "photo.badge.plus", action: onPlace)
            if occurrenceCount > 0 {
                Button("Utilisée \(occurrenceCount) fois", systemImage: "lock") {}
                    .disabled(true)
            }
            Button("Supprimer de cet album", systemImage: "trash", role: .destructive) {
                onDelete()
            }
            .disabled(occurrenceCount > 0)
        }
        .accessibilityLabel(
            "\(asset.originalFilename ?? "Photo"), Disponible, utilisée \(occurrenceCount) fois"
        )
        .accessibilityHint(
            occurrenceCount > 0
                ? "Utilisée \(occurrenceCount) fois. Faites glisser pour la placer. La suppression est indisponible."
                : "Touchez ou faites glisser pour remplir le cadre sélectionné ou créer un cadre."
        )
    }

    private func squareThumbnail(maximumPixelSize: Int) -> some View {
        GeometryReader { geometry in
            StoredPhotoImage(
                metadata: asset,
                cache: cache,
                maximumPixelSize: maximumPixelSize
            )
            .scaledToFill()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }
}

private struct OtherAlbumsPhotoPicker: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var model: EditorViewModel

    @State private var sourceAlbumID: UUID?
    @State private var sourcePhotos: [PhotoAssetMetadata] = []
    @State private var selection = Set<UUID>()
    @State private var selectionOrder: [UUID] = []
    @State private var unavailablePhotoIDs = Set<UUID>()
    @State private var isLoading = false

    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 12)]

    var body: some View {
        NavigationStack {
            Group {
                if let sourceAlbumID {
                    photoGrid(sourceAlbumID: sourceAlbumID)
                } else {
                    List(model.otherActiveAlbums) { album in
                        Button {
                            self.sourceAlbumID = album.id
                            Task { await load(album.id) }
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.stack")
                                VStack(alignment: .leading) {
                                    Text(album.name)
                                    Text(album.updatedAt, format: .dateTime.day().month().year())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Depuis vos autres albums")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(sourceAlbumID == nil ? "Fermer" : "Albums") {
                        if sourceAlbumID == nil { dismiss() }
                        else {
                            sourceAlbumID = nil
                            sourcePhotos = []
                            selection = []
                            selectionOrder = []
                        }
                    }
                }
                if let sourceAlbumID {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Ajouter \(selection.count) photos") {
                            let ordered = selectionOrder.filter(selection.contains)
                            Task {
                                if await model.reusePhotos(ordered, from: sourceAlbumID) {
                                    dismiss()
                                } else {
                                    // A physical preflight can fail after the
                                    // grid was loaded (file removed/corrupted).
                                    // Reclassify it immediately as Réessayer.
                                    await load(sourceAlbumID)
                                }
                            }
                        }
                        .disabled(selection.isEmpty || model.isReadOnly)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func photoGrid(sourceAlbumID: UUID) -> some View {
        if isLoading {
            ProgressView("Chargement des photos…")
        } else if sourcePhotos.isEmpty {
            ContentUnavailableView(
                "Aucune photo disponible",
                systemImage: "photo",
                description: Text("Cet album ne contient aucune photo réutilisable.")
            )
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(sourcePhotos) { asset in
                        let alreadyAdded = model.currentPhotoHashes.contains(asset.contentHash)
                        let isUnavailable = unavailablePhotoIDs.contains(asset.id)
                        Button {
                            if isUnavailable {
                                Task { await load(sourceAlbumID) }
                            } else if selection.contains(asset.id) {
                                selection.remove(asset.id)
                                selectionOrder.removeAll { $0 == asset.id }
                            } else {
                                selection.insert(asset.id)
                                selectionOrder.append(asset.id)
                            }
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                GeometryReader { geometry in
                                    StoredPhotoImage(
                                        metadata: asset,
                                        cache: model.imageCache,
                                        maximumPixelSize: 360
                                    )
                                    .scaledToFill()
                                    .frame(
                                        width: geometry.size.width,
                                        height: geometry.size.height
                                    )
                                    .clipped()
                                }
                                .aspectRatio(1, contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                                Image(systemName: alreadyAdded
                                    ? "checkmark.circle.fill"
                                    : isUnavailable
                                        ? "arrow.clockwise.circle.fill"
                                        : selection.contains(asset.id)
                                            ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(
                                        alreadyAdded || isUnavailable
                                            ? Color.secondary : Color.accentColor,
                                        Color.white
                                    )
                                    .padding(6)
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(alreadyAdded)
                        .accessibilityLabel(
                            alreadyAdded
                                ? "\(asset.originalFilename ?? "Photo"), déjà ajoutée"
                                : isUnavailable
                                    ? "\(asset.originalFilename ?? "Photo"), fichier indisponible, Réessayer"
                                    : asset.originalFilename ?? "Photo"
                        )
                        .accessibilityValue(selection.contains(asset.id) ? "Sélectionnée" : "Non sélectionnée")
                    }
                }
                .padding()
            }
        }
    }

    private func load(_ albumID: UUID) async {
        isLoading = true
        let photos = await model.photos(inOtherAlbum: albumID)
        var unavailable = Set<UUID>()
        for photo in photos where !(await model.isPhotoBlobAvailable(photo)) {
            unavailable.insert(photo.id)
        }
        sourcePhotos = photos
        unavailablePhotoIDs = unavailable
        selection.subtract(unavailable)
        selectionOrder.removeAll { unavailable.contains($0) }
        isLoading = false
    }
}
