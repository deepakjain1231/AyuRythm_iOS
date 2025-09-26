//
//  TopGoalTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 25/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class TopGoalTableCell: UITableViewCell {

    var arr_selectedID = [Int]()
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var collection_view: UICollectionView!
    @IBOutlet weak var constraint_collection_view_Height: NSLayoutConstraint!
    
    var completation: ((_ selected_id: Int, _ selected_unselected: Bool)->Void)? = nil
    
    var arr_goal: [SurveyCuretedList]? {
        didSet {
            guard arr_goal != nil else {
                return
            }
            self.collection_view.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collection_view.register(nibWithCellClass: TopGoalCollectionCell.self)
        self.collection_view.delegate = self
        self.collection_view.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

extension TopGoalTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_goal?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopGoalCollectionCell", for: indexPath) as? TopGoalCollectionCell else {
            return UICollectionViewCell()
        }
        if let listData = self.arr_goal?[indexPath.row] {
            cell.lbl_title.text = listData.title.localized()
            cell.img_icon.image = UIImage(named: listData.image)
            cell.view_inner.backgroundColor = UIColor().hexStringToUIColor(hex: listData.color)
            cell.view_outer.backgroundColor = UIColor().hexStringToUIColor(hex: listData.color)
            
            if self.arr_selectedID.contains(listData.id) {
                cell.view_outer.layer.borderWidth = 1
                cell.view_outer.layer.borderColor = UIColor.black.cgColor
                cell.view_outer.backgroundColor = .clear
            }
            else {
                cell.view_outer.layer.borderWidth = 0
                cell.view_outer.layer.borderColor = UIColor.clear.cgColor
                cell.view_outer.backgroundColor = UIColor().hexStringToUIColor(hex: listData.color)
            }
        }
        
        return cell
            
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let int_width = (screenWidth - 50)/2
        return CGSize.init(width: int_width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let listData = self.arr_goal?[indexPath.row] {
            if let indx = self.arr_selectedID.firstIndex(of: listData.id) {
                self.arr_selectedID.remove(at: indx)
                completation!(listData.id, false)
            }
            else {
                completation!(listData.id, true)
                self.arr_selectedID.append(listData.id)
            }
            self.collection_view.reloadData()
        }
    }
}



//MARK: - New Cell
class Today_Goal_1TableCell: UITableViewCell {

    var arr_selectedID = [Int]()
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var collection_view: UICollectionView!
    @IBOutlet weak var constraint_collection_view_Height: NSLayoutConstraint!
    
    var completation: ((_ selected_id: Int, _ selected_unselected: Bool)->Void)? = nil
    
    var arr_goal: [SurveyCuretedList]? {
        didSet {
            guard arr_goal != nil else {
                return
            }
            self.collection_view.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collection_view.register(nibWithCellClass: TodayGoal_1CollectionCell.self)
        self.collection_view.delegate = self
        self.collection_view.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension Today_Goal_1TableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_goal?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodayGoal_1CollectionCell", for: indexPath) as? TodayGoal_1CollectionCell else {
            return UICollectionViewCell()
        }
        if let listData = self.arr_goal?[indexPath.row] {
            cell.lbl_title.text = listData.title.localized()
            cell.img_icon.image = UIImage(named: listData.image)
            cell.lbl_title.textColor = listData.id == 5 ? .lightGray : .black
            cell.view_inner.backgroundColor = UIColor().hexStringToUIColor(hex: listData.color)
            cell.view_outer.backgroundColor = UIColor().hexStringToUIColor(hex: listData.color)

            if self.arr_selectedID.contains(listData.id) {
                cell.view_outer.layer.borderWidth = 1
                cell.view_outer.layer.borderColor = UIColor.black.cgColor
                cell.view_outer.backgroundColor = .clear
            }
            else {
                cell.view_outer.layer.borderWidth = 0
                cell.view_outer.layer.borderColor = UIColor.clear.cgColor
                cell.view_outer.backgroundColor = UIColor().hexStringToUIColor(hex: listData.color)
            }
        }

        return cell
            
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let int_width = screenWidth
        return CGSize.init(width: int_width, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let listData = self.arr_goal?[indexPath.row] {
            if listData.id == 5 {
                return
            }
            
            if let indx = self.arr_selectedID.firstIndex(of: listData.id) {
                self.arr_selectedID.remove(at: indx)
                completation!(listData.id, false)
            }
            else {
                completation!(listData.id, true)
                self.arr_selectedID.append(listData.id)
            }
            self.collection_view.reloadData()
        }
    }
}



