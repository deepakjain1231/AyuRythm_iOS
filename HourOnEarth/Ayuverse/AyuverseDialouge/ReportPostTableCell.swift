//
//  ReportPostTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 23/09/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ReportPostTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var img_Selection: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
