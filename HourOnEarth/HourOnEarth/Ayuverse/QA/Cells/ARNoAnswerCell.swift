//
//  ARNoAnswerCell.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 31/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
class ARNoAnswerCell: UITableViewCell{
    
    
    @IBOutlet weak var noDataL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
