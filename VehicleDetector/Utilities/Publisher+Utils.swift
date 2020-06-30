//
//  Publisher+Utils.swift
//  VehicleDetectorTest
//
//  Created by Andrew Balmer on 6/1/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//
//  Lightly adapted from TMBD project by Maksym Shcheglov
//  https://www.onswiftwings.com/posts/mvvm-with-combine/
//  https://github.com/sgl0v/TMDB


import Foundation
import Combine


extension Publisher {
    
    static func empty() -> AnyPublisher<Output, Failure> {
        return Empty().eraseToAnyPublisher()
    }
    
    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        return Just(output)
            .catch { _ in AnyPublisher<Output, Failure>.empty() }
            .eraseToAnyPublisher()
    }
    
    static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        return Fail(error: error).eraseToAnyPublisher()
    }
}
