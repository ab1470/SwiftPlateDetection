//
//  VehicleDetectorTests.swift
//  VehicleDetectorTests
//
//  Created by Andrew Balmer on 6/9/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import XCTest
@testable import VehicleDetector


class GeometryUtilitiesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_CGRect_denormalized() {
        let normalizedRect = CGRect(x: 0.5, y: 0.5, width: 0.75, height: 0.25)
        let sizeOfTargetObject = CGSize(width: 400, height: 600)
        
        let expectedResult = CGRect(x: 200, y: 300, width: 300, height: 150)
        
        let denormalizedRect = normalizedRect.denormalized(to: sizeOfTargetObject)
        XCTAssertEqual(denormalizedRect, expectedResult)
    }
    
    func test_CGPoint_denormalized() {
        let originalPoint = CGPoint(x: 0.25, y: 0.75)
        let sizeOfTargetObject = CGSize(width: 400, height: 600)
        
        let expectedResult = CGPoint(x: 100, y: 450)
        
        let scaledPoint = originalPoint.denormalized(to: sizeOfTargetObject)
        XCTAssertEqual(scaledPoint, expectedResult)
    }
    
    func test_CGPoint_normalized() {
        let originalPoint = CGPoint(x: 50, y: 300)
        let sizeOfTargetObject = CGSize(width: 200, height: 400)
        
        let expectedResult = CGPoint(x: 0.25, y: 0.75)
        
        let scaledPoint = originalPoint.normalized(to: sizeOfTargetObject)
        XCTAssertEqual(scaledPoint, expectedResult)
    }
    
    func test_ConvexHull() {
        let points = [
            CGPoint(x: 1, y: 1),
            CGPoint(x: 2, y: 1),
            CGPoint(x: 3, y: 1),
            CGPoint(x: 3, y: 2),
            CGPoint(x: 4, y: 0)
        ]
        
        let expectedResult = [
            CGPoint(x: 1, y: 1),
            CGPoint(x: 4, y: 0),
            CGPoint(x: 3, y: 2)
        ]

        let hullPoints = convexHull(points)
        XCTAssertEqual(hullPoints, expectedResult)
    }

}
