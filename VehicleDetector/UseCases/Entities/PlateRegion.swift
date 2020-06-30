//
//  PlateRegion.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/18/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation


enum PlateRegion {
    case usa
    case europe
    
    // width-to-height ratio
    var ratio: Double {
        switch self {
        case .usa:
            return 2/1
        case .europe:
            return 520/110
        }
    }
    
    public func width(forHeight height: Int) -> Int {
        let width = Double(height) * self.ratio
        return Int(width)
    }
    
    public func height(forWidth width: Int) -> Int {
        let height = Double(width) / self.ratio
        return Int(height)
    }
}
