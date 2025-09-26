//
//  HomeScreenDailyPlanner.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 30/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class HomeScreenDailyPlanner: UITableViewCell {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var btn_explore: UIButton!
    @IBOutlet weak var img_Banner: UIImageView!
    @IBOutlet weak var view_Main: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view_Main.layer.cornerRadius = 12
        self.view_Main.layer.masksToBounds = true
        self.view_Main.clipsToBounds = true
    }
    
    func setupCell_Data() {
        self.lbl_subTitle.numberOfLines = 0
        let dic_userInfo = UserDefaults.user.get_user_info_result_data
        let str_title = dic_userInfo["daily_planner_title"] as? String ?? ""
        let str_sub_title = dic_userInfo["daily_planner_subtitle"] as? String ?? ""
        let str_btn_text = dic_userInfo["daily_planner_buttontext"] as? String ?? ""
        let strBackImage = dic_userInfo["daily_planner_background"] as? String ?? ""
    
        self.lbl_title.text = str_title
        self.lbl_subTitle.text = str_sub_title
        self.btn_explore.setTitle(str_btn_text, for: .normal)
        self.img_Banner.sd_setImage(with: URL(string: strBackImage), placeholderImage: UIImage(named: "icon_dieet_plan_banner"))
        
        self.lbl_title.textColor = .black
        self.lbl_subTitle.textColor = .black
        let strTextColor = dic_userInfo["daily_planner_textcolor"] as? String ?? ""
        if strTextColor != "" {
            self.lbl_title.textColor = UIColor.fromHex(hexString: strTextColor)
            self.lbl_subTitle.textColor = UIColor.fromHex(hexString: strTextColor)
        }
        
        let strButtonBGColor = dic_userInfo["daily_planner_buttonbgcolor"] as? String ?? ""
        if strButtonBGColor != "" {
            self.btn_explore.backgroundColor = UIColor.fromHex(hexString: strButtonBGColor)
        }
        
        let strButtonTextColor = dic_userInfo["daily_planner_buttontextcolor"] as? String ?? ""
        if strButtonTextColor != "" {
            self.btn_explore.setTitleColor(UIColor.fromHex(hexString: strButtonTextColor), for: .normal)
        }
    }
    
    
    
}
