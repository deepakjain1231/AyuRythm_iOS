//
//  MyListDataTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 24/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class MyListDataTableCell: UITableViewCell {

    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var selectButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectButtonLeadngConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.listImageView.layer.cornerRadius = 12
        self.listImageView.clipsToBounds = true
        self.listImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
