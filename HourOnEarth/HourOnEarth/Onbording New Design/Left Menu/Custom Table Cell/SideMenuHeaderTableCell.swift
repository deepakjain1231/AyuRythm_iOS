//
//  SideMenuHeaderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 11/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class SideMenuHeaderTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var view_inner: UIView!
    @IBOutlet weak var img_profile: UIImageView!
    
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_email: UILabel!
    @IBOutlet weak var lbl_mobile: UILabel!
    @IBOutlet weak var view_Pro: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.img_profile.layer.cornerRadius = 45.5
        self.img_profile.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
