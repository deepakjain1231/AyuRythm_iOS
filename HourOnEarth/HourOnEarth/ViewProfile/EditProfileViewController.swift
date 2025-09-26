//
//  EditProfileViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 6/5/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
import SKCountryPicker

class EditProfileViewController:BaseViewController,UIScrollViewDelegate,UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var name_Text: UITextField?
    @IBOutlet var mobilenum_Text: UITextField?
    @IBOutlet var email_Text: UITextField?
    @IBOutlet var password_Text: UITextField?
    @IBOutlet var confirmpwd_Text: UITextField?
    @IBOutlet var dateofbirth_Text: UITextField?
    @IBOutlet var register_Btn: UIButton?
    @IBOutlet var male_Btn: UIButton?
    @IBOutlet var female_Btn: UIButton?
    @IBOutlet var calendar_Btn: UIButton?
    @IBOutlet var scrollView: UIScrollView?
    
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var txtFieldInches: UITextField!
    @IBOutlet weak var txtFieldHeight: UITextField!
    @IBOutlet weak var scrollBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgViewProfile: UIImageView!
    
    @IBOutlet weak var viewHeightPicker: UIView!
    @IBOutlet weak var picker: UIPickerView!

    @IBOutlet weak var lblWeightHeading: UILabel!
    @IBOutlet weak var lblInches: UILabel!
    @IBOutlet weak var lblFt: UILabel!
    @IBOutlet weak var viewLine: UIView!
    
    @IBOutlet weak var viewFemale: UIView!
    @IBOutlet weak var viewMale: UIView!
    @IBOutlet weak var viewEnterMobileNumber: UIView!
    @IBOutlet weak var verifyEmail_Btn: UIButton!

    var isHeightInCm = false
    var isWeightInPounds = false
    var arrFt = MeasurementData.Height.feetValues
    var arrInch = MeasurementData.Height.inchValues
    var arrcm = MeasurementData.Height.cmValues
    
    var arrkgs = MeasurementData.weight.kgValues
    var arrlbs = MeasurementData.weight.poundValues
    let arrSelectionHeight = ["Imperial","Metric"]
    let arrSelectionsHeight = ["cm","ft in"]
    let arrISelectionWeight = ["lbs", "Kgs"]

    var selectedType: SelectionType = .heightFtIn
    
    
    var selectedHeightType: SelectionsHeightType = .ftin
    var selectedWeightType: SelectionWeightType = .Kgs
    
    var ftString = ""
    var inchString = ""
    var cmString = ""
    var weightString = ""
    
    @IBOutlet weak var viewcountryPicker: UIView!
    @IBOutlet weak var countrypicker: CountryPickerView!
    @IBOutlet weak var countryButton: UIButton!
    var countryCodes = "+91"
    var countryName = "India"

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
        navigationController!.navigationBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        navigationItem.title = "Edit Profile".localized()
        
        let rightButtonItem = UIBarButtonItem(title: "Save".localized(), style:  .plain, target: self, action: #selector(rightButtonAction(sender:)))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        
        
        // Do any additional setup after loading the view.
        // NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        //  NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        self.viewPicker.isHidden = true
        male_Btn?.isSelected = true
        self.viewHeightPicker.isHidden = true
        self.viewcountryPicker.isHidden = true
        self.countryPickerCallback()
        
        //  self.hideKeyboardWhenTappedAround()
        //  addDoneButtonOnKeyboard()
        
        if let urlString = kUserDefaults.value(forKey: kUserImage) as? String, let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            let imageDownloader = UIImageView.af_sharedImageDownloader
            _ = imageDownloader.imageCache?.removeImage(for: urlRequest, withIdentifier: nil)
            //imageDownloader.sessionManager.session.configuration.urlCache?.removeCachedResponse(for: urlRequest)
            imageDownloader.session.session.configuration.urlCache!.removeCachedResponse(for: urlRequest)
            
            
            self.imgViewProfile.af_setImage(withURL: url)
        }
        self.imgViewProfile.layer.cornerRadius = self.imgViewProfile.frame.size.width/2
        self.imgViewProfile.clipsToBounds = true
        
        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            return
        }
        self.name_Text?.text = empData["name"] as? String ?? ""
        self.email_Text?.text = empData["email"] as? String ?? ""
        self.mobilenum_Text?.text = empData["mobile"] as? String ?? ""
        self.dateofbirth_Text?.text = empData["dob"] as? String ?? ""
        self.countryCodes = empData["countrycode"] as? String ?? ""
        self.countryName = empData["country"] as? String ?? ""
        self.countryButton.setTitle(self.countryCodes, for: .normal)
        
        female_Btn?.isSelected = false
        male_Btn?.isSelected = false
        if empData["gender"] as? String ?? "" == "Male" {
            male_Btn?.isSelected = true
        } else {
            female_Btn?.isSelected = true
        }
        
        self.isWeightInPounds = Shared.sharedInstance.isInKg
        
        if (male_Btn?.isSelected == true) {
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
        
        guard let measurement = empData["measurements"] as? String else {
            return
        }
        let arrMeasurement = Utils.parseValidValue(string: measurement).components(separatedBy: ",")
        if arrMeasurement.count >= 4 {
            
            let cms = Double(arrMeasurement[0]) ?? 0
            
            
            let heightUnit = arrMeasurement[2]
            
            if heightUnit == "feet"
            {
                let INCH_IN_CM = 2.54
                
                let numInches = roundf(Float(cms / INCH_IN_CM))
                let feet = Int(numInches / 12);
                let inches = Int(numInches.truncatingRemainder(dividingBy: 12.0))  //% 12.0;
                self.txtFieldHeight.text = String(format: "%d " + "ft".localized() + " ", arguments: [feet]) + "\(inches) " + "in".localized()
                Shared.sharedInstance.inFt = "\(feet)"
                Shared.sharedInstance.inInc = "\(inches)"
                Shared.sharedInstance.isInFt = false 
            }
            else
            {
                self.txtFieldHeight.text = "\(cms) " + "cm".localized()
                Shared.sharedInstance.inFt = "\(cms)"
                Shared.sharedInstance.isInFt = true
                
            }
            let weightUnit = arrMeasurement[3]
            
            if weightUnit == "Kilogram"
            {
                self.txtWeight.text = arrMeasurement[1] + " " + "Kgs".localized()
                Shared.sharedInstance.weigh = arrMeasurement[1]
                Shared.sharedInstance.isInKg = true
                
            }
            else
            {
                
                self.txtWeight.text = Utils.convertKgToPounds(kg: arrMeasurement[1]) + " " + "lbs".localized()
                Shared.sharedInstance.weigh = Utils.convertKgToPounds(kg: arrMeasurement[1])
                Shared.sharedInstance.isInKg = false
                
            }
            print("heightUnit=",heightUnit)
            
        }
        
        /*if let loginTypeInt = empData["logintype"] as? String, let loginType = ARLoginType(rawValue: Int(loginTypeInt) ?? 0){
            if loginType != .normal {
                if mobilenum_Text?.text?.isEmpty ?? true {
                    email_Text?.isUserInteractionEnabled = false
                    viewEnterMobileNumber.isHidden = true
                }
            }
        }*/
        if mobilenum_Text?.text?.isEmpty ?? true {
            mobilenum_Text?.isUserInteractionEnabled = true
            countryButton.isUserInteractionEnabled = true
        } else {
            mobilenum_Text?.isUserInteractionEnabled = false
            countryButton.isUserInteractionEnabled = false
        }
        
        if #available(iOS 14.0, *) {
            datePicker.tintColor = .black
            datePicker.preferredDatePickerStyle = .wheels
        }
        handleApplicationDidBecomeActiveEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserInfoFromServer()
    }
    
    //MARK: Actions
    @objc func rightButtonAction(sender: UIBarButtonItem) {
        view.endEditing(true)
        validateDataAndUpdateOnServer()
    }
    
    @IBAction func heightSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            //in ft
            lblInches.isHidden = false
            self.txtFieldInches.isHidden = false
            viewLine.isHidden = false
            self.lblFt.text = "Ft".localized()
            self.isHeightInCm = false
            self.txtFieldHeight.text = ""
            self.txtFieldInches.text = ""
        } else {
            lblInches.isHidden = true
            self.txtFieldInches.isHidden = true
            self.lblFt.text = "Cm".localized()
            self.isHeightInCm = true
            viewLine.isHidden = true
            self.txtFieldHeight.text = ""
        }
    }
    
    @IBAction func weightSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0  {
            self.lblWeightHeading.text = "Weight".localized()
            self.isWeightInPounds = true
        } else {
            self.lblWeightHeading.text = "Weight".localized()
            self.isWeightInPounds = false
        }
    }
    
    func handleApplicationDidBecomeActiveEvent() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] notif in
            self?.getUserInfoFromServer()
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView?.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func countryPickerButtonClicked(_ sender: UIButton)
      {
          self.viewcountryPicker.isHidden = false
          self.view.endEditing(true)
      }
    
      @IBAction func pickerCountryDoneClicked(_ sender: UIBarButtonItem)
      {
          self.viewcountryPicker.isHidden = true
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
    
    
    @IBAction func register_Action(sender: UIButton) {
        validateDataAndUpdateOnServer()
    }
    
    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @IBAction func back_Action(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pickerDoneClicked(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateofbirth_Text?.text = dateFormatter.string(from: self.datePicker.date)
        self.viewPicker.isHidden = true
    }
    
    @IBAction func UpdateDOBClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.viewPicker.isHidden = false
    }
    
    @IBAction func infoButtonClicked(_ sender: UIButton)
    {
        self.view.endEditing(true)
        self.viewPicker.isHidden = true
        self.viewcountryPicker.isHidden = true
        Utils.showAlertWithTitleInController(Date_Of_BirthTitle, message: DateOfBirthDescription, controller: self)
    }

    @IBAction func radio_btn(sender: UIButton) {
        
        if (male_Btn?.isSelected == false) {
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
    
    @IBAction func imageClicked(_ sender: UIButton) {
        showImagePickerActionSheet()
    }
    
    @IBAction func verifyEmailClicked(_ sender: UIButton) {
        print("verify email now")
        if let email = email_Text?.text {
            showActivityIndicator()
            emailVerifyFromServer(email: email) { [weak self] (isSuccess, title, message) in
                self?.hideActivityIndicator()
                self?.showAlert(title: title, message: message)
            }
        }
    }
    
    func validateDataAndUpdateOnServer() {
        
        guard let username = name_Text?.text, !username.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter username.".localized(), controller: self)
            return
        }
        
        guard let email = email_Text?.text, !email.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter email.".localized(), controller: self)
            return
        }
        
        guard isValidEmail(testStr: email) else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter valid email.".localized(), controller: self)
            return
        }
        
        guard let mobileNumber = mobilenum_Text?.text, mobileNumber.isEmpty || (!mobileNumber.isEmpty && mobileNumber.count >= 10) else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter valid mobile number.".localized(), controller: self)
            return
        }
        
        updateDetailsOnServer()
    }
    
    func checkEmailVerificationStatus() {
        let emailVerifyStatus = (kUserDefaults.value(forKey: kEmailVerifyStatus) as? String) ?? "0"
        if emailVerifyStatus == "1" {
            verifyEmail_Btn.isSelected = true
            verifyEmail_Btn.isUserInteractionEnabled = false
            email_Text?.isUserInteractionEnabled = false
        } else {
            //set true if you want to change email before verify it
            email_Text?.isUserInteractionEnabled = false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.scrollView?.scrollRectToVisible(CGRect(x: textField.frame.origin.x, y: textField.frame.origin.y, width: textField.frame.size.width, height: textField.frame.size.height + 50), animated: true)
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done".localized(), style: UIBarButtonItem.Style.plain, target: self, action: #selector(EditProfileViewController.doneButtonAction))
        
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
    
    @IBAction func pickerSelectClicked(_ sender: Any) {
      if selectedType == SelectionType.heightFtIn {
            
        self.txtFieldHeight.text = selectedHeightType != SelectionsHeightType.cm ?   arrFt[self.picker.selectedRow(inComponent: 0)] + " " + "ft".localized() + " " + arrInch[self.picker.selectedRow(inComponent: 1)] + " " + "in".localized() : arrcm[self.picker.selectedRow(inComponent: 0)] + " " + "cm".localized()

            self.isHeightInCm = selectedHeightType != SelectionsHeightType.cm ? false : true
            
            Shared.sharedInstance.isInFt = self.isHeightInCm

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
    
    
    
}

extension EditProfileViewController {
    func updateDetailsOnServer() {
        if Utils.isConnectedToNetwork() {
            
            var height = 0.0
            var heightUnit = ""
            if !Shared.sharedInstance.isInFt {
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
            if !Shared.sharedInstance.isInKg {
                weightUnit = "Pound"
                weight = Utils.convertPoundsToKg(lb: Shared.sharedInstance.weigh)
            } else {
                weightUnit = "Kilogram"
                weight = Shared.sharedInstance.weigh
            }
            
            let userMeasurements = "[\"\(height)\",\"\(weight)\",\"\(heightUnit)\",\"\(weightUnit)\"]"

            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let isMale = (male_Btn?.isSelected)! ? "Male" : "Female"
            let urlString = kBaseNewURL + endPoint.updateuserdata.rawValue
            let params = ["user_name": name_Text?.text ?? "", "user_id": kSharedAppDelegate.userId, "user_mobile": mobilenum_Text?.text ?? "", "user_email": email_Text?.text ?? "", "gender": isMale,"user_dob":dateofbirth_Text?.text ?? "", "user_measurements": userMeasurements, "countrycode": self.countryCodes, "country": self.countryName]
            
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON { response in
                
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    let status = dicResponse["status"] as? String
                    if status == "Success" {
                        Utils.showAlertWithTitleInControllerWithCompletion("Success".localized(), message: "Updated successfully".localized(), okTitle: "Ok".localized(), controller: self, completionHandler: {
                            
                            guard var empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
                                return
                            }
                            empData["name"] = self.name_Text?.text ?? ""
                            empData["email"] = self.email_Text?.text ?? ""
                            empData["mobile"] = self.mobilenum_Text?.text ?? ""
                            empData["dob"]  = self.dateofbirth_Text?.text ?? ""
                            empData["measurements"] = userMeasurements
                            empData["gender"] = (self.male_Btn?.isSelected)! ? "Male" : "Female"
                            empData["country"] = self.countryName
                            empData["countrycode"] = self.countryCodes
                            kUserDefaults.set(empData, forKey: USER_DATA)
                            kUserDefaults.synchronize()
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        Utils.showAlertWithTitleInController(status ?? APP_NAME, message: (dicResponse["Message"] as? String ?? "Failed to update user details.".localized()), controller: self)
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
    
    func updateImageOnServer(imageString: String) {
        if Utils.isConnectedToNetwork() {
            //let urlString = kBaseURL + "saveimage.php"
            let urlString = kBaseNewURL + endPoint.uploadprofilepicture.rawValue
            let params = ["image": imageString]
          

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON { response in
                
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    if dicResponse["status"] as? String ?? "" == "Sucess"
                    {

                        if let urlString = dicResponse["data"]!["image"] as? String, let url = URL(string: urlString) {
                            let urlRequest = URLRequest(url: url)
                            let imageDownloader = UIImageView.af_sharedImageDownloader
                            _ = imageDownloader.imageCache?.removeImage(for: urlRequest, withIdentifier: nil)
                            imageDownloader.session.session.configuration.urlCache?.removeCachedResponse(for: urlRequest)
                            
                            kUserDefaults.set(urlString, forKey: kUserImage)
                            self.imgViewProfile.af_setImage(withURL: url)
                        }
                        Utils.showAlertWithTitleInControllerWithCompletion("Success".localized(), message: "Updated successfully".localized(), okTitle: "Ok".localized(), controller: self, completionHandler: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["Message"] as? String ?? "Failed to update user details.".localized()), controller: self)
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
    
    func emailVerifyFromServer(email: String, completion: @escaping (Bool, String, String)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.emailVerify.rawValue

            AF.request(urlString, method: .post, parameters: ["email": email], encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        completion(false, APP_NAME, "")
                        return
                    }
                    
                    let isSuccess = dicResponse["status"] as? String == "success"
                    let message = dicResponse["message"] as? String ?? ""
                    completion(isSuccess, APP_NAME, message)
                case .failure(let error):
                    print(error)
                    completion(false, APP_NAME, error.localizedDescription)
                }
            }
        } else {
            completion(false, APP_NAME, NO_NETWORK)
        }
    }
    
    func getUserInfoFromServer() {
        if Utils.isConnectedToNetwork() {
            showActivityIndicator()
            let urlString = kBaseNewURL + endPoint.userinfo.rawValue
            AF.request(urlString, method: .post, parameters: nil, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any], let data = dicResponse["data"] as? [String: Any] else {
                        self.hideActivityIndicator()
                        return
                    }
                    
                    let emailVerifyStatus = data["email_verify_status"] as? String ?? "0"
                    kUserDefaults.set(emailVerifyStatus, forKey: kEmailVerifyStatus)
                    self.checkEmailVerificationStatus()
                    self.hideActivityIndicator()
                case .failure(let error):
                    print(error)
                    self.hideActivityIndicator()
                    //showAlert(message: error.localizedDescription)
                }
            }
        }
    }
}


extension EditProfileViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if selectedType == SelectionType.heightFtIn {
            if selectedHeightType == SelectionsHeightType.cm {
                return 2
            } else {
                return 3
            }
        } else if  selectedType == SelectionType.weightSelection {
            return 2
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectedType == SelectionType.heightFtIn {
            if selectedHeightType == SelectionsHeightType.cm {
                if component == 0 {
                    return arrcm.count
                } else {
                    return arrSelectionsHeight.count
                }
            } else {
                if component == 0 {
                    return arrFt.count
                } else if component == 1 {
                    return arrInch.count
                } else {
                    return arrSelectionsHeight.count
                }
            }
        } else {
            if selectedWeightType == SelectionWeightType.Kgs {
                if component == 0 {
                    return arrkgs.count
                } else {
                    return arrISelectionWeight.count
                }
            } else {
                if component == 0 {
                    return arrlbs.count
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
                    return arrcm[row]
                } else {
                    return arrSelectionsHeight[row].localized()
                }
            } else {
                if component == 0 {
                    return arrFt[row]
                } else if component == 1 {
                    return arrInch[row]
                } else {
                    return arrSelectionsHeight[row].localized()
                }
            }
        } else {
            if selectedWeightType == SelectionWeightType.Kgs {
                if component == 0 {
                    return arrkgs[row]
                } else  {
                    return arrISelectionWeight[row].localized()
                }
            } else {
                if component == 0 {
                    return arrlbs[row]
                } else  {
                    return arrISelectionWeight[row].localized()
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
                    picker.reloadAllComponents()
                }
            }
        }
        else if selectedHeightType == SelectionsHeightType.cm {
            if component == 1 {
                if row == 1 {
                    selectedType = SelectionType.heightFtIn
                    selectedHeightType = SelectionsHeightType.ftin
                    picker.reloadAllComponents()
                    
                }
            }
        }
        else if selectedWeightType == SelectionWeightType.Kgs {
            if component == 1 {
                if row == 0 {
                    selectedWeightType = SelectionWeightType.lbs
                    picker.reloadAllComponents()
                    
                }
            }
        }
        else {
            if component == 1 {
                if row == 1 {
                    selectedWeightType = SelectionWeightType.Kgs
                    picker.reloadAllComponents()
                    
                }
            }
            
        }
        
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerActionSheet(isCancelVisible:Bool = true){
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option".localized(), preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Take Photo".localized(), style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.openCamera()
        })
        let saveAction = UIAlertAction(title: "Choose From Library".localized(), style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.openPhotoLibrary()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in
            print("Cancelled", terminator: "")
           
        })

        // Y
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        if isCancelVisible {
            optionMenu.addAction(cancelAction)
        }
        optionMenu.popoverPresentationController?.sourceView = self.view
        optionMenu.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    //User cancelled action remove the last dragged imageview
    private func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func openCamera(){
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: false,
                         completion: nil)
        }
    }
    
    
    private func openPhotoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true,
                         completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        _ = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as? String
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)]
            as? UIImage
        //let indexPath = NSIndexPath (row: 0, section: 0)
        var newimage = UIImage()
        //let newImg = image?.upOrientationImage()
        newimage = (image?.resizeWith(width: 250, height: 250))!
        let imgData: NSData = NSData(data: newimage.pngData()!)
        let imageSize: Int = imgData.length
        print("size of image in KB: %f ", imageSize/1024)
        
        let imageStr = imgData.base64EncodedString(options: [])
        self.updateImageOnServer(imageString: imageStr)
        self.dismiss(animated: true, completion: nil)

        
        // self.Tableview_ProfileDetail.reloadRows(at: [indexPath as IndexPath], with: .none)
//        uploadImageToServer(image: newimage,urlstring: BaseURL + "api/Check/" + "\(issuedCheckId)/uploadcheck",completionHandler: {(responseData,statuscode)->()in
//            //self.Tableview_ProfileDetail.reloadRows(at: [indexPath as IndexPath], with: .none)
//            // self.dismiss(animated: true, completion: nil)
//            if(statuscode == 200) {
//                self.activityIndicatorEnd()
//                self.paidChecks(strId: "\(self.issuedCheckId)")
//            }
//        })
    }
}


extension UIImage {
    
    func resizeWith(width: CGFloat,height: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func upOrientationImage() -> UIImage? {
            switch imageOrientation {
            case .up:
                return self
            default:
                UIGraphicsBeginImageContextWithOptions(size, false, scale)
                draw(in: CGRect(origin: .zero, size: size))
                let result = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return result
            }
        }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
