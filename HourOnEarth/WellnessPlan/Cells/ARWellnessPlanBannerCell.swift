//
//  ARWellnessPlanBannerCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 21/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARWellnessPlanBannerCell: UITableViewCell {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var btn_explore: UIButton!
    @IBOutlet weak var img_Banner: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setupCell_Data() {
        self.lbl_subTitle.numberOfLines = 0
        let dic_userInfo = UserDefaults.user.get_user_info_result_data
        let str_title = dic_userInfo["diet_plans_subscription_title"] as? String ?? ""
        let str_sub_title = dic_userInfo["diet_plans_subscription_subtitle"] as? String ?? ""
        let str_btn_text = dic_userInfo["diet_plans_subscription_btn_text"] as? String ?? ""
        let strBackImage = dic_userInfo["diet_plans_subscription_background"] as? String ?? ""
        let strTextAlignment = dic_userInfo["diet_plans_subscription_textalignment"] as? String ?? ""
        if strTextAlignment.lowercased() == "left" {
            self.lbl_title.textAlignment = .left
            self.lbl_subTitle.textAlignment = .left
        }
        else if strTextAlignment.lowercased() == "right" {
            self.lbl_title.textAlignment = .right
            self.lbl_subTitle.textAlignment = .right
        }
        else {
            self.lbl_title.textAlignment = .center
            self.lbl_subTitle.textAlignment = .center
        }
        self.lbl_title.text = str_title
        self.lbl_subTitle.text = str_sub_title
        self.btn_explore.setTitle(str_btn_text, for: .normal)
        self.img_Banner.sd_setImage(with: URL(string: strBackImage), placeholderImage: UIImage(named: "icon_dieet_plan_banner"))
        
        self.lbl_title.textColor = .black
        self.lbl_subTitle.textColor = .black
        let strTextColor = dic_userInfo["diet_plans_subscription_textcolor"] as? String ?? ""
        if strTextColor != "" {
            self.lbl_title.textColor = UIColor.fromHex(hexString: strTextColor)
            self.lbl_subTitle.textColor = UIColor.fromHex(hexString: strTextColor)
        }
        
        let strButtonBGColor = dic_userInfo["diet_plans_subscription_btn_bgcolor"] as? String ?? ""
        if strButtonBGColor != "" {
            self.btn_explore.backgroundColor = UIColor.fromHex(hexString: strButtonBGColor)
        }
        
        let strButtonTextColor = dic_userInfo["diet_plans_subscription_btn_textcolor"] as? String ?? ""
        if strButtonTextColor != "" {
            self.btn_explore.setTitleColor(UIColor.fromHex(hexString: strButtonTextColor), for: .normal)
        }
    }
    
    
    
}
