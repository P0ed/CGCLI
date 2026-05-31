import AppKit

func maskImages(in folder: String, using mask: String) throws {
	let fm = FileManager.default
	let inputURL = URL(fileURLWithPath: folder)
	let outputURL = inputURL.appending(path: "Masked", directoryHint: .isDirectory)

	try fm.createDirectory(at: outputURL, withIntermediateDirectories: true)

	let files = try fm.contentsOfDirectory(at: inputURL, includingPropertiesForKeys: nil)
	let maskImage = CGImage.image(url: URL(fileURLWithPath: mask))!

	for file in files where file.pathExtension == "png" {
		let img = CGImage.image(url: file)
		let mskd = img?.masked(maskImage)
		if let image = mskd {
			if let pngData = image.pngData {
				let outFile = outputURL.appending(
					path: file.lastPathComponent,
					directoryHint: .notDirectory
				)
				try pngData.write(to: outFile)
			}
		}
	}
}

try maskImages(in: "~/Desktop/Tiles", using: "~/Desktop/Masks/RhombusMask.png")
