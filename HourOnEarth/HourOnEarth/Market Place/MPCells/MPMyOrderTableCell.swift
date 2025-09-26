//
//  MPMyOrderTableCell.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 20/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import Cosmos

class MPMyOrderTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var view_rating: UIView!
    @IBOutlet weak var stack_rating: UIStackView!
    @IBOutlet weak var lbl_writeReview: UILabel!
    @IBOutlet weak var lbl_deliveryStatus: UILabel!
    @IBOutlet weak var icon_deliveryStatus: UIImageView!
    @IBOutlet weak var img_Product: UIImageView!
    @IBOutlet weak var lbl_ProductName: UILabel!
    @IBOutlet weak var lbl_ProductSubtitle: UILabel!
    @IBOutlet weak var lbl_deliveryDate: UILabel!
    @IBOutlet weak var view_Delivery_BG: UIView!
    @IBOutlet weak var product_rating: CosmosView!
    @IBOutlet weak var constraint_view_Base_Top: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_Base_Bottom: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_Rating_Height: NSLayoutConstraint!
    
    @IBOutlet weak var view_UnderlineTop1_withBorder: UIView!
    @IBOutlet weak var view_UnderlineTop1_withoutBorder: UIView!
    
    @IBOutlet weak var view_UnderlineBottom1_withBorder: UIView!
    @IBOutlet weak var view_UnderlineBottom1_withoutBorder: UIView!
    
    var didTappedReview: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - UIButton Method Action
    @IBAction func btn_Review_Action(_ sender: UIControl) {
        if self.didTappedReview != nil {
            self.didTappedReview!(sender)
        }
    }
    
}
