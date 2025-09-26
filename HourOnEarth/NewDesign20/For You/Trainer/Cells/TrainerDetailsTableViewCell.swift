//
//  TrainerDetailsTableViewCell.swift
//  HourOnEarth
//
//  Created by Ayu on 16/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

protocol TrainerDetailsTableViewCellDelegate: class {
    func readMoreClicked()
}

class TrainerDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var programLabel: UILabel!
    @IBOutlet weak var sessionCostLabel: UILabel?
    @IBOutlet weak var sessionCountLabel: UILabel?
    @IBOutlet weak var sessionDurationLabel: UILabel?
    @IBOutlet weak var sessionDetailsLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var btnArrow: UIButton!
    @IBOutlet weak var bookNowButton: UIButton!
    @IBOutlet weak var readMoreButton: UIButton?
    
    weak var delegate: TrainerDetailsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sessionCostLabel?.layer.cornerRadius = 10
        sessionCountLabel?.layer.cornerRadius = 10
        sessionDurationLabel?.layer.cornerRadius = 10
        
        sessionCostLabel?.layer.masksToBounds = true
        sessionCountLabel?.layer.masksToBounds = true
        sessionDurationLabel?.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func readMoreBtnPressed(sender: UIButton) {
        delegate?.readMoreClicked()
    }
}
