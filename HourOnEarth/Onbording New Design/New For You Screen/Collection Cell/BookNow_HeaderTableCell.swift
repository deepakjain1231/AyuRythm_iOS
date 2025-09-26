//
//  BookNow_HeaderTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 26/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class BookNow_HeaderTableCell: UITableViewCell {
    
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_sessionCost: UILabel!
    @IBOutlet weak var lbl_old_sessionCost: UILabel!
    @IBOutlet weak var lbl_discount: UILabel!
    @IBOutlet weak var lbl_inclusive_all_tax: UILabel!
    @IBOutlet weak var lbl_sessionDuration: UILabel!
    @IBOutlet weak var view_Discount: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func setupCellData(package_detail: TrainerPackage) {
        let strName = package_detail.name
        let discount = package_detail.final_discount_per_session
        let str_TotalSession = package_detail.total_session_string
        let str_SessionDuration = package_detail.time_per_session ?? ""
        let sessionPrice = package_detail.final_dis_price_per_session.priceValueString
        
        lbl_Title.text = strName
        lbl_sessionCost.text = sessionPrice + "/" + "session".localized()
        view_Discount.isHidden = discount > 0 ? false : true
        lbl_discount.text = discount > 0 ? "\(discount.nonDecimalStringValue)% Off" : ""
        view_Discount.isHidden = discount > 0 ? false : true
        lbl_sessionDuration.text = str_TotalSession + " | " + str_SessionDuration + " " + "min each".localized()
    }
    
}


