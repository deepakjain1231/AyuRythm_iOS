//
//  GenderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 11/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class GenderTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    @IBOutlet weak var img_male: UIImageView!
    @IBOutlet weak var img_female: UIImageView!
    
    @IBOutlet weak var lbl_male: UILabel!
    @IBOutlet weak var lbl_female: UILabel!
    
    @IBOutlet weak var btn_male: UIControl!
    @IBOutlet weak var btn_female: UIControl!
    
    var didTappedonMaleFemale: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btn_MaleFemale_Action(_ sender: UIControl) {
        if self.didTappedonMaleFemale != nil {
            self.didTappedonMaleFemale!(sender)
        }
    }
}
