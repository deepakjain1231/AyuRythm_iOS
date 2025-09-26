//
//  HomeRemediesDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 13/12/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class HomeRemediesDialouge: UIViewController {
    
    var screen_from = ScreenType.k_none
    var delegate: delegateFaceNaadi?
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var btn_prime: UIButton!
    @IBOutlet weak var btn_unlock: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupData()
        self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func setupData() {
        self.btn_prime.setTitle("Join Prime Club".localized(), for: .normal)
        self.btn_unlock.setTitle("Unlock Home Remedies".localized(), for: .normal)
        self.lbl_title.text = "Personalized Home Remedies".localized()
        self.lbl_subtitle.text = "Personalized home remedies, aligned with your doshas.".localized()
    }
    
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Main.transform = .identity
            self.view_Main.layer.cornerRadius = 16
            self.view_Main.clipsToBounds = true
            self.view_Main.layer.masksToBounds = true
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose(_ action: Bool, isPrime: String) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if action {
                self.delegate?.subscribe_tryNow_click(true, type: isPrime == "prime" ? ScreenType.from_PrimeMember : self.screen_from)
            }
            else {
                self.delegate?.subscribe_tryNow_click(false, type: .k_none)
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
        self.clkToClose(false, isPrime: "")
    }
    
    @IBAction func btn_JoinPrime_Action(_ sender: UIButton) {
        self.clkToClose(true, isPrime: "prime")
    }
    
    @IBAction func btn_Unlock_Action(_ sender: UIButton) {
        self.clkToClose(true, isPrime: "unlock")
    }
}
