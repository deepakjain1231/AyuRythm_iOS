//
//  PrakritiViewController.swift
//  HourOnEarth
//
//  Created by hardik mulani on 23/01/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class PrakritiViewController: UIViewController {

    @IBOutlet weak var textview: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let attributedString = NSMutableAttributedString(string: "1. All questions must be answered\n\n2. It can be fun to do the questionnaire alongside someone who knows you well\n\n3. Important: We are establishing your core nature so please consider how you were as a child, as well as now\n\n4. If you have difficulty deciding, choose the answer that best represents how you have been for the majority of your life\n\n5. The choices given are relative with the characteristics of the places you have lived\n\n6. You can pause and come back anytime".localized(), attributes: [
          .font: UIFont.systemFont(ofSize: 13.0, weight: .regular),
          .foregroundColor: UIColor.black,
          .kern: -0.08
        ])
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0, weight: .bold), range: Utils.isAppInHindiLanguage ? NSRange(location: 182, length: 13) : NSRange(location: 117, length: 10))
        
        textview.attributedText = attributedString
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func startBtnClicked(_ sender: Any) {
        PrakritiQuestionsNewVC.showScreen(isFromOnBoarding: true, fromVC: self)
    }
}
