//
//  ARWellnessPlanHeaderCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 25/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARWellnessPlanHeaderCell: UITableViewCell {
    
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var autoplayView: UIView!
    @IBOutlet weak var autoplaySwitch: UISwitch?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        //autoplaySwitch.backgroundColor = UIColor.green.withAlphaComponent(0.4)
        autoplaySwitch?.transform = CGAffineTransform(scaleX: 0.70, y: 0.70)
    }
}
