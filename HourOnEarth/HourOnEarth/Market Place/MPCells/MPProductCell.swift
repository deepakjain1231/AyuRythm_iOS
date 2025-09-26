//
//  MPProductCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 12/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class MPProductCell: UICollectionViewCell {
    
    
    @IBOutlet weak var view_forRecommendedBG: UIView!
    @IBOutlet weak var lbl_titleL_recommended: UILabel!
    @IBOutlet weak var img_product_recommended: UIImageView!
    @IBOutlet weak var lbl_off_recommended: UILabel!
    @IBOutlet weak var lbl_old_Price_recommended: UILabel!
    @IBOutlet weak var lbl_currentPrice_recommended: UILabel!
    @IBOutlet weak var btn_AddTocart_recommended: UIControl!
    
    
    @IBOutlet weak var btnRating: UIButton!
    @IBOutlet weak var btnRating_BG: UIView!
    
    @IBOutlet weak var view_DefaultBG: UIView!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var img_product: UIImageView!
    @IBOutlet weak var lbl_off: UILabel!
    @IBOutlet weak var lbl_old_Price: UILabel!
    @IBOutlet weak var lbl_currentPrice: UILabel!
    @IBOutlet weak var btn_AddTocart: UIButton!
    @IBOutlet weak var view_AddTocartBG: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
