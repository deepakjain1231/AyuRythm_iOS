//
//  SideMenuViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 5/25/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import ViewDeck

class SideMenuViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,IIViewDeckControllerDelegate,UINavigationControllerDelegate {
    
    enum SideMenuItems: Int {
        case MyProfile
        case ResultHistory
        case NadiBandProject
        case Notifications
        case LinkWithSocialMedia
        case ChangeLanguage
        case MyBookings
        case MyLists
        case MyActivePlan
        case AppleHealth
        case RateTheApp
        case HowItWorks
        case AboutUs
        case Certificates
        case TermsOfUsage
        case PrivacyPolicy
        case ContactUs
        case AccountSettings
        case MyBPLDevices
        case Logout
        case MyAddress
        case MyOrders
        case MyCart
        case MyWishlist
        case MyRewards
        case MyWallet
        case RemoveSubscription

        var title: String {
            switch self {
            case .MyProfile:
                return "My Profile"
                
            case .ResultHistory:
                return "Result History"
                
            case .NadiBandProject:
                return "Nadi Band Project"
                
            case .Notifications:
                return "Notifications"
                
            case .LinkWithSocialMedia:
                return "Link with Social Media"
                
            case .ChangeLanguage:
                return "Change Language"
                
            case .AppleHealth:
                return "Apple Health"
                
            case .RateTheApp:
                return "Rate the App"
                
            case .HowItWorks:
                return "How it Works"
                
            case .AboutUs:
                return "About Us"
                
            case .Certificates:
                return "Certificates"
                
            case .TermsOfUsage:
                return "Terms of Usage"
                
            case .PrivacyPolicy:
                return "Privacy Policy"
                
            case .ContactUs:
                return "Contact Us"
                
            case .AccountSettings:
                return "Account Settings"
                
            case .Logout:
                return "Logout"
                
            case .MyBookings:
                return "My Bookings"
                
            case .MyLists:
                return "My Lists"
                
            case .MyActivePlan:
                return "My Active Plan"
                
            case .MyBPLDevices:
                return "My BPL Devices"
                
            case .MyWallet:
                return "My Wallet"
                
            case .MyAddress:
                return "My Addresses"
                
            case .MyOrders:
                return "My Orders"
                
            case .MyCart:
                return "My Cart"
                
            case .MyWishlist:
                return "My Wishlist"
                
            case .MyRewards:
                return "My Rewards"
                
            case .RemoveSubscription:
                return "Remove Subscription"
                
            }
            
        }
    }
    
    
    @IBOutlet weak var tblViewSettings: UITableView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgViewProfile: UIImageView!
    
    let healthStore = HealthKitManager()
    var heightString = String()
    var weightString = String()
    var dateOfBirthString  = String()
    var genderString = String()
    var stringCount : String = ""
    
    var arraySettings: [SideMenuItems] = [.MyProfile, .ResultHistory, .Notifications, .MyBookings, .MyLists, .MyAddress, .MyOrders, .MyCart, .MyWishlist, /*.MyRewards,*/ .MyWallet/*, .LinkWithSocialMedia*/, .MyBPLDevices, .ChangeLanguage, .AppleHealth, .RateTheApp, .HowItWorks, .AboutUs, .Certificates, .NadiBandProject, .TermsOfUsage, .PrivacyPolicy, .ContactUs, .AccountSettings, .Logout]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblViewSettings.tableFooterView = UIView()
        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            return
        }
        
        navigationController!.navigationBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        navigationItem.title = empData["name"] as? String ?? ""
        let backButtonItem = UIBarButtonItem(title: Utils.isAppInHindiLanguage ? "".localized() : "Back".localized(), style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButtonItem
        
        tblViewSettings.rowHeight = 60
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.NotificationCountFromServer()
        updateUIForMyActivePlan()
    }
    
    func updateUIForMyActivePlan() {
        if UserDefaults.user.is_main_subscription {
            if !arraySettings.contains(.MyActivePlan),
                arraySettings.count > 4 {
                arraySettings.insert(.MyActivePlan, at: 4)
            }
        } else if UserDefaults.user.is_main_subscription == false, arraySettings.contains(.MyActivePlan) {
            arraySettings.remove(object: .MyActivePlan)
        }
    }
    
    
    //MARK: UITableView Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arraySettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellSettings")!
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        let lblSettings: UILabel = cell.viewWithTag(1001) as! UILabel
        
        let sideMenuItem = arraySettings[indexPath.row]
        switch sideMenuItem {
        case .Notifications:
            lblSettings.text = self.stringCount == "" || self.stringCount == "0" || self.stringCount.isEmpty ? "Notifications".localized() : "Notifications".localized() + " (\(self.stringCount))"
            
        case .MyActivePlan:
            lblSettings.attributedText = NSAttributedString(string: sideMenuItem.title.localized()) + NSAttributedString(string: " •", attributes: [.foregroundColor: #colorLiteral(red: 0.9215686275, green: 0.4431372549, blue: 0.1215686275, alpha: 1), .font : UIFont.systemFont(ofSize: 34)])
            
        default:
            lblSettings.text = sideMenuItem.title.localized()
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let objNavController = self.navigationController else {
            return
        }
        
        let sideMenuItem = arraySettings[indexPath.row]
        switch sideMenuItem {
        case .MyProfile: //Profile
            //Success
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please register first to view your profile.".localized(), controller: self)
                return
            }
            
            let storyBoard = UIStoryboard(name: "Home", bundle: nil)
            let objProfileView:EditProfileViewController = storyBoard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
            self.navigationController?.pushViewController(objProfileView, animated: true)
            
        case .ResultHistory: // Result History
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please register first to view your result history.".localized(), controller: self)
                return
            }
            
            let storyBoard = UIStoryboard(name:"ResultHistory", bundle:nil)
            guard let resultHistoryViewController = storyBoard.instantiateViewController(withIdentifier: "ResultHistoryViewController") as? ResultHistoryViewController else {
                return
            }
            self.navigationController?.pushViewController(resultHistoryViewController, animated: true)
            
            break;
            
        case .NadiBandProject: // Nadi Band Project
            if kUserDefaults.isNadiBandProjectUnlocked {
                showAlert(message: "You have already enrolled in this project.".localized())
            } else {
                CCRYNUnlockAlertVC.showScreen(isNadiBandProject: true, presentingVC: self) { (success, message) in
                    if success {
                        self.showAlert(title:"Success".localized(), message: "Congratulations! You have successfully signed up for Nadi Band Project.".localized())
                    } else {
                        self.showAlert(title: "Error".localized(), message: message)
                    }
                }
            }
            
        case .Notifications: //Notifications
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please register first to view your Notification.".localized(), controller: self)
                return
            }
            let storyBoard = UIStoryboard(name: "Notification", bundle: nil)
            let objSettings:ARNotification = storyBoard.instantiateViewController(withIdentifier: "ARNotification") as! ARNotification
            objSettings.nitificationCount = self.stringCount
            objNavController.pushViewController(objSettings, animated: true)
            
            return
            
        case .LinkWithSocialMedia: //Link with Social Media
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            let objSettings:SocialMediaLinkViewController = storyBoard.instantiateViewController(withIdentifier: "SocialMediaLinkViewController") as! SocialMediaLinkViewController
            objNavController.pushViewController(objSettings, animated: true)
            break
            
        case .ChangeLanguage: //Change Language
            let storyBoard = UIStoryboard(name: "ChooseLanguage", bundle: nil)
            guard let chooseLanguageViewController = storyBoard.instantiateViewController(withIdentifier: "ChooseLanguageViewController") as? ChooseLanguageViewController else {
                return
            }
            
            chooseLanguageViewController.isInitialLaunch = false
            objNavController.pushViewController(chooseLanguageViewController, animated: true)
            
            break
            
            
        case .MyAddress:
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }

            let vcMyAddress = MPMyAddressVC.instantiate(fromAppStoryboard: .MarketPlace)
            objNavController.pushViewController(vcMyAddress, animated: true)
            break
            
        case .MyBookings:
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please register first to sync Apple Health.".localized(), controller: self)
                return
            }
            
            let storyBoard = UIStoryboard(name: "Booking", bundle: nil)
            guard let myBookingViewController = storyBoard.instantiateViewController(withIdentifier: "MyBookingViewController") as? MyBookingViewController else {
                return
            }
            objNavController.pushViewController(myBookingViewController, animated: true)
            break
            
        case .MyLists:
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please Register now to view My List section".localized(), controller: self)
                return
            }
            
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
            objNavController.pushViewController(myListVC, animated: true)
            break

        case .MyActivePlan:
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please register first to check my active plan.".localized(), controller: self)
                return
            }
            
            let vc = ActiveSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
            objNavController.pushViewController(vc, animated: true)
            break
            
        case .AppleHealth: //Apple Health
            
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please register first to sync Apple Health.".localized(), controller: self)
                return
            }
            
            healthStore.checkAuthorizationStatusAndGetHealthParameters(fromVC: self, isAllParamReqired: true) { heightInCmString, weightInKgsString, dob, gender in
                guard let dob = dob, let heightInCmString = heightInCmString, let weightInKgsString = weightInKgsString else {
                    print("!!! All health kit data not provided by user")
                    self.healthStore.showOpenHealthKitSettingAlert(fromVC: self)
                    return
                }
                
                self.syncHealthKit(dob, gender, heightInCmString, weightInKgsString)
            }
            return
            
            
            /*self.healthStore.checkAllPermission { (issuccess) in
                if issuccess == true
                {
                    DispatchQueue.main.async(execute: {
                        Utils.showAlertWithTitleInControllerWithCompletion(Healthkit, message: "Healthkit date update successfully!.".localized(), okTitle: "Ok".localized(), controller: self) {
                            
                            self.HealthkitData()
                        }
                    })
                }
                else
                {
                    
                    Utils.startActivityIndicatorInView(self.view, userInteraction: false)
                    self.healthStore.checkAuthorization { (issuccess) in
                        if issuccess
                        {
                            DispatchQueue.main.async(execute: {
                                
                                self.healthStore.checkAllPermission { (issuccess) in
                                    if issuccess == true
                                    {
                                        DispatchQueue.main.async(execute: {
                                            self.HealthkitData()
                                            Utils.stopActivityIndicatorinView(self.view)
                                        })
                                    }
                                    else
                                    {
                                        DispatchQueue.main.async(execute: {
                                            
                                            Utils.stopActivityIndicatorinView(self.view)
                                            Utils.showAlertWithTitleInControllerWithCompletion(Healthkit, message: "You can turn on healthkit permissions from setting => Health => Data Access & Devices => AyuRythm App and Turn All Categories On".localized(), cancelTitle: "Cancel".localized(), okTitle: "Go To".localized(), controller: self, completionHandler: {
                                                self.healthStore.openUrl(urlString: UIApplication.openSettingsURLString)
                                            }) {
                                            }
                                        })
                                        
                                    }
                                }
                            })
                            
                        } else {
                            Utils.stopActivityIndicatorinView(self.view)
                        }
                    }
                }
            }*/
            
            
        case .MyOrders:
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view my orders".localized(), controller: self)
                return
            }
            
            let myOrderViewController = MPMyOrderVC.instantiate(fromAppStoryboard: .MarketPlace)
            objNavController.pushViewController(myOrderViewController, animated: true)
            break
            
        case .MyCart:
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view cart".localized(), controller: self)
                return
            }
            
            let myCartViewController = MPCartVC.instantiate(fromAppStoryboard: .MarketPlace)
            objNavController.pushViewController(myCartViewController, animated: true)
            break
            
        case .MyWishlist:
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view favourite".localized(), controller: self)
                return
            }
            
            let myFavoriteViewController = MPFavoriteVC.instantiate(fromAppStoryboard: .MarketPlace)
            objNavController.pushViewController(myFavoriteViewController, animated: true)
            break
            
        case .MyWallet: //My Wallet
            
            guard !kSharedAppDelegate.userId.isEmpty else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view wallet".localized(), controller: self)
                return
            }
            
            let vc = MPWalletVC.instantiate(fromAppStoryboard: .MarketPlace)
            objNavController.pushViewController(vc, animated: true)
            
        case .RateTheApp: //Rate the App
            let urlString = "https://apps.apple.com/us/app/ayurthym/id1401306733?ls=1"
            guard let url = URL(string: urlString) else {
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        case .HowItWorks: //How it Works
            let storyBoard = UIStoryboard(name: "ChooseLanguage", bundle: nil)
            let objSlideView:SlideShowViewController = storyBoard.instantiateViewController(withIdentifier: "SlideShowViewController") as! SlideShowViewController
            objSlideView.isFromSettings = true
            objSlideView.title = sideMenuItem.title.localized()
            objSlideView.hidesBottomBarWhenPushed = true
            objNavController.pushViewController(objSlideView, animated: true)
            
        case .AboutUs: //About US
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            let objSettings:HOEAboutUS = storyBoard.instantiateViewController(withIdentifier: "HOEAboutUS") as! HOEAboutUS
            objNavController.pushViewController(objSettings, animated: true)
            
            
        case .Certificates: //Certificates
            let storyBoard = UIStoryboard(name: "Certificates", bundle: nil)
            let objSettings:HOECertificates = storyBoard.instantiateViewController(withIdentifier: "HOECertificates") as! HOECertificates
            objNavController.pushViewController(objSettings, animated: true)
            
            return
            
        case .TermsOfUsage: //TERMS OF USE
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            let objSettings:WebVIewViewController = storyBoard.instantiateViewController(withIdentifier: "WebVIewViewController") as! WebVIewViewController
            objSettings.webViewType = .termsOfUse
            objNavController.pushViewController(objSettings, animated: true)
            
        case .PrivacyPolicy: //PRIVACY
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            let objSettings:WebVIewViewController = storyBoard.instantiateViewController(withIdentifier: "WebVIewViewController") as! WebVIewViewController
            objSettings.webViewType = .privacyPolicy
            objNavController.pushViewController(objSettings, animated: true)
            
        case .ContactUs: //CONTACT US
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            let objSettings:ContactUsViewController = storyBoard.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            objNavController.pushViewController(objSettings, animated: true)
            
        case .AccountSettings: //Account Settings
            let vc = ARAccountSettingsVC.instantiate(fromAppStoryboard: .Profile)
            objNavController.pushViewController(vc, animated: true)
            
        case .MyBPLDevices: //My BPL Devices
            let vc = ARBPLDeviceListVC.instantiate(fromAppStoryboard: .BPLDevices)
            objNavController.pushViewController(vc, animated: true)
            
        case .Logout: //Logout
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
            
            //        case 10: //changePassword
            //            guard !kSharedAppDelegate.userId.isEmpty else {
            //                Utils.showAlertWithTitleInController(APP_NAME, message: "Please register first to view your Change Password.", controller: self)
            //                return
            //            }
            //            let storyBoard = UIStoryboard(name: "ChangePassword", bundle: nil)
            //            let objSettings:HOEChangePassword = storyBoard.instantiateViewController(withIdentifier: "HOEChangePassword") as! HOEChangePassword
            //            objNavController.pushViewController(objSettings, animated: true)
            
        default:
            print("default")
        }
    }
    
    @IBAction func editProfileClicked(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let objProfileView:EditProfileViewController = storyBoard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        self.navigationController?.pushViewController(objProfileView, animated: true)
    }
    
    func HealthkitData() {
        DispatchQueue.main.async(execute: {
            
            self.healthStore.healthWeight { (weight) in
                //Weight
                let lbsString = String(weight.dropLast(3))
                let stString = String(weight.dropLast(2))
                self.weightString = lbsString == "lbs" ? Utils.convertPoundsToKg(lb: String(weight.dropLast(4))) : stString == "st" ? "\(Double(String(weight.dropLast(3)))! * 6.35029)" : String(weight.dropLast(3))
            }
            
            // DateOfBirth
            self.healthStore.healthDateOfBirth { (dateOfBirth) in
                self.dateOfBirthString = dateOfBirth
            }
            self.genderString = self.healthStore.healthGender()
            
            self.healthStore.healthHeight { (height) in
                //Height
                self.heightString = String(height.dropLast(1)) == "m" ? "\(Int(String(height.dropLast(3)))! * 100)":  String(height.dropLast(1)) == "ft" ? "\(Double(String(height.dropLast(3)))! * 30.48)" : String(height.dropLast(3))
                
                self.syncHealthKit(self.dateOfBirthString, self.genderString, self.heightString, self.weightString)
            }
            
        })
    }
    
    
    //MARK: - Naigationbar button click action
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    static func clearUserDefaultsData() {
        kUserDefaults.set(nil, forKey: IS_LOGGEDIN)
        kUserDefaults.set(nil, forKey: USER_DATA)
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
        kUserDefaults.set(nil, forKey: kSanaayPatientID)
        
        
        
        
        
        
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
    
    func NotificationCountFromServer() {
        if Utils.isConnectedToNetwork() {
            guard !kSharedAppDelegate.userId.isEmpty else {

                return
                }
            let urlString = kBaseNewURL + endPoint.notificationCount.rawValue
            
            AF.request(urlString, method: .post, parameters: nil, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        return
                    }
                    self.stringCount = dicResponse["data"] as? String ?? ""
                    self.tblViewSettings.reloadData()
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
   
    
    func syncHealthKit(_ dateOfBirth:String,_ gender : String,_ height : String,_ weight : String)
    {
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

