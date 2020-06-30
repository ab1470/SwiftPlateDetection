//
//  VehicleDetectorTests.swift
//  VehicleDetectorTests
//
//  Created by Andrew Balmer on 6/18/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import XCTest
import Combine
@testable import VehicleDetector


class VehicleDetectorServiceTests: XCTestCase {

    // MARK: Setup
    var vehicleDetector: VehicleDetectorService!
    var urls: [URL]!
    var blankImageUrl: URL!
    
    override func setUpWithError() throws {
        vehicleDetector = VehicleDetectorService()
        
        let bundle = Bundle(for: type(of: self))
        guard let urls = bundle.urls(forResourcesWithExtension: "jpeg", subdirectory: "TestImages/FullImages"),
            urls.count > 0 else {
                XCTFail("unable to load the URLs for the test images")
                return
        }
        
        guard let blankImageUrl = bundle.url(forResource: "TestImages/TestBlankImage", withExtension: "jpeg") else {
            XCTFail("Missing file: TestBlankImage.jpeg")
            return
        }
        
        self.urls = urls
        self.blankImageUrl = blankImageUrl
    }


    // MARK: Tests
    func test_detectVehicless_badImageUrl() {
        let badUrl = URL(fileURLWithPath: "badurl")
        let publisher = vehicleDetector.detectVehicles(in: badUrl)
        
        _ = publisher.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                XCTFail("The publisher should have returned a failure")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, FileError.cannotLoadFile.localizedDescription)
            }
        }, receiveValue: { value in
            XCTFail("the publisher should not have emitted a value")
        })
    }
    
    
    func test_detectVehicles_oneVehicleInImage() {
        guard let url = urls.first else { XCTFail("unable to find a valid test url"); return }
        let publisher = vehicleDetector.detectVehicles(in: url)
        
        _ = publisher.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                XCTFail("detectVehicles() function failed: \(error)")
            }
        }, receiveValue: { imageModel in
            XCTAssertEqual(imageModel.vehicleModels.count, 1)
        })

    }
    
    
    /// When `detectVehicles` is run on an image that has no vehicles in it, it should return an `ImageModel` object with zero `VehicleModel`s. 
    func test_detectVehicles_noVehiclesInImage() {
        let publisher = vehicleDetector.detectVehicles(in: blankImageUrl)
        
        _ = publisher.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                XCTFail("detectVehicles() function failed: \(error)")
            }
        }, receiveValue: { imageModel in
            XCTAssertEqual(imageModel.vehicleModels.count, 0)
        })
    }
    
    
    /// When `detectVehicles` is run on an image that has no vehicles in it, it should still return an `ImageModel` object with the correct image URL
    func test_detectVehicles_noVehiclesInImage_correctImageUrl() {
        let publisher = vehicleDetector.detectVehicles(in: blankImageUrl)

        _ = publisher.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                XCTFail("detectVehicles() function failed: \(error)")
            }
        }, receiveValue: { imageModel in
            XCTAssertEqual(imageModel.imageUrl.lastPathComponent, "TestBlankImage.jpeg")
        })
    }
    
}


class VehicleDetectorUseCaseTests: XCTestCase {

    // MARK: Setup
    let useCase: VehicleDetectorUseCase = {
        let vehicleDetector = VehicleDetectorService()
        return VehicleDetectorUseCase(vehicleDetectorService: vehicleDetector)
    }()
    var urls: [URL]!
    var blankImageUrl: URL!
    
    override func setUpWithError() throws {
        let bundle = Bundle(for: type(of: self))
        guard let urls = bundle.urls(forResourcesWithExtension: "jpeg", subdirectory: "TestImages/FullImages"),
            urls.count > 0 else {
                XCTFail("unable to load the URLs for the test images")
                return
        }
        
        guard let blankImageUrl = bundle.url(forResource: "TestImages/TestBlankImage", withExtension: "jpeg") else {
            XCTFail("Missing file: TestBlankImage.jpeg")
            return
        }
        
        self.urls = urls
        self.blankImageUrl = blankImageUrl
    }


    // MARK: Tests
    func test_detectVehicles() {
        let expectation = XCTestExpectation(description: "detect vehicles in images")
        
        let publisher = useCase.detectVehicles(inImagesAt: urls)
        
        _ = publisher.sink(receiveValue: { imageModels in
            XCTAssertEqual(imageModels.count, self.urls.count)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    
    func test_detectVehicles_badUrlGetsSkipped() {
        let expectation = XCTestExpectation(description: "detect vehicles in images")
        
        let badUrl = URL(fileURLWithPath: "badurl")
        urls.insert(badUrl, at: 2)
        
        let publisher = useCase.detectVehicles(inImagesAt: urls)

        _ = publisher.sink(receiveValue: { imageModels in
            XCTAssertEqual(imageModels.count, (self.urls.count - 1) )
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    
    func test_detectVehicles_subscribeOnBackgroundThread() {
        let expectation = XCTestExpectation(description: "detect vehicles in images")
        
        let publisher = useCase.detectVehicles(inImagesAt: urls)
            .handleEvents(receiveSubscription: { aValue in
                XCTAssertFalse(Thread.isMainThread, "the publisher should be subscribed on a background thread")
            })
        _ = publisher.sink(receiveValue: { imageModels in
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    
    func test_detectVehicles_receiveOnMainThread() {
        let expectation = XCTestExpectation(description: "detect vehicles in images")
        
        let publisher = useCase.detectVehicles(inImagesAt: urls)
        
        _ = publisher.sink(receiveValue: { imageModels in
            XCTAssertTrue(Thread.isMainThread, "the subscriber should receive the result on the main thread")
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    
}


class ImageProcessorViewModelTests: XCTestCase {

    // MARK: Setup
    let viewModel: VehicleDetectorViewModel = {
        let vehicleDetector = VehicleDetectorService()
        let useCase = VehicleDetectorUseCase(vehicleDetectorService: vehicleDetector)
        return VehicleDetectorViewModel(useCase: useCase)
    }()
    var urls: [URL]!
    var blankImageUrl: URL!
    
    var cancellables: [AnyCancellable] = []
    let detectVehicles = PassthroughSubject<[URL], Never>()
    var output: VehicleDetectorViewModelOuput!
    
    override func setUpWithError() throws {
        let bundle = Bundle(for: type(of: self))
        guard let urls = bundle.urls(forResourcesWithExtension: "jpeg", subdirectory: "TestImages/FullImages"),
            urls.count > 0 else {
                XCTFail("unable to load the URLs for the test images")
                return
        }
        
        guard let blankImageUrl = bundle.url(forResource: "TestImages/TestBlankImage", withExtension: "jpeg") else {
            XCTFail("Missing file: TestBlankImage.jpeg")
            return
        }
        
        self.urls = urls
        self.blankImageUrl = blankImageUrl
        
        let input = VehicleDetectorViewModelInput(detectVehicles: detectVehicles.eraseToAnyPublisher())
        self.output = viewModel.transform(input: input)
    }
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }


    // MARK: Tests
    func test_detectVehicles_publishesLoading() {
        let expectLoading = XCTestExpectation(description: "the publisher should publish a '.loading' value")
                
        _ = output.sink(receiveValue: { state in
            switch state {
            case .loading:
                expectLoading.fulfill()
            case .success(_):
                break
            default:
                XCTFail("the publisher should only publish a .loading value and a .success value")
            }
        }).store(in: &cancellables)

        detectVehicles.send(urls)
        
        wait(for: [expectLoading], timeout: 5.0)
    }
    
    
    func test_detectVehicles_publishesSuccess() {
        let expectSuccess = XCTestExpectation(description: "the publisher should publish a '.success' value")
                
        _ = output.sink(receiveValue: { state in
            switch state {
            case .loading:
                break
            case .success(_):
                expectSuccess.fulfill()
            default:
                XCTFail("the publisher should only publish a .loading value and a .success value")
            }
        }).store(in: &cancellables)

        detectVehicles.send(urls)
        
        wait(for: [expectSuccess], timeout: 5.0)
    }
    
    
    func test_detectVehicles_withEmptyInput() {
        let expectation = XCTestExpectation(description: "the publisher should publish a '.noResults' value")
                
        _ = output.sink(receiveValue: { state in
            switch state {
            case .noResults:
                expectation.fulfill()
            default:
                XCTFail("the publisher should only publish a .noResults value")
            }
        }).store(in: &cancellables)

        detectVehicles.send([])
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    func test_detectVehicles_withBlankImageInput() {
        let expectLoading = XCTestExpectation(description: "the publisher should publish a '.loading' value")
        let expectSuccess = XCTestExpectation(description: "the publisher should publish a '.noResults' value")
                
        _ = output.sink(receiveValue: { state in
            switch state {
            case .loading:
                expectLoading.fulfill()
            case .success(let imageModels):
                XCTAssertEqual(imageModels.count, 1)
                XCTAssertEqual(imageModels.first?.plateDetectorVMs.count, 0)
                expectSuccess.fulfill()
            default:
                XCTFail("the publisher should only publish a .loading value and a .success value")
            }
        }).store(in: &cancellables)

        detectVehicles.send([blankImageUrl])
        
        wait(for: [expectLoading, expectSuccess], timeout: 5.0)
    }
    
}
