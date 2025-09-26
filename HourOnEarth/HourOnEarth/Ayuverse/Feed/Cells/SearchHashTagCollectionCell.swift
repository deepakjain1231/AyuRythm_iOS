//
//  SearchHashTagCollectionCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 30/09/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class SearchHashTagCollectionCell: UICollectionViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    var didTappedonOnWholeCell: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func btn_Close_Action(_ sender: UIControl) {
        if self.didTappedonOnWholeCell != nil {
            self.didTappedonOnWholeCell!(sender)
        }
    }

}
