//
//  SideMenuVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 11/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

class D_SideMenuData {
    var key: SideMenuOptionsKey?
    var title: SideMenuOptionsName?
    var identifier: SideMenuOptionIDs
    
    internal init(key: SideMenuOptionsKey? = nil, title: SideMenuOptionsName? = nil, identifier: SideMenuOptionIDs = .other) {
        self.key = key
        self.title = title
        self.identifier = identifier
    }
}


import UIKit
import Alamofire

class SideMenuVC: UIViewController {

    var arr_Section = [D_SideMenuData]()
    @IBOutlet weak var tbl_View: UITableView!
    
    var headers: HTTPHeaders {
        get {
            return ["Authorization": Utils.getAuthToken()]
        }
    }
    let healthStore = HealthKitManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Register Table Cell
        self.tbl_View.register(nibWithCellClass: SideMenuOptionTableCell.self)
        self.tbl_View.register(nibWithCellClass: SideMenuHeaderTableCell.self)
        self.tbl_View.register(nibWithCellClass: SideMenuBlankTableCell.self)
        self.tbl_View.register(nibWithCellClass: SideMenuButtonTableCell.self)
        
        manageSection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUIForMyActivePlan()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func updateUIForMyActivePlan() {
        var is_subscribed = true
        if UserDefaults.user.is_main_subscription {
            is_subscribed = true
        }
        else if UserDefaults.user.is_facenaadi_subscribed ||
                    UserDefaults.user.is_finger_subscribed ||
                    UserDefaults.user.is_ayumonk_subscribed ||
                    UserDefaults.user.is_remedies_subscribed ||
                    UserDefaults.user.is_diet_plan_subscribed {
            is_subscribed = true
        }
        
        if let indx = self.arr_Section.firstIndex(where: { menu_data in
            return menu_data.key == .kMyAcPlan
        }) {
            if is_subscribed == false {
                self.arr_Section.remove(at: indx)
            }
        }
        else {
            if is_subscribed {
                self.arr_Section.insert(D_SideMenuData.init(key: .kMyAcPlan, title: .kMyAcPlan, identifier: .label), at: 4)
            }
        }
        self.tbl_View.reloadData()
        
        
        
//        if UserDefaults.user.is_main_subscription {
//            if self.arr_Section.contains(where: { menu_data in
//                return menu_data.key == .kMyAcPlan
//            }) {
//            }
//            else {
//                self.arr_Section.insert(D_SideMenuData.init(key: .kMyAcPlan, title: .kMyAcPlan, identifier: .label), at: 4)
//            }
//        }
//        else if UserDefaults.user.is_main_subscription {
//            if let indx = self.arr_Section.firstIndex(where: { menu_data in
//                return menu_data.key == .kMyAcPlan
//            }) {
//                self.arr_Section.remove(at: indx)
//            }
//        }
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

//MARK: - UITableView Delegate DataSource Method
extension SideMenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_Section.removeAll()
        
        self.arr_Section.append(D_SideMenuData.init(key: .kheader, title: .N_none, identifier: .header))
        self.arr_Section.append(D_SideMenuData.init(key: .kResult_His, title: .kResult_His, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kMyBooking, title: .kMyBooking, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kMyList, title: .kMyList, identifier: .label))
        //self.arr_Section.append(D_SideMenuData.init(key: .kMyAcPlan, title: .kMyAcPlan, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kAppleHealth, title: .kAppleHealth, identifier: .label))
        
        //Temp Added
        if is_APP_LIVE == false {
            self.arr_Section.append(D_SideMenuData.init(key: .kRemove_Subscription, title: .kRemoveSubscription, identifier: .label))
        }
        //*********************************************//

        self.arr_Section.append(D_SideMenuData.init(key: .none, title: .N_none, identifier: .blank))
        
        /*
         //Remove Shop Section as per Sandeep
        if Locale.current.isCurrencyCodeInINR {
            self.arr_Section.append(D_SideMenuData.init(key: .kMyAddress, title: .kMyAddress, identifier: .label))
            self.arr_Section.append(D_SideMenuData.init(key: .kMyOrder, title: .kMyOrder, identifier: .label))
            self.arr_Section.append(D_SideMenuData.init(key: .kMyCart, title: .kMyCart, identifier: .label))
            self.arr_Section.append(D_SideMenuData.init(key: .kWishlist, title: .kWishlist, identifier: .label))
            //self.arr_Section.append(D_SideMenuData.init(key: .kMyReward, title: .kMyReward, identifier: .label))
            self.arr_Section.append(D_SideMenuData.init(key: .kMyWallet, title: .kMyWallet, identifier: .label))
        }
        */
        self.arr_Section.append(D_SideMenuData.init(key: .none, title: .N_none, identifier: .blank))
        
        self.arr_Section.append(D_SideMenuData.init(key: .kReferEarn, title: .kReferEarn, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kContactUs, title: .kContactUs, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kAccSetting, title: .kAccSetting, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kLogout, title: .kLogout, identifier: .button))
        
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
        let str_Title = self.arr_Section[indexPath.row].title
        
        if str_ID == .header {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuHeaderTableCell", for: indexPath) as! SideMenuHeaderTableCell
            cell.selectionStyle = .none
            
            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                cell.lbl_name.text = empData["name"] as? String ?? ""
                cell.lbl_email.text = empData["email"] as? String ?? ""
                cell.lbl_mobile.text = empData["mobile"] as? String ?? ""
            }
            
            if let urlString = kUserDefaults.value(forKey: kUserImage) as? String, let url = URL(string: urlString) {
                cell.img_profile.sd_setImage(with: url, placeholderImage: UIImage.init(named: "icon_user_default_avtar"), progress: nil)
            }
            
            if UserDefaults.user.is_main_subscription {
                cell.img_profile.layer.borderWidth = 2
                cell.img_profile.layer.borderColor = UIColor.fromHex(hexString: "#F9B014").cgColor
                cell.view_Pro.isHidden = false
            }
            else {
                cell.view_Pro.isHidden = true
                cell.img_profile.layer.borderWidth = 0
            }
            
            
            
            return cell
            
        }
        else if str_ID == .label {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuOptionTableCell", for: indexPath) as! SideMenuOptionTableCell
            cell.selectionStyle = .none
            cell.lbl_title.text = str_Title?.rawValue.localized()
            
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
            cell.lbl_logout.text = str_Title?.rawValue.localized()
            
            //Log out tapped
            cell.didTappedonLogout = { (sender) in
                self.logOutTapped()
            }
            
            return cell
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let objNavVC = self.navigationController else {
            return
        }
        objNavVC.isNavigationBarHidden = false
        
        guard Utils.isConnectedToNetwork() else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
            return
        }
        
        let str_Key = self.arr_Section[indexPath.row].key
        if str_Key == .kheader {
            
            self.pleaseRegisterFirst("to view your profile.")
            
            let obj = Story_SideMenu.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
            objNavVC.pushViewController(obj, animated: true)
        }
        else if str_Key == .kResult_His {
            // Result History
            
            self.pleaseRegisterFirst("to view your result history.")
            
            let storyBoard = UIStoryboard(name:"ResultHistory", bundle:nil)
            guard let resultHistoryViewController = storyBoard.instantiateViewController(withIdentifier: "ResultHistoryViewController") as? ResultHistoryViewController else {
                return
            }
            objNavVC.pushViewController(resultHistoryViewController, animated: true)
        }
        else if str_Key == .kMyBooking {
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please register first to sync Apple Health.".localized(), controller: self)
                return
            }
            
            let storyBoard = UIStoryboard(name: "Booking", bundle: nil)
            guard let myBookingVC = storyBoard.instantiateViewController(withIdentifier: "MyBookingViewController") as? MyBookingViewController else {
                return
            }
            objNavVC.pushViewController(myBookingVC, animated: true)
        }
        else if str_Key == .kMyList {
            
            self.pleaseRegisterFirst("to view My List section.")
            
            //If registered but not given test
            if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil && kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti and Vikriti assessment to view recommendations".localized(), controller: self)
                return
            } else if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti assessment to view recommendations".localized(), controller: self)
                return
            } else if kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Vikriti assessment to view recommendations".localized(), controller: self)
                return
            }
            
            let storyBoard = UIStoryboard(name: "MyLists", bundle: nil)
            guard let myListVC = storyBoard.instantiateViewController(withIdentifier: "MyListsViewController") as? MyListsViewController else {
                return
            }
            objNavVC.pushViewController(myListVC, animated: true)
        }
        else if str_Key == .kMyAcPlan {
            
            //If User Subscribe Main Subscription
            if UserDefaults.user.is_main_subscription {
                let vc = ActiveSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
                objNavVC.pushViewController(vc, animated: true)
                return
            }
            else {
                let vc = ActiveExtraPlanVC.instantiate(fromAppStoryboard: .Subscription)
                objNavVC.pushViewController(vc, animated: true)
                return
            }
            
        }
        else if str_Key == .kAppleHealth {
            self.navigationController?.isNavigationBarHidden = true
            self.pleaseRegisterFirst("to sync Apple Health.")
            
            healthStore.checkAuthorizationStatusAndGetHealthParameters(fromVC: self, isAllParamReqired: true) { heightInCmString, weightInKgsString, dob, gender in
                guard let dob = dob, let heightInCmString = heightInCmString, let weightInKgsString = weightInKgsString else {
                    print("!!! All health kit data not provided by user")
                    self.healthStore.showOpenHealthKitSettingAlert(fromVC: self)
                    return
                }
                
                self.syncHealthKit(dob, gender, heightInCmString, weightInKgsString)
            }
            return
        }        
        else if str_Key == .kMyAddress {
            
            let vcMyAddress = MPMyAddressVC.instantiate(fromAppStoryboard: .MarketPlace)
            objNavVC.pushViewController(vcMyAddress, animated: true)
            
        }
        else if str_Key == .kMyOrder {
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view my orders".localized(), controller: self)
                return
            }
            
            let obj_MyOrder = MPMyOrderVC.instantiate(fromAppStoryboard: .MarketPlace)
            objNavVC.pushViewController(obj_MyOrder, animated: true)
            
        }
        else if str_Key == .kMyCart {
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view cart".localized(), controller: self)
                return
            }
            
            let obj_myCart = MPCartVC.instantiate(fromAppStoryboard: .MarketPlace)
            objNavVC.pushViewController(obj_myCart, animated: true)
            
        }
        else if str_Key == .kWishlist {
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view favourite".localized(), controller: self)
                return
            }
            
            let obj_myFavorite = MPFavoriteVC.instantiate(fromAppStoryboard: .MarketPlace)
            objNavVC.pushViewController(obj_myFavorite, animated: true)
            
        }
        else if str_Key == .kMyReward {
        }
        else if str_Key == .kMyWallet {
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view wallet".localized(), controller: self)
                return
            }
            
            let vc = MPWalletVC.instantiate(fromAppStoryboard: .MarketPlace)
            objNavVC.pushViewController(vc, animated: true)
            
        }
        else if str_Key == .kReferEarn {
            self.navigationController?.isNavigationBarHidden = true
            
            let obj = Story_SideMenu.instantiateViewController(withIdentifier: "ReferEarnVC") as! ReferEarnVC
            objNavVC.pushViewController(obj, animated: true)
        }
        else if str_Key == .kContactUs {
            
            let obj = Story_Profile.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            objNavVC.pushViewController(obj, animated: true)
            
        }
        else if str_Key == .kAccSetting {
            let vc = AccountSettingVC.instantiate(fromAppStoryboard: .SideMenu)
            objNavVC.pushViewController(vc, animated: true)
        }
        else if str_Key == .kRemove_Subscription {
            let vc = RemoveSubscriptionVC.instantiate(fromAppStoryboard: .FaceNaadi)
            objNavVC.pushViewController(vc, animated: true)
        }
        
    }
    
    func pleaseRegisterFirst(_ strText: String) {
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please register first \(strText).".localized(), controller: self)
            return
        }
    }
    
    func logOutTapped() {
        guard Utils.isConnectedToNetwork() else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
            return
        }
        Utils.showAlertWithTitleInControllerWithCompletion("", message: "Are you sure you want to logout?".localized(), cancelTitle: "No".localized(), okTitle: "Yes".localized(), controller: self, completionHandler: {
            Self.clearUserDefaultsData()
            kUserDefaults.synchronize()
            kSharedAppDelegate.showLoginScreen()
        }) {
        }
    }
    
    func syncHealthKit(_ dateOfBirth:String,_ gender : String,_ height : String,_ weight : String) {
        if Utils.isConnectedToNetwork() {
            let userMeasurements = "[\"\(height)\",\"\(weight)\",\"\("Centimeter")\",\"\("Kilogram")\"]"

            guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
                return
            }

            let urlString = kBaseNewURL + endPoint.updateuserdata.rawValue
            let params = ["user_name": empData["name"] as? String ?? "", "user_id": kSharedAppDelegate.userId, "user_mobile": empData["mobile"] as? String ?? "", "user_email": empData["email"] as? String ?? "", "gender": gender,"user_dob":dateOfBirth , "user_measurements": userMeasurements]
            showActivityIndicator()
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON { response in
                
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    self.hideActivityIndicator()
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    if dicResponse["status"] as? String ?? "" == "Success" {
                        
                        guard var empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
                            return
                        }
                        empData["name"] = empData["name"] as? String ?? ""
                        empData["email"] = empData["email"] as? String ?? ""
                        empData["mobile"] = empData["mobile"] as? String ?? ""
                        empData["dob"]  = dateOfBirth
                        empData["measurements"] = userMeasurements
                        empData["gender"] = gender
                        kUserDefaults.set(empData, forKey: USER_DATA)
                        kUserDefaults.synchronize()
                    }
                    Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["Message"] as? String ?? "Failed to update details.".localized()), controller: self)
                    
                case .failure(let error):
                    print(error)
                    self.hideActivityIndicator()
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
}


//MARK: - Clear UserDefault
extension SideMenuVC {
    
    static func clearUserDefaultsData() {
        kUserDefaults.set(nil, forKey: IS_LOGGEDIN)
        kUserDefaults.set(nil, forKey: USER_DATA)
        kUserDefaults.set(nil, forKey: kUserImage)
        kUserDefaults.set(nil, forKey: VIKRITI_PRASHNA)
        kUserDefaults.set(nil, forKey: VIKRITI_DARSHNA)
        kUserDefaults.set(nil, forKey: VIKRITI_SPARSHNA)
        kUserDefaults.set(nil, forKey: RESULT_PRAKRITI)
        kUserDefaults.set(nil, forKey: RESULT_VIKRITI)
        kUserDefaults.set(false, forKey: kVikritiSparshanaCompleted)
        kUserDefaults.set(false, forKey: kVikritiPrashnaCompleted)
        kUserDefaults.set(nil, forKey: kPrakritiAnswers)
        kUserDefaults.set(nil, forKey: kSkippedQuestions)
        kUserDefaults.set(nil, forKey: kUserMeasurementData)
        kUserDefaults.set(nil, forKey: LAST_ASSESSMENT_DATA)
        kUserDefaults.set(nil, forKey: LAST_ASSESSMENT_DATE)
        kUserDefaults.set(nil, forKey: PRASHNA_VIKRITI_ANSWERS)
        kUserDefaults.set(nil, forKey: ksubscription_title)
        kUserDefaults.set(nil, forKey: ksubscription_subtitle)
        kUserDefaults.set(nil, forKey: ksubscription_background)
        kUserDefaults.set(nil, forKey: ksubscription_textalignment)
        kUserDefaults.set(nil, forKey: ksubscription_textColor)
        kUserDefaults.set(nil, forKey: ksubscription_button_text)
        kUserDefaults.set(nil, forKey: ksubscription_buttonColor)
        kUserDefaults.set(nil, forKey: ksubscription_button_textColor)
        kUserDefaults.set(nil, forKey: kDeliveryPincode)
        kUserDefaults.set(nil, forKey: kDeliveryAddressID)        
        
        kUserDefaults.isCCRYNChallengeUnlocked = false
        kUserDefaults.isNadiBandProjectUnlocked = false
        LoginViewController.clearUserDefaultsData(userID: kSharedAppDelegate.userId)
        kSharedAppDelegate.userId = ""
        Shared.sharedInstance.clearData()
        SurveyData.shared.clearData()
        TodayRecommendations.shared.clearData()
        Utils.clearUserDataBaseData()
        //Temo Comment//MoEngageHelper.shared.resetUser()
        ARPedometerData.deleteFromUserDefault()
        ARBPLDeviceManager.clearSavedBPLDeviceDataFromUserDefauld()
        MPCartManager.removeCartData()
        
        kUserDefaults.storedScratchCards = [:] //clear any saved guest scratch cards
        kUserDefaults.giftClaimedPrakritiQuestionIndices = []
        kUserDefaults.giftClaimedVikritiQuestionIndices = []
    }
}
