//
//  DynamicCacheManager.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/20/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class DynamicCacheManager {
    static var loadedImages: Dictionary<String,UIImage> = [:]
    
    static func getImage(url: String) -> UIImage{
        if let UIImage = loadedImages[url] {
            return UIImage
        } else {
            let image = UIImageView()
            image.setImageFromURl(stringImageUrl:url)
            loadedImages[url] = image.image
            return image.image!
        }
    }
}
