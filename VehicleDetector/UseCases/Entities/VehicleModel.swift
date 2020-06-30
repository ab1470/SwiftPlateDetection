//
//  VehicleModel.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/20/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation
import Combine
import UIKit


class VehicleModel {
    let identifier = UUID()
    let parentImage: URL
    var bbox: CGRect
    var hasPlates: Bool? /// This flag is set after the model goes through the VehicleDetector. If it didn't detect any plates, it will be set to false so that we don't attempt to re-run the plate detection.
    var licensePlate: LicensePlate?
    
    init(parentImage: URL, bbox: CGRect) {
        self.parentImage = parentImage
        self.bbox = bbox
    }
}
