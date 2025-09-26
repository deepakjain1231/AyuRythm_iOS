//
//  PrakritiQuestionCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 22/01/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class PrakritiQuestionCell: UITableViewCell {
    
    @IBOutlet weak var lblAnswer1: UILabel!
    @IBOutlet weak var lblAnswer2: UILabel!
    @IBOutlet weak var lblAnswer3: UILabel!
    @IBOutlet weak var lblAnswer4: UILabel!

    @IBOutlet weak var btnAnswer1: UIButton!
    @IBOutlet weak var btnAnswer2: UIButton!
    @IBOutlet weak var btnAnswer3: UIButton!
    @IBOutlet weak var btnAnswer4: UIButton!
    
    @IBOutlet weak var viewAnswer4: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
