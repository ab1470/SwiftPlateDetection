//
//  CIImage+Ext.swift
//  VehicleDetectorTest
//
//  Created by Andrew Balmer on 6/7/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import CoreImage.CIImage
import CoreImage.CIFilter

public extension CIImage {
    
    /// Resizes a `CIImage` to the specified size
    ///
    /// - Note: code adapted from: [https://nshipster.com/image-resizing/](https://nshipster.com/image-resizing/)
    func resize(to size: CGSize) -> CIImage? {
        
        var img = self
        
        if img.extent.origin != .zero {
            let transform = CGAffineTransform(translationX: -img.extent.origin.x, y: -img.extent.origin.y)
            img = img.transformed(by: transform)
        }
                
        let existingWidth = img.extent.width
        let existingHeight = img.extent.height

        let scale = size.height / existingHeight
        let aspectRatio = (size.width / size.height) / (existingWidth / existingHeight)

        let filter = CIFilter(name: "CILanczosScaleTransform")
        filter?.setValue(img, forKey: kCIInputImageKey)
        filter?.setValue(scale, forKey: kCIInputScaleKey)
        filter?.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)

        guard let outputImage = filter?.outputImage else {
            return nil
        }

        return outputImage
    }

}
