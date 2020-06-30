//
//  ImageProcessorViewModel.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/19/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation
import Combine


final class VehicleDetectorViewModel: VehicleDetectorViewModelType {

    private let useCase: VehicleDetectorUseCaseType

    init(useCase: VehicleDetectorUseCaseType) {
        self.useCase = useCase
    }

    func transform(input: VehicleDetectorViewModelInput) -> VehicleDetectorViewModelOuput {

        let loading: VehicleDetectorViewModelOuput = input.detectVehicles
            .filter{ !$0.isEmpty }
            .map({ _ in .loading })
            .eraseToAnyPublisher()
                
        let imageModels = input.detectVehicles
            .flatMap{ [unowned self] urls -> AnyPublisher<[ImageModel], Never> in
                self.useCase.detectVehicles(inImagesAt: urls)
            }
            .map({ imageModels -> VehicleDetectorState in
                guard !imageModels.isEmpty else { return .noResults }
                return .success(self.viewModels(from: imageModels))
            })
            .eraseToAnyPublisher()
                
        return Publishers.Merge(loading, imageModels).eraseToAnyPublisher()
    }

    private func viewModels(from imageModels: [ImageModel]) -> [ImageViewModel] {
        return imageModels.map({ [unowned self] imageModel in
            let vehicleViewModels = imageModel.vehicleModels.map { [unowned self] vehicleModel -> PlateDetectorViewModel in
                return PlateDetectorViewModel(vehicleModel: vehicleModel, plateDetector: self.useCase.plateDetectorService)
            }
            
            return ImageViewModel(imageUrl: imageModel.imageUrl, plateDetectorVMs: vehicleViewModels)
            
//            return MovieViewModelBuilder.viewModel(from: movie, imageLoader: {[unowned self] movie in self.useCase.loadImage(for: movie, size: .small) })
        })
    }

}
