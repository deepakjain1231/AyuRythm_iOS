//
//  ShopProductsCell.swift
//  HourOnEarth
//
//  Created by Apple on 20/02/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

enum FlowType {
    case recommended
    case featured
    case none
}

class ShopProductsCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionViewProducts: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!

    var categoriesArray = [[String: Any]]()
    var flowType: FlowType = .none
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionViewProducts.register(UINib(nibName: "ShopProductCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ShopProductCollectionCell")
    }
    
    func configureUI(dataArray: [[String: Any]], flowType: FlowType = .none) {
        self.categoriesArray = dataArray
        self.collectionViewProducts.reloadData()
        self.flowType = flowType
        switch self.flowType {
        case .featured:
            self.lblTitle.text = "Featured Products".localized()
        case .recommended:
            self.lblTitle.text = "Recommended for You".localized()
        case .none:
            self.lblTitle.text = ""
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
           layout collectionViewLayout: UICollectionViewLayout,
           sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.contentView.frame.size.width/3, height: 220)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.categoriesArray.count > 3 {
            return 3
        }
        return self.categoriesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopProductCollectionCell", for: indexPath) as? ShopProductCollectionCell else {
            return UICollectionViewCell()
        }
        cell.configureUI(dicCategory: self.categoriesArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
