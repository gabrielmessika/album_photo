import Foundation
import XCTest
@testable import AlbumPhotoCore

private actor FailingOnceLibraryRepository: LibraryRepository {
    private let wrapped: InMemoryLibraryRepository
    private var shouldFailNextCommit = false

    init(snapshot: LocalLibrarySnapshot) {
        wrapped = InMemoryLibraryRepository(snapshot: snapshot)
    }

    func failNextCommit() {
        shouldFailNextCommit = true
    }

    func load() async throws -> LocalLibrarySnapshot {
        try await wrapped.load()
    }

    func commit(_ transaction: PersistedTransaction) async throws {
        if shouldFailNextCommit {
            shouldFailNextCommit = false
            throw DomainValidationError.injectedFailure("beforeCommit")
        }
        try await wrapped.commit(transaction)
    }

    func flush() async throws {
        await wrapped.flush()
    }
}

final class AlbumApplicationServiceTests: XCTestCase {
    // 3:ACPT-100, 3:ALB-011...3:ALB-016
    func testCreateAlbumTrimsNameAllowsDuplicatesAndSortsByUpdatedAt() async throws {
        let service = TestFixtures.service()
        let first = try await service.createAlbum(
            named: "  Guatemala  ",
            now: Date(timeIntervalSince1970: 1)
        )
        let second = try await service.createAlbum(
            named: "Guatemala",
            now: Date(timeIntervalSince1970: 2)
        )
        XCTAssertEqual(first.name, "Guatemala")
        let activeIDs = try await service.activeAlbums().map(\.id)
        XCTAssertEqual(activeIDs, [second.id, first.id])
        await XCTAssertThrowsDomainError({
            try await service.createAlbum(named: " \n ")
        }, matching: { $0 == .emptyAlbumName })
    }

    // 3:PHO-015
    func testActiveAlbumsSortByRecencyLocalizedNameThenUUIDBytes() async throws {
        let service = TestFixtures.service()
        let tiedDate = Date(timeIntervalSince1970: 10_000)
        let lowID = UUID(uuidString: "00000000-0000-4000-8000-000000000001")!
        let highID = UUID(uuidString: "00000000-0000-4000-8000-0000000000FF")!
        let alphaID = UUID(uuidString: "10000000-0000-4000-8000-000000000000")!
        let zuluID = UUID(uuidString: "20000000-0000-4000-8000-000000000000")!
        let recentID = UUID(uuidString: "30000000-0000-4000-8000-000000000000")!

        _ = try await service.createAlbum(named: "Bravo", id: highID, now: tiedDate)
        _ = try await service.createAlbum(named: "Zulu", id: zuluID, now: tiedDate)
        _ = try await service.createAlbum(named: "Bravo", id: lowID, now: tiedDate)
        _ = try await service.createAlbum(named: "Alpha", id: alphaID, now: tiedDate)
        _ = try await service.createAlbum(
            named: "Récent",
            id: recentID,
            now: tiedDate.addingTimeInterval(1)
        )

        let ordered = try await service.activeAlbums().map(\.id)
        XCTAssertEqual(ordered, [recentID, alphaID, lowID, highID, zuluID])
    }

    // 3:ALB-021, 3:UND-011
    func testLibraryRenameHasIndependentUndoRedo() async throws {
        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Guatemala")
        _ = try await service.renameAlbum(album.id, to: "Voyage", history: .library)
        let canUndoLibrary = await service.canUndoLibrary()
        let undone = try await service.undoLibrary()
        let redone = try await service.redoLibrary()
        let canUndoEditor = await service.canUndo(albumID: album.id)
        XCTAssertTrue(canUndoLibrary)
        XCTAssertEqual(undone.name, "Guatemala")
        XCTAssertEqual(redone.name, "Voyage")
        XCTAssertFalse(canUndoEditor)
    }

    // 3:UND-004, 3:UND-011
    func testEditorRenameUsesEditorHistoryAndNeverLibraryHistory() async throws {
        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Guatemala")

        let renamed = try await service.renameAlbum(
            album.id,
            to: "Voyage",
            history: .editor
        )
        let canUndoEditor = await service.canUndo(albumID: album.id)
        let canUndoLibrary = await service.canUndoLibrary()
        XCTAssertEqual(renamed.name, "Voyage")
        XCTAssertTrue(canUndoEditor)
        XCTAssertFalse(canUndoLibrary)

        let undone = try await service.undo(albumID: album.id)
        XCTAssertEqual(undone.name, "Guatemala")
    }

    // 3:ACPT-102, 3:ALB-017...3:ALB-020
    func testTrashRestoreAndPermanentDeletionPreserveCorrectTarget() async throws {
        let service = TestFixtures.service()
        let retained = try await service.createAlbum(named: "Retenu")
        let removed = try await service.createAlbum(named: "Supprimé")
        _ = try await service.moveAlbumToTrash(removed.id, now: TestFixtures.date)
        let activeAfterTrash = try await service.activeAlbums().map(\.id)
        let trashAfterMove = try await service.trashedAlbums().map(\.id)
        XCTAssertEqual(activeAfterTrash, [retained.id])
        XCTAssertEqual(trashAfterMove, [removed.id])
        _ = try await service.restoreAlbum(removed.id)
        _ = try await service.moveAlbumToTrash(removed.id)
        try await service.permanentlyDeleteAlbum(removed.id)
        let finalActive = Set(try await service.activeAlbums().map(\.id))
        let finalTrash = try await service.trashedAlbums()
        XCTAssertEqual(finalActive, [retained.id])
        XCTAssertTrue(finalTrash.isEmpty)
    }

    // 3:ALB-020, 3:LOC-008
    func testPermanentDeletionCreatesOneValidatedTombstoneAndKeepsBlob() async throws {
        let service = TestFixtures.service()
        let (album, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        let trashedAt = TestFixtures.date.addingTimeInterval(100)
        let deletedAt = trashedAt.addingTimeInterval(10)
        let commandID = UUID(uuidString: "AAAAAAAA-1111-4222-8333-BBBBBBBBBBBB")!
        let trashed = try await service.moveAlbumToTrash(album.id, now: trashedAt)
        let expectedLogicalHash = try AlbumLogicalFingerprint.hash(
            album: trashed,
            photoAssets: [metadata]
        )

        try await service.permanentlyDeleteAlbum(
            album.id,
            now: deletedAt,
            commandID: commandID
        )
        try await service.permanentlyDeleteAlbum(
            album.id,
            now: deletedAt,
            commandID: commandID
        )

        let state = try await service.snapshot()
        XCTAssertNil(state.album(id: album.id))
        XCTAssertFalse(state.photoAssets.contains { $0.albumID == album.id })
        let tombstone = try XCTUnwrap(state.albumDeletionTombstones.first)
        XCTAssertEqual(state.albumDeletionTombstones.count, 1)
        XCTAssertEqual(tombstone.albumID, album.id)
        XCTAssertEqual(tombstone.trashedAt, trashedAt)
        XCTAssertEqual(tombstone.deletedAt, deletedAt)
        XCTAssertEqual(tombstone.reason, .userConfirmed)
        XCTAssertEqual(tombstone.albumLogicalHash, expectedLogicalHash)
        XCTAssertEqual(tombstone.deletionCommandID, commandID)
        XCTAssertNoThrow(try DomainValidator.validate(state))

        let retainedBlob = try XCTUnwrap(state.blobIndex.first {
            $0.contentHash == metadata.contentHash
        })
        XCTAssertEqual(retainedBlob.referenceCount, 0)
        XCTAssertEqual(retainedBlob.state, .orphaned)
    }

    // 3:ALB-020, 3:ALB-023, 3:ALB-024
    func testTrashExpiresAtExactlyThirtyPeriodsOfTwentyFourHours() async throws {
        let service = TestFixtures.service()
        let now = Date(timeIntervalSince1970: 5_000_000)
        let expired = try await service.createAlbum(named: "Expiré")
        let retained = try await service.createAlbum(named: "Retenu")
        _ = try await service.moveAlbumToTrash(
            expired.id,
            now: now.addingTimeInterval(-30 * 24 * 60 * 60)
        )
        _ = try await service.moveAlbumToTrash(
            retained.id,
            now: now.addingTimeInterval(-30 * 24 * 60 * 60 + 1)
        )
        let commandID = UUID(uuidString: "BBBBBBBB-1111-4222-8333-CCCCCCCCCCCC")!
        let purged = try await service.purgeExpiredTrashedAlbums(
            now: now,
            commandID: commandID
        )
        let replayedCount = try await service.purgeExpiredTrashedAlbums(
            now: now,
            commandID: commandID
        )
        let retainedTrash = try await service.trashedAlbums().map(\.id)
        XCTAssertEqual(purged, 1)
        XCTAssertEqual(replayedCount, 1)
        XCTAssertEqual(retainedTrash, [retained.id])
        let state = try await service.snapshot()
        let tombstone = try XCTUnwrap(state.albumDeletionTombstones.first)
        XCTAssertEqual(tombstone.albumID, expired.id)
        XCTAssertEqual(tombstone.deletedAt, now)
        XCTAssertEqual(tombstone.reason, .retentionExpired)
        XCTAssertEqual(tombstone.deletionCommandID, commandID)
    }

    // 3:ALB-023, 3:ALB-024
    func testTrashExpirationEvaluatesAtLaunchThenAtMostOnceBeforeDailyBoundary() async throws {
        let service = TestFixtures.service()
        let launch = Date(timeIntervalSince1970: 6_000_000)
        let album = try await service.createAlbum(named: "Expiration quotidienne")
        _ = try await service.moveAlbumToTrash(
            album.id,
            now: launch.addingTimeInterval(-AlbumDeletionTombstone.recoveryDuration + 1)
        )

        let launchEvaluation = try await service.evaluateTrashExpiration(
            trigger: .applicationLaunch,
            now: launch,
            commandID: UUID()
        )
        XCTAssertEqual(launchEvaluation, TrashExpirationEvaluation(
            didEvaluate: true,
            purgedAlbumCount: 0
        ))

        let skipped = try await service.evaluateTrashExpiration(
            trigger: .applicationActive,
            now: launch.addingTimeInterval(24 * 60 * 60 - 1),
            commandID: UUID()
        )
        XCTAssertEqual(skipped, TrashExpirationEvaluation(
            didEvaluate: false,
            purgedAlbumCount: 0
        ))
        let retainedBeforeDailyEvaluation = try await service.album(id: album.id)
        XCTAssertEqual(retainedBeforeDailyEvaluation.id, album.id)

        let dailyEvaluation = try await service.evaluateTrashExpiration(
            trigger: .applicationActive,
            now: launch.addingTimeInterval(24 * 60 * 60),
            commandID: UUID()
        )
        XCTAssertEqual(dailyEvaluation, TrashExpirationEvaluation(
            didEvaluate: true,
            purgedAlbumCount: 1
        ))
        let trashed = try await service.trashedAlbums()
        XCTAssertTrue(trashed.isEmpty)
    }

    // 3:PAG-001...3:PAG-011, 3:ACPT-104
    func testPageAddAppendsReorderDeleteAndTwoUndosRestoreInitialOrder() async throws {
        let service = TestFixtures.service()
        let ids = (0..<5).map { _ in UUID() }
        var album = try await service.createAlbum(
            named: "Guatemala",
            firstPageID: ids[0]
        )
        for id in ids.dropFirst() {
            album = try await service.addPage(
                to: album.id,
                pageID: id
            )
        }
        XCTAssertEqual(album.pages.map(\.id), ids)
        _ = try await service.reorderPages(
            in: album.id,
            orderedPageIDs: [ids[0], ids[4], ids[1], ids[2], ids[3]]
        )
        _ = try await service.deletePage(from: album.id, pageID: ids[4])
        let restoredDeletion = try await service.undo(albumID: album.id)
        XCTAssertEqual(restoredDeletion.pages.map(\.id), [
            ids[0], ids[4], ids[1], ids[2], ids[3]
        ])
        let restoredOrder = try await service.undo(albumID: album.id)
        XCTAssertEqual(restoredOrder.pages.map(\.id), ids)
    }

    // 3:PAG-007
    func testOnlyPageCannotBeDeleted() async throws {
        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Guatemala")
        await XCTAssertThrowsDomainError({
            try await service.deletePage(from: album.id, pageID: album.pages[0].id)
        }, matching: { $0 == .cannotDeleteOnlyPage })
    }

    // 3:BG-005, 3:BG-006, 3:BG-013, 3:ACPT-127
    func testBackgroundPerPageApplyAllAndUndoAreAtomic() async throws {
        let service = TestFixtures.service()
        var album = try await service.createAlbum(named: "Guatemala")
        album = try await service.addPage(to: album.id)
        album = try await service.setBackground(.solid(.black), on: album.pages[0].id, in: album.id)
        XCTAssertEqual(album.pages[0].background, .solid(.black))
        XCTAssertEqual(album.pages[1].background, .classicSpiral)
        _ = try await service.applyBackgroundToAllPages(.none, in: album.id)
        let undone = try await service.undo(albumID: album.id)
        XCTAssertEqual(undone.pages[0].background, .solid(.black))
        XCTAssertEqual(undone.pages[1].background, .classicSpiral)
    }

    // 3:APL-002, 3:PHO-007, 3:DAT-036
    func testMultipleRegistrationPreservesSelectionOrderAsOneUndoAction() async throws {
        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Guatemala")
        let firstData = TestFixtures.data("first")
        let secondData = TestFixtures.data("second")
        let first = TestFixtures.metadata(id: UUID(), data: firstData)
        let second = TestFixtures.metadata(id: UUID(), data: secondData)
        let imported = try await service.registerPhotos([
            PhotoRegistration(metadata: first, blob: TestFixtures.blob(data: firstData)),
            PhotoRegistration(metadata: second, blob: TestFixtures.blob(data: secondData))
        ], in: album.id)
        XCTAssertEqual(imported.photoAssetIDs, [first.id, second.id])
        let undone = try await service.undo(albumID: album.id)
        XCTAssertTrue(undone.photoAssetIDs.isEmpty)
    }

    // 3:PHO-019, 3:DAT-036
    func testRegistrationDeduplicatesContentHashWithinAlbumWithoutExtraUndo() async throws {
        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Empreintes")
        let sharedData = TestFixtures.data("same exact file")
        let uniqueData = TestFixtures.data("new file in repeated batch")
        let first = TestFixtures.metadata(id: UUID(), data: sharedData)
        let duplicate = TestFixtures.metadata(id: UUID(), data: sharedData)
        let batchDuplicate = TestFixtures.metadata(id: UUID(), data: sharedData)
        let unique = TestFixtures.metadata(id: UUID(), data: uniqueData)
        let repeatedUnique = TestFixtures.metadata(id: UUID(), data: uniqueData)

        let imported = try await service.registerPhoto(
            first,
            blob: TestFixtures.blob(data: sharedData),
            in: album.id
        )
        let unchanged = try await service.registerPhoto(
            duplicate,
            blob: TestFixtures.blob(data: sharedData),
            in: album.id
        )
        let batchImported = try await service.registerPhotos([
            PhotoRegistration(
                metadata: batchDuplicate,
                blob: TestFixtures.blob(data: sharedData)
            ),
            PhotoRegistration(
                metadata: unique,
                blob: TestFixtures.blob(data: uniqueData)
            ),
            PhotoRegistration(
                metadata: repeatedUnique,
                blob: TestFixtures.blob(data: uniqueData)
            )
        ], in: album.id)

        XCTAssertEqual(imported.photoAssetIDs, [first.id])
        XCTAssertEqual(unchanged.photoAssetIDs, [first.id])
        XCTAssertEqual(batchImported.photoAssetIDs, [first.id, unique.id])
        let undoneBatch = try await service.undo(albumID: album.id)
        XCTAssertEqual(undoneBatch.photoAssetIDs, [first.id])
        let undoneFirst = try await service.undo(albumID: album.id)
        let canUndoAgain = await service.canUndo(albumID: album.id)
        XCTAssertTrue(undoneFirst.photoAssetIDs.isEmpty)
        XCTAssertFalse(canUndoAgain)
    }

    // 3:ARC-007, 3:LOC-011
    func testRepeatedCommandIDIsIdempotentAndDoesNotDuplicateUndo() async throws {
        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Guatemala")
        let commandID = UUID()
        let pageID = UUID()
        _ = try await service.addPage(
            to: album.id,
            pageID: pageID,
            commandID: commandID
        )
        let repeated = try await service.addPage(
            to: album.id,
            pageID: pageID,
            commandID: commandID
        )
        XCTAssertEqual(repeated.pages.count, 2)
        let undone = try await service.undo(albumID: album.id)
        let canUndo = await service.canUndo(albumID: album.id)
        XCTAssertEqual(undone.pages.count, 1)
        XCTAssertFalse(canUndo)
    }

    // 3:PHO-004...3:PHO-006, 3:FRM-009
    func testAddMultipleFramesCreatesIndependentOccurrencesAtOneX() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        var album = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: TestFixtures.elementID
        )
        album = try await service.addPhotoFrame(
            to: album.pages[0].id,
            in: album.id,
            assetID: metadata.id
        )
        let frames = album.pages[0].elements.compactMap(\.photoFrame)
        XCTAssertEqual(frames.count, 2)
        XCTAssertEqual(frames.map { $0.content?.nativeScale }, [1, 1])
        let occurrenceCount = try await service.occurrenceCount(of: metadata.id, in: album.id)
        XCTAssertEqual(occurrenceCount, 2)
    }

    // 3:FRM-003, 3:PHO-009, 3:PHO-010
    func testRemoveContentKeepsFrameAndAssetDeletionRequiresZeroOccurrences() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        let withFrame = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: TestFixtures.elementID
        )
        await XCTAssertThrowsDomainError({
            try await service.removePhotoAsset(metadata.id, from: initial.id)
        }, matching: {
            if case .assetIsUsed(metadata.id, count: 1) = $0 { return true }
            return false
        })
        let emptyFrame = try await service.removePhotoFromFrame(
            TestFixtures.elementID,
            on: withFrame.pages[0].id,
            in: initial.id
        )
        XCTAssertNil(emptyFrame.pages[0].element(id: TestFixtures.elementID)?.photoFrame?.content)
        XCTAssertTrue(emptyFrame.photoAssetIDs.contains(metadata.id))
        let removed = try await service.removePhotoAsset(metadata.id, from: initial.id)
        XCTAssertFalse(removed.photoAssetIDs.contains(metadata.id))
    }

    // 3:TPL-004...3:TPL-010, 3:TPL-016, 3:DAT-042
    func testApplyingBuiltInTemplateIsOneValidatedUndoableCommand() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(
            service: service
        )
        let pageID = initial.pages[0].id
        var album = try await service.addPhotoFrame(
            to: pageID,
            in: initial.id,
            assetID: metadata.id,
            elementID: TestFixtures.elementID
        )
        let template = try XCTUnwrap(BuiltInLayoutTemplateCatalog.active.first {
            $0.photoSlots.count == 2 && $0.textSlots.isEmpty
        })

        album = try await service.applyLayoutTemplate(
            id: template.id,
            version: template.version,
            to: pageID,
            in: initial.id
        )
        XCTAssertEqual(album.pages[0].layout.photoMode, .template)
        XCTAssertEqual(album.pages[0].layout.templateID, template.id)
        XCTAssertEqual(album.pages[0].elements.compactMap(\.photoFrame).count, 2)
        XCTAssertEqual(
            Set(album.pages[0].elements.compactMap(\.photoFrame)
                .compactMap(\.sourceTemplateSlotID)),
            Set(template.photoSlots.map(\.id))
        )
        XCTAssertNoThrow(try DomainValidator.validate(
            album.pages[0],
            validAssetIDs: [metadata.id]
        ))

        let undone = try await service.undo(albumID: initial.id)
        XCTAssertEqual(undone.pages[0].layout.photoMode, .free)
        XCTAssertEqual(undone.pages[0].elements.map(\.id), [TestFixtures.elementID])
        XCTAssertEqual(
            undone.pages[0].elements[0].photoFrame?.content?.assetID,
            metadata.id
        )
    }

    // 3:TPL-007, 3:TPL-010
    func testSmallerBuiltInTemplateRequiresConfirmationWithoutPartialCommit() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(
            service: service
        )
        let pageID = initial.pages[0].id
        var album = initial
        for _ in 0..<2 {
            album = try await service.addPhotoFrame(
                to: pageID,
                in: initial.id,
                assetID: metadata.id
            )
        }
        let template = try XCTUnwrap(BuiltInLayoutTemplateCatalog.active.first {
            $0.photoSlots.count == 1 && $0.textSlots.isEmpty
        })
        let revisionBefore = try await service.snapshot().revision

        await XCTAssertThrowsDomainError({
            try await service.applyLayoutTemplate(
                id: template.id,
                version: template.version,
                to: pageID,
                in: initial.id
            )
        }, matching: {
            if case .invalidTemplate("confirmation requise") = $0 { return true }
            return false
        })
        let revisionAfterCancellation = try await service.snapshot().revision
        XCTAssertEqual(revisionAfterCancellation, revisionBefore)

        album = try await service.applyLayoutTemplate(
            id: template.id,
            version: template.version,
            to: pageID,
            in: initial.id,
            confirmsPhotoRemoval: true
        )
        XCTAssertEqual(album.pages[0].elements.compactMap(\.photoFrame).count, 1)
        XCTAssertTrue(album.photoAssetIDs.contains(metadata.id))
    }

    // 3:TPL-011, 3:TPL-012, 3:DAT-042
    func testMovingTemplateTextOnlyFreesThatTextProvenance() async throws {
        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Texte de modèle")
        let pageID = album.pages[0].id
        let template = try XCTUnwrap(BuiltInLayoutTemplateCatalog.active.first {
            $0.photoSlots.count == 1 && $0.textSlots.count == 1
        })
        let applied = try await service.applyLayoutTemplate(
            id: template.id,
            version: template.version,
            to: pageID,
            in: album.id
        )
        let text = try XCTUnwrap(applied.pages[0].elements.compactMap(\.textBox).first)
        var geometry = text.geometry
        geometry.centerX = 0.4

        let moved = try await service.updateElementGeometry(
            geometry,
            elementID: text.id,
            on: pageID,
            in: album.id
        )
        XCTAssertEqual(moved.pages[0].layout.photoMode, .template)
        XCTAssertNil(moved.pages[0].element(id: text.id)?.textBox?.sourceTemplateSlotID)
        XCTAssertNotNil(
            moved.pages[0].elements.compactMap(\.photoFrame).first?.sourceTemplateSlotID
        )
    }

    // 3:AUT-001...3:AUT-008, 3:AUT-018, 3:AUT-019
    func testAutomaticLayoutRecomposesStructuralPhotoCommandsAndIsUndoable() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(
            service: service
        )
        let pageID = initial.pages[0].id
        var album = try await service.setAutomaticLayoutEnabled(
            true,
            on: pageID,
            in: initial.id
        )
        XCTAssertTrue(album.pages[0].layout.isAutoLayoutEnabled)
        XCTAssertEqual(album.pages[0].layout.photoMode, .automatic)

        await XCTAssertThrowsDomainError({
            try await service.addPhotoFrame(to: pageID, in: initial.id)
        }, matching: { $0 == .invalidLayoutState })

        album = try await service.addPhotoFrame(
            to: pageID,
            in: initial.id,
            assetID: metadata.id,
            elementID: TestFixtures.elementID
        )
        album = try await service.duplicateElement(
            TestFixtures.elementID,
            on: pageID,
            in: initial.id,
            newElementID: UUID()
        )
        XCTAssertEqual(album.pages[0].elements.compactMap(\.photoFrame).count, 2)
        XCTAssertTrue(album.pages[0].layout.isAutoLayoutEnabled)
        XCTAssertTrue(album.pages[0].elements.compactMap(\.photoFrame).allSatisfy {
            $0.content != nil && $0.sourceTemplateSlotID == nil
        })

        album = try await service.removePhotoFromFrame(
            TestFixtures.elementID,
            on: pageID,
            in: initial.id
        )
        XCTAssertNil(album.pages[0].element(id: TestFixtures.elementID))
        XCTAssertEqual(album.pages[0].elements.compactMap(\.photoFrame).count, 1)
        let undoneRemoval = try await service.undo(albumID: initial.id)
        XCTAssertEqual(undoneRemoval.pages[0].elements.compactMap(\.photoFrame).count, 2)

        let disabled = try await service.setAutomaticLayoutEnabled(
            false,
            on: pageID,
            in: initial.id
        )
        XCTAssertFalse(disabled.pages[0].layout.isAutoLayoutEnabled)
        XCTAssertEqual(disabled.pages[0].layout.photoMode, .automatic)
    }

    // 3:AUT-008, 3:TPL-022
    func testEnablingAutoOnExistingTemplateRequiresConfirmationAndClearsSlots() async throws {
        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Passage en Auto")
        let pageID = album.pages[0].id
        let template = try XCTUnwrap(BuiltInLayoutTemplateCatalog.active.first {
            $0.photoSlots.count == 1 && $0.textSlots.count == 1
        })
        _ = try await service.applyLayoutTemplate(
            id: template.id,
            version: template.version,
            to: pageID,
            in: album.id
        )

        await XCTAssertThrowsDomainError({
            try await service.setAutomaticLayoutEnabled(
                true,
                on: pageID,
                in: album.id
            )
        }, matching: {
            if case .invalidTemplate("confirmation Auto requise") = $0 { return true }
            return false
        })
        let automatic = try await service.setAutomaticLayoutEnabled(
            true,
            on: pageID,
            in: album.id,
            confirmsReplacement: true
        )
        XCTAssertTrue(automatic.pages[0].elements.compactMap(\.photoFrame).isEmpty)
        XCTAssertTrue(automatic.pages[0].elements.compactMap(\.textBox).allSatisfy {
            $0.sourceTemplateSlotID == nil
        })
        XCTAssertEqual(automatic.pages[0].layout.photoMode, .automatic)

        let textID = try XCTUnwrap(
            automatic.pages[0].elements.compactMap(\.textBox).first?.id
        )
        let withoutText = try await service.deleteElement(
            textID,
            on: pageID,
            in: album.id
        )
        XCTAssertTrue(withoutText.pages[0].layout.isAutoLayoutEnabled)
        XCTAssertEqual(withoutText.pages[0].layout.photoMode, .automatic)
    }

    // 3:DAT-017, 3:LOC-008, 3:UND-010
    func testBlobLedgerRetainsUndoAndClipboardReferencesAfterLogicalRemoval() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        _ = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: TestFixtures.elementID
        )

        let sceneID = UUID()
        let firstAcquisition = await service.editLeases.acquire(
            albumID: initial.id,
            sceneID: sceneID
        )
        XCTAssertTrue(firstAcquisition)
        let closed = try await service.closeEditingSession(
            albumID: initial.id,
            sceneID: sceneID
        )
        XCTAssertTrue(closed)
        let secondAcquisition = await service.editLeases.acquire(
            albumID: initial.id,
            sceneID: sceneID
        )
        XCTAssertTrue(secondAcquisition)

        try await service.copyElement(
            TestFixtures.elementID,
            on: initial.pages[0].id,
            in: initial.id
        )
        _ = try await service.removePhotoFromFrame(
            TestFixtures.elementID,
            on: initial.pages[0].id,
            in: initial.id
        )
        _ = try await service.removePhotoAsset(metadata.id, from: initial.id)

        let state = try await service.snapshot()
        XCTAssertTrue(state.photoAssets(in: initial.id).isEmpty)
        let retainedBlob = try XCTUnwrap(state.blobIndex.first {
            $0.contentHash == metadata.contentHash
        })
        XCTAssertGreaterThan(retainedBlob.referenceCount, 0)
        XCTAssertEqual(retainedBlob.state, .available)

        let restored = try await service.undo(albumID: initial.id)
        XCTAssertEqual(restored.photoAssetIDs, [metadata.id])
    }

    // 3:PHO-017, 3:PHO-018
    func testReuseAcrossAlbumsCreatesNewLogicalIDWithSameBlobAndLeavesSourceUntouched() async throws {
        let service = TestFixtures.service()
        let (source, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        let target = try await service.createAlbum(named: "Cible")
        let targetID = UUID()
        let reused = try await service.reusePhotos(
            assetIDs: [metadata.id],
            from: source.id,
            to: target.id,
            newAssetIDs: [targetID],
            now: TestFixtures.date.addingTimeInterval(10)
        )
        XCTAssertEqual(reused.map(\.id), [targetID])
        XCTAssertEqual(reused[0].contentHash, metadata.contentHash)
        XCTAssertEqual(reused[0].source, .reusedAlbum)
        let storedSource = try await service.album(id: source.id)
        let storedTarget = try await service.album(id: target.id)
        let storedSnapshot = try await service.snapshot()
        XCTAssertEqual(storedSource.photoAssetIDs, [metadata.id])
        XCTAssertEqual(storedTarget.photoAssetIDs, [targetID])
        XCTAssertEqual(storedSnapshot.blobIndex.count, 4)
    }

    // 3:LOC-011, 3:PHO-017, 3:PHO-018
    func testReuseRetryWithoutInjectedDestinationIDsReturnsSameLogicalResult() async throws {
        let service = TestFixtures.service()
        let (source, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        let target = try await service.createAlbum(named: "Cible")
        let commandID = UUID()
        let first = try await service.reusePhotos(
            assetIDs: [metadata.id],
            from: source.id,
            to: target.id,
            commandID: commandID
        )
        let retry = try await service.reusePhotos(
            assetIDs: [metadata.id],
            from: source.id,
            to: target.id,
            commandID: commandID
        )
        XCTAssertEqual(retry, first)
        let stored = try await service.album(id: target.id)
        XCTAssertEqual(stored.photoAssetIDs, [first[0].id])
        let undone = try await service.undo(albumID: target.id)
        XCTAssertTrue(undone.photoAssetIDs.isEmpty)
    }

    // 3:COV-001...3:COV-005
    func testManualCoverTracksElementThenFallsBackAfterContentRemoval() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        var album = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: TestFixtures.elementID
        )
        album = try await service.setCover(
            .pagePhoto(pageID: initial.pages[0].id, elementID: TestFixtures.elementID),
            for: initial.id
        )
        XCTAssertEqual(album.resolvedCoverOccurrence, album.coverSelection)
        album = try await service.removePhotoFromFrame(
            TestFixtures.elementID,
            on: initial.pages[0].id,
            in: initial.id
        )
        XCTAssertEqual(album.coverSelection, .automatic)
        XCTAssertNil(album.resolvedCoverOccurrence)
    }

    // 3:CRP-005...3:CRP-007, 3:ACC-011, 3:ACC-017, 3:UND-007
    func testCropIsOnePersistedUndoableCommand() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        _ = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: TestFixtures.elementID
        )
        let changed = PhotoPlacement(
            assetID: metadata.id,
            nativeScale: 0.5,
            focalX: 0.25,
            focalY: 0.75,
            quarterTurns: 1,
            flippedHorizontally: true,
            accessibilityDescription: "Chat roux devant une fenêtre"
        )
        let cropped = try await service.updatePhotoPlacement(
            changed,
            elementID: TestFixtures.elementID,
            on: initial.pages[0].id,
            in: initial.id
        )
        XCTAssertEqual(cropped.pages[0].element(id: TestFixtures.elementID)?.photoFrame?.content, changed)
        let undone = try await service.undo(albumID: initial.id)
        XCTAssertEqual(undone.pages[0].element(id: TestFixtures.elementID)?.photoFrame?.content?.nativeScale, 1)
        let redone = try await service.redo(albumID: initial.id)
        XCTAssertEqual(redone.pages[0].element(id: TestFixtures.elementID)?.photoFrame?.content, changed)
    }

    // 3:CLP-001...3:CLP-004, 3:ACPT-130 domain portion.
    func testCopyPasteUsesNewElementIDAndIndependentCropThenCutUndoRestores() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        var album = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: TestFixtures.elementID
        )
        let secondPageID = UUID()
        album = try await service.addPage(to: album.id, pageID: secondPageID)
        try await service.copyElement(TestFixtures.elementID, on: initial.pages[0].id, in: initial.id)
        let pastedID = UUID()
        album = try await service.pasteElement(on: secondPageID, in: initial.id, newElementID: pastedID)
        XCTAssertEqual(album.pages[1].elements.map(\.id), [pastedID])
        XCTAssertEqual(album.pages[1].elements[0].photoFrame?.content?.assetID, metadata.id)
        _ = try await service.cutElement(pastedID, on: secondPageID, in: initial.id)
        let afterCut = try await service.album(id: initial.id)
        let afterUndo = try await service.undo(albumID: initial.id)
        XCTAssertTrue(afterCut.pages[1].elements.isEmpty)
        XCTAssertEqual(afterUndo.pages[1].elements.map(\.id), [pastedID])
    }

    // 3:ARC-007, 3:CLP-002, 3:LOC-011
    func testCutRetryIsIdempotentAndCreatesOnlyOneUndoCommand() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        let elementID = UUID()
        _ = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: elementID
        )
        let commandID = UUID()

        let first = try await service.cutElement(
            elementID,
            on: initial.pages[0].id,
            in: initial.id,
            commandID: commandID
        )
        let revisionAfterFirst = try await service.snapshot().revision
        let retry = try await service.cutElement(
            elementID,
            on: initial.pages[0].id,
            in: initial.id,
            commandID: commandID
        )
        let revisionAfterRetry = try await service.snapshot().revision

        XCTAssertTrue(first.pages[0].elements.isEmpty)
        XCTAssertEqual(retry, first)
        XCTAssertEqual(revisionAfterRetry, revisionAfterFirst)
        let undone = try await service.undo(albumID: initial.id)
        XCTAssertEqual(undone.pages[0].elements.map(\.id), [elementID])
    }

    // 3:ARC-007, 3:CLP-002
    func testCutRetryDoesNotOverwriteClipboardChangedAfterFirstSuccess() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        let cutID = UUID()
        let latestClipboardID = UUID()
        _ = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: cutID
        )
        _ = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: latestClipboardID
        )
        _ = try await service.updateElementGeometry(
            ElementGeometry(centerX: 0.2, centerY: 0.3, order: 1_024),
            elementID: cutID,
            on: initial.pages[0].id,
            in: initial.id
        )
        _ = try await service.updateElementGeometry(
            ElementGeometry(centerX: 0.8, centerY: 0.7, order: 2_048),
            elementID: latestClipboardID,
            on: initial.pages[0].id,
            in: initial.id
        )
        let commandID = UUID()
        _ = try await service.cutElement(
            cutID,
            on: initial.pages[0].id,
            in: initial.id,
            commandID: commandID
        )
        try await service.copyElement(
            latestClipboardID,
            on: initial.pages[0].id,
            in: initial.id
        )

        _ = try await service.cutElement(
            cutID,
            on: initial.pages[0].id,
            in: initial.id,
            commandID: commandID
        )
        let pastedID = UUID()
        let pasted = try await service.pasteElement(
            on: initial.pages[0].id,
            in: initial.id,
            newElementID: pastedID,
            offsetNormalized: GeometryPoint(x: 0, y: 0)
        )
        let geometry = try XCTUnwrap(pasted.pages[0].element(id: pastedID)?.geometry)
        XCTAssertEqual(geometry.centerX, 0.8, accuracy: 1e-12)
        XCTAssertEqual(geometry.centerY, 0.7, accuracy: 1e-12)
    }

    // 3:CLP-002, 3:LOC-004, 3:LOC-011
    func testFailedCutPreservesAlbumUndoHistoryAndPreviousClipboard() async throws {
        let repository = FailingOnceLibraryRepository(snapshot: LocalLibrarySnapshot(
            blobIndex: TestFixtures.catalogBlobEntries
        ))
        let service = AlbumApplicationService(repository: repository)
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        let sourceID = UUID()
        let targetID = UUID()
        _ = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: sourceID
        )
        _ = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: targetID
        )
        _ = try await service.updateElementGeometry(
            ElementGeometry(centerX: 0.2, centerY: 0.3, order: 1_024),
            elementID: sourceID,
            on: initial.pages[0].id,
            in: initial.id
        )
        _ = try await service.updateElementGeometry(
            ElementGeometry(centerX: 0.8, centerY: 0.7, order: 2_048),
            elementID: targetID,
            on: initial.pages[0].id,
            in: initial.id
        )
        try await service.copyElement(sourceID, on: initial.pages[0].id, in: initial.id)
        let before = try await service.snapshot()
        let canUndoBefore = await service.canUndo(albumID: initial.id)
        await repository.failNextCommit()

        await XCTAssertThrowsDomainError({
            try await service.cutElement(
                targetID,
                on: initial.pages[0].id,
                in: initial.id,
                commandID: UUID()
            )
        }, matching: { $0 == .injectedFailure("beforeCommit") })

        let afterFailure = try await service.snapshot()
        let canUndoAfterFailure = await service.canUndo(albumID: initial.id)
        XCTAssertEqual(afterFailure, before)
        XCTAssertEqual(canUndoAfterFailure, canUndoBefore)
        let pastedID = UUID()
        let pasted = try await service.pasteElement(
            on: initial.pages[0].id,
            in: initial.id,
            newElementID: pastedID,
            offsetNormalized: GeometryPoint(x: 0, y: 0)
        )
        let pastedGeometry = try XCTUnwrap(pasted.pages[0].element(id: pastedID)?.geometry)
        XCTAssertEqual(pastedGeometry.centerX, 0.2, accuracy: 1e-12)
        XCTAssertEqual(pastedGeometry.centerY, 0.3, accuracy: 1e-12)
        XCTAssertNotNil(pasted.pages[0].element(id: targetID))
    }

    // 3:PHO-016...3:PHO-018, 3:LOC-012, 3:CLP-001...3:CLP-005
    func testClipboardRejectsCrossAlbumPasteWithoutCreatingAssetOrRevision() async throws {
        let service = TestFixtures.service()
        let (source, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        let sourceElementID = UUID()
        _ = try await service.addPhotoFrame(
            to: source.pages[0].id,
            in: source.id,
            assetID: metadata.id,
            elementID: sourceElementID
        )
        let target = try await service.createAlbum(named: "Destination")
        try await service.copyElement(
            sourceElementID,
            on: source.pages[0].id,
            in: source.id
        )

        let sourceSession = await service.sessionState(for: source.id)
        let targetSession = await service.sessionState(for: target.id)
        XCTAssertTrue(sourceSession.hasCompatibleClipboard)
        XCTAssertFalse(targetSession.hasCompatibleClipboard)
        let before = try await service.snapshot()

        await XCTAssertThrowsDomainError({
            try await service.pasteElement(
                on: target.pages[0].id,
                in: target.id,
                newElementID: UUID(),
                commandID: UUID()
            )
        }, matching: { $0 == .invalidClipboard })

        let after = try await service.snapshot()
        XCTAssertEqual(after, before)
        XCTAssertTrue(after.photoAssets(in: target.id).isEmpty)
        let unchangedTarget = try await service.album(id: target.id)
        XCTAssertTrue(unchangedTarget.pages[0].elements.isEmpty)
    }

    // 3:ELM-008, 3:DAT-012
    func testDepthCommandsRenumberWithConstantStep() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        let firstID = UUID()
        let secondID = UUID()
        _ = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: firstID
        )
        _ = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: secondID
        )
        let moved = try await service.moveElementDepth(
            .front,
            elementID: firstID,
            on: initial.pages[0].id,
            in: initial.id
        )
        XCTAssertEqual(moved.pages[0].orderedElements.map(\.id), [secondID, firstID])
        XCTAssertEqual(moved.pages[0].orderedElements.map { $0.geometry.order }, [1_024, 2_048])
    }

    // 3:UND-003
    func testNewModificationAfterUndoClearsRedoBranch() async throws {
        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Guatemala")
        _ = try await service.addPage(to: album.id)
        _ = try await service.undo(albumID: album.id)
        _ = try await service.addPage(to: album.id)
        let canRedo = await service.canRedo(albumID: album.id)
        XCTAssertFalse(canRedo)
    }

    // 3:LOC-011, 3:UND-011
    func testLibraryUndoRedoRetriesDoNotMoveAnotherHistoryEntry() async throws {
        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Avant")
        _ = try await service.renameAlbum(album.id, to: "Après", history: .library)
        let undoID = UUID()
        let firstUndo = try await service.undoLibrary(commandID: undoID)
        let retryUndo = try await service.undoLibrary(commandID: undoID)
        XCTAssertEqual(firstUndo.name, "Avant")
        XCTAssertEqual(retryUndo, firstUndo)
        let canRedoAfterRetry = await service.canRedoLibrary()
        XCTAssertTrue(canRedoAfterRetry)
        let redoID = UUID()
        let firstRedo = try await service.redoLibrary(commandID: redoID)
        let retryRedo = try await service.redoLibrary(commandID: redoID)
        XCTAssertEqual(firstRedo.name, "Après")
        XCTAssertEqual(retryRedo, firstRedo)
        let canRedo = await service.canRedoLibrary()
        XCTAssertFalse(canRedo)
    }

    // 3:DAT-002
    func testSemanticNoOpsDoNotChangeRevisionUpdatedAtOrUndoStacks() async throws {
        let service = TestFixtures.service()
        let created = try await service.createAlbum(
            named: "Guatemala",
            now: TestFixtures.date
        )
        let beforeRename = try await service.snapshot()
        let renamed = try await service.renameAlbum(
            created.id,
            to: "  Guatemala  ",
            history: .library,
            now: TestFixtures.date.addingTimeInterval(100)
        )
        let afterRename = try await service.snapshot()
        XCTAssertEqual(afterRename.revision, beforeRename.revision)
        XCTAssertEqual(renamed.updatedAt, created.updatedAt)
        let canUndoLibrary = await service.canUndoLibrary()
        XCTAssertFalse(canUndoLibrary)

        let background = try await service.setBackground(
            .classicSpiral,
            on: created.pages[0].id,
            in: created.id,
            now: TestFixtures.date.addingTimeInterval(200)
        )
        let afterBackground = try await service.snapshot()
        XCTAssertEqual(afterBackground.revision, beforeRename.revision)
        XCTAssertEqual(background.updatedAt, created.updatedAt)

        let withFrame = try await service.addPhotoFrame(
            to: created.pages[0].id,
            in: created.id
        )
        let sceneID = UUID()
        let acquired = await service.editLeases.acquire(albumID: created.id, sceneID: sceneID)
        XCTAssertTrue(acquired)
        let closed = try await service.closeEditingSession(albumID: created.id, sceneID: sceneID)
        XCTAssertTrue(closed)
        let beforeDepth = try await service.snapshot()
        let unchanged = try await service.moveElementDepth(
            .front,
            elementID: withFrame.pages[0].elements[0].id,
            on: created.pages[0].id,
            in: created.id,
            now: TestFixtures.date.addingTimeInterval(300)
        )
        let afterDepth = try await service.snapshot()
        XCTAssertEqual(afterDepth.revision, beforeDepth.revision)
        XCTAssertEqual(unchanged.updatedAt, withFrame.updatedAt)
        let canUndoEditor = await service.canUndo(albumID: created.id)
        XCTAssertFalse(canUndoEditor)
    }

    // 3:ELM-009
    func testPasteDepthIsImmediatelyAboveSourceOnSamePageAndFrontOnAnotherPage() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(service: service)
        let backID = UUID(), sourceID = UUID(), frontID = UUID()
        var album = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: backID
        )
        album = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: sourceID
        )
        album = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: frontID
        )
        try await service.copyElement(sourceID, on: initial.pages[0].id, in: initial.id)
        let samePageCopyID = UUID()
        album = try await service.pasteElement(
            on: initial.pages[0].id,
            in: initial.id,
            newElementID: samePageCopyID,
            offsetNormalized: GeometryPoint(x: 0.01, y: 0.02)
        )
        XCTAssertEqual(album.pages[0].orderedElements.map(\.id), [
            backID, sourceID, samePageCopyID, frontID
        ])
        let copiedGeometry = try XCTUnwrap(album.pages[0].element(id: samePageCopyID)?.geometry)
        XCTAssertEqual(copiedGeometry.centerX, 0.51, accuracy: 1e-12)
        XCTAssertEqual(copiedGeometry.centerY, 0.52, accuracy: 1e-12)

        let otherPageID = UUID(), existingID = UUID(), crossPageCopyID = UUID()
        album = try await service.addPage(
            to: initial.id,
            pageID: otherPageID
        )
        album = try await service.addPhotoFrame(
            to: otherPageID,
            in: initial.id,
            assetID: metadata.id,
            elementID: existingID
        )
        album = try await service.pasteElement(
            on: otherPageID,
            in: initial.id,
            newElementID: crossPageCopyID,
            offsetNormalized: GeometryPoint(x: 0, y: 0)
        )
        XCTAssertEqual(album.pages[1].orderedElements.map(\.id), [existingID, crossPageCopyID])
    }

    // 3:APP-011
    func testEditLeaseAllowsOnlyOneWriterPerAlbumAndReleasesByScene() async {
        let leases = AlbumEditLeaseService()
        let firstScene = UUID()
        let secondScene = UUID()
        let firstAcquisition = await leases.acquire(albumID: TestFixtures.albumID, sceneID: firstScene)
        let blockedAcquisition = await leases.acquire(albumID: TestFixtures.albumID, sceneID: secondScene)
        XCTAssertTrue(firstAcquisition)
        XCTAssertFalse(blockedAcquisition)
        await leases.release(albumID: TestFixtures.albumID, sceneID: firstScene)
        let secondAcquisition = await leases.acquire(albumID: TestFixtures.albumID, sceneID: secondScene)
        XCTAssertTrue(secondAcquisition)
    }

    // 3:APP-006, 3:APP-011, 3:UND-012
    func testStaleSceneCloseCannotClearNewOwnersUndoHistory() async throws {
        let leases = AlbumEditLeaseService()
        let service = AlbumApplicationService(
            repository: InMemoryLibraryRepository(snapshot: LocalLibrarySnapshot(
                blobIndex: TestFixtures.catalogBlobEntries
            )),
            editLeases: leases
        )
        let album = try await service.createAlbum(named: "Guatemala")
        let sceneA = UUID()
        let sceneB = UUID()
        let acquiredByA = await leases.acquire(albumID: album.id, sceneID: sceneA)
        XCTAssertTrue(acquiredByA)
        _ = try await service.addPage(to: album.id)

        let closedA = try await service.closeEditingSession(albumID: album.id, sceneID: sceneA)
        XCTAssertTrue(closedA)
        let acquiredByB = await leases.acquire(albumID: album.id, sceneID: sceneB)
        XCTAssertTrue(acquiredByB)
        let pageAddedByB = UUID()
        _ = try await service.addPage(
            to: album.id,
            pageID: pageAddedByB
        )
        let canUndoBeforeStaleClose = await service.canUndo(albumID: album.id)
        XCTAssertTrue(canUndoBeforeStaleClose)

        let staleClose = try await service.closeEditingSession(albumID: album.id, sceneID: sceneA)
        XCTAssertFalse(staleClose)
        let canUndoAfterStaleClose = await service.canUndo(albumID: album.id)
        XCTAssertTrue(canUndoAfterStaleClose)
        let undone = try await service.undo(albumID: album.id)
        XCTAssertFalse(undone.pages.contains { $0.id == pageAddedByB })
    }
}
