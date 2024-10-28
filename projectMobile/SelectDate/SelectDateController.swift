//
//  SelectDateController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 18/9/24.
//

import UIKit
import FSCalendar

class SelectDateController: BaseView {
    
    @IBOutlet var viewDate: UIView!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var lbCheckOut: UILabel!
    @IBOutlet var lbCheckIn: UILabel!
    var calendar = FSCalendar()
    
    var checkInDate: Date?
    var checkOutDate: Date?
    
    var dateChange: ((String, String) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCalender()
        setupDefaultDates()
        
        navigationItem.title = "Select Dates"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hex: "#03528A")]
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        btnDone.roundCorners(radius: 25)
        btnDone.backgroundColor = UIColor(hex: "#03528A")
    }
    func setupCalender() {
        view.addSubview(calendar)
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.bottomAnchor.constraint(equalTo: viewDate.topAnchor, constant: -60).isActive = true
        calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        calendar.heightAnchor.constraint(equalToConstant: 500).isActive = true
        
        calendar.allowsMultipleSelection = true
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 19)
        
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 19)
        calendar.appearance.weekdayTextColor = UIColor(hex: "#03528A")
        
        calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 19)
        calendar.appearance.headerTitleColor = UIColor(hex: "#03528A")
        
        
        calendar.delegate = self
        calendar.dataSource = self
    }
    
    func setupView() {
        
        let containerView = UIView()
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        containerView.addSubview(viewDate)
        
        containerView.layer.shadowColor = UIColor.black.cgColor  // Màu của bóng đổ (đen)
        containerView.layer.shadowOffset = CGSize(width: 0, height: -5)  // Độ lệch của bóng, ngang và dọc
        containerView.layer.shadowOpacity = 0.3  // Độ trong suốt của bóng
        containerView.layer.shadowRadius = 10  // Bán kính làm mờ bóng
        containerView.layer.masksToBounds = false  // Đảm bảo view không cắt bóng
        
        viewDate.layer.masksToBounds = true
        viewDate.layer.cornerRadius = 15
        
    }
    
    @IBAction func tapOnDone(_ sender: Any) {
        print("da chon done")
        
        guard let checkIn = lbCheckIn.text, !checkIn.isEmpty else {
            if let checkOut = lbCheckOut.text, checkOut.isEmpty {
                self.showAlert(title: "", message: "Ban chua chon ngay check-in va check-out")
                return
            }else{
                self.showAlert(title: "", message: "Ban chua chon ngay check-in")
                return
            }
        }
        
        guard let checkOut = lbCheckOut.text, !checkOut.isEmpty else {
            self.showAlert(title: "", message: "Ban chua chon ngay check-out")
            return
        }
        
        
        if let closure = dateChange {
            closure(checkIn, checkOut)
        }
        navigationController?.popViewController(animated: true)
    }
//    
//    func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        return formatter.string(from: date)
//    }
//    
//    func stringToDate(_ dateString: String) -> Date? {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        return formatter.date(from: dateString)
//    }
    
    func setupDefaultDates() {
        
        if let checkIn = checkInDate {
            lbCheckIn.text = formatDate(checkIn)
            calendar.select(checkInDate)
        }
        if let checkOut = checkOutDate {
            lbCheckOut.text = formatDate(checkOut)
            calendar.select(checkOutDate)
        }
    }
}
extension SelectDateController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        handleDateSelection(date)
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        handleDateDeselection(date)
    }
    
    private func handleDateSelection(_ date: Date) {
        let selectedDate = Calendar.current.startOfDay(for: date)
        
        if checkInDate == nil {
            
            if let checkout = checkOutDate{
                if selectedDate < checkout
                {
                    checkInDate = selectedDate
                    lbCheckIn.text = formatDate(selectedDate)
                }else{
                    calendar.deselect(date)
                    calendar.reloadData()
                }
            }
            else {
                checkInDate = selectedDate
                lbCheckIn.text = formatDate(selectedDate)
            }
        } else if checkOutDate == nil {
            // Chọn ngày check-out nếu lớn hơn check-in
            if selectedDate > checkInDate! {
                checkOutDate = selectedDate
                lbCheckOut.text = formatDate(selectedDate)
            }else{
                calendar.deselect(checkInDate!)
                checkInDate = selectedDate
                lbCheckIn.text = formatDate(selectedDate)
                checkOutDate = nil
                lbCheckOut.text = ""
            }
        } else {
            // Đã chọn cả hai ngày, reset lại
            calendar.deselect(checkInDate!)
            calendar.deselect(checkOutDate!)
            checkInDate = selectedDate
            lbCheckIn.text = formatDate(selectedDate)
            checkOutDate = nil
            lbCheckOut.text = ""
        }
    }
    
    private func handleDateDeselection(_ date: Date) {
        let deselectedDate = Calendar.current.startOfDay(for: date)
        
        if checkInDate == deselectedDate {
            checkInDate = nil
            lbCheckIn.text = ""
        } else if checkOutDate == deselectedDate {
            checkOutDate = nil
            lbCheckOut.text = ""
        }
        
    }
    
    
    
    
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return date >= Date()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        if date < Date() {
            return UIColor.lightGray // Màu cho các ngày không thể chọn
        }
        return UIColor.black // Màu cho các ngày có thể chọn
        
    }
}
