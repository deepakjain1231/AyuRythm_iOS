//
//  PlayListCollectionViewCell.swift
//  HourOnEarth
//
//  Created by Apple on 17/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import CoreData

class PlayListCollectionViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var dataArray = [PlayList]()
    var delegate: RecommendationSeeAllDelegate?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0)
        self.collectionView.register(nibWithCellClass: PlayListCell.self)
    }
    
    func configureUI(title: String, data: [PlayList]) {
        self.lblTitle.text = title.localized()
        self.dataArray = data
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count > 4 ? 4 : self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
        //return CGSize(width: (kDeviceWidth - 20)/4, height: (kDeviceWidth - 20)/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayListCell", for: indexPath) as? PlayListCell else {
            return UICollectionViewCell()
        }
        let playList = self.dataArray[indexPath.item]
        if playList.access_point > 0 {
            cell.lockView.isHidden = playList.redeemed
        }
        else {
            cell.lockView.isHidden = true
        }
        cell.configureCell(title: playList.name ?? "", urlString: playList.detail_image ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let indexValue = self.indexPath else {
            return
        }
        
        let playList = self.dataArray[indexPath.item]
        if (playList.access_point == 0 || playList.redeemed) {
            delegate?.didSelectedSelectRow(indexPath: indexValue, index: indexPath.item)
        } else {
            delegate?.didSelectedSelectRowForRedeem(indexPath: indexValue, index: indexPath.item)
        }
    }
    
    @IBAction func seeMoreClicked(_ sender: UIButton) {
        guard let indexPath = self.indexPath else {
            return
        }
        delegate?.didSelectedSelectRow(indexPath: indexPath, index: nil)
    }

}
