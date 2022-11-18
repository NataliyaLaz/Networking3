//
//  ImageProperties.swift
//  Networking3
//
//  Created by Nataliya Lazouskaya on 18.11.22.
//

import UIKit

struct ImageProperties {
    let key: String
    let data: Data
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        guard let data = image.pngData() else { return nil}
        self.data = data
    }
}
