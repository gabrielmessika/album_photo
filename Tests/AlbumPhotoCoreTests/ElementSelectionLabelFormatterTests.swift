import XCTest
@testable import AlbumPhotoCore

final class ElementSelectionLabelFormatterTests: XCTestCase {
    // 3:ELM-014, 3:ACC-002
    func testCompactLabelTruncatesOnlyDetailAndKeepsPositionAndDepth() {
        let label = ElementSelectionLabelFormatter.compact(
            type: "Photo",
            detail: "abcdefghijklmno.jpg",
            position: "milieu centre",
            depth: "plan 20 sur 20"
        )

        XCTAssertEqual(label, "Photo — abc… — milieu centre — plan 20 sur 20")
        XCTAssertEqual(label.count, 45)
        XCTAssertTrue(label.hasSuffix("milieu centre — plan 20 sur 20"))
        XCTAssertFalse(label.contains("abcdefgh"))
    }

    // 3:ELM-014, 3:ACC-002
    func testAccessibleLabelKeepsFullDetail() {
        let label = ElementSelectionLabelFormatter.accessible(
            type: "Photo",
            detail: "photo-de-vacances-avec-un-nom-tres-long.jpg",
            position: "haut gauche",
            depth: "plan 2 sur 4"
        )

        XCTAssertEqual(
            label,
            "Photo — photo-de-vacances-avec-un-nom-tres-long.jpg — haut gauche — plan 2 sur 4"
        )
    }
}
