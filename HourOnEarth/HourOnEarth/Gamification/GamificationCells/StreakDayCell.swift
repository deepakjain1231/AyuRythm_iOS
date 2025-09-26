//
//  StreakDayCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 31/01/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class StreakDayCell: UICollectionViewCell {
    
    @IBOutlet weak var dayL: UILabel!
    @IBOutlet weak var bgView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI(data: ARStreakDayModel, index: Int) {
        dayL.text = data.isToday ? "Today".localized() : ("Day".localized() + " "  + (index+1).stringValue)
        let colors = data.getDayColors()
        bgView.backgroundColor = colors.bgColor
        dayL.textColor = colors.textColor
    }

}
