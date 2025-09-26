//
//  ARCategoryCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 10/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

// MARK: -
class ARCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleL: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var selectionBGColor = UIColor.fromHex(hexString: "0FA958")
    
    var category: ARAyuverseCategoryModel? {
        didSet {
            guard let category = category else { return }
            
            titleL.text = category.name
            
            //titleL.layer.cornerRadius = titleL.frame.height/2
            titleL.layer.cornerRadius = 10
            titleL.layer.masksToBounds = true
            
            titleL.textColor = category.isSelected ? .white : .black
            titleL.backgroundColor = category.isSelected ? selectionBGColor : UIColor.fromHex(hexString: "EEEEEE")
            
            layoutIfNeeded()
        }
    }
}
