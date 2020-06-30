//
//  Scheduler.swift
//  VehicleDetectorTest
//
//  Created by Andrew Balmer on 6/7/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//
//  Code adapted from https://github.com/sgl0v/TMDB


import Foundation
import Combine

final class Scheduler {

    static var backgroundScheduler = DispatchQueue.global()
    static let mainScheduler = DispatchQueue.main

}
