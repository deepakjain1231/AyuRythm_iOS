//
//  FreeTrialEndedDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 13/12/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

protocol delegate_click_event {
    func handle_dialouge_btn_click_event(_ success: Bool)
}

import UIKit

class FreeTrialEndedDialouge: UIViewController {

    var screen_from = ScreenType.k_none
    var delegate: delegate_click_event?
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var view_inner: UIView!
    @IBOutlet weak var lbl_btn_ok: UILabel!
    @IBOutlet weak var btn_ok: UIControl!
    @IBOutlet weak var lbl_ok: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupData()
        self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func setupData() {
        self.lbl_ok.text = "Ok".localized()
        self.lbl_title.text = "Your free trial has ended!".localized()
        if self.screen_from == .from_home_remedies {
            self.lbl_subtitle.text = "Unlock unlimited access to personalized home remedies by joining our Prime Club, or subscribe to personalized home remedies.".localized()
        }
        else if self.screen_from == .from_AyuMonk_Only {
            self.lbl_subtitle.text = "Unlock unlimited access to AyuMonk by joining our Prime Club, or subscribe to AyuMonk.".localized()
        }
    }

    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Main.transform = .identity
            self.view_inner.roundCornerss([.bottomLeft, .bottomRight], radius: 16)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
        
    func clkToClose(_ action: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()

            self.delegate?.handle_dialouge_btn_click_event(action)
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
        
    @IBAction func btn_Ok_Action(_ sender: UIButton) {
        self.clkToClose(true)
    }
}
