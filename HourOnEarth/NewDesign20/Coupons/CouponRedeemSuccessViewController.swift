//
//  CouponRedeemSuccessViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 16/11/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

protocol delegateAedPoppupBack {
    func seedPopupBack_action(_ success: Bool)
}

import UIKit


class CouponRedeemSuccessViewController: UIViewController {

    var delegate: delegateAedPoppupBack?
    @IBOutlet weak var offerL: UILabel!
    @IBOutlet weak var companyNameL: UILabel!
    @IBOutlet weak var couponCodeBtn: UIButton!
    @IBOutlet weak var messageL: UILabel!
    @IBOutlet weak var offerTitleL: UILabel!
    
    var coupon: CouponModel?
    var couponCompany: CouponCompanyModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        guard let coupon = coupon else { return }
        
        offerL.text = coupon.categoryName
        companyNameL.text = couponCompany?.companyName
        messageL.text = coupon.message
        offerTitleL.transform = CGAffineTransform(rotationAngle: -.pi/2)
        
        couponCodeBtn.setTitle(coupon.couponcode, for: .normal)
        let dashedBorderL = CAShapeLayer()
        dashedBorderL.strokeColor = kAppGreenD2Color.cgColor
        dashedBorderL.lineDashPattern = [5, 3]
        dashedBorderL.frame = couponCodeBtn.bounds
        dashedBorderL.fillColor = nil
        dashedBorderL.lineWidth = 1.6
        dashedBorderL.path = UIBezierPath(roundedRect: couponCodeBtn.bounds, cornerRadius: 6).cgPath
        couponCodeBtn.layer.addSublayer(dashedBorderL)
    }
    
    @IBAction func closeBtnPressed(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCopyCouponCodeClicked(_ sender: UIButton) {
        if let code = sender.title(for: .normal), !code.isEmpty {
            UIPasteboard.general.string = code
            Utils.showAlertWithTitleInControllerWithCompletion("", message: "Coupon code copied successfully".localized(), okTitle: "Ok".localized(), controller: self) {
                print("code : ", code)
            }
        }
    }
    
    @IBAction func shopNowBtnPressed(sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.seedPopupBack_action(true)
        }
        
        
        
        
        
//        if let siteURL = coupon?.url, let url = URL(string: siteURL), UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//        }
    }
}
