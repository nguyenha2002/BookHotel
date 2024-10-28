//
//  SortController.swift
//  projectMobile
//
//  Created by Nguyễn Thị Hạ on 17/10/24.
//

import UIKit

class Sort {
    var nameSort: String
    
    init(nameSort: String) {
        self.nameSort = nameSort
    }
}


class SortController: UIViewController {

    
    var sortData: ((String) -> Void)?
    var selectedIndex: Int?
    var arrSort = [Sort]()
    @IBOutlet weak var sortTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTable()
        bindData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func setupTable() {
        let nib = UINib(nibName: "SortTableCell", bundle: nil)
        sortTable.register(nib, forCellReuseIdentifier: "sortTableCell")
        
        sortTable.delegate = self
        sortTable.dataSource = self
    }
    
    func bindData(){
        let ratingDesc = Sort(nameSort: "Rating (desc)")
        let ratingAsc = Sort(nameSort: "Rating (asc)")
        let priceDesc = Sort(nameSort: "Price (desc)")
        let priceAsc = Sort(nameSort: "Price (asc)")
        let numberReviewDesc = Sort(nameSort: "Number review (desc)")
        let numberReviewAsc = Sort(nameSort: "Number review (asc)")
        
        arrSort.append(ratingDesc)
        arrSort.append(ratingAsc)
        arrSort.append(priceDesc)
        arrSort.append(priceAsc)
        arrSort.append(numberReviewDesc)
        arrSort.append(numberReviewAsc)
        
        sortTable.reloadData()
    }

}

extension SortController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSort.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sortTable.dequeueReusableCell(withIdentifier: "sortTableCell", for: indexPath) as! SortTableCell
        let data = arrSort[indexPath.row]
        
        cell.onRadioButtonTapped = { [self] in
           handleRadioButtonTapped(at: indexPath)
        }
        
        if indexPath.row == selectedIndex {
            cell.radioButton.setImage(UIImage(named: "radio_fill"), for: .normal)
        }else{
            cell.radioButton.setImage(UIImage(named: "radio"), for: .normal)
        }
        
        
        cell.lbName.text = data.nameSort
        
        
        return cell
        
    }
    
    func handleRadioButtonTapped(at indexPath: IndexPath){
        selectedIndex = indexPath.row
        print(arrSort[indexPath.row].nameSort)
        sortTable.reloadData()
        if let data = sortData {
            data(arrSort[indexPath.row].nameSort)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
