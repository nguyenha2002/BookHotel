//
//  Room.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 8/9/24.
//

import Foundation

struct RoomResponse: Decodable {
    let status: String
    let data: Room?
    let message: String?
}

struct RoomsResponse: Decodable {
    let status: String
    let data: RoomData?
    let message: String?
}

struct RoomData: Decodable {
    let rooms: [Room]
}

struct Room: Decodable {
    let id: Int
    let roomName: String
    let price: Double
    let area: Int
    let numberOfBeds: Int
    let numberOfBaths: Int
    let numberOfGuests: Int
    let status: String
    let roomType: String
    let hotelId: Int
    let detail: String
    let images: [String]
    let reviews: [Reviews]
    let reviewCount: Int?
    let amenities: String?
    var isFavorite: Bool
    let averageRating: String?
    let addressHotel: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomName = "room_name"
        case price
        case area
        case numberOfBeds = "number_of_beds"
        case numberOfBaths = "number_of_baths"
        case numberOfGuests = "number_of_guests"
        case status
        case roomType = "room_type"
        case hotelId = "hotel_id"
        case detail
        case images
        case reviews
        case reviewCount = "review_count"
        case amenities
        case isFavorite = "is_favorite"
        case averageRating = "average_rating"
        case addressHotel = "hotel_address"
    }
}

