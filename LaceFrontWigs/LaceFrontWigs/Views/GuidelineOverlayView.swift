import SwiftUI

struct GuidelineOverlayView: View {
    let state: WigGuidelineState
    let isFrozen: Bool

    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                let hairlinePoints = state.hairlineCurve.map { $0.denormalized(in: size) }
                if hairlinePoints.count >= 2 {
                    var path = Path()
                    path.addLines(hairlinePoints)
                    context.stroke(path, with: .color(.green.opacity(0.8)), lineWidth: 4)
                }

                drawGuideline(context: context, size: size, guideline: state.earToEar, color: .blue)
                drawGuideline(context: context, size: size, guideline: state.centerLine, color: .orange)

                for temple in state.temples {
                    let converted = temple.denormalized(in: size)
                    let rect = CGRect(x: converted.x - 6, y: converted.y - 6, width: 12, height: 12)
                    context.fill(Path(ellipseIn: rect), with: .color(.pink))
                }
            }
            .overlay(alignment: .topTrailing) {
                VStack(alignment: .trailing, spacing: 4) {
                    label(text: String(format: "Tilt: %.1f°", state.tiltDegrees), systemImage: "arrow.triangle.2.circlepath")
                    label(text: String(format: "Forehead offset: %.1f mm", state.foreheadOffsetMillimeters), systemImage: "ruler")
                    if isFrozen {
                        label(text: "Overlay frozen", systemImage: "pause.fill")
                    }
                }
                .padding(12)
            }
        }
        .allowsHitTesting(false)
    }

    private func drawGuideline(context: GraphicsContext, size: CGSize, guideline: WigGuidelineState.Guideline, color: Color) {
        let start = guideline.start.denormalized(in: size)
        let end = guideline.end.denormalized(in: size)
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        context.stroke(path, with: .color(color.opacity(0.9)), lineWidth: 3)
    }

    private func label(text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.caption2)
            .padding(6)
            .background(.ultraThinMaterial, in: Capsule())
    }
}

#Preview {
    GuidelineOverlayView(state: FaceTrackingViewModel.preview.guidelineState ?? .empty, isFrozen: false)
        .frame(width: 390, height: 600)
        .background(Color.black)
}
