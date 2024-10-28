//
//  RegisterController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 26/8/24.
//

import UIKit
import Alamofire

class RegisterController: BaseView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var registerContraintBottom: NSLayoutConstraint!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfUsername: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRegister.roundCorners(radius: 25)
//        setupTextField()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        scrollView.contentInsetAdjustmentBehavior = .automatic
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            
            let bottomSafeArea = self.view.safeAreaInsets.bottom
            self.registerContraintBottom.constant = keyboardHeight - bottomSafeArea
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
     
    @objc func keyboardWillHide() {
        self.registerContraintBottom.constant = 60
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
//    func setupTextField() {
//        tfPassword.delegate = self
//        tfConfirmPassword.delegate = self
//    }
//    
    func fetchRegister(username: String, password: String, email: String, completion: @escaping(Result<(String,String,Int,Int), Error>) -> Void) {
        
        let url = APIConfig.registerUser
        let parameters: [String: Any] = [
            "username": username,
            "password": password,
            "email": email
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any]{
                    if let status = json["status"] as? String, status == "success"{
                        if let token = json["token"] as? String, let refreshToken = json["refresh_token"] as? String,
                           let expires_in = json["expires_in"] as? Int,
                           let refresh_expires_in = json["refresh_expires_in"] as? Int
                        
                        {
                            completion(.success((token, refreshToken, expires_in, refresh_expires_in)))
                        }else{
                            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Token not found"])))
                        }
                    }else{
                        if let message = json["message"] as? String{
                            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])))
                        }else{
                            
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    @IBAction func tapOnRegister(_ sender: Any) {
        
        guard let username = tfUsername.text, !username.isEmpty else {
            showAlert(title: "", message: "Bạn chưa nhập thông tin username")
            return
        }
        guard let email = tfEmail.text, !email.isEmpty else {
            showAlert(title: "", message: "Bạn chưa nhập thông tin email")
            return
        }
        guard let password = tfPassword.text, !password.isEmpty else {
            showAlert(title: "", message: "Bạn chưa nhập thông tin password")
            return
        }
        guard let confirmPassword = tfConfirmPassword.text, !confirmPassword.isEmpty else {
            showAlert(title: "", message: "Bạn chưa nhập thông tin confirm password")
            return
        }
        if password != confirmPassword{
            showAlert(title: "", message: "Password và Confirm password không trùng khớp. Vui lòng nhập lại")
            return
        }
        
        fetchRegister(username: username, password: password, email: email) { result in
            switch result {
            case .success((let token, let refreshToken, let expiresIn, let refreshExpiresIn)):
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
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .failure(let error):
                self.showAlert(title: "", message: error.localizedDescription)
            }
        }
    }
}

//extension RegisterController: UITextFieldDelegate {
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        registerConstraintBottom.constant = 320
//        return true
//    }
//}
