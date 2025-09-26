//
//  SuggestionForActivityTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 29/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class SuggestionForActivityTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var collection_view: UICollectionView!
    @IBOutlet weak var btn_allActivity: UIControl!
    @IBOutlet weak var lbl_button_Title: UILabel!
    @IBOutlet weak var constraint_btn_allActivity_Top: NSLayoutConstraint!
    @IBOutlet weak var constraint_btn_allActivity_height: NSLayoutConstraint!
    
    var cellType = ""
    var arr_Remedies: [HomeRemedies] = [HomeRemedies]()
    
    var didTappedonActivity: ((IsSectionType)->Void)? = nil
    var didTappedonRemedies: ((HomeRemedies)->Void)? = nil
    var didTappedonAllActivity: ((UIControl)->Void)? = nil
    
    var arr_suggestion: [[String: Any]]? {
        didSet {
            self.cellType = ""
            guard let listData = arr_suggestion else {
                return
            }
            self.collection_view.reloadData()
        }
    }
    
    var arr_remedies = [HomeRemedies]() {
        didSet {
            self.cellType = "remedies"
            self.arr_Remedies = arr_remedies
            self.collection_view.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collection_view.register(nibWithCellClass: ActivityCollectionCell.self)
        self.collection_view.delegate = self
        self.collection_view.dataSource = self
        self.lbl_button_Title.text = "View all home remedies".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func btn_AllActivity(_ sender: UIControl) {
        if self.didTappedonAllActivity != nil {
            self.didTappedonAllActivity!(sender)
        }
    }
    
}


//MARK: - UICollection View Delegate Datasource Method
extension SuggestionForActivityTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.cellType == "remedies" {
            return self.arr_Remedies.count
        }
        return self.arr_suggestion?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if self.cellType == "remedies" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityCollectionCell", for: indexPath) as! ActivityCollectionCell
            
            let dicDetail = self.arr_Remedies[indexPath.row]
            let heading = dicDetail.item ?? ""
            cell.lbl_Title.text = heading
            if let imageUrl = dicDetail.image, let url = URL(string: imageUrl) {
                cell.img_icon.af.setImage(withURL: url)
            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityCollectionCell", for: indexPath) as! ActivityCollectionCell
            
            cell.img_icon.image = UIImage.init(named: (self.arr_suggestion?[indexPath.row]["icon"] as? String ?? ""))
            cell.lbl_Title.text = self.arr_suggestion?[indexPath.row]["title"] as? String ?? ""
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.cellType == "remedies" {
            return CGSize.init(width: (self.collection_view.frame.size.width - 36)/3, height: self.collection_view.frame.size.height)
        }
        else {
            return CGSize.init(width: ((self.collection_view.frame.size.width - 36)/3) - 22, height: self.collection_view.frame.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
#if !APPCLIP
        if self.cellType == "remedies" {
            let dicDetail = self.arr_Remedies[indexPath.row]

            if self.didTappedonRemedies != nil {
                self.didTappedonRemedies!(dicDetail)
            }
        }
        else {
            let goal_type = self.arr_suggestion?[indexPath.row]["type"] as? IsSectionType ?? .kriya
            
            if self.didTappedonActivity != nil {
                self.didTappedonActivity!(goal_type)
            }
        }
#endif
    }
}
