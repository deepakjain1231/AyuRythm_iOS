//
//  RedeemCouponCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 17/11/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class RedeemCouponCell: UITableViewCell {
    
    @IBOutlet weak var offerL: UILabel!
    @IBOutlet weak var companyNameL: UILabel!
    @IBOutlet weak var couponCodeBtn: UIButton!
    @IBOutlet weak var messageL: UILabel!
    @IBOutlet weak var offerTitleL: UILabel!
    
    var didTappedonShopNow: ((UIButton)->Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        offerTitleL.transform = CGAffineTransform(rotationAngle: -.pi/2)
        
        let dashedBorderL = CAShapeLayer()
        dashedBorderL.strokeColor = kAppGreenD2Color.cgColor
        dashedBorderL.lineDashPattern = [5, 3]
        dashedBorderL.frame = couponCodeBtn.bounds
        dashedBorderL.fillColor = nil
        dashedBorderL.lineWidth = 1.6
        dashedBorderL.path = UIBezierPath(roundedRect: couponCodeBtn.bounds, cornerRadius: 6).cgPath
        couponCodeBtn.layer.addSublayer(dashedBorderL)
    }
    
    var coupon: CouponModel? {
        didSet {
            guard let coupon = coupon else { return }
            
            offerL.text = coupon.categoryName
            companyNameL.text = coupon.companyName
            messageL.text = coupon.message
            couponCodeBtn.setTitle(coupon.couponcode, for: .normal)
        }
    }
    
    @IBAction func btnCopyCouponCodeClicked(_ sender: UIButton) {
        if let code = sender.title(for: .normal), !code.isEmpty {
            UIPasteboard.general.string = code
            if let vc = UIApplication.topViewController() {
                Utils.showAlertWithTitleInControllerWithCompletion("", message: "Coupon code copied successfully".localized(), okTitle: "Ok".localized(), controller: vc) {
                    print("code : ", code)
                }
            }
        }
    }
    
    @IBAction func shopNowBtnPressed(sender: UIButton) {
        if self.didTappedonShopNow != nil {
            self.didTappedonShopNow!(sender)
        }
    }
}
