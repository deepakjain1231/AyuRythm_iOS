//
//  HowtoUseTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 22/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class HowtoUseTableCell: UITableViewCell {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_count: UILabel!
    @IBOutlet weak var lbl_top_line: UILabel!
    @IBOutlet weak var lbl_bottom_line: UILabel!
    @IBOutlet weak var icon_aftercare: UIImageView!
    @IBOutlet weak var view_counter_Bg: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
