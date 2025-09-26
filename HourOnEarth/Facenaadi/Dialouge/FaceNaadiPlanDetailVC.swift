//
//  FaceNaadiPlanDetailVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 03/11/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

protocol delegate_buyPlan {
    func chooseFaceNaadiPlan(_ success: Bool, plan_product_id: String)
}

import UIKit

class FaceNaadiPlanDetailVC: UIViewController {
    
    var delegate: delegate_buyPlan?
    var screen_From = ScreenType.k_none
    var selectedPlan: ARSubscriptionPlanModel?
    
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var lbl_InfoText1: UILabel!
    @IBOutlet weak var lbl_InfoText2: UILabel!
    @IBOutlet weak var lbl_InfoText3: UILabel!
    @IBOutlet weak var lbl_buyNow: UILabel!
    @IBOutlet weak var btn_BuyNow: UIControl!
    @IBOutlet weak var constraint_btn_bottom: NSLayoutConstraint!
    @IBOutlet weak var constraint_viewMain_bottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupText()
        self.constraint_viewMain_bottom.constant = -screenHeight
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    
    
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewMain_bottom.constant = 0
            self.view_Main.roundCorners(corners: [.topLeft, .topRight], radius: 22)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose(_ isAction: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewMain_bottom.constant = -screenHeight
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if isAction {
                self.delegate?.chooseFaceNaadiPlan(true, plan_product_id: self.selectedPlan?.pack_id ?? "")// self.str_planID)
            }
        }
    }
    
    func setupText() {
        self.lbl_buyNow.text = "Buy Now".localized()
        self.lbl_InfoText1.text = "Access to Premium dosha assessment".localized()
        if self.screen_From == .from_home_remedies {
            self.lbl_InfoText1.text = "Access to personalized Home Remedies".localized()
        }
        else if self.screen_From == .from_AyuMonk_Only {
            self.lbl_InfoText1.text = "Access to asking personalized wellness questions".localized()
        }
        else if self.screen_From == .from_dietplan {
            self.lbl_InfoText1.text = "Access to Premium diet plan".localized()
        }
        
        self.lbl_InfoText3.text = "personalized results".localized()
        self.lbl_price.text = self.selectedPlan?.amount.priceValueString
        
        if (self.selectedPlan?.packMonths ?? 0) == 1 {
            self.lbl_title.text = "1 month plan avail at".localized()
            self.lbl_InfoText2.text = "Unlimited tests upto 1 month".localized()
            
            if self.screen_From == .from_home_remedies {
                self.lbl_InfoText2.text = "Unlimited personalized Home Remedies access upto 1 month".localized()
            }
            else if self.screen_From == .from_AyuMonk_Only {
                self.lbl_InfoText2.text = "Unlimited access upto 1 month".localized()
            }
            else if self.screen_From == .from_dietplan {
                self.lbl_InfoText2.text = "Diet plan access upto 1 month".localized()
            }
        }
        else if (self.selectedPlan?.packMonths ?? 0) == 3 {
            self.lbl_title.text = "3 month plan avail at".localized()
            self.lbl_InfoText2.text = "Unlimited tests upto 3 months".localized()
            
            if self.screen_From == .from_home_remedies {
                self.lbl_InfoText2.text = "Unlimited personalized Home Remedies access upto 3 months".localized()
            }
            else if self.screen_From == .from_AyuMonk_Only {
                self.lbl_InfoText2.text = "Unlimited access upto 3 months".localized()
            }
            else if self.screen_From == .from_dietplan {
                self.lbl_InfoText2.text = "Diet plan access upto 3 month".localized()
            }
        }
        else if (self.selectedPlan?.packMonths ?? 0) == 6 {
            self.lbl_title.text = "6 month plan avail at".localized()
            self.lbl_InfoText2.text = "Unlimited tests upto 6 months".localized()
            
            if self.screen_From == .from_home_remedies {
                self.lbl_InfoText2.text = "Unlimited personalized Home Remedies access upto 6 months".localized()
            }
            else if self.screen_From == .from_AyuMonk_Only {
                self.lbl_InfoText2.text = "Unlimited access upto 6 months".localized()
            }
            else if self.screen_From == .from_dietplan {
                self.lbl_InfoText2.text = "Diet plan access upto 6 month".localized()
            }
        }
        else if (self.selectedPlan?.packMonths ?? 0) == 12 {
            self.lbl_title.text = "12 month plan avail at".localized()
            self.lbl_InfoText2.text = "Unlimited tests upto 12 months".localized()
            
            if self.screen_From == .from_home_remedies {
                self.lbl_InfoText2.text = "Unlimited personalized Home Remedies access upto 12 months".localized()
            }
            else if self.screen_From == .from_AyuMonk_Only {
                self.lbl_InfoText2.text = "Unlimited access upto 12 months".localized()
            }
            else if self.screen_From == .from_dietplan {
                self.lbl_InfoText2.text = "Diet plan access upto 12 month".localized()
            }
        }
                
        let bottomsafeArea: CGFloat = appDelegate.window?.safeAreaInsets.bottom ?? 0
        if bottomsafeArea != 0 {
            self.constraint_btn_bottom.constant = 30
        }
        else {
            self.constraint_btn_bottom.constant = 20
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
    
    @IBAction func btn_close_Action(_ sender: Any) {
        self.clkToClose()
    }
    
    @IBAction func btn_buyNow_action(_ sender: UIControl) {
        self.clkToClose(true)
    }
    
}


