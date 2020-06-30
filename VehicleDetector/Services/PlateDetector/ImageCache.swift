//
//  ImageCache.swift
//  VehicleDetector
//
//  Created by Andrew Balmer on 6/25/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//
//  Code lightly adapted from https://www.onswiftwings.com/posts/reusable-image-cache/


import UIKit
import ImageIO

// Declares in-memory image cache
protocol ImageCacheType: class {
    // Returns the image associated with a given UUID
    func image(for id: UUID) -> UIImage?
    // Inserts the image of the specified UUID in the cache
    func insertImage(_ image: UIImage?, for id: UUID)
    // Removes the image of the specified UUID in the cache
    func removeImage(for id: UUID)
    // Removes all images from the cache
    func removeAllImages()
    // Accesses the value associated with the given key for reading and writing
    subscript(_ id: UUID) -> UIImage? { get set }
}

final class ImageCache: ImageCacheType {

    // 1st level cache, that contains encoded images
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = config.countLimit
        return cache
    }()
    // 2nd level cache, that contains decoded images
    private lazy var decodedImageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = config.memoryLimit
        return cache
    }()
    private let lock = NSLock()
    private let config: Config

    struct Config {
        let countLimit: Int
        let memoryLimit: Int

        static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
    }

    init(config: Config = Config.defaultConfig) {
        self.config = config
    }

    func image(for id: UUID) -> UIImage? {
        lock.lock(); defer { lock.unlock() }
        // the best case scenario -> there is a decoded image in memory
        if let decodedImage = decodedImageCache.object(forKey: id as AnyObject) as? UIImage {
            return decodedImage
        }
        // search for image data
        if let image = imageCache.object(forKey: id as AnyObject) as? UIImage {
            let decodedImage = image.decodedImage()
            decodedImageCache.setObject(image as AnyObject, forKey: id as AnyObject, cost: decodedImage.diskSize)
            return decodedImage
        }
        return nil
    }

    func insertImage(_ image: UIImage?, for id: UUID) {
        guard let image = image else { return removeImage(for: id) }
        let decompressedImage = image.decodedImage()

        lock.lock(); defer { lock.unlock() }
        imageCache.setObject(decompressedImage, forKey: id as AnyObject, cost: 1)
        decodedImageCache.setObject(image as AnyObject, forKey: id as AnyObject, cost: decompressedImage.diskSize)
    }

    func removeImage(for id: UUID) {
        lock.lock(); defer { lock.unlock() }
        imageCache.removeObject(forKey: id as AnyObject)
        decodedImageCache.removeObject(forKey: id as AnyObject)
    }

    func removeAllImages() {
        lock.lock(); defer { lock.unlock() }
        imageCache.removeAllObjects()
        decodedImageCache.removeAllObjects()
    }

    subscript(_ key: UUID) -> UIImage? {
        get {
            return image(for: key)
        }
        set {
            return insertImage(newValue, for: key)
        }
    }
}

fileprivate extension UIImage {

    func decodedImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        self.draw(at: CGPoint.zero)
        UIGraphicsEndImageContext()
        return self
    }

    // Rough estimation of how much memory image uses in bytes
    var diskSize: Int {
        guard let cgImage = cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}


