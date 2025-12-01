import CoreGraphics
import Foundation

struct WigGuidelineState: Equatable {
    struct Guideline: Equatable {
        var start: CGPoint
        var end: CGPoint
    }

    var hairlineCurve: [CGPoint]
    var earToEar: Guideline
    var centerLine: Guideline
    var temples: [CGPoint]
    var tiltDegrees: Double
    var foreheadOffsetMillimeters: Double
    var advice: String

    static let empty = WigGuidelineState(
        hairlineCurve: [],
        earToEar: .init(start: .zero, end: .zero),
        centerLine: .init(start: .zero, end: .zero),
        temples: [],
        tiltDegrees: 0,
        foreheadOffsetMillimeters: 0,
        advice: "Hold steady while we find your fit"
    )
}
