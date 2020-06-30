//
//  ImageViewModel.swift
//  VehicleDetectorTest
//
//  Created by Andrew Balmer on 6/1/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation


struct ImageModel {
    public var imageUrl: URL
    public var vehicleModels: [VehicleModel]

    public init(imageUrl: URL, vehicleModels: [VehicleModel] = []) {
        self.imageUrl = imageUrl
        self.vehicleModels = vehicleModels
    }
}
