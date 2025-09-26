//
//  ProductHeaderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 21/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ProductHeaderTableCell: UITableViewCell {

    @IBOutlet weak var lbl_weekName: UILabel!
    @IBOutlet weak var view_weekName_BG: UIView!
    @IBOutlet weak var lbl_TimeSlot: UILabel!
    @IBOutlet weak var constraint_lbl_TimeSlot_leading: NSLayoutConstraint!
    @IBOutlet weak var constraint_Text_Bottom_leading: NSLayoutConstraint!
    @IBOutlet weak var constraint_Text_Top_leading: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
