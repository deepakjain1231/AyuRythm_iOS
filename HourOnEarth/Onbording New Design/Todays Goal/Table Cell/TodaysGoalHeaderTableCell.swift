//
//  TodaysGoalHeaderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 24/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class TodaysGoalHeaderTableCell: UITableViewCell {

    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var comstraint_lbl_subTitle_Top: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
