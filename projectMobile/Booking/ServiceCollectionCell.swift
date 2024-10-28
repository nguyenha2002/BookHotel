//
//  ServiceCollectionCell.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 17/9/24.
//

import UIKit

class ServiceCollectionCell: UICollectionViewCell {

    @IBOutlet var lbPriceService: UILabel!
    @IBOutlet var lbNameService: UILabel!
    @IBOutlet var imgService: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgService.layer.masksToBounds = true
        imgService.layer.cornerRadius = 25
        
        
        lbNameService.font = Font.shared.bodyFont
        lbPriceService.font = Font.shared.bodyFont
    }

}
