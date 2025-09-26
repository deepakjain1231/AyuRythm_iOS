//
//  ARAyuverseGroupSectionHeaderCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 10/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARAyuverseGroupSectionHeaderCell: UITableViewCell {
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var exploreBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var section: String? {
        didSet {
            guard let section = section else { return }
            if section == "Popular groups".localized() {
                exploreBtn.setTitle("View All".localized(), for: .normal)
            }else{
                exploreBtn.setTitle("View All".localized(), for: .normal)
            }
            titleL.text = section
        }
    }
}
