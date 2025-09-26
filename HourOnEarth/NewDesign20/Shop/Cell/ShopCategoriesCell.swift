//
//  ShopCategoriesCell.swift
//  HourOnEarth
//
//  Created by Apple on 20/02/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class ShopCategoriesCell: UITableViewCell, UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var collectionViewCategories: UICollectionView!
    
    var categoriesArray = [[String: Any]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionViewCategories.register(UINib(nibName: "ShopCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShopCollectionViewCell")
    }
    
    func configureUI(dataArray: [[String: Any]]) {
        self.categoriesArray = dataArray
        self.collectionViewCategories.reloadData()
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoriesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopCollectionViewCell", for: indexPath) as? ShopCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureUI(dicCategory: self.categoriesArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
