//
//  WeeklyPlannerTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 11/02/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class WeeklyPlannerTableCell: UITableViewCell {

    @IBOutlet weak var btn_click: UIButton!
    @IBOutlet weak var img_banner: UIImageView!
    @IBOutlet weak var view_Base: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        img_banner.layer.cornerRadius = 12
        img_banner.clipsToBounds = true
        img_banner.layer.masksToBounds = true
        self.view_Base.layer.cornerRadius = 12
        self.view_Base.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
