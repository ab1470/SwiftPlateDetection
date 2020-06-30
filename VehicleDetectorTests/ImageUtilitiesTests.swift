//
//  VehicleDetectorTests.swift
//  VehicleDetectorTests
//
//  Created by Andrew Balmer on 6/9/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import XCTest
@testable import VehicleDetector


private protocol CIImageTestable where Self: XCTestCase {
    var testCIImage: CIImage! { get set }
    
    func setUp()
}

private protocol UIImageTestable where Self: XCTestCase {
    var testUIImage: UIImage! { get set }
    
    func setUp()
}


// MARK: - CIImageUtilities
class CIImageUtilitiesTests: XCTestCase, CIImageTestable {
    var testCIImage: CIImage!
    
    override func setUp() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "TestImages/FullImages/TestFullImage1", ofType: "jpeg"),
            let img = UIImage(contentsOfFile: path) else {
            XCTFail("unable to load the test image"); return
        }
        testCIImage = CIImage(image: img)
    }
    
    
    func test_CIImage_resize_extension_returns_not_nil() {
        let newSize = CGSize(width: 500, height: 500)
        
        XCTAssertNotNil(testCIImage.resize(to: newSize))
    }
    
    
    func test_CIImage_resize_extension_returns_correct_size() {
        let newSize = CGSize(width: 500, height: 350)
        
        guard let resizedCIImage = testCIImage.resize(to: newSize) else {
            XCTFail("the resize method failed"); return
        }
        let outputSize = CGSize(width: resizedCIImage.extent.width, height: resizedCIImage.extent.height)
        
        XCTAssertEqual(outputSize, newSize)
    }
    
    
    func test_CIImage_resize_extension_returns_correct_size_with_nonzero_origin() {
        let newSize = CGSize(width: 500, height: 350)
        
        let transform = CGAffineTransform(translationX: 100, y: 100)
        let ciImg = testCIImage.transformed(by: transform)
        
        guard let resizedCIImage = ciImg.resize(to: newSize) else {
            XCTFail("the resize method failed"); return
        }
        let outputSize = CGSize(width: resizedCIImage.extent.width, height: resizedCIImage.extent.height)
        
        XCTAssertEqual(outputSize, newSize)
    }

}


// MARK: - UIImageUtilities
class UIImageUtilitiesTests: XCTestCase, UIImageTestable {
    var testUIImage: UIImage!
    
    override func setUp() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "TestImages/FullImages/TestFullImage1", ofType: "jpeg"),
            let img = UIImage(contentsOfFile: path) else {
            XCTFail("unable to load the test image"); return
        }
        testUIImage = img
    }
    
    
    func test_UIImage_fixOrientation_notNil() {
        let newImage = UIImage(cgImage: testUIImage.cgImage!, scale: testUIImage.scale, orientation: .leftMirrored)
        XCTAssertNotNil(newImage.fixOrientation())
    }
    
    
    func test_UIImage_fixOrientation() {
        let newImage = UIImage(cgImage: testUIImage.cgImage!, scale: testUIImage.scale, orientation: .leftMirrored)
        guard let orientedImage = newImage.fixOrientation() else { XCTFail("the `fixOrientation()` method returned nil"); return }
        XCTAssertEqual(orientedImage.imageOrientation, UIImage.Orientation.up)
    }
    
    
    func test_UIImage_resize_extension_returns_correct_size() {
        let newSize = CGSize(width: 500, height: 350)
        let resizedUIImage = testUIImage.resized(to: newSize)
        XCTAssertEqual(resizedUIImage.size, newSize)
    }
    
    
    func test_UIImage_downsample() {
        let newSize = CGSize(width: 500, height: 350)
        let resizedUIImage = testUIImage.downsample(to: newSize, scale: 1.0)
        XCTAssertEqual(resizedUIImage.size, newSize)
    }
    
    
    func test_UIImage_downsample_scaleAspectFit() {
        let newSize = CGSize(width: 500, height: 300)
        let resizedUIImage = testUIImage.downsample(to: newSize, scale: 1.0, contentMode: .scaleAspectFit)
        
        let expectedSize = CGSize(width: 400, height: 300)
        
        XCTAssertEqual(resizedUIImage.size, expectedSize)
    }
    
    
    func test_UIImageView_contentClippingRect() {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 400, height: 400)))
        imageView.image = testUIImage
        imageView.contentMode = .scaleAspectFit
        
        let expectedRect = CGRect(x: 0, y: 50, width: 400, height: 300)
        
        let contentClippingRect = imageView.contentClippingRect
        
        XCTAssertEqual(contentClippingRect, expectedRect)
    }

}
