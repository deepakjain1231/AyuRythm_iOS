//
//  ARContentLibraryDataCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 02/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARContentLibraryDataCell: UITableViewCell {
    
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var subtitleL: UILabel!
    @IBOutlet weak var selectionBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        selectionBtn.isHidden = true
    }
    
    var data: ARContentLibraryDataModel? {
        didSet {
            guard let data = data else { return }
            
            imageIV.af_setImage(withURLString: data.image)
            titleL.text = data.name
            subtitleL.text = data.englishName
            selectionBtn.isSelected = data.isSelected
        }
    }
}
