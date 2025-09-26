//
//  BookNowLocationTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 26/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class BookNowLocationTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var btn_info: UIButton!
    @IBOutlet weak var timeZoneView: TextTagCollectionView!
    
    var didTappedInfo: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let textConfig = TextTagConfig()
        textConfig.textColor = UIColor.fromHex(hexString: "#6B6B6B")
        textConfig.selectedTextColor = AppColor.app_DarkGreenColor
        textConfig.backgroundColor = .clear
        textConfig.selectedBackgroundColor = .clear
        textConfig.borderColor = UIColor.fromHex(hexString: "#878787")
        textConfig.borderWidth = 1.0
        textConfig.selectedBorderWidth = 1.0
        textConfig.selectedBorderColor = AppColor.app_DarkGreenColor
        textConfig.cornerRadius = 5
        textConfig.selectedCornerRadius = 5
        textConfig.shadowColor = .white
        textConfig.minWidth = (kDeviceWidth / 2) - 30
        textConfig.textFont = UIFont.AppFontRegular(14)
        
        if timeZoneView != nil {
            timeZoneView.defaultConfig = textConfig
        }
    }
    
    func setupCellData(locations: [String], selected_index: Int) {
        timeZoneView.removeAllTags()
        let localizedTitle = locations.map{ $0.localized() }
        timeZoneView.addTags(localizedTitle)
        if selected_index >= 0 {
            timeZoneView.setTagAt(UInt(selected_index), selected: true)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    // MARK: - UIButton Action
    @IBAction func btn_Info_Action(_ sender: UIButton) {
        self.didTappedInfo?(sender)
    }
}
