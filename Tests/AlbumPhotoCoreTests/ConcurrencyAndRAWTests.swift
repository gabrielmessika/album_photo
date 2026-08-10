import Foundation
import XCTest
@testable import AlbumPhotoCore

private actor SlowReentrantLibraryRepository: LibraryRepository {
    private var snapshot: LocalLibrarySnapshot

    init(snapshot: LocalLibrarySnapshot) {
        self.snapshot = snapshot
    }

    func load() async throws -> LocalLibrarySnapshot {
        let value = snapshot
        // The suspension makes two unguarded application commands observe the
        // same revision deterministically enough to expose actor reentrancy.
        try await Task.sleep(nanoseconds: 5_000_000)
        return value
    }

    func commit(_ transaction: PersistedTransaction) async throws {
        if snapshot.appliedCommandIDs.contains(transaction.commandID) { return }
        guard transaction.expectedRevision == snapshot.revision else {
            throw DomainValidationError.staleRevision(
                expected: transaction.expectedRevision,
                actual: snapshot.revision
            )
        }
        try DomainValidator.validate(transaction.resultingSnapshot)
        snapshot = transaction.resultingSnapshot
    }

    func flush() async throws {}
}

final class LibraryConcurrencyTests: XCTestCase {
    // 3:APP-002, 3:APP-005, 3:LOC-011...3:LOC-014
    func testConcurrentAlbumCommandsKeepEveryMutationWithoutStaleRevision() async throws {
        let repository = SlowReentrantLibraryRepository(snapshot: LocalLibrarySnapshot(
            blobIndex: TestFixtures.catalogBlobEntries
        ))
        let service = AlbumApplicationService(repository: repository)
        let album = try await service.createAlbum(named: "Concurrence")
        let pageIDs = (0..<12).map { _ in UUID() }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for pageID in pageIDs {
                group.addTask {
                    _ = try await service.addPage(
                        to: album.id,
                        after: album.pages[0].id,
                        pageID: pageID
                    )
                }
            }
            try await group.waitForAll()
        }

        let finalPageID = UUID()
        async let background: AlbumSnapshot = service.setBackground(
            .solid(.white),
            on: album.pages[0].id,
            in: album.id
        )
        async let page: AlbumSnapshot = service.addPage(
            to: album.id,
            after: album.pages[0].id,
            pageID: finalPageID
        )
        _ = try await (background, page)

        let stored = try await service.album(id: album.id)
        XCTAssertEqual(stored.pages.count, 14)
        XCTAssertTrue(Set(pageIDs + [finalPageID]).isSubset(of: Set(stored.pages.map(\.id))))
        XCTAssertEqual(stored.pages.first?.background, .solid(.white))
    }

    // 3:APP-002, 3:APP-005, 3:APP-006, 3:UND-011, 3:ARC-007
    func testLeaseBlocksEveryLibraryAlbumMutationWithoutChangingSnapshot() async throws {
        let service = TestFixtures.service()
        let (initial, metadata) = try await TestFixtures.albumWithRegisteredPhoto(
            service: service
        )
        let framed = try await service.addPhotoFrame(
            to: initial.pages[0].id,
            in: initial.id,
            assetID: metadata.id,
            elementID: TestFixtures.elementID
        )
        let sceneID = UUID()
        let acquired = await service.editLeases.acquire(
            albumID: initial.id,
            sceneID: sceneID
        )
        XCTAssertTrue(acquired)
        let before = try await service.snapshot()

        await XCTAssertThrowsDomainError({
            try await service.renameAlbum(initial.id, to: "Bloqué", history: .library)
        }, matching: { $0 == .albumLibraryMutationBlocked(initial.id) })
        await XCTAssertThrowsDomainError({
            try await service.setCover(
                .pagePhoto(pageID: framed.pages[0].id, elementID: TestFixtures.elementID),
                for: initial.id,
                fromLibrary: true
            )
        }, matching: { $0 == .albumLibraryMutationBlocked(initial.id) })
        await XCTAssertThrowsDomainError({
            try await service.moveAlbumToTrash(initial.id)
        }, matching: { $0 == .albumLibraryMutationBlocked(initial.id) })
        let afterBlockedCommands = try await service.snapshot()
        XCTAssertEqual(afterBlockedCommands, before)

        await service.editLeases.release(albumID: initial.id, sceneID: sceneID)
        let renamed = try await service.renameAlbum(
            initial.id,
            to: "Autorisé",
            history: .library
        )
        XCTAssertEqual(renamed.name, "Autorisé")
    }

    // 3:APP-002, 3:APP-005, 3:UND-011
    func testLibraryUndoCannotOverwriteAnAlbumWithAnEditingLease() async throws {
        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Avant")
        _ = try await service.renameAlbum(album.id, to: "Après", history: .library)
        let sceneID = UUID()
        let acquired = await service.editLeases.acquire(
            albumID: album.id,
            sceneID: sceneID
        )
        XCTAssertTrue(acquired)

        await XCTAssertThrowsDomainError({
            try await service.undoLibrary()
        }, matching: { $0 == .albumLibraryMutationBlocked(album.id) })
        let stillRenamed = try await service.album(id: album.id)
        XCTAssertEqual(stillRenamed.name, "Après")

        await service.editLeases.release(albumID: album.id, sceneID: sceneID)
        let undone = try await service.undoLibrary()
        XCTAssertEqual(undone.name, "Avant")
    }

    // 3:ARC-007, 3:APP-002, 3:UND-011
    func testAppliedLibraryMutationAndUndoRetriesRemainIdempotentWhileLeased() async throws {
        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Avant")
        let renameID = UUID()
        let firstRename = try await service.renameAlbum(
            album.id,
            to: "Après",
            history: .library,
            commandID: renameID
        )
        let sceneID = UUID()
        let acquiredForRenameRetry = await service.editLeases.acquire(
            albumID: album.id,
            sceneID: sceneID
        )
        XCTAssertTrue(acquiredForRenameRetry)
        let retryRename = try await service.renameAlbum(
            album.id,
            to: "Après",
            history: .library,
            commandID: renameID
        )
        XCTAssertEqual(retryRename, firstRename)
        await service.editLeases.release(albumID: album.id, sceneID: sceneID)

        let undoID = UUID()
        let firstUndo = try await service.undoLibrary(commandID: undoID)
        let acquiredForUndoRetry = await service.editLeases.acquire(
            albumID: album.id,
            sceneID: sceneID
        )
        XCTAssertTrue(acquiredForUndoRetry)
        let retryUndo = try await service.undoLibrary(commandID: undoID)
        XCTAssertEqual(retryUndo, firstUndo)
        await service.editLeases.release(albumID: album.id, sceneID: sceneID)
    }

    // 3:APP-002, 3:APP-006, 3:UND-012
    func testLibraryBarrierBlocksLeaseAndClosingLibraryClearsBothStacks() async throws {
        let leases = AlbumEditLeaseService()
        let mutationID = UUID()
        let beganMutation = await leases.beginLibraryMutation(
            albumID: TestFixtures.albumID,
            mutationID: mutationID
        )
        XCTAssertTrue(beganMutation)
        let acquisitionDuringMutation = await leases.acquire(
            albumID: TestFixtures.albumID,
            sceneID: UUID()
        )
        XCTAssertFalse(acquisitionDuringMutation)
        await leases.completeLibraryMutation(
            albumID: TestFixtures.albumID,
            mutationID: mutationID
        )

        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "Un")
        _ = try await service.renameAlbum(album.id, to: "Deux", history: .library)
        _ = try await service.renameAlbum(album.id, to: "Trois", history: .library)
        _ = try await service.undoLibrary()
        let canUndoBeforeClose = await service.canUndoLibrary()
        let canRedoBeforeClose = await service.canRedoLibrary()
        XCTAssertTrue(canUndoBeforeClose)
        XCTAssertTrue(canRedoBeforeClose)

        try await service.closeLibrarySession()
        let canUndoAfterClose = await service.canUndoLibrary()
        let canRedoAfterClose = await service.canRedoLibrary()
        XCTAssertFalse(canUndoAfterClose)
        XCTAssertFalse(canRedoAfterClose)
        await XCTAssertThrowsDomainError({
            try await service.undoLibrary()
        }, matching: { $0 == .nothingToUndo })
    }

    // 3:APP-005, 3:UND-011 — two rapid taps are FIFO commands, not busy errors.
    func testRapidLibraryCommandsAndUndosAreSerialised() async throws {
        let service = AlbumApplicationService(repository: SlowReentrantLibraryRepository(
            snapshot: LocalLibrarySnapshot(blobIndex: TestFixtures.catalogBlobEntries)
        ))
        let album = try await service.createAlbum(named: "Initial")
        async let first: AlbumSnapshot = service.renameAlbum(
            album.id,
            to: "Premier",
            history: .library
        )
        async let second: AlbumSnapshot = service.renameAlbum(
            album.id,
            to: "Second",
            history: .library
        )
        _ = try await (first, second)

        async let firstUndo: AlbumSnapshot = service.undoLibrary()
        async let secondUndo: AlbumSnapshot = service.undoLibrary()
        _ = try await (firstUndo, secondUndo)
        let stored = try await service.album(id: album.id)
        XCTAssertEqual(stored.name, "Initial")
    }
}

final class RAWDerivativeTests: XCTestCase {
    private func fixture(
        id: UUID = UUID()
    ) -> (
        original: Data,
        derivative: Data,
        metadata: PhotoAssetMetadata,
        originalBlob: AssetBlobIndexEntry,
        derivativeBlob: AssetBlobIndexEntry
    ) {
        let original = Data("synthetic raw original".utf8)
        let derivative = Data("synthetic static png derivative".utf8)
        let displayDerivative = TestFixtures.displayDerivative(data: derivative)
        return (
            original,
            derivative,
            TestFixtures.metadata(
                id: id,
                data: original,
                mimeType: "image/x-raw",
                displayDerivative: displayDerivative
            ),
            TestFixtures.blob(data: original, mimeType: "image/x-raw"),
            TestFixtures.blob(data: derivative, mimeType: "image/png")
        )
    }

    // 3:FMT-002, 3:DAT-010, 3:LOC-016
    func testRAWMissingDerivativeMetadataOrRegistrationIsRejectedAtomically() async throws {
        XCTAssertThrowsError(try DomainValidator.validate(TestFixtures.metadata(
            data: Data("raw".utf8),
            mimeType: "image/x-raw"
        )))

        let service = TestFixtures.service()
        let album = try await service.createAlbum(named: "RAW")
        let value = fixture()
        await XCTAssertThrowsDomainError({
            try await service.registerPhoto(
                value.metadata,
                blob: value.originalBlob,
                in: album.id
            )
        }, matching: { $0 == .invalidPhotoMetadata })
        let state = try await service.snapshot()
        XCTAssertTrue(state.photoAssets.isEmpty)
        XCTAssertNil(state.blobIndex.first { $0.contentHash == value.originalBlob.contentHash })
        XCTAssertNil(state.blobIndex.first { $0.contentHash == value.derivativeBlob.contentHash })
    }

    // 3:FMT-002, 3:DAT-010, 3:DAT-017, 3:PHO-017, 3:PHO-018
    func testRAWIndexesCountsAndPhysicallyVerifiesOriginalAndDerivativeForReuse() async throws {
        let service = TestFixtures.service()
        let source = try await service.createAlbum(named: "Source RAW")
        let target = try await service.createAlbum(named: "Cible RAW")
        let value = fixture()
        _ = try await service.registerPhoto(
            value.metadata,
            blob: value.originalBlob,
            displayDerivativeBlob: value.derivativeBlob,
            in: source.id
        )

        var state = try await service.snapshot()
        for hash in value.metadata.durableContentHashes {
            let indexed = try XCTUnwrap(state.blobIndex.first { $0.contentHash == hash })
            XCTAssertGreaterThan(indexed.referenceCount, 0)
            XCTAssertEqual(indexed.state, .available)
        }

        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = ContentAddressedAssetStore(directoryURL: directory)
        _ = try await store.store(
            data: value.original,
            detectedContentType: value.metadata.mimeType
        )
        _ = try await store.store(
            data: value.derivative,
            detectedContentType: "image/png"
        )
        let reused = try await VerifiedPhotoReuseCoordinator(
            assetStore: store,
            applicationService: service
        ).reusePhotos(
            assetIDs: [value.metadata.id],
            from: source.id,
            to: target.id
        )
        XCTAssertEqual(reused.count, 1)
        XCTAssertEqual(reused[0].contentHash, value.metadata.contentHash)
        XCTAssertEqual(reused[0].displayDerivative, value.metadata.displayDerivative)

        state = try await service.snapshot()
        for hash in value.metadata.durableContentHashes {
            XCTAssertGreaterThanOrEqual(
                try XCTUnwrap(state.blobIndex.first { $0.contentHash == hash }).referenceCount,
                2
            )
        }
    }

    // 3:LOC-017, 3:FMT-002 — immutable RAW derivatives consume capacity once.
    func testRAWDerivativeParticipatesInDeduplicatedCapacity() {
        let id = UUID()
        var album = AlbumSnapshot(
            id: UUID(),
            name: "Capacité RAW",
            background: .none
        )
        album.photoAssetIDs = [id]
        let derivative = PhotoDisplayDerivative(
            contentHash: String(repeating: "d", count: 64),
            pixelWidth: 1,
            pixelHeight: 1,
            byteCount: 5_000_000_000
        )
        let metadata = PhotoAssetMetadata(
            id: id,
            contentHash: String(repeating: "a", count: 64),
            mimeType: "image/x-raw",
            pixelWidth: 1,
            pixelHeight: 1,
            byteCount: 1,
            source: .files,
            displayDerivative: derivative
        )
        XCTAssertTrue(AlbumCapacityPolicy.warnings(
            for: album,
            photoAssets: [metadata]
        ).contains(.albumByteCount(
            actual: 5_000_000_001,
            guaranteed: 5_000_000_000
        )))
    }

    // 3:DAT-027 — local display encoding is outside the logical album hash.
    func testLogicalHashIsIndependentFromRAWDisplayDerivativeEncoding() throws {
        let assetID = UUID()
        var album = AlbumSnapshot(id: UUID(), name: "Empreinte RAW")
        album.photoAssetIDs = [assetID]
        let first = fixture(id: assetID).metadata
        let otherData = Data("different valid display encoding".utf8)
        let second = TestFixtures.metadata(
            id: assetID,
            data: Data("synthetic raw original".utf8),
            mimeType: "image/x-raw",
            displayDerivative: TestFixtures.displayDerivative(data: otherData)
        )
        XCTAssertEqual(
            try AlbumLogicalFingerprint.hash(album: album, photoAssets: [first]),
            try AlbumLogicalFingerprint.hash(album: album, photoAssets: [second])
        )
    }
}
