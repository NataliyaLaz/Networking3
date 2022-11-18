//
//  Course.swift
//  Networking3
//
//  Created by Nataliya Lazouskaya on 17.11.22.
//

import Foundation

struct Course: Decodable {
    let id: Int?
    let name: String?
    let link: String?
    let imageUrl: String?
    let numberOfLessons: Int?
    let numberOfTests: Int?
}
