//
//  ARFeedHashtagCollectionCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 30/09/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARFeedHashtagCollectionCell: UICollectionViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var btn_Close: UIButton!
    
    var didTappedonOnRemoveTag: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func btn_Close_Action(_ sender: UIButton) {
        if self.didTappedonOnRemoveTag != nil {
            self.didTappedonOnRemoveTag!(sender)
        }
    }
}
