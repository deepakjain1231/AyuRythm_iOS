//
//  MyListTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 18/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class MyListTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_sub_title: UILabel!
    @IBOutlet weak var img_player: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgThumb.layer.cornerRadius = 12
        self.imgThumb.clipsToBounds = true
        self.imgThumb.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
