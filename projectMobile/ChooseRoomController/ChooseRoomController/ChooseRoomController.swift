//
//  ChooseRoomController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 8/9/24.
//

import UIKit
import Alamofire

class ChooseRoomController: BaseView {
    
    var checkInDate: String?
    var checkOutDate: String?

    var hotelId: Int?
    var arrRoom = [Room]()
    @IBOutlet var collectionRoom: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupCollection()
        self.title = "Choose Rooms"
        
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
        
        if let checkIn = checkInDate, let checkOut = checkOutDate, let hotelId = hotelId {
            bindRooms(for: hotelId, check_in_date: checkIn, check_out_date:checkOut)
        }
        
//        print(DateData.shared.checkIn)
//        print(DateData.shared.checkOut)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let checkIn = checkInDate, let checkOut = checkOutDate, let hotelId = hotelId {
            bindRooms(for: hotelId, check_in_date: checkIn, check_out_date:checkOut)
        }
    }
    
    func setupCollection(){
        collectionRoom.delegate = self
        collectionRoom.dataSource = self
        
        let nib = UINib(nibName: "ChooseRoomCollectionCell", bundle: nil)
        collectionRoom.register(nib, forCellWithReuseIdentifier: "chooseRoomCollectionCell")
    }
    
    func fetchRooms(hotelId: Int, check_in_date: String, check_out_date: String, completion: @escaping ([Room]) -> Void ) {
        let url = APIConfig.getRoomsURL
        let parameters: [String: Any] = [
            "hotel_id": hotelId,
            "check_in_date": check_in_date,
            "check_out_date": check_out_date
        ]
        
        let token = "Bearer \(TokenManager.shared.getUserToken()  ?? "")"
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RoomsResponse.self) { response in
            
            print(response)
            switch response.result {
            case .success(let roomResponse):
                if roomResponse.status == "success"{
                    guard let dataRoom = roomResponse.data else {return}
                    
                    completion(dataRoom.rooms)
                }else if roomResponse.status == "error"{
                    if let message = roomResponse.message, message == "Token expired" {
                        TokenManager.shared.refreshToken { success in
                            if success {
                                self.fetchRooms(hotelId: hotelId, check_in_date: check_in_date, check_out_date: check_out_date, completion: completion)
                            }else{
                                
                            }
                        }
                    }
                    completion([])
                }
            case .failure(let error):
                print("\(error)")
                if let data = response.data, let errorResponse = String(data: data, encoding: .utf8) {
                    
                }
                completion([])
            }
        }
    }
    
    func bindRooms(for hotelId: Int, check_in_date: String, check_out_date: String) {
        fetchRooms(hotelId: hotelId, check_in_date: check_in_date, check_out_date: check_out_date) { [weak self] rooms in
            DispatchQueue.main.async {
                self?.arrRoom = rooms
                
                // In ra số lượng phòng để kiểm tra
                print("Số lượng phòng: \(self?.arrRoom.count ?? 0)")
                
                // Reload collection view
                self?.collectionRoom.reloadData()
                
                // Sau khi reload, kiểm tra nếu không có phòng trống
                if self?.arrRoom.count == 0 {
                    print("Hiển thị alert: không có phòng trống")
                    self?.showAlert(title: "", message: "Không còn phòng trống từ ngày \(check_in_date) đến ngày \(check_out_date)")
                }
                
            }
        }
    }

}
extension ChooseRoomController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrRoom.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chooseRoomCollectionCell", for: indexPath) as! ChooseRoomCollectionCell
        let data = arrRoom[indexPath.item]
        
        cell.contentView.backgroundColor = .orange
        cell.lbNameRoom.text = data.roomName
        cell.lbSizeRoom.text = "Room size: " + "\(data.area)" + " m"
        cell.lbCategoryRoom.text = "Category: " + data.roomType
        cell.lbPriceRoom.text = "\(formatCurrency(price: data.price))" + " " + "VNĐ/night"
        cell.isFavorite.isHidden = true
        
        cell.imgURL = data.images
        cell.imgCollection.reloadData()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = ( collectionView.frame.height - 50 ) / 2
        let w = view.frame.width - 30
        
        return CGSize(width: w, height: h)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "DetailRoom", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "detailRoomController") as! DetailRoomController
        vc.chooseRoom = arrRoom[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
}
