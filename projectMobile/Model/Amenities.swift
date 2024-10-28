//
//  Amenities.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 30/9/24.
//

import Foundation

struct AmenitiesResponse: Decodable{
    let status: String
    let data: AmenitiesData
}
struct AmenitiesData: Decodable {
    let amenities: [Amenity]
}

struct Amenity: Decodable {
    let id: Int
    let nameAmenities: String
    let imgAmenities: String
}
