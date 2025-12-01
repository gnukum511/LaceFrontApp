import CoreGraphics
import Vision

struct WigGuidelineCalculator {
    private let foreheadOffsetRatio: CGFloat = 0.018
    private let millimetersPerPoint: CGFloat = 0.35

    func guidelines(for observation: VNFaceObservation) -> WigGuidelineState {
        guard let landmarks = observation.landmarks else { return WigGuidelineState.empty }

        let boundingBox = observation.boundingBox

        let browMidPoint = midpoint(of: landmarks.leftEyebrow, and: landmarks.rightEyebrow)
        let leftTemple = point(from: landmarks.leftEye?.pointsInImage(imageSize: CGSize(width: 1, height: 1)).first)
        let rightTemple = point(from: landmarks.rightEye?.pointsInImage(imageSize: CGSize(width: 1, height: 1)).last)

        let hairlineY = max((browMidPoint?.y ?? 0.75) - foreheadOffsetRatio, 0.02)
        let hairlineCurve = stride(from: 0.0, through: 1.0, by: 0.1).map { fraction -> CGPoint in
            let localX = CGFloat(fraction)
            let x = boundingBox.minX + boundingBox.width * localX
            let y = boundingBox.minY + boundingBox.height * hairlineY
            return CGPoint(x: x, y: y)
        }

        let earToEar = WigGuidelineState.Guideline(
            start: CGPoint(x: boundingBox.minX, y: boundingBox.midY),
            end: CGPoint(x: boundingBox.maxX, y: boundingBox.midY)
        )

        let centerLine = WigGuidelineState.Guideline(
            start: CGPoint(x: boundingBox.midX, y: boundingBox.maxY),
            end: CGPoint(x: boundingBox.midX, y: boundingBox.minY)
        )

    let tilt = tiltDegrees(for: earToEar)
        let foreheadOffsetMm = abs((browMidPoint?.y ?? 0.5) - hairlineY) * 1000 * millimetersPerPoint

        let advice: String
        if abs(tilt) > 2.5 {
            advice = "Rotate the wig \(tilt > 0 ? "clockwise" : "counter-clockwise") by \(String(format: "%.1f", abs(tilt)))°"
        } else if foreheadOffsetMm < 2 {
            advice = "Slide the lace slightly forward to avoid tension"
        } else {
            advice = "Great position! Tap snapshot to save this alignment"
        }

        return WigGuidelineState(
            hairlineCurve: hairlineCurve,
            earToEar: earToEar,
            centerLine: centerLine,
            temples: [leftTemple, rightTemple].compactMap { $0 },
            tiltDegrees: tilt,
            foreheadOffsetMillimeters: foreheadOffsetMm,
            advice: advice
        )
    }

    private func point(from maybePoint: CGPoint?) -> CGPoint? {
        guard let point = maybePoint else { return nil }
        return CGPoint(x: point.x, y: 1 - point.y)
    }

    private func midpoint(of first: VNFaceLandmarkRegion2D?, and second: VNFaceLandmarkRegion2D?) -> CGPoint? {
        guard
            let firstPoints = first?.normalizedPoints,
            let secondPoints = second?.normalizedPoints,
            !firstPoints.isEmpty,
            !secondPoints.isEmpty
        else { return nil }

        let firstAvg = average(of: firstPoints)
        let secondAvg = average(of: secondPoints)
        return CGPoint(x: (firstAvg.x + secondAvg.x) / 2, y: 1 - ((firstAvg.y + secondAvg.y) / 2))
    }

    private func average(of points: [CGPoint]) -> CGPoint {
        let sum = points.reduce(.zero) { partialResult, point in
            CGPoint(x: partialResult.x + point.x, y: partialResult.y + point.y)
        }
        return CGPoint(x: sum.x / CGFloat(points.count), y: sum.y / CGFloat(points.count))
    }

    func tiltDegrees(for guideline: WigGuidelineState.Guideline) -> Double {
        let deltaY = Double(guideline.end.y - guideline.start.y)
        let deltaX = Double(guideline.end.x - guideline.start.x)
        return atan2(deltaY, deltaX) * 180 / .pi
    }
}
