//
//  BaseView.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 26/8/24.
//

import UIKit

class BaseView: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func showAlert(title: String, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            
            self.present(alert, animated: true)
        }
    }
    

    

}

extension UIView {
    func roundCorners(radius: CGFloat){
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UIViewController {
    private var activityIndicator: UIActivityIndicatorView{
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }
    
    func showIndicator() {
        let indicator = activityIndicator
        
        if !view.subviews.contains(indicator) {
            view.addSubview(indicator)
            
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
        }
        
        indicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func hideIndicator(){
        for subview in view.subviews {
            if let subview = subview as? UIActivityIndicatorView{
                subview.stopAnimating()
                view.isUserInteractionEnabled = true
            }
        }
    }
    
    func formatCurrency(price: Double) -> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
//        formatter.maximumFractionDigits = 0
//        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = "."
//        formatter.decimalSeparator = ","
        return formatter.string(from: NSNumber(value: price )) ?? ""
    }
    
    func stringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.dateFormat = "dd-MM-yyyy"
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
    
    
    
}
