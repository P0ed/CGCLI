import AppKit

func drawHex(at path: String, line: NSColor?, base: NSColor?) throws {
	let size = CGSize(width: 64, height: 64)
	let rep = NSBitmapImageRep(cgImage: .draw(size: size) { ctx in
		let origin = CGPoint(x: size.width, y: size.height) / 2
		ctx.addPath(.hex(origin: origin, radius: origin.x))
		if let line {
			ctx.setStrokeColor(gray: line.whiteComponent, alpha: line.alphaComponent)
			ctx.strokePath()
		}
		if let base {
			ctx.setFillColor(gray: base.whiteComponent, alpha: base.alphaComponent)
			ctx.fillPath()
		}
	}!)
	let pngData = rep.representation(using: .png, properties: [:])!
	let outFile = URL(fileURLWithPath: path)
	try pngData.write(to: outFile)
}

func hexCropImages(in folder: String) throws {
	let fm = FileManager.default
	let inputURL = URL(fileURLWithPath: folder)
	let outputURL = inputURL.appending(path: "Hexes", directoryHint: .isDirectory)

	try fm.createDirectory(at: outputURL, withIntermediateDirectories: true)

	let files = try fm.contentsOfDirectory(at: inputURL, includingPropertiesForKeys: nil)
	for file in files where file.pathExtension == "png" {
		if let nsImage = NSImage(contentsOf: file),
		   let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil),
		   let cropped = cgImage.croppedToHex(size: nsImage.size) {

			let rep = NSBitmapImageRep(cgImage: cropped)
			if let pngData = rep.representation(using: .png, properties: [:]) {
				let outFile = outputURL.appending(
					path: file.lastPathComponent,
					directoryHint: .notDirectory
				)
				try pngData.write(to: outFile)
			}
		}
	}
}

try drawHex(at: "~/Desktop/Cell.png", line: .init(white: 0.15, alpha: 1.0), base: nil)
try drawHex(at: "~/Desktop/Fog.png", line: nil, base: .init(white: 0.15, alpha: 0.15))
//try hexCropImages(in: "~/Desktop/Terrain")
