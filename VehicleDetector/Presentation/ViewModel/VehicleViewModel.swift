//
//  VehicleViewModel.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/20/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation
import UIKit.UIImage


struct VehicleViewModel {
    let vehicleImage: UIImage
    let licensePlate: LicensePlateViewModel?

    init(_ vehicleImage: UIImage, _ licensePlate: LicensePlateViewModel? = nil) {
        self.vehicleImage = vehicleImage
        self.licensePlate = licensePlate
    }
}

extension VehicleViewModel: Equatable {
    static func == (lhs: VehicleViewModel, rhs: VehicleViewModel) -> Bool {
        if lhs.vehicleImage == rhs.vehicleImage {
            return true
        } else {
            return false
        }
    }
}
