//
//  Review.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 10/9/24.
//

import Foundation

class Review {
    var avatar: String
    var username: String
    var stackStar: [String]
    var reviewDate: Date
    var review: String
    
    init(avatar: String, username: String, stackStar: [String], reviewDate: Date, review: String) {
        self.avatar = avatar
        self.username = username
        self.stackStar = stackStar
        self.reviewDate = reviewDate
        self.review = review
    }
}

struct ReviewsResponse: Decodable {
    let status: String
    let data: [Reviews]?
    let message: String?
}


struct Reviews: Decodable {
    let id: Int
    let userId: Int
    let rating: Int
    let review: String
    let createdAt: String
    let userInfo: UserInfo
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case rating
        case review
        case createdAt = "created_at"
        case userInfo
    }
}

struct UserInfo: Decodable {
    let username: String
    let avatar: String?
}
