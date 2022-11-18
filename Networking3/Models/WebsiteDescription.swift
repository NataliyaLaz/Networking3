//
//  WebsiteDescription.swift
//  Networking3
//
//  Created by Nataliya Lazouskaya on 17.11.22.
//

import Foundation

struct WebsiteDescription: Decodable {
    let websiteDescription: String?
    let websiteName: String?
    let courses: [Course]
}
