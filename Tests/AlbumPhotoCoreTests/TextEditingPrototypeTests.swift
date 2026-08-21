import Foundation
import XCTest
@testable import AlbumPhotoCore

final class TextEditingPrototypeTests: XCTestCase {
    private func content(_ text: String, style: TextStyleDefaults = TextStyleDefaults()) -> TextBoxContent {
        TextBoxContent(paragraphs: [
            TextParagraph(
                alignment: style.alignment,
                lineSpacing: style.lineSpacing,
                runs: [TextRun(text: text, style: style)]
            )
        ])
    }

    // Lot 0, 3:TXA-005, 3:TBX-010, 3:TBX-023
    func testPartialCharacterSelectionSplitsRunsWithoutBreakingEmojiGrapheme() throws {
        let source = content("A👨‍👩‍👧‍👦B")
        let changed = try TextEditingPrototype.applying(
            TextCharacterStylePatch(weight: .bold, isItalic: true),
            to: source,
            selection: TextSelectionRange(lowerBound: 1, upperBound: 2)
        )
        XCTAssertEqual(changed.plainText, source.plainText)
        XCTAssertEqual(changed.paragraphs[0].runs.map(\.text), ["A", "👨‍👩‍👧‍👦", "B"])
        XCTAssertEqual(changed.paragraphs[0].runs[1].weight, .bold)
        XCTAssertTrue(changed.paragraphs[0].runs[1].isItalic)
        XCTAssertEqual(changed.paragraphs[0].runs[0].weight, .regular)
    }

    // Lot 0, 3:TXA-005, 3:TBX-010, 3:DAT-038
    func testCollapsedSelectionChangesTypingDefaultsOnly() throws {
        let original = TextStyleDefaults()
        let changed = try TextEditingPrototype.typingDefaults(
            applying: TextCharacterStylePatch(
                fontID: "system-serif",
                relativeFontSize: 24 / AlbumPhotoConstants.canonicalPageHeight,
                color: SRGBAColor(red: 0.2, green: 0.3, blue: 0.4)
            ),
            to: original
        )
        XCTAssertEqual(changed.fontID, "system-serif")
        XCTAssertEqual(changed.relativeFontSize, 24 / AlbumPhotoConstants.canonicalPageHeight)
        XCTAssertNotEqual(changed, original)
    }

    // Lot 0, 3:TXA-005, 3:TBX-011
    func testParagraphStyleAppliesOnlyToTouchedParagraphs() throws {
        let style = TextStyleDefaults()
        let source = TextBoxContent(paragraphs: [
            TextParagraph(runs: [TextRun(text: "Premier", style: style)]),
            TextParagraph(runs: [TextRun(text: "Second", style: style)])
        ])
        let changed = try TextEditingPrototype.applying(
            TextParagraphStylePatch(alignment: .trailing, lineSpacing: 1.5),
            to: source,
            selection: TextSelectionRange(lowerBound: 8, upperBound: 14)
        )
        XCTAssertEqual(changed.paragraphs[0].alignment, .center)
        XCTAssertEqual(changed.paragraphs[1].alignment, .trailing)
        XCTAssertEqual(changed.paragraphs[1].lineSpacing, 1.5)
    }

    // Lot 0, 3:TXA-005, 3:TBX-006, 3:TBX-007
    func testFilteredPasteKeepsURLAndSupportedStyleButDropsAttachmentAndMetadata() throws {
        let pasted = try TextEditingPrototype.filteredPaste(
            TextPastePrototypePayload(
                text: "https://example.test\u{fffc}\u{0007}\nFin",
                supportedStyle: TextCharacterStylePatch(weight: .bold, isItalic: true),
                discardedAttributeNames: ["link", "list", "table", "highlight"],
                containsAttachment: true
            ),
            typingDefaults: TextStyleDefaults()
        )
        XCTAssertEqual(pasted.plainText, "https://example.test\nFin")
        XCTAssertEqual(pasted.paragraphs.count, 2)
        XCTAssertTrue(pasted.paragraphs.allSatisfy { $0.runs[0].weight == .bold })
        XCTAssertTrue(pasted.paragraphs.allSatisfy { $0.runs[0].isItalic })
        XCTAssertEqual(
            TextEditingPrototype.sanitizedPlainText("A\u{fffc}\u{0007}\tB\nC"),
            "A\tB\nC"
        )
        XCTAssertThrowsError(try DomainValidator.validate(TextBoxElement(
            content: content("Pièce\u{fffc}jointe")
        )))
    }

    // Lot 0, 3:TXA-005, 3:TBX-018...3:TBX-021
    func testManualResizePreservesFontAndDetectsOverflow() throws {
        let style = TextStyleDefaults(
            relativeFontSize: 96 / AlbumPhotoConstants.canonicalPageHeight
        )
        let original = TextBoxElement(content: content(
            String(repeating: "Texte ", count: 50),
            style: style
        ))
        let resized = try TextEditingPrototype.resized(
            original,
            to: ElementGeometry(width: 0.05, height: 0.05)
        )
        XCTAssertFalse(resized.usesAutomaticHeight)
        XCTAssertEqual(
            resized.content.paragraphs[0].runs[0].relativeFontSize,
            original.content.paragraphs[0].runs[0].relativeFontSize
        )
        XCTAssertTrue(TextPrototypeEngine.overflows(
            content: resized.content,
            geometry: resized.geometry
        ))
    }

    // Lot 0, 3:TXA-005, 3:TBX-022, 3:UND-001...3:UND-004
    func testTextSessionUndoRedoAndSerializationRoundTrip() throws {
        let original = TextBoxElement(content: content("Avant"))
        var session = TextEditingPrototypeSession(element: original)
        var changed = original
        changed.content = content("Après")
        try session.commit(changed)
        XCTAssertEqual(try session.undo().content.plainText, "Avant")
        XCTAssertEqual(try session.redo().content.plainText, "Après")
        let encoded = try CanonicalJSON.encode(session)
        let decoded = try JSONDecoder.albumPhotoDecoder.decode(
            TextEditingPrototypeSession.self,
            from: encoded
        )
        XCTAssertEqual(decoded, session)
    }

    // 3:TBX-006
    func testAppendingCountsSwiftCharactersAndStopsAtThousand() {
        let emoji = "👨‍👩‍👧‍👦"
        let result = TextPrototypeEngine.appending(
            "xyz",
            to: String(repeating: emoji, count: 999)
        )
        XCTAssertEqual(result.count, 1_000)
        XCTAssertTrue(result.hasSuffix("x"))
    }

    // 3:TBX-013, 3:TBX-025
    func testBuiltInFontManifestUsesUniqueOfflineSystemDesigns() {
        let fonts = BuiltInTextFontCatalog.manifest
        XCTAssertEqual(Set(fonts.map(\.id)).count, fonts.count)
        XCTAssertEqual(
            Set(fonts.map(\.design)),
            Set<TextFontDesignValue>([.standard, .serif, .rounded, .monospaced])
        )
        XCTAssertEqual(BuiltInTextFontCatalog.definition(id: "system")?.design, .standard)
        XCTAssertNil(BuiltInTextFontCatalog.definition(id: "downloaded-font"))
    }

    // 3:BG-011, 3:BG-016, 3:TBX-025
    func testInitialTextColorUsesBackgroundContrastWithoutChangingContent() {
        XCTAssertEqual(TextInitialStyleEngine.color(for: .none), .black)
        XCTAssertEqual(
            TextInitialStyleEngine.color(for: .solid(SRGBAColor(
                red: 0.95,
                green: 0.95,
                blue: 0.95
            ))),
            .black
        )
        XCTAssertEqual(
            TextInitialStyleEngine.color(for: .solid(SRGBAColor(
                red: 0.05,
                green: 0.05,
                blue: 0.05
            ))),
            .white
        )
        XCTAssertEqual(
            TextInitialStyleEngine.color(for: .catalog(
                BackgroundCatalog.themes.first {
                    $0.textContrastHint == .lightText
                }!.reference
            )),
            .white
        )
    }

    // 3:TBX-018...3:TBX-020
    func testAutomaticHeightUsesLargestRunAndParagraphLineSpacing() {
        let large = TextStyleDefaults(
            relativeFontSize: 96 / AlbumPhotoConstants.canonicalPageHeight,
            lineSpacing: 2
        )
        let content = TextBoxContent(paragraphs: [
            TextParagraph(
                alignment: .leading,
                lineSpacing: 2,
                runs: [TextRun(text: String(repeating: "M", count: 20), style: large)]
            )
        ])
        let original = ElementGeometry(width: 0.60, height: 0.12)
        let fitted = TextPrototypeEngine.automaticallyFittedGeometry(
            for: content,
            from: original
        )
        XCTAssertGreaterThan(fitted.height, original.height)
        XCTAssertFalse(TextPrototypeEngine.overflows(content: content, geometry: fitted))
        XCTAssertTrue(TextPrototypeEngine.overflows(
            content: content,
            geometry: ElementGeometry(width: 0.60, height: 0.12)
        ))

        let small = TextStyleDefaults(
            relativeFontSize: 8 / AlbumPhotoConstants.canonicalPageHeight
        )
        XCTAssertEqual(
            TextPrototypeEngine.requiredHeight(
                for: self.content("jpgqy", style: small),
                width: 0.60
            ),
            8 * TextPrototypeEngine.glyphLineHeightFactor
                * AlbumPhotoConstants.canonicalUnitsPerTypographicPoint
                / AlbumPhotoConstants.canonicalPageHeight,
            accuracy: 0.000_001
        )
    }

    // 3:TBX-003, 3:TBX-014, 3:TBX-025
    func testTypographicPointsRemainReadableAtRenderedPageScale() {
        let renderedPageHeight = 600.0
        XCTAssertEqual(
            TextStyleDefaults().relativeFontSize,
            18 / AlbumPhotoConstants.canonicalPageHeight,
            accuracy: 0.000_001
        )
        XCTAssertEqual(
            TextPrototypeEngine.renderedFontSize(
                relativeFontSize: TextStyleDefaults().relativeFontSize,
                pageHeight: renderedPageHeight
            ),
            15,
            accuracy: 0.000_001
        )
        XCTAssertEqual(
            TextPrototypeEngine.renderedFontSize(
                relativeFontSize: 96 / AlbumPhotoConstants.canonicalPageHeight,
                pageHeight: renderedPageHeight
            ),
            80,
            accuracy: 0.000_001
        )
    }
}
