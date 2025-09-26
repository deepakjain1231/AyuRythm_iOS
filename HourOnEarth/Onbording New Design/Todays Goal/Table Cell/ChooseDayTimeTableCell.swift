//
//  ChooseDayTimeTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 28/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class ChooseDayTimeTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_chooseTime: UILabel!
    @IBOutlet weak var lbl_repeat: UILabel!
    @IBOutlet weak var date_picker: UIDatePicker!
    @IBOutlet weak var view_StackDay: UIStackView!
    
    var didTappedonDays: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_chooseTime.text = "Choose time".localized()
        self.lbl_repeat.text = "Repeat".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBAction func btn_Datys_Action(_ sender: UIControl) {
        if self.didTappedonDays != nil {
            self.didTappedonDays!(sender)
        }
    }
}
