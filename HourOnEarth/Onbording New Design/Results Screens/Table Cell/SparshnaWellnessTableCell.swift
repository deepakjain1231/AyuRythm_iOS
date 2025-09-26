//
//  SparshnaWellnessTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 29/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class SparshnaWellnessTableCell: UITableViewCell {

    private var increasedValues = [KPVType]()
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_detail_result: UILabel!
    @IBOutlet weak var img_aggrivation: UIImageView!
    @IBOutlet weak var view_aggrivation: UIView!
    @IBOutlet weak var lbl_aggrivationType: UILabel!
    @IBOutlet weak var lbl_bodyConstitution: UILabel!
    @IBOutlet weak var lbl_bottomText: UILabel!
    @IBOutlet weak var img_KPV_full: UIImageView!
    @IBOutlet weak var img_KPV_arrow: UIImageView!
    
    
    var didTappedonDetailResult: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_title.text = "Wellness Index".localized()
        self.lbl_detail_result.text = "View detailed result".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_detailResultAction(_ sender: UIControl) {
        if self.didTappedonDetailResult != nil {
            self.didTappedonDetailResult!(sender)
        }
    }
    
}
