//
//  TrainerPackageTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 25/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class TrainerPackageTableCell: UITableViewCell {
    
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_sessionCost: UILabel!
    @IBOutlet weak var lbl_old_sessionCost: UILabel!
    @IBOutlet weak var lbl_discount: UILabel!
    @IBOutlet weak var view_discount: UIView!
    @IBOutlet weak var lbl_inclusive_all_tax: UILabel!
    @IBOutlet weak var lbl_sessionDuration: UILabel!
    @IBOutlet weak var lbl_BookNow: UILabel!
    @IBOutlet weak var btn_BookNow: UIControl!
    @IBOutlet weak var lbl_Instruction: UILabel!
    @IBOutlet weak var lbl_Instruction_Title: UILabel!

    var didTappedBookNow: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_Action(_ sender: UIControl) {
        self.didTappedBookNow?(sender)
    }
}

