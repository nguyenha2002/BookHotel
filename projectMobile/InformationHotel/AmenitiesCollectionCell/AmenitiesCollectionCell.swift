//
//  AmenitiesCollectionCell.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 8/9/24.
//

import UIKit

class AmenitiesCollectionCell: UICollectionViewCell {

    @IBOutlet var lbNameAmenities: UILabel!
    @IBOutlet var imgAmenities: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgAmenities.layer.masksToBounds = true
        imgAmenities.layer.cornerRadius = 20
    }

}
