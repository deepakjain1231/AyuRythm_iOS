//
//  EditProfileHeaderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 11/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class EditProfileHeaderTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var view_inner: UIView!
    @IBOutlet weak var img_Profile: UIImageView!
    @IBOutlet weak var btn_AddPhoto: UIButton!
    @IBOutlet weak var view_Pro: UIView!
    
    
    var didTappedonAddPhoto: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_logout(_ sender: UIButton) {
        if self.didTappedonAddPhoto != nil {
            self.didTappedonAddPhoto!(sender)
        }
    }
    
}
