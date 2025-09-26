//
//  MyListsTableViewCell.swift
//  HourOnEarth
//
//  Created by Ayu on 24/07/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class MyListsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var selectButtonWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
