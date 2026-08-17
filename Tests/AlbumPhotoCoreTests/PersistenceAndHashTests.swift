import Foundation
import XCTest
@testable import AlbumPhotoCore

final class PersistenceAndHashTests: XCTestCase {
    private struct CanonicalFixture: Codable {
        let z: Int
        let id: UUID
        let text: String
        let date: Date
    }

    private func seedCatalogIndex(at directory: URL) throws {
        let database = directory.appendingPathComponent("Database", isDirectory: true)
        try FileManager.default.createDirectory(at: database, withIntermediateDirectories: true)
        try CanonicalJSON.encode(LocalLibrarySnapshot(
            blobIndex: TestFixtures.catalogBlobEntries
        )).write(to: database.appendingPathComponent("library-v1.json"), options: .atomic)
    }

    // 3:LOC-007
    func testSHA256StandardVectors() {
        XCTAssertEqual(
            SHA256.hexDigest(Data()),
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        )
        XCTAssertEqual(
            SHA256.hexDigest(Data("abc".utf8)),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        )
    }

    // 3:LOC-007 — vectors NIST split before, on and after SHA-256 block edges.
    func testIncrementalSHA256MatchesStandardVectorsAcrossUnevenChunks() {
        let vectors: [(Data, String)] = [
            (
                Data(),
                "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
            ),
            (
                Data("abc".utf8),
                "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
            ),
            (
                Data(
                    "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq".utf8
                ),
                "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1"
            )
        ]
        let chunkSizes = [1, 7, 2, 31, 3, 64, 5, 65]

        for (data, expectedHash) in vectors {
            var hasher = SHA256IncrementalHasher()
            var offset = 0
            var chunkIndex = 0
            while offset < data.count {
                let end = min(offset + chunkSizes[chunkIndex % chunkSizes.count], data.count)
                hasher.update(data.subdata(in: offset..<end))
                offset = end
                chunkIndex += 1
            }

            XCTAssertEqual(hasher.byteCount, UInt64(data.count))
            XCTAssertEqual(hasher.hexDigest(), expectedHash)
            XCTAssertEqual(hasher.hexDigest(), expectedHash, "finalize doit être non destructif")
        }

        let millionAs = Data(repeating: 0x61, count: 1_000_000)
        var millionHasher = SHA256IncrementalHasher()
        for offset in stride(from: 0, to: millionAs.count, by: 8_191) {
            millionHasher.update(
                millionAs.subdata(in: offset..<min(offset + 8_191, millionAs.count))
            )
        }
        XCTAssertEqual(
            millionHasher.hexDigest(),
            "cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0"
        )
    }

    // 3:LOC-007 — one physical file is hashed through many bounded reads.
    func testFileFingerprintStreamsMultipleChunksWithExactByteCount() throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let data = Data((0..<200_123).map {
            UInt8(truncatingIfNeeded: ($0 &* 31) &+ 17)
        })
        let file = directory.appendingPathComponent("multi-chunk.bin")
        try data.write(to: file)

        let fingerprint = try SHA256.fingerprint(fileAt: file, chunkSize: 4_093)

        XCTAssertEqual(fingerprint.byteCount, Int64(data.count))
        XCTAssertEqual(fingerprint.contentHash, SHA256.hexDigest(data))
    }

    // 3:DAT-020, 3:DAT-021, 3:DAT-024
    func testCanonicalJSONSortsKeysLowercasesIdentifierAndPreservesUserText() throws {
        let upper = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
        let fixture = CanonicalFixture(
            z: 2,
            id: UUID(uuidString: upper)!,
            text: upper,
            date: TestFixtures.date
        )
        let encoded = try XCTUnwrap(String(
            data: CanonicalJSON.encode(fixture),
            encoding: .utf8
        ))
        XCTAssertEqual(encoded.first, "{")
        XCTAssertLessThan(try XCTUnwrap(encoded.range(of: "\"date\"" )?.lowerBound),
                          try XCTUnwrap(encoded.range(of: "\"id\"" )?.lowerBound))
        XCTAssertTrue(encoded.contains("aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"))
        XCTAssertTrue(encoded.contains("\"text\":\"\(upper)\""))
        XCTAssertTrue(encoded.contains("2023-11-14T22:13:20.123Z"))
    }

    // 3:DAT-022, 3:DAT-024 — RFC 8785 / ECMAScript exponent boundaries.
    func testCanonicalJSONUsesECMAScriptNumberThresholds() throws {
        let encoded = try XCTUnwrap(String(
            data: CanonicalJSON.encode([1e20, 1e-6, 1e21, 1e-7]),
            encoding: .utf8
        ))
        XCTAssertEqual(encoded, "[100000000000000000000,0.000001,1e+21,1e-7]")
    }

    // 3:DAT-027, 3:DAT-028
    func testLogicalHashExcludesOperationalDatesButIncludesNameAndPageContent() throws {
        var first = AlbumSnapshot(
            id: TestFixtures.albumID,
            name: "Guatemala",
            firstPageID: TestFixtures.pageID,
            createdAt: TestFixtures.date
        )
        var sameContent = AlbumSnapshot(
            id: TestFixtures.albumID,
            name: "Guatemala",
            firstPageID: TestFixtures.pageID,
            createdAt: TestFixtures.date.addingTimeInterval(500)
        )
        first.updatedAt = TestFixtures.date.addingTimeInterval(1)
        sameContent.updatedAt = TestFixtures.date.addingTimeInterval(900)
        sameContent.trashedAt = TestFixtures.date.addingTimeInterval(1_000)
        let firstHash = try AlbumLogicalFingerprint.hash(album: first, photoAssets: [])
        let datesChangedHash = try AlbumLogicalFingerprint.hash(album: sameContent, photoAssets: [])
        XCTAssertEqual(firstHash, datesChangedHash)
        sameContent.name = "Voyage"
        XCTAssertNotEqual(
            firstHash,
            try AlbumLogicalFingerprint.hash(album: sameContent, photoAssets: [])
        )
        sameContent.name = first.name
        sameContent.pages[0].background = .solid(.white)
        XCTAssertNotEqual(
            firstHash,
            try AlbumLogicalFingerprint.hash(album: sameContent, photoAssets: [])
        )
    }

    // 3:LOC-001...3:LOC-006, 3:TST-007
    func testTransactionalRepositoryPersistsAcrossRelaunch() async throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        try seedCatalogIndex(at: directory)
        let firstRepository = TransactionalJSONLibraryRepository(directoryURL: directory)
        let firstService = AlbumApplicationService(repository: firstRepository)
        let persistedID = UUID(uuidString: "AAAAAAAA-BBBB-4CCC-8DDD-EEEEEEEEEEEE")!
        let created = try await firstService.createAlbum(
            named: "Guatemala",
            id: persistedID,
            firstPageID: TestFixtures.pageID,
            now: TestFixtures.date
        )
        try await firstService.save()
        let relaunched = AlbumApplicationService(
            repository: TransactionalJSONLibraryRepository(directoryURL: directory)
        )
        let loaded = try await relaunched.album(id: created.id)
        XCTAssertEqual(loaded, created)
        let storeData = try Data(contentsOf: directory
            .appendingPathComponent("Database/library-v1.json"))
        let storeJSON = try XCTUnwrap(String(data: storeData, encoding: .utf8))
        XCTAssertTrue(storeJSON.contains(created.id.uuidString.lowercased()))
        XCTAssertFalse(storeJSON.contains(created.id.uuidString.uppercased()))
    }

    // 3:ALB-020, 3:DAT-020...3:DAT-024, 3:LOC-009...3:LOC-014
    func testDeletionTombstoneSurvivesRelaunchInCanonicalStore() async throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        try seedCatalogIndex(at: directory)
        let albumID = UUID(uuidString: "ABCDEFAB-CDEF-4ABC-8DEF-ABCDEFABCDEF")!
        let commandID = UUID(uuidString: "12345678-1234-4234-8234-123456789ABC")!
        let trashedAt = TestFixtures.date
        let deletedAt = trashedAt.addingTimeInterval(60)
        let service = AlbumApplicationService(
            repository: TransactionalJSONLibraryRepository(directoryURL: directory)
        )
        _ = try await service.createAlbum(
            named: "Suppression durable",
            id: albumID,
            firstPageID: TestFixtures.pageID,
            now: trashedAt.addingTimeInterval(-1)
        )
        _ = try await service.moveAlbumToTrash(albumID, now: trashedAt)
        try await service.permanentlyDeleteAlbum(
            albumID,
            now: deletedAt,
            commandID: commandID
        )
        try await service.save()

        let relaunched = try await TransactionalJSONLibraryRepository(
            directoryURL: directory
        ).load()
        XCTAssertNil(relaunched.album(id: albumID))
        let tombstone = try XCTUnwrap(relaunched.albumDeletionTombstones.first)
        XCTAssertEqual(tombstone.albumID, albumID)
        XCTAssertEqual(tombstone.trashedAt, trashedAt)
        XCTAssertEqual(tombstone.deletedAt, deletedAt)
        XCTAssertEqual(tombstone.reason, .userConfirmed)
        XCTAssertEqual(tombstone.deletionCommandID, commandID)

        let storeData = try Data(contentsOf: directory
            .appendingPathComponent("Database/library-v1.json"))
        let storeJSON = try XCTUnwrap(String(data: storeData, encoding: .utf8))
        XCTAssertTrue(storeJSON.contains("\"albumDeletionTombstones\""))
        XCTAssertTrue(storeJSON.contains(albumID.uuidString.lowercased()))
        XCTAssertFalse(storeJSON.contains(albumID.uuidString.uppercased()))
    }

    // 3:ALB-020, 3:LOC-009...3:LOC-014
    func testCrashAfterDeletionJournalRecoversTombstoneAndRemovalTogether() async throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        try seedCatalogIndex(at: directory)
        let albumID = UUID(uuidString: "AAAAAAAA-CCCC-4DDD-8EEE-FFFFFFFFFFFF")!
        let commandID = UUID(uuidString: "99999999-8888-4777-8666-555555555555")!
        let trashedAt = TestFixtures.date
        let setupService = AlbumApplicationService(
            repository: TransactionalJSONLibraryRepository(directoryURL: directory)
        )
        _ = try await setupService.createAlbum(
            named: "Interruption",
            id: albumID,
            firstPageID: TestFixtures.pageID,
            now: trashedAt.addingTimeInterval(-1)
        )
        _ = try await setupService.moveAlbumToTrash(albumID, now: trashedAt)

        let interruptedService = AlbumApplicationService(
            repository: TransactionalJSONLibraryRepository(
                directoryURL: directory,
                faultInjector: FailingPersistenceInjector(checkpoint: .afterJournalWrite)
            )
        )
        await XCTAssertThrowsDomainError({
            try await interruptedService.permanentlyDeleteAlbum(
                albumID,
                now: trashedAt.addingTimeInterval(1),
                commandID: commandID
            )
        }, matching: { $0 == .injectedFailure("afterJournalWrite") })

        let recovered = try await TransactionalJSONLibraryRepository(
            directoryURL: directory
        ).load()
        XCTAssertNil(recovered.album(id: albumID))
        XCTAssertFalse(recovered.photoAssets.contains { $0.albumID == albumID })
        XCTAssertEqual(recovered.albumDeletionTombstones.count, 1)
        XCTAssertEqual(recovered.albumDeletionTombstones[0].albumID, albumID)
        XCTAssertEqual(recovered.albumDeletionTombstones[0].deletionCommandID, commandID)
    }

    // Internal generation-3 snapshots written before ALB-020 had no distinct
    // tombstone array; they remain readable because this format is not public.
    func testSnapshotWithoutDeletionTombstoneKeyDecodesAsEmptyArray() throws {
        let encoded = try JSONEncoder.albumPhotoEncoder.encode(LocalLibrarySnapshot.empty)
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        object.removeValue(forKey: "albumDeletionTombstones")
        let legacyData = try JSONSerialization.data(withJSONObject: object)
        let decoded = try JSONDecoder.albumPhotoDecoder.decode(
            LocalLibrarySnapshot.self,
            from: legacyData
        )
        XCTAssertEqual(decoded, .empty)
        XCTAssertTrue(decoded.albumDeletionTombstones.isEmpty)
    }

    // 3:DAT-032, 3:DAT-033, 3:LOC-029...3:LOC-031
    func testRepositoryRejectsOldGenerationBeforeSchema() async throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let database = directory.appendingPathComponent("Database", isDirectory: true)
        try FileManager.default.createDirectory(at: database, withIntermediateDirectories: true)
        let old = LocalLibrarySnapshot(modelGeneration: "prototype-2.1", schemaVersion: 999)
        try JSONEncoder.albumPhotoEncoder.encode(old).write(
            to: database.appendingPathComponent("library-v1.json")
        )
        let repository = TransactionalJSONLibraryRepository(directoryURL: directory)
        do {
            _ = try await repository.load()
            XCTFail("L’ancien store devait être refusé")
        } catch let error as DomainValidationError {
            XCTAssertEqual(error, .unsupportedGeneration("prototype-2.1"))
        }
    }

    // 3:LOC-029...3:LOC-031
    func testGenerationRootInitializationIsAtomicIdempotentAndRejectsPartialPublication() async throws {
        let support = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: support) }
        XCTAssertThrowsError(try AlbumPhotoRootInitializer.initialize(
            applicationSupportURL: support,
            faultInjector: FailingPersistenceInjector(checkpoint: .afterGenerationRootPrepared)
        ))
        let target = support.appendingPathComponent(
            AlbumPhotoRootInitializer.directoryName,
            isDirectory: true
        )
        XCTAssertFalse(FileManager.default.fileExists(atPath: target.path))
        XCTAssertFalse(try FileManager.default.contentsOfDirectory(atPath: support.path)
            .contains { $0.contains("-initializing-") })

        let root = try AlbumPhotoRootInitializer.initialize(applicationSupportURL: support)
        let repeated = try AlbumPhotoRootInitializer.initialize(applicationSupportURL: support)
        XCTAssertEqual(root, repeated)
        let snapshot = try await TransactionalJSONLibraryRepository(
            storageRoot: root
        ).load()
        XCTAssertEqual(snapshot, .empty)
        let store = ContentAddressedAssetStore(storageRoot: root)
        let entry = try await store.store(
            data: TestFixtures.data("root token"),
            detectedContentType: "image/jpeg"
        )
        let contains = await store.contains(entry.contentHash)
        XCTAssertTrue(contains)
    }

    // 3:DAT-002, 3:LOC-009...3:LOC-014
    func testInMemoryRepositoryEnforcesSameTransactionalEnvelopeAsJSONRepository() async throws {
        let repository = InMemoryLibraryRepository()
        let commandID = UUID(uuidString: "11111111-2222-4333-8444-555555555555")!

        await XCTAssertThrowsDomainError({
            try await repository.commit(PersistedTransaction(
                commandID: commandID,
                expectedRevision: 0,
                resultingSnapshot: LocalLibrarySnapshot(
                    revision: 1,
                    appliedCommandIDs: []
                )
            ))
        }, matching: {
            if case .persistenceFailure("transaction non idempotente") = $0 { return true }
            return false
        })

        await XCTAssertThrowsDomainError({
            try await repository.commit(PersistedTransaction(
                commandID: commandID,
                expectedRevision: 0,
                resultingSnapshot: LocalLibrarySnapshot(
                    revision: 2,
                    appliedCommandIDs: [commandID]
                )
            ))
        }, matching: {
            if case .persistenceFailure("transaction non idempotente") = $0 { return true }
            return false
        })

        let unchanged = try await repository.load()
        XCTAssertEqual(unchanged, .empty)

        let valid = LocalLibrarySnapshot(revision: 1, appliedCommandIDs: [commandID])
        try await repository.commit(PersistedTransaction(
            commandID: commandID,
            expectedRevision: 0,
            resultingSnapshot: valid
        ))
        let committed = try await repository.load()
        XCTAssertEqual(committed, valid)
    }

    // 3:LOC-009...3:LOC-014
    func testJournalReplaysCrashAfterJournalWriteExactlyOnce() async throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        try seedCatalogIndex(at: directory)
        let commandID = UUID(uuidString: "ABCDEFAB-CDEF-4ABC-8DEF-ABCDEFABCDEF")!
        let failing = TransactionalJSONLibraryRepository(
            directoryURL: directory,
            faultInjector: FailingPersistenceInjector(checkpoint: .afterJournalWrite)
        )
        let service = AlbumApplicationService(repository: failing)
        do {
            _ = try await service.createAlbum(
                named: "Guatemala",
                id: TestFixtures.albumID,
                firstPageID: TestFixtures.pageID,
                commandID: commandID
            )
            XCTFail("L’interruption injectée était attendue")
        } catch let error as DomainValidationError {
            XCTAssertEqual(error, .injectedFailure("afterJournalWrite"))
        }
        let pendingData = try Data(contentsOf: directory
            .appendingPathComponent("Journal/pending.json"))
        let pendingJSON = try XCTUnwrap(String(data: pendingData, encoding: .utf8))
        XCTAssertTrue(pendingJSON.contains(commandID.uuidString.lowercased()))
        XCTAssertFalse(pendingJSON.contains(commandID.uuidString.uppercased()))
        let recoveredRepository = TransactionalJSONLibraryRepository(directoryURL: directory)
        let recovered = try await recoveredRepository.load()
        XCTAssertEqual(recovered.albums.map(\.id), [TestFixtures.albumID])
        XCTAssertEqual(recovered.revision, 1)
        XCTAssertEqual(recovered.appliedCommandIDs, [commandID])
        let secondLoad = try await recoveredRepository.load()
        XCTAssertEqual(secondLoad, recovered)
    }

    // 3:APP-005, 3:ARC-007, 3:LOC-009...3:LOC-014, 3:UND-010
    func testPostPublicationCleanupFaultIsSuccessWithSameServiceRetryAndUndo() async throws {
        for checkpoint in [
            PersistenceCheckpoint.afterSnapshotReplace,
            .beforeJournalCleanup
        ] {
            let directory = try TestFixtures.temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: directory) }
            try seedCatalogIndex(at: directory)
            let repository = TransactionalJSONLibraryRepository(
                directoryURL: directory,
                faultInjector: FailingPersistenceInjector(checkpoint: checkpoint)
            )
            let service = AlbumApplicationService(repository: repository)
            let album = try await service.createAlbum(
                named: "Guatemala",
                id: TestFixtures.albumID,
                firstPageID: TestFixtures.pageID,
                now: TestFixtures.date,
                commandID: UUID()
            )
            let pageID = UUID()
            let commandID = UUID()

            let first = try await service.addPage(
                to: album.id,
                pageID: pageID,
                now: TestFixtures.date.addingTimeInterval(1),
                commandID: commandID
            )
            XCTAssertEqual(first.pages.map(\.id), [TestFixtures.pageID, pageID])
            let pendingURL = directory.appendingPathComponent("Journal/pending.json")
            XCTAssertTrue(FileManager.default.fileExists(atPath: pendingURL.path))

            let retry = try await service.addPage(
                to: album.id,
                pageID: pageID,
                now: TestFixtures.date.addingTimeInterval(1),
                commandID: commandID
            )
            XCTAssertEqual(retry, first)
            XCTAssertFalse(FileManager.default.fileExists(atPath: pendingURL.path))

            let canUndoBefore = await service.canUndo(albumID: album.id)
            XCTAssertTrue(canUndoBefore)
            let undone = try await service.undo(
                albumID: album.id,
                now: TestFixtures.date.addingTimeInterval(2)
            )
            XCTAssertEqual(undone.pages.map(\.id), [TestFixtures.pageID])
            let canUndoAfter = await service.canUndo(albumID: album.id)
            let canRedoAfter = await service.canRedo(albumID: album.id)
            XCTAssertFalse(canUndoAfter, "Le retry ne doit pas dupliquer l’historique")
            XCTAssertTrue(canRedoAfter)

            let durable = try await TransactionalJSONLibraryRepository(
                directoryURL: directory
            ).load()
            XCTAssertEqual(durable.album(id: album.id)?.pages.map(\.id), [TestFixtures.pageID])
            XCTAssertTrue(durable.appliedCommandIDs.contains(commandID))
        }
    }

    // 3:LOC-007, 3:LOC-015...3:LOC-017
    func testContentAddressedStoreDeduplicatesAndVerifiesExactBytes() async throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = ContentAddressedAssetStore(directoryURL: directory)
        let data = TestFixtures.data("same immutable bytes")
        let first = try await store.storeDetailed(data: data, detectedContentType: "image/jpeg")
        let second = try await store.storeDetailed(data: data, detectedContentType: "image/jpeg")
        XCTAssertFalse(first.wasDeduplicated)
        XCTAssertTrue(second.wasDeduplicated)
        XCTAssertEqual(first.entry, second.entry)
        let fingerprint = try await store.verifyPhysicalBlob(
            contentHash: first.entry.contentHash,
            expectedByteCount: first.entry.byteCount,
            chunkSize: 3
        )
        XCTAssertEqual(fingerprint.contentHash, first.entry.contentHash)
        XCTAssertEqual(fingerprint.byteCount, first.entry.byteCount)
        await XCTAssertThrowsDomainError({
            try await store.verifyPhysicalBlob(
                contentHash: first.entry.contentHash,
                expectedByteCount: first.entry.byteCount + 1,
                chunkSize: 3
            )
        }, matching: { $0 == .invalidBlobIndex(first.entry.contentHash) })
        let loaded = try await store.data(for: first.entry.contentHash)
        XCTAssertEqual(loaded, data)
        let assetsURL = directory.appendingPathComponent("Assets", isDirectory: true)
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: assetsURL.path).count, 1)
    }

    // 3:LOC-007, 3:LOC-015...3:LOC-017, 3:SEC-007
    func testContentAddressedStoreRejectsSameSizeCorruptionDuringVerificationAndDeduplication() async throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = ContentAddressedAssetStore(directoryURL: directory)
        let data = Data((0..<131_089).map {
            UInt8(truncatingIfNeeded: ($0 &* 17) &+ 9)
        })
        let first = try await store.storeDetailed(
            data: data,
            detectedContentType: "image/jpeg"
        )
        let storedURL = await store.url(for: first.entry.contentHash)
        let file = try XCTUnwrap(storedURL)
        var corrupted = data
        corrupted.replaceSubrange(0..<1, with: [data[0] ^ 0xff])
        XCTAssertEqual(corrupted.count, data.count)
        try corrupted.write(to: file, options: .atomic)

        await XCTAssertThrowsDomainError({
            try await store.verifyPhysicalBlob(
                contentHash: first.entry.contentHash,
                expectedByteCount: first.entry.byteCount,
                chunkSize: 4_093
            )
        }, matching: { $0 == .invalidBlobIndex(first.entry.contentHash) })

        await XCTAssertThrowsDomainError({
            try await store.storeDetailed(
                data: data,
                detectedContentType: "image/jpeg"
            )
        }, matching: { $0 == .invalidBlobIndex(first.entry.contentHash) })
        let staging = directory.appendingPathComponent("Staging", isDirectory: true)
        XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: staging.path).isEmpty)
    }

    // 3:LOC-014, 3:LOC-017
    func testCrashAfterBlobMoveLeavesVerifiedImmutableBlobRecoverable() async throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let data = TestFixtures.data("recoverable")
        let hash = SHA256.hexDigest(data)
        let failing = ContentAddressedAssetStore(
            directoryURL: directory,
            faultInjector: FailingPersistenceInjector(checkpoint: .afterBlobMove)
        )
        do {
            _ = try await failing.store(data: data, detectedContentType: "image/png")
            XCTFail("L’interruption injectée était attendue")
        } catch {}
        let recovered = ContentAddressedAssetStore(directoryURL: directory)
        let contains = await recovered.contains(hash)
        let loaded = try await recovered.data(for: hash)
        XCTAssertTrue(contains)
        XCTAssertEqual(loaded, data)
    }

    // 3:CAT-001...3:CAT-008, 3:BG-008, 3:LOC-007...3:LOC-017
    func testCatalogBootstrapPersistsVerifiedFallbacksAndResolvesWithoutBundleLookup() async throws {
        let directory = try TestFixtures.temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let sourceRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let resources = sourceRoot.appendingPathComponent(
            "Albumzh.swiftpm/Sources/AppModule/Resources/Backgrounds.xcassets"
        )
        let definitions: [(String, String)] = [
            ("album.classicSpiral", "AlbumClassicSpiralData.dataset/album-classic-spiral-v1.png"),
            ("album.travelKraft", "AlbumTravelKraftData.dataset/album-travel-kraft-v1.png"),
            ("album.minimalDark", "AlbumMinimalDarkData.dataset/album-minimal-dark-v1.png")
        ]
        let inputs = try definitions.map { id, path in
            CatalogResourceBootstrapInput(
                catalogID: id,
                data: try Data(contentsOf: resources.appendingPathComponent(path)),
                detectedContentType: "image/png"
            )
        }
        let assetStore = ContentAddressedAssetStore(directoryURL: directory)
        let appService = AlbumApplicationService(
            repository: TransactionalJSONLibraryRepository(directoryURL: directory)
        )
        let bootstrap = CatalogResourceBootstrapService(
            assetStore: assetStore,
            applicationService: appService
        )
        let commandID = UUID()
        let first = try await bootstrap.bootstrap(inputs, commandID: commandID)
        let retry = try await bootstrap.bootstrap(inputs, commandID: commandID)
        XCTAssertEqual(first, retry)
        XCTAssertEqual(first.count, 3)
        XCTAssertTrue(first.allSatisfy { $0.referenceCount >= 1 && $0.state == .available })
        let snapshot = try await appService.snapshot()
        XCTAssertEqual(snapshot.blobIndex.count, 3)

        // Resolution uses the persisted reference/hash and content store; no
        // access to the original bundle URL is involved after bootstrap.
        let entry = try await appService.catalogBlob(
            for: BackgroundCatalog.defaultTheme.reference
        )
        let fallbackData = try await assetStore.data(for: entry.contentHash)
        XCTAssertEqual(SHA256.hexDigest(fallbackData), entry.contentHash)
    }
}
