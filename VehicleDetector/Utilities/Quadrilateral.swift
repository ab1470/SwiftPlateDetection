//
//  Quadrilateral.swift
//  VehicleDetectorTest
//
//  Created by Andrew Balmer on 6/4/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit
import SwiftClipper

public protocol Quadrilateral: Equatable {
    var tl: CGPoint { get set }
    var tr: CGPoint { get set }
    var br: CGPoint { get set }
    var bl: CGPoint { get set }
}

public extension Quadrilateral {

    /// Returns a `CGPoint` representing the centroid of the quadrilateral
    func centroid() -> CGPoint {
        let cx = (self.tl.x + self.tr.x + self.br.x + self.bl.x) / 4
        let cy = (self.tl.y + self.tr.y + self.br.y + self.bl.y) / 4
        return CGPoint(x: cx, y: cy)
    }
    
    /// Returns an array of the quadrilateral's four points
    func points() -> [CGPoint] {
        return [tl, tr, br, bl]
    }
}


/// A quadrilateral made up of four `CGPoint`s
public struct CGQuad: Quadrilateral {
    public var tl: CGPoint
    public var tr: CGPoint
    public var br: CGPoint
    public var bl: CGPoint
    
    public init(tl: CGPoint, tr: CGPoint, br: CGPoint, bl: CGPoint) {
        self.tl = tl
        self.tr = tr
        self.br = br
        self.bl = bl
    }
    
    public init(with rect: CGRect) {
        self.tl = CGPoint(x: rect.minX, y: rect.minY)
        self.tr = CGPoint(x: rect.maxX, y: rect.minY)
        self.br = CGPoint(x: rect.maxX, y: rect.maxY)
        self.bl = CGPoint(x: rect.minX, y: rect.maxY)
    }
    
    
    /// Offsets the quadrilateral by some positive value
    /// - Parameter delta: The value with which to offset the `CGQuad`. This should be a positive value
    /// - Note: This method makes use of the [SwiftClipper](https://github.com/lhuanyu/SwiftClipper/tree/7b0d8d55ebd6a2c26549e6f7ffc865f9d83660c1) package (installed via SPM)
    public func expand(by delta: CGFloat) -> CGQuad {
        guard delta > 0 else { return self }
        let points = self.points()
        guard let newPoints = points.offset(delta).first else { return self }
        return CGQuad(tl: newPoints[2], tr: newPoints[3], br: newPoints[0], bl: newPoints[1])
    }
}



/// A quadrilateral whose four `CGPoint`s are normalized (i.e., their x- and y-values are in the range 0.0 to 1.0)
public struct CGNormalizedQuad: Quadrilateral {
    public var tl: CGPoint
    public var tr: CGPoint
    public var br: CGPoint
    public var bl: CGPoint
    
    public init(tl: CGPoint, tr: CGPoint, br: CGPoint, bl: CGPoint) {
        self.tl = tl
        self.tr = tr
        self.br = br
        self.bl = bl
    }
    
    
    public func denormalize(to size: CGSize, withPadding padding: CGFloat? = nil) -> CGQuad {
        var tl = self.tl.denormalized(to: size)
        var tr = self.tr.denormalized(to: size)
        var br = self.br.denormalized(to: size)
        var bl = self.bl.denormalized(to: size)
        
        if let padding = padding {
            tl.x -= padding; tl.y -= padding
            tr.x += padding; tr.y -= padding
            br.x += padding; br.y += padding
            bl.x -= padding; bl.y += padding
        }
                
        return CGQuad(tl: tl, tr: tr, br: br, bl: bl)
    }
    
    
    public func denormalize(to rect: CGRect, withPadding padding: CGFloat? = nil) -> CGQuad {
        let size = CGSize(width: rect.width, height: rect.height)
        
        var tl = self.tl.denormalized(to: size)
        var tr = self.tr.denormalized(to: size)
        var br = self.br.denormalized(to: size)
        var bl = self.bl.denormalized(to: size)
        
        if let padding = padding {
            tl.x -= padding; tl.y -= padding
            tr.x += padding; tr.y -= padding
            br.x += padding; br.y += padding
            bl.x -= padding; bl.y += padding
        }

        tl.x += rect.minX; tl.y += rect.minY
        tr.x += rect.minX; tr.y += rect.minY
        br.x += rect.minX; br.y += rect.minY
        bl.x += rect.minX; bl.y += rect.minY
        
        return CGQuad(tl: tl, tr: tr, br: br, bl: bl)
    }
    
    
    public func quadrant() -> Quadrant {
        let centroid = self.centroid()
        
        if centroid.y < 0.5 {
            if centroid.x < 0.5 {
                return Quadrant.topLeft
            } else {
                return Quadrant.topRight
            }
        } else {
            if centroid.x < 0.5 {
                return Quadrant.bottomLeft
            } else {
                return Quadrant.bottomRight
            }
        }
    }

}



public func multiArrayToNormalizedQuad(_ multiarray: MultiArray<Float32>) -> CGNormalizedQuad? {
    guard multiarray.shape == [2, 4] else { return nil }
    
    let tl = CGPoint(x: CGFloat(multiarray[0]), y: CGFloat(multiarray[4]))
    let tr = CGPoint(x: CGFloat(multiarray[1]), y: CGFloat(multiarray[5]))
    let br = CGPoint(x: CGFloat(multiarray[2]), y: CGFloat(multiarray[6]))
    let bl = CGPoint(x: CGFloat(multiarray[3]), y: CGFloat(multiarray[7]))

    return CGNormalizedQuad(tl: tl, tr: tr, br: br, bl: bl)
}
