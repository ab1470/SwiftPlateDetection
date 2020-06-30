//
//  PlateDetector.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/24/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit
import Combine
import Vision
import CoreImage.CIFilterBuiltins

final class PlateDetectorService {
    
    private typealias PlateDetectorOutput = (vehicleImg: UIImage, plateQuad: CGNormalizedQuad?, plateImg: UIImage?)
        
    private let vehicleImgCache: ImageCacheType = ImageCache()
    private let plateImgCache: ImageCacheType = ImageCache()
    
    private let modelConfig: Configuration<VNCoreMLRequest, VNCoreMLFeatureValueObservation>
    let sharedContext = CIContext(options: [.useSoftwareRenderer : false])
    
    init() {
        let mlmodel = PlateDetectorPipeline().model
        let vnmodel: VNCoreMLModel
        
        do {
            vnmodel = try VNCoreMLModel(for: mlmodel)
            
            // Use a threshold provider to specify custom thresholds for the object detector.
            vnmodel.featureProvider = ThresholdProvider()
            
            modelConfig = Configuration<VNCoreMLRequest, VNCoreMLFeatureValueObservation>(model: vnmodel) { request in
                request.imageCropAndScaleOption = .scaleFit
            }
        } catch {
            preconditionFailure(
                "there was an error converting the PlateDetector model to a VNCoreMLModel: \n\(error.localizedDescription)"
            )
        }
        
    }
    
    
    func detectPlates(with vehicleModel: VehicleModel,
                      displayProps: DisplayProps,
                      activitySubject: PassthroughSubject<Void, Never>) -> AnyPublisher<VehicleViewModel, Never> {
        
        /// If the `hasPlates` flag has been set (either to `true` or to `false`, it means that the plate detector has already been run on the vehicle model.
        /// We don't need to re-run it, we simply need to fetch the images from the caches, or re-load those image(s) in the case the cache(s) have been cleared.
        if vehicleModel.hasPlates != nil {
            
            let vehicleViewModel: AnyPublisher<VehicleViewModel, Never>
                        
            let vehicleImgPublisher = Just(vehicleModel)
                .flatMap { [unowned self] fetchModel -> AnyPublisher<UIImage, Never> in
                    if let cachedVehicleImg = self.vehicleImgCache.image(for: fetchModel.identifier) {
                        return .just(cachedVehicleImg)
                    } else {
                        return self.cropImageToVehicle(with: fetchModel)
                            /// For some reason, adding this delay prevents a memory leak.
                            .delay(for: .seconds(0.05), scheduler: DispatchQueue.main)
                            .map { [unowned self] ciImg -> UIImage in
                                let final = self.sharedContext.createCGImage(ciImg, from: ciImg.extent)
                                let vehicleImg = UIImage(cgImage: final!)
                                self.vehicleImgCache.insertImage(vehicleImg, for: fetchModel.identifier)
                                return vehicleImg
                            }
                            .replaceError(with: UIImage())
                            .eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
            
            if let licensePlate = vehicleModel.licensePlate {
                
                vehicleViewModel = vehicleImgPublisher
                    .map { vehicleImg -> VehicleViewModel in
                        let plateImg: UIImage?
                        
                        if let cachedPlateImg = self.plateImgCache.image(for: licensePlate.identifier) {
                            plateImg = cachedPlateImg
                        } else {
                            plateImg = self.extractPlateImage(from: vehicleImg, for: licensePlate.plateQuad, plateRegion: licensePlate.region)
                        }
                        
                        if let plateImg = plateImg {
                            self.plateImgCache.insertImage(plateImg, for: licensePlate.identifier)
                            let licensePlateVM = LicensePlateViewModel(plateModel: licensePlate, image: plateImg)
                            return VehicleViewModel(vehicleImg, licensePlateVM)
                        } else {
                            return VehicleViewModel(vehicleImg)
                        }
                    }
                    .eraseToAnyPublisher()
                
            } else {
                vehicleViewModel = vehicleImgPublisher
                    .map { vehicleImg -> VehicleViewModel in
                        return VehicleViewModel(vehicleImg)
                    }
                    .eraseToAnyPublisher()
            }
            
            return vehicleViewModel
        }
        
        
        return Deferred { return Just(vehicleModel) }
            .setFailureType(to: Error.self)
            .flatMap( { [unowned self] fetchModel -> AnyPublisher<CIImage, Error> in
                activitySubject.send(())
                return self.cropImageToVehicle(with: fetchModel)
            })
            .flatMap( { [unowned self] ciImg -> AnyPublisher<PlateDetectorOutput, Error> in
                return self.detectPlates(in: ciImg, displayProps: displayProps)
            })
            // FIXME: - For some reason, adding this delay prevents a memory leak. I think it has something to with the delay being on the main thread. Figure out how to remove the delay and prevent the leak.
            .delay(for: .seconds(0.01), scheduler: Scheduler.mainScheduler)
            .map { [unowned self] output -> VehicleViewModel in
                self.vehicleImgCache.insertImage(output.vehicleImg, for: vehicleModel.identifier)

                if let plateQuad = output.plateQuad, let plateImg = output.plateImg {
                    let licensePlate = LicensePlate(quad: plateQuad, region: .europe)
                    self.plateImgCache.insertImage(plateImg, for: licensePlate.identifier)
                    vehicleModel.licensePlate = licensePlate
                    vehicleModel.hasPlates = true
                    
                    let plateViewModel = LicensePlateViewModel(plateModel: licensePlate, image: plateImg)
                    return VehicleViewModel(output.vehicleImg, plateViewModel)
                } else {
                    vehicleModel.hasPlates = false
                    return VehicleViewModel(output.vehicleImg)
                }
            }
            .replaceError(with: VehicleViewModel(UIImage()))
            .eraseToAnyPublisher()
    }
    
    
    private func detectPlates(in image: CIImage, displayProps: DisplayProps) -> AnyPublisher<PlateDetectorOutput, Error> {
        let handler = VNImageRequestHandler(ciImage: image)

        return handler
            .publisher(for: modelConfig)
            .compactMap { [unowned self] observations in
                assert(type(of: observations) == [VNCoreMLFeatureValueObservation].self,
                       "VNRequest did not return a VNCoreMLFeatureValueObservation: \(observations.debugDescription)")

                /// The output of the MLModel prediction includes flag to indicate whether the model found any license plates. These two lines read this flag.
                let hasResultsFeatureValue = observations.last!.featureValue
                let hasResults = hasResultsFeatureValue.multiArrayValue![0].floatValue == 1.0 ? true : false
                
                let final = self.sharedContext.createCGImage(image, from:image.extent)
                let vehicleImg = UIImage(cgImage: final!)
                    .downsample(to: displayProps.size, scale: displayProps.scale, contentMode: .scaleAspectFit)
                                
                guard hasResults else {
                    print("no license plates found in photo")
                    return (vehicleImg, nil, nil)
                }
                
                guard let plateQuads = self.getPlateQuads(from: observations) else {
                    return (vehicleImg, nil, nil)
                }
                
                let plateImages = plateQuads.compactMap {
                    self.extractPlateImage(from: image, for: $0, plateRegion: .europe)
                }
                
                if let plateQuad = plateQuads.first, let plateImg = plateImages.first {
                    return (vehicleImg, plateQuad, plateImg)
                } else {
                    return (vehicleImg, nil, nil)
                }
                
        }
        .eraseToAnyPublisher()
        
    }
    
    
    func cropImageToVehicle(with fetchModel: VehicleModel) -> AnyPublisher<CIImage, Error> {
                
        guard let image = getImage(from: fetchModel.parentImage)?.fixOrientation() else {
            return .fail(ImageError.orientationError)
        }
        
        guard var ciImg = CIImage(image: image) else {
            return .fail(ImageError.conversionError)
        }
        
        ciImg = ciImg.cropped(to: fetchModel.bbox.denormalized(to: image.size))
        let transform = CGAffineTransform(translationX: -ciImg.extent.origin.x, y: -ciImg.extent.origin.y)
        ciImg = ciImg.transformed(by: transform)
        
        let croppedImageSize = CGSize(width: ciImg.extent.width, height: ciImg.extent.height)
        
        let sizeForPlateDetector = self.getPlateDetectorSize(for: croppedImageSize)
        guard let ciImgResized = ciImg.resize(to: sizeForPlateDetector) else {
            return .fail(ImageError.resizeError)
        }
        
        return .just(ciImgResized)
    }

    
        
}


private extension PlateDetectorService {
    
    func getPlateDetectorSize(for originalSize: CGSize) -> CGSize {
                
        let originalW = originalSize.width
        let originalH = originalSize.height
        
        let ratio = max(originalH, originalW) / min(originalH, originalW)
        let side = Int(ratio * 288)
        let boundDim = CGFloat(min(side + (side%16),608))
        
        let minDimension = min(originalH, originalW)
        let factor = boundDim/minDimension
        
        var newW = Int(originalW * factor)
        var newH = Int(originalH * factor)
        
        if newW % 16 != 0 { newW += (16 - newW % 16) }
        if newH % 16 != 0 { newH += (16 - newH % 16) }
        
        let newSize = CGSize(width: newW, height: newH)
        
        return newSize
        
    }
    
    
    func getPlateDetectorSize(for ciImg: CIImage) -> CGSize {
                
        let originalW = ciImg.extent.width
        let originalH = ciImg.extent.height
        
        let ratio = max(originalH, originalW) / min(originalH, originalW)
        let side = Int(ratio * 288)
        let boundDim = CGFloat(min(side + (side%16),608))
        
        let minDimension = min(originalH, originalW)
        let factor = boundDim/minDimension
        
        var newW = Int(originalW * factor)
        var newH = Int(originalH * factor)
        
        if newW % 16 != 0 { newW += (16 - newW % 16) }
        if newH % 16 != 0 { newH += (16 - newH % 16) }
        
        let newSize = CGSize(width: newW, height: newH)
        
        return newSize
        
    }
    
    
    private func getPlateQuads(from observations: [VNCoreMLFeatureValueObservation]) -> [CGNormalizedQuad]? {
        var plateQuads = [CGNormalizedQuad]()
                
        let quadPtsFeatureValue = observations[1].featureValue
        let quadPtsMLMultiArray = quadPtsFeatureValue.multiArrayValue!
        let quadPtsArray = MultiArray<Float32>(quadPtsMLMultiArray)
                
        guard let plateQuad = multiArrayToNormalizedQuad(quadPtsArray) else {
            return nil
        }
        plateQuads.append(plateQuad)
        
        return plateQuads
    }
    
    
    private func extractPlateImage(from image: UIImage, for quad: CGNormalizedQuad, plateRegion: PlateRegion) -> UIImage? {
        guard let ciImg = CIImage(image: image) else {
            return nil
        }
        
        return extractPlateImage(from: ciImg, for: quad, plateRegion: plateRegion)
    }
    
    
    private func extractPlateImage(from image: CIImage, for quad: CGNormalizedQuad, plateRegion: PlateRegion) -> UIImage? {
        
        let outputHeight: Int = 90
        
        let imageWidth = image.extent.width
        let imageHeight = image.extent.height
        let imageSize = CGSize(width: imageWidth, height: imageHeight)
        let filter = CIFilter.perspectiveCorrection()
        
        let plateQuadDenorm = quad.denormalize(to: imageSize, withPadding: 3)
        
        filter.setValue(CIVector(cgPoint: plateQuadDenorm.tl), forKey: "inputTopLeft")
        filter.setValue(CIVector(cgPoint: plateQuadDenorm.tr), forKey: "inputTopRight")
        filter.setValue(CIVector(cgPoint: plateQuadDenorm.bl), forKey: "inputBottomLeft")
        filter.setValue(CIVector(cgPoint: plateQuadDenorm.br), forKey: "inputBottomRight")
        
        filter.inputImage = image.oriented(forExifOrientation: 4)
        guard let output = filter.outputImage else { return nil }
        
        let outputImg = UIImage(ciImage: output)
        let outputWidth = plateRegion.width(forHeight: outputHeight)
        let outputSize = CGSize(width: outputWidth, height: outputHeight)
        
        return outputImg.resized(to: outputSize)
    }
    
}
