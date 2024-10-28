//
//  common.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 23/9/24.
//

import Foundation

struct APIConfig {
    static let baseURL = "http://localhost/BTap/api/v1/"
    
//    static let getHotelsURL = baseURL + "hotels.php"
    
    static let getHotelsURL = baseURL + "get_list_hotel.php"
    
    static let getAmenitiesURL = baseURL + "amenities.php"
    
    //lay danh sach tat ca cac phong trong scdl
    static let getRooms = baseURL + "get_rooms.php"
    
    static let getRoomsURL = baseURL + "get_list_room.php"
    
    static let getReviewsURL = baseURL + "get_reviews.php"
    
    static let login = baseURL + "login.php"
    
    static let registerUser = baseURL + "register_user.php"
    
    static let favorite_room = baseURL + "favorite_room.php"
    
    static let refreshToken = baseURL + "refresh_token.php"
    
    static let getServices = baseURL + "services.php"
    
    static let postReview = baseURL + "post_review.php"
    
    static let getUserId = baseURL + "get_userId.php"
    
    static let getInformationRoom = baseURL + "get_information_room.php"
    
    static let getFavoriteRooms = baseURL + "get_favorite_rooms.php"
    
    static let filter = baseURL + "filter.php"
}
