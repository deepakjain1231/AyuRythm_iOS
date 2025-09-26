//
//  MPHelpTableCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 29/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class MPHelpTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var img_arrow: UIImageView!
    @IBOutlet weak var constraint_subtitle_Top: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
