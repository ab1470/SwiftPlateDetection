import UIKit


public class BlurImageView: UIView {
    
    public var imageView: UIImageView!
    var backgroundView: UIImageView?
    
    public var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue; setBackgroundBlurImage() }
    }
    
    public override var contentMode: UIView.ContentMode {
        get { return imageView.contentMode }
        set { imageView.contentMode = newValue; setBackgroundBlurImage() }
    }
    
    public var blurStyle: UIBlurEffect.Style? {
        didSet {
            if blurStyle == nil {
                backgroundView = nil
            } else {
                if oldValue != blurStyle { backgroundView = nil }
                setBackgroundBlurImage()
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createSubviews()
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    
    private func createSubviews() {
        self.clipsToBounds = true
        
        imageView = UIImageView(frame: bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(imageView)
        
    }
    
    
    private func setBackgroundBlurImage() {
        guard let blurStyle = blurStyle, self.image != nil, contentMode == .scaleAspectFit else {
            backgroundView?.image = nil
            return
        }

        if backgroundView == nil {

            self.backgroundView = UIImageView(frame: bounds)
            guard let backgroundView = self.backgroundView else { return }
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.insertSubview(backgroundView, belowSubview: imageView)
            
            let blurEffectView = UIVisualEffectView(frame: bounds)
            blurEffectView.effect = UIBlurEffect(style: blurStyle)
            backgroundView.addSubview(blurEffectView)
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
        }
                
        if let image = self.image, let backgroundView = self.backgroundView {
            backgroundView.image = image
        }
        
    }
    
    
    public func clearBackgroundImage() {
        if let backgroundView = self.backgroundView {
            backgroundView.image = nil
        }
    }
    
}
