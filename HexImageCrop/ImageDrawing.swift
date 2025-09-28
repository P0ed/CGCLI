import CoreGraphics

extension CGImage {

	static func draw(size: CGSize, drawings: (CGContext) -> Void) -> CGImage? {
		let width = Int(size.width)
		let height = Int(size.height)
		let bppx = 32
		let bpcp = 8

		guard let context = CGContext(
			data: nil,
			width: width,
			height: height,
			bitsPerComponent: bpcp,
			bytesPerRow: width * bppx / 8,
			space: CGColorSpaceCreateDeviceRGB(),
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
			let radius = min(origin.x, origin.y)

			context.addPath(.hex(origin: origin, radius: radius))
			context.clip()

			let rect = CGRect(origin: .zero, size: size)
			context.draw(self, in: rect)
		}
	}
}
