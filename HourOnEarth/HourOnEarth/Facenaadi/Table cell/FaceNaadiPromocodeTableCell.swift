//
//  FaceNaadiPromocodeTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 25/11/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class FaceNaadiPromocodeTableCell: UITableViewCell {

    @IBOutlet weak var view_Base_BG: UIView!
    @IBOutlet weak var view_Coupon_BG: UIView!
    @IBOutlet weak var txt_coupon: UITextField!
    @IBOutlet weak var btn_Apply: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var view_seperatorView1: DashedLineView!
    @IBOutlet weak var view_seperatorView2: DashedLineView!
    
    var didTappedApplyButton: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view_seperatorView1.perDashLength = 5
        self.view_seperatorView2.perDashLength = 5
        self.view_seperatorView1.spaceBetweenDash = 5
        self.view_seperatorView2.spaceBetweenDash = 5
        self.lbl_title.text = "Enter coupon code".localized()
        self.txt_coupon.placeholder = "Enter coupon code".localized()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: - UIButton Action
    @IBAction func btn_Apply_Action(_ sender: UIButton) {
        self.didTappedApplyButton?(sender)
    }
}
