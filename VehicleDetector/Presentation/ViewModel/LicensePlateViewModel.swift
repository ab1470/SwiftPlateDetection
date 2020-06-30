//
//  LicensePlateViewModel.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/25/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation
import UIKit


struct LicensePlateViewModel {
    var plateQuad: CGNormalizedQuad
    var image: UIImage
    var region: PlateRegion
    var plateStrings: [(str: String, confidence: Double)]?
    
    init(plateModel: LicensePlate, image: UIImage) {
        self.plateQuad = plateModel.plateQuad
        self.region = plateModel.region
        self.plateStrings = plateModel.plateStrings
        self.image = image
    }

}
