//
//  DetailRoomController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 9/9/24.
//

import UIKit
import Alamofire

class DetailRoomController: BaseView {

    var chooseRoom: Room!
    var isFavorite: Bool!
    var imgURL: [String] = []
    @IBOutlet var favorite: UIButton!
    var review = [Reviews]()
    
    var room: Room!
    
    @IBOutlet var imageStar: UIImageView!
    @IBOutlet var btnBookNow: UIButton!
    @IBOutlet var imgCollection: UICollectionView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var reviewCollection: UICollectionView!
    @IBOutlet var lbPrice: UILabel!
    @IBOutlet var btnShowAllReviews: UIButton!
    @IBOutlet var lbRating: UILabel!
    @IBOutlet var lbAmenities: UILabel!
    @IBOutlet var tvDetail: UITextView!
    @IBOutlet var lbArea: UILabel!
    @IBOutlet var lbGuest: UILabel!
    @IBOutlet var lbBath: UILabel!
    @IBOutlet var lbBed: UILabel!
    @IBOutlet var lbName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupImgCollection()
        setupCollectionReview()
        btnBookNow.roundCorners(radius: 8)
        mainView.roundCorners(radius: 20)
        favorite.roundCorners(radius: 25)
        
        setupView()
        print(chooseRoom.reviews)
        
     //   bindRviews(roomId: chooseRoom.id)
        review = chooseRoom.reviews
        updateFavoriteButton(isFavorite: chooseRoom.isFavorite)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupView()
        imgCollection.reloadData()
        reviewCollection.reloadData()
    }
    
    func setupImgCollection(){
        imgCollection.delegate = self
        imgCollection.dataSource = self
        
        let nib = UINib(nibName: "ImageCollectionCell", bundle: nil)
        imgCollection.register(nib, forCellWithReuseIdentifier: "imageCollectionCell")
        
        imgURL = chooseRoom.images
    }
    
    func setupCollectionReview(){
        reviewCollection.delegate = self
        reviewCollection.dataSource = self
        
        let nib = UINib(nibName: "ReviewCollectionCell", bundle: nil)
        reviewCollection.register(nib, forCellWithReuseIdentifier: "reviewCollectionCell")
        
        review = chooseRoom.reviews
    }
    
    func setupView() {
        lbName.text = chooseRoom.roomName
        lbPrice.text = "\(formatCurrency(price: chooseRoom.price))"
        tvDetail.text = chooseRoom.detail
        lbBed.text = "\(chooseRoom.numberOfBeds) beds"
        lbBath.text = "\(chooseRoom.numberOfBaths) baths"
        lbGuest.text = "\(chooseRoom.numberOfGuests) guests"
        lbArea.text = "\(chooseRoom.area) mxm"
        lbAmenities.text = chooseRoom.amenities
        
        if !chooseRoom.reviews.isEmpty {
            let totalRating = chooseRoom.reviews.reduce(0.0){
                $0 + (Double($1.rating))
            }
            let avgRating = totalRating / Double(chooseRoom.reviews.count)
            if avgRating == 0.0 {
                lbRating.text = ""
            }
            else {
                let formattedRating = String(format: "%.2f", avgRating)
                lbRating.text = "\(formattedRating)"
            }
        }
    }
    
    func fetchInformationRoom(roomId: Int, completion: @escaping (Room?) -> Void) {
        let url = APIConfig.getInformationRoom
        
        let token = "Bearer \(TokenManager.shared.getUserToken() ?? "")"
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "room_id": roomId
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RoomResponse.self) { response in
            switch response.result {
            case .success(let roomResponse):
                if roomResponse.status == "success" {
                    if let data = roomResponse.data {
                        completion(data)
                    }
                }else if roomResponse.status == "error" {
                    if let message = roomResponse.message {
                        if message == "Token Expired" {
                            TokenManager.shared.refreshToken { success in
                                if success {
                                    self.fetchInformationRoom(roomId: roomId, completion: completion)
                                }else{
                                    
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    func fetchInformationRoom(roomId: Int) {
        fetchInformationRoom(roomId: roomId) { room in
            if let room = room {
                DispatchQueue.main.async {
                    self.review = room.reviews
                }
            }
        }
    }
    
    
    
    
    @IBAction func tapOnFavorite(_ sender: Any) {
        chooseRoom.isFavorite.toggle()
        
        // Cập nhật giao diện của nút theo trạng thái mới
        updateFavoriteButton(isFavorite: chooseRoom.isFavorite)
        
        // Thực hiện yêu cầu mạng để đồng bộ trạng thái yêu thích
        fetchFavorite(roomId: chooseRoom.id) { result in
            switch result {
            case .success(let isFavorite):
                print(isFavorite)
                self.updateFavoriteButton(isFavorite: isFavorite)
            case .failure(let error):
                print("\(error.localizedDescription)")
                // Có thể quay lại trạng thái cũ nếu yêu cầu mạng thất bại
                self.chooseRoom.isFavorite.toggle()
                self.updateFavoriteButton(isFavorite: self.chooseRoom.isFavorite)
            }
        }
    }
    
    func updateFavoriteButton(isFavorite: Bool) {
        
        DispatchQueue.main.async {
            if isFavorite {
                self.favorite.setImage(UIImage(named: "heart_red"), for: .normal)
            }else{
                self.favorite.setImage(UIImage(named: "heart_white"), for: .normal)
            }

        }
    }
    
    @IBAction func tapOnBookNow(_ sender: Any) {
        
        let vc = BookingController(nibName: "BookingController", bundle: nil) 
        vc.room = chooseRoom
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func tapOnShowAllReview(_ sender: Any) {
        
        let vc = ShowAllReviewController(nibName: "ShowAllReviewController", bundle: nil) 
        vc.roomId = chooseRoom.id
        //vc.arrReview = chooseRoom.reviews
        if let avgText = lbRating.text {
            vc.avgStar = avgText
        }else{
            return 
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension DetailRoomController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == imgCollection {
            return imgURL.count
        }else{
            if review.count >= 3 {
                return 3
            }else{
                return review.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == imgCollection {
            let cell = imgCollection.dequeueReusableCell(withReuseIdentifier: "imageCollectionCell", for: indexPath) as! ImageCollectionCell
            let data = imgURL[indexPath.item]
            
            if let url = URL(string: data) {
                URLSession.shared.dataTask(with: url) {
                    data, response, error in
                    if let error = error {
                        return
                    }
                    guard let data = data, let image = UIImage(data: data) else {return}
                    
                    DispatchQueue.main.sync {
                        cell.imgRoom.image = image
                    }
                }.resume()
            }
            return cell
        }
        else {
            let cell = reviewCollection.dequeueReusableCell(withReuseIdentifier: "reviewCollectionCell", for: indexPath) as! ReviewCollectionCell
            
            if indexPath.item < review.count {
                let data = review[indexPath.item]
                cell.avatar.image = UIImage(named: "anh1")
                cell.username.text =  data.userInfo.username
                cell.reviewDate.text = data.createdAt
                cell.txtReview.text = data.review
                
                let arrStar = [cell.star1, cell.star2, cell.star3, cell.star4, cell.star5]
                let rating = data.rating
                
                for (index, star) in arrStar.enumerated(){
                    if index < rating {
                        star?.image = UIImage(named: "star_yellow")
                    }else{
                        star?.image = UIImage(named: "star_0")
                    }
                }
                
            }else{
                reviewCollection.isHidden = true
                imageStar.image = UIImage(named: "star_0.png")
                
                let view1 = UIView()
                view.addSubview(view1)
                view1.translatesAutoresizingMaskIntoConstraints = false
                view1.topAnchor.constraint(equalTo: reviewCollection.topAnchor).isActive = true
                view1.leadingAnchor.constraint(equalTo: reviewCollection.leadingAnchor).isActive = true
                view1.trailingAnchor.constraint(equalTo: reviewCollection.trailingAnchor).isActive = true
                view1.bottomAnchor.constraint(equalTo: reviewCollection.bottomAnchor).isActive = true
                
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                view1.addSubview(label)
                
                label.text = "Chưa có đánh giá nào cho phòng này!"
                label.textColor = UIColor(hex: "#03528A")
                label.centerXAnchor.constraint(equalTo: view1.centerXAnchor).isActive = true
                label.centerYAnchor.constraint(equalTo: view1.centerYAnchor).isActive = true
                
                btnShowAllReviews.tintColor = .systemGray4
                btnShowAllReviews.isUserInteractionEnabled = false
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == imgCollection {
            let h = imgCollection.frame.height
            let w = imgCollection.frame.width
            
            return CGSize(width: w, height: h)
        }else{
//            let w = reviewCollection.frame.width - 30
//            return CGSize(width: w, height: 175)
            
            let w = reviewCollection.frame.width - 30
            let reviewText = review[indexPath.item].review
            let maxNumberOfLines = 4
            let lineHeight = CGFloat(20)
            let maxHeight = lineHeight * CGFloat(maxNumberOfLines)
            let lbText = UILabel()
            lbText.text = reviewText
            lbText.sizeToFit()
            lbText.numberOfLines = maxNumberOfLines
            let lbTextSize = lbText.sizeThatFits(CGSize(width: w, height: .greatestFiniteMagnitude))
            let reviewHeight = min(lbTextSize.height, maxHeight)
            let staticHeight: CGFloat = 95
            let totalHeight = staticHeight + reviewHeight
            
            return CGSize(width: w, height: totalHeight)
        }
    }
}

extension UIViewController {
    
    func fetchFavorite(roomId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = APIConfig.favorite_room
        let token = "Bearer \(TokenManager.shared.getUserToken()  ?? "")"
        
        let parameters: [String: Any] = [
            "room_id": roomId
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let status = json["status"] as? String {
                    if status == "success", let isFavorite = json["isfavorite"] as? Bool {
                        DispatchQueue.main.async {
                            completion(.success(isFavorite))
                        }
                    }else if let message = json["message"] as? String {
                        //                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])))
                        if message == "Expired token" {
                            TokenManager.shared.refreshToken { success in
                                if success {
                                    self.fetchFavorite(roomId: roomId, completion: completion)
                                }else{
                                    
                                }
                            }
                            
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
