//
//  AddReviewController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 11/9/24.
//

import UIKit
import Alamofire

class AddReviewController: BaseView {

    var userId: Int?
    var rating = 5
    
    
    @IBOutlet var star5: UIButton!
    @IBOutlet var star4: UIButton!
    @IBOutlet var star3: UIButton!
    @IBOutlet var star2: UIButton!
    @IBOutlet var star1: UIButton!
    @IBOutlet var btnSubmit: UIButton!
    @IBOutlet var yourReview: UITextView!
    
    var roomId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        yourReview.roundCorners(radius: 15)
        btnSubmit.roundCorners(radius: 20)
        
        navigationItem.title = "Add review"
        
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
        
        fetchUserId { userId in
            if let userId = userId {
                self.userId = userId
                print(userId)
            }
        }
        
    }
    
    
    @IBAction func tapOnStar(_ sender: UIButton) {
        rating = sender.tag
        
        updateStarButtons()
    }
    

    
    func postData(roomId: Int, userId: Int, rating: Int, review: String, completion: @escaping(Result<String, Error>) -> Void) {
        let url = APIConfig.postReview
        let token = "Bearer \(TokenManager.shared.getUserToken() ?? "")"
        
        let parameters: [String: Any] = [
            "room_id": roomId,
            "user_id": userId,
            "rating": rating,
            "review": review
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any]{
                    if let status = json["status"] as? String {
                        if status == "success" {
                            if let message = json["message"] as? String {
                                DispatchQueue.main.async {
                                    completion(.success(message))
                                }
                            }
                        }else if status == "error" {
                            if let message = json["message"] as? String {
                                if message == "Token Expired" {
                                    TokenManager.shared.refreshToken { success in
                                        if success {
                                            self.postData(roomId: roomId, userId: userId, rating: rating, review: review, completion: completion)
                                        }else{
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    @IBAction func tapOnSubmit(_ sender: Any) {
        
        guard let review = yourReview.text, !review.isEmpty else {
            self.showAlert(title: "", message: "Ban chua nhap danh gia")
            return
        }
        if let roomId = roomId , let userId = userId {
            print(roomId)
            postData(roomId: roomId, userId: userId, rating: rating, review: review) { result in
                switch result {
                case .success(let message):
//                    self.showAlert(title: "", message: message)
                    
//                    if let chooseRoomController = self.navigationController?.viewControllers.first(where: { $0 is ChooseRoomController }) {
//                        self.navigationController?.popToViewController(chooseRoomController, animated: true)
//                    }
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
    func updateStarButtons() {
        for tag in 1...5 {
            if let starButton = view.viewWithTag(tag) as? UIButton {
                if tag <= rating {
                    starButton.setImage(UIImage(named: "star_yellow"), for: .normal)
                }else{
                    starButton.setImage(UIImage(named: "star_0"), for: .normal)
                }
                
                starButton.imageView?.contentMode = .scaleAspectFit
            }
                
        }
    }
}

extension UIViewController {
    func fetchUserId(completion: @escaping(Int?) -> Void){
        let url = APIConfig.getUserId
        let token = "Bearer \(TokenManager.shared.getUserToken() ?? "")"
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    if let status = json["status"] as? String {
                        if status == "success" {
                            if let userId = json["user_id"] as? Int {
                                completion(userId)
                            }
                        }else if status == "error" {
                            if let message = json["message"] as? String {
                                if message == "Token expired"{
                                    TokenManager.shared.refreshToken { success in
                                        if success {
                                            self.fetchUserId(completion: completion)
                                        }else {
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                completion(nil)
            }
        }
        
    }
}
