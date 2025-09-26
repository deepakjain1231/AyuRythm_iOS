//
//  OTPViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 8/30/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseAuth

class OTPViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var constraintBottomScrollView: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var otp1: UITextField!

    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var lblAttemptsLeft: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblReceiveMessage: UILabel!
    @IBOutlet weak var btnVerify: RoundedButton!
    
    var phoneNumber  = ""
    var countryCode  = ""
    var isFromSignUp = false
    var maxAttempts = 3
    var signUpParasm = [String: Any]()
    var timer: Timer?
    var totalTime = 60
    var verificationID = ""
    var isFromLogin = false
    var serverReceivedOTP = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFromLogin {
            lblTitle.text = "Verify OTP".localized()
        }else{
        if isFromSignUp{
            lblTitle.text = "Verify OTP".localized()
        }else{
            lblTitle.text = "Forgot Password?".localized()
        }
        }
      
        let attributedString = NSMutableAttributedString(string: String(format: "Please enter the verification code \nsent to %@%@".localized(), countryCode, phoneNumber), attributes: [
          .font: UIFont.systemFont(ofSize: 20.0, weight: .regular),
          .foregroundColor: UIColor.black,
          .kern: 0.38
        ])
        let phone = countryCode + phoneNumber
        let strPhone : NSString = phone as NSString
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20.0, weight: .bold), range: NSRange(location: Utils.isAppInHindiLanguage ? 7 : 44, length: strPhone.length))
        
        lblDescription.attributedText = attributedString
        
      //  NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
      //  NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
      // self.hideKeyboardWhenTappedAround()
        
       // self.addDoneButtonOnKeyboard()
        
        otp1.layer.cornerRadius = 10
        otp1.layer.borderWidth = 1.0
        otp1.layer.borderColor = kAppColorGreen.cgColor
        
        self.lblAttemptsLeft.text = "\(self.maxAttempts) " + "attempts left".localized()
        generateOTPFromServer()
        otp1.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    private func startOtpTimer() {
        self.totalTime = 120
        resendButton.isEnabled = false
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    private func stopOtpTimer() {
        timer?.invalidate()
        self.timer = nil
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView?.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func updateTimer() {
               print(self.totalTime)
               self.lblCount.text = self.timeFormatted(self.totalTime) // will show timer
               if totalTime != 0 {
                   totalTime -= 1  // decrease counter timer
               } else {
                   if let timer = self.timer {
                       timer.invalidate()
                       self.timer = nil
                    resendButton.isEnabled = true

                   }
               }
           }
       func timeFormatted(_ totalSeconds: Int) -> String {
           let seconds: Int = totalSeconds % 60
           let minutes: Int = (totalSeconds / 60) % 60
           return String(format: "%02d:%02d", minutes, seconds)
       }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        scrollView?.contentOffset = CGPoint(x:0, y:keyboardFrame.size.height-150)
        self.constraintBottomScrollView.constant = -keyboardFrame.size.height
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        scrollView?.contentOffset = .zero
        self.constraintBottomScrollView.constant = 0.0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backClicked(_ sender: UIButton) {
        stopOtpTimer()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextClicked(_ sender: UIButton) {
        let otp = otp1.text!
        if otp.isEmpty {
            Utils.showAlertWithTitleInController("", message: "Please enter text", controller: self)
        } else {
            stopOtpTimer()
            resendButton.isEnabled = true

            otpFromServer(otp: otp)
        }
    }
    
    @IBAction func resendClicked(_ sender: UIButton)
    {
        self.maxAttempts -= 1
        if self.maxAttempts < 0{
           
            Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: "Please verify if the mobile number is correct".localized(), okTitle: "Ok".localized(), controller: self) {
                self.navigationController?.popViewController(animated: true)
            }
            self.resendButton.isEnabled = false
            return
        }
        self.lblAttemptsLeft.text = "\(self.maxAttempts) " + "attempts left".localized()
        self.resendButton.isEnabled = true
        self.generateOTPFromServer()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done".localized(), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MeasurementsViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.otp1.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
}

extension OTPViewController {
    func otpFromServer(otp: String) {
        if Utils.isConnectedToNetwork() {
            //Firebase OTP verification
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: otp)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                if let _ = error {
                    // let authError = error as NSError
                    Utils.showAlertWithTitleInController("Error".localized(), message: "Failed to validate OTP, please try again.".localized(), controller: self)
                    return
                }
                self.doProcessAfterOTPVerificationDone()
            }
            
            //Twilio OTP
            /*if isFromSignUp {
                //do on device OTP verification
                showActivityIndicator()
                if serverReceivedOTP == otp {
                    hideActivityIndicator()
                    doProcessAfterOTPVerificationDone()
                } else {
                    hideActivityIndicator()
                    showAlert(title: "Error".localized(), message: "OTP verification failed".localized())
                }
            } else {
                showActivityIndicator()
                let params = ["mobile_no": phoneNumber, "mobile_otp": otp] as [String : Any]
                Utils.doAPICall(endPoint: .verifyOTP, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
                    self.hideActivityIndicator()
                    if isSuccess {
                        self.doProcessAfterOTPVerificationDone()
                    } else {
                        self.showAlert(title: status, message: message)
                    }
                }
            }*/
        } else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func generateOTPFromServer() {
        startOtpTimer()
        
        if Utils.isConnectedToNetwork() {
            //Firebase OTP generator
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let phone = countryCode + phoneNumber
            
            print("phone=",phone)
            
            PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationID, error) in
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                if let error = error {
                    print("### OTP error : ", error.localizedDescription)
                    Utils.showAlertWithTitleInController("Error".localized(), message: error.localizedDescription, controller: self)
                    //Utils.showAlertWithTitleInController("Error".localized(), message: "Failed to send OTP, Please try again".localized(), controller: self)
                    return
                }
                self.verificationID = verificationID ?? ""
            }
            
            //Twilio OTP
            /*showActivityIndicator()
            let params = ["mobile_no": phoneNumber, "country_code": countryCode, "type": isFromSignUp ? 1 : 0] as [String : Any]
            Utils.doAPICall(endPoint: .generateOTP, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
                self.hideActivityIndicator()
                self.serverReceivedOTP = responseJSON?["Otp"].stringValue ?? ""
                if !isSuccess {
                    self.showAlert(title: status, message: message)
                }
            }*/
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
}



extension OTPViewController {
    func doProcessAfterOTPVerificationDone() {
        // User is signed in
        if self.isFromLogin {
            kUserDefaults.set(true, forKey: kIsFirstLaunch)
            kUserDefaults.storedScratchCards = [:] //clear any saved guest scratch cards
            kSharedAppDelegate.showHomeScreen()
        } else {
            if self.isFromSignUp {
                self.signUpFromServer(params: self.signUpParasm)
            } else {
                let objResetPasswordView:ResetPasswordViewController = Story_Main.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
                objResetPasswordView.phoneNumber = self.phoneNumber
                self.navigationController?.pushViewController(objResetPasswordView, animated: true)
            }
        }
    }
    
    func signUpFromServer(params: [String: Any]) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.register.rawValue
            
            print("params=",params)
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default).responseJSON  { response in
                
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                
                    if dicResponse["status"] as? String ?? "" == "Sucess" {
                        let userId = dicResponse["id"] as? String
                        
                        kSharedAppDelegate.userId = dicResponse["id"] as? String ?? ""
                        kUserDefaults.set(dicResponse, forKey: USER_DATA)
                        //Temo Comment//MoEngageHelper.shared.setDefaultAttributes(from: dicResponse)
                        
                        kUserDefaults.set(dicResponse["token"] as? String ?? "", forKey:TOKEN)
                        self.uploadGuestUserDataOnServer(userId: userId ?? "")
                    } else {
                        Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["Message"] as? String ?? "Failed to register user".localized()), controller: self)
                    }
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
              
            }
        
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func uploadGuestUserDataOnServer(userId: String) {
        if Utils.isConnectedToNetwork() {
            let strPrashna = Utils.getPrakritiValue()
            let resultP = strPrashna.isEmpty ? "" : "[" + strPrashna + "]"

            let strVikrti = Utils.getVikritiValue()
            let resultV = strVikrti.isEmpty ? "" : "[" + strVikrti + "]"

            let isSparshnaTestGiven = kUserDefaults.bool(forKey: kVikritiSparshanaCompleted)
            let isPrashnaTestGiven = kUserDefaults.bool(forKey: kVikritiPrashnaCompleted)
            
            var sparshnaValues = ""
            if let measurementData = kUserDefaults.value(forKey: kUserMeasurementData) as? [String: Any] {
                sparshnaValues = measurementData["user_result"] as? String ?? ""
            }

            var params = ["prashna_prakriti" : resultP, "sparshna": sparshnaValues, "user_ffs": "", "user_ppf": "", "user_sparshna": "", "graph_params": "" , "user_id": userId,  "user_vikriti": resultV, "vikriti_prashna": (isPrashnaTestGiven ? "true" : "false"), "vikriti_sprashna": (isSparshnaTestGiven ? "true" : "false")]
            params.addVikritiResultFinalValue()

            print("params=",params)
            
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.usergraphspar.rawValue

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON  { response in
                
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    if dicResponse["status"] as? String ?? "" == "Sucess" {
                        if kUserDefaults.value(forKey: kUserMeasurementData) != nil
                        {
                            self.uploadMeasumentDataOnServer(userId: userId, isPrashnaGiven:isPrashnaTestGiven, resultP: resultP)
                            
                        } else {
                            if isPrashnaTestGiven {
                                self.postPrakritiAnswersData(value: resultP)
                            } else {
                                kUserDefaults.set(true, forKey: kIsFirstLaunch)
                                //kSharedAppDelegate.showHomeScreen()
                                self.addEarnHistoryFromServer()
                            }
                        }
                    } else {
                        Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["Message"] as? String ?? "Failed to register user".localized()), controller: self)
                    }
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
        ScratchCardVC.updateStoredScratchCardOnServer()
    }
    
    func uploadMeasumentDataOnServer(userId: String, isPrashnaGiven: Bool, resultP: String) {
        if Utils.isConnectedToNetwork() {
            //REGISTERED USER
            let urlString = kBaseNewURL + endPoint.savesparshnatest.rawValue

            var params = kUserDefaults.value(forKey: kUserMeasurementData) as? [String: Any]
            
            params?["user_duid"] = userId
            
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).responseJSON  { response in
                
                Utils.stopActivityIndicatorinView(self.view)
                switch response.result {
                    
                case .success(let value):
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    
                    if dicResponse["status"] as? String ?? "" == "Sucess" {
                        if isPrashnaGiven {
                            self.postPrakritiAnswersData(value: resultP)
                        } else {
                            kUserDefaults.set(true, forKey: kIsFirstLaunch)
                            //kSharedAppDelegate.showHomeScreen()
                            self.addEarnHistoryFromServer()
                        }
                    } else {
                        Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["Message"] as? String ?? "Failed to register user".localized()), controller: self)
                    }
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
            }
        } else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func postPrakritiAnswersData(value: String) {
        if Utils.isConnectedToNetwork() {
            
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let answers = kUserDefaults.value(forKey: kPrakritiAnswersToSend) ?? ""
            let urlString = kBaseNewURL + endPoint.updateparkriti.rawValue
            var params = ["user_prakriti": value, "answers": answers, "score": value]
            params.addPrakritiResultFinalValue()

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON  { response in
                
                switch response.result {
                    
                case .success(let values):
                    print(response)
                    guard let dic = (values as? [String: Any]) else {
                        return
                    }
                    if (dic["status"] as? String ?? "") == "Sucess" {
                        kUserDefaults.set(true, forKey: kIsFirstLaunch)
                        //kSharedAppDelegate.showHomeScreen()
                        self.addEarnHistoryFromServer()
                    } else {
                        Utils.showAlertWithTitleInController(APP_NAME, message: (dic["Message"] as? String ?? ""), controller: self)
                    }
                    
                case .failure(let error):
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
}

extension OTPViewController {
    func addEarnHistoryFromServer() {
        let params = ["activity_favorite_id": AyuSeedEarnActivity.onboarding.rawValue, "language_id": Utils.getLanguageId()] as [String : Any]
        ReferPopupViewController.addEarmHistoryFromServer(params: params) { (isSuccess, title, message) in
            print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
            self.hideActivityIndicator()
            if isSuccess {
                Utils.showAlertWithTitleInControllerWithCompletion(title, message: message, okTitle: "Ok", controller: self) {
                    kSharedAppDelegate.showHomeScreen()
                }
            } else {
                kSharedAppDelegate.showHomeScreen()
            }
        }
    }
}
