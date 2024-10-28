//
//  SearchController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 14/10/24.
//

import UIKit
import Alamofire

class SearchController: BaseView {
    
    var arrRooms = [Room]()
    var refreshControl = UIRefreshControl()
    var isSearching =  false
    var filteredRoom = [Room]()
    
    @IBOutlet weak var searchCollection: UICollectionView!
    @IBOutlet weak var btnMap: UIButton!
    @IBOutlet weak var btnSort: UIButton!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupView()
        setupSearchCollection()
        bindRooms()
        
        searchCollection.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        searchBar.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    @objc func reloadData(){
        bindRooms()
    }
    
    func setupView() {
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .systemGray6
        searchBar.alpha = 0.8
        searchBar.searchTextField.backgroundColor = .systemGray6
        searchBar.roundCorners(radius: 10)
        
        btnMap.roundCorners(radius: 10)
        btnSort.roundCorners(radius: 10)
        btnFilter.roundCorners(radius: 10)
    }
    
    func fetchRooms(completion: @escaping([Room]) -> Void){
        let url = APIConfig.getRooms
        
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
                }else if roomsResponse.status == "error"{
                    if let message = roomsResponse.message {
                        if message == "Token expired" {
                            TokenManager.shared.refreshToken { success in
                                if success {
                                    self.fetchRooms(completion: completion)
                                }else{
                                    
                                }
                            }
                        }
                        completion([])
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
                if let data = response.data, let errorResponse = String(data: data, encoding: .utf8) {
                    print("Response Data: \(errorResponse)")
                }
                completion([])
            }
        }
    }
    
    func bindRooms(){
        fetchRooms { rooms in
            DispatchQueue.main.async {
                self.arrRooms = rooms
                self.searchCollection.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func setupSearchCollection() {
        searchCollection.delegate = self
        searchCollection.dataSource = self
        let nib = UINib(nibName: "RoomCollectionCell", bundle: nil)
        
        searchCollection.register(nib, forCellWithReuseIdentifier: "roomCollectionCell")
    }
    
    func sortRooms(sort: String){
        switch sort {
        case "Rating (desc)":
            arrRooms.sort{
                (Double($0.averageRating ?? "0.0") ?? 0.0)  > (Double($1.averageRating ?? "0.0") ?? 0.0)
            }
        case "Rating (asc)":
            arrRooms.sort {
                (Double($0.averageRating ?? "0.0") ?? 0.0) < (Double($1.averageRating ?? "0.0") ?? 0.0)
            }
        case "Price (desc)":
            arrRooms.sort {
                $0.price > $1.price
            }
        case "Price (asc)":
            arrRooms.sort {
                $0.price < $1.price
            }
        case "Number review (desc)":
            arrRooms.sort {
                ($0.reviewCount ?? 0) > ($1.reviewCount ?? 0)
            }
        case "Number review (asc)":
            arrRooms.sort {
                ($0.reviewCount ?? 0) < ($1.reviewCount ?? 0)
            }
        default:
            print("Giữ nguyên")
        }
        
        searchCollection.reloadData()
    }
    
    @IBAction func tapOnFilter(_ sender: Any) {
        let vc = FilterController(nibName: "FilterController", bundle: nil)
        
        vc.delegate = self
        
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
    @IBAction func tapOnSort(_ sender: Any) {
        let vc = SortController(nibName: "SortController", bundle: nil)
        vc.sortData = {
            sortData in
            self.sortRooms(sort: sortData)
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func tapOnMap(_ sender: Any) {
    }
}

extension SearchController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return filteredRoom.count
        }else{
            return arrRooms.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = searchCollection.dequeueReusableCell(withReuseIdentifier: "roomCollectionCell", for: indexPath) as! RoomCollectionCell
        
        let data = isSearching ? filteredRoom[indexPath.item] : arrRooms[indexPath.item]
//        let data = arrRooms[indexPath.item]
        
        cell.viewCollection.backgroundColor = UIColor(hex: "#f2f4f8")
        cell.imageURL = data.images
        cell.imageCollection.reloadData()
        if let address = data.addressHotel {
            cell.lbAddress.text = "Address: " + address
        }
        cell.lbNameRoom.text = data.roomName
        if let numberReviews = data.reviewCount {
            cell.lbCountReviews.text = "\(numberReviews) Reviews"
        }
        cell.lbPrice.text = "Price: \(formatCurrency(price: data.price)) VNĐ/night"
        if data.isFavorite {
            cell.imageFavorite.setImage(UIImage(named: "heart_red"), for: .normal)
        }else{
            cell.imageFavorite.setImage(UIImage(named: "heart_white"), for: .normal)
        }
        cell.isFavorite = data.isFavorite
        cell.onIsFavoriteTapped = { isFavorite in
            self.arrRooms[indexPath.item].isFavorite = isFavorite
            let roomId = self.arrRooms[indexPath.item].id
            self.fetchFavorite(roomId: roomId) { result in
                switch result {
                case .success(let isFavorite):
                    self.arrRooms[indexPath.item].isFavorite = isFavorite
                    self.searchCollection.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        
        if let avgRating = data.averageRating {
            cell.lbStar.text = avgRating
            cell.imageStar.image = UIImage(named: "star_yellow")
        }else{
            cell.lbStar.text = "0.00"
            cell.imageStar.image = UIImage(named: "star_0")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = searchCollection.frame.width - 30
        
        return CGSize(width: w, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "DetailRoom", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "detailRoomController") as! DetailRoomController
        vc.chooseRoom = arrRooms[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchController: FilterControllerDelegate {
    func didSendDataFromFilter(room: [Room]) {
            arrRooms = room
            print(room)
            searchCollection.reloadData()
    }
    
    func didSendDataFromSort(by: String) {
        print("")
    }
}

extension SearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredRoom = arrRooms
        }else{
            isSearching = true
            filteredRoom = arrRooms.filter({
                $0.roomName.lowercased().contains(searchText.lowercased()) ||
                ($0.addressHotel?.lowercased().contains(searchText.lowercased()) ?? false)
            })
        }
        searchCollection.reloadData()
    }
}
