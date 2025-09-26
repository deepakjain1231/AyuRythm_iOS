//
//  ARAyuVerseRulesVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 05/08/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

protocol delegateRulesAccepted {
    func rulesAcceptedAndContinue(_ success: Bool)
}

class ARAyuVerseRulesVC: UIViewController {

    var str_Rules = ""
    var delegate: delegateRulesAccepted?
    @IBOutlet weak var btn_Close: UIButton!
    @IBOutlet weak var view_MainBG: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_ButtonTitle: UILabel!
    @IBOutlet weak var lbl_Rules: UILabel!
    @IBOutlet weak var btn_AcceptContinue: UIControl!
    @IBOutlet weak var constraint_btnAccept_bottom: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_bottom: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setTitle_Message()
        self.constraint_view_bottom.constant = -UIScreen.main.bounds.height
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func setTitle_Message() {
        self.lbl_Title.text = "Rules".localized()
        self.lbl_ButtonTitle.text = "Accept & Continue".localized()
        
        let truncated = self.str_Rules.substring(to: self.str_Rules.index(before: self.str_Rules.endIndex))
        self.str_Rules = truncated
        
        
        let strtext = self.str_Rules.localized()
        let newText = NSMutableAttributedString.init(string: strtext)
        
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange.init(location: 0, length: newText.length))

        let textRange = NSString(string: strtext)
        let highlight_range1 = textRange.range(of: "1.")
        let highlight_range2 = textRange.range(of: "2.")
        let highlight_range3 = textRange.range(of: "3.")
        let highlight_range4 = textRange.range(of: "4.")
        let highlight_range5 = textRange.range(of: "5.")
        let highlight_range6 = textRange.range(of: "6.")
        let highlight_range7 = textRange.range(of: "7.")
        let highlight_range8 = textRange.range(of: "8.")
        let highlight_range9 = textRange.range(of: "9.")
        let highlight_range10 = textRange.range(of: "10.")
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: highlight_range1)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: highlight_range2)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: highlight_range3)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: highlight_range4)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: highlight_range5)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: highlight_range6)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: highlight_range7)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: highlight_range8)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: highlight_range9)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: highlight_range10)
        self.lbl_Rules.attributedText = newText
        
        
        let bottomSafeArea = (kSharedAppDelegate.window?.safeAreaInsets.bottom ?? 0) + 20
        self.constraint_btnAccept_bottom.constant = bottomSafeArea
        self.view_MainBG.roundCorners(corners: [UIRectCorner.topLeft, .topRight], radius: 22)
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_bottom.constant = 0
            self.view_MainBG.roundCorners(corners: [UIRectCorner.topLeft, .topRight], radius: 22)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.view_MainBG.roundCorners(corners: [UIRectCorner.topLeft, .topRight], radius: 22)
        }
    }
    
    
    func clkToClose(_ is_Action: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_bottom.constant = -UIScreen.main.bounds.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if is_Action {
                self.delegate?.rulesAcceptedAndContinue(true)
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
    
    // MARK: - API Call Action
    @IBAction func btnSubmit_Action(_ sender: UIControl) {
        self.clkToClose(true)
    }
    
    @IBAction func btnClose_Action(_ sender: UIButton) {
        self.clkToClose(false)
    }
}


