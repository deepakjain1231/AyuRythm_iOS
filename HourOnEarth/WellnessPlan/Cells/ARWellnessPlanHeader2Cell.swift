//
//  ARWellnessPlanHeader2Cell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 25/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARWellnessPlanHeader2Cell: ARWellnessPlanHeaderCell {

    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var moreDietInfo: UIView!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var headerL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerL.text = "Diet Plan".localized()
    }
}
