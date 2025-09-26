//
//  PrakritiCell.swift
//  HourOnEarth
//
//  Created by Pradeep on 5/27/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit

class PrakritiCell: UITableViewCell {

    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblAnswer1: UILabel!
    @IBOutlet weak var lblAnswer2: UILabel!
    @IBOutlet weak var lblAnswer3: UILabel!
    @IBOutlet weak var lblAnswer4: UILabel!

    @IBOutlet weak var btnAnswer1: UIButton!
    @IBOutlet weak var btnAnswer2: UIButton!
    @IBOutlet weak var imageViewQuestion: UIImageView!
    @IBOutlet weak var viewBackground: UIView!
    
    @IBOutlet weak var btnAnswer3: UIButton!
    @IBOutlet weak var viewAnswer4: UIView!

    @IBOutlet weak var btnAnswer4: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
//        btnAnswer1.layer.borderColor = UIColor.lightGray.cgColor
//        btnAnswer1.layer.borderWidth = 0.5
//        
//        btnAnswer2.layer.borderColor = UIColor.lightGray.cgColor
//        btnAnswer2.layer.borderWidth = 0.5
//        
//        btnAnswer3.layer.borderColor = UIColor.lightGray.cgColor
//        btnAnswer3.layer.borderWidth = 0.5
//        
//        btnAnswer4.layer.borderColor = UIColor.lightGray.cgColor
//        btnAnswer4.layer.borderWidth = 0.5
    }
}
