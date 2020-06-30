//
//  VNImageRequestHandler+Ext.swift
//  DiffableCollectionViewTest
//
//  Created by Andrew Balmer on 5/22/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//
//  copied from https://github.com/CombineExtensions/CxVision/blob/499a8455c89c7ffd7479be99130b694c0ea38d1d/CxVision/Source/VNImageRequestHandler%2BCx.swift

import Vision
import Combine

enum VisionError: Error {
    case unexpectedResultType
}

public extension VNImageRequestHandler {
    /// Creates a publisher based on the provided Configuration
    /// - Parameter configuration: Configuration<A: VNRequest, B: VNObservation>.
    func publisher<Request: VNRequest, Observation: VNObservation>(for configuration: Configuration<Request, Observation>) -> AnyPublisher<[Observation], Error> {
        var requests = [VNRequest]()
        
        let visionFuture = Future<[Observation], Error> { promise in
            var visionRequest = Request { (request, error) in
                if let error = error { return promise(.failure(error)) }
                
                guard let results = request.results as? [Observation] else {
                    return promise(.failure(VisionError.unexpectedResultType))
                }
                
                return promise(.success(results))
            }
            
            configuration.configure(&visionRequest)
            requests.append(visionRequest)
        }
        
        let performPublisher = Future { promise in promise(Result { try self.perform(requests) }) }
        
        return performPublisher
            .combineLatest(visionFuture)
            .map { _, results in results }
            .eraseToAnyPublisher()
    }
    
    /// Creates a publisher that performs a collection of Vision operations.
    /// - Parameter requestTypes: The types of Vision requests to perform
    ///
    /// This is the only way to perform a batch of operations on the same request handler, which unfortunately does not support customization.
    func publisher(for requestTypes: [VNImageBasedRequest.Type]) -> AnyPublisher<[VNObservation], Error> {
        var requests = [VNImageBasedRequest]()
        
        let futures = Publishers.MergeMany<Future<[VNObservation], Error>>(
            requestTypes.map { requestType -> Future<[VNObservation], Error> in
                Future { promise in
                    let request = requestType.init { request, error in
                        if let error = error { return promise(.failure(error)) }
                        
                        guard let results = request.results as? [VNObservation] else {
                            return promise(.failure(VisionError.unexpectedResultType))
                        }
                        
                        return promise(.success(results))
                    }
                    requests.append(request)
                }
            }
        )
        
        let performPublisher = Future { promise in promise(Result { try self.perform(requests) }) }
        
        return performPublisher
            .combineLatest(futures)
            .map { _, results in results }
            .eraseToAnyPublisher()
    }
}
