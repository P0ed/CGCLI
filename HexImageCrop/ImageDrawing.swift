import CoreGraphics
import Foundation
import AppKit

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

	var size: CGSize {
		CGSize(width: width, height: height)
	}

	var pngData: Data? {
		NSBitmapImageRep(cgImage: self).representation(using: .png, properties: [:])
	}

	static func image(url: URL) -> CGImage? {
		NSImage(contentsOf: url).flatMap { img in
			img.cgImage(forProposedRect: nil, context: nil, hints: nil)
		}
	}

	func masked(_ mask: CGImage) -> CGImage? {
		.draw(size: mask.size) { ctx in
			ctx.clip(
				to: mask.size.rect,
				mask: mask
			)
			ctx.draw(self, in: size.rect)
		}
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
