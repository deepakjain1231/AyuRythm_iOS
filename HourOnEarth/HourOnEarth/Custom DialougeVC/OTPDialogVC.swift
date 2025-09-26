//
//  OTPDialogVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 10/03/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

protocol delegate_otpVeried {
    func otp_verified_continue(_ success: Bool)
}


import UIKit
import SVPinView
import Alamofire
import FirebaseAuth

class OTPDialogVC: UIViewController {

    var timer = Timer()
    var remainingSeconds = 59
    var strMobileNo = ""
    var strCountryCode = ""
    var str_enteredOTP = ""
    var verificationID = ""
    var is_NewUser = false
    var isButtonEnable = false
    var screen_from = ScreenType.k_none
    var delegate: delegate_otpVeried?
    var super_vc = UIViewController()
    @IBOutlet weak var pinView: SVPinView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lbl_topText: UILabel!
    @IBOutlet weak var lbl_bottomText: UILabel!
    @IBOutlet weak var btn_Next: UIControl!
    @IBOutlet weak var lbl_buttonText: UILabel!
    @IBOutlet weak var btn_Resend: UIButton!
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var constraint_viewMain_Bottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUpLabel()
        self.configurePinView()
        self.setTimer()
        
        self.constraint_viewMain_Bottom.constant = -UIScreen.main.bounds.size.height
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func configurePinView() {
        self.pinView.style = .box
        self.pinView.pinLength = 6
        self.pinView.textColor = UIColor.black
        //self.pinView.interSpace = 5
        self.pinView.placeholder = ""
        self.pinView.fieldCornerRadius = 8
        self.pinView.activeFieldCornerRadius = 8
        self.pinView.borderLineThickness = 1
        self.pinView.keyboardType = .phonePad
        self.pinView.shouldSecureText = false
        self.pinView.allowsWhitespaces = false
        self.pinView.secureCharacter = "\u{25CF}"
        self.pinView.activeBorderLineThickness = 1
        self.pinView.isContentTypeOneTimeCode = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.pinView.becomeFirstResponderAtIndex = 0
        }
        self.pinView.font = UIFont.init(name: "Inter-Medium", size: 18)!
        self.pinView.borderLineColor = UIColor.fromHex(hexString: "#AAAAAA")
        self.pinView.activeBorderLineColor = UIColor.fromHex(hexString: "#AAAAAA")
        self.pinView.fieldBackgroundColor = .clear
        self.pinView.activeFieldBackgroundColor = .clear
        
        self.pinView.pinInputAccessoryView = { () -> UIView in
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            doneToolbar.barStyle = UIBarStyle.default
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(dismissKeyboard))
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)
            
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            return doneToolbar
        }()
        
        self.pinView.didFinishCallback = didFinishEnteringPin(pin:)
        self.pinView.didChangeCallback = { pin in
            self.str_enteredOTP = pin
            if pin.count >= 6 {
                self.isButtonEnable = true
                self.btn_Next.backgroundColor = AppColor.app_DarkGreenColor
            }
            else {
                self.isButtonEnable = false
                self.btn_Next.backgroundColor = UIColor.fromHex(hexString: "#777777")
            }
        }
    }
    
    @objc func dismissKeyboard() {
            self.view.endEditing(false)
        }

    func didFinishEnteringPin(pin:String) {
        self.str_enteredOTP = pin
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewMain_Bottom.constant = 0
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose(_ action: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.timer.invalidate()
            self.constraint_viewMain_Bottom.constant = -UIScreen.main.bounds.size.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if action {
                if self.screen_from == .from_ediProfile {
                    self.delegate?.otp_verified_continue(true)
                }
            }
        }
    }
    
    func setTimer() {
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        print("Remaining Second:========\(self.remainingSeconds)")
        self.lbl_bottomText.text = self.timeFormatted(self.remainingSeconds) // will show timer
        if self.remainingSeconds != 0 {
            self.remainingSeconds -= 1  // decrease counter timer
        } else {
            self.timer.invalidate()
            self.setupBotttomText()
            self.btn_Resend.isHidden = false
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let str_didnReceive = "didnt_receive_code".localized()
        let str_resendIn = "Resend in".localized()
        let str_sec = "second_short".localized()
        return String(format: "\(str_didnReceive) \(str_resendIn) %02d \(str_sec)", seconds)
    }
    
    func setupBotttomText() {
        let str_resend_code = "resend_code".localized()
        let str_didnReceive = "didnt_receive_code".localized()
        let str_resend = "\(str_didnReceive) \(str_resend_code)"
        let newText = NSMutableAttributedString.init(string: str_resend)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(15), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColor.app_TextGrayColor, range: NSRange.init(location: 0, length: newText.length))
        let textRange = NSString(string: str_resend)
        
        let termrange = textRange.range(of: str_resend_code)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(15), range: termrange)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColor.app_TextBlueColor, range: termrange)
        self.lbl_bottomText.attributedText = newText
    }
    
        
    func setUpLabel() {
        self.lblTitle.text = "Verify OTP".localized()
        self.lbl_buttonText.text = "verify_OTP".localized()
        
        
        var str_enter_Number = "Please enter the OTP sent to".localized() + " \(self.strCountryCode)\(self.strMobileNo)  " + "Edit".localized()
        if Utils.getLanguageId() == 2 {
            str_enter_Number =  "\(self.strCountryCode)\(self.strMobileNo)  " + "Please enter the OTP sent to".localized() + " " + "Edit".localized()
        }
        
        let newText = NSMutableAttributedString.init(string: str_enter_Number)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(15), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColor.app_TextGrayColor, range: NSRange.init(location: 0, length: newText.length))
        let textRange = NSString(string: str_enter_Number)
        
        let termrange = textRange.range(of: "Edit".localized())
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(15), range: termrange)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColor.app_TextBlueColor, range: termrange)
        
        
        let mobilerange = textRange.range(of: self.strMobileNo)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontBold(15), range: mobilerange)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColor.app_TextGrayColor, range: mobilerange)

        self.lbl_topText.attributedText = newText
        
        
        self.lbl_topText.isUserInteractionEnabled = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        self.lbl_topText.addGestureRecognizer(tapgesture)
    }

    //MARK:- tappedOnLabel
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = self.lbl_topText.text else { return }
        let register_Range = (text as NSString).range(of: "Edit".localized())
        if gesture.didTapAttributedTextInLabel(label: self.lbl_topText, inRange: register_Range) {
            print("user tapped on Edit")
            self.clkToClose()
        }
    }
    

    //MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Button Action
    @IBAction func btn_close(_ sender: UIButton) {
        self.clkToClose()
    }
    
    @IBAction func btn_edit_Action(_ sender: UIButton) {
        self.clkToClose()
    }

    // MARK: - UIButton Action
    @IBAction func btn_Resend_Action(_ sender: UIButton) {
        self.remainingSeconds = 59
        self.btn_Resend.isHidden = true
        self.generateOTPFromServer()
    }
    
    @IBAction func btn_Next_Action(_ sender: UIControl) {
        self.view.endEditing(true)
        if self.isButtonEnable {
            self.callApiforVerifyOTP()
        }
    }

}


extension OTPDialogVC {
    
    func callApiforVerifyOTP() {
        if Utils.isConnectedToNetwork() {
            //Firebase OTP verification
            Utils.startActivityIndicatorInView(self.view_Main, userInteraction: false)
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: str_enteredOTP)

            Auth.auth().signIn(with: credential) { (authResult, error) in
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view_Main)
                })
                if let _ = error {
                    // let authError = error as NSError
                    Utils.showAlertWithTitleInController("Error".localized(), message: "Failed to validate OTP, please try again.".localized(), controller: self)
                    return
                }
                
                if self.screen_from == .from_ediProfile {
                    self.clkToClose(true)
                }
                else {
                    self.doProcessAfterOTPVerificationDone()
                }
            }
        } else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func generateOTPFromServer() {
        self.setTimer()
        
        if Utils.isConnectedToNetwork() {
            //Firebase OTP generator
            Utils.startActivityIndicatorInView(self.view_Main, userInteraction: false)
            let phone = self.strCountryCode + self.strMobileNo
            print("phone=",phone)
            PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationID, error) in
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view_Main)
                })
                if let error = error {
                    print("### OTP error : ", error.localizedDescription)
                    Utils.showAlertWithTitleInController("Error".localized(), message: error.localizedDescription, controller: self)
                    return
                }
                self.verificationID = verificationID ?? ""
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
}


extension OTPDialogVC {
    
    func doProcessAfterOTPVerificationDone() {
        // User is signed in
        kUserDefaults.set(true, forKey: kIsFirstLaunch)
        kUserDefaults.storedScratchCards = [:] //clear any saved guest scratch cards
        self.clkToClose()
        if self.is_NewUser {
            let objSignUp = Story_LoginSignup.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
            objSignUp.str_PhoneNumber = self.strMobileNo
            self.super_vc.navigationController?.pushViewController(objSignUp, animated: true)
        }
        else {
            kSharedAppDelegate.showHomeScreen()
        }
    }

}
