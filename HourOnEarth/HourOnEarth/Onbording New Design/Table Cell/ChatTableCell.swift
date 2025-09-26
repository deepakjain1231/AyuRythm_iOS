//
//  ChatTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 06/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class ChatTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Text: UILabel!
    @IBOutlet weak var view_Base_main: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
