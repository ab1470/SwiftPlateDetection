import Foundation
import UIKit
import Vision


public protocol InsetDrawable where Self: UIView {
    var insetView: UIImageView? { get set }
}


public extension InsetDrawable where Self: UIView {
    
    func drawInset(image: UIImage, insetSize: CGSize, in quadrant: Quadrant, padding: CGFloat = 10) {
        if insetView == nil {
            self.insetView = UIImageView(frame: .zero)
            addShadow()
            addBorder()
            self.insetView!.translatesAutoresizingMaskIntoConstraints = false
            self.insertSubview(self.insetView!, at: 6)
        }
                
        self.setInsetPosition(to: quadrant, padding: padding)
        self.setInsetSize(to: insetSize)
        insetView!.image = image
    }
    
        
    func removeInset() {
        self.insetView?.removeFromSuperview()
        self.insetView?.image = nil
    }
    
}


public extension InsetDrawable where Self: UIView {
    
    func setInsetSize(to size: CGSize) {
        guard let insetView = insetView else { return }
        
        let widthConstraintIdentifier = "insetWidthConstraint"
        let heightConstraintIdentifier = "insetHeightConstraint"
        
        if let widthConstraint = constraintWithIdentifier(widthConstraintIdentifier) {
            widthConstraint.constant = size.width
        } else {
            let widthConstraint = insetView.widthAnchor.constraint(equalToConstant: size.width)
            widthConstraint.identifier = widthConstraintIdentifier
            widthConstraint.isActive = true
        }
        
        if let heightConstraint = constraintWithIdentifier(heightConstraintIdentifier) {
            heightConstraint.constant = size.height
        } else {
            let heightConstraint = insetView.heightAnchor.constraint(equalToConstant: size.height)
            heightConstraint.identifier = heightConstraintIdentifier
            heightConstraint.isActive = true
            
        }
        
        self.setNeedsLayout()
    }
    
    
    func setInsetPosition(to quadrant: Quadrant, padding: CGFloat) {
        guard let insetView = insetView else { return }
        
        let topConstraint: NSLayoutConstraint = {
            let topConstraintIdentifier = "insetTopConstraint"
            if let constraint = constraintWithIdentifier(topConstraintIdentifier) {
                return constraint
            } else {
                let constraint = insetView.topAnchor.constraint(equalTo: self.topAnchor, constant: padding)
                constraint.identifier = topConstraintIdentifier
                return constraint
            }
        }()
        
        let leftConstraint: NSLayoutConstraint = {
            let leftConstraintIdentifier = "insetLeftConstraint"
            if let constraint = constraintWithIdentifier(leftConstraintIdentifier) {
                return constraint
            } else {
                let constraint = insetView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: padding)
                constraint.identifier = leftConstraintIdentifier
                return constraint
            }
        }()
        
        let bottomConstraint: NSLayoutConstraint = {
            let bottomConstraintIdentifier = "insetBottomConstraint"
            if let constraint = constraintWithIdentifier(bottomConstraintIdentifier) {
                return constraint
            } else {
                let constraint = insetView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding)
                constraint.identifier = bottomConstraintIdentifier
                return constraint
            }
        }()
        
        let rightConstraint: NSLayoutConstraint = {
            let rightConstraintIdentifier = "insetRightConstraint"
            if let constraint = constraintWithIdentifier(rightConstraintIdentifier) {
                return constraint
            } else {
                let constraint = insetView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -padding)
                constraint.identifier = rightConstraintIdentifier
                return constraint
            }
        }()
            
            
        switch quadrant {
        case .topLeft:
            topConstraint.isActive = true
            leftConstraint.isActive = true
            bottomConstraint.isActive = false
            rightConstraint.isActive = false
        case .topRight:
            leftConstraint.isActive = false
            bottomConstraint.isActive = false
            topConstraint.isActive = true
            rightConstraint.isActive = true
        case .bottomRight:
            topConstraint.isActive = false
            leftConstraint.isActive = false
            bottomConstraint.isActive = true
            rightConstraint.isActive = true
        case .bottomLeft:
            topConstraint.isActive = false
            leftConstraint.isActive = true
            bottomConstraint.isActive = true
            rightConstraint.isActive = false
        }

        self.setNeedsLayout()
    }
    
    
    func constraintWithIdentifier(_ identifier: String) -> NSLayoutConstraint? {
        if let constraint = self.constraints.first(where: { $0.identifier == identifier }) {
            return constraint
        } else {
            guard let insetView = insetView else { return nil }
            return insetView.constraints.first { $0.identifier == identifier }
        }
    }
    
}
    
    
private extension InsetDrawable where Self: UIView {
    
    func addShadow() {
        guard let insetView = insetView else { return }
        
        insetView.layer.shadowOffset = CGSize(width: 3, height: -3)
        insetView.layer.shadowOpacity = 0.8
        insetView.layer.shadowRadius = 12
        insetView.layer.shadowColor = UIColor.black.cgColor
        insetView.layer.masksToBounds = false
    }
    
    
    func addBorder() {
        guard let insetView = insetView else { return }
        
        insetView.layer.borderWidth = 5.0
        insetView.layer.borderColor = UIColor.white.cgColor
    }
    
}
    
    



//    func getOrigin(for plateSize: CGSize, quadrant: Quadrant, padding: CGFloat) -> CGPoint {
//        let posX: CGFloat
//        let posY: CGFloat
//
//        switch quadrant {
//        case .topLeft:
//            posX = padding
//            posY = padding
//        case .topRight:
//            posX = self.frame.width - plateSize.width - padding
//            posY = padding
//        case .bottomLeft:
//            posX = padding
//            posY = self.frame.height - plateSize.height - padding
//        case .bottomRight:
//            posX = self.frame.width - plateSize.width - padding
//            posY = self.frame.height - plateSize.height - padding
//        }
//
//        let plateOverlayCenter = CGPoint(x: posX, y: posY)
//        return plateOverlayCenter
//    }
