//
//  Service.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 17/9/24.
//

import Foundation

class Service {
    var imgService: String
    var nameService: String
    var priceService: Double
    
    init(imgService: String, nameService: String, priceService: Double) {
        self.imgService = imgService
        self.nameService = nameService
        self.priceService = priceService
    }
}
