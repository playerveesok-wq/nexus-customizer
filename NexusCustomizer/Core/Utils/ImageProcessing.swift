import UIKit
import ImageIO

enum ImageProcessing {
    static func thumbnail(at url: URL, index: Int = 0, maxPixel: CGFloat) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions),
              index < CGImageSourceGetCount(source) else { return nil }
        return thumbnail(from: source, index: index, maxPixel: maxPixel)
    }

    private static func thumbnail(from source: CGImageSource, index: Int, maxPixel: CGFloat) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ]
        guard let cg = CGImageSourceCreateThumbnailAtIndex(source, index, options as CFDictionary) else { return nil }
        return UIImage(cgImage: cg)
    }

    static func animatedImage(at url: URL, maxPixel: CGFloat, maxFrames: Int = 120) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary)
        else { return nil }

        let count = min(CGImageSourceGetCount(source), maxFrames)
        guard count > 1 else { return thumbnail(at: url, maxPixel: maxPixel) }

        var frames: [UIImage] = []
        var total: TimeInterval = 0

        for i in 0..<count {
            guard let frame = thumbnail(from: source, index: i, maxPixel: maxPixel) else { continue }
            frames.append(frame)

            let props = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [CFString: Any]
            let gif = props?[kCGImagePropertyGIFDictionary] as? [CFString: Any]
            var delay = (gif?[kCGImagePropertyGIFUnclampedDelayTime] as? Double)
                ?? (gif?[kCGImagePropertyGIFDelayTime] as? Double) ?? 0.1
            if delay < 0.02 { delay = 0.1 }
            total += delay
        }
        return UIImage.animatedImage(with: frames, duration: total)
    }
}
