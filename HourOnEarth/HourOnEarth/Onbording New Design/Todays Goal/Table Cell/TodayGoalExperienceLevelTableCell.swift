//
//  TodayGoalExperienceLevelTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 27/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class TodayGoalExperienceLevelTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet var view_beginner_outer: UIView!
    @IBOutlet var view_intermideate_outer: UIView!
    @IBOutlet var view_advanced_outer: UIView!
    
    @IBOutlet weak var lbl_beginger: UILabel!
    @IBOutlet weak var lbl_Intermiddiate: UILabel!
    @IBOutlet weak var lbl_advance: UILabel!
    
    @IBOutlet var view_beginner_Ineer: UIView!
    @IBOutlet var view_intermideate_Ineer: UIView!
    @IBOutlet var view_advanced_Ineer: UIView!
    
    @IBOutlet var constraint_img_beginner_Ineer: NSLayoutConstraint!
    @IBOutlet var constraint_img_intermidiate_Ineer: NSLayoutConstraint!
    @IBOutlet var constraint_img_advances_Ineer: NSLayoutConstraint!
    
    var didTappedonLevel: ((UIControl)->Void)? = nil
//    var didTappedonIntermidiate: ((UIControl)->Void)? = nil
//    var didTappedonAdvanced: ((UIControl)->Void)? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_beginger.text = "Beginner".localized()
        self.lbl_Intermiddiate.text = "Intermediate".localized()
        self.lbl_advance.text = "Advanced".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    
    //MARK: - UIButton Action
    @IBAction func btn_beginner_Action(_ sender: UIControl) {
        if self.didTappedonLevel != nil {
            self.didTappedonLevel!(sender)
        }
    }
    
    @IBAction func btn_intermidiate_Action(_ sender: UIControl) {
        if self.didTappedonLevel != nil {
            self.didTappedonLevel!(sender)
        }
    }
    
    @IBAction func btn_advanced_Action(_ sender: UIControl) {
        if self.didTappedonLevel != nil {
            self.didTappedonLevel!(sender)
        }
    }
    
}
