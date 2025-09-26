//
//  ARNoCommentTableCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 24/08/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARNoCommentTableCell: UITableViewCell {

    @IBOutlet weak var img_view_Nodata: UIImageView!
    @IBOutlet weak var lbl_Nodata_Title: UILabel!
    @IBOutlet weak var lbl_Nodata_subTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_Nodata_Title.text = "No comments found!".localized()
        self.lbl_Nodata_subTitle.text = "No comment text".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
