//
//  HomeScreenExploreTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 03/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class HomeScreenExploreTableCell: UITableViewCell {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_food: UILabel!
    @IBOutlet weak var lbl_herbs: UILabel!
    @IBOutlet weak var lbl_yogasana: UILabel!
    @IBOutlet weak var lbl_pranayam: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_title.text = "Explore".localized()
        self.lbl_food.text = "Food".localized()
        self.lbl_herbs.text = "Herbs".localized()
        self.lbl_yogasana.text = "Yogasana".localized()
        self.lbl_pranayam.text = "Pranayam".localized()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
