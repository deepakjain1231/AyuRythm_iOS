//
//  PauseSubscriptionPopupVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 16/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class PauseSubscriptionPopupVC: UIViewController {

    @IBOutlet var blurView: UIVisualEffectView! {
        didSet {
            blurView.layer.cornerRadius = 12
            blurView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var greetingL: UILabel!
    
    var continueHandler: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        greetingL.text = String(format: "Hi %@, Need a break?".localized(), Utils.getLoginUserUsername())
    }
    
    static func showScreen(from fromVC: UIViewController, continueHandler: @escaping ()->Void) {
        let vc = PauseSubscriptionPopupVC.instantiate(fromAppStoryboard: .Subscription)
        vc.continueHandler = continueHandler
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        fromVC.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func continueBtnPressed(sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.continueHandler?()
        }
    }
    
    @IBAction func cancelBtnPressed(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
