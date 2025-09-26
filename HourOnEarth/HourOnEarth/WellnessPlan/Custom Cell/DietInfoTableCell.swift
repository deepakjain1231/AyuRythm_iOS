//
//  DietInfoTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 23/02/24.
//  Copyright © 2024 AyuRythm. All rights reserved.
//

import UIKit

class DietInfoTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var img_icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
