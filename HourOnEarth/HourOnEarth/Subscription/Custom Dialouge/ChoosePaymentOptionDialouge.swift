//
//  ChoosePaymentOptionDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 27/02/24.
//  Copyright © 2024 AyuRythm. All rights reserved.
//

enum PaymentOption {
    case knone
    case krazorpay
    case inapppurchase
}


protocol delegatePaymentOption {
    func chaoosePaymentOption(_ success: Bool, optionn: PaymentOption)
}

import UIKit

class ChoosePaymentOptionDialouge: UIViewController {

    var is_inappPayment = true
    var is_razorpayPayment = false
    var kpaymentOption = PaymentOption.knone
    var delegate: delegatePaymentOption?
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var btn_Continue: UIButton!
    
    @IBOutlet weak var view_Razorpay: UIView!
    @IBOutlet weak var view_InAppPurcahse: UIView!
    
    @IBOutlet weak var img_Razorpay: UIImageView!
    @IBOutlet weak var img_InAppPurcahse: UIImageView!
    
    @IBOutlet weak var constraint_view_Main_Bottom: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_Inner_Bottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupData()
        self.constraint_view_Main_Bottom.constant = -screenHeight
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func setupData() {
        self.constraint_view_Inner_Bottom.constant = (appDelegate.window?.safeAreaInsets.bottom ?? 0) + 22
        
        if self.is_inappPayment == false {
            self.view_InAppPurcahse.isHidden = true
        }
        
        if self.is_razorpayPayment == false {
            self.view_Razorpay.isHidden = true
        }
        self.btn_Continue.isEnabled = false
        self.btn_Continue.backgroundColor = UIColor.fromHex(hexString: "#777777")
        self.img_Razorpay.image = UIImage.init(named: "radio_button_unchecked_razor")
        self.img_InAppPurcahse.image = UIImage.init(named: "radio_button_unchecked_razor")
        
    }

    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_Main_Bottom.constant = 0
            self.view_Main.roundCorners(corners: [.topLeft, .topRight], radius: 16)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.view_Main.roundCorners(corners: [.topLeft, .topRight], radius: 16)
        }
    }
        
    func clkToClose(_ action: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_Main_Bottom.constant = -screenHeight
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if action {
                self.delegate?.chaoosePaymentOption(true, optionn: self.kpaymentOption)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func btn_Close_Action(_ sender: UIButton) {
        self.clkToClose(false)
    }
      
    @IBAction func btn_inApp_Action(_ sender: UIButton) {
        self.kpaymentOption = .inapppurchase
        self.btn_Continue.isEnabled = true
        self.btn_Continue.backgroundColor = AppColor.app_DarkGreenColor
        self.view_InAppPurcahse.layer.borderColor = AppColor.app_DarkGreenColor.cgColor
        self.img_Razorpay.image = UIImage.init(named: "radio_button_unchecked_razor")
        self.img_InAppPurcahse.image = UIImage.init(named: "radio_button_checked_razor")
        self.view_Razorpay.layer.borderColor = UIColor.fromHex(hexString: "#DADCE0").cgColor
    }
      
    
    @IBAction func btn_Razorpay_Action(_ sender: UIButton) {
        self.kpaymentOption = .krazorpay
        self.btn_Continue.isEnabled = true
        self.btn_Continue.backgroundColor = AppColor.app_DarkGreenColor
        self.view_InAppPurcahse.layer.borderColor = UIColor.fromHex(hexString: "#DADCE0").cgColor
        self.view_Razorpay.layer.borderColor = AppColor.app_DarkGreenColor.cgColor
        self.img_Razorpay.image = UIImage.init(named: "radio_button_checked_razor")
        self.img_InAppPurcahse.image = UIImage.init(named: "radio_button_unchecked_razor")
        
    }
      
    @IBAction func btn_Continue_Action(_ sender: UIButton) {
        self.clkToClose(true)
    }

}
