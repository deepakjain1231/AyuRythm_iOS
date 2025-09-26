//
//  RemediesOverviewCell.swift
//  HourOnEarth
//
//  Created by Pradeep on 1/28/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//

import UIKit

class RemediesOverviewCell: RoundedCell {

    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblSubTitle: UILabel!
    
    func configure(title: String, subTitle: String) {
        lblTitle.text = title
        lblSubTitle.text = subTitle
    }
}
