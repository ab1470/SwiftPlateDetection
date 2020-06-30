////
////  VehicleDetectorServiceType.swift
////  VehicleDetectorTest
////
////  Created by Andrew Balmer on 6/1/20.
////  Copyright © 2020 Andrew Balmer. All rights reserved.
////

import Foundation
import UIKit.UIImage
import Combine


protocol VehicleDetectorServiceType: AnyObject {

    func detectVehicles(in imageUrl: URL) -> AnyPublisher<ImageModel, Error>
    func deinitModel()

}
