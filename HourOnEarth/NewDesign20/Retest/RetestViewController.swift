//
//  RetestViewController.swift
//  HourOnEarth
//
//  Created by Apple on 28/01/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class RetestViewController: BaseViewController {

    @IBOutlet weak var lbl_title: UILabel!
    
    @IBOutlet weak var lbl_HeaderTitle1: UILabel!
    @IBOutlet weak var lbl_HeaderTitle2: UILabel!
    
    @IBOutlet weak var lbl_prakriti_subtitle: UILabel!
    @IBOutlet weak var lbl_prakriti_lastText: UILabel!
    @IBOutlet weak var lbl_prashna_text_1: UILabel!
    @IBOutlet weak var lbl_prashna_text_2: UILabel!
    @IBOutlet weak var lbl_prashna_text_3: UILabel!
    @IBOutlet weak var lbl_sprashna_text_1: UILabel!
    @IBOutlet weak var lbl_sprashna_text_2: UILabel!
    @IBOutlet weak var lbl_sprashna_text_3: UILabel!
    
    
    
    @IBOutlet weak var btn_Prashna: UIButton!
    @IBOutlet weak var btn_Vikrati_Prashna: UIButton!
    @IBOutlet weak var btn_Sprashna: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_title.text = "Wellness Assessment".localized()
        self.lbl_HeaderTitle1.text = "Prakriti | The Ideal Me".localized()
        self.lbl_HeaderTitle2.text = "VIKRITI | The Current Me".localized()
        self.lbl_prakriti_subtitle.text = "Prakriti / The Ideal Me".localized()
        self.lbl_prakriti_lastText.text = "Complete 30 questions to get personalized results.".localized()
        self.lbl_prashna_text_1.text = "PRASHNA".localized().capitalized
        self.lbl_prashna_text_2.text = "Vikriti / The Current Me".localized()
        self.lbl_prashna_text_3.text = "Complete 21 questions to get personalized results.".localized()
        self.lbl_sprashna_text_1.text = "Sparshna".localized()
        self.lbl_sprashna_text_2.text = "Naadi pariksha".localized()
        self.lbl_sprashna_text_3.text = "30_second_pulse_assessment_to_get_personalized_results".localized()
        
        self.btn_Prashna.setTitle("Begin here".localized(), for: .normal)
        self.btn_Sprashna.setTitle("Begin here".localized(), for: .normal)
        self.btn_Vikrati_Prashna.setTitle("Begin here".localized(), for: .normal)
        self.btn_Prashna.setTitleColor(.white, for: .normal)
        self.btn_Sprashna.setTitleColor(.white, for: .normal)
        self.btn_Vikrati_Prashna.setTitleColor(.white, for: .normal)
        self.btn_Prashna.backgroundColor = AppColor.app_DarkGreenColor
        self.btn_Sprashna.backgroundColor = AppColor.app_DarkGreenColor
        self.btn_Vikrati_Prashna.backgroundColor = AppColor.app_DarkGreenColor
        
        if let prashnaResult = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String, !prashnaResult.isEmpty {
            //self.imgPrashna.isHidden = false
            self.btn_Prashna.setTitleColor(AppColor.app_DarkGreenColor, for: .normal)
            self.btn_Prashna.setTitle("Test again".localized(), for: .normal)
            self.btn_Prashna.backgroundColor = .white
        }
        
        let isSparshnaTestGiven = kUserDefaults.bool(forKey: kVikritiSparshanaCompleted)
        let isPrashnaTestGiven = kUserDefaults.bool(forKey: kVikritiPrashnaCompleted)
        if isPrashnaTestGiven {
            self.btn_Vikrati_Prashna.setTitleColor(AppColor.app_DarkGreenColor, for: .normal)
            self.btn_Vikrati_Prashna.setTitle("Test again".localized(), for: .normal)
            self.btn_Vikrati_Prashna.backgroundColor = .white
        }
        
        if isSparshnaTestGiven {
            self.btn_Sprashna.setTitleColor(AppColor.app_DarkGreenColor, for: .normal)
            self.btn_Sprashna.setTitle("Test again".localized(), for: .normal)
            self.btn_Sprashna.backgroundColor = .white
        }
    }
    
    @IBAction func prakritiClicked(_ sender: UIButton) {
        //startPrakritiTestFlow()
        //New Design
        let objBalVC = Story_Assessment.instantiateViewController(withIdentifier: "IdealBalanceQuestionnaireVC") as! IdealBalanceQuestionnaireVC
        self.navigationController?.pushViewController(objBalVC, animated: true)
        
//        let vc = PrakritiResult1VC.instantiate(fromAppStoryboard: .Questionnaire)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func prashnaClicked(_ sender: UIButton) {
        Vikrati30QuestionnaireVC.showScreen(fromVC: self)
        //VikritiQuestionsVC.showScreen(fromVC: self)
    }

    @IBAction func sparshnaClicked(_ sender: UIButton) {
        let objBalVC = Story_LoginSignup.instantiateViewController(withIdentifier: "CurrentImbalanceVC") as! CurrentImbalanceVC
        objBalVC.hidesBottomBarWhenPushed = true
        objBalVC.isBackButtonHide = false
        self.navigationController?.pushViewController(objBalVC, animated: true)
        
        /*
        //SPARSHNA
        if kUserDefaults.bool(forKey: kDoNotShowTestInfo) {
            let objSlideView = CameraViewController.instantiate(fromAppStoryboard: .Camera)
            self.navigationController?.pushViewController(objSlideView, animated: true)
            
            /*
            let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
            let objAlert = storyBoard.instantiateViewController(withIdentifier: "SparshnaAlert") as! SparshnaAlert
            objAlert.modalPresentationStyle = .overCurrentContext
            objAlert.completionHandler = {
                let objSlideView = CameraViewController.instantiate(fromAppStoryboard: .Camera)
                self.navigationController?.pushViewController(objSlideView, animated: true)
            }
            self.present(objAlert, animated: true)
            */
        } else {
            let storyBoard = UIStoryboard(name: "SparshnaTestInfo", bundle: nil)
            let objSlideView: SparshnaTestInfoViewController = storyBoard.instantiateViewController(withIdentifier: "SparshnaTestInfoViewController") as! SparshnaTestInfoViewController
            self.navigationController?.pushViewController(objSlideView, animated: true)
        }
        */
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
