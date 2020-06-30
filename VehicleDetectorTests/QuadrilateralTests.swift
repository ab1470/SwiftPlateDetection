//
//  QuadrilateralTests.swift
//  VehicleDetectorTests
//
//  Created by Andrew Balmer on 6/9/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import XCTest
import CoreML
@testable import VehicleDetector


class QuadrilateralTests: XCTestCase {
    
    // MARK: Properties
    lazy var normalizedQuad = {
        return CGNormalizedQuad(
            tl: CGPoint(x: 0.20, y: 0.20),
            tr: CGPoint(x: 0.80, y: 0.40),
            br: CGPoint(x: 0.60, y: 0.80),
            bl: CGPoint(x: 0.40, y: 0.60)
        )
    }()
    
    lazy var quad = {
        return CGQuad(
            tl: CGPoint(x: 20, y: 20),
            tr: CGPoint(x: 80, y: 10),
            br: CGPoint(x: 90, y: 80),
            bl: CGPoint(x: 30, y: 70)
        )
    }()
    
    
    // MARK: Tests
    func test_CGQuad_centroid() {
        let centroid = quad.centroid()
        let expectedResult = CGPoint(x: 55, y: 45)
        
        XCTAssertEqual(centroid, expectedResult)
    }
    
    
    func test_CGNormalizedQuad_centroid() {
        let centroid = normalizedQuad.centroid()
        let expectedResult = CGPoint(x: 0.5, y: 0.5)
                
        XCTAssertEqual(centroid, expectedResult)
    }
    
    
    func test_CGQuad_points() {
        let points = quad.points()
        let expectedResult = [
            CGPoint(x: 20, y: 20),
            CGPoint(x: 80, y: 10),
            CGPoint(x: 90, y: 80),
            CGPoint(x: 30, y: 70)
        ]
        
        XCTAssertEqual(points, expectedResult)
    }
    
    
    /// The `Quadrilateral` protocol conforms to `Equatable`. This test is to ensure that that when two equivalent `CGQuad`s are compared with the `==` operator, the result is `true`.
    func test_CGQuad_equatable() {
        let quad1 = CGQuad(
            tl: CGPoint(x: 20, y: 20),
            tr: CGPoint(x: 80, y: 10),
            br: CGPoint(x: 90, y: 80),
            bl: CGPoint(x: 30, y: 70)
        )
        
        let quad2 = CGQuad(
            tl: CGPoint(x: 20, y: 20),
            tr: CGPoint(x: 80, y: 10),
            br: CGPoint(x: 90, y: 80),
            bl: CGPoint(x: 30, y: 70)
        )
        
        let equal = quad1 == quad2
        
        XCTAssertTrue(equal, "`quad1 == quad2` return `true`, but it does not.")
    }
    
    
    func test_CGQuad_initWithRect() {
        let rect = CGRect(origin: .zero, size: CGSize(width: 40, height: 60))
        let quad = CGQuad(with: rect)
        
        let expectedResult = CGQuad(
            tl: CGPoint(x: 0, y: 0),
            tr: CGPoint(x: 40, y: 0),
            br: CGPoint(x: 40, y: 60),
            bl: CGPoint(x: 0, y: 60)
        )
        
        XCTAssertEqual(quad, expectedResult)
    }
    
    
    func test_CGNormalizedQuad_denormalizeToSize() {
        let size = CGSize(width: 100, height: 200)
        let denormalized = normalizedQuad.denormalize(to: size)
                
        let expectedResult = CGQuad(
            tl: CGPoint(x: 20, y: 40),
            tr: CGPoint(x: 80, y: 80),
            br: CGPoint(x: 60, y: 160),
            bl: CGPoint(x: 40, y: 120)
        )
                
        XCTAssertEqual(denormalized, expectedResult)
    }
    
    
    func test_CGNormalizedQuad_denormalizeToSizeWithPadding() {
        let size = CGSize(width: 100, height: 200)
        let denormalized = normalizedQuad.denormalize(to: size, withPadding: 5)
                
        let expectedResult = CGQuad(
            tl: CGPoint(x: 15, y: 35),
            tr: CGPoint(x: 85, y: 75),
            br: CGPoint(x: 65, y: 165),
            bl: CGPoint(x: 35, y: 125)
        )
                
        XCTAssertEqual(denormalized, expectedResult)
    }
    
    
    func test_CGNormalizedQuad_denormalizeToRect() {
        let rect = CGRect(x: 20, y: 0, width: 100, height: 200)
        let denormalized = normalizedQuad.denormalize(to: rect)
                
        let expectedResult = CGQuad(
            tl: CGPoint(x: 40, y: 40),
            tr: CGPoint(x: 100, y: 80),
            br: CGPoint(x: 80, y: 160),
            bl: CGPoint(x: 60, y: 120)
        )
                
        XCTAssertEqual(denormalized, expectedResult)
    }
    
    
    func test_CGNormalizedQuad_denormalizeToRectWithPadding() {
        let rect = CGRect(x: 20, y: 0, width: 100, height: 200)
        let denormalized = normalizedQuad.denormalize(to: rect, withPadding: 5)
                
        let expectedResult = CGQuad(
            tl: CGPoint(x: 35, y: 35),
            tr: CGPoint(x: 105, y: 75),
            br: CGPoint(x: 85, y: 165),
            bl: CGPoint(x: 55, y: 125)
        )
                
        XCTAssertEqual(denormalized, expectedResult)
    }
    
    
    func test_CGQuad_Expand_0() {
        let offsetQuad = quad.expand(by: 0)
                
        let expectedResult = CGQuad(
            tl: CGPoint(x: 20, y: 20),
            tr: CGPoint(x: 80, y: 10),
            br: CGPoint(x: 90, y: 80),
            bl: CGPoint(x: 30, y: 70)
        )
                        
        XCTAssertEqual(offsetQuad, expectedResult)
    }
    
    
    func test_CGQuad_Expand_5() {
        let offsetQuad = quad.expand(by: 5)
                
        let expectedResult = CGQuad(
            tl: CGPoint(x: 14.0, y: 16.0),
            tr: CGPoint(x: 84.0, y: 4.0),
            br: CGPoint(x: 96.0, y: 86.0),
            bl: CGPoint(x: 26.0, y: 74.0)
        )
        
        XCTAssertEqual(offsetQuad, expectedResult)
    }
    
    
    func test_quadrant_tl() {
        let tlNormalizedQuad = CGNormalizedQuad(
            tl: CGPoint(x: 0.20, y: 0.20),
            tr: CGPoint(x: 0.50, y: 0.20),
            br: CGPoint(x: 0.50, y: 0.60),
            bl: CGPoint(x: 0.20, y: 0.60)
        )
        
        let quadrant = tlNormalizedQuad.quadrant()
        
        XCTAssertEqual(quadrant, Quadrant.topLeft)
    }
    
    
    func test_quadrant_tr() {
        let tlNormalizedQuad = CGNormalizedQuad(
            tl: CGPoint(x: 0.50, y: 0.00),
            tr: CGPoint(x: 0.90, y: 0.10),
            br: CGPoint(x: 0.90, y: 0.50),
            bl: CGPoint(x: 0.40, y: 0.50)
        )
        
        let quadrant = tlNormalizedQuad.quadrant()
        
        XCTAssertEqual(quadrant, Quadrant.topRight)
    }
    
    
    func test_quadrant_br() {
        let tlNormalizedQuad = CGNormalizedQuad(
            tl: CGPoint(x: 0.50, y: 0.50),
            tr: CGPoint(x: 0.90, y: 0.50),
            br: CGPoint(x: 0.90, y: 0.90),
            bl: CGPoint(x: 0.50, y: 0.90)
        )
        
        let quadrant = tlNormalizedQuad.quadrant()
        
        XCTAssertEqual(quadrant, Quadrant.bottomRight)
    }
    
    
    func test_quadrant_bl() {
        let tlNormalizedQuad = CGNormalizedQuad(
            tl: CGPoint(x: 0.10, y: 0.50),
            tr: CGPoint(x: 0.60, y: 0.50),
            br: CGPoint(x: 0.60, y: 0.90),
            bl: CGPoint(x: 0.10, y: 0.90)
        )
        
        let quadrant = tlNormalizedQuad.quadrant()
        
        XCTAssertEqual(quadrant, Quadrant.bottomLeft)
    }
    
}


