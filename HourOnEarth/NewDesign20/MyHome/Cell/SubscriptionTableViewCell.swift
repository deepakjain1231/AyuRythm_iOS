//
//  SubscriptionTableViewCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 21/12/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import SDWebImage

class SubscriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subscriptionBtn: UIButton!
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var img_Banner: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view_Base.layer.cornerRadius = 12
        view_Base.clipsToBounds = true
        
        img_Banner.layer.cornerRadius = 12
        img_Banner.clipsToBounds = true
        
        self.view_Base.layer.shadowOpacity = 1
        self.view_Base.layer.shadowRadius = 4
        self.view_Base.layer.shadowOffset = CGSize.init(width: 0, height: 2)
        self.view_Base.layer.shadowColor = UIColor.fromHex(hexString: "#000000").withAlphaComponent(0.3).cgColor
        self.view_Base.layer.masksToBounds = true
        
//        subscriptionBtn.layer.cornerRadius = 8
//        subscriptionBtn.clipsToBounds = true
//        subscriptionBtn.layer.applySketchShadow()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupData() {
        self.lbl_subTitle.numberOfLines = 0
        let strBackImage = kUserDefaults.string(forKey: ksubscription_background)
        let strTextAlignment = kUserDefaults.string(forKey: ksubscription_textalignment)
        if strTextAlignment?.lowercased() == "left" {
            self.lbl_Title.textAlignment = .left
            self.lbl_subTitle.textAlignment = .left
        }
        else if strTextAlignment?.lowercased() == "right" {
            self.lbl_Title.textAlignment = .right
            self.lbl_subTitle.textAlignment = .right
        }
        else {
            self.lbl_Title.textAlignment = .center
            self.lbl_subTitle.textAlignment = .center
        }
        self.lbl_Title.text = kUserDefaults.string(forKey: ksubscription_title)
        self.lbl_subTitle.text = kUserDefaults.string(forKey: ksubscription_subtitle)
        self.subscriptionBtn.setTitle(kUserDefaults.string(forKey: ksubscription_button_text), for: .normal)
        self.img_Banner.sd_setImage(with: URL(string: strBackImage ?? ""), placeholderImage: UIImage(named: "ios_subscription_diwali"))
        
        
        self.lbl_Title.textColor = .black
        self.lbl_subTitle.textColor = .black
        let strTextColor = kUserDefaults.string(forKey: ksubscription_textColor) ?? ""
        if strTextColor != "" {
            self.lbl_Title.textColor = UIColor.fromHex(hexString: strTextColor)
            self.lbl_subTitle.textColor = UIColor.fromHex(hexString: strTextColor)
        }
        
        let strButtonColor = kUserDefaults.string(forKey: ksubscription_buttonColor) ?? ""
        if strButtonColor != "" {
            self.subscriptionBtn.backgroundColor = UIColor.fromHex(hexString: strButtonColor)
        }
        
        let strButtonTextColor = kUserDefaults.string(forKey: ksubscription_button_textColor) ?? ""
        if strButtonTextColor != "" {
            self.subscriptionBtn.setTitleColor(UIColor.fromHex(hexString: strButtonTextColor), for: .normal)
        }
    }
    
}
