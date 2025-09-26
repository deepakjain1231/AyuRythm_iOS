//
//  ProductReminderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 20/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ProductReminderTableCell: UITableViewCell {

    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var btn_Switch: UISwitch!
    
    var didTappedonSwitch: ((UISwitch)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_Switch_Acton(_ sender: UISwitch) {
        if self.didTappedonSwitch != nil {
            self.didTappedonSwitch!(sender)
        }
    }
    
}
