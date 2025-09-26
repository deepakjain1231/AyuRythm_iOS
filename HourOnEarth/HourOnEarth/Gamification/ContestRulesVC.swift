//
//  ContestRulesVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 21/03/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ContestRulesVC: UIViewController {
    
    @IBOutlet weak var rulesTV: UITextView!
    
    var rules = ["Enter the contest.".localized(),
                 "Answer all the questions.".localized(),
                 "Earn points for each correct answer.".localized(),
                 "No points deducted for wrong answers.".localized(),
                 "Win exciting rewards.".localized(),
                 "You can enter this contest multiple times.".localized(),
                 "Answer all questions correctly to be eligible for the lucky draw.".localized(),
                 "Houronearth Creative Solutions Pvt. Ltd. explicitly attests that Apple is in no way involved as a sponsor of the competition and/or in its organization.".localized()]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Rules".localized()
        setBackButtonTitle()
        setupUI()
    }
    
    func setupUI() {
        rulesTV.attributedText = NSAttributedString.bulletListedAttributedString(stringList: rules, font: rulesTV.font!, bullet: "•", indentation: 16, lineSpacing: 6, paragraphSpacing: 12, textColor: .black, bulletColor: .black)
    }
}
