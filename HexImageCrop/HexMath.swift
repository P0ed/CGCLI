import CoreGraphics

extension CGPoint {

	static var hexCorners: [CGPoint] {
		(0..<6).map(CGPoint.hexCorner)
	}

	static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}

	static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}

	static func * (lhs: CGPoint, rhs: Double) -> CGPoint {
		CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
	}

	static func / (lhs: CGPoint, rhs: Double) -> CGPoint {
		CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
	}

	static func hexCorner(_ corner: Int) -> CGPoint {
		let a = .pi * Double(corner) / 3.0
		return CGPoint(x: cos(a), y: sin(a))
	}
}

extension CGSize {

	var rect: CGRect { .init(origin: .zero, size: self) }
}

extension CGPath {

	static func make(_ transform: (CGMutablePath) -> Void) -> CGPath {
		let path = CGMutablePath()
		transform(path)
		return path
	}

	static func hex(origin: CGPoint, radius: CGFloat) -> CGPath {
		.make { path in
			path.addLines(between: CGPoint.hexCorners.map { origin + $0 * radius })
			path.closeSubpath()
		}
	}
}
