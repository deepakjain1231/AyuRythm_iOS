//
//  SignUpViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 5/25/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
import SKCountryPicker

class SignUpViewController: BaseViewController,UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIPickerViewAccessibilityDelegate, UITextViewDelegate {
   
    @IBOutlet var name_Text: UITextField?
    @IBOutlet var mobilenum_Text: UITextField?
    @IBOutlet var email_Text: UITextField?
    @IBOutlet var password_Text: UITextField?
    @IBOutlet var confirmpwd_Text: UITextField?
    @IBOutlet var dateofbirth_Text: UITextField?
    @IBOutlet var register_Btn: UIButton?
    @IBOutlet var male_Btn: UIButton?
    @IBOutlet var female_Btn: UIButton?
    @IBOutlet var other_Btn: UIButton?
    @IBOutlet var calendar_Btn: UIButton?
    @IBOutlet var scrollView: UIScrollView?
    
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var txtFieldInches: UITextField!
    @IBOutlet weak var txtFieldHeight: UITextField!
    @IBOutlet weak var scrollBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewHeightPicker: UIView!
    @IBOutlet weak var picker: UIPickerView!

    @IBOutlet weak var viewcountryPicker: UIView!
    @IBOutlet weak var countrypicker: CountryPickerView!

    
    @IBOutlet weak var lblWeightHeading: UILabel!
    @IBOutlet weak var lblInches: UILabel!
    @IBOutlet weak var lblFt: UILabel!
    @IBOutlet weak var viewLine: UIView!
    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet var textView: UITextView?
    @IBOutlet weak var referralCodeView: ARReferralCodeView!
    @IBOutlet weak var viewEnterMobileNumber: UIView!
    @IBOutlet weak var viewEnterMobileNumberTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var appleHealthButton: UIButton!

    @IBOutlet weak var lblKgs: UILabel!
    var mobileNumber = ""
    
    var arrFt = MeasurementData.Height.feetValues
    var arrInch = MeasurementData.Height.inchValues
    var arrcm = MeasurementData.Height.cmValues
    
    var arrkgs = MeasurementData.weight.kgValues
    var arrlbs = MeasurementData.weight.poundValues
    let arrSelectionHeight = ["Imperial","Metric"]
    let arrSelectionsHeight = ["cm","ft in"]
    let arrISelectionWeight = ["lbs", "Kgs"]

    var selectedType: SelectionType = .heightFtIn
    var isHeightInCm = false
    var isWeightInPounds = false
    @IBOutlet weak var viewFemale: UIView!
    @IBOutlet weak var viewMale: UIView!

    var selectedHeightType: SelectionsHeightType = .ftin
    var selectedWeightType: SelectionWeightType = .Kgs

    var ftString = ""
    var inchString = ""
    var cmString = ""
    var weightString = ""

    var countryCodes = "+91"
    var countryName = "India"
    var socialLoginUser: SocialLoginUser?
    let healthStore = HealthKitManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributedString = NSMutableAttributedString(string: "By proceeding with registration, login and using our app, you agree to our Terms and Conditions and Privacy Policy.".localized(), attributes: [
              .font: UIFont.systemFont(ofSize: 17.0, weight: .regular),
              .foregroundColor: UIColor.black,
              .kern: -0.41
            ])
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: Utils.isAppInHindiLanguage ? NSRange(location: 73, length: 16) : NSRange(location: 75, length: 20))
            attributedString.addAttribute(.foregroundColor, value: kAppColorGreen, range: Utils.isAppInHindiLanguage ? NSRange(location: 94, length: 13) : NSRange(location: 100, length: 14))
        
            attributedString.addAttribute(.link, value: kTermsAndCondition, range: Utils.isAppInHindiLanguage ? NSRange(location: 73, length: 16) : NSRange(location: 75, length: 20))
            attributedString.addAttribute(.link, value: kPrivacyPolicy, range: Utils.isAppInHindiLanguage ? NSRange(location: 94, length: 13) : NSRange(location: 100, length: 14))
        
        textView?.attributedText = attributedString
        textView?.delegate = self
        
        // Do any additional setup after loading the view.
       // NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
       //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        self.viewPicker.isHidden = true
        self.viewcountryPicker.isHidden = true

        viewMale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
        viewFemale.backgroundColor = .white
        viewFemale.layer.borderWidth = 0.5
        viewFemale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
        viewFemale.clipsToBounds = true
        male_Btn?.isSelected = true
        mobilenum_Text?.text = mobileNumber
       // TEMPFIX
        self.viewHeightPicker.isHidden = true

        self.displaySharedStoredData()
       // self.hideKeyboardWhenTappedAround()
       //self.addDoneButtonOnKeyboard()
        //datePicker.maximumDate = Date()
        let min12YearDate = Calendar.current.date(byAdding: .year, value: -12, to: Date())
        datePicker.maximumDate = min12YearDate
        self.countryPickerCallback()
        referralCodeView.presentingVC = self
        referralCodeView.updateUIForReferralCode(code: Shared.sharedInstance.referralCode)
        
        appleHealthButton.layer.borderWidth = 2
        appleHealthButton.layer.borderColor = UIColor(red: 62/255, green: 139/255, blue: 58/255, alpha: 1.0).cgColor
        if let socialLoginUser = socialLoginUser {
            name_Text?.text = socialLoginUser.name ?? ""
            email_Text?.text = socialLoginUser.email ?? ""
            mobilenum_Text?.text = socialLoginUser.phoneNumber ?? ""
            //if socialLoginUser.type == .apple {
                viewEnterMobileNumber.isHidden = true
                viewEnterMobileNumberTopConstraint.constant = -50
                self.view.layoutIfNeeded()
            //}
            appleHealthButton.isHidden = false
        }
        
        if #available(iOS 14.0, *) {
            datePicker.tintColor = .black
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        self.privacyPolicyy()
    }
    
    func privacyPolicyy() {
        let objDialouge = PrivacyNewUserVC(nibName:"PrivacyNewUserVC", bundle:nil)
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView?.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func countryPickerButtonClicked(_ sender: UIButton) {
        self.viewcountryPicker.isHidden = false
        self.viewHeightPicker.isHidden = true
        self.viewPicker.isHidden = true
        self.view.endEditing(true)
    }
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
           UIApplication.shared.open(URL)
           return false
    }
    
    func countryPickerCallback()
    {
        countrypicker.onSelectCountry { [weak self] (country) in
            guard let self = self,
                let digitCountrycode = country.digitCountrycode else {
                return
            }
            self.countryCodes = "+\(digitCountrycode)"
            self.countryName = country.countryName
            self.countryButton.setTitle("+\(digitCountrycode)", for: .normal)
        }
    }
    
    @IBAction func pickerCountryDoneClicked(_ sender: UIBarButtonItem)
    {
        self.viewcountryPicker.isHidden = true
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
    
    
    @IBAction func register_Action(sender: UIButton) {
        
        if self.countryCodes == "+91" && socialLoginUser == nil {
            if mobilenum_Text?.text?.count != 10 {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter 10 digits mobile number.".localized(), controller: self)
                return;
            }
        }
        
        if name_Text?.text?.isEmpty ?? true {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter username.".localized(), controller: self)
        }
        else if (mobilenum_Text?.text?.isEmpty ?? true) && socialLoginUser == nil {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter valid mobile number.".localized(), controller: self)
        } else if email_Text?.text?.isEmpty ?? true {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter email.".localized(), controller: self)
        }
        else if dateofbirth_Text?.text?.isEmpty ?? true {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter date of birth.".localized(), controller: self)
        } else if male_Btn?.isSelected == false && female_Btn?.isSelected == false {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please select gender.".localized(), controller: self)
        }
        else if !Utils.isValidEmail(testStr: (email_Text?.text ?? "")) {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter valid email.".localized(), controller: self)
        } else {
            signUpFromServer()
        }
    }
    
    @IBAction func pickerWeightSelectPreferredUnitClicked(_ sender: UIButton) {
        selectedType = SelectionType.weightSelection
        self.viewHeightPicker.isHidden = false
        self.view.endEditing(true)
        self.viewPicker.isHidden = true
        self.viewcountryPicker.isHidden = true
        self.picker.reloadAllComponents()
    }
    
    @IBAction func pickerHeightSelectPreferred(_ sender: UIButton) {
        selectedType = SelectionType.heightSelection
        self.viewHeightPicker.isHidden = false
        self.view.endEditing(true)
        self.viewPicker.isHidden = true
        self.viewcountryPicker.isHidden = true

        self.picker.reloadAllComponents()
    }
    
    @IBAction func heightSegmentChanged(_ sender: UISwitch) {
        if sender.isOn {
            lblInches.isHidden = false
            self.txtFieldInches.isHidden = false
            self.lblFt.text = "Ft".localized()
            self.txtFieldHeight.text = ""
            self.txtFieldInches.text = ""

        } else {
            lblInches.isHidden = true
            self.txtFieldInches.isHidden = true
            self.lblFt.text = "Cm".localized()
            self.txtFieldHeight.text = ""
        }
    }
    
    @IBAction func weightSegmentChanged(_ sender: UISwitch) {
        if sender.isOn  {
            self.lblWeightHeading.text = "Weight".localized()
            self.isWeightInPounds = true
            self.lblKgs.text = "Lbs".localized()
        } else {
            self.lblWeightHeading.text = "Weight".localized()
            self.isWeightInPounds = false
            self.lblKgs.text = "Kgs".localized()

        }
    }
    
    @IBAction func back_Action(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pickerDoneClicked(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateofbirth_Text?.text = dateFormatter.string(from: self.datePicker.date)
        self.viewPicker.isHidden = true
        self.viewcountryPicker.isHidden = true

    }
    
    @IBAction func pickerHeightDoneClicked(_ sender: UIBarButtonItem) {
        if selectedType == SelectionType.heightFtIn {
            
            self.txtFieldHeight.text = selectedHeightType != SelectionsHeightType.cm ?   arrFt[self.picker.selectedRow(inComponent: 0)] + " " + "ft".localized() + " " + arrInch[self.picker.selectedRow(inComponent: 1)] + " " + "in".localized() : arrcm[self.picker.selectedRow(inComponent: 0)] + " " + "cm".localized()

            
            isHeightInCm = (selectedHeightType == SelectionsHeightType.cm)
            
            Shared.sharedInstance.isInFt = !isHeightInCm

            Shared.sharedInstance.inFt = selectedHeightType != SelectionsHeightType.cm ? arrFt[self.picker.selectedRow(inComponent: 0)] : arrcm[self.picker.selectedRow(inComponent: 0)]
                
            Shared.sharedInstance.inInc = selectedHeightType != SelectionsHeightType.cm ? arrInch[self.picker.selectedRow(inComponent: 1)] : ""
                
        } else if selectedType == SelectionType.heightSelection {
            if self.picker.selectedRow(inComponent: 0) == 0 {
                lblInches.isHidden = false
                self.txtFieldInches.isHidden = false
                self.lblFt.text = "Ft".localized()
            } else {
                lblInches.isHidden = true
                self.txtFieldInches.isHidden = true
                self.lblFt.text = "Cm".localized()
            }
        } else {
            
            self.txtWeight.text = SelectionWeightType.Kgs.rawValue == arrISelectionWeight[self.picker.selectedRow(inComponent: 1)] ? arrkgs[self.picker.selectedRow(inComponent: 0)] + " " + "kg".localized() : arrlbs[self.picker.selectedRow(inComponent: 0)] + " " + "lbs".localized()
            
            Shared.sharedInstance.weigh = SelectionWeightType.Kgs.rawValue == arrISelectionWeight[self.picker.selectedRow(inComponent: 1)] ? arrkgs[self.picker.selectedRow(inComponent: 0)] : arrlbs[self.picker.selectedRow(inComponent: 0)]
            
            
            self.isWeightInPounds = SelectionWeightType.Kgs.rawValue == arrISelectionWeight[self.picker.selectedRow(inComponent: 1)] ? true : false
            Shared.sharedInstance.isInKg = self.isWeightInPounds
        }
        
        self.viewHeightPicker.isHidden = true
    }
    
     
    @IBAction func btnHIdeShowNew(_ sender: UIButton) {
        if (self.confirmpwd_Text?.isSecureTextEntry == true)
        {
            self.confirmpwd_Text?.isSecureTextEntry = false;
            sender.setImage(UIImage(named: "imageShow"), for: .normal)

        }
        else
        {
            self.confirmpwd_Text?.isSecureTextEntry = true;
            sender.setImage(UIImage(named: "imageHide"), for: .normal)

        }
    }

    @IBAction func btnHIdeShow(_ sender: UIButton) {
           if (self.password_Text?.isSecureTextEntry == true)
           {
               self.password_Text?.isSecureTextEntry = false;
               sender.setImage(UIImage(named: "imageShow"), for: .normal)

           }
           else
           {
               self.password_Text?.isSecureTextEntry = true;
               sender.setImage(UIImage(named: "imageHide"), for: .normal)

           }
       }
    
    @IBAction func infoButtonClicked(_ sender: UIButton)
    {
        self.view.endEditing(true)
        self.viewPicker.isHidden = true
        self.viewcountryPicker.isHidden = true
        Utils.showAlertWithTitleInController(Date_Of_BirthTitle, message: DateOfBirthDescription, controller: self)
    }

    @IBAction func UpdateDOBClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.viewPicker.isHidden = false
        self.viewcountryPicker.isHidden = true
    }
    
    @IBAction func radio_btn(sender: UIButton) {
        
                if (male_Btn?.isSelected == false)
                {
                    male_Btn?.isSelected = true;
                    female_Btn?.isSelected = false;
                    viewMale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
                    viewMale.layer.borderColor = UIColor.white.cgColor
                    viewFemale.backgroundColor = .white
                    viewFemale.layer.borderWidth = 0.5
                    viewFemale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
                    viewFemale.clipsToBounds = true
                }
                else {
                    female_Btn?.isSelected = true;
                    male_Btn?.isSelected = false;
                    viewFemale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
                    viewFemale.layer.borderColor = UIColor.white.cgColor
                    viewMale.backgroundColor = .white
                    viewMale.layer.borderWidth = 0.5
                    viewMale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
                    viewMale.clipsToBounds = true
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
    
    @IBAction func healthkitButtonClicked(_ sender: UIButton) {
        healthStore.checkAuthorizationStatusAndGetHealthParameters(fromVC: self) { heightInCmString, weightInKgsString, dob, gender in
            
            if let heightInCmString = heightInCmString {
                self.cmString = heightInCmString
                self.selectedType = SelectionType.heightFtIn
                self.selectedHeightType = SelectionsHeightType.cm
                self.txtFieldHeight.text = self.cmString + " " + "cm".localized()
                self.isHeightInCm = true
                Shared.sharedInstance.inFt = self.cmString
            }
            
            if let weightInKgsString = weightInKgsString {
                self.isWeightInPounds = true
                self.weightString = weightInKgsString
                self.txtWeight.text = self.weightString + " Kgs"
                self.selectedType = SelectionType.weightSelection
                self.selectedWeightType = SelectionWeightType.Kgs
                Shared.sharedInstance.weigh = self.weightString
            }
            
            if let dob = dob {
                self.dateofbirth_Text?.text = dob
            }
            
            if gender == "Female" {
                //Gender Female
                self.viewFemale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
                self.viewFemale.layer.borderColor = UIColor.white.cgColor
                self.viewMale.backgroundColor = .white
                self.viewMale.layer.borderWidth = 0.5
                self.viewMale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
                self.viewMale.clipsToBounds = true
                self.female_Btn?.isSelected = true;
                self.male_Btn?.isSelected = false;
            } else {
                //Gender Male
                self.male_Btn?.isSelected = true;
                self.female_Btn?.isSelected = false;
                self.viewMale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
                self.viewMale.layer.borderColor = UIColor.white.cgColor
                self.self.viewFemale.backgroundColor = .white
                self.viewFemale.layer.borderWidth = 0.5
                self.viewFemale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
                self.viewFemale.clipsToBounds = true
            }
            self.picker.reloadAllComponents()
        }
        return
        
        /*Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        healthStore.checkAuthorization { (issuccess) in
            if issuccess {
                DispatchQueue.main.async(execute: {
                    self.healthStore.healthHeight { (height) in
                        //Height
                        self.cmString = String(height.dropLast(1)) == "m" ? "\(Int(String(height.dropLast(3)))! * 100)":  String(height.dropLast(1)) == "ft" ? "\(Double(String(height.dropLast(3)))! * 30.48)" : String(height.dropLast(3))
                        self.selectedType = SelectionType.heightFtIn
                        self.selectedHeightType = SelectionsHeightType.cm
                        self.txtFieldHeight.text = self.cmString + " " + "cm".localized()
                        self.isHeightInCm = true
                        Shared.sharedInstance.inFt = self.cmString
                    }
                    self.healthStore.healthWeight { (weight) in
                        //Weight
                        self.isWeightInPounds = true
                        let lbsString = String(weight.dropLast(3))
                        let stString = String(weight.dropLast(2))
                        self.weightString = lbsString == "lbs" ? Utils.convertPoundsToKg(lb: String(weight.dropLast(4))) : stString == "st" ? "\(Double(String(weight.dropLast(3)))! * 6.35029)" : String(weight.dropLast(3))
                        self.txtWeight.text = self.weightString + " Kgs"
                        self.selectedType = SelectionType.weightSelection
                        self.selectedWeightType = SelectionWeightType.Kgs
                        Shared.sharedInstance.weigh = self.weightString
                    }
                    
                    // DateOfBirth
                    self.healthStore.healthDateOfBirth { (dateOfBirth) in
                        self.dateofbirth_Text?.text = dateOfBirth
                    }
                    
                    if self.healthStore.healthGender() == "Female" {
                        //Gender Female
                        self.viewFemale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
                        self.viewFemale.layer.borderColor = UIColor.white.cgColor
                        self.viewMale.backgroundColor = .white
                        self.viewMale.layer.borderWidth = 0.5
                        self.viewMale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
                        self.viewMale.clipsToBounds = true
                        self.female_Btn?.isSelected = true;
                        self.male_Btn?.isSelected = false;
                    } else {
                        //Gender Male
                        self.male_Btn?.isSelected = true;
                        self.female_Btn?.isSelected = false;
                        self.viewMale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
                        self.viewMale.layer.borderColor = UIColor.white.cgColor
                        self.self.viewFemale.backgroundColor = .white
                        self.viewFemale.layer.borderWidth = 0.5
                        self.viewFemale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
                        self.viewFemale.clipsToBounds = true
                    }
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        }*/
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
        
        self.txtWeight.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.txtWeight.resignFirstResponder()
        
    }
    
    func displaySharedStoredData() {
        
        self.name_Text?.text = Shared.sharedInstance.name
        self.dateofbirth_Text?.text = Shared.sharedInstance.dob
        self.isHeightInCm = Shared.sharedInstance.isInFt
        self.isWeightInPounds = Shared.sharedInstance.isInKg
        
        if !Shared.sharedInstance.weigh.isEmpty {
            self.txtWeight.text = self.isWeightInPounds == true ? Shared.sharedInstance.weigh + " " + "kg".localized() : Shared.sharedInstance.weigh + " " + "lbs".localized()
        }
        
        
        if !Shared.sharedInstance.inFt.isEmpty || !Shared.sharedInstance.inInc.isEmpty {
            self.txtFieldHeight.text = self.isHeightInCm == false ?  Shared.sharedInstance.inFt + " " + "cm".localized() : Shared.sharedInstance.inFt + " " + "ft".localized() + " " + Shared.sharedInstance.inInc + " " + "in".localized()
        }
        
        if Shared.sharedInstance.isMale {
            male_Btn?.isSelected = true;
            
            viewMale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
            viewMale.layer.borderColor = UIColor.white.cgColor
            viewFemale.backgroundColor = .white
            viewFemale.layer.borderWidth = 0.5
            viewFemale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
            viewFemale.clipsToBounds = true

            female_Btn?.isSelected = false;
        } else {
            female_Btn?.isSelected = true;
            male_Btn?.isSelected = false;
            
            viewFemale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
            viewFemale.layer.borderColor = UIColor.white.cgColor

            viewMale.backgroundColor = .white
            viewMale.layer.borderWidth = 0.5
            viewMale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
            viewMale.clipsToBounds = true

        }
        
        if self.isWeightInPounds {
        } else {
        }
        
//        if !self.isHeightInCm {
//            self.isHeightInCm = false
//        } else {
//            self.isHeightInCm = true
//        }
        
        referralCodeView.updateUIForReferralCode(code: Shared.sharedInstance.referralCode)
    }
    
}

extension SignUpViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        if selectedType == SelectionType.heightFtIn
        {
             if selectedHeightType == SelectionsHeightType.cm
            {
                return 2
            }
             else
             {
            return 3
            }
        }
        else if  selectedType == SelectionType.weightSelection
        {
            return 2

        }
        return 1

    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if selectedType == SelectionType.heightFtIn {
            if selectedHeightType == SelectionsHeightType.cm
            {
                if component == 0
                {
                    return arrcm.count
                }
                else
                {
                    return arrSelectionsHeight.count
                }
            }
            else
            {
                if component == 0
                {
                    return arrFt.count
                    
                } else if component == 1
                {
                    return arrInch.count
                }
                else
                {
                    return arrSelectionsHeight.count
                }
            }
        }
    
        else {
            if selectedWeightType == SelectionWeightType.Kgs
            {
                if component == 0 {
                    return arrkgs.count
                } else
                {
                    return arrISelectionWeight.count
                }
            }
            else
            {
                if component == 0 {
                    return arrlbs.count
                } else
                {
                    return arrISelectionWeight.count
                }
            }
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        
        if selectedType == SelectionType.heightFtIn {
            if selectedHeightType == SelectionsHeightType.cm
            {
                if component == 0
                {
                    return arrcm[row]
                }
                else
                {
                    return arrSelectionsHeight[row]
                }
            }
            else
            {
                
                if component == 0 {
                    return arrFt[row]
                } else if component == 1 {
                    return arrInch[row]
                }
                else
                {
                    return arrSelectionsHeight[row]
                }
            }
        }

        else {
            if selectedWeightType == SelectionWeightType.Kgs
            {
                
                if component == 0 {
                    return arrkgs[row]
                } else  {
                    return arrISelectionWeight[row]
                }
            }
            else
            {
                if component == 0 {
                    return arrlbs[row]
                } else  {
                    return arrISelectionWeight[row]
                }
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if selectedHeightType == SelectionsHeightType.ftin
        {
            if component == 2
            {
                if row == 0
                {
                    selectedType = SelectionType.heightFtIn
                    selectedHeightType = SelectionsHeightType.cm
                    picker.reloadAllComponents()
                    if picker.numberOfComponents >= 1 && picker.numberOfRows(inComponent: 1) > 0 {
                        picker.selectRow(0, inComponent: 1, animated: false)
                    }
                    
                }
            }
        }
        else if selectedHeightType == SelectionsHeightType.cm
        {
            if component == 1
            {
                if row == 1
                {
                    selectedType = SelectionType.heightFtIn
                    selectedHeightType = SelectionsHeightType.ftin
                    picker.reloadAllComponents()
                    if picker.numberOfComponents >= 2 && picker.numberOfRows(inComponent: 2) > 1 {
                        picker.selectRow(1, inComponent: 2, animated: false)
                    }
                    
                    
                }
            }
        }
        else if selectedWeightType == SelectionWeightType.Kgs
        {
            if component == 1
            {
                if row == 0
                {
                    selectedWeightType = SelectionWeightType.lbs
                    picker.reloadAllComponents()

                }
            }
        }
        else
        {
            if component == 1
            {
                if row == 1
                {
                    selectedWeightType = SelectionWeightType.Kgs
                    picker.reloadAllComponents()

                }
            }

        }
    }
}

extension SignUpViewController {
    func signUpFromServer() {
        if Utils.isConnectedToNetwork() {
            
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

            let isMale = (male_Btn?.isSelected)! ? "Male" : "Female"
            var params = ["user_name": name_Text?.text ?? "", "user_mobile": mobilenum_Text?.text ?? "", "user_email": email_Text?.text ?? "", "user_gender": isMale,"user_dob":dateofbirth_Text?.text ?? "","user_measurements": userMeasurements,"fcm":fcm_Token,"type": DEVICE_TYPE,"deviceid":deviceid_TOKEN, "countrycode": self.countryCodes, "country": self.countryName, "login_type": ARLoginType.normal.rawValue] as [String : Any]
            
            if let referralCode = referralCodeView.referralCode {
                params["referral_code"] = referralCode
            }
            // If county code = 91 show OTP screen otherwise not
//            if self.countryCodes == "91"
//            {
            if let socialLoginUser = socialLoginUser {
                params["social_type"] = socialLoginUser.type.rawValue
                params["social_id"] = socialLoginUser.socialID
                signUpFromServer(params: params)
            } else {
                let objView:OTPViewController = Story_Main.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
                objView.phoneNumber = self.mobilenum_Text?.text ?? ""
                objView.countryCode = self.countryCodes
                objView.isFromSignUp = true
                objView.signUpParasm = params
                self.navigationController?.pushViewController(objView, animated: true)
            }
//            }
//            else
//            {
//                self.signUpFromServer(params: params)
//            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
}

extension SignUpViewController {
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
//
//    func uploadGuestUserDataOnServer(userId: String) {
//        if Utils.isConnectedToNetwork() {
//            let strPrashna = Utils.getPrakritiValue()
//            let resultP = strPrashna.isEmpty ? "" : "[" + strPrashna + "]"
//
//            let strVikrti = Utils.getVikritiValue()
//            let resultV = strVikrti.isEmpty ? "" : "[" + strVikrti + "]"
//
//            let isSparshnaTestGiven = kUserDefaults.bool(forKey: kVikritiSparshanaCompleted)
//            let isPrashnaTestGiven = kUserDefaults.bool(forKey: kVikritiPrashnaCompleted)
//
//            let params = ["prashna_prakriti" : resultP, "sparshna": resultV, "user_ffs": "", "user_ppf": "", "user_sparshna": "", "graph_params": "" , "user_id": userId,  "user_vikriti": resultV, "vikriti_prashna": (isPrashnaTestGiven ? "true" : "false"), "vikriti_sprashna": (isSparshnaTestGiven ? "true" : "false")]
//
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.usergraphspar.rawValue
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON  { response in
//
//                DispatchQueue.main.async(execute: {
//                    Utils.stopActivityIndicatorinView(self.view)
//                })
//                switch response.result {
//
//                case .success(let value):
//                    print(response)
//                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
//                        return
//                    }
//                    if dicResponse["status"] as? String ?? "" == "Sucess" {
//                        if kUserDefaults.value(forKey: kUserMeasurementData) != nil
//                        {
//                            self.uploadMeasumentDataOnServer(userId: userId)
//
//                        } else {
////                            let objView:SignUpSuccessViewController = Story_Main.instantiateViewController(withIdentifier: "SignUpSuccessViewController") as! SignUpSuccessViewController
////                            self.navigationController?.pushViewController(objView, animated: true)
//                            kUserDefaults.set(true, forKey: kIsFirstLaunch)
//                            kSharedAppDelegate.showHomeScreen()
//                        }
//                    } else {
//                        Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["Message"] as? String ?? "Failed to register user"), controller: self)
//                    }
//
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//            }
//        }else {
//            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
//        }
//    }
//
//    func uploadMeasumentDataOnServer(userId: String) {
//        if Utils.isConnectedToNetwork() {
//
//            //REGISTERED USER
//           // let urlString = kBaseURL + "user_data_collection/docpatientdata.php"
//            let urlString = kBaseNewURL + endPoint.savesparshnatest.rawValue
//
//            var params = kUserDefaults.value(forKey: kUserMeasurementData) as? [String: Any]
//
//            params?["user_duid"] = userId
//
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).responseJSON  { response in
//
//                Utils.stopActivityIndicatorinView(self.view)
//                switch response.result {
//
//                case .success(let value):
//                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
//                        return
//                    }
//
//                    if dicResponse["status"] as? String ?? "" == "Sucess" {
//                        kUserDefaults.set(true, forKey: kIsFirstLaunch)
//                        kSharedAppDelegate.showHomeScreen()
//                    } else {
//                        Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["Message"] as? String ?? "Failed to register user"), controller: self)
//                    }
//
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//            }
//        } else {
//            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
//        }
//    }
}

extension SignUpViewController:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.scrollView?.scrollRectToVisible(CGRect(x: textField.frame.origin.x, y: textField.frame.origin.y, width: textField.frame.size.width, height: textField.frame.size.height + 50), animated: true)
        
        referralCodeView.textFieldDidBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        referralCodeView.textFieldDidEndEditing(textField)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if txtFieldInches == textField || textField == txtFieldHeight {
            if self.isHeightInCm {
                self.view.endEditing(true)
                self.viewHeightPicker.isHidden = false
                selectedType = .heightFtIn
                self.picker.reloadAllComponents()
                selectedWeightType = .balnk
                selectedHeightType = .cm
                picker.selectRow(0, inComponent: 1, animated: false)
                return false
            } else {
                self.view.endEditing(true)
                self.viewHeightPicker.isHidden = false
                selectedType = .heightFtIn
                self.picker.reloadAllComponents()
                selectedWeightType = .balnk
                selectedHeightType = .ftin
                if let text = txtFieldHeight.text, !text.isEmpty {
                    //picker.selectRow(0, inComponent: 0, animated: false)
                } else {
                    if let index = arrFt.firstIndex(of: MeasurementData.Height.defaultFeetValue) {
                        picker.selectRow(index, inComponent: 0, animated: false)
                    } else {
                        picker.selectRow(0, inComponent: 0, animated: false)
                    }
                }
                picker.selectRow(1, inComponent: 2, animated: false)
                
                return false
            }
        } else if textField == txtWeight {
            selectedHeightType = .balnk
            self.view.endEditing(true)
            
            self.viewHeightPicker.isHidden = false
            selectedType = .weightSelection
            
            if selectedWeightType == .lbs {
                selectedWeightType = .lbs
                self.picker.reloadAllComponents()
                picker.selectRow(0, inComponent: 1, animated: true)
            } else {
                selectedWeightType = .Kgs
                self.picker.reloadAllComponents()
                if let text = textField.text, !text.isEmpty {
                    //picker.selectRow(0, inComponent: 0, animated: false)
                } else {
                    if let index = arrkgs.firstIndex(of: MeasurementData.weight.defaultKGValue) {
                        picker.selectRow(index, inComponent: 0, animated: false)
                    } else {
                        picker.selectRow(0, inComponent: 0, animated: false)
                    }
                }
                picker.selectRow(1, inComponent: 1, animated: true)
            }
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
        case self.mobilenum_Text:
            return true
            /*let textProspectiveText = prospectiveText.filter { !$0.isNewline && !$0.isWhitespace }
            return textProspectiveText.count <= 12*/
            
        default:
            return true
        }
    }
}

extension SignUpViewController {
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
            kSharedAppDelegate.showPersonalizingScreen()
        } else {
            kSharedAppDelegate.isSocialRegisteredUser = false
            kSharedAppDelegate.showHomeScreen()
        }
    }
}

