//
//  MPProductChooseSizeCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 08/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class MPProductChooseSizeCell: UITableViewCell {
    
    var str_ScreenType = ScreenType.k_none
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var data = ["1 Kg", "500 gms", "1000 gms", "pack of 2", "pack of 3", "Orange"]
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setupUISpace(allSide: 0, itemSpacing: 0, lineSpacing: 8)
        collectionView.register(nibWithCellClass: MPSizeCollectionCell.self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.reloadData()
    }
    
}


extension MPProductChooseSizeCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MPSizeCollectionCell.self, for: indexPath)
        cell.viewBG.layer.borderWidth = 1;
        cell.viewBG.layer.borderColor = kAppBlueColor.cgColor
        cell.lbl_title.text = data[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
