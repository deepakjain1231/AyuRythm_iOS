//
//  MPCouponTableCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 16/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class MPCouponTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var view_Basecorner_left: UIView!
    @IBOutlet weak var view_Basecorner_right: UIView!
    @IBOutlet weak var lblOffCoupon: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSaveUpto: UILabel!
    @IBOutlet weak var lblExpiryOn: UILabel!
    @IBOutlet weak var lblCouponCode: UILabel!
    @IBOutlet weak var img_checkmark: UIImageView!
    @IBOutlet weak var btn_Apply: UIButton!
    @IBOutlet weak var view_disable: UIView!
    
    var completion: (() -> ())!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view_Base.layer.borderWidth = 1
        self.view_Base.layer.borderColor = UIColor.fromHex(hexString: "#C4C4C4").cgColor
        
        self.view_Basecorner_left.layer.borderWidth = 1
        self.view_Basecorner_left.layer.borderColor = UIColor.fromHex(hexString: "#C4C4C4").cgColor
        
        self.view_Basecorner_right.layer.borderWidth = 1
        self.view_Basecorner_right.layer.borderColor = UIColor.fromHex(hexString: "#C4C4C4").cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func applyButton(_ sender: UIButton){
        completion()
    }
}
