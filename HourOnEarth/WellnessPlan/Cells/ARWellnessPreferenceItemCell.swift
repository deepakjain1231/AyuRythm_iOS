//
//  ARWellnessPreferenceItemCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 25/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARWellnessPreferenceItemCell: UITableViewCell {
    
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var constraint_imageIV_width: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var item: ARWellnessPreferenceValueModel? {
        didSet {
            guard let item = item else { return }
            
            nameL.text = item.title

            bgView.layer.borderWidth = 1
            bgView.layer.borderColor = UIColor.fromHex(hexString: "#DFDFDF").cgColor
            bgView.backgroundColor = item.selected ? UIColor.fromHex(hexString: "#E2F4E2") : .clear
            imageIV.image = item.cellImage
            //imageIV.isHidden = !item.isSelected
            if imageIV.image == #imageLiteral(resourceName: "icon_task_done") {
                self.constraint_imageIV_width.constant = 25
            }
            else {
                self.constraint_imageIV_width.constant = 20
            }
            
        }
    }
}
