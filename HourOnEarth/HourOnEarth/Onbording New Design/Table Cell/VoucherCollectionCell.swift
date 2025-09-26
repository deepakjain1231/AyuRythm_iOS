//
//  VoucherCollectionCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 28/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class VoucherCollectionCell: UICollectionViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var view_Inner: UIView!
    @IBOutlet weak var view_innerforColor: UIView!
    @IBOutlet weak var view_offer_prensantage_BG: UIView!
    @IBOutlet weak var lbl_offer_prensantage: UILabel!
    @IBOutlet weak var lbl_ayuseed: UILabel!
    @IBOutlet weak var lbl_couponTitle: UILabel!
    @IBOutlet weak var img_logo: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let arr_gradientColor = [#colorLiteral(red: 0.4235294118, green: 0.7529411765, blue: 0.4078431373, alpha: 1), #colorLiteral(red: 0.7411764706, green: 0.8392156863, blue: 0.1882352941, alpha: 1), #colorLiteral(red: 1, green: 0.862745098, blue: 0.1882352941, alpha: 1)]  //6CC068, //BDD630, //FFDC30
        if let gradientColor = CAGradientLayer.init(frame: view_offer_prensantage_BG.frame, colors: arr_gradientColor, direction: GradientDirection.Right).creatGradientImage() {
            self.view_offer_prensantage_BG.layer.backgroundColor = UIColor.init(patternImage: gradientColor).cgColor
            self.view_offer_prensantage_BG.roundCornerss([.topLeft], radius: 12)
        }
    }

    
    
}
