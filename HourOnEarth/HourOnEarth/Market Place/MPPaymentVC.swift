//
//  MPPaymentVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 16/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class MPPaymentVC: UIViewController, didSelectOptionSuccess_Failed {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    //MARK: - UIButton Method Action
    @IBAction func btn_Success_Action(_ sender: UIControl) {
        if let parent = kSharedAppDelegate.window?.rootViewController {
            let objDialouge = MPPaymentSuccessFailedVC(nibName: "MPPaymentSuccessFailedVC", bundle: nil)
            objDialouge.delegate = self
            objDialouge.screenfrom = .MP_PaymentSuccess
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            parent.view.addSubview((objDialouge.view)!)
            parent.view.bringSubviewToFront(objDialouge.view)
            objDialouge.didMove(toParent: parent)
        }
    }
    
    @IBAction func btn_Failed_Action(_ sender: UIControl) {
        if let parent = kSharedAppDelegate.window?.rootViewController {
            let objDialouge = MPPaymentSuccessFailedVC(nibName: "MPPaymentSuccessFailedVC", bundle: nil)
            objDialouge.delegate = self
            objDialouge.screenfrom = .MP_PaymentFailed
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            parent.view.addSubview((objDialouge.view)!)
            parent.view.bringSubviewToFront(objDialouge.view)
            objDialouge.didMove(toParent: parent)
        }
    }
    
    
    //MARK: - AFTER PAYMENT SUCCESS FAILED
    func did_selectPaymentOption(_ seccess: Bool, is_payment_success: Bool) {
        if seccess {
            if is_payment_success {
                let vc = MPOrderConfirmedVC.instantiate(fromAppStoryboard: .MarketPlace)
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }
    }
}
