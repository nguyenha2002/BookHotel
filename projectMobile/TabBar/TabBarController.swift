//
//  TabBarController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 6/9/24.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        
        //        navigationItem.title = "StayMate"
        
        //        self.navigationController?.navigationBar.titleTextAttributes = [
        //            NSAttributedString.Key.font: UIFont(name: "MoonTime Regular", size: 40),
        //            NSAttributedString.Key.foregroundColor: UIColor(hex: "#03528A"),
        //        ]
        
        self.delegate = self
        navigationItem.title = "Home"
        
        self.navigationController?.navigationBar.barTintColor = .white // Hoặc màu khác bạn muốn
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.barTintColor = UIColor(hex: "#F2F4F8")
        tabBar.backgroundColor = UIColor(hex: "#F2F4F8")
        
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hex: "#03528A"), NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 20)
        ]
        
    }
    
}
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hex: "#03528A"), NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 20)
//        ]
        // Thay đổi tiêu đề dựa trên chỉ số của tab được chọn
        switch viewControllers?.firstIndex(of: viewController) {
            
        case 0:
            navigationItem.title = "Home"
        case 1:
            navigationItem.title = "Search"
        case 2:
            navigationItem.title = "My Stay"
        case 3:
            navigationItem.title = "My Favorite"
        default:
            navigationItem.title = "User"
        }
    }
}
