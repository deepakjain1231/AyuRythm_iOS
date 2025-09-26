//
//  MPSaveAddressCollectionCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 25/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MPSaveAddressCollectionCell: UICollectionViewCell {
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_SubTitle: UILabel!
    @IBOutlet weak var lbl_Type: UILabel!
    @IBOutlet weak var img_selection: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
