//
//  DailyPlannerSecondTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 31/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class DailyPlannerSecondTableCell: UITableViewCell {

    var int_selectedIndex = 0
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var collection_view: UICollectionView!
    
    var didCompliatation: ((Int)->Void)? = nil
    
    var arr_DayDate: [[String: Any]]? {
        didSet {
            guard let listData = arr_DayDate else {
                return
            }
            self.collection_view.reloadData()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collection_view.register(nibWithCellClass: DailyPlannerCollectionCell.self)
        self.collection_view.delegate = self
        self.collection_view.dataSource = self
        self.collection_view.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


//MARK: - UICollectionView Delegate Datasource Method
extension DailyPlannerSecondTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_DayDate?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyPlannerCollectionCell", for: indexPath) as! DailyPlannerCollectionCell
        
        let str_Date = self.arr_DayDate?[indexPath.row]["date"] as? String ?? ""
        if  str_Date.contains(" ") {
            let arrData = str_Date.components(separatedBy: " ")
            cell.lbl_day.text = arrData.first ?? ""
            cell.lbl_date.text = arrData.last ?? ""
        }
        else {
            cell.lbl_day.text = str_Date
            cell.lbl_date.text = str_Date
        }

        if self.int_selectedIndex == indexPath.row {
            cell.view_Base.backgroundColor = UIColor.fromHex(hexString: "#FFE7D6")
        }
        else {
            cell.view_Base.backgroundColor = .clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 50, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didCompliatation!(indexPath.row)
        self.int_selectedIndex = indexPath.row
        self.collection_view.reloadData()
    }
}
