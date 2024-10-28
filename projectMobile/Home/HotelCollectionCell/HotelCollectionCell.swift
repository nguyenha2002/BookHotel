//
//  HotelCollectionCell.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 7/9/24.
//

import UIKit

class HotelCollectionCell: UICollectionViewCell {

    @IBOutlet var imgStar: UIImageView!
    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var lbStarAverage: UILabel!
    @IBOutlet weak var lbPriceHotel: UILabel!
    @IBOutlet weak var lbAddressHotel: UILabel!
    @IBOutlet weak var lbNameHotel: UILabel!
    @IBOutlet weak var imgHotel: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        applyShadow()
        imgHotel.contentMode = .scaleAspectFill
        setupView()
        viewCell.backgroundColor = UIColor(hex: "#f2f4f8")
    }

    func setupView(){
        
        lbNameHotel.translatesAutoresizingMaskIntoConstraints = false
        let heightLbName = (viewCell.frame.height - 50) / 9
        lbNameHotel.heightAnchor.constraint(equalToConstant: heightLbName).isActive = true
        
        lbAddressHotel.translatesAutoresizingMaskIntoConstraints = false
        lbAddressHotel.heightAnchor.constraint(equalToConstant: heightLbName).isActive = true
        
        lbPriceHotel.translatesAutoresizingMaskIntoConstraints = false
        lbPriceHotel.heightAnchor.constraint(equalToConstant: heightLbName).isActive = true
        
        imgHotel.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        imgHotel.layer.cornerRadius = 20
        imgHotel.layer.masksToBounds = true
    }
    
    func applyShadow(){
        viewCell.layer.shadowColor = UIColor.black.cgColor
        viewCell.layer.shadowRadius = 10
        viewCell.layer.shadowOpacity = 1
        viewCell.layer.shadowOffset = CGSize(width: 20, height: 4)
        viewCell.layer.masksToBounds = false
        
        let shadowPath = UIBezierPath(roundedRect: viewCell.bounds, cornerRadius: viewCell.layer.cornerRadius)
        viewCell.layer.shadowPath = shadowPath.cgPath
    }
    
}
