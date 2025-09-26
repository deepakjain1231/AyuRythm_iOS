//
//  ARBPLDeviceRegisterSuccessVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 15/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARBPLDeviceRegisterSuccessVC: UIViewController {
    
    @IBOutlet var blurView: UIVisualEffectView! {
        didSet {
            blurView.layer.cornerRadius = 12
            blurView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var messageL: UILabel!
    
    var isGetSubscripitionCoupon = false

    override func viewDidLoad() {
        super.viewDidLoad()
        imageIV.image = UIImage.gifImageWithName("bpl_success_animation")
        titleL.text = "Congratulations".localized()
        let days = ARBPLDeviceManager.shared.appliedPromocodeDays
        if isGetSubscripitionCoupon, !days.isEmpty {
            messageL.text = "You've successfully registered with your BPL device and earned \(days) days free subscription plan.".localized()
        } else {
            messageL.text = "You've successfully registered with your BPL device.".localized()
        }
        
    }
    
    @IBAction func cancelBtnPressed(sender: UIButton) {
        dismiss(animated: true)
    }
}

extension ARBPLDeviceRegisterSuccessVC {
    static func showScreen(isGetSubscripitionCoupon: Bool, fromVC: UIViewController) {
        let vc = ARBPLDeviceRegisterSuccessVC.instantiate(fromAppStoryboard: .BPLDevices)
        vc.isGetSubscripitionCoupon = isGetSubscripitionCoupon
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        fromVC.present(vc, animated: true, completion: nil)
    }
}
