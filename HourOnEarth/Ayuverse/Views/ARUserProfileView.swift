//
//  ARUserProfileView.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 20/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARUserProfileView: PDDesignableXibView {
    
    enum ViewFor {
        case feed
        case groupMember
        case groupAdmin
    }
    
    @IBOutlet weak var profilePicIV: UIImageView!
    @IBOutlet weak var badgeIV: UIImageView!
    @IBOutlet weak var usernameL: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var timeL: UILabel!
    @IBOutlet weak var lbl_Edited: UILabel!
    @IBOutlet weak var profilePicWidthCons: NSLayoutConstraint!
    
    override func initialSetUp() {
        super.initialSetUp()
        //usernameL.text = "Paresh Dafda"
        self.lbl_Edited.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePicIV.layer.cornerRadius = profilePicIV.frame.width/2
        profilePicIV.clipsToBounds = true
    }
    
    func updateUI(for viewFor: ViewFor) {
        switch viewFor {
        case .groupMember:
            timeL.isHidden = true
            profilePicWidthCons.constant = 28
            usernameL.font = UIFont.systemFont(ofSize: 14)
            layoutIfNeeded()
            
        case .groupAdmin:
            timeL.isHidden = true
            /*profilePicWidthCons.constant = 38
            profilePicIV.layoutIfNeeded()
            usernameL.font = UIFont.systemFont(ofSize: 17, weight: .medium)*/
            
        default:
            print("feed cell")
        }
    }
}
