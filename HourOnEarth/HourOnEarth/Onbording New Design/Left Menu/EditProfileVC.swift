//
//  EditProfileVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 11/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import FirebaseAuth
import SKCountryPicker

class EditProfileVC: UIViewController, delegate_otpVeried, countryPickDelegate {
    
    var countryCodes = "+91"
    var countryName = "India"
    var dic_Param = [String: Any]()
    var arr_Section = [D_SideMenuData]()
    var dob_date_Picker = UIDatePicker()
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var tbl_View: UITableView!
    
    var headers: HTTPHeaders {
        get { return ["Authorization": Utils.getAuthToken()] }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_title.text = "Edit Profile".localized()
        
        //Register Table Cell
        self.tbl_View.register(nibWithCellClass: GenderTableCell.self)
        self.tbl_View.register(nibWithCellClass: EditProfileHeaderTableCell.self)
        self.tbl_View.register(nibWithCellClass: RegisterFieldTableCell.self)
        self.tbl_View.register(nibWithCellClass: TitleHeaderTableCell.self)
        self.tbl_View.register(nibWithCellClass: HeightWeightTableCell.self)
        self.tbl_View.register(nibWithCellClass: SideMenuButtonTableCell.self)
        self.tbl_View.register(nibWithCellClass: SideMenuBlankTableCell.self)
        //*******************************************************************//
        
        if #available(iOS 13.4, *) {
            self.dob_date_Picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        self.dob_date_Picker.maximumDate = Calendar.current.date(byAdding: .year, value: -12, to: Date())
        self.dob_date_Picker.datePickerMode = .date
        self.dob_date_Picker.addTarget(self, action: #selector(self.datePickerDidBirthday(_:)), for: UIControl.Event.valueChanged)
        
                
        setupDic()
        manageSection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupDic() {
        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            return
        }
        self.countryName = empData["country"] as? String ?? ""
        self.countryCodes = empData["countrycode"] as? String ?? ""
        let str_Mobile = empData["mobile"] as? String ?? ""
        if str_Mobile.trimed() == "" {
            self.countryName = CountryManager.shared.currentCountry?.countryName ?? "India"
            self.countryCodes = CountryManager.shared.currentCountry?.dialingCode ?? "91"
        }
        if self.countryCodes.contains("+") {
            self.countryCodes = self.countryCodes.replacingOccurrences(of: "+", with: "")
        }
        
        self.dic_Param["name"] = empData["name"] as? String ?? ""
        self.dic_Param["email"] = empData["email"] as? String ?? ""
        self.dic_Param["mobile"] = empData["mobile"] as? String ?? ""
        self.dic_Param["dob"] = empData["dob"] as? String ?? ""
        self.dic_Param["countrycode"] = self.countryCodes
        self.dic_Param["gender"] = empData["gender"] as? String ?? ""

        guard let measurement = empData["measurements"] as? String else {
            return
        }
        let arrMeasurement = Utils.parseValidValue(string: measurement).components(separatedBy: ",")
        if arrMeasurement.count >= 4 {
            let cms = Double(arrMeasurement[0]) ?? 0
            let heightUnit = arrMeasurement[2]
            
            self.dic_Param[SideMenuOptionsKey.kheightUnit.rawValue] = heightUnit
            
            if heightUnit == "feet" {
                let INCH_IN_CM = 2.54

                let numInches = roundf(Float(cms / INCH_IN_CM))
                let feet = Int(numInches / 12);
                let inches = Int(numInches.truncatingRemainder(dividingBy: 12.0))  //% 12.0;
                self.dic_Param[SideMenuOptionsKey.kheight_ft.rawValue] = "\(feet)"
                self.dic_Param[SideMenuOptionsKey.kheight_in.rawValue] = "\(inches)"
            }
            else {
                self.dic_Param[SideMenuOptionsKey.kheight_cm.rawValue] = "\(cms)"
            }
            
            let weightUnit = arrMeasurement[3]
            self.dic_Param[SideMenuOptionsKey.kweightUnit.rawValue] = weightUnit
            
            if weightUnit == "Kilogram" {
                self.dic_Param[SideMenuOptionsKey.kweight.rawValue] = arrMeasurement[1]
            }
            else {
                self.dic_Param[SideMenuOptionsKey.kweight.rawValue] = Utils.convertKgToPounds(kg: arrMeasurement[1])
            }
        }
        
        if #available(iOS 14.0, *) {
            self.dob_date_Picker.tintColor = .black
            self.dob_date_Picker.preferredDatePickerStyle = .wheels
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
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - Validation and API Calling
extension EditProfileVC {
    
    func validateDataAndUpdateOnServer() {
        
        let strname = self.dic_Param["name"] as? String ?? ""
        let stremail = self.dic_Param["email"] as? String ?? ""
        let strMobile = self.dic_Param["mobile"] as? String ?? ""
        
        let strHeightUnit = self.dic_Param[SideMenuOptionsKey.kheightUnit.rawValue] as? String ?? ""
        let strWeightUnit = self.dic_Param[SideMenuOptionsKey.kweightUnit.rawValue] as? String ?? ""
        let strHeightInFeet = self.dic_Param[SideMenuOptionsKey.kheight_ft.rawValue] as? String ?? ""
        let strHeightInInch = self.dic_Param[SideMenuOptionsKey.kheight_in.rawValue] as? String ?? ""
        let strHeightInCm = self.dic_Param[SideMenuOptionsKey.kheight_cm.rawValue] as? String ?? ""
        let strWeight = self.dic_Param[SideMenuOptionsKey.kweight.rawValue] as? String ?? ""
        
        if strname == "" {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter username.".localized(), controller: self)
            return
        }
        
        if stremail == "" {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter email.".localized(), controller: self)
            return
        }
        
        guard isValidEmail(testStr: stremail) else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter valid email.".localized(), controller: self)
            return
        }
        
        if strMobile == "" || !(strMobile != "" && strMobile.count >= 10) {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter valid mobile number.".localized(), controller: self)
            return
        }
        
        if strHeightUnit.lowercased() == "feet" {
            if strHeightInFeet == "" || strHeightInInch == "" {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter height".localized(), controller: self)
                return
            }
        }
        else {
            if strHeightInCm == "" {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter height".localized(), controller: self)
                return
            }
        }
        
        if strWeight == "" {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter weight".localized(), controller: self)
            return
        }

        updateDetailsOnServer(height_Unit: strHeightUnit, weight_Unit: strWeightUnit, heightInFeet: strHeightInFeet, heightInInch: strHeightInInch, heightInCM: strHeightInCm, str_weight: strWeight)
    }
    
    func updateDetailsOnServer(height_Unit: String, weight_Unit: String, heightInFeet: String, heightInInch: String, heightInCM: String, str_weight: String) {
        if Utils.isConnectedToNetwork() {
            var height = 0.0
            if height_Unit == "feet" {
                let heightInFeet = Double(heightInFeet) ?? 0
                let heightInInch = Double(heightInInch) ?? 0
                height = heightInFeet * 30.48 + heightInInch * 2.54
            } else {
                height = (Double(heightInCM) ?? 0)
            }
            
            var weight = str_weight
            if weight_Unit == "Pound" {
                weight = Utils.convertPoundsToKg(lb: str_weight)
            }
            
            let userMeasurements = "[\"\(height)\",\"\(weight)\",\"\(height_Unit)\",\"\(weight_Unit)\"]"

            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let strDOB = self.dic_Param[SideMenuOptionsKey.kDOB.rawValue] as? String ?? ""
            let strName = self.dic_Param[SideMenuOptionsKey.kName.rawValue] as? String ?? ""
            let strEmail = self.dic_Param[SideMenuOptionsKey.kEmail.rawValue] as? String ?? ""
            let strMobile = self.dic_Param[SideMenuOptionsKey.kMobile.rawValue] as? String ?? ""
            let str_Gender = (self.dic_Param[SideMenuOptionsKey.kGender.rawValue] as? String ?? "").capitalized
            
            let urlString = kBaseNewURL + endPoint.updateuserdata.rawValue
            
            let params = ["user_name": strName,
                          //"user_id": kSharedAppDelegate.userId,
                          "user_mobile": strMobile,
                          "user_email": strEmail,
                          "gender": str_Gender,
                          "user_dob": strDOB,
                          "user_measurements": userMeasurements,
                          "countrycode": self.countryCodes,
                          "country": self.countryName]
            
            debugPrint(params)

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON { response in
                
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    debugPrint("API Name: ===>>\(urlString),\n Params=====>>\(params),\nHeader:=====>>\(self.headers)\n\nResponse:=====>>\(response)")
                    
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    let status = dicResponse["status"] as? String
                    if status == "Success" {
                        Utils.showAlertWithTitleInControllerWithCompletion("Success".localized(), message: "Updated successfully".localized(), okTitle: "Ok".localized(), controller: self, completionHandler: {
                            
                            guard var empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
                                return
                            }
                            empData["name"] = strName
                            empData["email"] = strEmail
                            empData["mobile"] = strMobile
                            empData["dob"]  = strDOB
                            empData["measurements"] = userMeasurements
                            empData["gender"] = str_Gender
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
          

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).responseJSON { response in
                
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
                            self.tbl_View.reloadData()
                        }
                        Utils.showAlertWithTitleInControllerWithCompletion("Success".localized(), message: "Updated successfully".localized(), okTitle: "Ok".localized(), controller: self, completionHandler: {
                            //self.navigationController?.popViewController(animated: true)
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
                    self.tbl_View.reloadData()
                    self.hideActivityIndicator()
                case .failure(let error):
                    print(error)
                    self.hideActivityIndicator()
                }
            }
        }
    }

}


//MARK: - UITableView Delegate DataSource Method
extension EditProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_Section.removeAll()
        
        self.arr_Section.append(D_SideMenuData.init(key: .kheader, title: .none, identifier: .header))
        self.arr_Section.append(D_SideMenuData.init(key: .kMobile, title: .kMobile, identifier: .textField))
        self.arr_Section.append(D_SideMenuData.init(key: .kEmail, title: .kEmail, identifier: .textField))
        
        self.arr_Section.append(D_SideMenuData.init(key: .knone, title: .N_none, identifier: .blank))
        self.arr_Section.append(D_SideMenuData.init(key: .none, title: .kPersonalDetails, identifier: .titleHeader))
        
        self.arr_Section.append(D_SideMenuData.init(key: .kName, title: .kName, identifier: .textField))
        self.arr_Section.append(D_SideMenuData.init(key: .kGender, title: .kGender, identifier: .gender))
        
        self.arr_Section.append(D_SideMenuData.init(key: .kheight, title: .kHeight, identifier: .height_weightTextfield))
        self.arr_Section.append(D_SideMenuData.init(key: .kweight, title: .kWeight, identifier: .height_weightTextfield))
        
        self.arr_Section.append(D_SideMenuData.init(key: .kDOB, title: .kDOB, identifier: .textField))
        
        self.arr_Section.append(D_SideMenuData.init(key: .none, title: .kSaveChanges, identifier: .button))
        
        self.tbl_View.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let str_ID = self.arr_Section[indexPath.row].identifier
        let str_Key = self.arr_Section[indexPath.row].key ?? .knone
        let str_Title = self.arr_Section[indexPath.row].title ?? .none
        
        if str_ID == .header {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileHeaderTableCell", for: indexPath) as! EditProfileHeaderTableCell
            cell.selectionStyle = .none
            cell.img_Profile.layer.cornerRadius = 50
            cell.img_Profile.layer.masksToBounds = true
            
            if let urlString = kUserDefaults.value(forKey: kUserImage) as? String, let url = URL(string: urlString) {
                cell.img_Profile.sd_setImage(with: url, placeholderImage: UIImage.init(named: "icon_user_default_avtar"), progress: nil)
            }
            
            if UserDefaults.user.is_main_subscription {
                cell.img_Profile.layer.borderWidth = 2
                cell.img_Profile.layer.borderColor = UIColor.fromHex(hexString: "#F9B014").cgColor
                cell.view_Pro.isHidden = false
            }
            else {
                cell.view_Pro.isHidden = true
                cell.img_Profile.layer.borderWidth = 0
            }
            
            cell.didTappedonAddPhoto = { (sender) in
                self.showImagePickerActionSheet()
            }

            return cell
            
        }
        else if str_ID == .textField {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterFieldTableCell", for: indexPath) as! RegisterFieldTableCell
            cell.selectionStyle = .none
            cell.txt_Field.delegate = self
            cell.view_countryBG.isHidden = true
            cell.txt_Field_Mobile.isHidden = true
            cell.txt_Field_Mobile.delegate = self
            cell.lbl_Title.text = str_Title?.rawValue
            cell.txt_Field.keyboardType = .default
            cell.txt_Field.accessibilityHint = str_Key.rawValue
            cell.txt_Field_Mobile.accessibilityHint = str_Key.rawValue
            cell.txt_Field_Mobile.keyboardType = .phonePad
            cell.constraint_lbl_Title_TOP.constant = 12
            cell.constraint_view_TextFieldBg_Height.constant = 50
            

            //Set Keyboard TYPE
            if str_Key == .kMobile {
                cell.txt_Field.isHidden = true
                cell.btn_Verify.isHidden = true
                cell.view_countryBG.isHidden = false
                cell.txt_Field_Mobile.isHidden = false
                cell.txt_Field.keyboardType = .phonePad
                
                var empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] ?? [:]
                let str_ExistingMobile = empData["mobile"] as? String ?? ""
                let str_Phone = self.dic_Param[str_Key.rawValue] as? String ?? ""
                if str_ExistingMobile.trimed() == "" {
                    cell.txt_Field_Mobile.keyboardType = .phonePad
                    cell.view_countryBG.isUserInteractionEnabled = true
                    cell.txt_Field_Mobile.isUserInteractionEnabled = true
                }
                else {
                    cell.view_countryBG.isUserInteractionEnabled = false
                    cell.txt_Field_Mobile.isUserInteractionEnabled = false
                }
                cell.txt_Field_Mobile.text = str_Phone
                cell.lbl_countryCode.text = "+" + (self.dic_Param["countrycode"] as? String ?? "")
                
            }
            else if str_Key == .kEmail {
                cell.btn_Verify.isHidden = false
                cell.txt_Field.isHidden = false
                cell.view_countryBG.isHidden = true
                cell.txt_Field_Mobile.isHidden = true
                cell.txt_Field.keyboardType = .emailAddress
                cell.txt_Field.isUserInteractionEnabled = false
                cell.txt_Field.text = self.dic_Param[str_Key.rawValue] as? String ?? ""
                
                let emailVerifyStatus = (kUserDefaults.value(forKey: kEmailVerifyStatus) as? String) ?? "0"
                if emailVerifyStatus == "1" {
                    cell.btn_Verify.isHidden = true
                } else {
                    //set true if you want to change email before verify it
                    cell.btn_Verify.isHidden = false
                }
                
            }
            else {
                cell.btn_Verify.isHidden = true
                cell.txt_Field.isHidden = false
                cell.view_countryBG.isHidden = true
                cell.txt_Field_Mobile.isHidden = true
                cell.txt_Field.keyboardType = .default
                cell.txt_Field.isUserInteractionEnabled = true
                cell.txt_Field.placeholder = str_Key == .kName ? "Enter your name" : "Enter your Date of birth"
                cell.txt_Field.text = self.dic_Param[str_Key.rawValue] as? String ?? ""
            }
            
            cell.didTappedVerify = { (sender) in
                print("verify email now")
                let str_Email = self.dic_Param["email"] as? String ?? ""
                if str_Email != "" {
                    self.showActivityIndicator()
                    self.emailVerifyFromServer(email: str_Email) { [weak self] (isSuccess, title, message) in
                        self?.hideActivityIndicator()
                        self?.showAlert(title: title, message: message)
                    }
                }
            }
            
            cell.didTappedCountry = { (sender) in
                self.view.endEditing(true)
                let objDialouge = CountrySelectionVC(nibName:"CountrySelectionVC", bundle:nil)
                objDialouge.delegate = self
                self.addChild(objDialouge)
                objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                self.view.addSubview((objDialouge.view)!)
                objDialouge.didMove(toParent: self)
            }
            

            return cell
        }
        else if str_ID == .height_weightTextfield {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeightWeightTableCell", for: indexPath) as! HeightWeightTableCell
            cell.selectionStyle = .none
            cell.txt_Field.delegate = self
            cell.txt_Feet.delegate = self
            cell.txt_Inch.delegate = self
            cell.lbl_Title.text = str_Title?.rawValue
            cell.txt_Field.keyboardType = .numberPad
            cell.view_Height_TextFieldBg.isHidden = true
            cell.txt_Field.accessibilityHint = str_Key.rawValue
            cell.btn1.accessibilityHint = str_Key.rawValue
            cell.btn2.accessibilityHint = str_Key.rawValue
            cell.txt_Field.text = self.dic_Param[str_Key.rawValue] as? String ?? ""
            
            
            if str_Key == .kweight {
                cell.view_Height_TextFieldBg.isHidden = true
                cell.lbl_btnTitle1.text = HeightWeigtType.kg.rawValue
                cell.lbl_btnTitle2.text = HeightWeigtType.lbs.rawValue
                cell.txt_Field.accessibilityHint = SideMenuOptionsKey.kweight.rawValue
                
                let weightUnit = self.dic_Param[SideMenuOptionsKey.kweightUnit.rawValue] as? String ?? ""
                if weightUnit == SideMenuOptionsKey.kweight_kg.rawValue {
                    cell.lbl_btnTitle1.textColor = UIColor.white
                    cell.lbl_btnTitle2.textColor = AppColor.app_GreenColor
                    cell.btn1.backgroundColor = AppColor.app_GreenColor
                    cell.btn2.backgroundColor = UIColor.white
                }
                else {
                    cell.lbl_btnTitle2.textColor = UIColor.white
                    cell.lbl_btnTitle1.textColor = AppColor.app_GreenColor
                    cell.btn2.backgroundColor = AppColor.app_GreenColor
                    cell.btn1.backgroundColor = UIColor.white
                }
            }
            else if str_Key == .kheight {
                cell.lbl_btnTitle1.text = HeightWeigtType.ft.rawValue
                cell.lbl_btnTitle2.text = HeightWeigtType.cm.rawValue
                
                let heightUnit = self.dic_Param[SideMenuOptionsKey.kheightUnit.rawValue] as? String ?? ""
                if heightUnit == SideMenuOptionsKey.kheight_ft.rawValue {
                    cell.view_Height_TextFieldBg.isHidden = false
                    cell.lbl_btnTitle1.textColor = .white
                    cell.lbl_btnTitle2.textColor = AppColor.app_GreenColor
                    cell.btn1.backgroundColor = AppColor.app_GreenColor
                    cell.btn2.backgroundColor = UIColor.white
                    cell.txt_Feet.accessibilityHint = SideMenuOptionsKey.kheight_ft.rawValue
                    cell.txt_Inch.accessibilityHint = SideMenuOptionsKey.kheight_in.rawValue
                    cell.txt_Feet.text = self.dic_Param[SideMenuOptionsKey.kheight_ft.rawValue] as? String ?? ""
                    cell.txt_Inch.text = self.dic_Param[SideMenuOptionsKey.kheight_in.rawValue] as? String ?? ""
                }
                else {
                    cell.view_Height_TextFieldBg.isHidden = true
                    cell.lbl_btnTitle2.textColor = .white
                    cell.lbl_btnTitle1.textColor = AppColor.app_GreenColor
                    cell.btn2.backgroundColor = AppColor.app_GreenColor
                    cell.btn1.backgroundColor = UIColor.white
                    cell.txt_Field.accessibilityHint = SideMenuOptionsKey.kheight_cm.rawValue
                    cell.txt_Field.text = self.dic_Param[SideMenuOptionsKey.kheight_cm.rawValue] as? String ?? ""
                }
            }
                

            cell.didTappedButton = {(sender) in
                if sender.tag == 111 {
                    if str_Key == .kweight {
                        self.dic_Param[SideMenuOptionsKey.kweightUnit.rawValue] = "Kilogram"
                        
                        let getPoun = self.dic_Param[SideMenuOptionsKey.kweight.rawValue] as? String ?? ""
                        if getPoun != "" {
                            self.dic_Param[SideMenuOptionsKey.kweight.rawValue] = Utils.convertPoundsToKg(lb: getPoun)
                        }
                        else {
                            self.dic_Param[SideMenuOptionsKey.kweight.rawValue] = ""
                        }
                    }
                    else {
                        self.dic_Param[SideMenuOptionsKey.kheightUnit.rawValue] = "feet"
                        let getCM = self.dic_Param[SideMenuOptionsKey.kheight_cm.rawValue] as? String ?? ""
                        if getCM != "" {
                            let cms: Double = Double(getCM) ?? 0.0
                            let heightMeasure = Utils.convertHeightInFtIn(cms: cms)
                            self.dic_Param[SideMenuOptionsKey.kheight_ft.rawValue] = "\(heightMeasure.0)"
                            self.dic_Param[SideMenuOptionsKey.kheight_in.rawValue] = "\(heightMeasure.1)"
                            //self.convertCMtoFT(centimeter: cms)
                        }
                        else {
                            self.dic_Param[SideMenuOptionsKey.kheight_ft.rawValue] = ""
                            self.dic_Param[SideMenuOptionsKey.kheight_in.rawValue] = ""
                        }
                    }
                }
                else {
                    if str_Key == .kweight {
                        self.dic_Param[SideMenuOptionsKey.kweightUnit.rawValue] = "Pound"
                        
                        let getWeight = self.dic_Param[SideMenuOptionsKey.kweight.rawValue] as? String ?? ""
                        if getWeight != "" {
                            self.dic_Param[SideMenuOptionsKey.kweight.rawValue] = Utils.convertKgToPounds(kg: getWeight)
                        }
                        else {
                            self.dic_Param[SideMenuOptionsKey.kweight.rawValue] = ""
                        }
                    }
                    else {
                        Shared.sharedInstance.isInFt = false
                        self.dic_Param[SideMenuOptionsKey.kheightUnit.rawValue] = "Centimeter"
                        let strFT = self.dic_Param[SideMenuOptionsKey.kheight_ft.rawValue] as? String ?? ""
                        let strIN = self.dic_Param[SideMenuOptionsKey.kheight_in.rawValue] as? String ?? ""
                        if strFT != "" && strIN != "" {
                            let getcm = Utils.convertHeightInCms(ft: strFT, inc: strIN)
                            self.dic_Param[SideMenuOptionsKey.kheight_cm.rawValue] = "\(getcm)"
                        }
                        else {
                            self.dic_Param[SideMenuOptionsKey.kheight_cm.rawValue] = ""
                        }
                    }
                }
                self.tbl_View.reloadData()
            }
            
            
            return cell
        }
        else if str_ID == .gender {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GenderTableCell", for: indexPath) as! GenderTableCell
            cell.selectionStyle = .none
            cell.lbl_Title.text = str_Title?.rawValue
            
            let strGender = self.dic_Param[SideMenuOptionsKey.kGender.rawValue] as? String ?? ""
            if strGender.lowercased() == "female" {
                cell.lbl_female.textColor = .white
                cell.btn_male.backgroundColor = .white
                cell.lbl_male.textColor = AppColor.app_GreenColor
                cell.btn_female.backgroundColor = AppColor.app_GreenColor
                
                let image_male = cell.img_male.image?.withRenderingMode(.alwaysTemplate)
                cell.img_male.image = image_male
                cell.img_male.tintColor = AppColor.app_GreenColor
                
                let image_female = cell.img_female.image?.withRenderingMode(.alwaysTemplate)
                cell.img_female.image = image_female
                cell.img_female.tintColor = .white
                
            }
            else {
                cell.lbl_male.textColor = .white
                cell.btn_female.backgroundColor = .white
                cell.lbl_female.textColor = AppColor.app_GreenColor
                cell.btn_male.backgroundColor = AppColor.app_GreenColor
                
                let image_male = cell.img_male.image?.withRenderingMode(.alwaysTemplate)
                cell.img_male.image = image_male
                cell.img_male.tintColor = .white
                
                let image_female = cell.img_female.image?.withRenderingMode(.alwaysTemplate)
                cell.img_female.image = image_female
                cell.img_female.tintColor = AppColor.app_GreenColor
            }
            
            //Male Female Tapped==================================================//
            cell.didTappedonMaleFemale = { (sender) in
                if sender.tag == 222 {//For Female
                    self.dic_Param[SideMenuOptionsKey.kGender.rawValue] = "female"
                }
                else {//For male
                    self.dic_Param[SideMenuOptionsKey.kGender.rawValue] = "male"
                }
                self.tbl_View.reloadData()
            }
            //*******************************************************************//
            
            return cell
            
        }
        else if str_ID == .titleHeader {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleHeaderTableCell", for: indexPath) as! TitleHeaderTableCell
            cell.selectionStyle = .none
            cell.lbl_Title.text = str_Title?.rawValue
            
            return cell
            
        }
        else if str_ID == .blank {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuBlankTableCell", for: indexPath) as! SideMenuBlankTableCell
            cell.selectionStyle = .none
            
            return cell
            
        }
        else if str_ID == .button {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuButtonTableCell", for: indexPath) as! SideMenuButtonTableCell
            cell.selectionStyle = .none
            cell.lbl_logout.text = str_Title?.rawValue
            
            //Save Changes Button Tapped===========//
            cell.didTappedonLogout = {(sender) in
                self.check_mobileEntered_orNot()
            }
            //========================================//
            
            return cell
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func convertCMtoFT(centimeter: Double) {
        let INCH_IN_CM = 2.54
        let numInches = roundf(Float(centimeter / INCH_IN_CM))
        let feet = Int(numInches / 12);
        let inches = Int(numInches.truncatingRemainder(dividingBy: 12.0))  //% 12.0;
        self.dic_Param[SideMenuOptionsKey.kheight_ft.rawValue] = "\(feet)"
        self.dic_Param[SideMenuOptionsKey.kheight_in.rawValue] = "\(inches)"
    }
    
    func showFootAndInchesFromCm(_ cms: Double) -> String {

          let feet = cms * 0.0328084
          let feetShow = Int(floor(feet))
          let feetRest: Double = ((feet * 100).truncatingRemainder(dividingBy: 100) / 100)
          let inches = Int(floor(feetRest * 12))

          return "\(feetShow)' \(inches)\""
    }
    
    //MARK: - Country Selection
    func selectCountry(screenFrom: String, is_Pick: Bool, selectedCountry: Country?) {
        if is_Pick {
            self.countryCodes = selectedCountry?.phoneCode ?? "91"
            self.countryName = selectedCountry?.name ?? "India"
            
            if self.countryCodes.contains("+") {
                self.countryCodes = self.countryCodes.replacingOccurrences(of: "+", with: "")
            }
            self.dic_Param["country"] = self.countryName
            self.dic_Param["countrycode"] = self.countryCodes
            self.tbl_View.reloadData()
        }
    }
    
    func check_mobileEntered_orNot() {
        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            return
        }
        let str_enteredMobile = empData["mobile"] as? String ?? ""
        if str_enteredMobile == "" {
            self.verifyMobileNumber()
        }
        else {
            self.validateDataAndUpdateOnServer()
        }
    }
    
    func verifyMobileNumber() {
        if Utils.isConnectedToNetwork() {
            //Firebase OTP generator
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let str_mobile = self.dic_Param["mobile"] as? String ?? ""
            let str_country = "+" + (self.dic_Param["countrycode"] as? String ?? "")
            
            let phone = str_country + str_mobile
            PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationID, error) in
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                if let error = error {
                    print("### OTP error : ", error.localizedDescription)
                    Utils.showAlertWithTitleInController("Error".localized(), message: "Please enter valid mobile number.".localized(), controller: self)
                    return
                }
                let objDialouge = OTPDialogVC(nibName:"OTPDialogVC", bundle:nil)
                objDialouge.super_vc = self
                objDialouge.delegate = self
                objDialouge.is_NewUser = false
                objDialouge.screen_from = .from_ediProfile
                objDialouge.strMobileNo = str_mobile
                objDialouge.strCountryCode = str_country
                objDialouge.verificationID = verificationID ?? ""
                self.addChild(objDialouge)
                objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
                self.view.addSubview((objDialouge.view)!)
                objDialouge.didMove(toParent: self)
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func otp_verified_continue(_ success: Bool) {
        if success {
            self.validateDataAndUpdateOnServer()
        }
    }
}

//MARK: - PICKER DELEGATE, TEXTFIELD DELEGATE
extension EditProfileVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let strKey = textField.accessibilityHint {
            if strKey == "dob" {
                let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
                numberToolbar.barStyle = .default
                numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                                       UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneDatePicker))]
                numberToolbar.sizeToFit()
                textField.inputAccessoryView = numberToolbar
                textField.inputView = self.dob_date_Picker
            }
            else {
                textField.inputAccessoryView = nil
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let strKey = textField.accessibilityHint {
            if strKey != "dob" {
                self.dic_Param[strKey] = textField.text ?? ""
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let strKey = textField.accessibilityHint {
            if strKey == "mobile" {
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
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    @objc func doneDatePicker() {
        self.view.endEditing(true)
        self.tbl_View.reloadData()
    }
    
    @objc func datePickerDidBirthday(_ sender: UIDatePicker) {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy"
        self.dic_Param["dob"] = dateFormat.string(from: sender.date)
    }
}

//MARK: - UIIMAGEPICKED DELEGATE
extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerActionSheet(isCancelVisible:Bool = true) {
        
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
