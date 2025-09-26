//
//  AppDelegate.swift
//  HourOnEarth
//
//  Created by Pradeep on 5/25/18.
//  Copyright © 2018 Pradeep. All rights reserved.
// Commit 31 Aug
// Commit 19 July and it's branch upload on store with iphone 14 max issue resolved

import UIKit
import ViewDeck
import Alamofire
import Fabric
import Crashlytics
import UserNotifications
import Firebase
import FirebaseInAppMessaging
import FirebaseMessaging
import IQKeyboardManagerSwift
import GoogleSignIn
import FBSDKCoreKit
import DropDown

protocol delegate_login {
    func whatsapplogin_delegate(_ is_success: Bool, waID: String)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, UIGestureRecognizerDelegate {

    var window: UIWindow?
    var objViewDeck:IIViewDeckController? = nil

    var userId: String = ""
    var isTestMode: Bool = false
    var isUserActivityParamSend = false
    var isSocialRegisteredUser = false
    //var isShowPreferencesShowcase = false
    var isReminderLocalNotification = false
    var notificationInfo: NotifcationDetail?
    var viewSuggestionScreenFromSparshnaResult: TodayRecommendations.Types?
    var userStreakLevel: ARUserStreakLevelModel?
    var isAppDidEnterBackground = false
    var isWhatsAppLogin: Bool = false
    var login_vc = LoginViewController()
    var login_delegate: delegate_login?
    var is_popupShowing = false
    var apiCallingAsperDataChage = false
    var sparshanAssessmentDone = false
    var facenaadi_doctor_coupon_code = ""
    var facenaadi_subscriptionDone = false
    var is_start_dietPlan = false
    var from_selected_type = ScreenType.k_none
    var completation_handle_url: ((URL)->Void)? = nil
    
    var cloud_vikriti_status = ""
    
#if APPCLIP
    var cloud_vikriti_status = ""
#endif

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        sleep(1)
        Utils.setUpAppAppearance()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
//        if #available(iOS 13.0, *) {
//            window?.overrideUserInterfaceStyle = .light
//        } else {
//            // Fallback on earlier versions
//        }
        self.registerForPushNotifications(application)
        Fabric.with([Crashlytics.self])
//        if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil && kUserDefaults.value(forKey: RESULT_VIKRITI) != nil {
//            self.showPendingPrakritiScreen()
//            return true
//        }
        // Use the Firebase library to configure APIs.

        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        // Initialize Google sign-in

        //GIDSignIn.sharedInstance.currentUser?.serverClientID = FirebaseApp.app()?.options.clientID

        //SubscriptionDetailVC.completeAnyPendingIAPTransactions()
        //MoEngageHelper.shared.setup(with: launchOptions)
        
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
        ARLog("AuthToken : ", Utils.getAuthToken())
        
        // FIXME: - temp testing by Suraj, remove bellow code until first empty line
         //showTestingScreen()
         //return true
        /*
        // Language Selected
        if kUserDefaults.string(forKey: kAppLanguage)?.count ?? 0 > 0 {
            if kUserDefaults.value(forKey: kIsFirstLaunch) == nil {
                showSlideShow()
                return true
            }
            
            if kUserDefaults.bool(forKey: IS_LOGGEDIN) {
                self.showHomeScreen()
            } else {
                self.showLoginScreen()
            }
        } else {
            self.showChangeLanguageScreen()
        }*/
        DropDown.startListeningToKeyboard()
        
        
        // Initialize Facebook SDK
        // Initialize the SDK
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        return true
    }
    
    func appRedirection(is_lopgout: Bool = false ,cueent_vc: UIViewController) {
        if kUserDefaults.string(forKey: kAppLanguage)?.count ?? 0 > 0 {
            if kUserDefaults.value(forKey: kIsFirstLaunch) == nil {
                showSlideShow()
            }
            
            if kUserDefaults.bool(forKey: IS_LOGGEDIN) {
                self.showHomeScreen()
            } else {
                self.showLoginVC(current_vc: cueent_vc)
            }
        } else {
            self.showChangeLanguageScreen()
        }
    }
    
    //MARK: BASE CODE
    func registerForPushNotifications(_ application: UIApplication) {
        
        let center:UNUserNotificationCenter = UNUserNotificationCenter.current()
        center.delegate = self;
        center.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: { (success:Bool, error:Error?) in
            
            if success {
                DispatchQueue.main.sync {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
    }
    
    // MARK: - Local Notification
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        Utils.showAlertWithTitleInController(APP_NAME, message: notification.alertTitle ?? "", controller: (self.window?.rootViewController)!)
    }
    
    func showSlideShow() {
        let storyBoard = UIStoryboard(name: "ChooseLanguage", bundle: nil)
        let objSlideView:SlideShowViewController = storyBoard.instantiateViewController(withIdentifier: "SlideShowViewController") as! SlideShowViewController
        let navController: UINavigationController = UINavigationController(rootViewController: objSlideView)
        navController.interactivePopGestureRecognizer?.isEnabled = true
        navController.isNavigationBarHidden = true
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
    
    //------------------------------------------------------------------------------
    // MARK: - Create AppDelegate sharedInstance function
    //------------------------------------------------------------------------------
    func sharedInstance() -> AppDelegate
    {
        var appDelegate = AppDelegate()
        DispatchQueue.main.async {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        }
        return appDelegate
    }
    
    func showLoginScreen() {
        let objLoginView:UINavigationController = Story_Main.instantiateViewController(withIdentifier: "LoginNavigation") as! UINavigationController
        self.window?.rootViewController = objLoginView
        self.window?.makeKeyAndVisible()
    }
    
    func showLoginVC(current_vc: UIViewController) {
        let objLoginView: LoginViewController = Story_LoginSignup.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        current_vc.navigationController?.pushViewController(objLoginView, animated: true)
    }
    
    
    func showChangeLanguageScreen() {
        let storyBoard = UIStoryboard(name: "ChooseLanguage", bundle: nil)
        guard let chooseLanguageViewController = storyBoard.instantiateViewController(withIdentifier: "InitialChooseLanguageViewController") as? InitialChooseLanguageViewController else {
            return
        }
        self.window?.rootViewController = chooseLanguageViewController
        self.window?.makeKeyAndVisible()
    }
    
    func showHomeScreen() {
        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
            let userIdOld = empData["id"] as? String ?? ""
            kSharedAppDelegate.userId = userIdOld
        }
        
        ARStepsDeatilsVC.fetchAndUpdateStepGoalFromServer()
        
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let objTabBarController:UITabBarController = storyBoard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController

        //Remove 3rd number "Shop" tab when logged user in out of india
        //Remove Shop Section as per Sandeep
        if !Locale.current.isCurrencyCodeInINR || Locale.current.isCurrencyCodeInINR {
            let indexToRemove = 2
            if indexToRemove < objTabBarController.viewControllers?.count ?? 0 {
                var viewControllers = objTabBarController.viewControllers
                viewControllers?.remove(at: indexToRemove)
                objTabBarController.viewControllers = viewControllers
            }
        }
        
        self.window?.rootViewController = objTabBarController
        self.window?.makeKeyAndVisible()
    }
    
    func showGuestLoginScreen() {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let objInstructions = storyBoard.instantiateViewController(withIdentifier: "MeasurementsViewController") as! MeasurementsViewController
        objInstructions.isFromTryAsGuest = true
        let navController = UINavigationController(rootViewController: objInstructions)
        navController.interactivePopGestureRecognizer?.isEnabled = true
        navController.interactivePopGestureRecognizer?.delegate = self
        navController.isNavigationBarHidden = true
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
    
    func showSignUpScreen() {
        let objSignUp = Story_LoginSignup.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
       // objSignUp.mobileNumber = self.phoneNumber
       // self.navigationController?.pushViewController(objSignUp, animated: true)
        let navController = UINavigationController(rootViewController: objSignUp)
        navController.interactivePopGestureRecognizer?.isEnabled = true
        navController.interactivePopGestureRecognizer?.delegate = self
        navController.isNavigationBarHidden = true
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
    
    func showPersonalizingScreen() {
        let storyBoard = UIStoryboard(name: "InitialFlow", bundle: nil)
        let objPersonalize = storyBoard.instantiateViewController(withIdentifier: "PersonalizingViewController") as! PersonalizingViewController
        let navController = UINavigationController(rootViewController: objPersonalize)
        navController.interactivePopGestureRecognizer?.isEnabled = true
        navController.interactivePopGestureRecognizer?.delegate = self
        navController.isNavigationBarHidden = true
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
    
    func showTestingScreen() {
        let vc = ARAyuverseHomeVC.instantiate(fromAppStoryboard: .Ayuverse)
//        let vc = ARWellnessPlanVC.instantiate(fromAppStoryboard: .WellnessPlan)
        let navController = UINavigationController(rootViewController: vc)
        //navController.isNavigationBarHidden = true
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        isAppDidEnterBackground = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

        //Messaging.messaging().shouldEstablishDirectChannel = true

        application.applicationIconBadgeNumber = 0
        if kUserDefaults.bool(forKey: IS_LOGGEDIN), isAppDidEnterBackground {
            isAppDidEnterBackground = false
            ARPedometerManager.shared.fetchPedometerDataFromHealthKit()
        }

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    //------------------------------------------------------------------------------
    // MARK: - didRegisterForRemoteNotificationsWithDeviceToken
    //------------------------------------------------------------------------------
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        
        var token = ""
        for i in 0..<deviceToken.count
        {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
            
        }
        print(token)
       // kCurrentUser.token = " \(token)"
        //kCurrentUser.saveToDefault()
        Messaging.messaging().apnsToken = deviceToken

       // InstanceID.instanceID()
       // let str = String(format: "%@", InstanceID.instanceID().token(withAuthorizedEntity: String) ?? "")

       /* InstanceID.instanceID().instanceID(handler: { (result, error) in

        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else {
                print("Remote instance ID token: \(token ?? "")")
                kUserDefaults.set("\(token ?? "")", forKey: kFcmToken)
                kUserDefaults.set("\(token ?? "")", forKey: kDeviceToken)
            }
        } */
      

        
        // userDefault.XSET_STRING(Constant.StaticNameOfVariable.VdeviceToken, token)
    }
    
    //------------------------------------------------------------------------------
    // MARK: - didFailToRegisterForRemoteNotificationsWithError
    //------------------------------------------------------------------------------
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if self.isWhatsAppLogin {
            self.isWhatsAppLogin = false
            debugPrint("URL=======>>>>\(url)")
            if let components = URLComponents(string: url.absoluteString) {
                let str_waId = components.queryItems?.first(where: { queryItem in
                    queryItem.name == "waId"
                })?.value ?? ""

                debugPrint(str_waId)
                
                if str_waId != "" {
                    self.login_delegate?.whatsapplogin_delegate(true, waID: str_waId)
                }
            }
            return true
        }
        else {
            return GIDSignIn.sharedInstance.handle(url) || ApplicationDelegate.shared.application(app, open: url, options: options)
        }
    }
    
    
    func callAPIforGetDetail(_ waId: String) {
        self.login_delegate?.whatsapplogin_delegate(true, waID: waId)
//
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(UIApplication.topViewController()?.view, userInteraction: false)
//            let urlString = BaseURLWhatsapp
//            let params = ["waId": waId]
//
//            AF.request(BaseURLWhatsapp, method: .post, parameters: params, encoding:URLEncoding.default, headers: ["clientId": kWhatsappLogiClientID, "clientSecret": kWhatsappLogiClientSecret]).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
//                    guard let dicResponse = (value as? [String: Any]) else {
//                        return
//                    }
//                    let status = dicResponse["status"] as? String
//                    if status == "Sucess" {
//                        print("---->> Token update success")
//                    }
//
//                    let socialUser = SocialLoginUser(type: ARLoginType.whatsapp, socialID: waId, name: waId, email: waId, phoneNumber: waId)
//                    self.login_vc.socialLoginCompletion(isSuccess: true, message: "", user: socialUser, loginType: ARLoginType.whatsapp)
//
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self.login_vc)
//                }
//
//                DispatchQueue.main.async(execute: {
//                    Utils.stopActivityIndicatorinView(UIApplication.topViewController()?.view)
//                })
//            }
//        }
//        else {
//            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self.login_vc)
//        }
//
//
//
//
//
//
//
////        var str_param = ""
////        let param_dictionary = ["waId": waId]
////        if let theJSONData = try? JSONSerialization.data(withJSONObject: param_dictionary, options: []) {
////            str_param = String(data: theJSONData, encoding: .ascii) ?? ""
////            print("JSON string = \(str_param)")
////        }
////
////        let postData = str_param.data(using: .utf8)
////
////        var request = URLRequest(url: URL(string: "https://ayurythm.authlink.me")!,timeoutInterval: 60)
////        request.addValue(kWhatsappLogiClientID, forHTTPHeaderField: "clientId")
////        request.addValue(kWhatsappLogiClientSecret, forHTTPHeaderField: "clientSecret")
////        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
////
////        request.httpMethod = "POST"
////        request.httpBody = postData
////
////        let task = URLSession.shared.dataTask(with: request) { data, response, error in
////            guard let data = data else {
////                print(String(describing: error))
////                return
////            }
////            print(String(data: data, encoding: .utf8)!)
////            let socialUser = SocialLoginUser(type: ARLoginType.whatsapp, socialID: waId, name: waId, email: waId, phoneNumber: waId)
////             self.login_vc.socialLoginCompletion(isSuccess: true, message: "", user: socialUser, loginType: ARLoginType.whatsapp)
////        }
////
////        task.resume()
//
    }
    
    
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //update fcm token to server
        print("New FCM Token : ", fcmToken ?? "")
        kUserDefaults.set("\(fcmToken ?? "")", forKey: kFcmToken)
        let deviceToken = kUserDefaults.value(forKey: kDeviceToken) as? String ?? ""

        sendLatestTokensToServer(deviceToken: deviceToken, fcmToken: fcmToken!)
    }
    
   /* func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("APNs Message :: ", remoteMessage.appData)
    } */

     //   sendLatestTokensToServer(deviceToken: deviceToken, fcmToken: fcmToken ?? "")
    //}
    /*
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("APNs Message :: ", remoteMessage.appData)
    }
     */

    
    // For Displaying foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //for Displaying foreground notifications call, completionHandler([.alert, .sound, .badge])
        completionHandler([.alert, .sound, .badge])
        
        // dont show notif and handle it here
        //handleNotification(notification: notification)
        //completionHandler([])
        
        //If you want no action to happen, you can simply pass an empty array to the completion closure
        //completionHandler([])
    }
    
    // Handle user interaction to notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }
        guard response.actionIdentifier ==
            UNNotificationDefaultActionIdentifier else {
                return
        }
        
        // Perform actions here
        handleNotification(notification: response.notification)
    }
    
    func handleNotification(notification: UNNotification) {
        let payload = notification.request.content
        
        print("----->> payload.userInfo -- ", payload.userInfo)
        
        //UIApplication.topViewController()?.showAlert(message: payload.userInfo.description)
        if let isReminderLocalNotification = payload.userInfo["isReminderLocalNotification"] as? Bool {
            self.isReminderLocalNotification = isReminderLocalNotification
        }
        
        //redirect only if user already login
        if let event = payload.userInfo["event"] as? String, kUserDefaults.bool(forKey: IS_LOGGEDIN) {
            print("----->> redirect event -- ", event)
            if let trainer_id = payload.userInfo["trainer_id"] as? String, !trainer_id.isEmpty, trainer_id != "0" {
                let otherInfo = ["trainer_id": trainer_id]
                redirectApp(on: event, otherInfo: otherInfo)
            } else {
                redirectApp(on: event)
            }
        }
    }
    
    func redirectApp(on event: String, otherInfo: [String: Any]? = nil) {
        if let notificationInfo = NotifcationDetail.detail(for: event, otherInfo: otherInfo) {
            self.notificationInfo = notificationInfo
            TabBarViewController.handlePushNotification()
            ARNotification.markAllNotificationAsRead()
        }
    }
    
    func sendLatestTokensToServer(deviceToken: String, fcmToken: String) {
        guard let authToken = kUserDefaults.value(forKey: TOKEN) as? String else {
            return
        }
        
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.updatefcm.rawValue
            let params = ["fcm": fcmToken,"deviceid": deviceToken, "type" : DEVICE_TYPE] as [String : Any]
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: ["Authorization": authToken]).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                    guard let dicResponse = (value as? [String: Any]) else {
                        return
                    }
                    let status = dicResponse["status"] as? String
                    if status == "Sucess" {
                        print("---->> Token update success")
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func openWebLinkinBrowser(_ linkURL: String) {
        var new_linkURL = linkURL
        if !linkURL.contains("http") {
            new_linkURL = "https://\(linkURL)"
        }
        if new_linkURL != "" {
            if let url = URL(string: new_linkURL), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
    }
}


//MARK: - DEEP LINKING
extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        if let incomingURL = userActivity.webpageURL {
            print("incoming URL is \(incomingURL)")
            self.completation_handle_url?(incomingURL)
        }
        
        return true
    }



    func callAPIforVimeoExtracter(vimeo_url: String, current_view: UIViewController, completion: @escaping (Bool, String)->Void ) {
        //API Call
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(current_view.view, userInteraction: false)
            let arr_url = vimeo_url.components(separatedBy: "/")
            let urlString = BaseURL_Vimeo + (arr_url.last ?? "")
            
            AF.request(urlString, method: .get, parameters: nil, encoding:URLEncoding.default, headers: ["Authorization": Kvimeo_access_Token]).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print("API URL: - \(urlString)\n\n\nResponse: - \(response)")
                    guard let dicResponse = (value as? [String: Any]) else {
                        completion(false, "")
                        return
                    }
                    
                    guard let arr_video_file = dicResponse["files"] as? [[String: Any]] else {
                        completion(false, "")
                        return
                    }
                    
                    if arr_video_file.count != 0 {
                        var str_video_url = ""
                        let arr_filter_video_file = arr_video_file.filter({ dic_vimeo in
                            return (dic_vimeo["rendition"] as? String ?? "") == "540p"
                        })
                        
                        if arr_filter_video_file.count != 0 {
                            str_video_url = arr_filter_video_file.first?["link"] as? String ?? ""
                        }
                        else {
                            str_video_url = arr_video_file.first?["link"] as? String ?? ""
                        }
                        
                        completion(true, str_video_url)
                    }
                    else {
                        completion(false, "")
                        Utils.showAlertWithTitleInController(APP_NAME, message: "Something went wrong, please try again later", controller: current_view)
                    }
                    
                case .failure(let error):
                    print(error)
                    completion(false, "")
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: current_view)
                }
                
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(current_view.view)
                })
            }
        }
        else {
            completion(false, "")
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: current_view)
        }
        
    }
}
