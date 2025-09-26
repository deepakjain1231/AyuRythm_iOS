//
//  NoActivePlanTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 30/12/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class NoActivePlanTableCell: UITableViewCell {

    @IBOutlet weak var lbl_no_data: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_no_data.text = "We could not locate an active subscription at this time".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
