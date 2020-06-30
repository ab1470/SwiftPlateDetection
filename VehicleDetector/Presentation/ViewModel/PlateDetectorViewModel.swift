//
//  PlateDetectorViewModel.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/21/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation
import Combine
import UIKit


struct PlateDetectorViewModel {
    
    let id = UUID()
    let vehicleModel: VehicleModel
    
    private let plateDetectorService: PlateDetectorService
    
    
    init(vehicleModel: VehicleModel, plateDetector: PlateDetectorService) {
        self.vehicleModel = vehicleModel
        self.plateDetectorService = plateDetector
    }
    
    
    func detectPlates(outputProps: DisplayProps) -> AnyPublisher<PlateDetectorState, Never> {
        
        let activitySubject = PassthroughSubject<Void, Never>()
        let plateDetectorPublisher = plateDetectorService
            .detectPlates(with: self.vehicleModel, displayProps: outputProps, activitySubject: activitySubject)
        
        let loading = activitySubject
            .map({ _ in PlateDetectorState.loading })
            .eraseToAnyPublisher()
        
        let imageModels = plateDetectorPublisher
            .map({ viewModel -> PlateDetectorState in
                //                guard !viewModel.isEmpty else { return .noResults }
                return .success(viewModel)
            })
            .eraseToAnyPublisher()
        
        return Publishers.Merge(loading, imageModels)
            .subscribe(on: Scheduler.backgroundScheduler)
            .receive(on: Scheduler.mainScheduler)
            .eraseToAnyPublisher()
    }
    
}


extension PlateDetectorViewModel: Hashable {
    static func == (lhs: PlateDetectorViewModel, rhs: PlateDetectorViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
