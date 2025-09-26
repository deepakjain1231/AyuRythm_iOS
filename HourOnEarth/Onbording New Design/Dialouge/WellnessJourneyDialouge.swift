//
//  WellnessJourneyDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 28/06/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

protocol didTappedDelegate {
    func didTappedClose(_ success: Bool, product_id: String)
}

class WellnessJourneyDialouge: UIViewController {
    
    var str_product_ID = ""
    var delegate: didTappedDelegate?
    var dic_Value = [String: Any]()
    var screen_from = ScreenType.k_none
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var view_Inner_Top: UIView!
    @IBOutlet weak var view_Icon_BG: UIView!
    @IBOutlet weak var constrint_view_Icon_BG_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_Header_Height: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setup()
        self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func setup() {
        self.lbl_title.text = "Enjoy your wellness journey".localized()
        self.lbl_subtitle.text = "Thank you for helping us tailor the app for you!\nEnjoy your journey to a balanced lifestyle :)".localized()

        self.view_Inner_Top.roundCornerss([UIRectCorner.topLeft, .topRight], radius: 20)
        
        if self.screen_from == .from_subscription {
            var strName = "User"
            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                strName = empData["name"] as? String ?? ""
            }
            
            self.lbl_title.text = "Hello".localized() + String(format:" %@", strName)
            self.lbl_subtitle.text = String(format: "subscription_info_upi_text".localized(), strName)
            self.view_Icon_BG.isHidden = true
            self.constrint_view_Icon_BG_Height.constant = 50
            self.constraint_view_Header_Height.constant = 0
            
        }
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Main.transform = .identity
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            self.delegate?.didTappedClose(true, product_id: self.str_product_ID)
            
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
        self.clkToClose()
    }
    
}
