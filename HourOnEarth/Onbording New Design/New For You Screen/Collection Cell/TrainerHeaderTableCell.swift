//
//  TrainerHeaderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 25/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class TrainerHeaderTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var lbl_Third: UILabel!
    @IBOutlet weak var lbl_fourth: UILabel!
    @IBOutlet weak var img_Thumb: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.img_Thumb.layer.cornerRadius = 12
        self.img_Thumb.clipsToBounds = true
        self.img_Thumb.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
