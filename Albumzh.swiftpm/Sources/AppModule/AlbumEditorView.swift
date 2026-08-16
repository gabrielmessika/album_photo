import AlbumPhotoCore
import SwiftUI

private struct RotationEditorRequest: Identifiable {
    let elementID: UUID
    let initialRadians: Double
    var id: UUID { elementID }
}

private struct PhotoDescriptionRequest: Identifiable {
    let pageID: UUID
    let elementID: UUID
    let initialDescription: String
    var id: UUID { elementID }
}

struct AlbumEditorView: View {
    @EnvironmentObject private var appModel: AppModel
    let albumID: UUID

    var body: some View {
        AlbumEditorScene(albumID: albumID, appModel: appModel)
    }
}

private struct AlbumEditorScene: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @StateObject private var model: EditorViewModel
    @State private var mobilePanel: EditorPanel?
    @State private var showsRename = false
    @State private var rotationRequest: RotationEditorRequest?
    @State private var photoDescriptionRequest: PhotoDescriptionRequest?
    @State private var isClosing = false
    @State private var lifecycleTask: Task<Void, Never>?
    @State private var lifecycleOperationBlockTokens: [UUID] = []
    @State private var showsInspector = true

    init(albumID: UUID, appModel: AppModel) {
        _model = StateObject(
            wrappedValue: EditorViewModel(albumID: albumID, appModel: appModel)
        )
    }

    var body: some View {
        NavigationStack {
            responsiveContent
                .navigationTitle(model.album?.name ?? "Album")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { editorToolbar }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    bottomCommands
                }
        }
        .interactiveDismissDisabled()
        .task { await model.load() }
        .onDisappear {
            guard !isClosing else { return }
            isClosing = true
            model.cancelImportTask()
            let closingToken = model.beginClosingTransition()
            let pending = lifecycleTask
            Task {
                defer { model.endClosingTransition(closingToken) }
                await pending?.value
                _ = await model.close()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            enqueueLifecycleTransition(phase)
        }
        .onChange(of: model.presentationMode) { oldMode, newMode in
            if newMode != .page {
                model.cancelPhotoChoice()
                mobilePanel = nil
            }
            if newMode == .preview, oldMode != .preview {
                model.beginPreviewSession()
            } else if oldMode == .preview, newMode != .preview {
                model.endPreviewSession()
            }
        }
        .sheet(isPresented: $showsRename) {
            EditorRenameSheet(initialName: model.album?.name ?? "") { name in
                showsRename = false
                Task { await model.renameAlbum(to: name) }
            }
        }
        .sheet(item: $rotationRequest) { request in
            ElementRotationSheet(
                initialRadians: request.initialRadians,
                onPreview: { degrees in
                    model.previewElementRotation(
                        elementID: request.elementID,
                        degrees: degrees
                    )
                },
                onCancel: {
                    model.cancelElementRotationPreview(elementID: request.elementID)
                    rotationRequest = nil
                },
                onConfirm: { degrees in
                    let elementID = request.elementID
                    rotationRequest = nil
                    Task {
                        await model.commitElementRotationPreview(
                            elementID: elementID,
                            degrees: degrees
                        )
                    }
                }
            )
        }
        .sheet(item: $photoDescriptionRequest) { request in
            PhotoDescriptionSheet(initialDescription: request.initialDescription) {
                description in
                photoDescriptionRequest = nil
                Task {
                    await model.updatePhotoAccessibilityDescription(
                        description,
                        elementID: request.elementID,
                        pageID: request.pageID
                    )
                }
            }
        }
        .sheet(item: $model.helpContext) { context in
            HelpView(context: context)
        }
        .alert(
            "Une action n’a pas pu être terminée",
            isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { if !$0 { model.clearError() } }
            )
        ) {
            if model.saveState == .failed {
                Button("Réessayer la sauvegarde") { Task { await model.save() } }
            }
            Button("OK") { model.clearError() }
        } message: {
            Text(model.errorMessage ?? "")
        }
        .alert(
            "Enveloppe recommandée dépassée",
            isPresented: Binding(
                get: { model.capacityWarning != nil },
                set: { if !$0 { model.clearCapacityWarning() } }
            )
        ) {
            Button("Continuer") { model.clearCapacityWarning() }
        } message: {
            Text(model.capacityWarning ?? "")
        }
        .alert(item: $model.layoutTemplateConfirmation) { request in
            Alert(
                title: Text("Appliquer cette mise en page ?"),
                message: Text(
                    request.removedPhotoCount == 1
                        ? "Une occurrence photo sera retirée de la page. La photo originale restera disponible dans Photos."
                        : "\(request.removedPhotoCount) occurrences photo seront retirées de la page. Les originaux resteront disponibles dans Photos."
                ),
                primaryButton: .default(Text("Appliquer")) {
                    Task { await model.confirmLayoutTemplateApplication() }
                },
                secondaryButton: .cancel(Text("Annuler")) {
                    model.cancelLayoutTemplateApplication()
                }
            )
        }
        .alert(
            "Activer la mise en page auto ?",
            isPresented: $model.showsAutomaticLayoutConfirmation
        ) {
            Button("Activer") {
                Task { await model.confirmAutomaticLayout() }
            }
            Button("Annuler", role: .cancel) {
                model.cancelAutomaticLayout()
            }
        } message: {
            Text(
                "Les cadres vides seront retirés et les cadres photo remplis seront réorganisés. Les photos originales, les textes, les stickers et le fond seront conservés."
            )
        }
    }

    @ViewBuilder
    private var responsiveContent: some View {
        if horizontalSizeClass == .regular,
           model.presentationMode == .page {
            HStack(spacing: 0) {
                if model.cropDraft == nil {
                    editorRail
                    Divider()
                }
                pageWorkspace
                if model.cropDraft == nil, showsInspector {
                    Divider()
                    regularInspector
                        .frame(width: 340)
                }
            }
        } else if model.presentationMode == .page,
                  model.cropDraft == nil,
                  let mobilePanel {
            VStack(spacing: 0) {
                pageWorkspace
                Divider()
                compactPanel(mobilePanel)
            }
        } else {
            modeContent
        }
    }

    @ViewBuilder
    private var modeContent: some View {
        switch model.presentationMode {
        case .page:
            pageWorkspace
        case .global:
            GlobalPagesView(model: model)
        case .preview:
            PreviewPageView(model: model)
        }
    }

    private var pageWorkspace: some View {
        VStack(spacing: 0) {
            if model.isReadOnly {
                HStack(spacing: 10) {
                    Label(
                        "Lecture seule — cet album est déjà ouvert dans une autre fenêtre.",
                        systemImage: "lock"
                    )
                    .font(.caption)

                    Spacer(minLength: 4)

                    Button("Réessayer") {
                        Task { await model.retryEditAccess() }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(model.isLoading)
                    .accessibilityHint(
                        "Tente de reprendre l’édition si l’autre fenêtre a libéré l’album."
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(7)
                .background(Color.orange.opacity(0.16))
            }

            EditablePageCanvas(model: model)

            pageWorkspaceCommands
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.bar)
        }
    }

    private var pageWorkspaceCommands: some View {
        ViewThatFits(in: .horizontal) {
            pageWorkspaceCommandRow(addPhotoTitle: "Ajouter une photo")
                .fixedSize(horizontal: true, vertical: false)
            pageWorkspaceCommandRow(addPhotoTitle: "Ajouter")
                .fixedSize(horizontal: true, vertical: false)
            pageWorkspaceCommandRow(addPhotoTitle: nil)
                .fixedSize(horizontal: true, vertical: false)
            VStack(spacing: 6) {
                HStack(spacing: 14) {
                    if model.cropDraft == nil {
                        addPhotoButton(title: nil)
                        shuffleLayoutButton
                    }
                    CanvasZoomControls(model: model)
                }
                pageNavigation
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .frame(maxWidth: .infinity)
    }

    private func pageWorkspaceCommandRow(addPhotoTitle: String?) -> some View {
        HStack(spacing: 14) {
            if model.cropDraft == nil {
                addPhotoButton(title: addPhotoTitle)
                shuffleLayoutButton
            }
            CanvasZoomControls(model: model)
            Divider().frame(height: 26)
            pageNavigation
        }
    }

    private func addPhotoButton(title: String?) -> some View {
        Button {
            model.beginNewPhotoFrameChoice()
            openPhotosPanel()
        } label: {
            if let title {
                Label(title, systemImage: "photo.badge.plus")
                    .lineLimit(1)
            } else {
                Image(systemName: "photo.badge.plus")
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(model.isReadOnly)
        .accessibilityLabel("Ajouter une photo")
    }

    private var shuffleLayoutButton: some View {
        Button("Changer aléatoirement la mise en page", systemImage: "dice") {
            Task { await model.shuffleLayout() }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(!model.canShuffleLayout || model.cropDraft != nil)
        .accessibilityLabel("Changer aléatoirement la mise en page")
        .accessibilityHint(
            model.canShuffleLayout
                ? "Choisit un autre modèle compatible sans ajouter ni retirer d’élément."
                : "Aucun autre modèle n’est compatible avec les éléments de cette page."
        )
    }

    private var pageNavigation: some View {
        HStack(spacing: 10) {
            Button("Précédent", systemImage: "chevron.left") {
                model.goPrevious()
            }
            .labelStyle(.iconOnly)
            .disabled(!model.canGoPrevious || model.interaction.blocksPageNavigation)
            .keyboardShortcut(.leftArrow, modifiers: [.command])

            Text(
                "Page \(model.activePageIndex + 1) sur \(model.album?.pages.count ?? 1)"
            )
            .font(.subheadline.monospacedDigit())
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .accessibilityAddTraits(.isStaticText)

            Button("Suivant", systemImage: "chevron.right") {
                model.goNext()
            }
            .labelStyle(.iconOnly)
            .disabled(!model.canGoNext || model.interaction.blocksPageNavigation)
            .keyboardShortcut(.rightArrow, modifiers: [.command])
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }

    private var editorRail: some View {
        VStack(spacing: 10) {
            ForEach(EditorPanel.allCases) { panel in
                Button {
                    model.activePanel = panel
                    if reduceMotion {
                        showsInspector = true
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showsInspector = true
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: panel.symbol)
                            .font(.title3)
                        Text(panel.title)
                            .font(.caption2)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(width: 66, height: 58)
                    .background(
                        model.activePanel == panel
                            ? Color.accentColor.opacity(0.15) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 10)
                    )
                }
                .buttonStyle(.plain)
                .disabled(model.cropDraft != nil)
            }
            Spacer()
            Button {
                if showsInspector { model.cancelPhotoChoice() }
                if reduceMotion {
                    showsInspector.toggle()
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showsInspector.toggle()
                    }
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "sidebar.left")
                        .font(.title3)
                    Text(showsInspector ? "Replier" : "Afficher")
                        .font(.caption2)
                }
                .frame(width: 66, height: 58)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                showsInspector ? "Replier l’inspecteur" : "Afficher l’inspecteur"
            )
            .accessibilityHint("Conserve la sélection et le contenu de la page.")
        }
        .padding(.vertical, 12)
        .frame(width: 78)
        .background(.bar)
    }

    @ViewBuilder
    private func panelContent(_ panel: EditorPanel) -> some View {
        switch panel {
        case .photos:
            PhotosPanelView(model: model)
        case .layouts:
            LayoutPanelView(model: model)
        case .backgrounds:
            BackgroundPickerView(model: model)
        }
    }

    private var regularInspector: some View {
        VStack(spacing: 0) {
            if model.selectedElement != nil {
                ScrollView {
                    selectedElementInspector
                        .padding(12)
                }
                .frame(maxHeight: 390)
                Divider()
            }
            panelContent(model.activePanel)
        }
        .background(.bar)
    }

    private var selectedElementInspector: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let frame = model.selectedPhotoFrame {
                Text("Contenu photo")
                    .font(.headline)

                inspectorButton(
                    frame.content == nil ? "Ajouter une photo" : "Remplacer",
                    systemImage: frame.content == nil
                        ? "photo.badge.plus" : "arrow.triangle.2.circlepath"
                ) {
                    model.beginSelectedPhotoFrameChoice()
                    openPhotosPanel()
                }

                if frame.content != nil {
                    inspectorButton("Retirer la photo", systemImage: "photo.badge.minus") {
                        Task { await model.removePhotoFromSelectedFrame() }
                    }

                    if let quality = selectedPhotoQuality {
                        HStack {
                            Label(
                                "Qualité : \(qualityLabel(quality))",
                                systemImage: qualitySymbol(quality)
                            )
                            .foregroundStyle(qualityColor(quality))
                            Spacer()
                        }
                        .font(.subheadline.weight(.semibold))
                        .accessibilityLabel("Qualité photo : \(qualityLabel(quality))")
                    }

                    inspectorButton("Recadrer", systemImage: "crop") {
                        model.beginCrop()
                    }
                    inspectorButton("Pivoter la photo à gauche", systemImage: "rotate.left") {
                        Task { await model.rotatePhotoContent(by: -1) }
                    }
                    inspectorButton("Pivoter la photo à droite", systemImage: "rotate.right") {
                        Task { await model.rotatePhotoContent(by: 1) }
                    }
                    inspectorButton(
                        "Retourner la photo horizontalement",
                        systemImage: "arrow.left.and.right"
                    ) {
                        Task { await model.flipPhotoContent() }
                    }
                    inspectorButton("Description accessible…", systemImage: "accessibility") {
                        guard let pageID = model.activePageID else { return }
                        photoDescriptionRequest = PhotoDescriptionRequest(
                            pageID: pageID,
                            elementID: frame.id,
                            initialDescription: frame.content?.accessibilityDescription ?? ""
                        )
                    }
                }
                Divider()
            }

            Text("Cadre")
                .font(.headline)
            inspectorButton("Rotation…", systemImage: "rotate.right") {
                presentRotationEditor()
            }
            inspectorButton("Dupliquer", systemImage: "plus.square.on.square") {
                Task { await model.duplicateSelectedElement() }
            }
            .disabled(!model.canDuplicateSelectedElement)
            depthMenu
                .frame(maxWidth: .infinity, alignment: .leading)
            geometryMenu
                .frame(maxWidth: .infinity, alignment: .leading)
            inspectorButton("Supprimer", systemImage: "trash", role: .destructive) {
                Task { await model.deleteSelectedElement() }
            }
        }
        .buttonStyle(.bordered)
        .disabled(model.isReadOnly)
    }

    private func inspectorButton(
        _ title: String,
        systemImage: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Compact iPad layouts keep the inspector in the same window as the
    /// canvas. A photo can therefore be dragged out of the panel and dropped on
    /// the page; a modal sheet would isolate the drag source from its target.
    private func compactPanel(_ panel: EditorPanel) -> some View {
        VStack(spacing: 0) {
            HStack {
                Label(panel.title, systemImage: panel.symbol)
                    .font(.headline)
                Spacer()
                Button("Fermer le panneau", systemImage: "xmark") {
                    model.cancelPhotoChoice()
                    mobilePanel = nil
                }
                .labelStyle(.iconOnly)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()
            panelContent(panel)
        }
        .frame(minHeight: 180, idealHeight: 260, maxHeight: 320)
        .background(.bar)
        .accessibilityElement(children: .contain)
    }

    @ToolbarContentBuilder
    private var editorToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button("Retour aux albums", systemImage: "chevron.left") {
                closeEditor()
            }
            if horizontalSizeClass == .regular {
                Button("Aide", systemImage: "questionmark.circle") {
                    openContextHelp()
                }
            }
        }

        ToolbarItem(placement: .principal) {
            Button {
                showsRename = true
            } label: {
                VStack(spacing: 1) {
                    HStack(spacing: 4) {
                        Text(model.album?.name ?? "Album")
                            .font(.headline)
                            .lineLimit(1)
                        Image(systemName: "pencil")
                            .font(.caption)
                            .accessibilityHidden(true)
                    }
                    Label(model.saveState.label, systemImage: model.saveState.symbol)
                        .font(.caption2)
                        .foregroundStyle(
                            model.saveState == .failed ? Color.red : .secondary
                        )
                }
            }
            .buttonStyle(.plain)
            .disabled(model.album == nil || model.isReadOnly)
            .accessibilityLabel("Renommer l’album")
            .accessibilityValue(model.saveState.label)
            .accessibilityHint("Ouvre le formulaire de renommage. L’état de sauvegarde est annoncé comme valeur.")
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            Toggle(
                "Mise en page auto",
                systemImage: "wand.and.stars",
                isOn: Binding(
                    get: { model.activePage?.layout.isAutoLayoutEnabled == true },
                    set: { value in
                        Task { await model.requestAutomaticLayout(value) }
                    }
                )
            )
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .disabled(model.cropDraft != nil || model.isReadOnly)
            .accessibilityLabel("Mise en page auto")
            .accessibilityValue(
                model.activePage?.layout.isAutoLayoutEnabled == true
                    ? "Activée" : "Désactivée"
            )

            if horizontalSizeClass == .regular {
                Button("Sauvegarder", systemImage: "externaldrive.badge.checkmark") {
                    Task { await model.save() }
                }
                .disabled(!model.canSave)
                .keyboardShortcut("s", modifiers: .command)

                Button("Annuler", systemImage: "arrow.uturn.backward") {
                    Task { await model.undo() }
                }
                .disabled(!model.canUndo || model.cropDraft != nil || model.isReadOnly)
                .keyboardShortcut("z", modifiers: .command)

                Button("Rétablir", systemImage: "arrow.uturn.forward") {
                    Task { await model.redo() }
                }
                .disabled(!model.canRedo || model.cropDraft != nil || model.isReadOnly)
                .keyboardShortcut("z", modifiers: [.command, .shift])

                Button("Couper", systemImage: "scissors") {
                    Task { await model.cutSelected() }
                }
                .disabled(model.selectedElement == nil || model.cropDraft != nil || model.isReadOnly)
                .keyboardShortcut("x", modifiers: .command)

                Button("Copier", systemImage: "doc.on.doc") {
                    Task { await model.copySelected() }
                }
                .disabled(model.selectedElement == nil || model.cropDraft != nil || model.isReadOnly)
                .keyboardShortcut("c", modifiers: .command)

                Button("Coller", systemImage: "doc.on.clipboard") {
                    Task { await model.paste() }
                }
                .disabled(!model.canPaste || model.cropDraft != nil || model.isReadOnly)
                .keyboardShortcut("v", modifiers: .command)

                Button("Supprimer", systemImage: "trash", role: .destructive) {
                    Task { await model.deleteSelectedElement() }
                }
                .disabled(
                    model.selectedElement == nil
                        || model.cropDraft != nil
                        || model.isReadOnly
                )
                .keyboardShortcut(.delete, modifiers: [])
            } else {
                Button("Aide", systemImage: "questionmark.circle") {
                    openContextHelp()
                }
                compactCommandMenu
            }
        }
    }

    private var compactCommandMenu: some View {
        Menu("Plus", systemImage: "ellipsis.circle") {
            Button("Sauvegarder", systemImage: "externaldrive.badge.checkmark") {
                Task { await model.save() }
            }
            .disabled(!model.canSave)
            .keyboardShortcut("s", modifiers: .command)

            Divider()

            Button("Annuler", systemImage: "arrow.uturn.backward") {
                Task { await model.undo() }
            }
            .disabled(!model.canUndo || model.cropDraft != nil || model.isReadOnly)
            .keyboardShortcut("z", modifiers: .command)

            Button("Rétablir", systemImage: "arrow.uturn.forward") {
                Task { await model.redo() }
            }
            .disabled(!model.canRedo || model.cropDraft != nil || model.isReadOnly)
            .keyboardShortcut("z", modifiers: [.command, .shift])

            Divider()

            Button("Couper", systemImage: "scissors") {
                Task { await model.cutSelected() }
            }
            .disabled(model.selectedElement == nil || model.cropDraft != nil || model.isReadOnly)
            .keyboardShortcut("x", modifiers: .command)

            Button("Copier", systemImage: "doc.on.doc") {
                Task { await model.copySelected() }
            }
            .disabled(model.selectedElement == nil || model.cropDraft != nil || model.isReadOnly)
            .keyboardShortcut("c", modifiers: .command)

            Button("Coller", systemImage: "doc.on.clipboard") {
                Task { await model.paste() }
            }
            .disabled(!model.canPaste || model.cropDraft != nil || model.isReadOnly)
            .keyboardShortcut("v", modifiers: .command)

            Button("Supprimer", systemImage: "trash", role: .destructive) {
                Task { await model.deleteSelectedElement() }
            }
            .disabled(
                model.selectedElement == nil
                    || model.cropDraft != nil
                    || model.isReadOnly
            )
        }
    }

    @ViewBuilder
    private var bottomCommands: some View {
        if model.presentationMode == .preview {
            HStack {
                Button("Quitter la prévisualisation", systemImage: "xmark") {
                    model.presentationMode = .page
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(.bar)
        } else if model.presentationMode == .global {
            Picker("Mode d’affichage", selection: $model.presentationMode) {
                ForEach(EditorPresentationMode.allCases) { mode in
                    Label(mode.title, systemImage: mode.symbol)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 460)
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(.bar)
        } else if model.presentationMode == .page {
            if model.cropDraft != nil {
                cropCommands
            } else {
                editorBottomBar
            }
        }
    }

    private var editorBottomBar: some View {
        VStack(spacing: 0) {
            if model.selectedElement != nil, horizontalSizeClass != .regular {
                selectedElementCommands
                Divider()
            }

            HStack(spacing: 10) {
                if horizontalSizeClass != .regular {
                    ForEach(EditorPanel.allCases) { panel in
                        Button(panel.title, systemImage: panel.symbol) {
                            model.activePanel = panel
                            mobilePanel = panel
                        }
                        .labelStyle(.iconOnly)
                    }
                    Divider().frame(height: 24)
                }

                if model.activePage?.elements.isEmpty == false {
                    elementSelectionMenu
                    Divider().frame(height: 24)
                }

                Picker("Mode d’affichage", selection: $model.presentationMode) {
                    ForEach(EditorPresentationMode.allCases) { mode in
                        Label(mode.title, systemImage: mode.symbol)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 460)
                .accessibilityLabel("Vue de l’éditeur")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.bar)
    }

    private var selectedElementCommands: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let frame = model.selectedPhotoFrame {
                    Button(
                        frame.content == nil ? "Ajouter une photo" : "Remplacer",
                        systemImage: frame.content == nil
                            ? "photo.badge.plus" : "arrow.triangle.2.circlepath"
                    ) {
                        model.beginSelectedPhotoFrameChoice()
                        openPhotosPanel()
                    }

                    if frame.content != nil {
                        Button("Retirer la photo", systemImage: "photo.badge.minus") {
                            Task { await model.removePhotoFromSelectedFrame() }
                        }

                        qualityBadge
                        Button("Recadrer", systemImage: "crop") {
                            model.beginCrop()
                        }

                        Button("Pivoter à gauche", systemImage: "rotate.left") {
                            Task { await model.rotatePhotoContent(by: -1) }
                        }

                        Button("Pivoter à droite", systemImage: "rotate.right") {
                            Task { await model.rotatePhotoContent(by: 1) }
                        }

                        Button(
                            "Retourner horizontalement",
                            systemImage: "arrow.left.and.right"
                        ) {
                            Task { await model.flipPhotoContent() }
                        }

                        Button(
                            "Description accessible…",
                            systemImage: "accessibility"
                        ) {
                            guard let pageID = model.activePageID else { return }
                            photoDescriptionRequest = PhotoDescriptionRequest(
                                pageID: pageID,
                                elementID: frame.id,
                                initialDescription: frame.content?
                                    .accessibilityDescription ?? ""
                            )
                        }
                    }
                }

                Button("Rotation…", systemImage: "rotate.right") {
                    presentRotationEditor()
                }

                Button("Dupliquer", systemImage: "plus.square.on.square") {
                    Task { await model.duplicateSelectedElement() }
                }
                .disabled(!model.canDuplicateSelectedElement)

                depthMenu
                geometryMenu

                Button("Supprimer", systemImage: "trash", role: .destructive) {
                    Task { await model.deleteSelectedElement() }
                }
                .keyboardShortcut(.delete, modifiers: [])
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(model.isReadOnly)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private var qualityBadge: some View {
        if let quality = selectedPhotoQuality {
            Label(
                "Qualité : \(qualityLabel(quality))",
                systemImage: qualitySymbol(quality)
            )
                .font(.caption.weight(.semibold))
                .foregroundStyle(qualityColor(quality))
                .accessibilityLabel("Qualité photo : \(qualityLabel(quality))")
        }
    }

    private var depthMenu: some View {
        Menu("Profondeur", systemImage: "square.3.layers.3d") {
            Button("Premier plan", systemImage: "arrow.up.to.line") {
                Task { await model.moveSelectedElementDepth(.front) }
            }
            .disabled(!canMoveDepthForward)

            Button("Avancer", systemImage: "arrow.up") {
                Task { await model.moveSelectedElementDepth(.forward) }
            }
            .disabled(!canMoveDepthForward)

            Button("Reculer", systemImage: "arrow.down") {
                Task { await model.moveSelectedElementDepth(.backward) }
            }
            .disabled(!canMoveDepthBackward)

            Button("Arrière-plan", systemImage: "arrow.down.to.line") {
                Task { await model.moveSelectedElementDepth(.back) }
            }
            .disabled(!canMoveDepthBackward)
        }
    }

    private var geometryMenu: some View {
        Menu("Position et taille", systemImage: "move.3d") {
            ControlGroup("Déplacer") {
                Button("Gauche", systemImage: "arrow.left") {
                    Task { await model.adjustSelectedGeometry(deltaX: -0.01) }
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
                Button("Droite", systemImage: "arrow.right") {
                    Task { await model.adjustSelectedGeometry(deltaX: 0.01) }
                }
                .keyboardShortcut(.rightArrow, modifiers: [])
                Button("Haut", systemImage: "arrow.up") {
                    Task { await model.adjustSelectedGeometry(deltaY: -0.01) }
                }
                .keyboardShortcut(.upArrow, modifiers: [])
                Button("Bas", systemImage: "arrow.down") {
                    Task { await model.adjustSelectedGeometry(deltaY: 0.01) }
                }
                .keyboardShortcut(.downArrow, modifiers: [])
            }

            ControlGroup("Déplacer précisément") {
                Button("Gauche précise", systemImage: "arrow.left") {
                    Task { await model.adjustSelectedGeometry(deltaX: -0.0025) }
                }
                .keyboardShortcut(.leftArrow, modifiers: [.option])
                Button("Droite précise", systemImage: "arrow.right") {
                    Task { await model.adjustSelectedGeometry(deltaX: 0.0025) }
                }
                .keyboardShortcut(.rightArrow, modifiers: [.option])
                Button("Haut précis", systemImage: "arrow.up") {
                    Task { await model.adjustSelectedGeometry(deltaY: -0.0025) }
                }
                .keyboardShortcut(.upArrow, modifiers: [.option])
                Button("Bas précis", systemImage: "arrow.down") {
                    Task { await model.adjustSelectedGeometry(deltaY: 0.0025) }
                }
                .keyboardShortcut(.downArrow, modifiers: [.option])
            }

            Button("Agrandir", systemImage: "plus.magnifyingglass") {
                Task {
                    await model.adjustSelectedGeometry(
                        deltaWidth: 0.05,
                        deltaHeight: 0.05
                    )
                }
            }
            Button("Réduire", systemImage: "minus.magnifyingglass") {
                Task {
                    await model.adjustSelectedGeometry(
                        deltaWidth: -0.05,
                        deltaHeight: -0.05
                    )
                }
            }
            Button("Pleine page", systemImage: "rectangle.inset.filled") {
                Task { await model.makeSelectedElementFullPage() }
            }
        }
    }

    private var elementSelectionMenu: some View {
        Menu("Sélectionner un élément", systemImage: "cursorarrow.click.2") {
            if let page = model.activePage {
                ForEach(Array(page.orderedElements.reversed())) { element in
                    Button(model.elementSelectionLabel(element)) {
                        model.select(elementID: element.id)
                    }
                }
            }
        }
        .accessibilityHint("Permet notamment de sélectionner un élément masqué")
    }

    private var cropCommands: some View {
        VStack(spacing: 8) {
            HStack {
                Label("Zoom photo", systemImage: "magnifyingglass")
                    .font(.caption.weight(.semibold))
                if let draft = model.cropDraft {
                    Slider(
                        value: Binding(
                            get: { draft.placement.nativeScale },
                            set: { model.setCropScale($0) }
                        ),
                        in: draft.sessionMinimum...AlbumPhotoConstants.maximumNativeScale
                    )
                    Text(draft.placement.nativeScale, format: .number.precision(.fractionLength(2)))
                        .font(.caption.monospacedDigit())
                        .frame(width: 48)
                    Button(
                        "Réduire le zoom photo de 0,01×",
                        systemImage: "minus.circle"
                    ) {
                        model.setCropScale(draft.placement.nativeScale - 0.01)
                    }
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 44, minHeight: 44)
                    .disabled(draft.placement.nativeScale <= draft.sessionMinimum)

                    Button(
                        "Augmenter le zoom photo de 0,01×",
                        systemImage: "plus.circle"
                    ) {
                        model.setCropScale(draft.placement.nativeScale + 0.01)
                    }
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 44, minHeight: 44)
                    .disabled(
                        draft.placement.nativeScale
                            >= AlbumPhotoConstants.maximumNativeScale
                    )
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button(role: .cancel) {
                        model.cancelCrop()
                    } label: {
                        Label("Annuler", systemImage: "xmark")
                    }
                    Button("Réinitialiser", systemImage: "arrow.counterclockwise") {
                        model.resetCrop()
                    }
                    Button("Pivoter à gauche", systemImage: "rotate.left") {
                        model.rotateCrop(by: -1)
                    }
                    Button("Pivoter à droite", systemImage: "rotate.right") {
                        model.rotateCrop(by: 1)
                    }
                    Button(
                        "Retourner horizontalement",
                        systemImage: "arrow.left.and.right"
                    ) {
                        model.flipCrop()
                    }
                    Button("Terminé", systemImage: "checkmark") {
                        Task { await model.commitCrop() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private var canMoveDepthForward: Bool {
        guard let page = model.activePage,
              let selectedID = model.selectedElementID,
              let index = page.orderedElements.firstIndex(where: { $0.id == selectedID }) else {
            return false
        }
        return index < page.orderedElements.count - 1
    }

    private var canMoveDepthBackward: Bool {
        guard let page = model.activePage,
              let selectedID = model.selectedElementID,
              let index = page.orderedElements.firstIndex(where: { $0.id == selectedID }) else {
            return false
        }
        return index > 0
    }

    private var selectedPhotoQuality: PhotoQualityState? {
        guard let placement = model.selectedPhotoFrame?.content else { return nil }
        return DefaultPhotoQualityPolicy.state(for: placement)
    }

    private func qualityLabel(_ quality: PhotoQualityState) -> String {
        switch quality {
        case .ok: "OK"
        case .acceptable: "Acceptable"
        case .insufficient: "Insuffisante"
        }
    }

    private func qualitySymbol(_ quality: PhotoQualityState) -> String {
        switch quality {
        case .ok: "checkmark.circle"
        case .acceptable: "exclamationmark.circle"
        case .insufficient: "exclamationmark.triangle"
        }
    }

    private func qualityColor(_ quality: PhotoQualityState) -> Color {
        switch quality {
        case .ok: .green
        case .acceptable: .orange
        case .insufficient: .red
        }
    }

    private func openPhotosPanel() {
        if horizontalSizeClass == .regular {
            model.activePanel = .photos
            if reduceMotion {
                showsInspector = true
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showsInspector = true
                }
            }
        } else {
            model.activePanel = .photos
            mobilePanel = .photos
        }
    }

    private func presentRotationEditor() {
        guard let element = model.selectedElement else { return }
        model.beginElementRotationPreview(elementID: element.id)
        rotationRequest = RotationEditorRequest(
            elementID: element.id,
            initialRadians: element.geometry.rotationRadians
        )
    }

    private func openContextHelp() {
        if model.cropDraft != nil {
            model.helpContext = .crop
        } else {
            model.helpContext = model.presentationMode == .global
                ? .globalPages : .editor
        }
    }

    private func closeEditor() {
        guard !isClosing else { return }
        isClosing = true
        model.cancelImportTask()
        let closingToken = model.beginClosingTransition()
        let pending = lifecycleTask
        Task {
            defer { model.endClosingTransition(closingToken) }
            await pending?.value
            guard await model.save() else {
                isClosing = false
                return
            }
            guard await model.close(reacquireOnFailure: true) else {
                isClosing = false
                return
            }
            dismiss()
        }
    }

    private func enqueueLifecycleTransition(_ phase: ScenePhase) {
        guard phase == .background || phase == .active else { return }
        let tokensToRelease: [UUID]
        if phase == .background {
            model.cancelImportTask()
            lifecycleOperationBlockTokens.append(model.beginClosingTransition())
            tokensToRelease = []
        } else {
            tokensToRelease = lifecycleOperationBlockTokens
            lifecycleOperationBlockTokens.removeAll(keepingCapacity: true)
        }
        let previous = lifecycleTask
        lifecycleTask = Task {
            await previous?.value
            if phase == .background {
                _ = await model.save()
                _ = await model.close()
            } else {
                for token in tokensToRelease {
                    model.endClosingTransition(token)
                }
                await model.load()
            }
        }
    }
}

private struct PreviewPageView: View {
    @ObservedObject var model: EditorViewModel
    @State private var swipeEligible = false

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                if let page = model.activePage {
                    PageCompositionView(
                        page: page,
                        assets: Dictionary(
                            uniqueKeysWithValues: model.photos.map { ($0.id, $0) }
                        ),
                        imageCache: model.imageCache,
                        purpose: .preview,
                        pageNumber: model.activePageIndex + 1
                    )
                    .id(page.id)
                    .accessibilityLabel(previewPageAccessibilityLabel(page))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(24)
                    .background(Color.black.opacity(0.92))
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 18)
                            .onChanged { value in
                                swipeEligible = abs(value.translation.width)
                                    > abs(value.translation.height) * 1.25
                            }
                            .onEnded { value in
                                defer { swipeEligible = false }
                                guard swipeEligible else { return }
                                model.navigateBySwipe(
                                    translation: value.translation,
                                    pageWidth: geometry.size.width
                                )
                            }
                    )
                    .overlay(alignment: .top) {
                        let emptyCount = page.elements.filter {
                            $0.photoFrame != nil && $0.photoFrame?.content == nil
                        }.count
                        if emptyCount > 0 {
                            Label(
                                "\(emptyCount) cadre(s) photo vide(s) masqué(s) dans la prévisualisation",
                                systemImage: "exclamationmark.square"
                            )
                            .font(.caption.weight(.semibold))
                            .padding(8)
                            .background(.regularMaterial, in: Capsule())
                            .padding()
                        }
                    }
                    .onChange(of: model.activePageID) { _, _ in
                        swipeEligible = false
                    }
                }
            }
            pagePreviewNavigation
        }
    }

    private var pagePreviewNavigation: some View {
        HStack(spacing: 18) {
            Button("Précédent", systemImage: "chevron.left") { model.goPrevious() }
                .disabled(!model.canGoPrevious)
            Text("Page \(model.activePageIndex + 1) sur \(model.album?.pages.count ?? 1)")
                .font(.subheadline.monospacedDigit())
            Button("Suivant", systemImage: "chevron.right") { model.goNext() }
                .disabled(!model.canGoNext)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(.bar)
    }

    private func previewPageAccessibilityLabel(_ page: PageSnapshot) -> String {
        let frames = page.elements.filter { $0.photoFrame != nil }
        let emptyCount = frames.filter { $0.photoFrame?.content == nil }.count
        let textCount = page.elements.filter { $0.textBox != nil }.count
        let stickerCount = page.elements.filter { $0.sticker != nil }.count
        let qualityStates = frames.compactMap { frame -> PhotoQualityState? in
            guard let placement = frame.photoFrame?.content else { return nil }
            return DefaultPhotoQualityPolicy.state(for: placement)
        }
        let acceptableCount = qualityStates.filter { $0 == .acceptable }.count
        let insufficientCount = qualityStates.filter { $0 == .insufficient }.count
        let qualitySummary = acceptableCount == 0 && insufficientCount == 0
            ? "aucune alerte qualité"
            : "alertes qualité : \(insufficientCount) insuffisantes, "
                + "\(acceptableCount) acceptables"
        return "Page \(model.activePageIndex + 1) sur \(model.album?.pages.count ?? 1), "
            + "\(frames.count) cadres photo dont \(emptyCount) vides, "
            + "\(textCount) zones de texte, \(stickerCount) stickers, "
            + qualitySummary
    }
}

private struct PhotoDescriptionSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onConfirm: (String) -> Void
    @State private var description: String

    init(
        initialDescription: String,
        onConfirm: @escaping (String) -> Void
    ) {
        self.onConfirm = onConfirm
        _description = State(initialValue: String(initialDescription.prefix(500)))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $description)
                        .frame(minHeight: 160)
                        .accessibilityLabel("Description accessible de la photo")
                        .onChange(of: description) { _, value in
                            if value.count > 500 {
                                description = String(value.prefix(500))
                            }
                        }
                } footer: {
                    Text(
                        "\(description.count) sur 500 caractères. "
                            + "Laissez vide pour utiliser « Photo, page N »."
                    )
                }
            }
            .navigationTitle("Description accessible")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { onConfirm(description) }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct EditorRenameSheet: View {
    @Environment(\.dismiss) private var dismiss

    let initialName: String
    let onConfirm: (String) -> Void

    @State private var name: String

    init(initialName: String, onConfirm: @escaping (String) -> Void) {
        self.initialName = initialName
        self.onConfirm = onConfirm
        _name = State(initialValue: initialName)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nom de l’album", text: $name)
                    .submitLabel(.done)
                    .onSubmit(confirm)
            }
            .navigationTitle("Renommer l’album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Renommer", action: confirm)
                        .disabled(trimmedName.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func confirm() {
        guard !trimmedName.isEmpty else { return }
        onConfirm(trimmedName)
    }
}

private struct ElementRotationSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onPreview: (Double) -> Void
    let onCancel: () -> Void
    let onConfirm: (Double) -> Void
    @State private var degrees: Double
    @State private var didResolve = false

    init(
        initialRadians: Double,
        onPreview: @escaping (Double) -> Void,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping (Double) -> Void
    ) {
        self.onPreview = onPreview
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        _degrees = State(initialValue: Self.normalizedDegrees(
            initialRadians * 180 / .pi
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Angle du cadre") {
                    Slider(value: $degrees, in: -180...179, step: 1)
                        .accessibilityLabel("Rotation en degrés")
                    Text("\(degrees.formatted(.number.precision(.fractionLength(0))))°")
                        .font(.title2.monospacedDigit())
                        .frame(maxWidth: .infinity)
                }

                Section("Réglages rapides") {
                    ControlGroup {
                        Button("−90°") { degrees = Self.normalizedDegrees(degrees - 90) }
                        Button("+90°") { degrees = Self.normalizedDegrees(degrees + 90) }
                        Button("Réinitialiser") { degrees = 0 }
                    }
                }
            }
            .navigationTitle("Rotation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Valider", action: confirm)
                }
            }
        }
        .presentationDetents([.medium])
        .onChange(of: degrees) { _, value in onPreview(value) }
        .onDisappear {
            if !didResolve { onCancel() }
        }
    }

    private static func normalizedDegrees(_ value: Double) -> Double {
        var normalized = value.truncatingRemainder(dividingBy: 360)
        if normalized >= 180 { normalized -= 360 }
        if normalized < -180 { normalized += 360 }
        return normalized.rounded()
    }

    private func cancel() {
        guard !didResolve else { return }
        didResolve = true
        onCancel()
        dismiss()
    }

    private func confirm() {
        guard !didResolve else { return }
        didResolve = true
        onConfirm(degrees)
        dismiss()
    }
}
