//
//  YourProduct_KitCollectionCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 12/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class YourProduct_KitCollectionCell: UITableViewCell {

    @IBOutlet weak var collection_viewkit: UICollectionView!
    @IBOutlet weak var constraint_collection_viewkit_HEIGHT: NSLayoutConstraint!
    
    var didSelectCategory: ((WeeklyPlannerCategoryData)->Void)? = nil
    
    var arr_WeeklyCategory = [WeeklyPlanner_CategoryModel]()
    var categories: [WeeklyPlanner_CategoryModel] = [] {
        didSet {
            self.arr_WeeklyCategory = categories
            self.collection_viewkit.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collection_viewkit.delegate = self
        self.collection_viewkit.dataSource = self
        
        //Register Collection Cell
        self.collection_viewkit.register(nibWithCellClass: ProductCategoryCollectionCell.self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//MARK:- UICollectionView Delegate DataSource Method

extension YourProduct_KitCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_WeeklyCategory.first?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withClass: ProductCategoryCollectionCell.self, for: indexPath)
        cell.titleL.text = self.arr_WeeklyCategory.first?.data[indexPath.row].name
        
        let urlString = self.arr_WeeklyCategory.first?.data[indexPath.row].icon ?? ""
        if let url = URL(string: urlString) {
            cell.picIV.sd_setImage(with: url, placeholderImage: appImage.default_image_placeholder)
        }
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: (collectionView.bounds.size.width/2) - 6, height: 135)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let dic_Detail = self.arr_WeeklyCategory.first?.data[indexPath.row] as? WeeklyPlannerCategoryData {
            self.didSelectCategory!(dic_Detail)
        }
    }
}
