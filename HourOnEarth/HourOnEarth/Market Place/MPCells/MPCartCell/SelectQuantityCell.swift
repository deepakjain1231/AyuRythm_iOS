//
//  SelectQuantityCell.swift
//  HourOnEarth
//
//  Created by CodeInfoWay CodeInfoWay on 6/25/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class SelectQuantityCell: UITableViewCell {

    @IBOutlet weak var lbl_Size: UILabel!
    @IBOutlet weak var lbl_Prev_Price: UILabel!
    @IBOutlet weak var lbl_CurrentPrice: UILabel!
    @IBOutlet weak var lbl_OutOfStock: UILabel!
    @IBOutlet weak var btnRadioSelection: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setAttributeText(_ prv_Price: String) {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: prv_Price)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
        self.lbl_Prev_Price.attributedText = attributeString
    }
    
}
