//
//  AyuMonkLoaderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 01/11/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class AyuMonkLoaderTableCell: UITableViewCell {

    @IBOutlet weak var img_giff: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.img_giff.image = UIImage.gifImageWithName("chat_loader")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
