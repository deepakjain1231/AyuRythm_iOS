//
//  PatientHistoryTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 22/03/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class PatientHistoryTableCell: UITableViewCell {

    @IBOutlet weak var viewMain_BG: UIView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_aggrivation: UILabel!
    @IBOutlet weak var lbl_LastVisited: UILabel!
    @IBOutlet weak var lbl_TestnotDone: UILabel!
    @IBOutlet weak var lbl_aggrivationType: UILabel!
    @IBOutlet weak var img_aggrivationType: UIImageView!
    @IBOutlet weak var view_aggrivationTypeBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
