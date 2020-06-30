//
//  LicensePlateTests.swift
//  VehicleDetectorTests
//
//  Created by Andrew Balmer on 6/18/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import XCTest
@testable import VehicleDetector


class LicensePlateTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    
    // MARK: - Tests
    func test_PlateRegion_europe_width() throws {
        let europeanPlate = PlateRegion.europe
        let plateRatio = europeanPlate.ratio
        
        let outputWidth = europeanPlate.width(forHeight: 100)
        let expectedResult = Int(100 * plateRatio)
        
        XCTAssertEqual(outputWidth, expectedResult)
    }
    
    
    func test_PlateRegion_europe_height() throws {
        let europeanPlate = PlateRegion.europe
        let plateRatio = europeanPlate.ratio
        
        let outputHeight = europeanPlate.height(forWidth: 500)
        let expectedResult = Int(500 / plateRatio)
        
        XCTAssertEqual(outputHeight, expectedResult)
    }
    
    
    func test_PlateRegion_usa_width() throws {
        let usaPlate = PlateRegion.usa
        let plateRatio = usaPlate.ratio
        
        let outputWidth = usaPlate.width(forHeight: 100)
        let expectedResult = Int(100 * plateRatio)
        
        XCTAssertEqual(outputWidth, expectedResult)
    }
    
    
    func test_PlateRegion_usa_height() throws {
        let usaPlate = PlateRegion.usa
        let plateRatio = usaPlate.ratio
        
        let outputHeight = usaPlate.height(forWidth: 500)
        let expectedResult = Int(500 / plateRatio)
        
        XCTAssertEqual(outputHeight, expectedResult)
    }

}
