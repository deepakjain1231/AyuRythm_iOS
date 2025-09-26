//
//  WellnessJourneyCollectionCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 04/10/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class WellnessJourneyCollectionCell: UICollectionViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var img_logo: UIImageView!
    @IBOutlet weak var img_BG: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.img_BG.layer.cornerRadius = 12
        self.img_BG.layer.masksToBounds = true
    }

}
