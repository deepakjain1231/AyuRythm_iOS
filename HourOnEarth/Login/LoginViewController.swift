//
//  LoginViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 5/25/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseAuth
import SKCountryPicker
import AuthenticationServices

class LoginViewController: UIViewController,UITextFieldDelegate,UIScrollViewDelegate, UITextViewDelegate, delegate_login, countryPickDelegate {
    
    var verificationID = ""
    @IBOutlet var lbl_title: UILabel!
    @IBOutlet var textView: UITextView?
    @IBOutlet var btn_whatsapp: UIControl!
    @IBOutlet var btn_google: UIControl!
    @IBOutlet var btn_facebook: UIControl!
    @IBOutlet var btn_apple: UIControl!
    @IBOutlet var btn_submit: UIControl!
    @IBOutlet var lbl_send: UILabel!
    @IBOutlet var lbl_or_connect: UILabel!
    @IBOutlet var view_textBG: UIView!
    @IBOutlet var img_country: UIImageView!
    @IBOutlet var lbl_countryCode: UILabel!
    @IBOutlet var txt_number: UITextField!
    
    private var strprivacyText = "By proceeding with registration, login and using our app, you agree to our Terms and Conditions and Privacy Policy.".localized()
    var socialLoginHelper: SocialLoginHelper?
    var isButtonEnable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addToolBar(textField: txt_number!)
        kSharedAppDelegate.login_delegate = self
        self.lbl_send.text = "Send OTP".localized()
        self.lbl_title.text = "LOG IN or SIGN UP".localized()
        self.lbl_or_connect.text = "Or connect with".localized()
        self.txt_number.placeholder = "Mobile number".localized()
        self.lbl_countryCode.text = CountryManager.shared.currentCountry?.dialingCode ?? "+91"
        self.img_country.image = CountryManager.shared.currentCountry?.flag ?? UIImage.init(named: "IN.png")
        
        self.setupTermsConditionText()
        self.setupSocialButtons()
        self.txt_number.addTarget(self, action: #selector(self.textfieldDidChangeeee(_:)), for: .editingChanged)

        if #available(iOS 13.0, *) {
        } else {
            btn_apple.isHidden = true
        }
    }
    
    func setupTermsConditionText() {
        let attributedString = NSMutableAttributedString(string: self.strprivacyText, attributes: [.font: UIFont.init(name: "Inter-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium), .foregroundColor: UIColor.black, .kern: -0.41])

        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: Utils.isAppInHindiLanguage ? NSRange(location: 73, length: 16) : NSRange(location: 75, length: 20))
            attributedString.addAttribute(.foregroundColor, value: kAppColorGreen, range: Utils.isAppInHindiLanguage ? NSRange(location: 94, length: 13) : NSRange(location: 100, length: 14))
        
            attributedString.addAttribute(.link, value: kTermsAndCondition, range: Utils.isAppInHindiLanguage ? NSRange(location: 73, length: 16) : NSRange(location: 75, length: 20))
            attributedString.addAttribute(.link, value: kPrivacyPolicy, range: Utils.isAppInHindiLanguage ? NSRange(location: 94, length: 13) : NSRange(location: 100, length: 14))
        
        textView?.attributedText = attributedString
        textView?.delegate = self
    }
    
    func setupSocialButtons() {
        self.btn_whatsapp.layer.backgroundColor = UIColor(red: 1, green: 0.976, blue: 0.961, alpha: 1).cgColor
        self.btn_whatsapp.layer.cornerRadius = 12
        self.btn_whatsapp.layer.borderWidth = 1
        self.btn_whatsapp.layer.borderColor = UIColor(red: 0.153, green: 0.247, blue: 0.169, alpha: 1).cgColor
        
        self.btn_google.layer.backgroundColor = UIColor(red: 1, green: 0.976, blue: 0.961, alpha: 1).cgColor
        self.btn_google.layer.cornerRadius = 12
        self.btn_google.layer.borderWidth = 1
        self.btn_google.layer.borderColor = UIColor(red: 0.153, green: 0.247, blue: 0.169, alpha: 1).cgColor
        
        self.btn_facebook.layer.backgroundColor = UIColor(red: 1, green: 0.976, blue: 0.961, alpha: 1).cgColor
        self.btn_facebook.layer.cornerRadius = 12
        self.btn_facebook.layer.borderWidth = 1
        self.btn_facebook.layer.borderColor = UIColor(red: 0.153, green: 0.247, blue: 0.169, alpha: 1).cgColor
        
        self.btn_apple.layer.backgroundColor = UIColor(red: 1, green: 0.976, blue: 0.961, alpha: 1).cgColor
        self.btn_apple.layer.cornerRadius = 12
        self.btn_apple.layer.borderWidth = 1
        self.btn_apple.layer.borderColor = UIColor(red: 0.153, green: 0.247, blue: 0.169, alpha: 1).cgColor

        self.view_textBG.layer.cornerRadius = 12
        self.view_textBG.layer.borderWidth = 1
        self.view_textBG.layer.borderColor = UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 1).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        kUserDefaults.set(false, forKey: IS_LOGGEDIN)
    }

    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
           UIApplication.shared.open(URL)
           return false
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - UITextField Delegate
    @objc func textfieldDidChangeeee(_ textField: UITextField) {
        if let strText = textField.text {
            if strText.count >= 8 {
                self.isButtonEnable = true
                self.btn_submit.backgroundColor = AppColor.app_DarkGreenColor
            }
            else {
                self.isButtonEnable = false
                self.btn_submit.backgroundColor = UIColor.fromHex(hexString: "#777777")
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txt_number {
            if string == "0" && (textField.text ?? "").trimed().count == 0 {
                return false
            }
            else {
                let currentString: NSString = (textField.text ?? "") as NSString
                let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
                let ACCEPTABLE_NUMBERS = "1234567890"
                let cs = NSCharacterSet(charactersIn: ACCEPTABLE_NUMBERS).inverted
                let filtered = string.components(separatedBy: cs).joined(separator: "")
                if string != filtered {
                    return false
                }
                return newString.length <= 15
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func addToolBar(textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: UIBarButtonItem.Style.done, target: self, action: #selector(LoginViewController.donePressed))
        let cancelButton = UIBarButtonItem(title: "Cancel".localized(), style: UIBarButtonItem.Style.plain, target: self, action: #selector(LoginViewController.cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }

    @objc func donePressed(){
        view.endEditing(true)
    }

    @objc func cancelPressed(){
        view.endEditing(true) // or do something
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }

    @IBAction func btn_CountryCode_Action(_ sender: UIControl) {
        self.view.endEditing(true)
        let objDialouge = CountrySelectionVC(nibName:"CountrySelectionVC", bundle:nil)
        objDialouge.delegate = self
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }

    

    @IBAction func btn_login_Action(_ sender: UIButton) {
        self.view.endEditing(true)
        kSharedAppDelegate.isWhatsAppLogin = false
        if self.isButtonEnable {
            if self.lbl_countryCode.text?.isEmpty ?? true {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please select country code", controller: self)
            }
            else if self.txt_number?.text?.isEmpty ?? true {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter mobile number.", controller: self)
            }
            else {
                loginFromServer()
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Country Selection
    func selectCountry(screenFrom: String, is_Pick: Bool, selectedCountry: Country?) {
        if is_Pick {
            self.lbl_countryCode.text = selectedCountry?.phoneCode
            self.img_country.image = selectedCountry?.flag
            self.txt_number.becomeFirstResponder()
        }
    }
}

extension LoginViewController {
    func loginFromServer(socialLoginUser: SocialLoginUser? = nil, loginType: ARLoginType = .normal) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.login.rawValue
            
            let fcm_Token = kUserDefaults.value(forKey: kFcmToken) as? String ?? ""
            
            let deviceid_TOKEN = kUserDefaults.value(forKey: kDeviceToken) as? String ?? ""
            
            var params = ["user_name": self.txt_number?.text ?? "", "user_pass": "","fcm":fcm_Token,"type": DEVICE_TYPE,"deviceid":deviceid_TOKEN]
            
            if let socialLoginUser = socialLoginUser {
                params = ["user_name": socialLoginUser.email ?? ""/*, "socialid": socialLoginUser.socialID*/, "social_type": loginType.stringValue,"fcm":fcm_Token,"type": DEVICE_TYPE,"deviceid":deviceid_TOKEN]
                
                if loginType == .apple {
                    params["socialid"] = socialLoginUser.socialID
                }
            }
            
            if loginType == .whatsapp {
                params["waId"] = socialLoginUser?.socialID
            }
            print(params)
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default).responseJSON  { response in
                
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    
                    if dicResponse["status"] as? String == "Error" {
                        DispatchQueue.main.async(execute: {
                            Utils.stopActivityIndicatorinView(self.view)
                            if let socialLoginUser = socialLoginUser {
                                self.showSignupScreen(socialLoginUser: socialLoginUser)
                            } else {
                                self.generateOTPFromServer(true)
                            }
                        })
                        return
                    }
                    
                    kSharedAppDelegate.userId = dicResponse["id"] as? String ?? ""

                    var dicToSave = dicResponse
                    //replace null value with empty string
                    dicToSave = dicToSave.nullKeyRemoval()
                    kUserDefaults.set(dicToSave, forKey: USER_DATA)
                    kUserDefaults.set(dicResponse["token"] as? String ?? "", forKey:TOKEN)

                    let prashna: String = dicResponse["prashna_prakriti"] as? String ?? ""
                    let vikriti = dicResponse["vikriti"] as? String ?? ""
                    let vikritiPrashnaTest = dicResponse["vikriti_prashna"] as? String ?? "false"
                    let vikritiSparshnaTest = dicResponse["vikriti_sprashna"] as? String ?? "false"
                    kUserDefaults.set(Bool(vikritiPrashnaTest), forKey: kVikritiPrashnaCompleted)
                    kUserDefaults.set(Bool(vikritiSparshnaTest), forKey: kVikritiSparshanaCompleted)
                    
                    if !prashna.isEmpty {
                        let seprated = Utils.parseValidValue(string: prashna)
                        kUserDefaults.set(seprated, forKey: RESULT_PRAKRITI)
                    }
                    if !vikriti.isEmpty {
                        let seprated = Utils.parseValidValue(string: vikriti)
                        kUserDefaults.set(seprated, forKey: RESULT_VIKRITI)
                    }

                    if let urlString = dicResponse["image"] as? String, URL(string: urlString) != nil {
                        kUserDefaults.set(urlString, forKey: kUserImage)
                    }

                    if let _ = socialLoginUser {
                        kUserDefaults.set(true, forKey: kIsFirstLaunch)
                        kSharedAppDelegate.showHomeScreen()
                    } else {
                        self.generateOTPFromServer(false)
                    }

                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func generateOTPFromServer(_ newuser: Bool) {
        if Utils.isConnectedToNetwork() {
            //Firebase OTP generator
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let phone = (self.lbl_countryCode.text ?? "") + (self.txt_number.text ?? "")
            print("phone=",phone)
            PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationID, error) in
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                if let error = error {
                    print("### OTP error : ", error.localizedDescription)
                    Utils.showAlertWithTitleInController("Error".localized(), message: "Please enter valid mobile number.".localized(), controller: self)
                    return
                }
                self.verificationID = verificationID ?? ""
                self.goToOTPVC(newuser)
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func goToOTPVC(_ newuser: Bool) {
        let objDialouge = OTPDialogVC(nibName:"OTPDialogVC", bundle:nil)
        objDialouge.super_vc = self
        objDialouge.is_NewUser = newuser
        objDialouge.strMobileNo = self.txt_number.text ?? ""
        objDialouge.strCountryCode = self.lbl_countryCode.text ?? ""
        objDialouge.verificationID = self.verificationID
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }

    //
    static func clearUserDefaultsData(userID: String) {
        kUserDefaults.removeObject(forKey: USER_DATA)
        kUserDefaults.removeObject(forKey: VIKRITI_PRASHNA)
        kUserDefaults.removeObject(forKey: VIKRITI_DARSHNA)
        kUserDefaults.removeObject(forKey: VIKRITI_SPARSHNA)
        kUserDefaults.removeObject(forKey: RESULT_PRAKRITI)
        kUserDefaults.removeObject(forKey: RESULT_VIKRITI)
        kUserDefaults.removeObject(forKey: TOKEN)
        kUserDefaults.removeObject(forKey: kUserListPoints)
        kUserDefaults.removeObject(forKey: kUserListRedeemed)
        kUserDefaults.removeObject(forKey: kBYDoctorr)
    }
}

//MARK: - Whatsapp login
extension LoginViewController {

    func whatsapplogin_delegate(_ is_success: Bool, waID: String) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            DispatchQueue.main.async {
                Utils.stopActivityIndicatorinView(self.view)
            }

            let socialUser = SocialLoginUser(type: ARLoginType.whatsapp, socialID: waID, name: "", email: "", phoneNumber: "")
            self.socialLoginCompletion(isSuccess: true, message: "", user: socialUser, loginType: ARLoginType.whatsapp)
        }
        else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }

}


// MARK: - Social Login
extension LoginViewController {
    
    @IBAction func btn_WhatsApp_Action(_ sender: UIControl) {
        kSharedAppDelegate.isWhatsAppLogin = true
        UIApplication.shared.open(URL(string: kWhatsappURL)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func btn_GoogleLogin_Action(_ sender: UIControl) {
        kSharedAppDelegate.isWhatsAppLogin = false
        showActivityIndicator(view: self.view)
        socialLoginHelper = SocialLoginHelper(presentingVC: self)
        socialLoginHelper?.doGoogleSignIn(completion: socialLoginCompletion)
    }

    @IBAction func btn_FacebookLogin_Action(_ sender: UIControl) {
        kSharedAppDelegate.isWhatsAppLogin = false
        showActivityIndicator(view: self.view)
        socialLoginHelper = SocialLoginHelper(presentingVC: self)
        socialLoginHelper?.doFacebookSignIn(completion: socialLoginCompletion)
    }

    @IBAction func btn_appleLogin_Action(_ sender: UIControl) {
        kSharedAppDelegate.isWhatsAppLogin = false
        showActivityIndicator(view: self.view)
        socialLoginHelper = SocialLoginHelper(presentingVC: self)
        if #available(iOS 13, *) {
            socialLoginHelper?.doAppleSignIn(completion: socialLoginCompletion)
        }
    }

    func socialLoginCompletion(isSuccess: Bool, message: String, user: SocialLoginUser?, loginType: ARLoginType) {
        print("isSuccess : ", isSuccess, "\nmessage : ", message, "\nemail : ", user?.email ?? "", "\nphoneNumber : ", user?.phoneNumber, "\nloginType : ", loginType)
        DispatchQueue.main.async {
            if isSuccess, let user = user {
                self.hideActivityIndicator(view: self.view)
                self.loginFromServer(socialLoginUser: user, loginType: loginType)
            } else {
                self.hideActivityIndicator(view: self.view)
                self.showAlert(message: message)
            }
            self.socialLoginHelper = nil
        }
    }

    func showSignupScreen(socialLoginUser: SocialLoginUser) {
        let objSignUp = Story_LoginSignup.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        objSignUp.socialLoginUser = socialLoginUser
        self.navigationController?.pushViewController(objSignUp, animated: true)
     }
}

