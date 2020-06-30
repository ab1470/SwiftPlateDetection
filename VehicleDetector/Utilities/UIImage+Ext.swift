import UIKit

public extension UIImage {
    
    /// Fixes the orientation of a UIImage to portrait
    ///
    /// - Author: [Sam-Spencer on github](https://gist.github.com/schickling/b5d86cb070130f80bb40#gistcomment-2894406)
    func fixOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            // This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            fatalError("Missing...")
            break
        }
        
        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            fatalError("Missing...")
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
    
    
    /// Resizes an image
    ///
    /// - Note: code adapted from [https://nshipster.com/image-resizing/](https://nshipster.com/image-resizing/)
    func resized(to size: CGSize) -> UIImage {
        guard self.size != size else { return self }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = self.traitCollection.displayScale
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    
    func downsample(to pointSize: CGSize, scale: CGFloat, contentMode: DownsizeContentMode = .scaleToFill) -> UIImage {
        let aspectWidth = pointSize.width / self.size.width
        let aspectHeight = pointSize.height / self.size.height
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        
        let newSize: CGSize
        
        switch contentMode {
        case .scaleToFill:
            newSize = pointSize
        case .scaleAspectFit:
            let aspectRatio = min(aspectWidth, aspectHeight)
            newSize = CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
}

public enum DownsizeContentMode {
    case scaleToFill
    case scaleAspectFit
}
