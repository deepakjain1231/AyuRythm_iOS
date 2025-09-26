//
//  DailyPlannerFirstTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 31/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class DailyPlannerFirstTableCell: UITableViewCell {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    
    @IBOutlet weak var lbl_current_steak: UILabel!
    @IBOutlet weak var lbl_taskDone: UILabel!
    
    @IBOutlet weak var lbl_current_steak_title: UILabel!
    @IBOutlet weak var lbl_taskDone_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_taskDone_title.text = "Task done".localized()
        self.lbl_current_steak_title.text = "Current streak".localized()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
