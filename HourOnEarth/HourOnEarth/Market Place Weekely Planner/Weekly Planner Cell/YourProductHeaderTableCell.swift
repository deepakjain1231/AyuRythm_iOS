//
//  YourProductHeaderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 12/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class YourProductHeaderTableCell: UITableViewCell {

    @IBOutlet weak var lbl_title_1: UILabel!
    @IBOutlet weak var lbl_title_2: UILabel!
    @IBOutlet weak var btn_EditReminder: UIButton!
    
    var didTappedonEditReminder: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_EditReminder_Action(_ sender: UIButton) {
        if self.didTappedonEditReminder != nil {
            self.didTappedonEditReminder!(sender)
        }
    }
    
}
