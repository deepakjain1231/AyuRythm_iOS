//
//  TrainerCollectionViewCell.swift
//  HourOnEarth
//
//  Created by Ayu on 15/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import CoreData

class TrainerCollectionViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var seeMoreBtn: UIButton!
    
    var dataArray = [Trainer]()
    var delegate: RecommendationSeeAllDelegate?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(nibWithCellClass: TrainerListCell.self)
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0)

    }
    
    func configureUI(title: String, data: [Trainer]) {
        self.lblTitle.text = title.localized()
        self.dataArray = data
        //seeMoreBtn.isHidden = (data.count <= 4)
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count > 4 ? 4 : self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return CGSize(width: (kDeviceWidth - 20)/4, height: (kDeviceWidth - 20)/4 + 25 + 16)
        return CGSize(width: 150, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrainerListCell", for: indexPath) as? TrainerListCell else {
            return UICollectionViewCell()
        }
        let trainer = self.dataArray[indexPath.item]
        
        cell.lockView.isHidden = true
        cell.configureCell(title: trainer.name ?? "", urlString: trainer.image ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let indexValue = self.indexPath else {
            return
        }
        
        let trainer = self.dataArray[indexPath.item]
        if (trainer.access_point == 0 || trainer.redeemed) {
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
