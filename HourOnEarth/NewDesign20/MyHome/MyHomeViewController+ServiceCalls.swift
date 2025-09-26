//
//  MyHomeViewController+ServiceCalls.swift
//  HourOnEarth
//
//  Created by Apple on 15/01/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import Foundation
import Alamofire
import FirebaseAnalytics
import IQKeyboardManagerSwift

extension MyHomeViewController {
    
    func manageSection() {
        self.arr_section.removeAll()
        
        var isPrakritiPrashna = false
        if let prashnaResult = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String, !prashnaResult.isEmpty {
            isPrakritiPrashna = true
        }
        
        let isSparshnaTestGiven = kUserDefaults.bool(forKey: kVikritiSparshanaCompleted)
        let isPrashnaTestGiven = kUserDefaults.bool(forKey: kVikritiPrashnaCompleted)
        
        //If registered but not given test
        if !isPrakritiPrashna && !isSparshnaTestGiven  {
            self.arr_section.append(.noTestDone(title: "Begin your Ayurvedic journey today in just\n2 easy steps! 🔥".localized(), isSparshna: false, isPrashna: false))
            self.arr_section.append(.noSparshnaTest(isSparshna: isSparshnaTestGiven, isPrashna: isPrashnaTestGiven))
            self.arr_section.append(.noQuestionnaires(isSparshna: isSparshnaTestGiven, isPrashna: isPrashnaTestGiven))
            
            if self.dialouge_firstTime == false {
                self.dialouge_firstTime = true
                self.showingPopup()
            }
        }
        else if isSparshnaTestGiven && !isPrakritiPrashna  {
            self.arr_section.append(.noTestDone(title: "You are 1 step away from unlocking\npersonalized results 🔥".localized(), isSparshna: true, isPrashna: false))
            self.arr_section.append(.noQuestionnaires(isSparshna: isSparshnaTestGiven, isPrashna: isPrashnaTestGiven))
            self.arr_section.append(.noSparshnaTest(isSparshna: isSparshnaTestGiven, isPrashna: isPrashnaTestGiven))
            
            if self.dialouge_firstTime == false {
                self.dialouge_firstTime = true
                self.showingPopup()
            }
        }
        else if isPrakritiPrashna && !isSparshnaTestGiven  {
            self.arr_section.append(.noTestDone(title: "You are 1 step away from unlocking\npersonalized results 🔥".localized(), isSparshna: false, isPrashna: true))
            
            self.arr_section.append(.noSparshnaTest(isSparshna: isSparshnaTestGiven, isPrashna: isPrakritiPrashna))
            self.arr_section.append(.noQuestionnaires(isSparshna: isSparshnaTestGiven, isPrashna: isPrakritiPrashna))
            
            if self.dialouge_firstTime == false {
                self.dialouge_firstTime = true
                self.showingPopup()
            }
        }

        if isSparshnaTestGiven && isPrakritiPrashna {
            self.arr_section.append(.lastAssessment(title: lastAssessmentValue))
        }

        if isPrakritiPrashna && isSparshnaTestGiven &&  !isPrashnaTestGiven {
            self.arr_section.append(.noQuestionnairesVikrati)
        }
        
        //Check Mee Looha Benner visible
        if let is_visible = UserDefaults.user.get_user_info_result_data["melooha_banner_visible"] as? Bool, is_visible {
            self.arr_section.append(.meeLohaBanner)
        }
        
        
        

        if self.arr_TodayGoalData.count != 0 {
            self.arr_section.append(.todaygoal_header)
            
            for asana_data in self.arr_TodayGoalData {
                var goal = TodayGoal_Type.knone

                let goal_type = asana_data?.goal_asana_type ?? ""
                if goal_type.lowercased() == TodayGoal_Type.Yogasana.rawValue.lowercased() {
                    goal = .Yogasana
                }
                else if goal_type.lowercased() == TodayGoal_Type.Meditation.rawValue.lowercased() {
                    goal = .Meditation
                }
                else if goal_type.lowercased() == TodayGoal_Type.Pranayama.rawValue.lowercased() {
                    goal = .Pranayama
                }
                else if goal_type.lowercased() == TodayGoal_Type.Kriyas.rawValue.lowercased() ||
                            goal_type.lowercased() == "kriya" {
                    goal = .Kriyas
                }
                else if goal_type.lowercased() == TodayGoal_Type.Mudras.rawValue.lowercased() ||
                            goal_type.lowercased() == "mudra" {
                    goal = .Mudras
                }

                if let totalCount = asana_data?.goal_data?.user_watch_count_total, totalCount != 0 {
                   self.arr_section.append(.goal_Meditation(type: goal, data: asana_data))
                }
            }
            
            self.arr_section.append(.rewards)
        }
        else {
            if self.exceptFirstTime {
                self.arr_section.append(.todaysGoalLoading)
            }
        }

        self.arr_section.append(.weightTracker)
        self.arr_section.append(.ayumonk)
        self.arr_section.append(.pedometer)

        if !isPrakritiPrashna || !isSparshnaTestGiven {
            
            if UserDefaults.user.is_main_subscription == false, !kSharedAppDelegate.userId.isEmpty {
                self.arr_section.append(.homeremedies_banner)
            }
            
            self.arr_section.append(.explore)
        }
        else {
            
            /*
            //Remove Shop Section as per Sandeep
            let getEnableBanner = UserDefaults.user.get_user_info_result_data["discount_offer_background_is_enabled"] as? Bool ?? false
            if getEnableBanner {
                if Locale.current.isCurrencyCodeInINR {
                    self.arr_section.append(.shop_banner)
                }
            }
            */
            
            self.arr_section.append(.wellnessPlan)
            
            if UserDefaults.user.is_main_subscription == false, !kSharedAppDelegate.userId.isEmpty {
                self.arr_section.append(.subscription)
            }
            
            //if SurveyData.shared.contentTypeIDs.contains(4) {
                self.arr_section.append(.daily_planner)
            //}
            
            /*
            //Remove Shop Section as per Sandeep
            if self.arrVoucherCoupon.count != 0 {
                self.arr_section.append(.voucher)
            }
            */

            self.arr_section.append(.homeremedies_banner)

            self.arr_section.append(.explore_foodHerb)
        }

        self.tblViewHome.reloadData()
    }
    
    func refreshData() {

        //If both test are not given then show no data view
        if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil || kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
            //self.viewNoData.isHidden = false
            self.viewRegisterNow.isHidden = !kSharedAppDelegate.userId.isEmpty
            //self.view.bringSubviewToFront(self.viewNoData)
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            getResultFromServer { (isSuccess, isTokenExpired) in
                if !isSuccess && isTokenExpired {
                    self.loginForTokenRefreshFromServer { (isSuccess, message) in
                        if isSuccess {
                            self.getAllDataFromServer(withUserInfoResult: true)
                        } else {
                            print("Show login screen")
                            Utils.stopActivityIndicatorinView(self.view)
                        }
                    }
                } else {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
        }
        self.viewNoData.isHidden = true
        self.manageSection()

        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        getResultFromServer { (isSuccess, isTokenExpired) in
            if !isSuccess && isTokenExpired {
                self.loginForTokenRefreshFromServer { (isSuccess, message) in
                    if isSuccess {
                        self.getAllDataFromServer(withUserInfoResult: true)
                    } else {
                        print("Show login screen")
                        Utils.stopActivityIndicatorinView(self.view)
                    }
                }
            } else {
                self.getAllDataFromServer()
            }
        }
    }
    
    
    
    func getAllDataFromServer(withUserInfoResult: Bool = false) {

        let dispatchGroup = DispatchGroup()
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)

        if withUserInfoResult {
            dispatchGroup.enter()
            self.getResultFromServer { (isSuccess, isTokenExpired) in
                dispatchGroup.leave()
            }
        }
        
//        dispatchGroup.enter()
//        self.getUserInfoDetailsFromServer {
//            dispatchGroup.leave()
//        }
        
        
        if (kUserDefaults.value(forKey: RESULT_PRAKRITI) != nil) && (kUserDefaults.value(forKey: RESULT_VIKRITI) != nil) {
            dispatchGroup.enter()
            self.getUserTodaysGoalDetailsFromServer { success in
                self.exceptFirstTime = true
                dispatchGroup.leave()
                self.manageSection()
            }
            
            self.deepLinkHandle()
        }
        
        /*
        //Remove Shop Section as per Sandeep
        if (kUserDefaults.value(forKey: RESULT_PRAKRITI) != nil) && (kUserDefaults.value(forKey: RESULT_VIKRITI) != nil) {
            dispatchGroup.enter()
            if Locale.current.isCurrencyCodeInINR {
                self.viewModel.getCouponsFromServer { (isSuccess, message, couponCompanies) in
                    if isSuccess {
                        self.arrVoucherCoupon = couponCompanies
                        dispatchGroup.leave()
                        self.manageSection()
                    }
                }
            }
            else {
                dispatchGroup.leave()
            }
        }
        */

        dispatchGroup.notify(queue: .main) {
            Utils.stopActivityIndicatorinView(self.view)
            //self.allDataFetchCompleted()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
            self.NotificationFromServer()
        })
        
        self.setupAyuseedData()
    }

    func getResultFromServer (completion: @escaping (Bool, Bool)->Void) {
        
        if Utils.isConnectedToNetwork() {
            guard !kSharedAppDelegate.userId.isEmpty else {
                completion(false, false)
                return
            }
            let urlString = kBaseNewURL + endPoint.userinfoResult.rawValue
            var params = ["user_id": kSharedAppDelegate.userId]
            
            //send user activity
            if !kSharedAppDelegate.isUserActivityParamSend {
                params["is_tracking"] = "1"
                params["device_type"] = DEVICE_TYPE
                kSharedAppDelegate.isUserActivityParamSend = true
            }
            params["appVersion"] = Bundle.main.releaseVersionNumber ?? "0"
            params["deviceVersion"] = UIDevice.current.systemVersion
            params["deviceInfo"] = UIDevice.current.type.rawValue
            params["language_id"] = "\(Utils.getLanguageId())"
            
            //send prakriti/vikriti result final value
            //params.addVikritiResultFinalValue()
            //params.addPrakritiResultFinalValue()
            
            print("===>>> userinfoResult api called : Params : ", params)

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON { response in
                /*defer {
                     completion(true, false)
                }*/
                switch response.result {
                case .success(let value):
                    print(response)
                    
                    if let statusCode = response.response?.statusCode, (statusCode == 401 || statusCode == 404) {
                        print("call login api to refresh user access token")
                        completion(false, true)
                        return
                    }
                    
                    guard let dicResponse = (value as? [String: Any]) else {
                        completion(false, false)
                        return
                    }
                    
                    let last_test_timestamp: String = dicResponse["timestamp"] as? String ?? ""
                    
                    //Update user info to latest details
                    if let userInfo = dicResponse["Userinfo"] as? [String: Any] {
                        var finalUserInfo = userInfo.nullKeyRemoval()
                        finalUserInfo["timestamp"] = last_test_timestamp
                        kUserDefaults.set(finalUserInfo, forKey: USER_DATA)
                        appDelegate.cloud_vikriti_status = userInfo["aggravation"] as? String ?? ""
                        Shared.sharedInstance.userWeight = Utils.getLoginUserWeightInKg()
                    }
                    
                    UserDefaults.user.set_user_info_result(data: dicResponse)
                                        
                    let prashna: String = dicResponse["prashna_prakriti"] as? String ?? ""
                    let vikriti = dicResponse["vikriti"] as? String ?? ""
                    
                    if !prashna.isEmpty {
                        let seprated = Utils.parseValidValue(string: prashna)
                        kUserDefaults.set(seprated, forKey: RESULT_PRAKRITI)
                    }
                    if !vikriti.isEmpty {
                        let seprated = Utils.parseValidValue(string: vikriti)
                        kUserDefaults.set(seprated, forKey: RESULT_VIKRITI)
                    }
                    
                    //For Subscription
                    let subscription_title = dicResponse["subscription_title"] as? String ?? ""
                    let subscription_subtitle = dicResponse["subscription_subtitle"] as? String ?? ""
                    var subscription_btn_text = dicResponse["subscription_btn_text"] as? String ?? ""
                    let subscription_background = dicResponse["subscription_background"] as? String ?? ""
                    let subscription_textcolor = dicResponse["subscription_textcolor"] as? String ?? ""
                    let subscription_btn_bgcolor = dicResponse["subscription_btn_bgcolor"] as? String ?? ""
                    let subscription_textalignment = dicResponse["subscription_textalignment"] as? String ?? ""
                    var subscription_btn_textcolor = dicResponse["subscription_btn_textcolor"] as? String ?? ""
                    
                    if subscription_btn_textcolor == "" {
                        subscription_btn_textcolor = dicResponse["subscription_buttontextcolor"] as? String ?? ""
                    }

                    if subscription_btn_text == "" {
                        subscription_btn_text = dicResponse["subscription_buttontext"] as? String ?? ""
                    }
                    
                    //Trial Count
                    let free_finger_count = dicResponse["FreeSparshnaAssessment"] as? Int ?? 0
                    let free_facenaadi_count = dicResponse["FreeFaceNaadiAssessment"] as? Int ?? 0
                    let free_remdies_count = dicResponse["FreeHomeRemedies"] as? Int ?? 0
                    let ayumonk_free_question = dicResponse["AyuMonkFreeQuestions"] as? Int ?? 0
                    UserDefaults.user.set_finger_Count(data: free_finger_count)
                    UserDefaults.user.set_facenaadi_Count(data: free_facenaadi_count)
                    UserDefaults.user.set_ayumonk_Count(data: ayumonk_free_question)
                    UserDefaults.user.set_remedies_count(data: free_remdies_count)
                    
                    //Subcribed or not
                    var is_finger_subscribe = dicResponse["isSubscribedForFingerAssessment"] as? Bool ?? false
                    var is_facenaadi_subscribe = dicResponse["isSubscribedForFacenaadi"] as? Bool ?? false
                    var is_ayumonk_subscribe = dicResponse["isSubscribedForAyumonk"] as? Bool ?? false
                    var is_remedies_subscribe = dicResponse["isSubscribedForHomeRemedies"] as? Bool ?? false
                    var is_dietPlan_subscribe = dicResponse["isSubscribedForDietPlan"] as? Bool ?? false
                    
                    let is_main_subscribe = dicResponse["isSubscribe"] as? Bool ?? false
                    if is_main_subscribe {
                        is_finger_subscribe = true
                        is_ayumonk_subscribe = true
                        is_remedies_subscribe = true
                        is_facenaadi_subscribe = true
                        is_dietPlan_subscribe = true
                    }
                    UserDefaults.user.set_finger_Subscribed(data: is_finger_subscribe)
                    UserDefaults.user.set_facenaadi_Subscribed(data: is_facenaadi_subscribe)
                    UserDefaults.user.set_ayumonk_Subscribed(data: is_ayumonk_subscribe)
                    UserDefaults.user.set_home_remedies_Subscribed(data: is_remedies_subscribe)
                    UserDefaults.user.set_diet_plan_Subscribed(data: is_dietPlan_subscribe)
                    UserDefaults.user.set_main_subscription(data: is_main_subscribe)
                    //*****************//
                    
                    
                    //For FaceNaadi Subscription
                    let is_ayumonk = dicResponse["AyuMonk"] as? Bool ?? false
                    let is_facenaadiDone = dicResponse["is_facenaadi_done"] as? Bool ?? false
                    appDelegate.facenaadi_doctor_coupon_code = dicResponse["facenaadi_doctor_coupon_code"] as? String ?? ""
                    
                    if is_ayumonk {
                        self.btn_floating.isHidden = false
                        self.btn_ayumonk_floating.isHidden = false
                        self.constraint_btn_floating_Bottom.constant = 20
                    }
                    else {
                        self.btn_floating.isHidden = true
                        self.btn_ayumonk_floating.isHidden = true
                        self.btn_facenaadi_floating.transform = .identity
                        self.constraint_btn_floating_Bottom.constant = -40
                    }
                    
                    
                    
                   
                    kUserDefaults.set(is_ayumonk, forKey: k_ayumonk_hide)
                    kUserDefaults.set(subscription_title, forKey: ksubscription_title)
                    kUserDefaults.set(subscription_subtitle, forKey: ksubscription_subtitle)
                    kUserDefaults.set(subscription_background, forKey: ksubscription_background)
                    kUserDefaults.set(subscription_textalignment, forKey: ksubscription_textalignment)
                    kUserDefaults.set(subscription_textcolor, forKey: ksubscription_textColor)
                    kUserDefaults.set(subscription_btn_text, forKey: ksubscription_button_text)
                    kUserDefaults.set(subscription_btn_bgcolor, forKey: ksubscription_buttonColor)
                    kUserDefaults.set(subscription_btn_textcolor, forKey: ksubscription_button_textColor)
                    
                    let vikritiPrashnaTest = dicResponse["vikriti_prashna"] as? String ?? "false"
                    let vikritiSparshnaTest = dicResponse["vikriti_sprashna"] as? String ?? "false"
                    kUserDefaults.set(Bool(vikritiPrashnaTest), forKey: kVikritiPrashnaCompleted)
                    kUserDefaults.set(Bool(vikritiSparshnaTest), forKey: kVikritiSparshanaCompleted)
                    
                    let vikritiSparshnaValue = dicResponse["vikriti_sprashnavalue"] as? String ?? ""
                    kUserDefaults.set(vikritiSparshnaValue, forKey: VIKRITI_SPARSHNA)

                    let vikritiPrashnaValue = dicResponse["vikriti_prashnavalue"] as? String ?? ""
                    kUserDefaults.set(vikritiPrashnaValue, forKey: VIKRITI_PRASHNA)
                    
                    let lastAssesmentData = dicResponse["sparshna"] as? String ?? ""
                    kUserDefaults.set(lastAssesmentData, forKey: LAST_ASSESSMENT_DATA)
                    
                    self.getLastAssesmentValue(date: dicResponse["timestamp"] as? String)
                    
                    let userListPoint = dicResponse["User_Defined_List_points"] as? Int ?? 0
                    kUserDefaults.set(userListPoint, forKey: kUserListPoints)
                    
                    let userListRedeemed = dicResponse["User_Defined_List_redeemed"] as? Bool ?? false
                    kUserDefaults.set(userListRedeemed, forKey: kUserListRedeemed)
                    
                    //Save referral code
                    if let userInfo = dicResponse["Userinfo"] as? [String: Any] {
                        if let referralCode = userInfo["referralcode"] as? String {
                            kUserDefaults.referralCode = referralCode
                        }
                        SMLinkModel.saveSocialLinkEmails(from: userInfo)
                    }
                    
                    //Save User Goal code
                    SurveyData.shared.updateData(from: dicResponse)
                    
                    //Setting Device Red_min value for sparshna finger placement logic
                    if let deviceInfoIOS = dicResponse["deviceInfoIOS"] as? [[String: Any]], let deviceInfo = deviceInfoIOS.first {
                        if let red_min = deviceInfo["Red_min"] as? String, let doubleValue = Double(red_min) {
                            print("===>>> Setting device red_min value :: ", red_min)
                            Shared.sharedInstance.maxValue = doubleValue
                        }
                    }
                    
                    //check user isSubscribed for service or not
                    self.showNavProfileButton_MyHomeViewController(img_view: self.img_userIconHeader, btn_Profile: self.btn_userHeader, handlePro: self.view_ProUser)
                    
                    //get referral point value
                    if let value = dicResponse["referral_val"] as? String {
                        kUserDefaults.referralPointValue = String(value)
                    }
                    
                    //get surya namaskar count value
                    if let value = dicResponse["surya_namaskar_count"] as? String {
                        Shared.sharedInstance.suryaNamaskarCount = Int(value) ?? 0
                    }
                    
                    //get wellness preference set status
                    if let value = dicResponse["isUserWellnessPreferencesSet"] as? Bool {
                        kUserDefaults.isWellnessPreferenceSet = value
                    }
                    
                    
                    self.checkForNewVersion(from: dicResponse)
                    
                    //Temp comment//self.checkRedGraphValue()
                    self.checkAggravatedValue()

                    //Add Key Value Pair for Firebase Analycits
                    Analytics.setUserProperty(kSharedAppDelegate.userId, forName: "user_id")
                    
                    if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                        let dob = empData["dob"] as? String ?? ""
                        let gender = empData["gender"] as? String ?? ""
                        Analytics.setUserProperty(gender, forName: "gender")
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy"
                        if let birthday = dateFormatter.date(from: dob) {
                            let ageComponents = Calendar.current.dateComponents([.year], from: birthday, to: Date())
                            Analytics.setUserProperty("\(ageComponents.year ?? 0)", forName: "age")
                        }
                    }
                    
                    Analytics.setUserProperty(self.lastAssessmentValue, forName: "lastTest")
                    if UserDefaults.user.is_main_subscription {
                        Analytics.setUserProperty("Y", forName: "isSubscribe")
                    }
                    if UserDefaults.user.is_facenaadi_subscribed {
                        Analytics.setUserProperty("Y", forName: "isSubscribedForFacenaadi")
                    }
                    if UserDefaults.user.is_finger_subscribed {
                        Analytics.setUserProperty("Y", forName: "isSubscribedForPulse")
                    }
                    if UserDefaults.user.is_ayumonk_subscribed {
                        Analytics.setUserProperty("Y", forName: "isSubscribedForAyuMonk")
                    }
                    if UserDefaults.user.is_remedies_subscribed {
                        Analytics.setUserProperty("Y", forName: "isSubscribedForHomeRemedies")
                    }
                    if UserDefaults.user.is_diet_plan_subscribed {
                        Analytics.setUserProperty("Y", forName: "isSubscribedForDietPlan")
                    }
                    //*****************************************//
                    
                    //self.checkByDoctorSubscriptorNot(response: dicResponse)
                    self.tblViewHome.reloadData()
                    completion(true, false)
                    
                case .failure(let error):
                    print(error)
                    //Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                    completion(false, false)
                }
            }
        }else {
            completion(false, false)
            // Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
//    func checkByDoctorSubscriptorNot(response: [String: Any]) {
//        let PATIENT_COUNT = response["PATIENT_COUNT"] as? Int ?? 0
//        if let is_by_doctor = response["by_doctor"] as? Bool {
//            if is_by_doctor {
//                if UserDefaults.standard.string(forKey: kBYDoctorr) == nil {
//                    UserDefaults.standard.set(true, forKey: kBYDoctorr)
//                    if let parent = kSharedAppDelegate.window?.rootViewController {
//                        let objDialouge = PatientID_DialogVC(nibName:"PatientID_DialogVC", bundle:nil)
//                        objDialouge.delegate = self
//                        objDialouge.super_viewVC = self
//                        parent.addChild(objDialouge)
//                        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//                        parent.view.addSubview((objDialouge.view)!)
//                        objDialouge.didMove(toParent: parent)
//                    }
//                }
//            }
//
//            if PATIENT_COUNT == 1 {
//                if appDelegate.is_popupShowing == false {
//                    appDelegate.is_popupShowing = true
//
//                    showSingleAlert(Title: "Your subscription exoires soon", Message: "Get vour personalized content and exercise plan with unlimited access", buttonTitle: "Subscribe Now") {
//                    }
//                }
//
//            } else if PATIENT_COUNT == -1 {
//                if appDelegate.is_popupShowing == false {
//                    appDelegate.is_popupShowing = true
//
//                    showSingleAlert(Title: "Your subscription plan is expired", Message: "Get vour personalized content and exercise plan with unlimited access", buttonTitle: "Subscribe Now") {
//                    }
//                }
//            }
//        }
//    }
    
//    func addPatientID_subscription(_ success: Bool, patientID: String) {
//        IQKeyboardManager.shared.enable = false
//        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
//        if success && patientID != "" {
//            debugPrint("Screen Refresh")
//            self.viewWillAppear(true)
//        }
//    }
    
    
//    func getUserInfoDetailsFromServer(completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            let urlString = kBaseNewURL + endPoint.getUserInfo.rawValue
//
//            AF.request(urlString, method: .post, parameters: nil, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//
//                switch response.result {
//                case .success(let value):
//                    print(response)
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            completion()
//        }
//    }
    
    func callAPIforClickSukhamBanner(completion: @escaping (Bool)->Void) {
        if Utils.isConnectedToNetwork() {

            let urlString = kBaseNewURL + endPoint.SukhamBannerClick.rawValue

            AF.request(urlString, method: .post, parameters: ["language_id" : Utils.getLanguageId()], encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        completion(true)
                        return
                    }

                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? "Fail to get coupons, please try after some time".localized()
                    if status.lowercased() == "success" {
                        completion(true)
                    }

                case .failure(let error):
                    print(error)
                    completion(true)
                }
            }
        } else {
            completion(true)
        }
    }
    
    func callAPIforClickMeLoohaBanner(completion: @escaping (Bool)->Void) {
        if Utils.isConnectedToNetwork() {

            let urlString = kBaseNewURL + endPoint.MeloohaBannerClick.rawValue

            AF.request(urlString, method: .post, parameters: ["language_id" : Utils.getLanguageId(), "device_type": "ios"], encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        completion(true)
                        return
                    }

                    completion(true)

                case .failure(let error):
                    print(error)
                    completion(true)
                }
            }
        } else {
            completion(true)
        }
    }
    
    func getUserTodaysGoalDetailsFromServer(completion: @escaping (Bool)->Void) {
        if Utils.isConnectedToNetwork() {
            
            let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
            let recommendationPrakriti = Utils.getYourCurrentPrakritiStatus()

            let endpoint : endPoint = .getTodaysGoal

            var params = ["user_id": kSharedAppDelegate.userId,
                          "type": recommendationVikriti.rawValue,
                          "typetwo": recommendationPrakriti.rawValue,
                          "language_id" : Utils.getLanguageId()] as [String : Any]

#if !APPCLIP
        params["type"] = appDelegate.cloud_vikriti_status
#endif
            
            debugPrint("endpoint======>>>\(endpoint)\n\nParams=====>>\(params)")
            
            self.viewModel.getTodaysGoal(body: params, endpoint: endpoint) { status, result, error in
                switch status {
                case .loading:
                    break
                case .success:
                    if let result = result?.data, !result.isEmpty {
                        self.arr_TodayGoalData = result
                        completion(true)
                    }else {
                        completion(true)
                    }
                    break
                case .error:
                    completion(true)
                    break
                }
            }
        } else {
            completion(true)
        }
    }
    
    func loginForTokenRefreshFromServer(completion: @escaping (Bool, String) -> Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.login.rawValue
            
            let fcm_Token = kUserDefaults.value(forKey: kFcmToken) as? String ?? ""
            let deviceid_TOKEN = kUserDefaults.value(forKey: kDeviceToken) as? String ?? ""
            var email = ""
            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                email = empData["email"] as? String ?? ""
            }
            
            let params = ["user_name": email,"fcm":fcm_Token,"type": DEVICE_TYPE,"deviceid":deviceid_TOKEN]
            print("===>>> login api called")
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default).responseJSON  { response in
                
                switch response.result {
                
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        completion(false, "Failed to login.".localized())
                        return
                    }
                    
                    if dicResponse["status"] as? String == "Error" {
                        completion(false, dicResponse["Message"] as? String ?? "Failed to login.".localized())
                    }
                    
                    kUserDefaults.set(dicResponse["token"] as? String ?? "", forKey:TOKEN)
                    kUserDefaults.synchronize()
                    completion(true, dicResponse["Message"] as? String ?? "Login successfully".localized())
                    
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription)
                }
            }
        } else {
            completion(false, NO_NETWORK)
        }
    }
    
    static func checkCCRYNCode(isNadiBandProject: Bool, code: String, completion: @escaping (Bool, String)->Void) {
        if Utils.isConnectedToNetwork() {
            var urlString = kBaseNewURL + endPoint.checkCCRYNCode.rawValue
            var params = ["ccryn_code": code]
            
            if isNadiBandProject {
                urlString = kBaseNewURL + endPoint.checkAndSetNadiBandProjectCode.rawValue
                params = ["check_code": code]
            }
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        completion(false, Opps)
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    var message = dicResponse["message"] as? String ?? Opps
                    var isSuccess = (status.lowercased() == "success")
                    if !isNadiBandProject, (dicResponse["data"] as? [String: Any]) == nil {
                        isSuccess = false
                        message = "Please enter the correct code".localized()
                    }
                    completion(isSuccess, message)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription)
                }
            }
        } else {
            completion(false, NO_NETWORK)
        }
    }
    
    static func updateCCRYNValue(value: String, completion: @escaping (Bool, String)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.updateCCRYNValue.rawValue

            let params = ["counter": value]
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        completion(false, Opps)
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? Opps
                    let isSuccess = (status.lowercased() == "success")
                    completion(isSuccess, message)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription)
                }
            }
        } else {
            completion(false, NO_NETWORK)
        }
    }
    
    func showingPopup() {
        if let parent = kSharedAppDelegate.window?.rootViewController {
            let objDialouge = HomeVCNoTestDialouge(nibName:"HomeVCNoTestDialouge", bundle:nil)
            objDialouge.delegate = self
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
            parent.view.addSubview((objDialouge.view)!)
            objDialouge.didMove(toParent: parent)
        }
    }
}


//MARK: - TRY NOW CLICK EVENT
extension MyHomeViewController: delegateTappedTryNow {
    func didTappedOnClickTryNowEvent(_ isSuccess: Bool, is_assessment: Bool) {
        if isSuccess {
            if is_assessment {
                let objBalVC = Story_LoginSignup.instantiateViewController(withIdentifier: "CurrentImbalanceVC") as! CurrentImbalanceVC
                objBalVC.isBackButtonHide = false
                objBalVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(objBalVC, animated: true)
            }
            else {
                let objBalVC = Story_Assessment.instantiateViewController(withIdentifier: "IdealBalanceQuestionnaireVC") as! IdealBalanceQuestionnaireVC
                objBalVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(objBalVC, animated: true)
            }
        }
    }
}
