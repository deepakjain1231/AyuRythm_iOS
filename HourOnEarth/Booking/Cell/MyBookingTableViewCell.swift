//
//  MyBookingTableViewCell.swift
//  HourOnEarth
//
//  Created by Ayu on 16/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class MyBookingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mondayButton: UIButton?
    @IBOutlet weak var tuesdayButton: UIButton?
    @IBOutlet weak var wednesdayButton: UIButton?
    @IBOutlet weak var thursdayButton: UIButton?
    @IBOutlet weak var fridayButton: UIButton?
    @IBOutlet weak var saturdayButton: UIButton?
    @IBOutlet weak var sundayButton: UIButton?
    @IBOutlet weak var timeZoneView: TextTagCollectionView!
    
    @IBOutlet weak var packageNameLabel: UILabel?
    @IBOutlet weak var trainerNameLabel: UILabel?
    @IBOutlet weak var sessionTimeLabel: UILabel?
    @IBOutlet weak var sessionDateLabel: UILabel?
    @IBOutlet weak var sessionDaysLabel: UILabel?
    @IBOutlet weak var noOfSesseinPerWeekLabel: UILabel?
    @IBOutlet weak var sessionStartDateTextField: UITextField?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mondayButton?.cornerRadiuss = 22
        tuesdayButton?.cornerRadiuss = 22
        wednesdayButton?.cornerRadiuss = 22
        thursdayButton?.cornerRadiuss = 22
        fridayButton?.cornerRadiuss = 22
        saturdayButton?.cornerRadiuss = 22
        sundayButton?.cornerRadiuss = 22
        mondayButton?.layer.borderWidth = 2
        tuesdayButton?.layer.borderWidth = 2
        wednesdayButton?.layer.borderWidth = 2
        thursdayButton?.layer.borderWidth = 2
        fridayButton?.layer.borderWidth = 2
        saturdayButton?.layer.borderWidth = 2
        sundayButton?.layer.borderWidth = 2
        mondayButton?.layer.borderColor = kAppGreenD2Color.cgColor
        tuesdayButton?.layer.borderColor = kAppGreenD2Color.cgColor
        wednesdayButton?.layer.borderColor = kAppGreenD2Color.cgColor
        thursdayButton?.layer.borderColor = kAppGreenD2Color.cgColor
        fridayButton?.layer.borderColor = kAppGreenD2Color.cgColor
        saturdayButton?.layer.borderColor = kAppGreenD2Color.cgColor
        sundayButton?.layer.borderColor = kAppGreenD2Color.cgColor
        
        let textConfig = TextTagConfig()
        textConfig.textColor = .black
        textConfig.selectedTextColor = .black
        textConfig.backgroundColor = .white
        textConfig.selectedBackgroundColor = kGreenL3
        textConfig.borderColor = kSoftGreen
        textConfig.borderWidth = 2.0
        textConfig.selectedBorderColor = kSoftGreen
        textConfig.selectedBorderWidth = 2.0
        textConfig.cornerRadius = 10
        textConfig.selectedCornerRadius = 10
        textConfig.shadowColor = .white
        textConfig.minWidth = (kDeviceWidth / 2) - 30
        textConfig.textFont = UIFont.systemFont(ofSize: 15)
        
        if timeZoneView != nil {
            timeZoneView.defaultConfig = textConfig
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
