//
//  Font.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 13/10/24.
//

import Foundation
import UIKit

class Font {
    static let shared = Font()
    
    let nameApp: UIFont
    let bodyFont: UIFont
    
    private init() {
        nameApp = UIFont(name: "MoonTime Regular", size: 30) ?? UIFont.systemFont(ofSize: 30, weight: .regular)
        bodyFont = UIFont(name: "Roboto-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
}
