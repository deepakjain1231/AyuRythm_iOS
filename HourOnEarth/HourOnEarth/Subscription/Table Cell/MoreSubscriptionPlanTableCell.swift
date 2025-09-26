//
//  MoreSubscriptionPlanTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 28/12/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class MoreSubscriptionPlanTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var img_view_BG: UIImageView!
    @IBOutlet weak var lbl_plan_title: UILabel!
    @IBOutlet weak var lbl_plan_sub_Title: UILabel!
    @IBOutlet weak var lbl_view_Details: UILabel!
    @IBOutlet weak var img_arrow: UIImageView!
    @IBOutlet weak var img_plan_Type: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view_Base.layer.cornerRadius = 12
        self.view_Base.clipsToBounds = true
        self.view_Base.layer.masksToBounds = true
        //#C9F4C9, #FFFFFF
        
        //        let arrcolors = [UIColor.fromHex(hexString: "#FFE7A3"), UIColor.fromHex(hexString: "#FFFFFF")] as? [UIColor] ?? [UIColor.white]
        //        if let gradientColor = CAGradientLayer.init(frame: self.view_Base.frame, colors: arrcolors, direction: GradientDirection.Bottom).creatGradientImage() {
        //            self.view_Base.backgroundColor = UIColor.init(patternImage: gradientColor)
        //        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateUI(dic_plan_data: ARSubscriptionPlanModel) {
        self.lbl_plan_title.text = dic_plan_data.subscription_name
        let str_Start_Price = dic_plan_data.amount.priceValueString
        let strText = String.init(format: "Starts from %@".localized(), str_Start_Price)
        self.setupAttributeText(full_text: strText, hightLightText: str_Start_Price)
        self.lbl_view_Details.text = "VIEW DETAILS".localized().capitalized
        
        var str_imgName = ""
        var str_BG_imgName = "icon_other_plan_bg"
        let str_Subscription_Name = dic_plan_data.subscription_name.lowercased()
        if str_Subscription_Name == kSubscription_Name_Type.prime.rawValue {
            str_imgName = "icon_prime_logo"
            str_BG_imgName = "icon_prime_plan_bg"
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
        self.img_plan_Type.image = UIImage.init(named: str_imgName)
        self.img_view_BG.image = UIImage.init(named: str_BG_imgName)
    }
    
    func setupAttributeText(full_text: String, hightLightText: String) {
        let newText = NSMutableAttributedString.init(string: full_text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.26 // Whatever line spacing you want in points
        
        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontRegular(16), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange.init(location: 0, length: newText.length))
        
        let textRange = NSString(string: full_text)
        let highlight_range = textRange.range(of: hightLightText)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontSemiBold(16), range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: highlight_range)
        self.lbl_plan_sub_Title.attributedText = newText
    }
    
}

