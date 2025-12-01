import CoreGraphics
import XCTest
@testable import LaceFrontWigs

final class WigGuidelineCalculatorTests: XCTestCase {
    func testTiltCalculationReturnsZeroForHorizontalLine() {
        let calculator = WigGuidelineCalculator()
        let guideline = WigGuidelineState.Guideline(
            start: CGPoint(x: 0.1, y: 0.5),
            end: CGPoint(x: 0.9, y: 0.5)
        )

    let tilt = calculator.tiltDegrees(for: guideline)
        XCTAssertEqual(tilt, 0, accuracy: 0.01)
    }

    func testTiltCalculationDetectsPositiveAngle() {
        let calculator = WigGuidelineCalculator()
        let guideline = WigGuidelineState.Guideline(
            start: CGPoint(x: 0.1, y: 0.4),
            end: CGPoint(x: 0.9, y: 0.6)
        )

        let tilt = calculator.tiltDegrees(for: guideline)
        XCTAssertGreaterThan(tilt, 0)
    }

    func testTiltCalculationDetectsNegativeAngle() {
        let calculator = WigGuidelineCalculator()
        let guideline = WigGuidelineState.Guideline(
            start: CGPoint(x: 0.1, y: 0.7),
            end: CGPoint(x: 0.9, y: 0.3)
        )

        let tilt = calculator.tiltDegrees(for: guideline)
        XCTAssertLessThan(tilt, 0)
        XCTAssertEqual(tilt, -26.565, accuracy: 0.01)
    }

    func testTiltCalculationMatchesFortyFiveDegrees() {
        let calculator = WigGuidelineCalculator()
        let guideline = WigGuidelineState.Guideline(
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: 1, y: 1)
        )

        let tilt = calculator.tiltDegrees(for: guideline)
        XCTAssertEqual(tilt, 45, accuracy: 0.01)
    }

    func testTiltCalculationHandlesDegenerateGuideline() {
        let calculator = WigGuidelineCalculator()
        let point = CGPoint(x: 0.5, y: 0.5)
        let guideline = WigGuidelineState.Guideline(start: point, end: point)

        let tilt = calculator.tiltDegrees(for: guideline)
        XCTAssertEqual(tilt, 0, accuracy: 0.01)
    }
}
