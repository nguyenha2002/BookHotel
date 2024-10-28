//
//  Hotel.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 7/9/24.
//

import Foundation

struct HotelResponse: Decodable {
    let status: String
    let data: [Hotels]?
    let message: String?
}

struct Hotels: Decodable {
    let id: String
    let name: String
    let location: String
    let description: String
    let pricePerNight: Double
    let averageRating: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case description
        case pricePerNight = "price_per_night"
        case averageRating = "average_rating"
        case imageUrl = "image_url"
    }
}
