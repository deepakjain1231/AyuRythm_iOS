//
//  HomeScreenTodayGoalTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 29/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class HomeScreenTodayGoalTableCell: UITableViewCell {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var btn_edit: UIButton!
    var didTappedonEdit: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_title.text = "Today's goal".localized()
        self.btn_edit.setTitle("Edit".localized(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_EditAction(_ sender: UIButton) {
        if self.didTappedonEdit != nil {
            self.didTappedonEdit!(sender)
        }
    }
}
