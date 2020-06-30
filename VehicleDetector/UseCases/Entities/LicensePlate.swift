//
//  LicensePlate.swift
//  VehicleDetectorTest
//
//  Created by Andrew Balmer on 6/4/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit


struct LicensePlate {
    let identifier = UUID()
    var plateQuad: CGNormalizedQuad
    var region: PlateRegion
    var plateStrings: [(str: String, confidence: Double)]?
    
    init(quad: CGNormalizedQuad, region: PlateRegion, strings: [(str: String, confidence: Double)]? = nil) {
        self.plateQuad = quad
        self.region = region
        self.plateStrings = strings
    }
}
