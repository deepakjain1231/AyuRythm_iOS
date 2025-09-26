//
//  HomeScreenFoodHerbsTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 30/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class HomeScreenFoodHerbsTableCell: UITableViewCell {

    @IBOutlet weak var lbl_Food: UILabel!
    @IBOutlet weak var lbl_Hearbs: UILabel!
    
    @IBOutlet weak var btn_Food: UIControl!
    @IBOutlet weak var btn_Hearbs: UIControl!
    
    var didTappedonFood: ((UIControl)->Void)? = nil
    var didTappedonHearbs: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_Food.text = "Food".localized()
        self.lbl_Hearbs.text = "Herbs".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    
    @IBAction func btn_Food_Action(_ sender: UIButton) {
        if self.didTappedonFood != nil {
            self.didTappedonFood!(sender)
        }
    }
    
    @IBAction func btn_Hearbs_Action(_ sender: UIButton) {
        if self.didTappedonHearbs != nil {
            self.didTappedonHearbs!(sender)
        }
    }
}
