//
//  HOEPrakritiDetailCell.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 22/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class PrakritiDetailCell: UITableViewCell {

    @IBOutlet weak var lblDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(description: String) {
        let attributestring = NSAttributedString(string: description)

        self.lblDescription.attributedText = attributestring
    }
}
