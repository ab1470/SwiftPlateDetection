//
//  ImageProcessingUseCase.swift
//  VehicleDetectorTests
//
//  Created by Andrew Balmer on 6/18/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation
import Combine
import UIKit


typealias DisplayProps = (size: CGSize, scale: CGFloat)

protocol VehicleDetectorUseCaseType {
    var vehicleDetectorService: VehicleDetectorServiceType { get }
    var plateDetectorService: PlateDetectorService { get set }
    
    /// Detects vehicles within the provided images
    func detectVehicles(inImagesAt urls: [URL]) -> AnyPublisher<[ImageModel], Never>
}


final class VehicleDetectorUseCase: VehicleDetectorUseCaseType {

    let vehicleDetectorService: VehicleDetectorServiceType
    var plateDetectorService = PlateDetectorService()
    
    init(vehicleDetectorService: VehicleDetectorServiceType) {
        self.vehicleDetectorService = vehicleDetectorService
    }
    
    
    func detectVehicles(inImagesAt urls: [URL]) -> AnyPublisher<[ImageModel], Never> {
        return urls.publisher
            .flatMap(maxPublishers: .max(1)) { [unowned self] url -> AnyPublisher<ImageModel, Never> in
                return self.vehicleDetectorService.detectVehicles(in: url)
                    .catch { _ in
                        return Empty<ImageModel, Never>()
                    }
                    .eraseToAnyPublisher()
            }
            .collect()
            .handleEvents(receiveCompletion: { _ in
                /// The vehicle detector model is expensive, so we should deinitialize it when we're done using it.
                self.vehicleDetectorService.deinitModel()
            })
            .subscribe(on: Scheduler.backgroundScheduler)
            .receive(on: Scheduler.mainScheduler)
            .eraseToAnyPublisher()
    }
    
}
