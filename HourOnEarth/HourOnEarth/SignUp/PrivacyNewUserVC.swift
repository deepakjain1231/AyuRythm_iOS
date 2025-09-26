//
//  PrivacyNewUserVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 26/03/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class PrivacyNewUserVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblsub_Title: UILabel!
    @IBOutlet weak var lblAccContinue: UILabel!
    
    @IBOutlet weak var view_mainBG: UIView!
    @IBOutlet weak var constraint_button_bottom: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_mainBG_TOP: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setupData()
        self.constraint_view_mainBG_TOP.constant = -UIScreen.main.bounds.size.height
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func setupData() {
        self.lblTitle.text = "we_value_your_privacy".localized()
        self.lblsub_Title.text = "privacy_value".localized()
        self.lblAccContinue.text = "accept_and_continue".localized()
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_mainBG_TOP.constant = -20
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_mainBG_TOP.constant = -UIScreen.main.bounds.size.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
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
    
    // MARK: - FUNCTIONS
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.clkToClose()
    }

}

