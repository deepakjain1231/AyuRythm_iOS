//
//  FaceNaadiDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 31/10/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

protocol delegateFaceNaadi {
    func subscribe_tryNow_click(_ success: Bool, type: ScreenType)
}


import UIKit

class FaceNaadiDialouge: UIViewController {

    var sreen_type = ScreenType.k_none
    var delegate: delegateFaceNaadi?
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var btn_TryNow: UIControl!
    @IBOutlet weak var lbl_TryNow: UILabel!
    @IBOutlet weak var img_Assessment: UIImageView!
    @IBOutlet weak var lbl_join_prime: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setup()
        self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }

    func setup() {
        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
            //REGISTERED USER
            let gender = (empData["gender"] as? String ?? "")
            if gender.lowercased() == "female" {
                self.img_Assessment.image = UIImage.init(named: "icon_female_face_assessment")
            }
            else {
                self.img_Assessment.image = UIImage.init(named: "icon_face_assessment")
            }
        }

        if UserDefaults.user.free_facenaadi_count == UserDefaults.user.facenaadi_assessment_trial ||
            UserDefaults.user.free_facenaadi_count < UserDefaults.user.facenaadi_assessment_trial {
            self.sreen_type = ScreenType.fromFaceNaadi
            self.lbl_TryNow.text = "Unlock FaceNaadi".localized()
            self.lbl_subtitle.text = "30 second pulse assessment via selfie video".localized()
            return
        }
        
        self.lbl_join_prime.text = "Join Prime Club".localized()
        self.sreen_type = ScreenType.from_facenaadi_free_trial
        self.lbl_TryNow.text = "Free Trial".localized()
        let str_subText = "30 second pulse assessment via selfie video. Enjoy your free trial.".localized()
        self.setupAttributeText(full_text: str_subText, lbl_text: self.lbl_subtitle)
    }
    
    func setupAttributeText(full_text: String, lbl_text: UILabel) {
        let newText = NSMutableAttributedString.init(string: full_text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.26 // Whatever line spacing you want in points
        //paragraphStyle.alignment = .center

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(12), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#666666"), range: NSRange.init(location: 0, length: newText.length))

        let textRange = NSString(string: full_text)
        let highlight_range = textRange.range(of: "Enjoy your free trial.".localized())
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontSemiBold(12), range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#424242"), range: highlight_range)
        lbl_text.attributedText = newText
    }
        
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Main.transform = .identity
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
            
            if action {
                self.delegate?.subscribe_tryNow_click(true, type: self.sreen_type)
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
        self.clkToClose(false)
    }
        
    @IBAction func btn_TryNow_Action(_ sender: UIButton) {
        self.clkToClose(true)
    }
       
    @IBAction func btn_Join_Prime_Action(_ sender: UIButton) {
        self.sreen_type = ScreenType.from_PrimeMember
        self.clkToClose(true)
    }

}
