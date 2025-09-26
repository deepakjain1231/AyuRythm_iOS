//
//  HomeScreenKriyaMudraTableCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 09/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import MKMagneticProgress

class HomeScreenKriyaMudraTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var view_BG: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var img_Type: UIImageView!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var lbl_bottom: UILabel!
    @IBOutlet weak var lbl_ayuseed: UILabel!
    @IBOutlet weak var view_ayuseed: UIView!
    @IBOutlet weak var progressView: MKMagneticProgress!
    
    var didTappedonCell: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.progressView.setProgress(progress: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_check_Action(_ sender: UIButton) {
        if self.didTappedonCell != nil {
            self.didTappedonCell!(sender)
        }
    }
    
}
