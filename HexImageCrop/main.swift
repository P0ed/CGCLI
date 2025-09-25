import AppKit
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

extension CGPath {

	static func make(_ transform: (CGMutablePath) -> Void) -> CGPath {
		let path = CGMutablePath()
		transform(path)
		return path
	}

	static func hex(origin: CGPoint, radii: CGFloat) -> CGPath {
		.make { path in
			let corners = CGPoint.hexCorners
			path.move(to: origin + corners[0] * radii)
			corners.dropFirst().forEach { corner in
				path.addLine(to: origin + corner * radii)
			}
			path.closeSubpath()
		}
	}
}

extension CGImage {

	static func draw(size: CGSize, drawings: (CGContext) -> Void) -> CGImage? {
		let width = Int(size.width)
		let height = Int(size.height)

		var rgbSpace: CGColorSpace { CGColorSpaceCreateDeviceRGB() }

		let bppx = 32
		let bpcp = 8

		guard let context = CGContext(
			data: nil,
			width: width,
			height: height,
			bitsPerComponent: bpcp,
			bytesPerRow: width * bppx / 8,
			space: rgbSpace,
			bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
		) else {
			return nil
		}

		drawings(context)

		return context.makeImage()
	}

	func croppedToHex(size: CGSize) -> CGImage? {
		.draw(size: size) { context in
			let origin = CGPoint(x: size.width, y: size.height) / 2
			let radii = min(origin.x, origin.y)

			context.addPath(.hex(origin: origin, radii: radii))
			context.clip()

			let rect = CGRect(origin: .zero, size: size)
			context.draw(self, in: rect)
		}
	}
}

let fm = FileManager.default
let inputURL = URL(fileURLWithPath: "/Users/poed/Desktop")
let outputURL = URL(fileURLWithPath: "/Users/poed/Desktop/Hexes")

try fm.createDirectory(at: outputURL, withIntermediateDirectories: true)

let files = try fm.contentsOfDirectory(at: inputURL, includingPropertiesForKeys: nil)
for file in files where file.pathExtension == "png" {
	if let nsImage = NSImage(contentsOf: file),
	   let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil),
	   let cropped = cgImage.croppedToHex(size: nsImage.size) {

		let rep = NSBitmapImageRep(cgImage: cropped)
		if let pngData = rep.representation(using: .png, properties: [:]) {
			let outFile = outputURL.appendingPathComponent(file.lastPathComponent)
			try pngData.write(to: outFile)
		}
	}
}
