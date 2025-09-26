//
//  ARCategoryTableViewCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 18/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleL: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var category: ARAyuverseCategory? {
        didSet {
            guard let category = category else { return }
            
            titleL.text = category.name
            titleL.textColor = category.isSelected ? .white : .black
            titleL.backgroundColor = category.isSelected ? .black : UIColor.fromHex(hexString: "EEEEEE")
        }
    }
}
