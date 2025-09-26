//
//  HomeScreenNoSparshnaTableCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 02/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class HomeScreenNoSparshnaTableCell: UITableViewCell {

    @IBOutlet weak var lbl_Text1: UILabel!
    @IBOutlet weak var lbl_Text2: UILabel!
    @IBOutlet weak var lbl_Text3: UILabel!
    @IBOutlet weak var img_iCon: UIImageView!
    @IBOutlet weak var btn_TryNow: UIControl!
    @IBOutlet weak var lbl_TryNow: UILabel!
    @IBOutlet weak var constraint_btn_TryNow_Top: NSLayoutConstraint!
    @IBOutlet weak var constraint_btn_TryNow_Height: NSLayoutConstraint!
    
    var didTappedonTryNow: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbl_TryNow.text = "Try Now".localized()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupForPluseAssessment(is_sparshna: Bool, is_parshna: Bool, prakriti_result: Bool = false) {
        self.lbl_Text2.text = "Current Balance".localized()
        self.lbl_Text1.text = "Pulse assessment".localized()
        self.lbl_Text3.text = "Complete 30 second pulse assessment to get your current state.".localized()
        self.lbl_Text2.textColor = UIColor.fromHex(hexString: "#A949AE")
        self.btn_TryNow.backgroundColor = AppColor.app_DarkGreenColor
        self.lbl_TryNow.textColor = UIColor.white
        self.img_iCon.image = UIImage.init(named: "icon_pluse_assessment")
        
        if is_sparshna {
            self.btn_TryNow.isHidden = true
            self.constraint_btn_TryNow_Top.constant = 0
            self.constraint_btn_TryNow_Height.constant = 0
            self.lbl_Text3.text = "Complete Questionnaire to compare result".localized()
            self.img_iCon.image = UIImage.init(named: "pluse_assessment_done")
        }
        else {
            self.btn_TryNow.isHidden = false
            self.constraint_btn_TryNow_Top.constant = 16
            self.constraint_btn_TryNow_Height.constant = 45
        }
        
        if prakriti_result {
            self.lbl_Text3.text = "You are 1 step away from unlocking personalized results 🔥".localized()
        }
    }
    
    func setupForQuestionnaires(is_sparshna: Bool, is_parshna: Bool, prakriti_result: Bool = false) {
        self.lbl_Text2.text = "Ideal Balance".localized()
        self.lbl_Text1.text = "Questionnaire".localized()
        self.lbl_Text3.text = "Complete 30 questions to get personalized results.".localized()
        self.lbl_Text2.textColor = UIColor.fromHex(hexString: "#EB711F")
        self.btn_TryNow.backgroundColor = UIColor.clear
        self.lbl_TryNow.textColor = AppColor.app_DarkGreenColor
        self.img_iCon.image = UIImage.init(named: "icon_questionnaires")
        self.constraint_btn_TryNow_Top.constant = 16
        self.constraint_btn_TryNow_Height.constant = 45
        
        if is_sparshna && !is_parshna {
            self.btn_TryNow.isHidden = false
            self.lbl_TryNow.textColor = UIColor.white
            self.btn_TryNow.backgroundColor = AppColor.app_DarkGreenColor
        }
        else if is_parshna {
            self.btn_TryNow.isHidden = true
            self.constraint_btn_TryNow_Top.constant = 0
            self.constraint_btn_TryNow_Height.constant = 0
            self.lbl_Text3.text = "Complete assessment to compare result".localized()
            self.img_iCon.image = UIImage.init(named: "question_done")
        }
        
        if prakriti_result {
            self.lbl_Text3.text = "You are 1 step away from unlocking personalized results 🔥".localized()
        }

    }
    
    func setupForQuestionnairesVikrati() {
        self.lbl_Text2.text = "Current Balance".localized()
        self.lbl_Text1.text = "Questionnaire".localized()
        self.lbl_Text3.text = "Complete 21 questions to get personalized results.".localized()
        self.lbl_Text2.textColor = UIColor.fromHex(hexString: "#EB711F")
        self.btn_TryNow.backgroundColor = UIColor.clear
        self.lbl_TryNow.textColor = AppColor.app_DarkGreenColor
        self.img_iCon.image = UIImage.init(named: "icon_questionnaire_vikruti")
        self.constraint_btn_TryNow_Top.constant = 16
        self.constraint_btn_TryNow_Height.constant = 45
        self.btn_TryNow.isHidden = false
    }
    
    
    @IBAction func btn_TryNowAction(_ sender: UIControl) {
        if self.didTappedonTryNow != nil {
            self.didTappedonTryNow!(sender)
        }
    }
}
