//
//  LoginResponse.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 3/10/24.
//

import Foundation

struct LoginResponse: Codable {
    let status: String
    let token: String?
    let message: String?
}
