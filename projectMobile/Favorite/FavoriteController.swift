//
//  FavoriteController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 14/10/24.
//

import UIKit
import Alamofire

class FavoriteController: BaseView {

    var arrfavoriteRooms = [Room]()
    
    @IBOutlet weak var favoriteCollection: UICollectionView!
    let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupCollection()
        bindFavoriteRooms()
        setupRefreshControl()
        favoriteCollection.backgroundColor = UIColor(hex: "eeeeee")
        view.backgroundColor = UIColor(hex: "eeeeee")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bindFavoriteRooms()
    }
    
    func setupRefreshControl() {
        favoriteCollection.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc func refreshData() {
        bindFavoriteRooms()
    }
    
    func setupCollection() {
        favoriteCollection.delegate = self
        favoriteCollection.dataSource = self
        
        let nib = UINib(nibName: "RoomCollectionCell", bundle: nil)
        favoriteCollection.register(nib, forCellWithReuseIdentifier: "roomCollectionCell")
    }
    
    func fetchFavoriteRooms(completion: @escaping ([Room]) -> Void) {
        let url = APIConfig.getFavoriteRooms
        
        let token = "Bearer \(TokenManager.shared.getUserToken() ?? "")"
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .get, headers: headers).responseDecodable(of: RoomsResponse.self) { response in
            switch response.result {
            case .success(let roomsResponse):
                if roomsResponse.status == "success" {
                    guard let data = roomsResponse.data else {return}
                    completion(data.rooms)
                }else if roomsResponse.status == "error" {
                    if let message = roomsResponse.message {
                        if message == "Token expired"{
                            TokenManager.shared.refreshToken { success in
                                if success {
                                    self.fetchFavoriteRooms(completion: completion)
                                }else{
                                    
                                }
                            }
                        }else{
                            print(message)
                        }
                    }
                }
            case .failure(let error):
                completion([])
            }
        }
    }
    
    func bindFavoriteRooms() {
        fetchFavoriteRooms { room in
            DispatchQueue.main.async {
                self.arrfavoriteRooms = room
                self.favoriteCollection.reloadData()
                if self.arrfavoriteRooms.isEmpty {
                    self.showAlert(title: "", message: "Chua co phong nao duoc yeu thich")
                }
                self.refreshControl.endRefreshing()
            }
        }
    }
}

extension FavoriteController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return arrfavoriteRooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = favoriteCollection.dequeueReusableCell(withReuseIdentifier: "roomCollectionCell", for: indexPath) as! RoomCollectionCell
        
        let data = arrfavoriteRooms[indexPath.item]
        cell.imageURL = data.images
        cell.imageCollection.reloadData()
        if let reviewCount = data.reviewCount {
            cell.lbCountReviews.text = "\(reviewCount) Reviews"
        }else{
            cell.lbCountReviews.text = "0"
        }
        cell.lbNameRoom.text = data.roomName
        if let address = data.addressHotel {
            cell.lbAddress.text = "Address: " + address
        }else{
            
        }
        cell.lbPrice.text = "Price: \(formatCurrency(price: data.price)) VNĐ/night"
        
        cell.imageFavorite.setImage(UIImage(named: "heart_red"), for: .normal)
        
        cell.isFavorite = data.isFavorite
        cell.onIsFavoriteTapped = { isFavorite in
            self.arrfavoriteRooms[indexPath.item].isFavorite = isFavorite
            let roomId = self.arrfavoriteRooms[indexPath.item].id
            self.fetchFavorite(roomId: roomId) { result in
                switch result {
                case .success(let isFavorite):
                    self.arrfavoriteRooms[indexPath.item].isFavorite = isFavorite
                    self.favoriteCollection.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        if let avgStar = data.averageRating {
            cell.lbStar.text = "\(avgStar)"
            cell.imageStar.image = UIImage(named: "star_yellow")
        }else{
            cell.lbStar.text = "0.0"
            cell.imageStar.image = UIImage(named: "star_0")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = (favoriteCollection.frame.height - 40) / 2
        let w = favoriteCollection.frame.width - 30
        
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "DetailRoom", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "detailRoomController") as! DetailRoomController
        vc.chooseRoom = arrfavoriteRooms[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
}
