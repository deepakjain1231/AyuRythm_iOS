//
//  MPImageCollectionCell.swift
//  HourOnEarth
//
//  Created by Maulik Vora on 17/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MPImageCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imgP: UIImageView!
    @IBOutlet weak var img_playPause: UIImageView!
    @IBOutlet weak var viewOutOfStockGradientColor: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        img_playPause.isHidden = true
    }

}
