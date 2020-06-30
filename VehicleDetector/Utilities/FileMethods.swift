//
//  File.swift
//  DiffableCollectionViewTest
//
//  Created by Andrew Balmer on 5/20/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit


public func getImage(from url: URL) -> UIImage? {
    guard let imgData = try? Data(contentsOf: url),
        let image = UIImage(data: imgData) else { return nil }
    
    return image
}


func getImageUrls(inDirectory directory: String) -> [URL] {
    let imageExtensions = ["jpg", "jpeg", "png", "json", "heif"]
    let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: directory)?.filter {
        imageExtensions.contains($0.pathExtension)
    }

    guard let imageUrls = urls else { return [] }
    return imageUrls
}
