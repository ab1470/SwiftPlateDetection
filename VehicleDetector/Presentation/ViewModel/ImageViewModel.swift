//
//  ImageViewModel.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/21/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation


struct ImageViewModel {
    public let identifier = UUID()
    public var imageUrl: URL
    public var plateDetectorVMs: [PlateDetectorViewModel]

    public init(imageUrl: URL, plateDetectorVMs: [PlateDetectorViewModel] = []) {
        self.imageUrl = imageUrl
        self.plateDetectorVMs = plateDetectorVMs
    }
}


extension ImageViewModel: Hashable {
    static func == (lhs: ImageViewModel, rhs: ImageViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
