import UIKit


class VehiclePlateView: UIView, InsetDrawable, QuadDrawable {
    
    var displayData: VehicleViewModel? {
        didSet { self.draw() }
    }
    
    var vehicleImageView: BlurImageView!
    var insetView: UIImageView?
    private var outlineQuadrilateral: CGQuad?
    var plateOutlineLayer: CALayer?
    var calloutGradientLayer: CALayer?
    //    var label: UILabel!
    
    //    public var caption: String? {
    //        get { return label?.text }
    //        set { label.text = newValue }
    //    }
    
    var vehicleImage: UIImage? {
        get { return vehicleImageView.image }
        set { vehicleImageView.image = newValue }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    func createSubviews() {
        self.clipsToBounds = true
        
        vehicleImageView = BlurImageView(frame: bounds)
        vehicleImageView.contentMode = .scaleAspectFit
        vehicleImageView.blurStyle = .regular
        vehicleImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(vehicleImageView)
        
        // caption has translucent grey background 30 points high and span across bottom of view
        //        let captionBackgroundView = UIView(frame: CGRect(x: 0, y: bounds.height - 30, width: bounds.width, height: 30))
        //        captionBackgroundView.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        //        addSubview(captionBackgroundView)
        //
        //        label = UILabel(frame: captionBackgroundView.bounds.insetBy(dx: 10, dy: 5))
        //        label.textColor = UIColor(white: 0.9, alpha: 1.0)
        //        captionBackgroundView.addSubview(label)
    }
    
    private func draw() {
        guard let displayData = self.displayData else { return }
        self.vehicleImage = displayData.vehicleImage
        
        guard let licensePlate = displayData.licensePlate else {
            insetView?.removeFromSuperview()
            insetView = nil
            return
        }
        
        let plateQuad = licensePlate.plateQuad
        
        let quadrant: Quadrant
        switch plateQuad.quadrant() {
        case .bottomRight:
            quadrant = .topLeft
        case .bottomLeft:
            quadrant = .topRight
        case .topRight:
            quadrant = .bottomLeft
        case .topLeft:
            quadrant = .bottomRight
        }
        
        // TODO: - make the height a variable
        let insetWidth = licensePlate.region.width(forHeight: 65)
        let insetSize = CGSize(width: insetWidth, height: 65)
        
        drawInset(image: licensePlate.image, insetSize: insetSize, in: quadrant)
        self.outlineQuadrilateral = drawQuad(for: plateQuad, scaledTo: vehicleImageView.imageView)
    }
    
    
    private func drawCalloutGradient(outline: CGQuad, inset: CGQuad) {
        
        let points = outline.points() + inset.points()
        let calloutPoints = convexHull(points)
        
        guard let startPoint = calloutPoints.first else { return }
        
        if calloutGradientLayer == nil {
            let calloutGradientLayer = CALayer()
            self.calloutGradientLayer = calloutGradientLayer
            calloutGradientLayer.name = "CalloutGradientLayer"
            calloutGradientLayer.frame = self.frame
            self.layer.insertSublayer(calloutGradientLayer, below: insetView?.layer)
        }
        
        let gradientMask = UIBezierPath()
        
        gradientMask.move(to: startPoint)
        calloutPoints[0...].forEach{ gradientMask.addLine(to: $0) }
        gradientMask.close()
        
        let shape = CAShapeLayer()
        shape.frame = self.frame
        shape.path = gradientMask.cgPath
        
        let gradient = CAGradientLayer()
        gradient.frame = self.frame
        
        let insetCentroid = inset.centroid().normalized(to: self.frame.size)
        let outlineCentroid = outline.centroid().normalized(to: self.frame.size)
        
        gradient.colors = [
            UIColor.white.withAlphaComponent(0.1).cgColor,
            UIColor.white.withAlphaComponent(0.4).cgColor
        ]
        gradient.startPoint = outlineCentroid
        gradient.endPoint = insetCentroid
        gradient.mask = shape
        
        self.calloutGradientLayer?.addSublayer(gradient)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let insetView = insetView, let outlineQuad = outlineQuadrilateral {
            let insetQuad = CGQuad(with: insetView.frame)
            self.drawCalloutGradient(outline: outlineQuad, inset: insetQuad)
        }
    }
    
    
    func clear() {
        self.vehicleImage = nil
        insetView?.removeFromSuperview()
        insetView = nil
        self.plateOutlineLayer?.sublayers = nil
        self.calloutGradientLayer?.sublayers = nil
    }
    
}
