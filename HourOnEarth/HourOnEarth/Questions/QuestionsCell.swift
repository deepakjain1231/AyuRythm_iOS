//
//  QuestionsCell.swift
//  HourOnEarth
//
//  Created by Pradeep on 5/26/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit

class QuestionsCell: UITableViewCell {

    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var btnAnswer1: UIButton!
    @IBOutlet weak var btnAnswer2: UIButton!
    @IBOutlet weak var btnAnswer3: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        btnAnswer1.contentVerticalAlignment = .center
        btnAnswer1.contentHorizontalAlignment = .left
        
        btnAnswer2.contentVerticalAlignment = .center
        btnAnswer2.contentHorizontalAlignment = .left

        btnAnswer3.contentVerticalAlignment = .center
        btnAnswer3.contentHorizontalAlignment = .left

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
