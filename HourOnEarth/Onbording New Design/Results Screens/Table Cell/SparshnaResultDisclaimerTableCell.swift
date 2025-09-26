//
//  SparshnaResultDisclaimerTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 14/08/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class SparshnaResultDisclaimerTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_text: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_text.text = "DISCLAIMER: These results are only for Ayurvedic wellness and should not be interpreted or used for diagnosis or treatment.".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
