//
//  Active_Plan_TableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 21/12/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class Active_Plan_TableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_plan_title: UILabel!
    @IBOutlet weak var lbl_plan_type: UILabel!
    @IBOutlet weak var lbl_expire_date: UILabel!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var lbl_day: UILabel!
    @IBOutlet weak var lbl_hour: UILabel!
    @IBOutlet weak var lbl_day_title: UILabel!
    @IBOutlet weak var lbl_hour_title: UILabel!
    @IBOutlet weak var btn_pause: UIButton!
    @IBOutlet weak var constraint_btn_pause_height: NSLayoutConstraint!
    @IBOutlet weak var constraint_btn_pause_top: NSLayoutConstraint!
    @IBOutlet weak var btn_info: UIButton!
    @IBOutlet weak var btn_renew_Now: UIButton!
    @IBOutlet weak var constraint_btn_renew_Now_height: NSLayoutConstraint!
    @IBOutlet weak var constraint_btn_renew_Now_top: NSLayoutConstraint!
    
    var didTappedPauseButton: ((UIButton)->Void)? = nil
    var didTappedRenewButton: ((UIButton)->Void)? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //#C9F4C9, #FFFFFF
        
        let arrcolors = [UIColor.fromHex(hexString: "#FFE7A3"), UIColor.fromHex(hexString: "#FFFFFF")] as? [UIColor] ?? [UIColor.white]
        if let gradientColor = CAGradientLayer.init(frame: self.view_Base.frame, colors: arrcolors, direction: GradientDirection.Bottom).creatGradientImage() {
            self.view_Base.backgroundColor = UIColor.init(patternImage: gradientColor)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func updateUI(dic_active_plan: ARActiveSubscription) {
        self.lbl_plan_type.text = dic_active_plan.packName ?? ""
        self.lbl_expire_date.text = "Exp Date \(dic_active_plan.planExpiryDateString)"
        
        if let planExipresData = dic_active_plan.getPlanExpiresInData() {
            self.lbl_day_title.text = "Days".localized()
            self.lbl_hour_title.text = "Hours".localized()
            self.lbl_day.text = planExipresData.days.stringValue
            self.lbl_hour.text = planExipresData.hours.stringValue
            self.timerView.isHidden = false
        } else {
            self.lbl_day.text = ""
            self.lbl_hour.text = ""
            self.lbl_day_title.text = ""
            self.lbl_hour_title.text = ""
            self.timerView.isHidden = true
        }
        
        if dic_active_plan.isPlanExpired || !self.timerView.isHidden {
            self.btn_renew_Now.setTitle("Renew Now".localized(), for: .normal)
            self.btn_renew_Now.isSelected = false
            self.btn_renew_Now.isHidden = false
            self.constraint_btn_renew_Now_top.constant = 8
            self.constraint_btn_renew_Now_height.constant = 40
        }
        else {
            if dic_active_plan.isPlanPaused {
                self.btn_renew_Now.setTitle("Resume Subscription".localized(), for: .normal)
                self.btn_renew_Now.isSelected = true
                self.btn_renew_Now.isHidden = false
                self.constraint_btn_renew_Now_top.constant = 8
                self.constraint_btn_renew_Now_height.constant = 40
            } else {
                self.btn_pause.isHidden = false
                self.constraint_btn_pause_top.constant = 0
                self.constraint_btn_pause_height.constant = 22
            }
        }
        
        if dic_active_plan.favoriteId == "0" {
            //Free plan from Promocode
            self.btn_pause.isHidden = true
            self.btn_renew_Now.isHidden = true
            self.constraint_btn_pause_top.constant = 0
            self.constraint_btn_pause_height.constant = 0
            self.constraint_btn_renew_Now_top.constant = 0
            self.constraint_btn_renew_Now_height.constant = 0
            //infoBtn.isHidden = true
        }
        
    }
    
    
    // MARK: - UIButton Action
    @IBAction func btn_Pause_Action(_ sender: UIButton) {
        self.didTappedPauseButton?(sender)
    }
    
    @IBAction func btn_Renew_Action(_ sender: UIButton) {
        self.didTappedRenewButton?(sender)
    }
}
