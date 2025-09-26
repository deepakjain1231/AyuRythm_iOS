//
//  ShukhamBannerTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 08/11/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class ShukhamBannerTableCell: UITableViewCell {

    @IBOutlet weak var img_banner: UIImageView!
    @IBOutlet weak var view_blank: UIView!
    @IBOutlet weak var btn_download: UIControl!
    @IBOutlet weak var lbl_download: UILabel!
    @IBOutlet weak var constraint_view_Height: NSLayoutConstraint!
    
    var didTappedonDownload: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view_blank.isHidden = true
        self.btn_download.isHidden = true
        self.constraint_view_Height.constant = 135
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_Download_Action(_ sender: UIControl) {
        self.didTappedonDownload?(sender)
    }
    
}
