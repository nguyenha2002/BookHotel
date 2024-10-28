//
//  ChooseRoomCollectionCell.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 8/9/24.
//

import UIKit

class ChooseRoomCollectionCell: UICollectionViewCell {
 
    var imgURL: [String] = []
    
    @IBOutlet weak var isFavorite: UIImageView!
    @IBOutlet var viewCollection: UIView!
    @IBOutlet var lbPriceRoom: UILabel!
    @IBOutlet var lbSizeRoom: UILabel!
    @IBOutlet var lbCategoryRoom: UILabel!
    @IBOutlet var lbNameRoom: UILabel!
    @IBOutlet var imgCollection: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 15
        
        viewCollection.backgroundColor = UIColor(hex: "#eeeeee")
        imgCollection.isPagingEnabled = true
        setupImgCollection()
    }

    func setupView(){
        lbSizeRoom.translatesAutoresizingMaskIntoConstraints = false
        lbPriceRoom.translatesAutoresizingMaskIntoConstraints = false
        lbCategoryRoom.translatesAutoresizingMaskIntoConstraints = false
        
        lbNameRoom.translatesAutoresizingMaskIntoConstraints = false
        let heightLabel = 2 * (contentView.frame.height - 40) / 15
        
        lbNameRoom.heightAnchor.constraint(equalToConstant: heightLabel).isActive = true
    }
    
    func setupImgCollection(){
        imgCollection.delegate = self
        imgCollection.dataSource = self
        
        let nib = UINib(nibName: "ImageCollectionCell", bundle: nil)
        imgCollection.register(nib, forCellWithReuseIdentifier: "imageCollectionCell")
    }
}

extension ChooseRoomCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imgCollection.dequeueReusableCell(withReuseIdentifier: "imageCollectionCell", for: indexPath) as! ImageCollectionCell
        let data = imgURL[indexPath.item]
       
        if let url = URL(string: data) {
            URLSession.shared.dataTask(with: url) {
                [weak self] data, response, error in
                if let error = error {
                    return
                }
                guard let data = data, let image = UIImage(data: data) else {return}
                
                DispatchQueue.main.async {
                    cell.imgRoom.image = image
                }
            }.resume()
        }
        
        
//        cell.imgRoom.image = UIImage(named: data)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = imgCollection.frame.height
        let w = imgCollection.frame.width
        
        return CGSize(width: w, height: h)
    }
}
