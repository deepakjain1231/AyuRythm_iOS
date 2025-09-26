//
//  PlayListHeaderCell.swift
//  HourOnEarth
//
//  Created by Apple on 29/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class PlayListHeaderCell: UICollectionReusableView {
    
    @IBOutlet weak var lblTitle: UILabel!

    func configureUI(title: String) {
        self.lblTitle.text = title
    }
}
