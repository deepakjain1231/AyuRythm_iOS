//
//  RecommendedProductAlertDialouge.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 03/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

protocol delegate_recomded {
    func clkOnContuniforRecomendedProduct(is_success: Bool)
}

class RecommendedProductAlertDialouge: UIViewController {

    var screenFrom = ScreenType.k_none
    var delegate: delegate_recomded?
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Sub_Title: UILabel!
    
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnLater: UIButton!
    @IBOutlet weak var btn_TitleContinue: UILabel!
    @IBOutlet weak var btn_TitleLater: UILabel!
    @IBOutlet weak var viewButtonBg: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view_Main.layer.cornerRadius = 12
        
        
        if self.screenFrom == .MP_categories {
            self.lbl_Title.text = "Please complete Sparshna & Prashna test to view personalize products"
            
            if kSharedAppDelegate.userId.isEmpty {
                self.lbl_Sub_Title.text = "Register now and complete analyses to view personalized products and activities."
            }
            else {
                self.lbl_Sub_Title.text = "Fill up few basic details and complete the Sparshna (Pulse Analysis) and Prashna (questionnaire) to assess your dosha balance and view personalized products."
            }
        }
        else {
            self.lbl_Title.text = "Please complete Sparshna & Prashna test to view recommended products"
            
            if kSharedAppDelegate.userId.isEmpty {
                self.lbl_Sub_Title.text = "Register now and complete analyses to view recommended products and activities."
            }
            else {
                self.lbl_Sub_Title.text = "Fill up few basic details and complete the Sparshna (Pulse Analysis) and Prashna (questionnaire) to assess your dosha balance and view recommended products."
            }
        }
        

//        self.btnLater.layer.borderWidth = 2
//        self.btnLater.roundCorners(corners: [.bottomRight], radius: 12)
//        self.btnContinue.roundCorners(corners: [.bottomLeft], radius: 12)
//        self.btnContinue.backgroundColor = UIColor.fromHex(hexString: "#3C91E6")
//        self.btnLater.layer.borderColor = UIColor.fromHex(hexString: "#3C91E6").cgColor
        self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.view_Main.transform = .identity
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        } completion: { success in
            self.viewButtonBg.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
//            self.btnLater.roundCorners(corners: [.bottomLeft], radius: 12)
//            self.btnContinue.roundCorners(corners: [.bottomRight], radius: 12)
        }
    }
    
    @objc func close_animation(_ action: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        } completion: { success in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if action {
                self.delegate?.clkOnContuniforRecomendedProduct(is_success: true)
            }
        }
    }
    
    //MARK: - UIButton Method Action
    @IBAction func btn_Continue_Action(_ sender: UIControl) {
        self.close_animation(true)
    }
    
    @IBAction func btn_Later_Action(_ sender: UIControl) {
        self.close_animation(false)
    }

}
