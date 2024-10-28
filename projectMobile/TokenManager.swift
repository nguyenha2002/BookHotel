//
//  TokenManager.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 7/10/24.
//

import Foundation
import Alamofire

class TokenManager {
    static let shared = TokenManager()
    
    private init() {}//ngăn chặn việc khởi tạo mới
    
    func getUserToken() -> String? {
        return UserDefaults.standard.string(forKey: "userToken")
    }
    
    func setUserToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "userToken")
    }
    
    func refreshToken(completion: @escaping(Bool) -> Void) {
        let url = APIConfig.refreshToken
        
        guard let refreshToken =  UserDefaults.standard.string(forKey: "refreshToken") else {
            completion(false)
            return
        }
        
        let parameters: [String: Any] = [
            "refresh_token": refreshToken
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    if let status = json["status"] as? String, status == "success" {
                        if let token = json["access_token"] as? String {
                            self.setUserToken(token)
                            completion(true)
                        }else{
                            completion(false)
                        }
                    }else{
                        completion(false)
                    }
                }
            case .failure:
                completion(false)
            }
        }
    }
}
