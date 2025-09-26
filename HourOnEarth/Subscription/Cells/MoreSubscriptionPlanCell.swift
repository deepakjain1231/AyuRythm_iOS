//
//  MoreSubscriptionPlanCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 07/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

// MARK: -
class MoreSubscriptionPlanCell: UITableViewCell {
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var priceL: UILabel!
    @IBOutlet weak var price2L: UILabel!
    @IBOutlet weak var planTagL: PaddingLabel!
    @IBOutlet weak var bgIV: UIImageView!
    @IBOutlet weak var arrowBtn: UIControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        planTagL.roundCorners(corners: [.bottomLeft], radius: 10)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    var plan: ARSubscriptionPlanModel? {
        didSet {
            guard let data = plan else { return }
            
            titleL.text = data.packName
            let discountedPrice = (data.amount.floatValue/Float(data.packMonths)).priceValueString
            var priceAttributedText = NSAttributedString(string: data.amount.priceValueString + "  ")
            priceAttributedText += NSAttributedString(string: data.regularAmount, attributes: [.font: UIFont.systemFont(ofSize: 11, weight: .regular)]).struckthrough
            priceL.attributedText = priceAttributedText
            price2L.text = discountedPrice + "/month".localized()
            planTagL.isHidden = true
            
            /*
             if data.isMostPopular {
                 planTagL.isHidden = false
                 bgIV.image = #imageLiteral(resourceName: "plan-most-popular")
                 arrowBtn.backgroundColor = UIColor.fromHex(hexString: "#F4B800")
             } else {
                 planTagL.isHidden = true
                 bgIV.image = #imageLiteral(resourceName: "plan-normal")
                 arrowBtn.backgroundColor = UIColor.fromHex(hexString: "#84CB81")
             }
             */
        }
    }
    
    func updateCellBG(for row: Int) {
        let bgDetails = plan?.getBGImageAndColor(row: row)
        bgIV.image = bgDetails?.image
        arrowBtn.backgroundColor = bgDetails?.color
    }
}
