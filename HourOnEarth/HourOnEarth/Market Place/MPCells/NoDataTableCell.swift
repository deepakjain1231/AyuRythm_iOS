//
//  NoDataTableCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 13/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class NoDataTableCell: UITableViewCell {

    @IBOutlet weak var view_BG: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var btn_ShopNow: UIControl!
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var constraint_lbl_Title_TOP: NSLayoutConstraint!
    
    var did_TappedShopNow: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func btn_ShopNow_Action(_ sender: UIControl) {
        self.did_TappedShopNow!(sender)
    }
    
}
