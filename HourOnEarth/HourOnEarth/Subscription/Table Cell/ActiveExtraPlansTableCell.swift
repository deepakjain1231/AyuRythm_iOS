//
//  ActiveExtraPlansTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 28/12/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class ActiveExtraPlansTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_plan_title: UILabel!
    @IBOutlet weak var lbl_plan_type: UILabel!
    @IBOutlet weak var lbl_expire_date: UILabel!
    @IBOutlet weak var img_plan_type: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //#C9F4C9, #FFFFFF
        
        self.view_Base.layer.borderColor = UIColor.fromHex(hexString: "#89BF89").cgColor
        let arrcolors = [UIColor.fromHex(hexString: "#C9F4C9"), UIColor.fromHex(hexString: "#FFFFFF")] as? [UIColor] ?? [UIColor.white]
        if let gradientColor = CAGradientLayer.init(frame: self.view_Base.frame, colors: arrcolors, direction: GradientDirection.Bottom).creatGradientImage() {
            self.view_Base.backgroundColor = UIColor.init(patternImage: gradientColor)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func updateUI(dic_active_plan: ARActiveSubscription) {
        self.lbl_plan_title.text = dic_active_plan.subscription_name
        self.lbl_plan_type.text = dic_active_plan.packName ?? ""
        self.lbl_expire_date.text = "Exp Date \(dic_active_plan.planExpiryDateString)"
        
        var str_imgName = ""
        let str_Subscription_Name = dic_active_plan.subscription_name.lowercased()
        if str_Subscription_Name == kSubscription_Name_Type.prime.rawValue {
            str_imgName = "icon_prime_logo"
        }
        else if str_Subscription_Name == kSubscription_Name_Type.facenaadi.rawValue {
            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                let gender = (empData["gender"] as? String ?? "")
                if gender == "Female" {
                    str_imgName = "icon_female_face_assessment"
                }
                else {
                    str_imgName = "icon_face_assessment_male"
                }
            }
        }
        else if str_Subscription_Name == kSubscription_Name_Type.sparshna.rawValue {
            str_imgName = "icon_finger_assessment"
        }
        else if str_Subscription_Name == kSubscription_Name_Type.ayuMonk.rawValue {
            str_imgName = "icon_ayumonk_logoo"
        }
        else if str_Subscription_Name == kSubscription_Name_Type.remedies.rawValue {
            str_imgName = "icon_remediesss_logo"
        }
        else if str_Subscription_Name == kSubscription_Name_Type.diet_plan.rawValue {
            str_imgName = "icon_food_plan_list"
        }
        
        self.img_plan_type.image = UIImage.init(named: str_imgName)
    }

}
