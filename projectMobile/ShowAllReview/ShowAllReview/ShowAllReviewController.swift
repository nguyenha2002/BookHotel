//
//  ShowAllReviewController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 10/9/24.
//

import UIKit
import Alamofire

class ShowAllReviewController: UIViewController {
    
    @IBOutlet var star1: UIImageView!
    @IBOutlet var star2: UIImageView!
    @IBOutlet var star3: UIImageView!
    @IBOutlet var star4: UIImageView!
    @IBOutlet var star5: UIImageView!
    
    var roomId: Int?
    var arrReview = [Reviews]()
    var avgStar = ""
    
    var avgStarChange: ((Double) -> Void)?
    @IBOutlet var lbAvgStar: UILabel!
    @IBOutlet var reviewCollection: UICollectionView!
    @IBOutlet var numberReview: UILabel!
    @IBOutlet var stackStar: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "Reviews"
        
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
        
        let addReviewButton = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(tapOnAddReview))
        addReviewButton.tintColor = UIColor(hex: "#03528A")
        navigationItem.rightBarButtonItem = addReviewButton
        
        print(arrReview)
        setupReviewCollection()
      
        
        if let roomId = roomId {
            bindReview(roomId: roomId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let roomId = roomId {
            bindReview(roomId: roomId)
        }
    }
    
    func fetchReview(roomId: Int, completion: @escaping ([Reviews]) -> Void){
        let url = APIConfig.getReviewsURL
        
        let token = "Bearer \(TokenManager.shared.getUserToken() ?? "")"
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "room_id": roomId
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: ReviewsResponse.self) { response in
            switch response.result {
            case .success(let reviewResponse):
                if reviewResponse.status == "success" {
                    guard let data = reviewResponse.data else {return}
                    completion(data)
                }else if reviewResponse.status == "error" {
                    if let message = reviewResponse.message {
                        if message == "Token expired" {
                            TokenManager.shared.refreshToken { success in
                                if success {
                                    self.fetchReview(roomId: roomId, completion: completion)
                                }else {
                                    
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                completion([])
            }
        }
    }
    
    func bindReview(roomId: Int) {
        print(roomId)
        fetchReview(roomId: roomId) { reviews in
            self.arrReview = reviews
            DispatchQueue.main.async {
                self.reviewCollection.reloadData()
                self.setupView()
            }
        }
        
    }
    
    func setupView() {
        let numberOfReviews = arrReview.count
        numberReview.text = "\(numberOfReviews)"

        let totalStar = arrReview.reduce(0.0) { 
            $0 + Double($1.rating)
        }
        
        print(totalStar)
        
        let avgStar = totalStar / Double(numberOfReviews)
        if totalStar == 0.0 {
            lbAvgStar.text = "0"
        }else{
            let formatter = String(format: "%.2f", avgStar)
            lbAvgStar.text = formatter
            
            starAvg(rating: avgStar)
        }
        
    }
    
    func starAvg(rating: Double) {
        let wholeStars = Int(rating)
        let fractionalPart = rating - Double(wholeStars)
        
        for tag in 1...5 {
            if let starImageView = view.viewWithTag(tag) as? UIImageView {
                if tag <= wholeStars {
                    starImageView.image = UIImage(named: "star_yellow")
                }else if tag == wholeStars + 1{
                    if fractionalPart > 0.0 {
                        starImageView.image = UIImage(named: "star_half")
                    }else{
                        starImageView.image = UIImage(named: "star_0")
                    }
                }else{
                    starImageView.image = UIImage(named: "star_0")
                }
            }
        }
    }
    
    @objc func tapOnAddReview(){
        let vc = AddReviewController(nibName: "AddReviewController", bundle: nil)
        
        if let roomId = roomId {
            vc.roomId = roomId
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupReviewCollection(){
        reviewCollection.delegate = self
        reviewCollection.dataSource = self
        
        let nib = UINib(nibName: "ReviewCollectionCell", bundle: nil)
        reviewCollection.register(nib, forCellWithReuseIdentifier: "reviewCollectionCell")
        
    }

}
extension ShowAllReviewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrReview.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = reviewCollection.dequeueReusableCell(withReuseIdentifier: "reviewCollectionCell", for: indexPath) as! ReviewCollectionCell
        let data = arrReview[indexPath.item]
        
        cell.avatar.image = UIImage(named: "anh1")
        cell.username.text = data.userInfo.username
        cell.reviewDate.text = data.createdAt
        cell.txtReview.text = data.review
        
        
        let arrStar = [cell.star1, cell.star2, cell.star3, cell.star4, cell.star5]
        
        let rating = data.rating
        
        for (index, star) in arrStar.enumerated() {
            if index < rating {
                star?.image = UIImage(named: "star_yellow")
            }else{
                star?.image = UIImage(named: "star_0")
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard indexPath.item < arrReview.count else {
            return CGSize.zero
        }
        let w = reviewCollection.frame.width - 30
        let reviewText = arrReview[indexPath.item].review
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
