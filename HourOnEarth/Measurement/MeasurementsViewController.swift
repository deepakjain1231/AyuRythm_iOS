//
//  MeasurementsViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 29/05/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import HealthKit

enum MeasurementData {
    enum Height {
        static let feetValues = ["3","4","5","6","7","8"]
        static let inchValues = ["0","1","2","3","4","5","6","7","8","9","10","11"]
        static let cmValues = (90...240).map(String.init)
        static let defaultFeetValue = "5"
    }
    
    enum weight {
        static let kgValues = (30...150).map(String.init)
        static let poundValues = (66...330).map(String.init)
        static let defaultKGValue = "55"
    }
}

class MeasurementsViewController: UIViewController, UITextFieldDelegate , UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var txtFieldWeight: UITextField!
    @IBOutlet weak var txtFieldHeight: UITextField!
    @IBOutlet weak var txtFieldUserName: UITextField!
    @IBOutlet weak var viewUserName: UIView!
    @IBOutlet weak var viewUserNameHeightConst: NSLayoutConstraint!
    
    @IBOutlet var scrollView: UIScrollView?
    @IBOutlet weak var scrollBottomConstraint: NSLayoutConstraint!
    @IBOutlet var dateofbirth_Text: UITextField?

    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewHeightPicker: UIView!
    @IBOutlet weak var picker: UIPickerView!

    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet var textView: UITextView?
    @IBOutlet weak var viewFemale: UIView!
    @IBOutlet weak var viewMale: UIView!
    
    var isFromTryAsGuest = false
    var selectedType: SelectionType = .heightFtIn
    var isHeightInCm = false
    var isWeightInPounds = false
    var arrFt = MeasurementData.Height.feetValues
    var arrInch = MeasurementData.Height.inchValues
    var arrcm = MeasurementData.Height.cmValues
    
    var arrkgs = MeasurementData.weight.kgValues
    var arrlbs = MeasurementData.weight.poundValues
    
    let arrSelectionsHeight = ["cm","ft in"]
    let arrISelectionWeight = ["lbs", "Kgs"]
    let arrSelectionHeight = ["Imperial","Metric"]
    let arrSelectionAge = ["month year"]
    var strDateOfBirth = ""
    var heightInCms = 0.0
    
    var selectedHeightType: SelectionsHeightType = .ftin
    var selectedWeightType: SelectionWeightType = .Kgs
    var selectionsageType: SelectionsageType = .month

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnContinue: RoundedButton!
    
    var ftString = ""
    var inchString = ""
    var cmString = ""
    var weightString = ""
    let healthStore = HealthKitManager()

    @IBOutlet weak var btnHealthKit: UIButton!
    @IBOutlet weak var referralCodeView: ARReferralCodeView!
    
    var arrmonth = [String]()
    var arryear = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arrmonth = []
        for i in 0 ... 11 {
            arrmonth.append("\(i)")
        }

        arryear = []
        for i in 10 ... 100 {
            arryear.append("\(i)")
        }

        self.configureView()
        viewPicker.isHidden = true
        self.isHeightInCm = false

        //self.agePicker.delegate = self
        //self.agePicker.dataSource = self
        
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
        self.btnHealthKit.layer.borderWidth = 2
        self.btnHealthKit.layer.borderColor = UIColor(red: 62/255, green: 139/255, blue: 58/255, alpha: 1.0).cgColor
        // Do any additional setup after loading the view.
       // NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
      //  NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
       // self.hideKeyboardWhenTappedAround()
        self.viewHeightPicker.isHidden = true
       // datePicker.maximumDate = Date()
        let min12YearDate = Calendar.current.date(byAdding: .year, value: -12, to: Date())
        datePicker.maximumDate = min12YearDate
        //btnMale.backgroundColor = UIColor().hexStringToUIColor(hex: "#6CC068")
        viewMale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
        viewFemale.backgroundColor = .white
        viewFemale.layer.borderWidth = 0.5
        viewFemale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
        viewFemale.clipsToBounds = true
        btnMale.isSelected = true
//        lblMale.textColor = kAppColorGreen
//        lblFemale.textColor = UIColor.lightGray
        picker.selectRow(1, inComponent: 2, animated: true)
        //agePicker.selectRow(1, inComponent: 2, animated: true)

        //addDoneButtonOnKeyboard()
        // Do any additional setup after loading the view.
        referralCodeView.presentingVC = self
        referralCodeView.updateUIForReferralCode(code: Shared.sharedInstance.referralCode)
        
        if #available(iOS 14.0, *) {
            datePicker.tintColor = .black
            datePicker.preferredDatePickerStyle = .wheels
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
              UIApplication.shared.open(URL)
              return false
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView?.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        //scrollView?.contentOffset = CGPoint(x:0, y:keyboardFrame.size.height-150)
        
        self.scrollBottomConstraint.constant = keyboardFrame.size.height - 45.0
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        //scrollView?.contentOffset = .zero
        self.scrollBottomConstraint.constant = 0.0
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pickerDoneClicked(_ sender: Any) {
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "dd-MM-yyyy"
       dateofbirth_Text?.text = dateFormatter.string(from: self.datePicker.date)
       self.viewPicker.isHidden = true
//        dateofbirth_Text?.text = arrmonth[self.agePicker.selectedRow(inComponent: 0)] + " Month " + arryear[self.agePicker.selectedRow(inComponent: 1)] + " Year"
//        let date = Date()
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.year, .month, .day], from: date)
//
//        let currentDate : Date()
//        let strDate : String = "\(components.day!)-"
//        self.strDateOfBirth = strDate + arrmonth[self.agePicker.selectedRow(inComponent: 0)] + "-" + arryear[self.agePicker.selectedRow(inComponent: 1)]
//
//        print("self.strDateOfBirth=",self.strDateOfBirth)
//        self.viewPicker.isHidden = true
    }
    
    @IBAction func UpdateDOBClick(_ sender: UIButton) {
//        selectedType = SelectionType.age
//        selectedHeightType = SelectionsHeightType.balnk
//        self.view.endEditing(true)
//        self.viewHeightPicker.isHidden = true
//        self.viewPicker.isHidden = false
//        agePicker.reloadAllComponents()

        self.view.endEditing(true)
        self.viewPicker.isHidden = false

    }
    
    @IBAction func infoButtonClicked(_ sender: UIButton)
    {
        self.view.endEditing(true)
        self.viewPicker.isHidden = true
        Utils.showAlertWithTitleInController(Date_Of_BirthTitle, message: DateOfBirthDescription, controller: self)
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        let objLoginView: LoginViewController = Story_LoginSignup.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(objLoginView, animated: true)
    }
    
    @IBAction func radio_btn(sender: UIButton) {
        

        if (btnMale.isSelected == false) {

            btnMale.isSelected = true;

            btnFemale.isSelected = false;
            
            viewMale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
            viewMale.layer.borderColor = UIColor.white.cgColor
            viewFemale.backgroundColor = .white
            viewFemale.layer.borderWidth = 0.5
            viewFemale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
            viewFemale.clipsToBounds = true


        }
        else  {
            
            viewFemale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
            viewFemale.layer.borderColor = UIColor.white.cgColor

            viewMale.backgroundColor = .white
            viewMale.layer.borderWidth = 0.5
            viewMale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
            viewMale.clipsToBounds = true

            btnFemale.isSelected = true;

            btnMale.isSelected = false;

        }
    }
    
    @IBAction func pickerWeightSelectPreferredUnitClicked(_ sender: UIButton) {
        selectedType = SelectionType.weightSelection
        self.viewHeightPicker.isHidden = false
        self.view.endEditing(true)
        self.viewPicker.isHidden = true
        self.picker.reloadAllComponents()
    }
    
    @IBAction func pickerHeightSelectPreferred(_ sender: UIButton) {
        self.view.endEditing(true)
        selectedType = SelectionType.heightSelection
        self.viewHeightPicker.isHidden = false
        self.viewPicker.isHidden = true
        self.picker.reloadAllComponents()
    }
    
//    @IBAction func heightSegmentChanged(_ sender: UISwitch) {
//        if !sender.isOn {
//            //in ft
//            lblInches.isHidden = false
//            self.txtFieldInches.isHidden = false
//            self.lblFt.text = "Ft"
//            self.isHeightInCm = false
//            self.txtFieldHeight.text = ""
//            self.txtFieldInches.text = ""
//        } else {
//            lblInches.isHidden = true
//            self.txtFieldInches.isHidden = true
//            self.lblFt.text = "Cm"
//            self.isHeightInCm = true
//            self.txtFieldHeight.text = ""
//            }
//    }
//
//    @IBAction func weightSegmentChanged(_ sender: UISwitch) {
//        if sender.isOn {
//            self.lblWeightHeading.text = "Weight"
//            self.isWeightInPounds = true
//            self.lblLbs.text = "Lbs"
//        } else {
//            self.lblWeightHeading.text = "Weight"
//            self.isWeightInPounds = false
//            self.lblLbs.text = "Kgs"
//
//        }
//    }
    
    @IBAction func pickerHeightDoneClicked(_ sender: UIBarButtonItem) {
        if selectedType == SelectionType.heightFtIn {
            
            self.txtFieldHeight.text = selectedHeightType != SelectionsHeightType.cm ?   arrFt[self.picker.selectedRow(inComponent: 0)] + " " + "ft".localized() + " " + arrInch[self.picker.selectedRow(inComponent: 1)] + " " + "in".localized() : arrcm[self.picker.selectedRow(inComponent: 0)] + " " + "cm".localized()
            
            self.isHeightInCm = selectedHeightType != SelectionsHeightType.cm ? false : true
            
             ftString = selectedHeightType != SelectionsHeightType.cm ? arrFt[self.picker.selectedRow(inComponent: 0)] : ""
             inchString = selectedHeightType != SelectionsHeightType.cm ? arrInch[self.picker.selectedRow(inComponent: 1)] : ""
             cmString = selectedHeightType == SelectionsHeightType.cm ? arrcm[self.picker.selectedRow(inComponent: 0)] : ""

           // Dhrien
//        } else if selectedType == SelectionType.heightSelection {
//            if self.picker.selectedRow(inComponent: 0) == 0 {
//                self.txtFieldInches.isHidden = false
//                self.lblFt.text = "Ft"
//            } else {
//                lblInches.isHidden = true
//                self.txtFieldInches.isHidden = true
//                self.lblFt.text = "Cm"
//            }
        } else {
            
            self.txtFieldWeight.text = SelectionWeightType.Kgs.rawValue == arrISelectionWeight[self.picker.selectedRow(inComponent: 1)] ? arrkgs[self.picker.selectedRow(inComponent: 0)] + " " + "kg".localized() : arrlbs[self.picker.selectedRow(inComponent: 0)] + " " + "lbs".localized()
            
            self.weightString = SelectionWeightType.Kgs.rawValue == arrISelectionWeight[self.picker.selectedRow(inComponent: 1)] ? arrkgs[self.picker.selectedRow(inComponent: 0)] : arrlbs[self.picker.selectedRow(inComponent: 0)]
            
            self.isWeightInPounds = SelectionWeightType.Kgs.rawValue == arrISelectionWeight[self.picker.selectedRow(inComponent: 1)] ? true : false
            
        }
        self.viewHeightPicker.isHidden = true
    }
    
    @IBAction func healthkitButtonClicked(_ sender: UIButton)
    {
        healthStore.checkAuthorizationStatusAndGetHealthParameters(fromVC: self) { heightInCmString, weightInKgsString, dob, gender in
            
            if let heightInCmString = heightInCmString {
                self.cmString = heightInCmString
                self.selectedType = SelectionType.heightFtIn
                self.selectedHeightType = SelectionsHeightType.cm
                self.txtFieldHeight.text = self.cmString + " " + "cm".localized()
                self.isHeightInCm = true
            }
            
            if let weightInKgsString = weightInKgsString {
                self.isWeightInPounds = true
                self.weightString = weightInKgsString
                self.txtFieldWeight.text = self.weightString + " Kgs"
                self.selectedType = SelectionType.weightSelection
                self.selectedWeightType = SelectionWeightType.Kgs
            }
            
            if let dob = dob {
                self.dateofbirth_Text?.text = dob
            }
            
            if gender == "Female" {
                self.viewFemale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
                self.viewFemale.layer.borderColor = UIColor.white.cgColor
                self.viewMale.backgroundColor = .white
                self.viewMale.layer.borderWidth = 0.5
                self.viewMale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
                self.viewMale.clipsToBounds = true
                self.btnFemale.isSelected = true;
                self.btnMale.isSelected = false;
            } else {
                self.btnMale.isSelected = true;
                self.btnFemale.isSelected = false;
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
//                self.healthStore.checkAllPermission { (issuccess) in
//                    if issuccess == true
//                    {
                        DispatchQueue.main.async(execute: {
                            
                            self.healthStore.healthHeight { (height) in
                                //Height
                                self.cmString = String(height.dropLast(1)) == "m" ? "\(Int(String(height.dropLast(3)))! * 100)":  String(height.dropLast(1)) == "ft" ? "\(Double(String(height.dropLast(3)))! * 30.48)" : String(height.dropLast(3))
                                self.selectedType = SelectionType.heightFtIn
                                self.selectedHeightType = SelectionsHeightType.cm
                                self.txtFieldHeight.text = self.cmString + " " + "cm".localized()
                                self.isHeightInCm = true
                            }
                            self.healthStore.healthWeight { (weight) in
                                //Weight
                                self.isWeightInPounds = true
                                let lbsString = String(weight.dropLast(3))
                                let stString = String(weight.dropLast(2))
                                self.weightString = lbsString == "lbs" ? Utils.convertPoundsToKg(lb: String(weight.dropLast(4))) : stString == "st" ? "\(Double(String(weight.dropLast(3)))! * 6.35029)" : String(weight.dropLast(3))
                                self.txtFieldWeight.text = self.weightString + " Kgs"
                                self.selectedType = SelectionType.weightSelection
                                self.selectedWeightType = SelectionWeightType.Kgs
                            }
                            
                            // DateOfBirth
                            self.healthStore.healthDateOfBirth { (dateOfBirth) in
                                self.dateofbirth_Text?.text = dateOfBirth
                            }
                            
                            if self.healthStore.healthGender() == "Female"
                            {
                                self.viewFemale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
                                self.viewFemale.layer.borderColor = UIColor.white.cgColor
                                self.viewMale.backgroundColor = .white
                                self.viewMale.layer.borderWidth = 0.5
                                self.viewMale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
                                self.viewMale.clipsToBounds = true
                                self.btnFemale.isSelected = true;
                                self.btnMale.isSelected = false;
                            }
                            else
                            {
                                self.btnMale.isSelected = true;
                                self.btnFemale.isSelected = false;
                                self.viewMale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
                                self.viewMale.layer.borderColor = UIColor.white.cgColor
                                self.self.viewFemale.backgroundColor = .white
                                self.viewFemale.layer.borderWidth = 0.5
                                self.viewFemale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
                                self.viewFemale.clipsToBounds = true
                            }
                            Utils.stopActivityIndicatorinView(self.view)
                        })
                    //}
//                    else
//                    {
//                        DispatchQueue.main.async(execute: {
//
//                        Utils.stopActivityIndicatorinView(self.view)
//                            kUserDefaults.set("1", forKey: IsFromMesarmentScreen)
//
//                        Utils.showAlertWithTitleInControllerWithCompletion(Healthkit, message: "You can turn on healthkit permissions from setting => Health => Data Access & Devices => AyuRythm App and Turn All Categories On", cancelTitle: "Cancel", okTitle: "Go To", controller: self, completionHandler: {
//                            self.healthStore.openUrl(urlString: HealthkitURL)
//                        }) {
//                        }
//                        })
//
//                    }
              //  }
            }
        }*/
    }

    @IBAction func registerButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.checkValidation() {
            
            Shared.sharedInstance.isInFt = !self.isHeightInCm
            Shared.sharedInstance.inFt = self.isHeightInCm == false ? ftString : cmString

            if Shared.sharedInstance.isInFt {
                Shared.sharedInstance.inInc = inchString
            }

            Shared.sharedInstance.isInKg = self.isWeightInPounds
            
            Shared.sharedInstance.weigh = self.weightString
            
            Shared.sharedInstance.isMale = self.btnMale.isSelected ? true : false
            
            Shared.sharedInstance.dob = self.dateofbirth_Text?.text ?? ""
            Shared.sharedInstance.name = self.txtFieldUserName.text ?? ""
            
            if Shared.sharedInstance.isInFt
            {
                
                let height = Double(Shared.sharedInstance.inFt)! * 30.48 + Double(Shared.sharedInstance.inInc)! * 2.54
                          kUserDefaults.set(height, forKey: "Height")
            }
            else {
                kUserDefaults.set(Double(Shared.sharedInstance.inFt)!, forKey: "Height")
            }
                      
            if !Shared.sharedInstance.isInKg {
                let weight =  Utils.convertPoundsToKg(lb: Shared.sharedInstance.weigh)
                kUserDefaults.set(Double(weight) ?? 1.0, forKey: "Weight")
            }else{
                kUserDefaults.set(Double(Shared.sharedInstance.weigh) ?? 1.0, forKey: "Weight")
            }
            kUserDefaults.set(Shared.sharedInstance.isMale, forKey: "isMale")
            
            if let referralCode = referralCodeView.referralCode {
                Shared.sharedInstance.referralCode = referralCode
                kUserDefaults.set(referralCode, forKey: "referralCode")
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let dob = Shared.sharedInstance.dob
            let birthday = dateFormatter.date(from: dob)

            let ageComponents = Calendar.current.dateComponents([.year], from: birthday!, to: Date())
            kUserDefaults.set(Double(ageComponents.year!), forKey: "Age")

            kSharedAppDelegate.showPersonalizingScreen()
            
        }
    }
    
    func configureView() {
        if isFromTryAsGuest {
            self.viewUserName.isHidden = false
            self.viewUserNameHeightConst.constant = 133
        } else {
            self.viewUserName.isHidden = true
            self.viewUserNameHeightConst.constant = 0
        }
    }
    
    func checkValidation() -> Bool
    {
        if txtFieldUserName.text!.isEmpty && isFromTryAsGuest {
            Utils.showAlertWithTitleInController(APP_Form_incomplete, message: "Please enter user name".localized(), controller: self)
            return false
        } else if !btnMale.isSelected && !btnFemale.isSelected{
            Utils.showAlertWithTitleInController(APP_Form_incomplete, message: "Please select gender".localized(), controller: self)
            return false
        }
         else if txtFieldHeight.text!.isEmpty {
            Utils.showAlertWithTitleInController(APP_Form_incomplete, message: "Please enter height".localized(), controller: self)
            return false
        } else if txtFieldWeight.text!.isEmpty {
            Utils.showAlertWithTitleInController(APP_Form_incomplete, message: "Please enter weight".localized(), controller: self)
            return false
        } else if (dateofbirth_Text?.text!.isEmpty)! && isFromTryAsGuest {
            Utils.showAlertWithTitleInController(APP_Form_incomplete, message: "Please enter your Date of Birth".localized(), controller: self)
            return false
        } else {
            return true
        }
    }
}

extension MeasurementsViewController {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.viewPicker.isHidden = true
        self.viewHeightPicker.isHidden = true
        self.scrollView?.scrollRectToVisible(CGRect(x: textField.frame.origin.x, y: textField.frame.origin.y, width: textField.frame.size.width, height: textField.frame.size.height + 50), animated: true)
        referralCodeView.textFieldDidBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        referralCodeView.textFieldDidEndEditing(textField)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtFieldHeight {
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
        } else if textField == txtFieldWeight {
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
                if let text = txtFieldWeight.text, !text.isEmpty {
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
        
        self.txtFieldWeight.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.txtFieldWeight.resignFirstResponder()
    }
}
//var SelectionsageType: SelectionsageType = .month

extension MeasurementsViewController {
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
            else if  selectedType == SelectionType.age
            {
                  return 3
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
            else if  selectedType == SelectionType.age
            {
                if component == 0
                {
                    return arrmonth.count
                }
                 else if component == 1
                {
                    return arryear.count
                }
                else
                {
                    return arrSelectionAge.count
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
            else if  selectedType == SelectionType.age
            {
                    if component == 0
                    {
                        return arrmonth[row]
                    }
                    else if component == 1
                    {
                        return arryear[row]
                    }
                    else
                    {
                       return arrSelectionAge[row]
                    }
            }
        else
        {
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
        /*else if selectionsageType == SelectionsageType.month
        {
            //agePicker.reloadAllComponents()
        }*/
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
