//
//  HomeScreen_RewardsTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 24/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class HomeScreen_RewardsTableCell: UITableViewCell {

    @IBOutlet weak var lbl_reward: UILabel!
    @IBOutlet weak var lbl_trackprogrees: UILabel!
    
    var didTappedonRewards: ((UIControl)->Void)? = nil
    var didTappedonTrackProgress: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_reward.text = "Rewards".localized()
        self.lbl_trackprogrees.text = "Track Progress".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_Rewards_Action(_ sender: UIControl) {
        if self.didTappedonRewards != nil {
            self.didTappedonRewards!(sender)
        }
    }
    
    @IBAction func btn_TrackProgress_Action(_ sender: UIControl) {
        if self.didTappedonTrackProgress != nil {
            self.didTappedonTrackProgress!(sender)
        }
    }
    
}
