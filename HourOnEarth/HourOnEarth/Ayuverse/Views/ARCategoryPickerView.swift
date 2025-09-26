//
//  ARCategoryPickerView.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 13/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

// MARK: -
protocol ARCategoryPickerViewDelegate {
    func categoryPickerView(view: ARCategoryPickerView, didSelect category: ARAyuverseCategoryModel)
}

class ARCategoryPickerView: PDDesignableXibView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: ARCategoryPickerViewDelegate?
    var selectedCategory: ARAyuverseCategoryModel?
    var categories = [ARAyuverseCategoryModel]()
    
    override func initialSetUp() {
        super.initialSetUp()
        
        collectionView.register(nibWithCellClass: ARCategoryCell.self)
        collectionView.setupUISpace(top: 12, left: 20, bottom: 12, right: 20, itemSpacing: 16, lineSpacing: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.reloadData()
    }
    
    func reloadData() {
        var scrollInsx = 0
        self.categories = ARAyuverseManager.shared.categories
        
        if let selectedCategory = self.selectedCategory,
            let index = self.categories.firstIndex(where: { $0.name == selectedCategory.name && $0.id == selectedCategory.id }) {
            scrollInsx = index
            self.categories[index].isSelected = true
            self.selectedCategory = self.categories[index]
        } else {
            self.categories.first?.isSelected = true
            self.selectedCategory = self.categories.first
        }
        collectionView.reloadData()
    }
}

extension ARCategoryPickerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = categories[indexPath.row]
        return CGSize(width: category.textWidth + 32, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ARCategoryCell.self, for: indexPath)
        cell.category = categories[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        categories.forEach{ $0.isSelected = false }
        let category = categories[indexPath.row]
        category.isSelected = true
        collectionView.reloadData()
        delegate?.categoryPickerView(view: self, didSelect: category)
    }
}

extension ARCategoryPickerView {
    static func fetchCategoryData(completion: @escaping (_ list: [ARAyuverseCategoryModel])-> Void) {
        let params = ["category_for" : "1"] as [String : Any]
        Utils.doAPICall(endPoint: .getCategoriesList, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            let categories = responseJSON?["data"].array?.compactMap({ ARAyuverseCategoryModel(fromJson: $0) }) ?? []
            completion(categories)
        }
    }
}
