//
//  AyuMonkDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 11/12/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class AyuMonkDialouge: UIViewController {

    var delegate: delegateFaceNaadi?
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var btn_prime: UIControl!
    @IBOutlet weak var lbl_prine: UILabel!
    @IBOutlet weak var btn_unlock: UIControl!
    @IBOutlet weak var lbl_unlock: UILabel!
    @IBOutlet weak var img_icon: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setup()
        self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }

    func setup() {
        self.lbl_unlock.text = "Unlock AyuMonk".localized()
        self.lbl_prine.text = "Join Prime Club".localized()
        self.lbl_title.text = "Welcome to AyuMonk - Your wellness companion".localized()
        self.lbl_subtitle.text = "An AI-based guide on exercise, diet plans & advice for a balanced life".localized()
    }
        
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Main.transform = .identity
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
                self.delegate?.subscribe_tryNow_click(true, type: isPrime == "prime" ? ScreenType.from_PrimeMember : ScreenType.from_AyuMonk_Only)
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
