//
//  PlateDetectorViewModelType.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/19/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation
import Combine


struct PlateDetectorViewModelInput {
    /// called when the model is processing the input
    let processing: AnyPublisher<Void, Never>

    /// triggered when the search query is updated
    let detectPlate: AnyPublisher<VehicleModel, Never>
}

enum PlateDetectorState {
    case loading
    case success(VehicleViewModel)
    case noResults
}

extension PlateDetectorState: Equatable {
    static func == (lhs: PlateDetectorState, rhs: PlateDetectorState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.success(let lhsModel), .success(let rhsModel)): return lhsModel == rhsModel
        case (.noResults, .noResults): return true
        default: return false
        }
    }
}

typealias PlateDetectorViewModelOuput = AnyPublisher<PlateDetectorState, Never>

protocol PlateDetectorViewModelType {
    func transform(input: PlateDetectorViewModelInput) -> PlateDetectorViewModelOuput
}
