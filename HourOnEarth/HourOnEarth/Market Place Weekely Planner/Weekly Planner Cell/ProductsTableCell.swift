//
//  ProductsTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 13/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ProductsTableCell: UITableViewCell {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var lbl_wantApplyTitle: UILabel!
    @IBOutlet weak var lbl_Apply: UILabel!
    @IBOutlet weak var img_Product: UIImageView!
    @IBOutlet weak var collection_days: UICollectionView!
    
    var arr_Weekly = [String]()
    var week_Name: [String] = [] {
        didSet {
            self.arr_Weekly = week_Name
            self.collection_days.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collection_days.delegate = self
        collection_days.dataSource = self
        
        //Register Colllection cell
        self.collection_days.register(nibWithCellClass: WeekCollectionCell.self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//MARK: - UICollectionView Delegate DataSource Method
extension ProductsTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_Weekly.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCollectionCell", for: indexPath) as! WeekCollectionCell
        cell.lbl_weekName.text = self.arr_Weekly[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 50, height: collectionView.bounds.size.height)
    }
}
