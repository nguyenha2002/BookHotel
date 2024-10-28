//
//  HomeController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 6/9/24.
//

import UIKit
import Alamofire

class HomeController: BaseView {
    
    var hotels = [Hotels]()
    var filteredHotels = [Hotels]()
    var isSearching = false
    
    @IBOutlet weak var listHotelCollection: UICollectionView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollection()
        bindDt()
        setupRefresh()
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Hello"
        
        //        navigationItem.titleView = searchBar
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    func setupRefresh() {
        listHotelCollection.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc func refreshData() {
        bindDt()
    }
    func setupView(){
        imgAvatar.translatesAutoresizingMaskIntoConstraints = false
        imgAvatar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        imgAvatar.heightAnchor.constraint(equalToConstant: 46).isActive = true
        imgAvatar.widthAnchor.constraint(equalTo: imgAvatar.heightAnchor).isActive = true
        imgAvatar.backgroundColor = .gray
        imgAvatar.roundCorners(radius: 23)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        imgAvatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: imgAvatar.topAnchor).isActive = true
        
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: imgAvatar.leadingAnchor, constant: -17).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .systemGray6
        searchBar.searchTextField.backgroundColor = .systemGray6
        searchBar.alpha = 0.8
        searchBar.roundCorners(radius: 10)
        
        
        listHotelCollection.translatesAutoresizingMaskIntoConstraints = false
        listHotelCollection.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 15).isActive = true
        listHotelCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        listHotelCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        listHotelCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }
    
    func setupCollection(){
        listHotelCollection.delegate = self
        listHotelCollection.dataSource = self
        
        let nib = UINib(nibName: "HotelCollectionCell", bundle: nil)
        listHotelCollection.register(nib, forCellWithReuseIdentifier: "hotelCollectionCell")
    }
    func fetchHotels(completion: @escaping ([Hotels]) -> Void) {
        let url = APIConfig.getHotelsURL
        
        let token = "Bearer \(TokenManager.shared.getUserToken() ?? "")"
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .get, headers: headers).responseDecodable(of: HotelResponse.self) {
            response in
            switch response.result {
            case .success(let hotelResponse):
                if hotelResponse.status == "success"{
                    guard let data = hotelResponse.data else {return}
                    completion(data)
                }else if hotelResponse.status == "error"{
                    if let message = hotelResponse.message, message == "Token expired"{
                        TokenManager.shared.refreshToken { success in
                            if success {
                                self.fetchHotels(completion: completion)
                            }else{
                                
                            }
                        }
                    }
                    completion([])
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                if let data = response.data, let errorResponse = String(data: data, encoding: .utf8) {
                    print("Response data: \(errorResponse)")
                }
                completion([])
            }
        }
    }
    
    func bindDt() {
        fetchHotels { [weak self] hotels in
            self?.hotels = hotels
            DispatchQueue.main.async {
                self?.listHotelCollection.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
    }
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return filteredHotels.count
        }else{
            return hotels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = listHotelCollection.dequeueReusableCell(withReuseIdentifier: "hotelCollectionCell", for: indexPath) as! HotelCollectionCell
        
        let data = isSearching ? filteredHotels[indexPath.item] : hotels[indexPath.item]
        
        //        let data = hotels[indexPath.item]
        
        if let url = URL(string: data.imageUrl) {
            URLSession.shared.dataTask(with: url) {
                [weak self] data, response, error in
                if let error = error {
                    return
                }
                guard let data = data, let image = UIImage(data: data) else { return }
                
                DispatchQueue.main.async {
                    cell.imgHotel.image = image
                }
            }.resume()
        }
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
        
        cell.lbNameHotel.text = data.name
        cell.lbAddressHotel.text = "Address: " + data.location
        cell.lbPriceHotel.text = "Price: " + "\(formatCurrency(price: data.pricePerNight))" + " VNĐ/night"
        
        if let avgDouble = Double(data.averageRating) {
            let roundedRating = Double(round(100 * avgDouble) / 100)
            if roundedRating == 0.00 {
                cell.imgStar.image = UIImage(named: "star_0")
                cell.lbStarAverage.text = "0.00"
            }else{
                cell.imgStar.image = UIImage(named: "star_yellow")
                cell.lbStarAverage.text = String(format: "%.2f", roundedRating)
            }
        }
        //        "\(Double(String(format: "%.2f", data.averageRating)) ?? 0.0)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightCell = (listHotelCollection.frame.height - 40 ) / 2
        let weightCell = listHotelCollection.frame.width
        
        return CGSize(width: weightCell, height: heightCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "InformationHotel", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "informationHotel") as? InformationHotelController {
            vc.hotelDetail = hotels[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension HomeController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredHotels = hotels
        }else{
            isSearching = true
                filteredHotels = hotels.filter{ $0.name.lowercased().contains(searchText.lowercased()) ||  $0.location.lowercased().contains(searchText.lowercased())
            }
        }
        listHotelCollection.reloadData()
    }
}
