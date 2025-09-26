//
//  MPReasonTableCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 21/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MPReasonTableCell: UITableViewCell {
 
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Underline: UILabel!
    @IBOutlet weak var img_selection: UIImageView!
    
    var didTappedSelectionType: ((UIButton)->Void)? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
}
