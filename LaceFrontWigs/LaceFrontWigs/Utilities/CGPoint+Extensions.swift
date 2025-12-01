import CoreGraphics

extension CGPoint {
    func denormalized(in size: CGSize) -> CGPoint {
        CGPoint(x: x * size.width, y: y * size.height)
    }
}
