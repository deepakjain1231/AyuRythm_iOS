//
//  ChooseSubscriptionPlanCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 03/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class ChooseSubscriptionPlanCell: UITableViewCell {
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var subtitleL: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var statusBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        bgView.cornerRadiuss = 10
    }
    
    var data: ARSubscriptionPlanModel? {
        didSet {
            guard let data = data else { return }
            
            let months = data.packMonths 
            let monthStr = "\(months) " + (months > 1 ? "Months".localized() : "Month".localized())
            titleL.text = data.amount.priceValueString + "/ " + monthStr
//            subtitleL.text = "(\(months) month at " +
//            (data.amount.floatValue/Float(months)).priceValueString +
//            "/month " +
//            "\(data.bonusPercentage!) off)"
            subtitleL.text = String(format: "(%@ at %@/month %@ off)".localized(), monthStr, (data.amount.floatValue/Float(months)).priceValueString, data.bonusPercentage)
        }
    }
    
    func updateUI(isSelected: Bool) {
        statusBtn.isSelected = isSelected
        bgView.layer.borderWidth = isSelected ? 1 : 0
        bgView.layer.borderColor = UIColor.fromHex(hexString: "#6CA76C").cgColor
    }
}
