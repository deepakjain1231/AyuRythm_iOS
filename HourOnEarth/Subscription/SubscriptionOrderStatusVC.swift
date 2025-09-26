//
//  SubscriptionOrderStatusVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 08/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class SubscriptionOrderStatusVC: UIViewController {
    
    @IBOutlet weak var effectIV: UIImageView!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var messageL: UILabel!
    @IBOutlet weak var retryOrNextBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var status = false
    var screenFrom = ScreenType.k_none
    var plan: ARSubscriptionPlanModel?
    var orderDetails: ARSubsOrderDetailModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        if status == true {
            effectIV.image = UIImage.gifImageWithName("success-check")
            titleL.text = "Success!".localized()
            messageL.text = "Your transaction is successful".localized()
            retryOrNextBtn.setTitle("Next".localized(), for: .normal)
            cancelBtn.isHidden = true
        } else {
            effectIV.image = UIImage.gifImageWithName("failed-attempt")
            titleL.text = "Oops!".localized()
            messageL.text = "Something went wrong".localized()
            retryOrNextBtn.setTitle("Retry".localized(), for: .normal)
            cancelBtn.isHidden = false
        }
    }
    
    @IBAction func retryOrNextBtnPressed(sender: UIButton) {
        if status == true {
            let vc = SubscriptionOrderSummaryVC.instantiate(fromAppStoryboard: .Subscription)
            vc.plan = plan
            vc.orderDetails = orderDetails
            vc.screen_from = self.screenFrom
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelBtnPressed(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension SubscriptionOrderStatusVC {
    static func showScreen(plan: ARSubscriptionPlanModel?, orderDetails: ARSubsOrderDetailModel?, status: Bool = true, fromVC: UIViewController, screnn_from: ScreenType = ScreenType.k_none) {
        let vc = SubscriptionOrderStatusVC.instantiate(fromAppStoryboard: .Subscription)
        vc.status = status
        vc.plan = plan
        vc.screenFrom = screnn_from
        vc.orderDetails = orderDetails
        let nvc = UINavigationController(rootViewController: vc)
        nvc.navigationBar.isHidden = true
        nvc.modalPresentationStyle = .fullScreen
        fromVC.present(nvc, animated: true, completion: nil)
    }
}
