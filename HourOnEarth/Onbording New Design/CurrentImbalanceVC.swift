//
//  CurrentImbalanceVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 01/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class CurrentImbalanceVC: UIViewController {

    var is_subscriptionPurchased_Finger = false
    var is_subscriptionPurchased_Facenadi = false
    var isBackButtonHide = true
    var is_DirectFaceNaadi = false
    var is_open_fingerAssessment = false
    var is_open_facenaadiAssessment = false
    var is_FingerAssessmentClicked = false
    
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_select_option_title: UILabel!
    @IBOutlet weak var lbl_bottom1Text: UILabel!
    @IBOutlet weak var lbl_bottom2Text: UILabel!
    @IBOutlet weak var lbl_seeHowItText: UILabel!
    @IBOutlet weak var btn_startAssessment: UILabel!
    
    @IBOutlet weak var btn_Back: UIButton!
    @IBOutlet weak var btn_Skip: UIButton!
    @IBOutlet weak var view_Assessment: UIView!
    @IBOutlet weak var lbl_AssessmentTitle: UILabel!
    @IBOutlet weak var img_Assessment: UIImageView!
    @IBOutlet weak var img_AssessmentTitle: UIImageView!
    @IBOutlet weak var constraint_Header_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_Assessment_Top: NSLayoutConstraint!
    
    
    //Pulse
    @IBOutlet weak var view_pulse_assessment_BG: UIView!
    @IBOutlet weak var view_Option_pulse_assessment_Title: UILabel!
    @IBOutlet weak var view_Option_pulse_assessment_SubTitle: UILabel!
    @IBOutlet weak var btn_Option_pulse_assessment: UIButton!
    @IBOutlet weak var btn_Option_pulse_assessment_Prime: UIButton!
    @IBOutlet weak var btn_Option_pulse_assessment_UnlockNow: UIButton!
    @IBOutlet weak var img_Option_pulse_assessment: UIImageView!
    @IBOutlet weak var constraint_pulse_Assessment_stack_Top: NSLayoutConstraint!
    @IBOutlet weak var constraint_pulse_arrow_Height: NSLayoutConstraint!
    
    //FaceNaadi
    @IBOutlet weak var view_facenaadi_assessment_BG: UIView!
    @IBOutlet weak var view_Option_facenaadi_assessment_Title: UILabel!
    @IBOutlet weak var view_Option_facenaadi_assessment_SubTitle: UILabel!
    @IBOutlet weak var btn_Option_facenaadi_assessment: UIButton!
    @IBOutlet weak var btn_Option_facenaadi_assessment_Prime: UIButton!
    @IBOutlet weak var btn_Option_facenaadi_assessment_UnlockNow: UIButton!
    @IBOutlet weak var img_Option_facenaadi_assessment: UIImageView!
    @IBOutlet weak var constraint_facenaadi_Assessment_stack_Top: NSLayoutConstraint!
    @IBOutlet weak var constraint_facenaadi_arrow_Height: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setuplocalizationText()
        self.view_Assessment.isHidden = true
        self.btn_Option_pulse_assessment.isHidden = true
        self.btn_Option_facenaadi_assessment.isHidden = true
        self.btn_Back.isHidden = self.isBackButtonHide
        self.btn_Skip.isHidden = self.isBackButtonHide ? false : true
        self.constraint_Header_Height.constant = self.isBackButtonHide ? 30 : 50
        self.lbl_select_option_title.text = "Select any one of the option".localized()
        self.view_Option_pulse_assessment_Title.text = "Pulse assessment by placing finger on camera".localized()
        self.btn_Option_pulse_assessment_Prime.setTitle("Join Prime Club".localized(), for: .normal)
        self.btn_Option_facenaadi_assessment_Prime.setTitle("Join Prime Club".localized(), for: .normal)
        self.setupAttributeText(full_text: "30 second pulse assessment via placing your finger on camera".localized(), lbl_text: self.view_Option_pulse_assessment_SubTitle)
        self.setupAttributeText(full_text: "30 second pulse assessment via selfie video".localized(), lbl_text: self.view_Option_facenaadi_assessment_SubTitle)
        
        
        
        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
            //REGISTERED USER
            let gender = (empData["gender"] as? String ?? "")
            if gender == "Female" {
                self.img_Assessment.image = UIImage.init(named: "icon_female_face_assessment")
                self.img_AssessmentTitle.image = UIImage.init(named: "icon_female_face_assessment")
            }
            else {
                self.img_Assessment.image = UIImage.init(named: "icon_face_assessment_male")
                self.img_AssessmentTitle.image = UIImage.init(named: "icon_face_assessment_male")
            }
        }

        if self.is_DirectFaceNaadi {
            self.openFaceNaadiAssessment()
        }
        
        self.checkFinger_Accessment()
        self.checkFaceNaadi_Accessment()
    }
    
    func checkFinger_Accessment() {
        if UserDefaults.user.is_main_subscription {
            self.is_open_fingerAssessment = true
            self.img_Option_pulse_assessment.isHidden = false
            self.btn_Option_pulse_assessment.isHidden = false
            self.btn_Option_pulse_assessment_Prime.isHidden = true
            self.btn_Option_pulse_assessment_UnlockNow.isHidden = true
            self.constraint_pulse_Assessment_stack_Top.constant = 0
        }
        else {
            if UserDefaults.user.is_finger_subscribed {
                self.is_open_fingerAssessment = true
                self.btn_Option_pulse_assessment.isHidden = false
                self.img_Option_pulse_assessment.isHidden = false
                self.btn_Option_pulse_assessment_UnlockNow.isHidden = false
                self.setupAttributeText(full_text: "30 second pulse assessment via placing your finger on camera".localized(), lbl_text: self.view_Option_pulse_assessment_SubTitle)
                self.btn_Option_pulse_assessment_UnlockNow.setTitle("Test Now", for: .normal)
                
            }
            else {
                if UserDefaults.user.free_finger_count == UserDefaults.user.finger_assessment_trial || UserDefaults.user.free_finger_count < UserDefaults.user.finger_assessment_trial {
                    self.is_open_fingerAssessment = false
                    self.constraint_pulse_arrow_Height.constant = 0
                    self.btn_Option_pulse_assessment.isHidden = true
                    self.img_Option_pulse_assessment.isHidden = true
                    self.setupAttributeText(full_text: "30 second pulse assessment via placing your finger on camera".localized(), lbl_text: self.view_Option_pulse_assessment_SubTitle)
                    self.btn_Option_pulse_assessment_UnlockNow.setTitle("Unlock Sparshna".localized(), for: .normal)
                    return
                }
                
                self.is_open_fingerAssessment = true
                self.constraint_pulse_arrow_Height.constant = 0
                self.btn_Option_pulse_assessment.isHidden = true
                self.img_Option_pulse_assessment.isHidden = true
                self.setupAttributeText(full_text: "30 second pulse assessment test via placing your finger on camera enjoy your initial free trial", lbl_text: self.view_Option_pulse_assessment_SubTitle)
                self.btn_Option_pulse_assessment_UnlockNow.setTitle("Free Trial".localized(), for: .normal)
            }
        }
    }
    
    func checkFaceNaadi_Accessment() {
        if UserDefaults.user.is_main_subscription {
            self.is_open_facenaadiAssessment = true
            self.img_Option_facenaadi_assessment.isHidden = false
            self.btn_Option_facenaadi_assessment.isHidden = false
            self.btn_Option_facenaadi_assessment_Prime.isHidden = true
            self.btn_Option_facenaadi_assessment_UnlockNow.isHidden = true
            self.constraint_facenaadi_Assessment_stack_Top.constant = 0
        }
        else {
            if UserDefaults.user.is_facenaadi_subscribed {
                self.is_open_facenaadiAssessment = true
                self.btn_Option_facenaadi_assessment.isHidden = false
                self.img_Option_facenaadi_assessment.isHidden = false
                self.btn_Option_facenaadi_assessment_UnlockNow.isHidden = false
                self.setupAttributeText(full_text: "30 second pulse assessment via selfie video".localized(), lbl_text: self.view_Option_facenaadi_assessment_SubTitle)
                self.btn_Option_facenaadi_assessment_UnlockNow.setTitle("Test Now", for: .normal)
            }
            else {
                if UserDefaults.user.free_facenaadi_count == UserDefaults.user.facenaadi_assessment_trial || UserDefaults.user.free_facenaadi_count < UserDefaults.user.facenaadi_assessment_trial {
                    self.is_open_facenaadiAssessment = false
                    self.btn_Option_facenaadi_assessment.isHidden = true
                    self.img_Option_facenaadi_assessment.isHidden = true
                    self.constraint_facenaadi_arrow_Height.constant = 0
                    self.setupAttributeText(full_text: "30 second pulse assessment via selfie video".localized(), lbl_text: self.view_Option_facenaadi_assessment_SubTitle)
                    self.btn_Option_facenaadi_assessment_UnlockNow.setTitle("Unlock FaceNaadi".localized(), for: .normal)
                    return
                }
                
                self.is_open_facenaadiAssessment = true
                self.constraint_facenaadi_arrow_Height.constant = 0
                self.btn_Option_facenaadi_assessment.isHidden = true
                self.img_Option_facenaadi_assessment.isHidden = true
                self.setupAttributeText(full_text: "30 second pulse assessment via selfie video. Enjoy your free trial.".localized(), lbl_text: self.view_Option_facenaadi_assessment_SubTitle)
                self.btn_Option_facenaadi_assessment_UnlockNow.setTitle("Free Trial".localized(), for: .normal)
            }
        }
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
    
    func setuplocalizationText() {
        self.btn_Skip.setTitle("SKIP".localized().capitalized, for: .normal)
        self.lbl_Title.text = "Pulse assessment\nfor current balance".localized()
        self.lbl_bottom1Text.text = "Ensure you are in a\nbrightly lit area.".localized()
        self.lbl_bottom2Text.text = "Screen brightness will\nincrease during the test.".localized()
        self.lbl_seeHowItText.text = "see_how_it_works".localized()
        self.btn_startAssessment.text = "start_the_assessment".localized()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.tabBarController?.tabBar.isHidden = true
        self.checkFinger_Accessment()
        self.checkFaceNaadi_Accessment()
        if self.is_subscriptionPurchased_Finger {
            self.clickedFingerAssessment()
        }
        if self.is_subscriptionPurchased_Facenadi {
            self.openFaceNaadiAssessment()
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
    
    // MARK: - UIButton Action
    
    @IBAction func btn_Back_Action(_ sender: UIControl) {
        var is_back = false
        if let stackVCs = self.navigationController?.viewControllers {
            if let activeSubVC = stackVCs.first(where: { type(of: $0) == MyHomeViewController.self }) {
                is_back = true
                self.navigationController?.popToViewController(activeSubVC, animated: false)
            }
        }
        
        if is_back == false {
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    @IBAction func btn_howItWorks_Action(_ sender: UIControl) {
        debugPrint("See How It Works clicked")
    }
    @IBAction func btn_skip_Action(_ sender: UIControl) {
        debugPrint("Button Skip clicked")
        kSharedAppDelegate.showHomeScreen()
    }
    
    @IBAction func btn_FingerAssessment_Action(_ sender: UIControl) {
        if self.is_open_fingerAssessment {
            self.clickedFingerAssessment()
        }
        else {
            let obj = FaceNaadiSubscriptionListVC.instantiate(fromAppStoryboard: .FaceNaadi)
            obj.str_screenFrom = .from_finger_assessment
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    @IBAction func btn_FaceAssessment_Action(_ sender: UIControl) {
        if self.is_open_facenaadiAssessment {
            self.openFaceNaadiAssessment()
        }
        else {
            let obj = FaceNaadiSubscriptionListVC.instantiate(fromAppStoryboard: .FaceNaadi)
            obj.str_screenFrom = .fromFaceNaadi
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    func clickedFingerAssessment() {
        self.is_FingerAssessmentClicked = true
        self.img_AssessmentTitle.image = UIImage.gifImageWithName("sparshna")
        self.lbl_AssessmentTitle.text = "Start by placing your finger on the back camera for 30 seconds.".localized()
        UIView.animate(withDuration: 0.3) {
            self.view_Assessment.isHidden = false
        }
    }
    
    func openFaceNaadiAssessment() {
        self.is_FingerAssessmentClicked = false
        self.lbl_AssessmentTitle.text = "Start by taking selfie video for 30 seconds of your face"
        UIView.animate(withDuration: 0.3) {
            self.view_Assessment.isHidden = false
        }
    }
    
    @IBAction func btn_StartAssessment_Action(_ sender: UIControl) {
        debugPrint("Start assessment clicked")
        if self.is_FingerAssessmentClicked {
            SparshnaAlert.showSparshnaTestScreen(isBackBtnVisible: true, fromVC: self)
        }
        else {
            let obj = FaceNaadiCameraVC.instantiate(fromAppStoryboard: .FaceNaadi)
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    @IBAction func btn_JoinPrime_Action(_ sender: UIControl) {
        let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CurrentImbalanceVC {
    
    func callAPIforCheckFacenaadiCouponValid(completion: @escaping (Bool, String?)->Void ) {
        self.showActivityIndicator()
        let params = ["coupon_code": appDelegate.facenaadi_doctor_coupon_code] as [String : Any]
        doAPICall(endPoint: .checkFaceNaadiSubscriptionPromocode, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            var str_validity_msg = ""
            if isSuccess {
                if let dic_res = responseJSON?["response"].dictionary {
                    str_validity_msg = dic_res["validity_message"]?.stringValue ?? ""
                }
                self?.hideActivityIndicator()
                completion(isSuccess, str_validity_msg)
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
                completion(isSuccess, "")
            }
        }
    }
}
