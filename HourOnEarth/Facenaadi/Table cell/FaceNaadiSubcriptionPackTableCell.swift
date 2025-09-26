//
//  FaceNaadiSubcriptionPackTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 03/11/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class FaceNaadiSubcriptionPackTableCell: UITableViewCell {

    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var subtitleL: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var statusBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        bgView.cornerRadiuss = 10
    }
        

}
