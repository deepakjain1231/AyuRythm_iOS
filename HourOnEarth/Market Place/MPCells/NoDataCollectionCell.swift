//
//  NoDataCollectionCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 14/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class NoDataCollectionCell: UICollectionViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var view_BG: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var btn_ShopNow: UIControl!
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var constraint_lbl_Title_TOP: NSLayoutConstraint!
    
    var did_TappedShopNow: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btn_ShopNow.isHidden = true
    }
    
    @IBAction func btn_ShopNow_Action(_ sender: UIControl) {
        self.did_TappedShopNow!(sender)
    }
    
}
