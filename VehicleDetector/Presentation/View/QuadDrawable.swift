//
//  QuadDrawable.swift
//  VehicleDetectorTest
//
//  Created by Andrew Balmer on 6/4/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation
import UIKit
import Vision


public enum Quadrant {
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft
}

public protocol QuadDrawable where Self: UIView {
    var plateOutlineLayer: CALayer? { get set }
}

public extension QuadDrawable where Self: UIView {

    func drawQuad(for quad: CGNormalizedQuad, scaledTo imageView: UIImageView) -> CGQuad {
        if plateOutlineLayer == nil {
            let plateOutlineLayer = CALayer()
            self.plateOutlineLayer = plateOutlineLayer
            plateOutlineLayer.name = "PlateOutlineLayer"
            plateOutlineLayer.frame = self.frame
            self.layer.insertSublayer(plateOutlineLayer, at: 2)
        }
        
        let scaledQuad = scaleQuadFor(imageView: imageView, normalizedQuad: quad)
        let outlineShape = createPlateOutlineShape(for: scaledQuad)
        
        DispatchQueue.main.async {
            self.plateOutlineLayer?.sublayers = nil
            self.plateOutlineLayer?.addSublayer(outlineShape)
        }
        
        return scaledQuad
    }


    func removeQuad() {
        self.plateOutlineLayer?.sublayers = nil
    }

}


private extension QuadDrawable {
    
    func scaleQuadFor(imageView: UIImageView, normalizedQuad quad: CGNormalizedQuad) -> CGQuad {
        let targetSize = imageView.contentClippingRect
        let scaledQuad = quad.denormalize(to: targetSize)
        return scaledQuad
    }

    func createPlateOutlineShape(for quad: CGQuad) -> CAShapeLayer {
        let rectangleShape = CAShapeLayer()
        rectangleShape.lineWidth = 2
        rectangleShape.lineJoin = CAShapeLayerLineJoin.round
        rectangleShape.strokeColor = UIColor.white.withAlphaComponent(0.8).cgColor
        rectangleShape.fillColor = UIColor.clear.cgColor

        let rectanglePath = UIBezierPath()
        rectanglePath.move(to: quad.tl)
        rectanglePath.addLine(to: quad.tr)
        rectanglePath.addLine(to: quad.br)
        rectanglePath.addLine(to: quad.bl)
        rectanglePath.close()

        rectangleShape.path = rectanglePath.cgPath
        return rectangleShape
    }

}
