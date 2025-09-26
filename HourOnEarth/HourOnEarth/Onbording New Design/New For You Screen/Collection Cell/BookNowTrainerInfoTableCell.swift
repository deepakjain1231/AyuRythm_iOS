//
//  BookNowTrainerInfoTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 27/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class BookNowTrainerInfoTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var txt_info: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
