//
//  IdealBalanceQuestionnaireVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 02/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class IdealBalanceQuestionnaireVC: BaseViewController {

    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_QuestionnaireText1: UILabel!
    @IBOutlet weak var lbl_QuestionnaireText2: UILabel!
    @IBOutlet weak var lbl_QuestionnaireText3: UILabel!
    @IBOutlet weak var lbl_BtnText: UILabel!
    @IBOutlet weak var lbl_select_option_title: UILabel!
    
    @IBOutlet weak var btn_Back: UIButton!
    @IBOutlet weak var btn_Skip: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_Title.text = "Let's check your ideal\nbalance".localized()
        self.btn_Skip.setTitle("SKIP".localized().capitalized, for: .normal)
        self.lbl_QuestionnaireText1.text = "ideal_balance_text_1".localized()
        self.lbl_QuestionnaireText2.text = "ideal_balance_text_2".localized()
        self.lbl_QuestionnaireText3.text = "ideal_balance_text_3".localized()
        self.lbl_BtnText.text = "Start assessment".localized()
        self.lbl_select_option_title.text = "Select any one of the option".localized()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UIButton Action
    
    @IBAction func btn_Back_Action(_ sender: UIControl) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btn_skip_Action(_ sender: UIControl) {
        debugPrint("Button Skip clicked")
        kSharedAppDelegate.showHomeScreen()
    }
    
    @IBAction func btn_StartAssessment_Action(_ sender: UIControl) {
        debugPrint("Start assessment clicked")
        PrakritiQuestionIntroVC.showScreen(isFromOnBoarding: true, fromVC: self)
//        Prakriti30QuestionnaireVC.showScreen(isFromOnBoarding: true, fromVC: self)
//        VikritiQuestionsVC.showScreen(fromVC: self)
    }
}
