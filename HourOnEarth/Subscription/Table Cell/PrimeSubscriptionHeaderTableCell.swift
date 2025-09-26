//
//  PrimeSubscriptionHeaderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 16/12/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class PrimeSubscriptionHeaderTableCell: UITableViewCell {

    @IBOutlet weak var subInfoView: UIView!
    @IBOutlet weak var planTitleL: UILabel!
    @IBOutlet weak var planDetailL: UILabel!
    @IBOutlet weak var planTrailL: UILabel!
    @IBOutlet weak var btn_subscribe: UIButton!
    
    var didTappedSubscribeButton: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btn_subscribe.setTitle("Subscribe Now".localized(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: - UIButton Action
    @IBAction func btn_Subscribe_Now_Action(_ sender: UIButton) {
        self.didTappedSubscribeButton?(sender)
    }
}
