//
//  ReviewCollectionCell.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 10/9/24.
//

import UIKit

class ReviewCollectionCell: UICollectionViewCell {

    
    @IBOutlet var star5: UIImageView!
    @IBOutlet var star4: UIImageView!
    @IBOutlet var star3: UIImageView!
    @IBOutlet var star2: UIImageView!
    @IBOutlet var star1: UIImageView!
    
    @IBOutlet var viewCollection: UIView!
    @IBOutlet var txtReview: UITextView!
    @IBOutlet var reviewDate: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var avatar: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.layer.masksToBounds = true
        avatar.layer.cornerRadius = 20
    }

}
