//
//  ImageProcessorViewModelType.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/19/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation
import Combine


struct VehicleDetectorViewModelInput {
    let detectVehicles: AnyPublisher<[URL], Never>
}

enum VehicleDetectorState {
    case idle
    case loading
    case success([ImageViewModel])
    case noResults
}

extension VehicleDetectorState: Equatable {
    static func == (lhs: VehicleDetectorState, rhs: VehicleDetectorState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success(let lhsModels), .success(let rhsModels)): return lhsModels == rhsModels
        case (.noResults, .noResults): return true
        default: return false
        }
    }
}

typealias VehicleDetectorViewModelOuput = AnyPublisher<VehicleDetectorState, Never>

protocol VehicleDetectorViewModelType {
    func transform(input: VehicleDetectorViewModelInput) -> VehicleDetectorViewModelOuput
}
