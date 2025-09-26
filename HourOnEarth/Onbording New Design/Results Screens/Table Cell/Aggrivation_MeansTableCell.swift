//
//  Aggrivation_MeansTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 04/10/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class Aggrivation_MeansTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_desc: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
