//
//  MPPriceDetailTableCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 15/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class MPPriceDetailTableCell: UITableViewCell {

    @IBOutlet weak var btnApplyCoupan: UIButton!
    
    var didTappedApplyCoupen: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    //MARK:- UIBUTTON Action
    @IBAction func btn_ApplyCoupen(_ sender: UIButton) {
        if self.didTappedApplyCoupen != nil {
            self.didTappedApplyCoupen!(sender)
        }
    }
}
