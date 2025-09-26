//
//  HomeRemediesTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 09/02/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class HomeRemediesTableCell: UITableViewCell {
    
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_sub_title: UILabel!
    @IBOutlet weak var btn_click: UIButton!
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var btn_prime: UIButton!
    @IBOutlet weak var btn_unlock_remedies: UIButton!
    @IBOutlet weak var img_arrow: UIImageView!
    @IBOutlet weak var img_Banner_BG: UIImageView!
    
    var didTappedPrimeButton: ((UIButton)->Void)? = nil
    var didTappedUnlockRemediesButton: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view_Base.layer.cornerRadius = 12
        self.view_Base.clipsToBounds = true
        self.view_Base.layer.masksToBounds = true
        self.lbl_title.text = "Personalized Home Remedies".localized()
        self.btn_prime.setTitle("Join Prime Club".localized(), for: .normal)
        self.lbl_sub_title.text = "Personalized home remedies, aligned with your doshas.".localized()
    }
    
    func setupCellData() {
        self.lbl_sub_title.numberOfLines = 0
        let dic_userInfo = UserDefaults.user.get_user_info_result_data
        let str_title = dic_userInfo["home_remedies_title"] as? String ?? ""
        let str_sub_title = dic_userInfo["home_remedies_subtitle"] as? String ?? ""
        let strBackImage = dic_userInfo["home_remedies_background"] as? String ?? ""
        self.lbl_title.text = str_title
        self.lbl_sub_title.text = str_sub_title
        self.img_Banner_BG.sd_setImage(with: URL(string: strBackImage), placeholderImage: UIImage(named: "icon_dieet_plan_banner"))

        self.lbl_title.textColor = .black
        self.lbl_sub_title.textColor = .black
        let strTextColor = dic_userInfo["home_remedies_textcolor"] as? String ?? ""
        if strTextColor != "" {
            self.lbl_title.textColor = UIColor.fromHex(hexString: strTextColor)
            self.lbl_sub_title.textColor = UIColor.fromHex(hexString: strTextColor)
        }
    }
    
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_Prime_Action(_ sender: UIButton) {
        self.didTappedPrimeButton?(sender)
    }
    
    @IBAction func btn_Unloack_Action(_ sender: UIButton) {
        self.didTappedUnlockRemediesButton?(sender)
    }
}
