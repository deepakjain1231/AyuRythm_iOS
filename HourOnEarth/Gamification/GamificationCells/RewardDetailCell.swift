//
//  RewardDetailCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 27/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

protocol RewardDetailCellDelegate {
    func rewardDetailCellDidClickDropDown(_ cell: RewardDetailCell, data: ARStreakRewardModel?)
    func rewardDetailCellDidClickCopyCode(_ cell: RewardDetailCell, data: ARStreakRewardModel?)
}

class RewardDetailCell: UITableViewCell {
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var subtitleL: UILabel!
    @IBOutlet weak var expireL: UILabel!
    @IBOutlet weak var codeL: UILabel!
    @IBOutlet weak var offerDetailL: UILabel!
    @IBOutlet weak var stepToAvailL: UILabel!
    @IBOutlet weak var offerDetailArrowBtn: UIButton!
    @IBOutlet weak var stepToAvailArrowBtn: UIButton!
    @IBOutlet weak var subscribeBtn: UIButton!
    @IBOutlet weak var offerDetailSV: UIStackView!
    @IBOutlet weak var stepToAvailSV: UIStackView!
    
    var delegate: RewardDetailCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        subscribeBtn.isHidden = true
    }
    
    var streakReward: ARStreakRewardModel? {
        didSet {
            guard let data = streakReward else { return }
            titleL.text = data.rewardLabel
            subtitleL.text = data.rewardSubtitle
            expireL.text = "Expires on: ".localized() + data.rewardExpiryDate.dateStringEnglishLocale(format: "dd MMM, yyyy")
            codeL.text = "Code: ".localized() + data.rewardCode
            offerDetailL.text = data.rewardDetails
            stepToAvailL.text = data.rewardSteps
            offerDetailArrowBtn.isSelected = data.isDetailExpanded
            stepToAvailArrowBtn.isSelected = data.isStepsExpanded
            offerDetailSV.isHidden = !data.isDetailExpanded
            stepToAvailSV.isHidden = !data.isStepsExpanded
        }
    }
    
    @IBAction func copyCodeBtnPressed(sender: UIButton) {
        delegate?.rewardDetailCellDidClickCopyCode(self, data: streakReward)
    }
    
    @IBAction func offerDropDownArrowBtnPressed(sender: UIButton) {
        sender.isSelected.toggle()
        offerDetailSV.isHidden.toggle()
        streakReward?.isDetailExpanded.toggle()
        delegate?.rewardDetailCellDidClickDropDown(self, data: streakReward)
    }
    
    @IBAction func stepsDropDownArrowBtnPressed(sender: UIButton) {
        sender.isSelected.toggle()
        stepToAvailSV.isHidden.toggle()
        streakReward?.isStepsExpanded.toggle()
        delegate?.rewardDetailCellDidClickDropDown(self, data: streakReward)
    }
    
    @IBAction func subscribeBtnPressed(sender: UIButton) {
    }
}
