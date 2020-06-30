//
//  VisionTests.swift
//  VehicleDetectorTests
//
//  Created by Andrew Balmer on 6/11/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import XCTest
import CoreML
@testable import VehicleDetector


class MultiArrayWrapperTests: XCTestCase {
    
    // MARK: Properties & Setup
    let data = [[0.1795451,0.2992343,0.2790133,0.1593242],
                [0.3373274,0.3739613,0.4837797,0.4471458]]
    
    lazy var mockMultiArray: MLMultiArray = {
        let multiArray = try! MLMultiArray(shape: [2, 4], dataType: MLMultiArrayDataType.float32)
        let flattened = data.flatMap { $0 }
        
        var i = 0
        flattened.forEach({
            multiArray[i] = NSNumber(value: $0)
            i += 1
        })
        
        return multiArray
    }()
        

    // MARK: Tests
    func test_multiArrayWrapper_count() {
        let wrappedMultiArray = MultiArray<Float32>(mockMultiArray)
        let count = wrappedMultiArray.count
        
        XCTAssertEqual(count, 8)
    }
    
    
    func test_multiArrayWrapper_array() {
        let wrappedMultiArray = MultiArray<Float32>(mockMultiArray)
        let array = wrappedMultiArray.array
        
        XCTAssertTrue(array is MLMultiArray)
    }

    
    func test_multiArrayWrapper_shape() {
        let wrappedMultiArray = MultiArray<Float32>(mockMultiArray)
        let shape = wrappedMultiArray.shape
        
        let expectedResult = [2, 4]

        XCTAssertEqual(shape, expectedResult)
    }
    
    
    func test_createNewMultiArray() {
        var wrappedMultiArray = MultiArray<Float32>(shape: [2, 4])
        let flattenedData = data.flatMap { $0 }
        
        var i = 0
        flattenedData.forEach {
            wrappedMultiArray[i] = Float($0)
            i += 1
        }
        
        XCTAssertEqual(wrappedMultiArray.array, mockMultiArray)
    }
}


class MultiArrayToQuadTests: XCTestCase {
    
    // MARK: Properties & Setup
    let data = [[0.1795451,0.2992343,0.2790133,0.1593242],
                [0.3373274,0.3739613,0.4837797,0.4471458]]
    
    lazy var mockMultiArray: MultiArray<Float> = {
        var wrappedMultiArray = MultiArray<Float32>(shape: [2, 4])
        let flattenedData = data.flatMap { $0 }
        
        var i = 0
        flattenedData.forEach {
            wrappedMultiArray[i] = Float($0)
            i += 1
        }
        
        return wrappedMultiArray
    }()
    
    
    // MARK: Tests
    func test_multiArrayToNormalizedQuad_notNil() {
        let normalizedQuad = multiArrayToNormalizedQuad(mockMultiArray)
        XCTAssertNotNil(normalizedQuad)
    }
    
    
    func test_multiArrayToNormalizedQuad() {
        let normalizedQuad = multiArrayToNormalizedQuad(mockMultiArray)
        
        let expectedResult = CGNormalizedQuad(
            tl: CGPoint(x: 0.1795451045036316, y: 0.33732739090919495),
            tr: CGPoint(x: 0.2992343008518219, y: 0.37396129965782166),
            br: CGPoint(x: 0.2790133059024811, y: 0.4837796986103058),
            bl: CGPoint(x: 0.15932419896125793, y: 0.4471457898616791))
        
        XCTAssertEqual(normalizedQuad, expectedResult)
    }
    
}
