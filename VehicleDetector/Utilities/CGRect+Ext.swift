//
//  CGRect+Ext.swift
//  VehicleDetectorTest
//
//  Created by Andrew Balmer on 6/9/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit
import Vision


extension CGRect {
    func denormalized(to parentSize: CGSize) -> CGRect {

        let fixedBoundingBox = CGRect(x: self.origin.x,
                                      y: self.origin.y,
                                      width: self.width,
                                      height: self.height)

        let denormalized = VNImageRectForNormalizedRect(fixedBoundingBox, Int(parentSize.width), Int(parentSize.height))
        return denormalized
    }
}
