//
//  DailyPlannerRoutineTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 31/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class DailyPlannerRoutineTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var view_img_BG: UIView!
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var img_check: UIImageView!
    @IBOutlet weak var btn_check: UIButton!
    
    var didTappedonCheckMark: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view_img_BG.layer.cornerRadius = 12
        self.view_img_BG.layer.masksToBounds = true
        self.view_img_BG.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_check_Action(_ sender: UIButton) {
        if self.didTappedonCheckMark != nil {
            self.didTappedonCheckMark!(sender)
        }
    }
    
}
