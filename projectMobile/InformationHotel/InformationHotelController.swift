//
//  InformationHotelController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 8/9/24.
//

import UIKit
import MapKit
import Alamofire

struct Infor {
    var nameInfor: String
    
    init(nameInfor: String) {
        self.nameInfor = nameInfor
    }
}
class InformationHotelController: BaseView {
    
    
    var hotelDetail: Hotels!
    var arrAmenities = [Amenity]()
    var arrInfor = [Infor]()
    
    @IBOutlet var imgStar: UIImageView!
    @IBOutlet var avgStar: UILabel!
    @IBOutlet var addressHotel: UILabel!
    
    @IBOutlet var lbPrice: UILabel!
    @IBOutlet var btnChooseRooms: UIButton!
    @IBOutlet var tableInformation: UITableView!

    @IBOutlet var lbNameHotel: UILabel!
    
    @IBOutlet var lbCheckOut: UILabel!
    @IBOutlet var lbCheckIn: UILabel!
    @IBOutlet var mapKit: MKMapView!
    @IBOutlet var lbLocation: UILabel!
    @IBOutlet var viewCheckOut: UIView!
    @IBOutlet var viewCheckIn: UIView!
    @IBOutlet var btnChange: UIButton!
    @IBOutlet var lbBooking: UILabel!
    @IBOutlet var stackDate: UIStackView!
    @IBOutlet var amenitiesCollection: UICollectionView!
    @IBOutlet var imgHotel: UIImageView!
    @IBOutlet var viewInformation: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        btnChooseRooms.roundCorners(radius: 15)
        // Do any additional setup after loading the view.
        setupViewInformation()
        setupCollection()
        setupTable()
        bindDataTable()
        setupView()
        setupDefaultDates()
        print("\(Int(hotelDetail.id)!)")
        bindAmenities(for: Int(hotelDetail.id)!)
        
        print(lbCheckIn.text!)
        viewInformation.backgroundColor = UIColor(hex: "#f2f4f8")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    func setupViewInformation(){
        viewInformation.translatesAutoresizingMaskIntoConstraints = false
        
        viewInformation.topAnchor.constraint(equalTo: imgHotel.bottomAnchor, constant: -40).isActive = true
        viewInformation.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        viewInformation.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        viewInformation.heightAnchor.constraint(equalToConstant: 230).isActive = true
        
        viewInformation.backgroundColor = UIColor(hex: "#f8f6f7")
        viewInformation.roundCorners(radius: 15)
        
        stackDate.translatesAutoresizingMaskIntoConstraints = false
        stackDate.topAnchor.constraint(equalTo: imgHotel.bottomAnchor, constant: 210).isActive = true
        stackDate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        stackDate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        stackDate.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        lbBooking.translatesAutoresizingMaskIntoConstraints = false
        btnChange.translatesAutoresizingMaskIntoConstraints = false
        
        lbBooking.widthAnchor.constraint(equalTo: stackDate.widthAnchor, multiplier: 0.77).isActive = true
        
        viewCheckIn.layer.borderWidth = 0.5
        viewCheckIn.layer.borderColor = UIColor.systemGray2.cgColor
        viewCheckIn.roundCorners(radius: 15)
        
        viewCheckOut.layer.borderWidth = 0.5
        viewCheckOut.layer.borderColor = UIColor.systemGray2.cgColor
        viewCheckOut.roundCorners(radius: 15)
        
        lbLocation.translatesAutoresizingMaskIntoConstraints = false
        lbLocation.topAnchor.constraint(equalTo: stackDate.bottomAnchor, constant: 75).isActive = true
        lbLocation.leadingAnchor.constraint(equalTo: stackDate.leadingAnchor).isActive = true
        lbLocation.trailingAnchor.constraint(equalTo: stackDate.trailingAnchor).isActive = true
        lbLocation.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupMap(){
        
        mapKit.roundCorners(radius: 15)
        
        guard let address = addressHotel.text, !address.isEmpty else {
            print("Địa chỉ không hợp lệ.")
            return
        }
        getCoordinates(forAddress: address) { location in
            guard let location = location else {
                print("Không tìm thấy địa chỉ.")
                return
            }
            print(location)
            // Thiết lập vùng hiển thị trên bản đồ
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.mapKit.setRegion(region, animated: true)
            
            // Thêm marker vào bản đồ
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = address
            self.mapKit.addAnnotation(annotation)
        }
    }
    
    
    func getCoordinates(forAddress address: String, completion: @escaping (CLLocation?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Lỗi khi chuyển đổi địa chỉ: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?.first, let location = placemark.location else {
                print("Không tìm thấy địa chỉ.")
                completion(nil)
                return
            }
            
            completion(location)
        }
    }

    
    func setupView() {
        if let hotelDetail = hotelDetail {
            if let url = URL(string: hotelDetail.imageUrl) {
                URLSession.shared.dataTask(with: url) {
                    [weak self] data, response, error in
                    if let error = error {
                        return
                    }
                        guard let data = data, let image = UIImage(data: data) else {return}
                        DispatchQueue.main.async {
                            self?.imgHotel.image = image
                            self?.lbNameHotel.text = hotelDetail.name
                            self?.addressHotel.text = hotelDetail.location
                            self?.lbPrice.text = self?.formatCurrency(price: hotelDetail.pricePerNight) ?? ""
                            if let avgDouble = Double(hotelDetail.averageRating) {
                                let roundedRating = Double(round(100 * avgDouble) / 100)
                                if roundedRating == 0.00 {
                                    self?.imgStar.image = UIImage(named: "star_0")
                                    self?.avgStar.text = "0.00"
                                }else{
                                    self?.imgStar.image = UIImage(named: "star_yellow")
                                    self?.avgStar.text = String(format: "%.2f", roundedRating)
                                }
                            }
                            self?.setupMap()
                        }
                }.resume()
            }
        }
    }
    
    func setupTable(){
        tableInformation.dataSource = self
        tableInformation.delegate = self
        
        let nib = UINib(nibName: "InformationTableCell", bundle: nil)
        tableInformation.register(nib, forCellReuseIdentifier: "informationTableCell")
    }
    
    func bindDataTable(){
        let a = Infor(nameInfor: "Food & drinks")
        let a1 = Infor(nameInfor: "Service")
        let a2 = Infor(nameInfor: "Hotel rules")
        let a3 = Infor(nameInfor: "Contact us")
        
        arrInfor.append(a)
        arrInfor.append(a1)
        arrInfor.append(a2)
        arrInfor.append(a3)
        
        tableInformation.reloadData()
    }
    
    func setupCollection(){
        amenitiesCollection.delegate = self
        amenitiesCollection.dataSource = self
        
        let nib = UINib(nibName: "AmenitiesCollectionCell", bundle: nil)
        amenitiesCollection.register(nib, forCellWithReuseIdentifier: "amenitiesCollectionCell")
    }
//    
//    func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.timeZone = TimeZone.current
//        return formatter.string(from: date)
//    }
    public func setupDefaultDates() {
        let currentDate = Date()
        let calendarInstance = Calendar.current
        lbCheckIn.text = formatDate(currentDate)
        
        if let nextDay = calendarInstance.date(byAdding: .day, value: 1, to: currentDate) {
            lbCheckOut.text = formatDate(nextDay)
        }
    }

    
    func fetchData(hotelId: Int, completion: @escaping ([Amenity]) -> Void) {
        let url = "\(APIConfig.getAmenitiesURL)?hotel_id=\(hotelId)"
        
        AF.request(url, method: .get).responseDecodable( of: AmenitiesResponse.self) { response in
            switch response.result {
            case .success(let amenitiesResponse):
                completion(amenitiesResponse.data.amenities)
            case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                        if let data = response.data, let errorResponse = String(data: data, encoding: .utf8) {
                            print("Response data: \(errorResponse)")
                        }
                        completion([])
                    }
        }
    }
    
    func bindAmenities(for hotelId: Int) {
        fetchData(hotelId: hotelId) { [weak self] amenities in
            self?.arrAmenities = amenities
            DispatchQueue.main.async {
                self?.amenitiesCollection.reloadData()
            }
        }
    }
    
//    func stringToDate(_ dateString: String) -> Date? {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
////        formatter.locale = Locale(identifier: "vi")
//        formatter.timeZone = TimeZone.current
//        return formatter.date(from: dateString)
//    }
    
    @IBAction func tapOnChangeDate(_ sender: Any) {
        let vc = SelectDateController(nibName: "SelectDateController", bundle: nil)
        
        //truyen du lieu sang selectDate
        if let checkInDate = stringToDate(lbCheckIn.text!), let checkOutDate = stringToDate(lbCheckOut.text!) {
               vc.checkInDate = checkInDate
               vc.checkOutDate = checkOutDate
           }
        print(vc.checkInDate)
        print(vc.checkOutDate)
        //nhan du lieu tu selectData tra ve
        
        vc.dateChange = { [weak self] checkIn, checkOut in
            self!.lbCheckIn.text = checkIn
            self!.lbCheckOut.text = checkOut
            
        }
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func tapOnChooseRooms(_ sender: Any) {
        
        let vc = ChooseRoomController(nibName: "ChooseRoomController", bundle: nil) as ChooseRoomController
//        vc.checkInDate = stringToDate(lbCheckIn.text!)
//        vc.checkOutDate = stringToDate(lbCheckOut.text!)
        vc.hotelId = Int(hotelDetail.id)
        vc.checkInDate = lbCheckIn.text!
        vc.checkOutDate = lbCheckOut.text!
        
        let check_in = stringToDate(lbCheckIn.text!)
        DateData.shared.checkIn = check_in
        DateData.shared.checkOut = stringToDate(lbCheckOut.text!)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension InformationHotelController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrAmenities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = amenitiesCollection.dequeueReusableCell(withReuseIdentifier: "amenitiesCollectionCell", for: indexPath) as! AmenitiesCollectionCell
        let data = arrAmenities[indexPath.item]
        
        if let url = URL(string: data.imgAmenities) {
            URLSession.shared.dataTask(with: url) {
                [weak self] data, response, error in
                if let error = error {
                    return
                }
                guard let data = data, let image = UIImage(data: data) else {return}
                
                DispatchQueue.main.async {
                    cell.imgAmenities.image = image
                }
            }.resume()
        }
        cell.lbNameAmenities.text = data.nameAmenities
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (amenitiesCollection.frame.width - 40) / 4
        return CGSize(width: w, height: 60)
    }
}

extension InformationHotelController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrInfor.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableInformation.dequeueReusableCell(withIdentifier: "informationTableCell") as! InformationTableCell
        let data = arrInfor[indexPath.row]
        
        cell.lbNameInformation.text = data.nameInfor
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


class DateData {
    static let shared = DateData()
    
    private init() {}
    
    var checkIn: Date?
    var checkOut: Date?
}
