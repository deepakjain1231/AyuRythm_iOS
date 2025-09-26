//
//  MyListsCollectionViewCell.swift
//  HourOnEarth
//
//  Created by Ayu on 27/07/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class MyListsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sectionNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sectionNameLabel.layer.cornerRadius = 10
        sectionNameLabel.layer.masksToBounds = true
    }
    
}
