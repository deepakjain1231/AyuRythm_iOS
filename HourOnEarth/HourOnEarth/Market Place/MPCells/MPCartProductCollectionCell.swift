//
//  MPCartProductCollectionCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 15/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class MPCartProductCollectionCell: UICollectionViewCell {

    @IBOutlet weak var view_forRecommendedBG: UIView!
    
    @IBOutlet weak var lbl_titleL_recommended: UILabel!
    
    @IBOutlet weak var view_quantity_BG: UIView!
    @IBOutlet weak var lbl_quantity: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnAdd.setTitle("", for: .normal)
        self.btnRemove.setTitle("", for: .normal)
        self.view_quantity_BG.layer.cornerRadius = 8
        self.view_quantity_BG.layer.borderWidth = 1
        self.view_quantity_BG.layer.borderColor = kAppBlueColor.cgColor
    }

}
