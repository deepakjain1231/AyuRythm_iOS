//
//  WellnessPlanDayCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 21/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

// MARK: -
class WellnessPlanDayCell: UICollectionViewCell {
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var lbl_day: UILabel!
    @IBOutlet weak var lbl_dayunderline: UILabel!
    @IBOutlet weak var mainView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.borderWidth = 0
        
    }
    
    func updateCell(isDaySelected: Bool) {
        //mainView.backgroundColor = isDaySelected ? AppColor.app_DarkGreenColor : .white
        if isDaySelected {
            self.lbl_dayunderline.isHidden = false
            self.titleL.textColor = UIColor.fromHex(hexString: "#313131")
            self.lbl_day.textColor = UIColor.fromHex(hexString: "#313131")
            self.titleL.font = UIFont.AppFontOpenSansRegular(15)
            self.lbl_day.font = UIFont.AppFontOpenSansRegular(14)
        }
        else {
            self.lbl_dayunderline.isHidden = true
            self.titleL.font = UIFont.AppFontOpenSansRegular(12)
            self.lbl_day.font = UIFont.AppFontOpenSansRegular(12)
            self.titleL.textColor = UIColor.fromHex(hexString: "#313131").withAlphaComponent(0.8)
            self.lbl_day.textColor = UIColor.fromHex(hexString: "#313131").withAlphaComponent(0.8)
        }
        
        mainView.layoutIfNeeded()
    }
}
