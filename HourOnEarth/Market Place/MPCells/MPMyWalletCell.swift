//
//  MPMyWalletCell.swift
//  HourOnEarth
//
//  Created by Maulik Vora on 27/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MPMyWalletCell: UITableViewCell {

    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_TitleDate: UILabel!
    @IBOutlet weak var lblExpDate: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
