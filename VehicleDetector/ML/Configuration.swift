//
//  Configuration.swift
//  DiffableCollectionViewTest
//
//  Created by Andrew Balmer on 5/22/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//
//  copied from https://github.com/CombineExtensions/CxVision/blob/499a8455c89c7ffd7479be99130b694c0ea38d1d/CxVision/Source/Configuration.swift


import Vision
import CoreImage

/// A struct for holding onto a configuration function to be applied to a `VNRequest`
///
/// The VNObservation type parameter is used for typecasting in the VNImageRequestHandler extension method `publisher(for:)`
/// to return a publisher that emits the expected VNObservation subclass. If you prefer to typecast at the callsite, a `SimpleConfiguration<A: VNRequest>`
/// typealias is provided
public struct Configuration<A: VNRequest, B: VNObservation> {
    let configure: (inout A) -> ()
    
    /// Configuration initializer
    /// - Parameter configuration: The configuration function to apply the to VNRequest.
    ///
    /// *An example Configuration initialization:*
    /// ```
    /// let recognizeTextConfig = Configuration<VNRecognizeTextRequest, VNRecognizedTextObservation> { request in
    ///   request.minimumTextHeight = 10.0
    ///   request.recognitionLevel = .fast
    ///   request.regionOfInterest = CGRect(origin: .zero, size: CGSize(width: 0.50, height: 0.50)
    ///   request.prefersBackgroundProcessing = true
    /// }
    /// ```
    public init(_ configuration: @escaping (inout A) -> ()) {
        configure = configuration
    }
}

public typealias SimpleConfiguration<A: VNRequest> = Configuration<A, VNObservation>

public extension Configuration where A == VNCoreMLRequest {
    init(model: VNCoreMLModel, _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(model: model, completionHandler: completionHandler)
            configuration(&request)
        }
    }
}

public extension Configuration where A == VNTrackRectangleRequest {
    init(rectangleObservation: VNRectangleObservation, _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(rectangleObservation: rectangleObservation, completionHandler: completionHandler)
            configuration(&request)
        }
    }
}

public extension Configuration where A == VNTrackObjectRequest {
    init(detectedObjectObservation: VNDetectedObjectObservation, _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(detectedObjectObservation: detectedObjectObservation, completionHandler: completionHandler)
            configuration(&request)
        }
    }
}

public extension Configuration where A: VNTargetedImageRequest {
    init(targetedCGImage: CGImage, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(targetedCGImage: targetedCGImage, orientation: orientation, options: options, completionHandler: completionHandler)
            configuration(&request)
        }
    }
    
    init(targetedCGImage: CGImage, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(targetedCGImage: targetedCGImage, options: options, completionHandler: completionHandler)
            configuration(&request)
        }
    }
    
    init(targetedCIImage: CIImage, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(targetedCIImage: targetedCIImage, orientation: orientation, options: options, completionHandler: completionHandler)
            configuration(&request)
        }
    }
    
    init(targetedCIImage: CIImage, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(targetedCIImage: targetedCIImage, options: options, completionHandler: completionHandler)
            configuration(&request)
        }
    }
    
    init(targetedCVPixelBuffer: CVPixelBuffer, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(targetedCVPixelBuffer: targetedCVPixelBuffer, orientation: orientation, options: options, completionHandler: completionHandler)
            configuration(&request)
        }
    }
    
    init(targetedCVPixelBuffer: CVPixelBuffer, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(targetedCVPixelBuffer: targetedCVPixelBuffer, options: options, completionHandler: completionHandler)
            configuration(&request)
        }
    }
    
    init(targetedImageData: Data, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(targetedImageData: targetedImageData, orientation: orientation, options: options, completionHandler: completionHandler)
            configuration(&request)
        }
    }
    
    init(targetedImageData: Data, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(targetedImageData: targetedImageData, options: options, completionHandler: completionHandler)
            configuration(&request)
        }
    }
    
    init(targetedImageURL: URL, options: [VNImageOption: Any] = [:], orientation: CGImagePropertyOrientation, _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(targetedImageURL: targetedImageURL, orientation: orientation, options: options, completionHandler: completionHandler)
            configuration(&request)
        }
    }
    
    init(targetedImageURL: URL, options: [VNImageOption: Any] = [:], _ configuration: @escaping (inout A) -> ()) {
        configure = { request in
            let completionHandler = request.completionHandler
            request = A(targetedImageURL: targetedImageURL, options: options, completionHandler: completionHandler)
            configuration(&request)
        }
    }
}
