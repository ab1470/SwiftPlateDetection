import UIKit

public extension UIImageView {
    
    /// The size of the image inside the `UIImageView` when the content mode has been set to `.scaleAspectFit`.
    ///
    /// All images have a natural size, which is the number of pixels they are wide and high. All image views also have a size, which is whatever width and height they have once their Auto Layout constraints have been resolved.
    ///
    /// Things get a little more complex when you place an image inside an image view and make it use aspect fit content mode – the image gets scaled down to fit inside the image view, so that all parts of the image are visible.
    ///
    /// This property returns the size of an aspect fit image inside its image view.
    ///
    /// - Author: [Hacking with Swift](https://www.hackingwithswift.com/example-code/uikit/how-to-find-an-aspect-fit-images-size-inside-an-image-view)
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }

        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }

        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
}
