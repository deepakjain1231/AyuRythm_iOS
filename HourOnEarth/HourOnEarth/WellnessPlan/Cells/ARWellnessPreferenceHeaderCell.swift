//
//  ARWellnessPreferenceHeaderCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 25/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARWellnessPreferenceHeaderCell: UITableViewCell {
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var subtitleL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var preference: ARWellnessPreferenceModel? {
        didSet {
            guard let preference = preference else { return }
            
            titleL.text = preference.preference
            subtitleL.text = preference.info
        }
    }
}
