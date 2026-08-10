import Foundation
import XCTest
@testable import AlbumPhotoCore

final class DomainValidationTests: XCTestCase {
    // 3:ALB-011...3:ALB-016
    func testInitialAlbumUsesGenerationOnePageAndClassicBackground() throws {
        let album = AlbumSnapshot(
            id: TestFixtures.albumID,
            name: "Guatemala",
            firstPageID: TestFixtures.pageID,
            createdAt: TestFixtures.date
        )
        XCTAssertEqual(album.modelGeneration, "album-photo-canvas-v1")
        XCTAssertEqual(album.schemaVersion, 1)
        XCTAssertEqual(album.pages.count, 1)
        XCTAssertEqual(album.pages[0].background, .classicSpiral)
        XCTAssertEqual(album.pages[0].layout, .initial)
    }

    // 3:ALB-011
    func testAlbumNameRejectsWhitespaceOnlyAndTrimsValidName() throws {
        XCTAssertThrowsError(try DomainValidator.trimmedAlbumName(" \n "))
        XCTAssertEqual(try DomainValidator.trimmedAlbumName("  Voyage  "), "Voyage")
    }

    // 3:DAT-033
    func testGenerationIsValidatedBeforeSchema() throws {
        let wrong = LocalLibrarySnapshot(
            modelGeneration: "prototype-2.1",
            schemaVersion: 999
        )
        XCTAssertThrowsError(try DomainValidator.validate(wrong)) { error in
            XCTAssertEqual(error as? DomainValidationError, .unsupportedGeneration("prototype-2.1"))
        }
    }

    // 3:ALB-020, 3:DAT-030
    func testDeletionTombstoneRequiresValidHashDatesReasonAndNoLiveAlbum() throws {
        let trashedAt = TestFixtures.date
        let hash = String(repeating: "a", count: 64)
        let commandID = UUID()
        let valid = AlbumDeletionTombstone(
            albumID: TestFixtures.albumID,
            trashedAt: trashedAt,
            deletedAt: trashedAt.addingTimeInterval(AlbumDeletionTombstone.recoveryDuration),
            reason: .retentionExpired,
            albumLogicalHash: hash,
            deletionCommandID: commandID
        )
        XCTAssertNoThrow(try DomainValidator.validate(valid))

        let premature = AlbumDeletionTombstone(
            albumID: TestFixtures.albumID,
            trashedAt: trashedAt,
            deletedAt: trashedAt.addingTimeInterval(
                AlbumDeletionTombstone.recoveryDuration - 1
            ),
            reason: .retentionExpired,
            albumLogicalHash: hash,
            deletionCommandID: commandID
        )
        XCTAssertThrowsError(try DomainValidator.validate(premature))

        let invalidHash = AlbumDeletionTombstone(
            albumID: TestFixtures.albumID,
            trashedAt: trashedAt,
            deletedAt: trashedAt,
            reason: .userConfirmed,
            albumLogicalHash: "ABC",
            deletionCommandID: commandID
        )
        XCTAssertThrowsError(try DomainValidator.validate(invalidHash))

        let liveAlbum = AlbumSnapshot(
            id: TestFixtures.albumID,
            name: "Encore présent",
            firstPageID: TestFixtures.pageID
        )
        XCTAssertThrowsError(try DomainValidator.validate(LocalLibrarySnapshot(
            albums: [liveAlbum],
            blobIndex: TestFixtures.catalogBlobEntries,
            albumDeletionTombstones: [valid]
        ))) { error in
            XCTAssertEqual(
                error as? DomainValidationError,
                .invalidAlbumDeletionTombstone(TestFixtures.albumID)
            )
        }
    }

    // 3:DAT-030, 3:DAT-012
    func testPageRejectsDuplicateElementAndIncompleteAccessibilityOrder() throws {
        let frame = PhotoFrameElement(id: TestFixtures.elementID)
        var page = PageSnapshot(
            id: TestFixtures.pageID,
            elements: [.photo(frame), .photo(frame)],
            accessibilityOrder: [frame.id]
        )
        XCTAssertThrowsError(try DomainValidator.validate(page, validAssetIDs: []))
        page.elements = [.photo(frame)]
        page.accessibilityOrder = []
        XCTAssertThrowsError(try DomainValidator.validate(page, validAssetIDs: []))
    }

    // 3:CAN-005, 3:CAN-006, 3:DAT-011
    func testGeometryRequiresSelectableCenterMinimumSizeAndNormalizedRotation() throws {
        XCTAssertNoThrow(try DomainValidator.validate(ElementGeometry()))
        XCTAssertThrowsError(try DomainValidator.validate(ElementGeometry(centerX: -0.1)))
        XCTAssertThrowsError(try DomainValidator.validate(ElementGeometry(width: 0.049)))
        XCTAssertEqual(try DomainValidator.normalizedRotation(3 * .pi), -.pi, accuracy: 0.000_001)
    }

    // 3:DAT-006...3:DAT-009
    func testPhotoPlacementRejectsNonFiniteOutOfRangeAndTooLongDescription() throws {
        XCTAssertNoThrow(try DomainValidator.validate(PhotoPlacement(assetID: TestFixtures.assetID)))
        XCTAssertThrowsError(try DomainValidator.validate(PhotoPlacement(
            assetID: TestFixtures.assetID,
            nativeScale: 0
        )))
        XCTAssertThrowsError(try DomainValidator.validate(PhotoPlacement(
            assetID: TestFixtures.assetID,
            nativeScale: .infinity
        )))
        XCTAssertThrowsError(try DomainValidator.validate(PhotoPlacement(
            assetID: TestFixtures.assetID,
            focalX: 1.01
        )))
        XCTAssertThrowsError(try DomainValidator.validate(PhotoPlacement(
            assetID: TestFixtures.assetID,
            accessibilityDescription: String(repeating: "a", count: 501)
        )))
    }

    // 3:DAT-043, 3:FMT-001...3:FMT-007
    func testPhotoMetadataAcceptsEveryPersistedStaticAndRAWType() throws {
        let expectedMIMETypes: Set<String> = [
            "image/jpeg", "image/png", "image/heic", "image/heif", "image/tiff",
            "image/x-raw", "image/x-adobe-dng", "image/x-canon-cr2",
            "image/x-canon-crw", "image/x-epson-erf", "image/x-fuji-raf",
            "image/x-kodak-dcr", "image/x-kodak-k25", "image/x-kodak-kdc",
            "image/x-minolta-mrw", "image/x-nikon-nef", "image/x-olympus-orf",
            "image/x-panasonic-raw", "image/x-panasonic-rw2", "image/x-pentax-pef",
            "image/x-sigma-x3f", "image/x-sony-arw", "image/x-sony-sr2",
            "image/x-sony-srf"
        ]
        XCTAssertEqual(DomainValidator.acceptedPhotoMIMETypes, expectedMIMETypes)
        for mimeType in expectedMIMETypes {
            let derivative = DomainValidator.isRAWMIMEType(mimeType)
                ? TestFixtures.displayDerivative() : nil
            XCTAssertNoThrow(
                try DomainValidator.validate(TestFixtures.metadata(
                    mimeType: mimeType,
                    displayDerivative: derivative
                )),
                "Le MIME \(mimeType) devait être accepté"
            )
        }
    }

    // 3:DAT-043, 3:FMT-004, 3:FMT-006
    func testPhotoMetadataRejectsInvalidDimensionsAnimatedMimeAndOver200Megapixels() throws {
        XCTAssertThrowsError(try DomainValidator.validate(TestFixtures.metadata(width: 0)))
        XCTAssertThrowsError(try DomainValidator.validate(TestFixtures.metadata(
            mimeType: "image/gif"
        )))
        XCTAssertThrowsError(try DomainValidator.validate(TestFixtures.metadata(
            width: 20_001,
            height: 10_000
        )))
    }

    // 3:DAT-040
    func testLayoutStateRejectsImpossibleProvenanceCombinations() throws {
        XCTAssertNoThrow(try DomainValidator.validate(PageLayoutState.initial))
        XCTAssertNoThrow(try DomainValidator.validate(PageLayoutState(
            photoMode: .template,
            templateID: "layout.one",
            templateVersion: 1
        )))
        XCTAssertThrowsError(try DomainValidator.validate(PageLayoutState(
            isAutoLayoutEnabled: true,
            photoMode: .free
        )))
        XCTAssertThrowsError(try DomainValidator.validate(PageLayoutState(
            photoMode: .template
        )))
    }

    // 3:BG-015, 3:DAT-039
    func testBackgroundCasesRemainDistinctAndSolidMustBeOpaque() throws {
        XCTAssertNotEqual(BackgroundSelection.none, .solid(.white))
        XCTAssertNoThrow(try DomainValidator.validate(BackgroundSelection.solid(.white)))
        XCTAssertThrowsError(try DomainValidator.validate(BackgroundSelection.solid(
            SRGBAColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        )))
    }

    // 3:CAT-001...3:CAT-006, 3:DAT-039, 3:DAT-041
    func testCatalogReferencesResolveExactVersionPayloadAndHash() throws {
        XCTAssertEqual(BuiltInCatalogRegistry.entries.count, 9)
        XCTAssertNoThrow(try DomainValidator.validate(BackgroundSelection.classicSpiral))
        XCTAssertNoThrow(try DomainValidator.validate(
            CatalogResourceReference(catalogID: "shape.circle", catalogVersion: 1)
        ))
        XCTAssertThrowsError(try DomainValidator.validate(
            CatalogResourceReference(catalogID: "album.unknown", catalogVersion: 1)
        ))
        XCTAssertThrowsError(try DomainValidator.validate(
            CatalogResourceReference(
                catalogID: "album.classicSpiral",
                catalogVersion: 2,
                fallbackContentHash: BackgroundCatalog.defaultTheme.fallbackContentHash
            )
        ))
        XCTAssertThrowsError(try DomainValidator.validate(
            CatalogResourceReference(
                catalogID: "album.classicSpiral",
                catalogVersion: 1,
                fallbackContentHash: String(repeating: "0", count: 64)
            )
        ))
        XCTAssertThrowsError(try DomainValidator.validate(
            CatalogResourceReference(
                catalogID: "shape.circle",
                catalogVersion: 1,
                fallbackContentHash: String(repeating: "0", count: 64)
            )
        ))
    }

    // 3:CAT-005, 3:CAT-006, 3:CAT-008, 3:BG-008
    func testSnapshotRejectsReferencedFallbackWithoutVerifiedBlobIndexEntry() throws {
        let album = AlbumSnapshot(
            id: TestFixtures.albumID,
            name: "Guatemala",
            firstPageID: TestFixtures.pageID
        )
        XCTAssertThrowsError(try DomainValidator.validate(LocalLibrarySnapshot(
            albums: [album]
        )))
        XCTAssertNoThrow(try DomainValidator.validate(LocalLibrarySnapshot(
            albums: [album],
            blobIndex: TestFixtures.catalogBlobEntries
        )))
    }

    // 3:TBX-006
    func testTextUsesSwiftCharacterLimit() throws {
        let familyEmoji = "👨‍👩‍👧‍👦"
        let accepted = String(repeating: familyEmoji, count: 1_000)
        let rejected = accepted + "x"
        let style = TextStyleDefaults()
        XCTAssertNoThrow(try DomainValidator.validate(TextBoxElement(
            content: TextBoxContent(paragraphs: [
                TextParagraph(runs: [TextRun(text: accepted, style: style)])
            ])
        )))
        XCTAssertThrowsError(try DomainValidator.validate(TextBoxElement(
            content: TextBoxContent(paragraphs: [
                TextParagraph(runs: [TextRun(text: rejected, style: style)])
            ])
        )))
    }
}
