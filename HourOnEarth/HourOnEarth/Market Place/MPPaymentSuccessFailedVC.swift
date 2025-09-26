//
//  MPPaymentSuccessFailedVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 16/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

protocol didSelectOptionSuccess_Failed {
    func did_selectPaymentOption(_ seccess: Bool, is_payment_success: Bool)
}

class MPPaymentSuccessFailedVC: UIViewController {

    var is_screenfrrom = ""
    var screenfrom = ScreenType.k_none
    var delegate: didSelectOptionSuccess_Failed?

    @IBOutlet weak var view_Success: UIView!
    @IBOutlet weak var view_Failed: UIView!
    @IBOutlet weak var lblSuccessPrice: UILabel!
    @IBOutlet weak var lblFailurePrice: UILabel!
    @IBOutlet weak var btn_ReturnHome: UIControl!
    
    var price: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view_Failed.layer.cornerRadius = 12
        self.view_Success.layer.cornerRadius = 12
        self.lblFailurePrice.text = "Payment of ₹\(price) failed!"
        self.lblSuccessPrice.text = "₹\(price)"
        if self.screenfrom == ScreenType.MP_PaymentSuccess {
            self.view_Failed.isHidden = true
            self.view_Success.isHidden = false
            self.view_Success.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            
            DispatchQueue.delay(.seconds(4)) {
                self.close_animation(action: "success")
                self.dismiss(animated: false) {
                    if self.is_screenfrrom == "" {
                        let vc = MPOrderConfirmedVC.instantiate(fromAppStoryboard: .MarketPlace)
                        findtopViewController()!.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        else {
            self.view_Failed.isHidden = false
            self.view_Success.isHidden = true
            self.view_Failed.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        }
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            if self.screenfrom == ScreenType.MP_PaymentSuccess {
                self.view_Success.transform = .identity
            }
            else {
                self.view_Failed.transform = .identity
            }
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        } completion: { success in
        }
    }
    
    @objc func close_animation(action: String) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            if self.screenfrom == ScreenType.MP_PaymentSuccess {
                self.view_Success.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            }
            else {
                self.view_Failed.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            }
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        } completion: { success in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            if action == "success" {
                self.delegate?.did_selectPaymentOption(true, is_payment_success: true)
            }
            else {
                self.delegate?.did_selectPaymentOption(true, is_payment_success: false)
            }
            NotificationCenter.default.post(name: .refreshProductData, object: nil)
            NotificationCenter.default.post(name: Notification.Name("productAddedToCart"), object: nil)
        }
    }

    //MARK: - UIButton Method Action
    @IBAction func btn_Close_Action(_ sender: UIControl) {
        self.close_animation(action: "failed")
        self.dismiss(animated: false) {

        }
    }
    
}
