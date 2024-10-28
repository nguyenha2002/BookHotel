//
//  RoomCollectionCell.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 18/10/24.
//

import UIKit

class RoomCollectionCell: UICollectionViewCell {
    
    var imageURL: [String] = []
    var onIsFavoriteTapped: ((Bool) -> Void)?
    
    var isFavorite: Bool = false {
        didSet {
            updateFavoriteButton()
        }
    }
    
    @IBOutlet weak var viewCollection: UIView!
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var imageFavorite: UIButton!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbNameRoom: UILabel!
    @IBOutlet weak var lbCountReviews: UILabel!
    @IBOutlet weak var lbStar: UILabel!
    @IBOutlet weak var imageStar: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 15
        
//        viewCollection.backgroundColor = UIColor(hex: "#eeeeee")
        setupImageCollection()
        updateFavoriteButton()
    }

    func setupImageCollection() {
        imageCollection.delegate = self
        imageCollection.dataSource = self
        
        let nib = UINib(nibName: "ImageCollectionCell", bundle: nil)
        imageCollection.register(nib, forCellWithReuseIdentifier: "imageCollectionCell")
    }
    func updateFavoriteButton() {
        if isFavorite {
            imageFavorite.setImage(UIImage(named: "heart_red"), for: .normal)
        }else{
            imageFavorite.setImage(UIImage(named: "heart_white"), for: .normal)
        }
    }
    
    @IBAction func tapFavorite(_ sender: Any) {
        isFavorite.toggle()
        updateFavoriteButton()
        onIsFavoriteTapped?(isFavorite)
    }
    
    @IBAction func tapOnNext(_ sender: Any) {
    }
}

extension RoomCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollection.dequeueReusableCell(withReuseIdentifier: "imageCollectionCell", for: indexPath) as! ImageCollectionCell
        let data = imageURL[indexPath.item]
        
        if let url = URL(string: data) {
            URLSession.shared.dataTask(with: url) {
                data, response, error in
                if let error = error {
                    return
                }
                guard let data = data, let image = UIImage(data: data) else {return}
                
                DispatchQueue.main.async {
                    cell.imgRoom.image = image
                }
            }.resume()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = imageCollection.frame.height
        let w = imageCollection.frame.width
        
        return CGSize(width: w, height: h)
    }
    
}
