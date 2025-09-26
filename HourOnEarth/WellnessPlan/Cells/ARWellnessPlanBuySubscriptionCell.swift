//
//  ARWellnessPlanBuySubscriptionCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 25/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARWellnessPlanBuySubscriptionCell: UITableViewCell {
    
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var subscribeNowBtn: UIButton!
    @IBOutlet weak var lbl_sub_title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.lbl_sub_title.text = "To discover daily diet plans".localized()
        //imageIV.image = kUserDefaults.isGenderFemale ? #imageLiteral(resourceName: "meditation-female") : #imageLiteral(resourceName: "meditation-male")
    }
}
