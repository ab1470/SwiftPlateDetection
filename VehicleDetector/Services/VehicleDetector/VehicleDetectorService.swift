//
//  VehicleDetectorService.swift
//  VehicleDetectorTest
//
//  Created by Andrew Balmer on 6/1/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation
import UIKit.UIImage
import Combine
import Vision


final class VehicleDetectorService: VehicleDetectorServiceType {
    
    private var modelConfig: Configuration<VNCoreMLRequest, VNRecognizedObjectObservation>?
    private let categoriesToIdentify = ["car", "bus", "truck"]
            
    private func initializeModel() {
        let mlmodel = MobileNetV2_SSDLite().model
        let vnmodel: VNCoreMLModel
        
        do {
            vnmodel = try VNCoreMLModel(for: mlmodel)
            
            // Use a threshold provider to specify custom thresholds for the object detector.
            vnmodel.featureProvider = ThresholdProvider()
            
            modelConfig = Configuration<VNCoreMLRequest, VNRecognizedObjectObservation>(model: vnmodel) { request in
                request.imageCropAndScaleOption = .scaleFill
            }
        } catch {
            preconditionFailure(
                "there was an error converting the MobileNetV2_SSDLite model to a VNCoreMLModel: \n\(error.localizedDescription)"
            )
        }
    }
    
    func deinitModel() {
        self.modelConfig = nil
    }
    
    func detectVehicles(in imageUrl: URL) -> AnyPublisher<ImageModel, Error> {
        
        if modelConfig == nil {
            initializeModel()
        }
        
        let ciImage: CIImage
        let orientation: CGImagePropertyOrientation
        
        do {
            let imageData = try loadCIImage(from: imageUrl)
            ciImage = imageData.img
            orientation = imageData.orientation
        } catch let error {
            return .fail(error)
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
        
        return handler
            .publisher(for: modelConfig!)
            .map { [unowned self] observations -> [VNRecognizedObjectObservation] in
                assert(type(of: observations) == [VNRecognizedObjectObservation].self,
                       "VNRequest did not return a VNRecognizedObjectObservation: \(observations.debugDescription)")
                
                let vehicleObservations = observations.filter {
                    let mostConfidentLabel = $0.labels[0].identifier
                    return self.categoriesToIdentify.contains(mostConfidentLabel)
                }
                
                return vehicleObservations
            }
            .map { observations -> ImageModel in
                let vehicleViewModels = observations.map {
                    VehicleModel(parentImage: imageUrl, bbox: $0.boundingBox)
                }
                return ImageModel(imageUrl: imageUrl, vehicleModels: vehicleViewModels)
            }
            .eraseToAnyPublisher()
    }
    
    
    private func loadCIImage(from imageUrl: URL) throws -> (img: CIImage, orientation: CGImagePropertyOrientation) {
        guard let uiimage = getImage(from: imageUrl) else {
            throw FileError.cannotLoadFile
        }
        
        guard let image = uiimage.fixOrientation() else {
            print("unable to fix the image orientation")
            throw ImageError.orientationError
        }
        
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else {
            print("Unable to get the orientation of the image.")
            throw ImageError.orientationError
        }
        
        guard let ciImg = CIImage(image: image) else {
            print("Unable to create \(CIImage.self) from \(image).")
            throw ImageError.conversionError
        }
        
        return (img: ciImg, orientation: orientation)
    }

}







/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

final class VehicleDetectorService2 {
    
    private let modelConfig: Configuration<VNCoreMLRequest, VNRecognizedObjectObservation>
    private let categoriesToIdentify = ["car", "bus", "truck"]
            
    init() {
        let mlmodel = MobileNetV2_SSDLite().model
        let vnmodel: VNCoreMLModel
        
        do {
            vnmodel = try VNCoreMLModel(for: mlmodel)
            
            // Use a threshold provider to specify custom thresholds for the object detector.
            vnmodel.featureProvider = ThresholdProvider()
            
            modelConfig = Configuration<VNCoreMLRequest, VNRecognizedObjectObservation>(model: vnmodel) { request in
                request.imageCropAndScaleOption = .scaleFill
            }
        } catch {
            preconditionFailure(
                "there was an error converting the MobileNetV2_SSDLite model to a VNCoreMLModel: \n\(error.localizedDescription)"
            )
        }
        
    }
    
    
    func detectVehicles(in imageUrl: URL) -> AnyPublisher<[VNRecognizedObjectObservation], Error> {
        guard let image = getImage(from: imageUrl) else {
            return .fail(FileError.cannotLoadFile)
        }
        
        return detectVehicles(in: image)
    }
    
    
    func detectVehicles(in uiimage: UIImage) -> AnyPublisher<[VNRecognizedObjectObservation], Error> {
        guard let image = uiimage.fixOrientation() else {
            print("unable to fix the image orientation")
            return .fail(ImageError.orientationError)
        }
        
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else {
            print("Unable to get the orientation of the image.")
            return .fail(ImageError.orientationError)
        }
        
        guard let ciImg = CIImage(image: image) else {
            print("Unable to create \(CIImage.self) from \(image).")
            return .fail(ImageError.conversionError)
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImg, orientation: orientation)

        return handler
            .publisher(for: modelConfig)
            .map { [unowned self] observations in
                assert(type(of: observations) == [VNRecognizedObjectObservation].self,
                       "VNRequest did not return a VNRecognizedObjectObservation: \(observations.debugDescription)")
                
                let vehicleObservations = observations.filter {
                    self.categoriesToIdentify.contains($0.labels[0].identifier)
                }
                
                guard !vehicleObservations.isEmpty else {
                    print("no vehicles found in photo")
                    return []
                }
                return vehicleObservations
            }
            .handleEvents(receiveCompletion: { aValue in
                print("HANDLER receiveCompletion event called")
            }, receiveCancel: {
                print("HANDLER receiveCancel event invoked")
            })
            .eraseToAnyPublisher()
    }
    
}

enum ImageError: Error {
    case orientationError
    case conversionError
    case resizeError
}


enum FileError: Error {
    case cannotLoadFile
}
