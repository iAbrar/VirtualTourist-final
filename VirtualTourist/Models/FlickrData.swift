//
//  flickrData.swift
//  VirtualTourist
//
//  Created by imac on 8/20/20.
//  Copyright © 2020 Abrar. All rights reserved.
//

import Foundation

struct FlickrData: Decodable{
    let stat: String
    let photos: Images
}

struct Images: Decodable {
    let page: Int
    let total: String
    let photo: [Image]
}

struct Image: Decodable {
    let id: String
    let url_m: String
}
