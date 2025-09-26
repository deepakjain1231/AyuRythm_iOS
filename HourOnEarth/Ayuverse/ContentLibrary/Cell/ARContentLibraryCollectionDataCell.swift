//
//  ARContentLibraryCollectionDataCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 02/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

// MARK: -
protocol ARContentLibraryCollectionDataCellDelegate {
    func contentLibraryCollectionDataCell(cell: ARContentLibraryCollectionDataCell, didSelect item: ARContentLibraryDataModel , ofContent content: ARContentModel?)
}

class ARContentLibraryCollectionDataCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: ARContentLibraryCollectionDataCellDelegate?
    var items: [ARContentLibraryDataModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var data: ARContentModel? {
        didSet {
            guard let data = data else { return }
            
            items = data.items
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        collectionView.register(nibWithCellClass: ARContentLibraryCollectionItemCell.self)
        collectionView.register(nibWithCellClass: HOEFoodCell.self)
        collectionView.register(nibWithCellClass: RemediesNewCell.self)
        collectionView.setupUISpace(top: 12, left: 20, bottom: 12, right: 20, itemSpacing: 16, lineSpacing: 16)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.reloadData()
    }
    
}

extension ARContentLibraryCollectionDataCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.size.height
        return CGSize(width: height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ARContentLibraryCollectionItemCell.self, for: indexPath)
        let contentType = data?.type ?? .food
        let item = items[indexPath.row]
        cell.nameL.isHidden = false
        if contentType == .homeRemedies {
            cell.nameL.text = item.name
            cell.imageIV.contentMode = .scaleAspectFit
            cell.topPaddingConst.constant = 8
        } else if contentType == .herbs {
            cell.nameL.isHidden = true
            cell.imageIV.contentMode = .scaleAspectFill
            cell.topPaddingConst.constant = 0
        } else {
            cell.nameL.text = item.foodTypes
            cell.imageIV.contentMode = .scaleAspectFill
            cell.topPaddingConst.constant = 0
        }
        cell.imageIV.af_setImage(withURLString: item.image)
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        delegate?.contentLibraryCollectionDataCell(cell: self, didSelect: item, ofContent: data)
    }
}
