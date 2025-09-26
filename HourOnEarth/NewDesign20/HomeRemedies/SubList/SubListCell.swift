//
//  SubListCell.swift
//  HourOnEarth
//
//  Created by Pradeep on 1/29/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//

import UIKit

class SubListCell:  UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    func configure(title: String) {
        self.lblTitle.text = title
    }
}
