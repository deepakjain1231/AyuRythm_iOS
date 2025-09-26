//
//  PrakritiQuestionTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 06/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class PrakritiQuestionTableCell: UITableViewCell {

    @IBOutlet weak var lbl_Question: UILabel!
    @IBOutlet weak var img_Question: UIImageView!
    @IBOutlet weak var lbl_Option1: UILabel!
    @IBOutlet weak var lbl_Option2: UILabel!
    @IBOutlet weak var lbl_Option3: UILabel!
    @IBOutlet weak var lbl_Option4: UILabel!
    
    @IBOutlet weak var img_Option1: UIImageView!
    @IBOutlet weak var img_Option2: UIImageView!
    @IBOutlet weak var img_Option3: UIImageView!
    @IBOutlet weak var img_Option4: UIImageView!
    
    @IBOutlet weak var btn_Option1: UIControl!
    @IBOutlet weak var btn_Option2: UIControl!
    @IBOutlet weak var btn_Option3: UIControl!
    @IBOutlet weak var btn_Option4: UIControl!
    
    @IBOutlet weak var constraint_lbl_Option4_Top: NSLayoutConstraint!
    @IBOutlet weak var constraint_lbl_Option4_Bottom: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
