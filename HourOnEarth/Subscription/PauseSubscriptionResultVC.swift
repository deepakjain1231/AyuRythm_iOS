//
//  PauseSubscriptionResultVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 17/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class PauseSubscriptionResultVC: UIViewController {

    @IBOutlet weak var pauseDateL: UILabel!
    @IBOutlet weak var resumeDateL: UILabel!
    
    var activeSubscription: ARActiveSubscription?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pause".localized()
        setBackButtonTitle()
        setupUI()
    }
    
    func setupUI() {
        guard let activeSubscription = activeSubscription else {
            print(">>> no active subscription found")
            return
        }
        
        let dateFormat = "dd MMM, yyyy (EEE)"
        pauseDateL.text = activeSubscription.pauseDate.UTCToLocal(incomingFormat: App.dateFormat.yyyyMMdd, outGoingFormat: dateFormat)
        resumeDateL.text = activeSubscription.resumeDate.UTCToLocal(incomingFormat: App.dateFormat.yyyyMMdd, outGoingFormat: dateFormat)
        NotificationCenter.default.post(name: .refreshActiveSubscriptionData, object: nil)
    }

    @IBAction func doneBtnPressed(sender: UIButton) {
        self.popToViewController(ActiveSubscriptionPlanVC.self)
    }
}
