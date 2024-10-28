//
//  FilterController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 14/10/24.
//

import UIKit
import RangeSeekSlider
import Alamofire

class FilterController: BaseView {
    
    let sliderPrice = RangeSeekSlider()
    var star = 0
    var bed = 0
    var people = 0
    var minPrice = 0.0
    var maxPrice = 10_000_000.0
    var user_id = 0
    var arrRoomFilter = [Room]()
    var delegate: FilterControllerDelegate?
    
    @IBOutlet weak var tfCheckOut: UITextField!
    @IBOutlet weak var tfCheckIn: UITextField!
    
    
    @IBOutlet weak var lbPriceRange: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.title = "Filter"
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
        
        let clearButton = UIBarButtonItem()
        clearButton.title = "Clear"
        navigationItem.rightBarButtonItem = clearButton
        clearButton.target = self
        clearButton.action = #selector(tapOnClear)
        
        setupSliderPrice()
        updateStar()
        updateBed()
        updatePeople()
        setupDefaultDates()
        
        tfCheckIn.delegate = self
        tfCheckOut.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBed()
        updateStar()
        updatePeople()
    }
    
    @objc func tapOnClear() {
        
    }
    
    
    func setupSliderPrice() {
        sliderPrice.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(sliderPrice)
        sliderPrice.topAnchor.constraint(equalTo: lbPriceRange.bottomAnchor, constant: 5).isActive = true
        sliderPrice.trailingAnchor.constraint(equalTo: lbPriceRange.trailingAnchor).isActive = true
        sliderPrice.leadingAnchor.constraint(equalTo: lbPriceRange.leadingAnchor).isActive = true
        sliderPrice.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        sliderPrice.tintColor = .systemGray5
        sliderPrice.colorBetweenHandles = UIColor(hex: "#03528A")
        sliderPrice.handleColor = UIColor(hex: "#03528A")
        sliderPrice.minValue = 0
        sliderPrice.maxValue = 10_000_000
        sliderPrice.selectedMaxValue = 10_000_000
        sliderPrice.selectedMinValue = 0
        sliderPrice.lineHeight = 5
        sliderPrice.minDistance = 1_000_000
        
        sliderPrice.minLabelFont = Font.shared.bodyFont
        sliderPrice.maxLabelFont = Font.shared.bodyFont
        
        sliderPrice.enableStep = true
        sliderPrice.step = 200_000
        
        sliderPrice.minLabelColor = .black
        sliderPrice.maxLabelColor = .black
        sliderPrice.delegate = self
    }
    
    @IBAction func tapOnBed(_ sender: UIButton) {
        if bed != sender.tag {
            bed = sender.tag
            print(bed - 5)
        }else{
            bed = 0
        }
        updateBed()
    }
    
    
    @IBAction func tapOnPeople(_ sender: UIButton) {
        if people != sender.tag {
            people = sender.tag
            print(people - 8)
        }else{
            people = 0
        }
        updatePeople()
        
    }
    
    @IBAction func tapOnStar(_ sender: UIButton) {
        if star != sender.tag {
            star = sender.tag
            
        }else{
            star = 0
        }
        updateStar()
    }
    
    func fetchRooms(userId: Int, minPrice: Double, maxPrice: Double, min_rating: Int, min_bed: Int, min_guests: Int, check_in_date: String, check_out_date: String, completion: @escaping([Room]) -> Void) {
        let url = APIConfig.filter
        
        // Lấy token từ TokenManager
        let token = "Bearer \(TokenManager.shared.getUserToken() ?? "")"
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "user_id": userId,
            "min_beds": min_bed,
            "min_guests": min_guests,
            "min_price": minPrice,
            "max_price": maxPrice,
            "min_rating": min_rating,
            "check_in_date": check_in_date,
            "check_out_date": check_out_date
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: RoomsResponse.self) { response in
            switch response.result {
            case .success(let roomsResponse):
                if roomsResponse.status == "success" {
                    guard let roomData = roomsResponse.data else { return }
                    completion(roomData.rooms)
                } else if roomsResponse.status == "error" {
                    if let message = roomsResponse.message, message == "Token expired" {
                        // Làm mới token
                        TokenManager.shared.refreshToken { success in
                            if success {
                                // Gọi lại API sau khi token mới đã được cập nhật
                                self.fetchRooms(userId: userId, minPrice: minPrice, maxPrice: maxPrice, min_rating: min_rating, min_bed: min_bed, min_guests: min_guests, check_in_date: check_in_date, check_out_date: check_out_date, completion: completion)
                                
                                print("Token expired, attempting to refresh...")
                            } else {
                                print("Token refresh failed")
                                // Xử lý khi token refresh không thành công
                                completion([])
                            }
                        }
                    } else {
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
    
    
    //    func bindRooms(userId: Int, minPrice: Double, maxPrice: Double, min_rating: Int, min_bed: Int, min_guests: Int, check_in_date: String, check_out_date: String){
    //        fetchRooms(userId: userId, minPrice: minPrice, maxPrice: maxPrice, min_rating: min_rating, min_bed: min_bed, min_guests: min_guests, check_in_date: check_in_date, check_out_date: check_out_date) { rooms in
    //            DispatchQueue.main.async {
    //                self.arrRoomFilter = rooms
    //                print(rooms)
    //            }
    //        }
    //    }
    
    @IBAction func tapOnApplyFilter(_ sender: Any) {
        
        print("da chon filter")
        
        fetchUserId { [self] userId in
            if let userId = userId {
                user_id = userId
                if let checkin = tfCheckIn.text, let checkout = tfCheckOut.text {
                    if bed == 0 && people == 0 {
                        bindRooms(userId: user_id, minPrice: minPrice, maxPrice: maxPrice, min_rating: star, min_bed: bed, min_guests: people, check_in_date: checkin, check_out_date: checkout)
                    }else if bed > 0 && people > 0 {
                        bindRooms(userId: user_id, minPrice: minPrice, maxPrice: maxPrice, min_rating: star, min_bed: bed - 5, min_guests: people - 8, check_in_date: checkin, check_out_date: checkout)
                    }else if bed > 0 && people == 0{
                        bindRooms(userId: user_id, minPrice: minPrice, maxPrice: maxPrice, min_rating: star, min_bed: bed - 5, min_guests: people, check_in_date: checkin, check_out_date: checkout)
                        print(bed - 5)
                    }else if bed == 0 && people > 0{
                        bindRooms(userId: user_id, minPrice: minPrice, maxPrice: maxPrice, min_rating: star, min_bed: bed, min_guests: people - 8, check_in_date: checkin, check_out_date: checkout)
                        print(people - 8)
                    }
                }
            }
        }
    }
    
    func bindRooms(userId: Int, minPrice: Double, maxPrice: Double, min_rating: Int, min_bed: Int, min_guests: Int, check_in_date: String, check_out_date: String) {
        fetchRooms(userId: userId, minPrice: minPrice, maxPrice: maxPrice, min_rating: min_rating, min_bed: min_bed, min_guests: min_guests, check_in_date: check_in_date, check_out_date: check_out_date) { rooms in
            DispatchQueue.main.async {
                self.arrRoomFilter = rooms
                self.delegate?.didSendDataFromFilter(room: self.arrRoomFilter) // Gọi delegate sau khi mảng đã cập nhật
                if !self.arrRoomFilter.isEmpty {
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.showAlert(title: "", message: "Không có phòng nào phù hợp")
                }
            }
        }
    }
    
    func updateBed() {
        for tag in 6...8 {
            if let bedButton = view.viewWithTag(tag) as? UIButton {
                if tag == bed {
                    bedButton.backgroundColor = UIColor(hex: "#03528A")
                    
                    bedButton.setAttributedTitle(NSAttributedString(string: "\(tag - 5)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]), for: .normal)
                }else{
                    bedButton.backgroundColor = UIColor(hex: "#B9C6D1")
                    bedButton.setAttributedTitle(NSAttributedString(string: "\(tag - 5)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]), for: .normal)
                }
            }
        }
    }
    
    func updatePeople() {
        for tag in 9...13 {
            if let peopleButton = view.viewWithTag(tag) as? UIButton {
                if tag == people {
                    peopleButton.backgroundColor = UIColor(hex: "#03528A")
                    peopleButton.setAttributedTitle(NSAttributedString(string: "\(tag - 8)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]), for: .normal)
                }else{
                    peopleButton.backgroundColor = UIColor(hex: "#B9C6D1")
                    peopleButton.setAttributedTitle(NSAttributedString(string: "\(tag - 8)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]), for: .normal)
                }
            }
        }
    }
    
    func updateStar(){
        for tag in 2...5 {
            if let starButton = view.viewWithTag(tag) as? UIButton {
                if tag == star {
                    starButton.backgroundColor = UIColor(hex: "#03528A")
                    starButton.setAttributedTitle(NSAttributedString(string: "\(tag)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]), for: .normal)
                }else{
                    starButton.backgroundColor = UIColor(hex: "#B9C6D1")
                    starButton.setAttributedTitle(NSAttributedString(string: "\(tag)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]), for: .normal)
                }
            }
        }
    }
    
    func setupDefaultDates() {
        let currentDate = Date()
        let calendarInstance = Calendar.current
        tfCheckIn.text = formatDate(currentDate)
        
        if let nextDay = calendarInstance.date(byAdding: .day, value: 1, to: currentDate) {
            tfCheckOut.text = formatDate(nextDay)
        }
    }
    
    
}

extension FilterController: RangeSeekSliderDelegate {
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        
        minPrice = Double(minValue)
        maxPrice = Double(maxValue)
        print("Min value: \(minValue)\n Max value: \(maxValue)")
    }
}

extension FilterController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let vc = SelectDateController(nibName: "SelectDateController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
        
        if let checkInDate = tfCheckIn.text, let checkOutDate = tfCheckOut.text {
            vc.checkInDate = stringToDate(checkInDate)
            vc.checkOutDate = stringToDate(checkOutDate)
        }
        
        vc.dateChange = { checkIn, checkOut in
            self.tfCheckIn.text = checkIn
            self.tfCheckOut.text = checkOut
        }
        return false
    }
}

protocol FilterControllerDelegate: AnyObject {
    func didSendDataFromFilter(room: [Room])
    func didSendDataFromSort(by: String)
}
