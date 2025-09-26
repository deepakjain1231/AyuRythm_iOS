//
//  ReferEarnVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 21/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class ReferEarnVC: UIViewController {

    @IBOutlet weak var lbl_title: UILabel!
    
    @IBOutlet weak var lbl_ReferralCode: UILabel!
    @IBOutlet weak var lbl_ReferralBottomText: UILabel!
    @IBOutlet weak var lbl_Referraltitle: UILabel!
    @IBOutlet weak var lbl_ReferralSubtitle: UILabel!
    @IBOutlet weak var lbl_btn_ReferNow: UILabel!
    @IBOutlet weak var btn_ReferNow: UIControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_title.text = "Refer & Earn".localized()
        self.lbl_btn_ReferNow.text = "Refer Now".localized()
        self.lbl_ReferralBottomText.text = "Tap to copy the code".localized()
        self.lbl_Referraltitle.text = String(format: "Earn %@ AyuSeeds".localized(), kUserDefaults.referralPointValue)
        self.lbl_ReferralSubtitle.text = String(format: "Invite your friends to AyuRythm and earn %@ AyuSeeds each, when they sign up using your code!", kUserDefaults.referralPointValue)
        
        
        if let referralCode = kUserDefaults.string(forKey: kUserReferralCode) {
            self.lbl_ReferralCode.text = referralCode
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

    //MARK: - UIButton Method
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCopyReferralCodeClicked(_ sender: UIButton) {
        if let code = self.lbl_ReferralCode.text, !code.isEmpty {
            UIPasteboard.general.string = code
            Utils.showAlertWithTitleInControllerWithCompletion("", message: "Referral Code copied successfully".localized(), okTitle: "Ok".localized(), controller: self) { [weak self] in
            }
        }
    }
    

    
    @IBAction func btn_ReferNw_Action(_ sender: UIControl) {
        let shareAll = [ Utils.shareRegisterDownloadString ] as [Any]

        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
