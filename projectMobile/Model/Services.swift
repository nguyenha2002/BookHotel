//
//  Services.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 9/10/24.
//

import Foundation

struct ServicesResponse: Decodable {
    let status: String
    let data: [Services]?
    let message: String?
}

struct Services: Decodable {
    let id: Int
    let hotelId: Int
    let name: String
    let price: Double
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case hotelId = "hotel_id"
        case name
        case price
        case imageURL = "image_url"
    }
}
