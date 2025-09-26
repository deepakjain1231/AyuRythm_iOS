//
//  TodayGoalButtonTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 26/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class TodayGoalButtonTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var btn_Next: UIButton!
    @IBOutlet weak var btn_ClearExit: UIButton!
    
    var didTappedonNext: ((UIButton)->Void)? = nil
    var didTappedonClearExit: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btn_Next.setTitle("Next".localized(), for: .normal)
        self.btn_ClearExit?.setTitle("Clear & Exit".localized(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func btn_NextAction(_ sender: UIButton) {
        if self.didTappedonNext != nil {
            self.didTappedonNext!(sender)
        }
    }
    
    @IBAction func btn_Clear_Exit_Action(_ sender: UIButton) {
        if self.didTappedonClearExit != nil {
            self.didTappedonClearExit!(sender)
        }
    }
}
