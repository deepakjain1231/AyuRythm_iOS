//
//  TopGoalCollectionCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 25/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class TopGoalCollectionCell: UICollectionViewCell {

    @IBOutlet weak var view_mainBase: UIView!
    @IBOutlet weak var view_outer: UIView!
    @IBOutlet weak var view_inner: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var img_icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    var listData: SurveyCuretedList? {
        didSet {
            guard let listData = listData else {
                return
            }
            self.lbl_title.text = listData.title.localized()
            self.img_icon.image = UIImage(named: listData.image)
            self.view_inner.backgroundColor = UIColor().hexStringToUIColor(hex: listData.color)
            self.view_outer.backgroundColor = UIColor().hexStringToUIColor(hex: listData.color)
        }
    }
}
