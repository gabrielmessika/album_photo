import Foundation
import XCTest
@testable import AlbumPhotoCore

final class PrototypeEngineTests: XCTestCase {
    private func template(
        id: String = "layout.one",
        version: Int = 1,
        active: Bool = true,
        photos: Int,
        texts: Int = 0
    ) -> LayoutTemplateDefinition {
        var slots: [LayoutSlotDefinition] = []
        for index in 0..<photos {
            slots.append(LayoutSlotDefinition(
                id: "p\(index)",
                kind: .photo,
                geometry: LayoutSlotGeometry(
                    centerX: 0.25 + Double(index % 2) * 0.5,
                    centerY: 0.25 + Double(index / 2) * 0.4,
                    width: 0.35,
                    height: 0.25
                ),
                readingOrder: slots.count,
                defaultPhotoStyle: PhotoFrameStyleDefaults()
            ))
        }
        for index in 0..<texts {
            slots.append(LayoutSlotDefinition(
                id: "t\(index)",
                kind: .text,
                geometry: LayoutSlotGeometry(
                    centerX: 0.5,
                    centerY: 0.8 - Double(index) * 0.15,
                    width: 0.6,
                    height: 0.1
                ),
                readingOrder: slots.count,
                defaultTextStyle: TextStyleDefaults()
            ))
        }
        return LayoutTemplateDefinition(
            id: id,
            version: version,
            isActive: active,
            localizedNameKey: "template.\(id)",
            slots: slots
        )
    }

    private func filledFrame(id: UUID, assetID: UUID, order: Int64) -> PageElement {
        .photo(PhotoFrameElement(
            id: id,
            geometry: ElementGeometry(order: order),
            content: PhotoPlacement(
                assetID: assetID,
                nativeScale: 0.75,
                focalX: 0.2,
                focalY: 0.8,
                quarterTurns: 1,
                flippedHorizontally: true
            )
        ))
    }

    // 3:TPL-019, 3:TST-006
    func testTemplateCatalogRejectsDuplicateVersionAndMultipleActiveVersions() throws {
        let one = template(photos: 1)
        XCTAssertNoThrow(try LayoutTemplateEngine.validateCatalog([one]))
        XCTAssertThrowsError(try LayoutTemplateEngine.validateCatalog([one, one]))
        XCTAssertThrowsError(try LayoutTemplateEngine.validateCatalog([
            one,
            template(id: one.id, version: 2, active: true, photos: 1)
        ]))
        XCTAssertNoThrow(try LayoutTemplateEngine.validateCatalog([
            one,
            template(id: one.id, version: 2, active: false, photos: 1)
        ]))
    }

    // 3:TPL-004...3:TPL-010, 3:CRP-007
    func testSmallerTemplateRequiresConfirmationAndPreservesSurvivingCrop() throws {
        let frameIDs = [UUID(), UUID(), UUID()]
        let assetIDs = [UUID(), UUID(), UUID()]
        let page = PageSnapshot(
            elements: zip(frameIDs, assetIDs).enumerated().map { index, pair in
                filledFrame(
                    id: pair.0,
                    assetID: pair.1,
                    order: Int64(index + 1) * AlbumPhotoConstants.elementOrderStep
                )
            },
            accessibilityOrder: frameIDs
        )
        let smaller = template(photos: 2)
        XCTAssertEqual(
            LayoutTemplateEngine.preview(applying: smaller, to: page).disposition,
            .requiresPhotoRemovalConfirmation(count: 1)
        )
        XCTAssertThrowsError(try LayoutTemplateEngine.apply(
            smaller,
            to: page,
            confirmsPhotoRemoval: false
        ))
        let applied = try LayoutTemplateEngine.apply(
            smaller,
            to: page,
            confirmsPhotoRemoval: true
        )
        let frames = applied.elements.compactMap(\.photoFrame)
        XCTAssertEqual(frames.map(\.id), Array(frameIDs.prefix(2)))
        XCTAssertEqual(frames[0].content, page.elements[0].photoFrame?.content)
        XCTAssertEqual(applied.layout.photoMode, .template)
        XCTAssertEqual(applied.layout.templateID, smaller.id)
    }

    // 3:TPL-006, 3:TPL-011
    func testTemplateNeverSilentlyRemovesNonemptyText() {
        let textID = UUID()
        let style = TextStyleDefaults()
        let text = TextBoxElement(
            id: textID,
            content: TextBoxContent(paragraphs: [
                TextParagraph(runs: [TextRun(text: "À conserver", style: style)])
            ])
        )
        let page = PageSnapshot(
            elements: [.text(text)],
            accessibilityOrder: [textID]
        )
        XCTAssertEqual(
            LayoutTemplateEngine.preview(applying: template(photos: 1), to: page).disposition,
            .disabledBecauseTextWouldBeRemoved(count: 1)
        )
    }

    // 3:TPL-005, 3:TPL-014, 3:TPL-015
    func testTemplateUsesBaseOrderAndAddsMixedSlotsInReadingOrderWithoutChangingDepth() throws {
        let firstID = UUID(uuidString: "ffffffff-0000-0000-0000-000000000000")!
        let secondID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let stickerID = UUID()
        let original = PageSnapshot(
            elements: [
                .photo(PhotoFrameElement(
                    id: secondID,
                    geometry: ElementGeometry(centerX: 0.8, order: 3_072)
                )),
                .sticker(StickerElement(
                    id: stickerID,
                    geometry: ElementGeometry(order: 1_024),
                    resource: CatalogResourceReference(
                        catalogID: "sticker.star",
                        catalogVersion: 1
                    )
                )),
                .photo(PhotoFrameElement(
                    id: firstID,
                    geometry: ElementGeometry(centerX: 0.2, order: 2_048)
                ))
            ],
            accessibilityOrder: [secondID, stickerID, firstID]
        )
        let twoPhotos = template(photos: 2)
        let applied = try LayoutTemplateEngine.apply(
            twoPhotos,
            to: original,
            confirmsPhotoRemoval: false
        )

        XCTAssertEqual(applied.element(id: secondID)?.geometry.centerX, 0.25)
        XCTAssertEqual(applied.element(id: firstID)?.geometry.centerX, 0.75)
        XCTAssertEqual(applied.element(id: stickerID)?.geometry.order, 1_024)
        XCTAssertEqual(applied.element(id: firstID)?.geometry.order, 2_048)
        XCTAssertEqual(applied.element(id: secondID)?.geometry.order, 3_072)

        let textID = UUID(uuidString: "10000000-0000-0000-0000-000000000000")!
        let photoID = UUID(uuidString: "20000000-0000-0000-0000-000000000000")!
        var generatedIDs = [textID, photoID].makeIterator()
        let mixed = LayoutTemplateDefinition(
            id: "layout.mixed",
            version: 1,
            localizedNameKey: "layout.mixed.name",
            slots: [
                LayoutSlotDefinition(
                    id: "text-1",
                    kind: .text,
                    geometry: LayoutSlotGeometry(
                        centerX: 0.5,
                        centerY: 0.2,
                        width: 0.6,
                        height: 0.1
                    ),
                    readingOrder: 0
                ),
                LayoutSlotDefinition(
                    id: "photo-1",
                    kind: .photo,
                    geometry: LayoutSlotGeometry(
                        centerX: 0.5,
                        centerY: 0.6,
                        width: 0.6,
                        height: 0.6
                    ),
                    readingOrder: 1
                )
            ]
        )
        let created = try LayoutTemplateEngine.apply(
            mixed,
            to: PageSnapshot(),
            confirmsPhotoRemoval: false,
            makeID: { generatedIDs.next()! }
        )
        XCTAssertEqual(created.accessibilityOrder, [textID, photoID])
        XCTAssertLessThan(
            try XCTUnwrap(created.element(id: textID)).geometry.order,
            try XCTUnwrap(created.element(id: photoID)).geometry.order
        )
    }

    // 3:RND-001...3:RND-006
    func testShuffleBagUsesOnlyExactCompatibleSetWithoutImmediateRepeat() {
        let frameID = UUID()
        let page = PageSnapshot(
            elements: [.photo(PhotoFrameElement(id: frameID))],
            accessibilityOrder: [frameID]
        )
        let templates = [
            template(id: "layout.a", photos: 1),
            template(id: "layout.b", photos: 1),
            template(id: "layout.c", photos: 1),
            template(id: "layout.wrong", photos: 2)
        ]
        let compatible = templates.filter { LayoutTemplateEngine.compatibleWithDice($0, page: page) }
        XCTAssertEqual(compatible.count, 3)
        var bag = LayoutShuffleBag()
        var random = PredictableRandomNumberGenerator([0])
        let initial = LayoutTemplateKey(id: "layout.a", version: 1)
        let first = bag.choose(compatible: compatible, current: initial, using: &random)
        let second = bag.choose(compatible: compatible, current: first, using: &random)
        let third = bag.choose(compatible: compatible, current: second, using: &random)
        XCTAssertNotEqual(first, initial)
        XCTAssertNotEqual(second, first)
        XCTAssertNotEqual(third, second)
        XCTAssertEqual(Set([initial, first!, second!]), Set(compatible.map {
            LayoutTemplateKey(id: $0.id, version: $0.version)
        }))
    }

    // 3:AUT-012, 3:DAT-037
    func testAutomaticGeneratorIsDeterministicAndValidForZeroThroughTwenty() throws {
        for count in 0...20 {
            let first = try AutoLayoutEngine.geometries(count: count, density: .balanced)
            let second = try AutoLayoutEngine.geometries(count: count, density: .balanced)
            XCTAssertEqual(first, second)
            XCTAssertEqual(first.count, count)
            for geometry in first { XCTAssertNoThrow(try DomainValidator.validate(geometry)) }
        }
        XCTAssertThrowsError(try AutoLayoutEngine.geometries(count: 21, density: .dense))
    }

    // 3:AUT-012, 3:AUT-014, 3:AUT-016
    func testAutomaticGeneratorPrefersBestExactTemplateBeforeFallbackGrid() throws {
        func candidate(id: String, centerX: Double, width: Double, height: Double)
            -> LayoutTemplateDefinition {
            LayoutTemplateDefinition(
                id: id,
                version: 1,
                localizedNameKey: "template.\(id)",
                slots: [LayoutSlotDefinition(
                    id: "photo-1",
                    kind: .photo,
                    geometry: LayoutSlotGeometry(
                        centerX: centerX,
                        centerY: 0.5,
                        width: width,
                        height: height
                    ),
                    readingOrder: 0
                )]
            )
        }
        let portrait = candidate(id: "layout.portrait", centerX: 0.25, width: 0.3, height: 0.7)
        let landscape = candidate(id: "layout.landscape", centerX: 0.75, width: 0.8, height: 0.32)
        let result = try AutoLayoutEngine.geometries(
            count: 1,
            density: .balanced,
            photoAspectRatios: [2],
            templates: [portrait, landscape]
        )
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].centerX, 0.75)
        XCTAssertEqual(result[0].order, AlbumPhotoConstants.elementOrderStep)
    }

    // 3:AUT-006...3:AUT-015, 3:CRP-007
    func testAutoRecomposeRemovesEmptyFramesAndPreservesCropInAccessibilityOrder() throws {
        let firstID = UUID(), secondID = UUID(), emptyID = UUID()
        let firstAsset = UUID(), secondAsset = UUID()
        let first = filledFrame(id: firstID, assetID: firstAsset, order: 1_024)
        let second = filledFrame(id: secondID, assetID: secondAsset, order: 2_048)
        let empty = PageElement.photo(PhotoFrameElement(
            id: emptyID,
            geometry: ElementGeometry(order: 3_072)
        ))
        var page = PageSnapshot(
            elements: [first, second, empty],
            accessibilityOrder: [secondID, emptyID, firstID]
        )
        page.layout.density = .airy
        let recomposed = try AutoLayoutEngine.recompose(
            page: page,
            metadataByAssetID: [
                firstAsset: TestFixtures.metadata(id: firstAsset),
                secondAsset: TestFixtures.metadata(id: secondAsset, width: 1_800, height: 2_400)
            ]
        )
        XCTAssertNil(recomposed.element(id: emptyID))
        XCTAssertEqual(recomposed.accessibilityOrder, [secondID, firstID])
        XCTAssertEqual(
            recomposed.element(id: firstID)?.photoFrame?.content,
            first.photoFrame?.content
        )
        XCTAssertTrue(recomposed.layout.isAutoLayoutEnabled)
        XCTAssertEqual(recomposed.layout.photoMode, .automatic)
        XCTAssertNil(recomposed.layout.templateID)
    }

    // 3:AUT-009, 3:AUT-010, 3:AUT-012, 3:FRM-009, 3:TPL-005
    func testAlbumFillPlansStableGroupsReusesEmptyPagesAndCreatesTheRemainder() throws {
        let usedID = UUID(uuidString: "00000000-0000-4000-8000-000000000001")!
        let tieHighID = UUID(uuidString: "F0000000-0000-4000-8000-000000000002")!
        let tieLowID = UUID(uuidString: "10000000-0000-4000-8000-000000000003")!
        let earlyID = UUID(uuidString: "20000000-0000-4000-8000-000000000004")!
        let laterID = UUID(uuidString: "30000000-0000-4000-8000-000000000005")!
        let lastID = UUID(uuidString: "40000000-0000-4000-8000-000000000006")!
        let occupiedPageID = UUID(), reusablePageID = UUID()
        let occupiedFrameID = UUID(), firstEmptyID = UUID(), secondEmptyID = UUID()
        let baseDate = Date(timeIntervalSince1970: 10_000)

        let metadata = [
            TestFixtures.metadata(id: usedID, importedAt: baseDate),
            TestFixtures.metadata(
                id: tieHighID,
                importedAt: baseDate.addingTimeInterval(20),
                capturedAt: baseDate.addingTimeInterval(2)
            ),
            TestFixtures.metadata(
                id: tieLowID,
                importedAt: baseDate.addingTimeInterval(30),
                capturedAt: baseDate.addingTimeInterval(2)
            ),
            TestFixtures.metadata(
                id: earlyID,
                importedAt: baseDate.addingTimeInterval(1),
                capturedAt: nil
            ),
            TestFixtures.metadata(
                id: laterID,
                importedAt: baseDate.addingTimeInterval(40),
                capturedAt: baseDate.addingTimeInterval(3)
            ),
            TestFixtures.metadata(
                id: lastID,
                importedAt: baseDate.addingTimeInterval(50),
                capturedAt: baseDate.addingTimeInterval(4)
            )
        ]
        let metadataByID = Dictionary(uniqueKeysWithValues: metadata.map { ($0.id, $0) })
        var album = AlbumSnapshot(id: UUID(), name: "Remplissage", firstPageID: occupiedPageID)
        album.photoAssetIDs = [usedID, tieHighID, tieLowID, earlyID, laterID, lastID]
        album.pages[0] = PageSnapshot(
            id: occupiedPageID,
            elements: [.photo(PhotoFrameElement(
                id: occupiedFrameID,
                content: PhotoPlacement(assetID: usedID)
            ))],
            accessibilityOrder: [occupiedFrameID]
        )
        album.pages.append(PageSnapshot(
            id: reusablePageID,
            background: .solid(.black),
            elements: [
                .photo(PhotoFrameElement(
                    id: firstEmptyID,
                    geometry: ElementGeometry(order: 2_048)
                )),
                .photo(PhotoFrameElement(
                    id: secondEmptyID,
                    geometry: ElementGeometry(order: 1_024)
                ))
            ],
            accessibilityOrder: [firstEmptyID, secondEmptyID]
        ))

        let plan = try XCTUnwrap(AlbumFillEngine.plan(
            album: album,
            metadataByAssetID: metadataByID,
            density: .balanced
        ))
        XCTAssertEqual(plan.photoGroups, [
            [earlyID, tieHighID, tieLowID, laterID],
            [lastID]
        ])
        XCTAssertEqual(plan.reusablePageIDs, [reusablePageID])
        XCTAssertEqual(plan.emptyPhotoFrameCount, 2)
        XCTAssertEqual(plan.createdPageCount, 1)
        XCTAssertEqual(try AlbumFillEngine.plan(
            album: album,
            metadataByAssetID: metadataByID,
            density: .airy
        )?.photoGroups.map(\.count), [2, 2, 1])
        XCTAssertEqual(try AlbumFillEngine.plan(
            album: album,
            metadataByAssetID: metadataByID,
            density: .dense
        )?.photoGroups.map(\.count), [5])

        let createdPageID = UUID()
        var createdElementIDs = (0..<5).map { _ in UUID() }
        let filled = try AlbumFillEngine.apply(
            plan,
            to: album,
            metadataByAssetID: metadataByID,
            templates: BuiltInLayoutTemplateCatalog.active,
            makePageID: { createdPageID },
            makeElementID: { createdElementIDs.removeFirst() }
        )
        XCTAssertEqual(filled.pages.count, 3)
        XCTAssertEqual(filled.pages[0], album.pages[0])
        XCTAssertEqual(filled.pages[1].background, .solid(.black))
        XCTAssertEqual(filled.pages[2].id, createdPageID)
        XCTAssertEqual(filled.pages[2].background, .classicSpiral)
        XCTAssertEqual(
            filled.pages[1].elements.compactMap { $0.photoFrame?.content?.assetID },
            plan.photoGroups[0]
        )
        XCTAssertEqual(
            filled.pages[2].elements.compactMap { $0.photoFrame?.content?.assetID },
            plan.photoGroups[1]
        )
        for page in filled.pages.dropFirst() {
            XCTAssertTrue(page.layout.isAutoLayoutEnabled)
            XCTAssertEqual(page.layout.photoMode, .automatic)
            XCTAssertEqual(page.layout.density, .balanced)
            XCTAssertNil(page.layout.templateID)
            XCTAssertTrue(page.elements.compactMap(\.photoFrame).allSatisfy {
                $0.content?.nativeScale == 1
                    && $0.content?.focalX == 0.5
                    && $0.content?.focalY == 0.5
                    && $0.sourceTemplateSlotID == nil
            })
        }
    }

    // 3:NAV-004...3:NAV-007, 3:ANI-002...3:ANI-008
    func testPageTurnThresholdVelocityDirectionBoundsAndSingleTransition() {
        var state = PageTurnStateMachine()
        state.update(
            horizontalTranslation: -25,
            verticalTranslation: 0,
            availableWidth: 100,
            canGoPrevious: true,
            canGoNext: true
        )
        XCTAssertNil(state.end(velocity: -600))
        state.finishAnimation()
        state.update(
            horizontalTranslation: -10,
            verticalTranslation: 0,
            availableWidth: 100,
            canGoPrevious: true,
            canGoNext: true
        )
        XCTAssertNil(state.end(velocity: 900))
        state.finishAnimation()
        state.update(
            horizontalTranslation: -10,
            verticalTranslation: 0,
            availableWidth: 100,
            canGoPrevious: true,
            canGoNext: true
        )
        XCTAssertEqual(state.end(velocity: -601), .next)
        state.finishAnimation()
        state.update(
            horizontalTranslation: -80,
            verticalTranslation: 0,
            availableWidth: 100,
            canGoPrevious: true,
            canGoNext: false
        )
        XCTAssertNil(state.end(velocity: -900))
        XCTAssertTrue(state.beginButtonTransition(direction: .previous, canNavigate: true))
        XCTAssertFalse(state.beginButtonTransition(direction: .next, canNavigate: true))
        XCTAssertEqual(PageTurnStateMachine.buttonDurationSeconds, 0.35, accuracy: 0.000_001)
    }

    // Lot 0, 3:SYN-001...3:SYN-007
    func testCloudPlannerChangesOnePageIndependentlyAndQueuesThroughProtocol() async throws {
        let firstID = UUID(), secondID = UUID()
        var before = AlbumSnapshot(
            id: TestFixtures.albumID,
            name: "Guatemala",
            firstPageID: firstID,
            createdAt: TestFixtures.date
        )
        before.pages.append(PageSnapshot(id: secondID))
        var after = before
        after.pages[0].background = .solid(.white)
        after.updatedAt = before.updatedAt.addingTimeInterval(1)
        let plan = try CloudRecordPlanner.changes(from: before, to: after)
        XCTAssertEqual(plan.zoneName, "AlbumZone")
        XCTAssertEqual(plan.records.filter { $0.type == .album }.count, 1)
        XCTAssertEqual(plan.records.filter { $0.type == .page }.map(\.recordName), [
            "page-\(firstID.uuidString.lowercased())"
        ])
        XCTAssertFalse(plan.records.contains {
            $0.recordName == "page-\(secondID.uuidString.lowercased())"
        })
        XCTAssertTrue(plan.batches.allSatisfy {
            $0.records.count <= 200 && $0.inlineByteCount <= 1_000_000
        })
        let recorder = RecordingCloudSyncService()
        try await recorder.enqueue(plan)
        let recorded = await recorder.plans
        XCTAssertEqual(recorded, [plan])
    }
}
