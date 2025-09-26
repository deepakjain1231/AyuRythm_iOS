//
//  NutrisicionCollectionCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 22/02/24.
//  Copyright © 2024 AyuRythm. All rights reserved.
//

import UIKit

class NutrisicionCollectionCell: UICollectionViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var img_icon_BG: UIImageView!
    @IBOutlet weak var lbl_1: UILabel!
    @IBOutlet weak var lbl_2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.img_icon_BG.layer.cornerRadius = 12
        self.img_icon_BG.clipsToBounds = true
        self.img_icon_BG.layer.masksToBounds = true
        
        let BGColors1 = [UIColor.fromHex(hexString: "#DFF8DF"), UIColor.fromHex(hexString: "#FFFFFF")]
        if let gradientColor = CAGradientLayer.init(frame: self.view_Base.frame, colors: BGColors1, direction: GradientDirection.Top).creatGradientImage() {
            self.view_Base.backgroundColor = UIColor.init(patternImage: gradientColor)
        }
    }

}
