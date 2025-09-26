//
//  MPDescriptionTblCell.swift
//  HourOnEarth
//
//  Created by Maulik Vora on 17/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MPDescriptionTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var imgArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
