//
//  SortTableCell.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 18/10/24.
//

import UIKit

class SortTableCell: UITableViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var radioButton: UIButton!
    
    var onRadioButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapOnRadioButton(_ sender: Any) {
        onRadioButtonTapped?()
    }
}
