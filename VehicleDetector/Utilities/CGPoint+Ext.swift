//
//  CGPoint+Ext.swift
//  VehicleDetectorTest
//
//  Created by Andrew Balmer on 6/4/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit

public extension CGPoint {
    
    /// Denormalizes a normalized `CGPoint` to fit within the specified size
    ///
    /// Example: denormalizing a `CGPoint` with (x: 0.25, y: 0.75) to size (width: 200, height: 400) will result in a new point (x: 50, y: 300).
    ///
    /// - Precondition:The input point should be normalized; i.e., the x and y values fall within the range 0.0 to 1.0
    /// - Parameter size: the size of the object to which the point will be scaled
    /// - Returns: the scaled `CGPoint`
    func denormalized(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
    
    
    /// Finds the normalized values to represent a `CGPoint`'s position within a specified object.
    ///
    /// Example: normalizing a `CGPoint` with (x: 50, y: 300) to size (width: 200, height: 400) will result in a new point (x: 0.5, y: 0.75).
    ///
    /// - Parameter size: the size of the object to which the point is being normalized
    /// - Returns: the normalized `CGPoint`
    func normalized(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x / size.width, y: self.y / size.height)
    }
}
