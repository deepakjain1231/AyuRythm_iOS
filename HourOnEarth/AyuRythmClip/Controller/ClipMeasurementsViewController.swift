//
//  ClipMeasurementsViewController.swift
//  AyuRythmClip
//
//  Created by Paresh Dafda on 24/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class ClipMeasurementsViewController: UIViewController, UITextFieldDelegate , UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    
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
    var arrFt = ["1","2","3","4","5","6","7","8","9","10"]
    var arrInch = ["0","1","2","3","4","5","6","7","8","9","10","11"]
    var arrpoint = [".0",".1",".2",".3",".4",".5",".6",".7",".8",".9"]
    var arrkgs = [String]()
    let arrSelectionsHeight = ["cm","ft in"]
    let arrISelectionWeight = ["lbs", "Kgs"]
    let arrSelectionHeight = ["Imperial","Metric"]
    let arrSelectionAge = ["month year"]
    var strDateOfBirth = ""
    var heightInCms = 0.0
    var arrcm = [String]()
    var arrlbs = [String]()
    
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
    
    var arrmonth = [String]()
    var arryear = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrcm = []
        for i in 120 ... 300
        {
            arrcm.append("\(i)")
        }
        
        arrkgs = []
        for i in 25 ... 200 {
            arrkgs.append("\(i)")
        }
        
        arrlbs = []
        for i in 55 ... 440 {
            arrlbs.append("\(i)")
        }

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
        self.viewHeightPicker.isHidden = true
       // datePicker.maximumDate = Date()
        let min12YearDate = Calendar.current.date(byAdding: .year, value: -12, to: Date())
        datePicker.maximumDate = min12YearDate
        viewMale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
        viewFemale.backgroundColor = .white
        viewFemale.layer.borderWidth = 0.5
        viewFemale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
        viewFemale.clipsToBounds = true
        btnMale.isSelected = true
        displaySharedStoredData()
        //picker.selectRow(1, inComponent: 2, animated: true)
        
        if #available(iOS 14.0, *) {
            datePicker.tintColor = .black
            datePicker.preferredDatePickerStyle = .wheels
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
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
        
        /*let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let objLoginView: LoginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(objLoginView, animated: true)*/
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
    
    @IBAction func pickerHeightDoneClicked(_ sender: UIBarButtonItem) {
        if selectedType == SelectionType.heightFtIn {
            
            self.txtFieldHeight.text = selectedHeightType != SelectionsHeightType.cm ?   arrFt[self.picker.selectedRow(inComponent: 0)] + " " + "ft".localized() + " " + arrInch[self.picker.selectedRow(inComponent: 1)] + " " + "in".localized() : arrcm[self.picker.selectedRow(inComponent: 0)] + " " + "cm".localized()
            
            self.isHeightInCm = selectedHeightType != SelectionsHeightType.cm ? false : true
            
             ftString = selectedHeightType != SelectionsHeightType.cm ? arrFt[self.picker.selectedRow(inComponent: 0)] : ""
             inchString = selectedHeightType != SelectionsHeightType.cm ? arrInch[self.picker.selectedRow(inComponent: 1)] : ""
             cmString = selectedHeightType == SelectionsHeightType.cm ? arrcm[self.picker.selectedRow(inComponent: 0)] : ""
        } else {
            
            self.txtFieldWeight.text = SelectionWeightType.Kgs.rawValue == arrISelectionWeight[self.picker.selectedRow(inComponent: 1)] ? arrkgs[self.picker.selectedRow(inComponent: 0)] + " " + "kg".localized() : arrlbs[self.picker.selectedRow(inComponent: 0)] + " " + "lbs".localized()
            
            self.weightString = SelectionWeightType.Kgs.rawValue == arrISelectionWeight[self.picker.selectedRow(inComponent: 1)] ? arrkgs[self.picker.selectedRow(inComponent: 0)] : arrlbs[self.picker.selectedRow(inComponent: 0)]
            
            self.isWeightInPounds = SelectionWeightType.Kgs.rawValue == arrISelectionWeight[self.picker.selectedRow(inComponent: 1)] ? true : false
            
        }
        self.viewHeightPicker.isHidden = true
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
                let heightInFeet = Double(Shared.sharedInstance.inFt) ?? 0
                let heightInInch = Double(Shared.sharedInstance.inInc) ?? 0
                let height = heightInFeet * 30.48 + heightInInch * 2.54
                kUserDefaults.set(height, forKey: "Height")
            }
            else {
                let height = (Double(Shared.sharedInstance.inFt) ?? 0)
                kUserDefaults.set(height, forKey: "Height")
            }
                      
            if !Shared.sharedInstance.isInKg {
                let weight =  Utils.convertPoundsToKg(lb: Shared.sharedInstance.weigh)
                kUserDefaults.set(Double(weight) ?? 1.0, forKey: "Weight")
            }else{
                kUserDefaults.set(Double(Shared.sharedInstance.weigh) ?? 1.0, forKey: "Weight")
            }
            kUserDefaults.set(Shared.sharedInstance.isMale, forKey: "isMale")

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let dob = Shared.sharedInstance.dob
            let birthday = dateFormatter.date(from: dob)

            let ageComponents = Calendar.current.dateComponents([.year], from: birthday!, to: Date())
            kUserDefaults.set(Double(ageComponents.year!), forKey: "Age")
            Shared.sharedInstance.saveAllDataToUserDefaults()

//            debugUserMeasurements()
//            showRecommendations()
            
            showSparshnaAlert()
        }
    }
    
    func displaySharedStoredData() {
        
        Shared.sharedInstance.fetchAllDataFromUserDefaults()
        self.txtFieldUserName?.text = Shared.sharedInstance.name
        self.dateofbirth_Text?.text = Shared.sharedInstance.dob
        self.isHeightInCm = !Shared.sharedInstance.isInFt
        selectedHeightType = isHeightInCm ? .cm : .ftin
        self.isWeightInPounds = !Shared.sharedInstance.isInKg
        
        if !Shared.sharedInstance.weigh.isEmpty {
            self.txtFieldWeight.text = isWeightInPounds ? Shared.sharedInstance.weigh + " " + "lbs".localized() : Shared.sharedInstance.weigh + " " + "kg".localized()
            
            selectedWeightType = !isWeightInPounds ? .Kgs : .lbs
            weightString = Shared.sharedInstance.weigh
        }
        
        
        if !Shared.sharedInstance.inFt.isEmpty || !Shared.sharedInstance.inInc.isEmpty {
            self.txtFieldHeight.text = isHeightInCm ? Shared.sharedInstance.inFt + " " + "cm".localized() : Shared.sharedInstance.inFt + " " + "ft".localized() + " " + Shared.sharedInstance.inInc + " " + "in".localized()
            
            ftString = Shared.sharedInstance.inFt
            inchString = Shared.sharedInstance.inInc
            cmString = Shared.sharedInstance.inFt
        }
        
        if Shared.sharedInstance.isMale {
            btnMale?.isSelected = true;
            
            viewMale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
            viewMale.layer.borderColor = UIColor.white.cgColor
            viewFemale.backgroundColor = .white
            viewFemale.layer.borderWidth = 0.5
            viewFemale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
            viewFemale.clipsToBounds = true

            btnFemale?.isSelected = false;
        } else {
            btnFemale?.isSelected = true;
            btnMale?.isSelected = false;
            
            viewFemale.backgroundColor = UIColor().hexStringToUIColor(hex: "#CEEACD")
            viewFemale.layer.borderColor = UIColor.white.cgColor

            viewMale.backgroundColor = .white
            viewMale.layer.borderWidth = 0.5
            viewMale.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.29).cgColor
            viewMale.clipsToBounds = true

        }
        picker.reloadAllComponents()
    }
    
    func debugUserMeasurements() {
        var height = 0.0
        var heightUnit = ""
        if Shared.sharedInstance.isInFt {
            heightUnit = "feet"
            let heightInFeet = Double(Shared.sharedInstance.inFt) ?? 0
            let heightInInch = Double(Shared.sharedInstance.inInc) ?? 0
            height = heightInFeet * 30.48 + heightInInch * 2.54
            print("--->> Height : ", "\(heightInFeet)' \(heightInInch)\"")
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

        let userMeasurements = "[\"\(height)\",\"\(weight)\",\"\(heightUnit)\",\"\(weightUnit)\"]"
        print("====>>> userMeasurements : ", userMeasurements)
    }
    
    func showSparshnaAlert() {
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let objAlert = storyBoard.instantiateViewController(withIdentifier: "SparshnaAlert") as! SparshnaAlert
        objAlert.modalPresentationStyle = .overCurrentContext
        objAlert.completionHandler = {
            let objSlideView = CameraViewController.instantiate(fromAppStoryboard: .Camera)
            self.navigationController?.pushViewController(objSlideView, animated: true)
        }
        self.present(objAlert, animated: true)
    }
    
    func showResultScreen() {
        let storyBoard = UIStoryboard(name: "SparshnaResult", bundle: nil)
        let objDescription = storyBoard.instantiateViewController(withIdentifier: "SparshnaResult") as! SparshnaResult
        objDescription.isRegisteredUser = false
        objDescription.isFromCameraView = true
        self.navigationController?.pushViewController(objDescription, animated: true)
        
        
//        let storyBoard = UIStoryboard(name: "Questionnaire", bundle: nil)
//        let objDescription = storyBoard.instantiateViewController(withIdentifier: "LastAssessmentVC") as! LastAssessmentVC
//        //objDescription.isRegisteredUser = false
//        objDescription.isFromCameraView = true
//        self.navigationController?.pushViewController(objDescription, animated: true)
    }
    
    func showRecommendations() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let objDescription = storyBoard.instantiateViewController(withIdentifier: "RecommendationsVC") as! RecommendationsVC
        self.navigationController?.pushViewController(objDescription, animated: true)
    }
    
    func configureView() {
        /*if isFromTryAsGuest {
            self.viewUserName.isHidden = false
            self.viewUserNameHeightConst.constant = 133
        } else {
            self.viewUserName.isHidden = true
            self.viewUserNameHeightConst.constant = 0
        }*/
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

extension ClipMeasurementsViewController {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.viewPicker.isHidden = true
        self.viewHeightPicker.isHidden = true
        self.scrollView?.scrollRectToVisible(CGRect(x: textField.frame.origin.x, y: textField.frame.origin.y, width: textField.frame.size.width, height: textField.frame.size.height + 50), animated: true)
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
                picker.selectRow(0, inComponent: 1, animated: true)
                return false
            } else {
                self.view.endEditing(true)
                self.viewHeightPicker.isHidden = false
                selectedType = .heightFtIn
                self.picker.reloadAllComponents()
                selectedWeightType = .balnk
                selectedHeightType = .ftin
                picker.selectRow(1, inComponent: 2, animated: true)

                return false
            }
        }
        else if textField == txtFieldWeight
        {
            selectedHeightType = .balnk
            selectedWeightType = .Kgs
            self.view.endEditing(true)
            picker.selectRow(1, inComponent: 1, animated: true)

            self.viewHeightPicker.isHidden = false
            selectedType = .weightSelection
            self.picker.reloadAllComponents()
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
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done".localized(), style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneButtonAction))
        
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

extension ClipMeasurementsViewController {
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

