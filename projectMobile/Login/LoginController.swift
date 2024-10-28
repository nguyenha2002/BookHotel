//
//  LoginController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 26/8/24.
//

import UIKit
import Alamofire

class LoginController: BaseView {
    
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSignIn.roundCorners(radius: 25)
        tfEmail.delegate = self
        tfPassword.delegate = self
        
//        let image = UIImageView(frame: UIScreen.main.bounds)
//        image.image = UIImage(named: "background_login")
//        
//        self.view.insertSubview(image, at: 0)
        
        tfEmail.font = UIFont(name: "MoonTime-Regular", size: 25)
        
        for family in UIFont.familyNames {
            print("Font Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("    Font Name: \(name)")
            }
        }
        
    }
    
    func login(username: String, password: String, completion: @escaping (Result<(String, String, Int, Int), Error>) -> Void) {
        
        let url = APIConfig.login
        let parameters: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default,  headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if let status = json["status"] as? String, status == "success" {
                            if let token = json["token"] as? String, let refreshToken = json["refresh_token"] as? String,
                               let expires_in = json["expires_in"] as? Int,
                               let refresh_expires_in = json["refresh_expires_in"] as? Int
                            
                            {
                                completion(.success((token, refreshToken, expires_in, refresh_expires_in)))
                            } else {
                                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Token not found"])))
                            }
                        } else {
                            if let message = json["message"] as? String {
                                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])))
                            } else {
                                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                            }
                        }
                    }
                case .failure(let error):
                    // Xử lý lỗi mạng
                    completion(.failure(error))
                }
            }
    }
    
    @IBAction func tapOnSignIn(_ sender: Any) {
        
        showIndicator()
        guard let username = tfEmail.text, !username.isEmpty else {
            showAlert(title: "", message: "Bạn chưa nhập thông tin username")
            return
        }
        guard let password = tfPassword.text, !password.isEmpty else {
            showAlert(title: "", message: "Bạn chưa nhập thông tin mật khẩu")
            return
        }
        
        login(username: username, password: password) { [weak self] result in
            switch result {
            case .success((let token, let refreshToken, let expiresIn, let refreshExpiresIn)):
                //lưu vào userdefault
                print(token)
                UserDefaults.standard.set(token, forKey: "userToken")
                UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                UserDefaults.standard.set(expiresIn, forKey: "expiresIn")
                UserDefaults.standard.set(refreshExpiresIn, forKey: "refreshExpiresIn")
                
                let a = UserDefaults.standard.string(forKey: "userToken")
                let b = UserDefaults.standard.string(forKey: "refreshToken")
                let c = UserDefaults.standard.string(forKey: "expiresIn")
                let d = UserDefaults.standard.string(forKey: "refreshExpiresIn")
                
                print("Token: \(a)")
                print("      Refresh Token: \(b)")
                
                print("expiresIn: \(c)")
                print("refreshExpiresIn: \(d)")
                let sb = UIStoryboard(name: "TabBar", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "tabBarVC")
                self?.navigationController?.pushViewController(vc, animated: true)
                self?.hideIndicator()
                
            case .failure(let error):
                self?.showAlert(title: "", message: error.localizedDescription)
                self?.hideIndicator()
            }
        }
    }
    
    @IBAction func tapOnRegister(_ sender: Any) {
        let vc = RegisterController(nibName: "RegisterController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
        //        present(vc, animated: true)
    }
    
    @IBAction func tapOnForgotPassword(_ sender: Any) {
    }
}
extension LoginController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfEmail.resignFirstResponder()
        tfPassword.resignFirstResponder()
        return true
    }
}
