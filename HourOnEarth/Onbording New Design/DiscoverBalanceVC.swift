//
//  DiscoverBalanceVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 01/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class DiscoverBalanceVC: UIViewController {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_balText1: UILabel!
    @IBOutlet weak var lbl_balText2: UILabel!
    @IBOutlet weak var lbl_balText3: UILabel!
    @IBOutlet weak var lbl_bottomText: UILabel!
    @IBOutlet weak var lbl_knowMore: UILabel!
    @IBOutlet weak var lbl_btnText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_title.text = "Discover your unique body\nbalance!".localized()
        self.lbl_balText1.text = "Current\nBalance".localized()
        self.lbl_balText2.text = "Ideal\nBalance".localized()
        self.lbl_balText3.text = "Body\nImbalance".localized()
        self.lbl_bottomText.text = "ayurythm_helps_you_find_your_unique_body_balance_and_stay_healthy".localized()
        self.lbl_knowMore.text = "KNOW MORE".localized().capitalized
        self.lbl_btnText.text = "Discover current balance".localized()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btn_knowMore(_ sender: UIControl) {
        debugPrint("Button Know more clicked")
        if let youtubeURL = URL(string: kPromotionalYoutubeLink), UIApplication.shared.canOpenURL(youtubeURL) {
            // redirect to app
            UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
        } else if let youtubeURL = URL(string: kPromotionalYoutubeLink) {
            // redirect through safari
            UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func btn_DiscoverImbalance(_ sender: UIControl) {
        let objBalVC = Story_LoginSignup.instantiateViewController(withIdentifier: "CurrentImbalanceVC") as! CurrentImbalanceVC
        self.navigationController?.pushViewController(objBalVC, animated: true)
    }
}
