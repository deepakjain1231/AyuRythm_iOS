//
//  Category_ProductsTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 13/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class Category_ProductsTableCell: UITableViewCell {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var img_Product: UIImageView!
    @IBOutlet weak var view_NotStarted: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
