//
//  SignUpVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 11/03/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import SKCountryPicker

class SignUpVC: BaseViewController, UIScrollViewDelegate, didTappedReferral {
   
    @IBOutlet var lbl_title: UILabel!
    @IBOutlet var lbl_subtitle: UILabel!
    
    @IBOutlet var txt_name: UITextField!
    @IBOutlet var txt_email: UITextField!
    @IBOutlet var txt_height: UITextField!
    @IBOutlet var txt_weight: UITextField!
    @IBOutlet var txt_dob: UITextField!
    
    @IBOutlet var lbl_name: UILabel!
    @IBOutlet var lbl_email: UILabel!
    @IBOutlet var lbl_height: UILabel!
    @IBOutlet var lbl_weight: UILabel!
    @IBOutlet var lbl_dob: UILabel!
    
    @IBOutlet var lbl_male: UILabel!
    @IBOutlet var lbl_female: UILabel!
    @IBOutlet var btn_male: UIControl!
    @IBOutlet var btn_female: UIControl!
    
    @IBOutlet var btn_referralCode: UIButton!
    @IBOutlet var btn_register: UIControl!
    @IBOutlet var btn_appleHealth: UIControl!
    
    @IBOutlet var lbl_or: UILabel!
    @IBOutlet var lbl_letsBegin: UILabel!
    @IBOutlet var lbl_appleHealth: UILabel!
    @IBOutlet var lbl_alreadyHaveAccount: UILabel!
    @IBOutlet var btn_signIn: UIButton!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var scrollBottomConstraint: NSLayoutConstraint!
    
    var arr_Feet = MeasurementData.Height.feetValues
    var arr_Inch = MeasurementData.Height.inchValues
    var arr_CM = MeasurementData.Height.cmValues
    var arr_Kgs = MeasurementData.weight.kgValues
    var arr_Lbs = MeasurementData.weight.poundValues
    
    let arrSelectionHeight = ["Imperial","Metric"]
    let arrSelectionsHeight = ["cm","ft in"]
    let arrISelectionWeight = ["lbs", "Kgs"]

    var selectedType: SelectionType = .heightFtIn
    var isHeightInCm = false
    var isWeightInPounds = false

    var selectedHeightType: SelectionsHeightType = .ftin
    var selectedWeightType: SelectionWeightType = .Kgs

    var ftString = ""
    var inchString = ""
    var cmString = ""
    var weightString = ""
    var str_gender = ""
    var referral_code = ""

    var countryCodes = "+91"
    var countryName = "India"
    var str_PhoneNumber = ""
    var socialLoginUser: SocialLoginUser?
    let healthStore = HealthKitManager()
    
    var dob_date_Picker = UIDatePicker()
    var height_Picker = UIPickerView()
    var weight_Picker = UIPickerView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setLocalizationText()
        self.malefemale_selection(true)
        
        self.height_Picker.delegate = self
        self.height_Picker.dataSource = self
        self.weight_Picker.delegate = self
        self.weight_Picker.dataSource = self
        
        if #available(iOS 13.4, *) {
            self.dob_date_Picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        self.dob_date_Picker.maximumDate = Calendar.current.date(byAdding: .year, value: -12, to: Date())
        self.dob_date_Picker.datePickerMode = .date
        self.dob_date_Picker.addTarget(self, action: #selector(self.datePickerDidBirthday(_:)), for: UIControl.Event.valueChanged)
        
        
        if let socialLoginUser = socialLoginUser {
            txt_name.text = socialLoginUser.name ?? ""
            txt_email.text = socialLoginUser.email ?? ""
            self.str_PhoneNumber = socialLoginUser.phoneNumber ?? ""
            self.view.layoutIfNeeded()
        }
        
        self.displaySharedStoredData()
        
        self.privacyPolicyy()
    }
    
    func setLocalizationText() {
        self.lbl_title.text = "enter_your_details".localized()
        self.lbl_subtitle.text = "get_stated_enter_your_details".localized()
        self.lbl_male.text = "Male".localized()
        self.lbl_female.text = "Female".localized()
        self.lbl_name.text = "your_name".localized()
        self.lbl_email.text = "your_email".localized()
        self.lbl_height.text = "your_height".localized()
        self.lbl_weight.text = "your_weight".localized()
        self.lbl_dob.text = "your_birthday".localized()
        self.txt_name.placeholder = "Enter your name here".localized()
        self.txt_email.placeholder = "Email ID".localized()
        self.txt_height.placeholder = "Height".localized()
        self.txt_weight.placeholder = "Weight".localized()
        self.txt_dob.placeholder = "Date of Birth".localized()
        self.lbl_appleHealth.text = "Autofill with Apple Health".localized()
        self.btn_referralCode.setTitle("have_a_referral_code".localized(), for: .normal)
        self.lbl_letsBegin.text = "let_s_begin".localized()
        self.lbl_or.text = "or".localized()
        self.btn_signIn.setTitle("Sign in".localized(), for: .normal)
        self.lbl_alreadyHaveAccount.text = "Already have an account?".localized()
    }
    
    func privacyPolicyy() {
        let objDialouge = PrivacyNewUserVC(nibName:"PrivacyNewUserVC", bundle:nil)
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView?.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func countryPickerButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        self.scrollBottomConstraint.constant = -keyboardFrame.size.height
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        self.scrollBottomConstraint.constant = 0.0
    }
    
    @objc func datePickerDidBirthday(_ sender: UIDatePicker) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy"
        self.txt_dob.text = dateFormat.string(from: sender.date)
    }
    
    
    @IBAction func register_Action(sender: UIButton) {

        if self.txt_name.text?.isEmpty ?? true {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter your name".localized(), controller: self)
        }
        else if self.txt_email.text?.isEmpty ?? true {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter email.".localized(), controller: self)
        }
        else if self.txt_dob.text?.isEmpty ?? true {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter date of birth.".localized(), controller: self)
        }
        else if !Utils.isValidEmail(testStr: (txt_email.text ?? "")) {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter valid email.".localized(), controller: self)
        } else {
            signUpFromServer()
        }
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        var is_moveScreen = false
        for controller in self.navigationController?.viewControllers ?? [] {
            if controller is LoginViewController {
                is_moveScreen = true
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
        
        if is_moveScreen == false {
            kSharedAppDelegate.showLoginScreen()
        }
    }
    
    @IBAction func healthkitButtonClicked(_ sender: UIControl) {
        healthStore.checkAuthorizationStatusAndGetHealthParameters(fromVC: self) { heightInCmString, weightInKgsString, dob, gender in
            
            if let heightInCmString = heightInCmString {
                self.cmString = heightInCmString
                self.selectedType = SelectionType.heightFtIn
                self.selectedHeightType = SelectionsHeightType.cm
                self.txt_height.text = self.cmString + " " + "cm".localized()
                self.isHeightInCm = true
                Shared.sharedInstance.inFt = self.cmString
            }
            
            if let weightInKgsString = weightInKgsString {
                self.isWeightInPounds = true
                self.weightString = weightInKgsString
                self.txt_weight.text = self.weightString + " Kgs"
                self.selectedType = SelectionType.weightSelection
                self.selectedWeightType = SelectionWeightType.Kgs
                Shared.sharedInstance.weigh = self.weightString
            }
            
            if let dob = dob {
                self.txt_dob?.text = dob
            }
            
            if gender == "Female" {
                //Gender Female
                self.malefemale_selection(false)
            } else {
                //Gender Male
                self.malefemale_selection(true)
            }
        }
        return
    }
    
    func displaySharedStoredData() {
        self.txt_name?.text = Shared.sharedInstance.name
        self.txt_dob?.text = Shared.sharedInstance.dob
        self.isHeightInCm = Shared.sharedInstance.isInFt
        self.isWeightInPounds = Shared.sharedInstance.isInKg
        
        if !Shared.sharedInstance.weigh.isEmpty {
            self.txt_weight.text = self.isWeightInPounds == true ? Shared.sharedInstance.weigh + " " + "kg".localized() : Shared.sharedInstance.weigh + " " + "lbs".localized()
        }
        
        
        if !Shared.sharedInstance.inFt.isEmpty || !Shared.sharedInstance.inInc.isEmpty {
            self.txt_height.text = self.isHeightInCm == false ?  Shared.sharedInstance.inFt + " " + "cm".localized() : Shared.sharedInstance.inFt + " " + "ft".localized() + " " + Shared.sharedInstance.inInc + " " + "in".localized()
        }
        
        if Shared.sharedInstance.isMale {
            self.malefemale_selection(true)
        } else {
            self.malefemale_selection(false)
        }
    }
    
    func malefemale_selection(_ isMale: Bool) {
        if isMale {
            self.str_gender = "Male"
            self.btn_male.borderWidth1 = 3
            self.btn_female.borderWidth1 = 1
            self.btn_male.borderColor1 = UIColor.fromHex(hexString: "#3E8B3A")
            self.btn_female.borderColor1 = UIColor.fromHex(hexString: "#AAAAAA")
        }
        else {
            self.str_gender = "Female"
            self.btn_male.borderWidth1 = 1
            self.btn_female.borderWidth1 = 3
            self.btn_male.borderColor1 = UIColor.fromHex(hexString: "#AAAAAA")
            self.btn_female.borderColor1 = UIColor.fromHex(hexString: "#3E8B3A")
        }
    }
    
    
    //MARK: - UIButtton Action
    @IBAction func btn_male_Action(_ sender: UIControl) {
        self.malefemale_selection(true)
    }
    
    @IBAction func btn_female_Action(_ sender: UIControl) {
        self.malefemale_selection(false)
    }
    
    @IBAction func infoButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        Utils.showAlertWithTitleInController(Date_Of_BirthTitle, message: DateOfBirthDescription, controller: self)
    }
    
    @IBAction func btn_DobClicked(_ sender: UIControl) {
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                               UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneDatePicker))]
        numberToolbar.sizeToFit()
        self.txt_dob.inputAccessoryView = numberToolbar
        self.txt_dob.inputView = self.dob_date_Picker
    }
    
    @IBAction func btn_ReferralCode(_ sender: UIButton) {
        if self.btn_referralCode.isSelected == false {
            let objDialouge = EnterReferralDialouge(nibName:"EnterReferralDialouge", bundle:nil)
            objDialouge.delegate = self
            objDialouge.presentingVC = self
            self.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
            self.view.addSubview((objDialouge.view)!)
            objDialouge.didMove(toParent: self)
        }
    }
    
    func didTappedClose_referralSelected(_ success: Bool, referralCode: String) {
        if success {
            if referralCode != "" {
                DispatchQueue.main.async {
                    self.referral_code = referralCode
                    self.btn_referralCode.isSelected = true
                }
            }
        }
    }
}



extension SignUpVC {
    func signUpFromServer() {
        if Utils.isConnectedToNetwork() {
            
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            var height = 0.0
            var heightUnit = ""
            if Shared.sharedInstance.isInFt {
                heightUnit = "feet"
                let heightInFeet = Double(Shared.sharedInstance.inFt) ?? 0
                let heightInInch = Double(Shared.sharedInstance.inInc) ?? 0
                height = heightInFeet * 30.48 + heightInInch * 2.54
            
            } else {
                heightUnit = "Centimeter"
                height = (Double(Shared.sharedInstance.inFt) ?? 0)
            }
            
            var weight = ""
            var weightUnit = ""
            if !isWeightInPounds {
                weightUnit = "Pound"
                weight = Utils.convertPoundsToKg(lb: Shared.sharedInstance.weigh)
            } else {
                weightUnit = "Kilogram"
                weight = Shared.sharedInstance.weigh
            }

            let heightString = String(format: "%.2f", height)
            let userMeasurements = "[\"\(heightString)\",\"\(weight)\",\"\(heightUnit)\",\"\(weightUnit)\"]"
            
             let fcm_Token = kUserDefaults.value(forKey: kFcmToken) as? String ?? ""
             let deviceid_TOKEN = kUserDefaults.value(forKey: kDeviceToken) as? String ?? ""

            var params = ["user_name": txt_name.text ?? "",
                          "user_mobile": self.str_PhoneNumber,
                          "user_email": self.txt_email.text ?? "",
                          "user_gender": self.str_gender,
                          "user_dob":txt_dob?.text ?? "",
                          "user_measurements": userMeasurements,
                          "fcm":fcm_Token,
                          "type": DEVICE_TYPE,
                          "deviceid":deviceid_TOKEN,
                          "countrycode": self.countryCodes,
                          "country": self.countryName,
                          "login_type": ARLoginType.normal.rawValue] as [String : Any]
            
            if self.referral_code != "" {
                params["referral_code"] = self.referral_code
            }
            
            if let socialLoginUser = socialLoginUser {
                params["social_type"] = socialLoginUser.type.rawValue
                params["social_id"] = socialLoginUser.socialID
                signUpFromServer(params: params)
            } else {
                self.signUpFromServer(params: params)
//                let objView:OTPViewController = Story_Main.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
//                objView.phoneNumber = self.str_PhoneNumber
//                objView.countryCode = self.countryCodes
//                objView.isFromSignUp = true
//                objView.signUpParasm = params
//                self.navigationController?.pushViewController(objView, animated: true)
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
}

extension SignUpVC {
    func signUpFromServer(params: [String: Any]) {
        if Utils.isConnectedToNetwork() {
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
                        let userId = dicResponse["id"] as? String ?? ""
                        
                        kSharedAppDelegate.userId = userId
                        kUserDefaults.set(dicResponse, forKey: USER_DATA)
                        kUserDefaults.set(dicResponse["token"] as? String ?? "", forKey:TOKEN)
                        kUserDefaults.set(true, forKey: kIsFirstLaunch)
                        
                        //Set Logic For Free Trial
                        UserDefaults.user.set_finger_Count(data: 1)
                        UserDefaults.user.set_facenaadi_Count(data: 1)
                        
                        UserDefaults.user.set_finger_trialCount(data: 0)
                        UserDefaults.user.set_facenaadi_trialCount(data: 0)
                        UserDefaults.user.set_ayumonk_trialCount(data: 0)
                        UserDefaults.user.set_home_remidies_trial_count(data: 0)
                        //*************************//

                        //Temo Comment//MoEngageHelper.shared.setDefaultAttributes(from: dicResponse)
                        //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.signup.rawValue)
                        self.addEarnHistoryFromServer()
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
    
}



// MARK: - UITextField Delegate Method
extension SignUpVC: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txt_dob {
            self.dob_date_Picker.addTarget(self, action: #selector(self.datePickerDidBirthday(_:)), for: UIControl.Event.valueChanged)
            
            let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            numberToolbar.barStyle = .default
            numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                                   UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneDatePicker))]
            numberToolbar.sizeToFit()
            textField.inputAccessoryView = numberToolbar
            textField.inputView = self.dob_date_Picker
            
            if textField.text == "" {
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "dd-MM-yyyy"
                textField.text = dateFormat.string(from: self.dob_date_Picker.date)
            }
        }
        else if textField == txt_height {
            if self.isHeightInCm {
                selectedType = .heightFtIn
                self.height_Picker.reloadAllComponents()
                selectedWeightType = .balnk
                selectedHeightType = .cm
                self.height_Picker.selectRow(0, inComponent: 1, animated: false)
            } else {
                self.selectedType = .heightFtIn
                self.selectedWeightType = .balnk
                self.selectedHeightType = .ftin
                self.height_Picker.reloadAllComponents()
                
                if let text = txt_height.text, !text.isEmpty {
                } else {
                    if let index = arr_Feet.firstIndex(of: MeasurementData.Height.defaultFeetValue) {
                        self.height_Picker.selectRow(index, inComponent: 0, animated: false)
                    } else {
                        self.height_Picker.selectRow(0, inComponent: 0, animated: false)
                    }
                }
                self.height_Picker.selectRow(1, inComponent: 2, animated: false)
            }
            
            self.addDoneToolBar(textField, pickerview: self.height_Picker, clicked: #selector(pickerHeightDoneClicked))
        }
        else if textField == self.txt_weight {
            selectedHeightType = .balnk
            selectedType = .weightSelection
            if selectedWeightType == .lbs {
                selectedWeightType = .lbs
                self.weight_Picker.reloadAllComponents()
                self.weight_Picker.selectRow(0, inComponent: 1, animated: true)
            } else {
                selectedWeightType = .Kgs
                self.weight_Picker.reloadAllComponents()
                if let text = textField.text, !text.isEmpty {
                } else {
                    if let index = arr_Kgs.firstIndex(of: MeasurementData.weight.defaultKGValue) {
                        self.weight_Picker.selectRow(index, inComponent: 0, animated: false)
                    } else {
                        self.weight_Picker.selectRow(0, inComponent: 0, animated: false)
                    }
                }
                self.weight_Picker.selectRow(1, inComponent: 1, animated: true)
            }
            
            self.addDoneToolBar(textField, pickerview: self.weight_Picker, clicked: #selector(pickerHeightDoneClicked))
        }

        return true
    }
    
    func addDoneToolBar(_ textFild: UITextField, pickerview: UIPickerView, clicked: Selector?) {
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                               UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: clicked)]
        numberToolbar.sizeToFit()
        textFild.inputAccessoryView = numberToolbar
        textFild.inputView = pickerview
    }
    
    @objc func doneDatePicker() {
        self.view.endEditing(true)
    }
    
    @objc func pickerHeightDoneClicked(_ sender: UIBarButtonItem) {
        if selectedType == SelectionType.heightFtIn {
            
            self.txt_height.text = selectedHeightType != SelectionsHeightType.cm ?   arr_Feet[self.height_Picker.selectedRow(inComponent: 0)] + " " + "ft".localized() + " " + arr_Inch[self.height_Picker.selectedRow(inComponent: 1)] + " " + "in".localized() : arr_CM[self.height_Picker.selectedRow(inComponent: 0)] + " " + "cm".localized()

            isHeightInCm = (selectedHeightType == SelectionsHeightType.cm)
            
            Shared.sharedInstance.isInFt = !isHeightInCm

            Shared.sharedInstance.inFt = selectedHeightType != SelectionsHeightType.cm ? arr_Feet[self.height_Picker.selectedRow(inComponent: 0)] : arr_CM[self.height_Picker.selectedRow(inComponent: 0)]
                
            Shared.sharedInstance.inInc = selectedHeightType != SelectionsHeightType.cm ? arr_Inch[self.height_Picker.selectedRow(inComponent: 1)] : ""
                
        } else {
            
            self.txt_weight.text = SelectionWeightType.Kgs.rawValue == arrISelectionWeight[self.weight_Picker.selectedRow(inComponent: 1)] ? arr_Kgs[self.weight_Picker.selectedRow(inComponent: 0)] + " " + "kg".localized() : arr_Lbs[self.weight_Picker.selectedRow(inComponent: 0)] + " " + "lbs".localized()
            
            Shared.sharedInstance.weigh = SelectionWeightType.Kgs.rawValue == arrISelectionWeight[self.weight_Picker.selectedRow(inComponent: 1)] ? arr_Kgs[self.weight_Picker.selectedRow(inComponent: 0)] : arr_Lbs[self.weight_Picker.selectedRow(inComponent: 0)]
            
            
            self.isWeightInPounds = SelectionWeightType.Kgs.rawValue == arrISelectionWeight[self.weight_Picker.selectedRow(inComponent: 1)] ? true : false
            Shared.sharedInstance.isInKg = self.isWeightInPounds
        }
        
        self.view.endEditing(true)
    }
    
    
    
    // MARK: - UIPickerView Delegate Datasource Method
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if selectedType == SelectionType.heightFtIn {
            if selectedHeightType == SelectionsHeightType.cm {
                return 2
            } else {
                return 3
            }
        }
        else if  selectedType == SelectionType.weightSelection {
            return 2
        }
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectedType == SelectionType.heightFtIn {
            if selectedHeightType == SelectionsHeightType.cm {
                if component == 0 {
                    return arr_CM.count
                } else {
                    return arrSelectionsHeight.count
                }
            }
            else {
                if component == 0 {
                    return arr_Feet.count
                } else if component == 1 {
                    return arr_Inch.count
                } else {
                    return arrSelectionsHeight.count
                }
            }
        }
        else {
            if selectedWeightType == SelectionWeightType.Kgs {
                if component == 0 {
                    return arr_Kgs.count
                } else {
                    return arrISelectionWeight.count
                }
            }
            else {
                if component == 0 {
                    return arr_Lbs.count
                } else {
                    return arrISelectionWeight.count
                }
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if selectedType == SelectionType.heightFtIn {
            if selectedHeightType == SelectionsHeightType.cm {
                if component == 0 {
                    return arr_CM[row]
                } else {
                    return arrSelectionsHeight[row]
                }
            }
            else {
                if component == 0 {
                    return arr_Feet[row]
                } else if component == 1 {
                    return arr_Inch[row]
                } else {
                    return arrSelectionsHeight[row]
                }
            }
        }
        else {
            if selectedWeightType == SelectionWeightType.Kgs {
                if component == 0 {
                    return arr_Kgs[row]
                } else  {
                    return arrISelectionWeight[row]
                }
            }
            else {
                if component == 0 {
                    return arr_Lbs[row]
                } else  {
                    return arrISelectionWeight[row]
                }
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if selectedHeightType == SelectionsHeightType.ftin {
            if component == 2 {
                if row == 0 {
                    selectedType = SelectionType.heightFtIn
                    selectedHeightType = SelectionsHeightType.cm
                    self.height_Picker.reloadAllComponents()
                    if self.height_Picker.numberOfComponents >= 1 && self.height_Picker.numberOfRows(inComponent: 1) > 0 {
                        self.height_Picker.selectRow(0, inComponent: 1, animated: false)
                    }
                }
            }
        }
        else if selectedHeightType == SelectionsHeightType.cm {
            if component == 1 {
                if row == 1 {
                    selectedType = SelectionType.heightFtIn
                    selectedHeightType = SelectionsHeightType.ftin
                    self.height_Picker.reloadAllComponents()
                    if self.height_Picker.numberOfComponents >= 2 && self.height_Picker.numberOfRows(inComponent: 2) > 1 {
                        self.height_Picker.selectRow(1, inComponent: 2, animated: false)
                    }
                }
            }
        }
        else if selectedWeightType == SelectionWeightType.Kgs {
            if component == 1 {
                if row == 0 {
                    selectedWeightType = SelectionWeightType.lbs
                    self.weight_Picker.reloadAllComponents()
                }
            }
        }
        else {
            if component == 1 {
                if row == 1 {
                    selectedWeightType = SelectionWeightType.Kgs
                    self.weight_Picker.reloadAllComponents()
                }
            }
        }
    }
}


extension SignUpVC {
    func addEarnHistoryFromServer() {
        let params = ["activity_favorite_id": AyuSeedEarnActivity.onboarding.rawValue, "language_id": Utils.getLanguageId()] as [String : Any]
        ReferPopupViewController.addEarmHistoryFromServer(params: params) { (isSuccess, title, message) in
            print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
            self.hideActivityIndicator()
            if isSuccess {
                Utils.showAlertWithTitleInControllerWithCompletion(title, message: message, okTitle: "Ok", controller: self) {
                    self.showNextScreen()
                }
            } else {
                self.showNextScreen()
            }
        }
    }
    
    func showNextScreen() {
        if let _ = socialLoginUser {
            kSharedAppDelegate.isSocialRegisteredUser = true
            //kSharedAppDelegate.showPersonalizingScreen()
        } else {
            kSharedAppDelegate.isSocialRegisteredUser = false
            //kSharedAppDelegate.showHomeScreen()
        }
        kUserDefaults.set(true, forKey: IS_LOGGEDIN)
        kUserDefaults.set(true, forKey: kIsFirstLaunch)
        let objBalVC = Story_LoginSignup.instantiateViewController(withIdentifier: "DiscoverBalanceVC") as! DiscoverBalanceVC
        self.navigationController?.pushViewController(objBalVC, animated: true)
        
        
        
    }
}

