//
//  BookingController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 11/9/24.
//

import UIKit
import Alamofire

class BookingController: BaseView {

    var priceService = 0.0
    var priceRoom = 0.0
    var total = 0.0
    var arrService = [Services]()
    var selectedService = [Services]()
    var room: Room?
    
    @IBOutlet var btnBook: UIButton!
    @IBOutlet var lbTotal: UILabel!
    @IBOutlet var lbPriceService: UILabel!
    @IBOutlet var lbPriceRoom: UILabel!
    @IBOutlet var collectionService: UICollectionView!
    @IBOutlet var tfCheckOut: UITextField!
    @IBOutlet var tfCheckIn: UITextField!
    @IBOutlet var tfPhoneNumber: UITextField!
    @IBOutlet var tfEmail: UITextField!
    @IBOutlet var tfLastName: UITextField!
    @IBOutlet var tfFirstName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "Booking"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hex: "#03528A")]
    
        let backButton = UIBarButtonItem()
        btnBook.backgroundColor = UIColor(hex: "#03528A")
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
        
        setupCollectionService()
        
        if let roomData = room {
            priceRoom = roomData.price
            lbPriceRoom.text = "\(formatCurrency(price: priceRoom)) VNĐ"
            bindService(hotelId: roomData.hotelId)
        }
        
        if let check_in = DateData.shared.checkIn, let check_out = DateData.shared.checkOut {
            tfCheckIn.text = formatDate(check_in)
            tfCheckOut.text = formatDate(check_out)
        }else{
            let currentDate = Date()
            let calendarInstance = Calendar.current
            tfCheckIn.text = formatDate(currentDate)
            
            if let nextDay = calendarInstance.date(byAdding: .day, value: 1, to: currentDate) {
                tfCheckOut.text = formatDate(nextDay)
            }
        }
        
        reloadPriceService()
        
//        print("     \n\n\nRoom thong tin: \(room)")
        
        tfCheckIn.delegate = self
        tfCheckOut.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let checkIn = tfCheckIn.text, let checkOut = tfCheckOut.text else {return}
        guard let checkin = stringToDate(checkIn), let checkout = stringToDate(checkOut) else {return}
        let numberOfNights = Calendar.current.dateComponents([.day], from: checkin, to: checkout).day ?? 1
        
        lbPriceRoom.text = "\(formatCurrency(price: priceRoom * Double(numberOfNights))) VNĐ"
        
        reloadPriceService()
    }
    
    func setupCollectionService() {
        collectionService.delegate = self
        collectionService.dataSource = self
        collectionService.allowsMultipleSelection = true
        
        let nib = UINib(nibName: "ServiceCollectionCell", bundle: nil)
        collectionService.register(nib, forCellWithReuseIdentifier: "serviceCollectionCell")
    }
    
    func fetchService(hotelId: Int, completion: @escaping([Services]) -> Void) {
        let url = APIConfig.getServices
        let parameters: [String: Any] = [
            "hotel_id": hotelId
        ]
        let token = "Bearer \(TokenManager.shared.getUserToken() ?? "")"
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        AF.request(url, parameters: parameters, headers: headers).responseDecodable(of: ServicesResponse.self) { response in
            switch response.result {
            case .success(let servicesResponse):
                if servicesResponse.status == "success"{
                    guard let data = servicesResponse.data else {return}
                    completion(data)
                }else if servicesResponse.status == "error" {
                    if let message = servicesResponse.message, message == "Token expired" {
                        TokenManager.shared.refreshToken { success in
                            if success {
                                self.fetchService(hotelId: hotelId, completion: completion)
                            }else{
                                
                            }
                        }
                    }
                    completion([])
                }
            case .failure(_):
                if let data = response.data, let errorResponse = String(data: data, encoding: .utf8) {
                    print("response data: \(errorResponse)")
                }
                completion([])
            }
        }
    }
   
    func bindService(hotelId: Int){
        fetchService(hotelId: hotelId) { services in
            self.arrService = services
            DispatchQueue.main.async {
                self.collectionService.reloadData()
            }
        }
    }
    
    func reloadPriceService() {
        
        guard let checkIn = tfCheckIn.text, let checkOut = tfCheckOut.text else {return}
        guard let checkin = stringToDate(checkIn), let checkout = stringToDate(checkOut) else {return}
        let numberOfNights = Calendar.current.dateComponents([.day], from: checkin, to: checkout).day ?? 1
        
        lbPriceRoom.text = "\(formatCurrency(price: priceRoom * Double(numberOfNights))) VNĐ"
        priceService = 0
        for service in selectedService {
            priceService += service.price
            
        }
        if selectedService.isEmpty {
            lbPriceService.text = "0 VNĐ"
        }else{
            lbPriceService.text = "\(formatCurrency(price: priceService)) VNĐ"
        }
        total = (priceRoom * Double(numberOfNights)) + priceService
        lbTotal.text = "\(formatCurrency(price: total)) VNĐ"
    }
    
    @IBAction func tapOnBook(_ sender: Any) {
        
        guard let firstName = tfFirstName.text, !firstName.isEmpty else {
            showAlert(title: "", message: "Ban chua nhap firtname")
            return
        }
        guard let lastName = tfLastName.text, !lastName.isEmpty else {
            showAlert(title: "", message: "Ban chua nhap lastname")
            return
        }
        guard let email = tfEmail.text, !email.isEmpty else {
            showAlert(title: "", message: "Ban chua nhap email")
            return
        }
        guard let phoneNumber = tfPhoneNumber.text, !phoneNumber.isEmpty else {
            showAlert(title: "", message: "Ban chua nhap phone number")
            return
        }
        
        showAlert(title: "", message: "Ban da dat phong thanh cong")
    }
}

extension BookingController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrService.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serviceCollectionCell", for: indexPath) as! ServiceCollectionCell
        let data = arrService[indexPath.item]
        
//        cell.imgService.image = UIImage(named: data.imgService)
        cell.lbNameService.text = data.name
        cell.lbPriceService.text = "\(formatCurrency(price: data.price)) vnđ"
        
        if let url = URL(string: data.imageURL) {
            AF.request(url).responseData { response in
                switch response.result {
                case .success(let data):
                    if let image = UIImage(data: data){
                        DispatchQueue.main.async {
                            cell.imgService.image = image
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = ( collectionService.frame.width - 50 ) / 3
        return CGSize(width: w, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ServiceCollectionCell
        
        cell.lbNameService.textColor = UIColor(hex: "#03528A")
        cell.lbPriceService.textColor = UIColor(hex: "#03528A")
        
        let service = arrService[indexPath.item]
        selectedService.append(service)
        reloadPriceService()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ServiceCollectionCell
        cell.lbNameService.textColor = .black
        cell.lbPriceService.textColor = .black
        
        let service = arrService[indexPath.item]
        selectedService.removeAll(where: {$0.id == service.id})
        reloadPriceService()
    }
}

extension BookingController: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let vc = SelectDateController(nibName: "SelectDateController", bundle: nil) as! SelectDateController
        if let checkin = tfCheckIn.text, let checkout = tfCheckOut.text{
            vc.checkInDate = stringToDate(checkin)
            vc.checkOutDate = stringToDate(checkout)
        }
        vc.dateChange = {
            checkInDate, checkOutDate in
            self.tfCheckIn.text = checkInDate
            self.tfCheckOut.text = checkOutDate
            
            print(self.tfCheckIn.text)
            print(self.tfCheckOut.text)
        }
        
        navigationController?.pushViewController(vc, animated: true)
        return false
    }
}
