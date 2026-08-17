import Foundation
import XCTest
@testable import AlbumPhotoCore

final class GeometryEngineTests: XCTestCase {
    // 3:CRP-001, 3:TST-006 fixture 600×400 in 1200×900.
    func testSmallPhotoAtOneXIsCenteredWithExpectedTransparentMargins() throws {
        let metadata = TestFixtures.metadata(width: 600, height: 400)
        let frame = ElementGeometry(width: 0.5, height: 0.3)
        let render = try PhotoCropGeometry.renderGeometry(
            placement: PhotoPlacement(assetID: metadata.id),
            metadata: metadata,
            frameGeometry: frame
        )
        XCTAssertEqual(render.frameSize, GeometrySize(width: 1_200, height: 900))
        XCTAssertEqual(render.photoRectInFrame.minX, 300, accuracy: 0.000_001)
        XCTAssertEqual(render.photoRectInFrame.minY, 250, accuracy: 0.000_001)
        XCTAssertEqual(render.photoRectInFrame.maxX, 900, accuracy: 0.000_001)
        XCTAssertEqual(render.photoRectInFrame.maxY, 650, accuracy: 0.000_001)
    }

    // 3:FRM-004, 3:FRM-009 — the default placement covers the frame while
    // preserving the photo ratio, whether that requires zooming in or out.
    func testInitialPlacementCoversFrameForSmallAndLargePhotos() throws {
        let frame = ElementGeometry(width: 0.5, height: 0.3)
        let small = TestFixtures.metadata(width: 600, height: 400)
        let smallPlacement = try PhotoCropGeometry.initialPlacement(
            assetID: small.id,
            metadata: small,
            frameGeometry: frame
        )
        XCTAssertEqual(smallPlacement.nativeScale, 2.25, accuracy: 0.000_001)
        try assertCoversFrame(smallPlacement, metadata: small, frame: frame)

        let large = TestFixtures.metadata(width: 4_800, height: 6_000)
        let largePlacement = try PhotoCropGeometry.initialPlacement(
            assetID: large.id,
            metadata: large,
            frameGeometry: frame
        )
        XCTAssertEqual(largePlacement.nativeScale, 0.25, accuracy: 0.000_001)
        try assertCoversFrame(largePlacement, metadata: large, frame: frame)
    }

    // 3:CRP-001, 3:CRP-004, 3:TST-006, 3:TST-011 — normative
    // 2400×1800 fixture at 0.5× exactly fills a 1200×900 frame.
    func testMediumPhotoAtPointFiveExactlyFillsNormativeFrame() throws {
        let metadata = TestFixtures.metadata(width: 2_400, height: 1_800)
        let frame = ElementGeometry(width: 0.5, height: 0.3)
        let minimum = try PhotoCropGeometry.minimumNativeScale(
            metadata: metadata,
            frameGeometry: frame,
            quarterTurns: 0
        )
        XCTAssertEqual(minimum, 0.5, accuracy: 0.000_001)

        let render = try PhotoCropGeometry.renderGeometry(
            placement: PhotoPlacement(
                assetID: metadata.id,
                nativeScale: 0.5
            ),
            metadata: metadata,
            frameGeometry: frame
        )
        XCTAssertEqual(render.frameSize, GeometrySize(width: 1_200, height: 900))
        XCTAssertEqual(render.photoRectInFrame.minX, 0, accuracy: 0.000_001)
        XCTAssertEqual(render.photoRectInFrame.minY, 0, accuracy: 0.000_001)
        XCTAssertEqual(render.photoRectInFrame.maxX, 1_200, accuracy: 0.000_001)
        XCTAssertEqual(render.photoRectInFrame.maxY, 900, accuracy: 0.000_001)
    }

    // 3:CRP-004 dynamic bound.
    func testLargeFullPagePhotoHasDynamicMinimumPointFive() throws {
        let metadata = TestFixtures.metadata(width: 4_800, height: 6_000)
        let scale = try PhotoCropGeometry.minimumNativeScale(
            metadata: metadata,
            frameGeometry: ElementGeometry(width: 1, height: 1),
            quarterTurns: 0
        )
        XCTAssertEqual(scale, 0.5, accuracy: 0.000_001)
    }

    // 3:CRP-004 — a small photo cannot be reduced below 1×.
    func testSmallPhotoMinimumIsOne() throws {
        let metadata = TestFixtures.metadata(width: 600, height: 400)
        XCTAssertEqual(try PhotoCropGeometry.minimumNativeScale(
            metadata: metadata,
            frameGeometry: ElementGeometry(width: 0.5, height: 0.3),
            quarterTurns: 0
        ), 1)
    }

    // 3:CRP-007 — opening a changed frame never raises an existing scale.
    func testSessionMinimumPreservesExistingSmallerScale() throws {
        let metadata = TestFixtures.metadata(width: 600, height: 400)
        XCTAssertEqual(try PhotoCropGeometry.sessionMinimumNativeScale(
            entryNativeScale: 0.4,
            metadata: metadata,
            frameGeometry: ElementGeometry(width: 1, height: 1),
            quarterTurns: 0
        ), 0.4)
    }

    // 3:DAT-008
    func testQuarterTurnSwapsDimensionsAndTransformsFocalPointBeforeFlip() throws {
        let metadata = TestFixtures.metadata(width: 2_400, height: 1_800)
        XCTAssertEqual(try PhotoCropGeometry.orientedPixelSize(
            metadata: metadata,
            quarterTurns: 1
        ), GeometrySize(width: 1_800, height: 2_400))
        XCTAssertEqual(try PhotoCropGeometry.transformedFocalPoint(
            x: 0.2,
            y: 0.3,
            quarterTurns: 1,
            flippedHorizontally: false
        ), GeometryPoint(x: 0.7, y: 0.2))
        let flipped = try PhotoCropGeometry.transformedFocalPoint(
            x: 0.2,
            y: 0.3,
            quarterTurns: 1,
            flippedHorizontally: true
        )
        XCTAssertEqual(flipped.x, 0.3, accuracy: 1e-12)
        XCTAssertEqual(flipped.y, 0.2, accuracy: 1e-12)
    }

    // 3:CRP-004
    func testScaleClampIncludesDynamicMinimumAndMaximum() throws {
        XCTAssertEqual(try PhotoCropGeometry.clampScale(0.1, sessionMinimum: 0.5), 0.5)
        XCTAssertEqual(try PhotoCropGeometry.clampScale(9, sessionMinimum: 0.5), 8)
        XCTAssertEqual(try PhotoCropGeometry.clampScale(2, sessionMinimum: 0.5), 2)
    }

    // 3:PHO-006
    func testInitialFramePreservesPhotoRatioInsidePoint45Box() throws {
        let metadata = TestFixtures.metadata(width: 2_400, height: 1_200)
        let geometry = try PhotoCropGeometry.initialFrameGeometry(metadata: metadata)
        let canonicalRatio = (geometry.width * 2_400) / (geometry.height * 3_000)
        XCTAssertEqual(canonicalRatio, 2, accuracy: 0.000_001)
        XCTAssertLessThanOrEqual(geometry.width, 0.45)
        XCTAssertLessThanOrEqual(geometry.height, 0.45)
    }

    private func assertCoversFrame(
        _ placement: PhotoPlacement,
        metadata: PhotoAssetMetadata,
        frame: ElementGeometry,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let render = try PhotoCropGeometry.renderGeometry(
            placement: placement,
            metadata: metadata,
            frameGeometry: frame
        )
        XCTAssertLessThanOrEqual(render.photoRectInFrame.minX, 0.000_001, file: file, line: line)
        XCTAssertLessThanOrEqual(render.photoRectInFrame.minY, 0.000_001, file: file, line: line)
        XCTAssertGreaterThanOrEqual(
            render.photoRectInFrame.maxX,
            render.frameSize.width - 0.000_001,
            file: file,
            line: line
        )
        XCTAssertGreaterThanOrEqual(
            render.photoRectInFrame.maxY,
            render.frameSize.height - 0.000_001,
            file: file,
            line: line
        )
    }

    // 3:ELM-001, 3:ELM-014
    func testHitTestingReturnsTopmostAndListsAllOverlapsWithoutReordering() {
        let back = PhotoFrameElement(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
            geometry: ElementGeometry(order: 1_024)
        )
        let front = TextBoxElement(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
            geometry: ElementGeometry(order: 2_048)
        )
        let page = PageSnapshot(
            elements: [.photo(back), .text(front)],
            accessibilityOrder: [back.id, front.id]
        )
        let point = GeometryPoint(x: 0.5, y: 0.5)
        XCTAssertEqual(CanvasHitTesting.topmostElement(at: point, in: page)?.id, front.id)
        XCTAssertEqual(CanvasHitTesting.overlappingElements(at: point, in: page).map(\.id), [front.id, back.id])
        XCTAssertEqual(page.elements.map(\.id), [back.id, front.id])
    }

    // 3:CAN-001, 3:ELM-001
    func testRotatedHitTestingAccountsForPageAspectRatio() {
        let geometry = ElementGeometry(
            centerX: 0.5,
            centerY: 0.5,
            width: 0.4,
            height: 0.1,
            rotationRadians: .pi / 2
        )
        XCTAssertTrue(CanvasHitTesting.contains(
            normalizedPoint: GeometryPoint(x: 0.555, y: 0.5),
            geometry: geometry
        ))
        XCTAssertFalse(CanvasHitTesting.contains(
            normalizedPoint: GeometryPoint(x: 0.57, y: 0.5),
            geometry: geometry
        ))
    }

    // 3:ZOM-005 — an unselected element belongs to the viewport gesture zone.
    func testCanvasGestureArbitrationOnlyProtectsTheSelectedElement() {
        let selectedID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!
        let otherID = UUID(uuidString: "00000000-0000-0000-0000-000000000011")!

        XCTAssertTrue(CanvasGestureArbitration.shouldTransformViewport(
            hitElementID: nil,
            selectedElementID: selectedID
        ))
        XCTAssertTrue(CanvasGestureArbitration.shouldTransformViewport(
            hitElementID: otherID,
            selectedElementID: selectedID
        ))
        XCTAssertTrue(CanvasGestureArbitration.shouldTransformViewport(
            hitElementID: otherID,
            selectedElementID: nil
        ))
        XCTAssertFalse(CanvasGestureArbitration.shouldTransformViewport(
            hitElementID: selectedID,
            selectedElementID: selectedID
        ))
    }

    // 3:ELM-005, 3:ELM-006
    func testSnapThresholdUsesSixScreenPointsAndSignalsGuideOncePerResult() {
        let moving = ElementGeometry(centerX: 0.506, width: 0.2)
        let result = CanvasSnapEngine.snap(
            moving: moving,
            otherElements: [],
            pageSizePoints: GeometrySize(width: 1_000, height: 1_000)
        )
        XCTAssertTrue(result.didSnap)
        XCTAssertEqual(result.geometry.centerX, 0.5, accuracy: 0.000_001)
        XCTAssertEqual(result.guides.filter { $0.axis == .vertical }.count, 1)
    }

    // 3:ZOM-001...3:ZOM-003
    func testCanvasZoomStepsAndContinuousClampStayDistinctFromPhotoScale() {
        XCTAssertEqual(CanvasZoomEngine.nextStep(after: 1.1), 1.25)
        XCTAssertEqual(CanvasZoomEngine.previousStep(before: 1.1), 1)
        XCTAssertEqual(CanvasZoomEngine.pinched(.fitted, magnification: 10).zoom, 4)
        XCTAssertEqual(CanvasZoomEngine.pinched(.fitted, magnification: 0.1).zoom, 0.5)
    }

    // 3:ZOM-003
    func testCanvasPinchKeepsNormalizedAnchorStationaryAndClampsCenter() {
        let zoomed = CanvasZoomEngine.pinched(
            .fitted,
            magnification: 2,
            anchorNormalized: GeometryPoint(x: 0.8, y: 0.2)
        )
        XCTAssertEqual(zoomed.zoom, 2)
        XCTAssertEqual(zoomed.centerX, 0.65, accuracy: 1e-12)
        XCTAssertEqual(zoomed.centerY, 0.35, accuracy: 1e-12)

        let clamped = CanvasZoomEngine.pinched(
            CanvasViewportState(zoom: 4, centerX: 0.875, centerY: 0.125),
            magnification: 0.01,
            anchorNormalized: GeometryPoint(x: 1, y: 0)
        )
        XCTAssertEqual(clamped.zoom, 0.5)
        XCTAssertEqual(clamped.centerX, 0)
        XCTAssertEqual(clamped.centerY, 1)
        XCTAssertEqual(
            CanvasZoomEngine.pinched(.fitted, magnification: .nan),
            .fitted
        )
    }

    // 3:ZOM-004, 3:ZOM-006
    func testCanvasPanRecentersFittingAxisAndClampsOversizedPage() {
        let fitted = CanvasZoomEngine.panned(
            .fitted,
            translationPoints: GeometryPoint(x: 200, y: -200),
            fittedPageSizePoints: GeometrySize(width: 400, height: 500),
            viewportSizePoints: GeometrySize(width: 500, height: 600)
        )
        XCTAssertEqual(fitted.centerX, 0.5)
        XCTAssertEqual(fitted.centerY, 0.5)

        let zoomed = CanvasZoomEngine.panned(
            CanvasViewportState(zoom: 2),
            translationPoints: GeometryPoint(x: 1_000, y: -1_000),
            fittedPageSizePoints: GeometrySize(width: 400, height: 500),
            viewportSizePoints: GeometrySize(width: 500, height: 600)
        )
        XCTAssertEqual(zoomed.centerX, 0.3125, accuracy: 1e-12)
        XCTAssertEqual(zoomed.centerY, 0.7, accuracy: 1e-12)
    }

    // 3:ZOM-003...3:ZOM-005
    func testCanvasTwoFingerTransformComposesScaleAndTranslation() {
        let transformed = CanvasZoomEngine.transformed(
            .fitted,
            magnification: 2,
            translationPoints: GeometryPoint(x: 80, y: -50),
            anchorNormalized: GeometryPoint(x: 0.5, y: 0.5),
            fittedPageSizePoints: GeometrySize(width: 400, height: 500),
            viewportSizePoints: GeometrySize(width: 400, height: 500)
        )
        XCTAssertEqual(transformed.zoom, 2, accuracy: 1e-12)
        XCTAssertEqual(transformed.centerX, 0.4, accuracy: 1e-12)
        XCTAssertEqual(transformed.centerY, 0.55, accuracy: 1e-12)
    }

    // 3:QLT-001, 3:QLT-002
    func testQualityThresholdsAreExact() throws {
        XCTAssertEqual(try PhotoQualityEngine.state(for: 300), .ok)
        XCTAssertEqual(try PhotoQualityEngine.state(for: 150), .acceptable)
        XCTAssertEqual(try PhotoQualityEngine.state(for: 149.999), .insufficient)
        XCTAssertEqual(try PhotoQualityEngine.pixelsPerInch(
            nativeScale: 1,
            canvasWidthInches: 8,
            canvasHeightInches: 10
        ), 300, accuracy: 0.000_001)
    }
}
