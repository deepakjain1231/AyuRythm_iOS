//
//  MyHomeViewController.swift
//  HourOnEarth
//
//  Created by Apple on 15/01/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SDWebImage
import MaterialShowcase
import FirebaseInAppMessaging
import AVKit


class MyHomeViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, RegisterDelegeate, delegateCompleteNow, delegateFaceNaadi, InAppMessagingDisplayDelegate {//RecommendationSeeAllDelegate, delegate_patienID

    var KpvPer1 = ""
    var KpvPer2 = ""
    var KpvPer3 = ""
    var is_showcaseAccess = false
    var arrIncreaseValue = [KPVType]()
    let playerController = AVPlayerViewController()
    
    @IBOutlet weak var tblViewHome: UITableView!
    @IBOutlet weak var btnViewDetails: UIButton!
    @IBOutlet weak var lblKpvPer1: UILabel!
    @IBOutlet weak var lblStatus1: UILabel!
    @IBOutlet weak var imgArrow1: UIImageView!
    @IBOutlet weak var lblKpvPer2: UILabel!
    @IBOutlet weak var lblStatus2: UILabel!
    @IBOutlet weak var imgArrow2: UIImageView!
    @IBOutlet weak var lblKpvPer3: UILabel!
    @IBOutlet weak var lblStatus3: UILabel!
    @IBOutlet weak var imgArrow3: UIImageView!
    @IBOutlet weak var viewNoData: UIView!
    @IBOutlet weak var viewRegisterNow: UIView!
    @IBOutlet weak var lblRecommendation: UILabel!
    @IBOutlet weak var lblRecommendationTitle: UILabel!

    @IBOutlet weak var lbl_AyuseedCount: UILabel!
    @IBOutlet weak var btn_userHeader: UIButton!
    @IBOutlet weak var img_userIconHeader: UIImageView!
    @IBOutlet weak var view_ProUser: UIView!
    @IBOutlet weak var btn_floating: UIButton!
    @IBOutlet weak var btn_facenaadi_floating: UIControl!
    @IBOutlet weak var btn_ayumonk_floating: UIControl!
    @IBOutlet weak var constraint_btn_floating_Bottom: NSLayoutConstraint!
    
    var is_openFloating = false
    var arrVoucherCoupon = [CouponCompanyModel]()
    var arr_TodayGoalData = [response_Data?]()
    var arr_section: [HomeScreenRecommendationType] = [HomeScreenRecommendationType]()
    var recommendationType = "Kapha"
    var lastAssessmentValue = ""
    var increasedValues = [KPVType]()
    var dialouge_firstTime = false
    var exceptFirstTime = false
    let viewModel: TodaysGoalViewModel = TodaysGoalViewModel()
    
    var sequence = MaterialShowcaseSequence()
    var sequence_floating = MaterialShowcaseSequence()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewNoData.isHidden = true
        self.btn_floating.isHidden = true
        self.btn_floating.backgroundColor = UIColor.fromHex(hexString: "#A0E09D")
        self.btn_ayumonk_floating.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.btn_facenaadi_floating.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.navigationController?.isNavigationBarHidden = true
        kUserDefaults.set(true, forKey: IS_LOGGEDIN)
        kUserDefaults.set(true, forKey: kIsFirstLaunch)
        registerCells()
        
        self.setupAyuseedData(true)

        addNotifcationObservers()
        fetchAndUpdatePedometerBannerData()
        showNavProfileButton_MyHomeViewController(img_view: self.img_userIconHeader, btn_Profile: self.btn_userHeader, handlePro: self.view_ProUser)
        
        refreshData()
        
        
//        let is_ayumonk = kUserDefaults.object(forKey: k_ayumonk_hide) as? Bool ?? false
//        if is_ayumonk == false {
//            self.btn_floating.isHidden = true
//            self.btn_ayumonk_floating.isHidden = true
//            self.btn_facenaadi_floating.transform = .identity
//            self.constraint_btn_floating_Bottom.constant = -40
//        }
//        else {
//            self.btn_floating.isHidden = false
//            self.btn_ayumonk_floating.isHidden = false
//            self.constraint_btn_floating_Bottom.constant = 20
//        }
    }
    
    func deepLinkHandle() {
        InAppMessaging.inAppMessaging().delegate = self
        self.inAppMessagingInitialization(setSuppressed: false, eventName: "main_activity_ready");
        
        //MARK: - Handle Deep Link
        appDelegate.completation_handle_url = { (str_URL) in
            let str_click = str_URL.lastPathComponent
            if str_click == "facenaadi" {
                self.facenaadi_clk()
                return
            }
            else if str_click == "ayumonk" {
                let is_ayumonk = kUserDefaults.object(forKey: k_ayumonk_hide) as? Bool ?? false
                if is_ayumonk {
                    let obj = AyuMonkVC.instantiate(fromAppStoryboard: .FaceNaadi)
                    obj.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(obj, animated: true)
                }
                return
            }
            else if str_click == "shop" {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    UIApplication.topViewController?.tabBarController?.selectedIndex = 2
                }
                return
            }
            else if str_click == "subscription" {
                let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            else if str_click == "contestlist" {
                debugPrint("Contestlist Click Event")
                let vc = ContestListVC.instantiate(fromAppStoryboard: .Gamification)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            else if str_click == "ayuseeds" {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    UIApplication.topViewController?.tabBarController?.selectedIndex = 3
                }
                return
            }
            else if str_click == "referafriend" {
                debugPrint("Refer a friend Click Event")
                let obj = Story_SideMenu.instantiateViewController(withIdentifier: "ReferEarnVC") as! ReferEarnVC
                obj.hidesBottomBarWhenPushed = true
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.pushViewController(obj, animated: true)
                return
            }
            else if str_click == "ayuverse" {
                debugPrint("Ayuverse Click Event")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    UIApplication.topViewController?.tabBarController?.selectedIndex = 4
                }
                return
            }
            else {
                let str_web_url = str_URL.absoluteString
                if str_web_url.contains("inapp") {
                    let saprate = str_web_url.components(separatedBy: "inapp/")
                    if saprate.count != 0 {
                        let saprate_new = (saprate.last ?? "").components(separatedBy: "/")
                        if (saprate_new.first ?? "") == "shopcategory" {
                            let cat_id = saprate_new[1]
                            let cat_name = saprate_new[2]
                            let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
                            
                            let strCatName = NSString(string: cat_name).removingPercentEncoding ?? cat_name
                            vc.str_Title = strCatName
                            vc.screenFrom = .MP_categoryProductOnly
                            vc.mpDataType = .categoryAllProduct
                            vc.selected_productID = cat_id
                            vc.screenFromm = "home"
                            self.navigationController?.pushViewController(vc, animated: true)
                            return
                        }
                    }
                }
            }
        }
        //********************************************//
    }
    
    func inAppMessagingInitialization(setSuppressed: Bool, eventName: String) {
        InAppMessaging.inAppMessaging().messageDisplaySuppressed = setSuppressed //true == Stop inAppMessaging
        
        if eventName != "" {
            InAppMessaging.inAppMessaging().triggerEvent("main_activity_ready");
        }
    }
    
    func setupAyuseedData(_ apicall: Bool = false) {
        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            //Temp comment//self.checkRedGraphValue()
            self.checkAggravatedValue()
            return
        }
        
        let userIdOld = empData["id"] as? String ?? ""
        self.lbl_AyuseedCount.text = empData["access_point"] as? String ?? ""
        kSharedAppDelegate.userId = userIdOld
        
        self.getLastAssesmentValue(date: empData["timestamp"] as? String)
        
        if apicall {
            get_AvailableSeeds { available_ayuseed in
                self.lbl_AyuseedCount.text = "\(available_ayuseed)"
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if var rightBarButtonItems = navigationItem.rightBarButtonItems, rightBarButtonItems.count < 2 {
//            if kUserDefaults.value(forKey: RESULT_PRAKRITI) != nil && kUserDefaults.value(forKey: RESULT_VIKRITI) != nil {
//                let surveyButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "invalidName_menu.png"), style: .plain, target: self, action: #selector(surveyBtnClicked(_:)))
//                surveyButtonItem.tag = 100
//                rightBarButtonItems.insert(surveyButtonItem, at: 0)
//                navigationItem.rightBarButtonItems = rightBarButtonItems
//            }
//        }
        self.navigationController?.isNavigationBarHidden = true
        self.setupAyuseedData()
        recommendationType = Utils.getRecommendationType()
        TodayRecommendations.shared.lastRecommendationType = recommendationType
//        refreshData()
        
        if self.exceptFirstTime {
            //This Api calling when user did done assessment
            if appDelegate.sparshanAssessmentDone {
                appDelegate.sparshanAssessmentDone = false

                //If both test are not given then show no data view
                Utils.startActivityIndicatorInView(self.view, userInteraction: false)
                getResultFromServer { (isSuccess, isTokenExpired) in
                    Utils.stopActivityIndicatorinView(self.view)
                    if isSuccess {
                        self.manageSection()
                    }
                    
                    if appDelegate.is_start_dietPlan {
                        appDelegate.is_start_dietPlan = false
                        self.gotoDietPlanFlow()
                    }
                }
            }
            
            //This Api calling when user did check mark today's goal
            if appDelegate.apiCallingAsperDataChage {
                appDelegate.apiCallingAsperDataChage = false
                self.arr_TodayGoalData.removeAll()
                self.manageSection()
                self.callAPIforTodaysGoal()
            }
        }
        else {
            var isPrakritiPrashna = false
            if let prashnaResult = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String, !prashnaResult.isEmpty {
                isPrakritiPrashna = true
            }
            
            let isSparshnaTestGiven = kUserDefaults.bool(forKey: kVikritiSparshanaCompleted)
            if isPrakritiPrashna && isSparshnaTestGiven {
                //self.refreshData()
            }
            else {
                manageSection()
            }
        }

        
//        if !kSharedAppDelegate.userId.isEmpty {
//            showNavProfileButton()
//        }
        ARLog("AuthToken : ", Utils.getAuthToken())
        self.tblViewHome.reloadData()
        
        //Check In App purchase Pending Transactions
        SubscriptionDetailVC.completeAnyPendingIAPTransactions(fromVC: self)
        SubscriptionDetailVC.restore_subscription()
    }
    
    
    
    func callAPIforTodaysGoal() {
        if (kUserDefaults.value(forKey: RESULT_PRAKRITI) != nil) && (kUserDefaults.value(forKey: RESULT_VIKRITI) != nil) {
            self.getUserTodaysGoalDetailsFromServer { success in
                self.manageSection()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //FloatingButton.addButton(in: self.view)
        handlePushNotificationDeepLink()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEndNotif(notif:)), name:
            NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        if let headerView = tblViewHome.tableHeaderView {
//
//            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//            var headerFrame = headerView.frame
//
//            //Comparison necessary to avoid infinite loop
//            if height != headerFrame.size.height {
//                headerFrame.size.height = height
//                headerView.frame = headerFrame
//                tblViewHome.tableHeaderView = headerView
//            }
//        }
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    func registerCells() {
        self.tblViewHome.register(nibWithCellClass: LoadingTableCell.self)
        self.tblViewHome.register(nibWithCellClass: HomeRemediesTableCell.self)
        self.tblViewHome.register(nibWithCellClass: HomeAyuMonkTableCell.self)
        self.tblViewHome.register(nibWithCellClass: SubscriptionTableViewCell.self)
        self.tblViewHome.register(nibWithCellClass: ARPedometerBannerCell.self)
        self.tblViewHome.register(nibWithCellClass: ARWellnessPlanBannerCell.self)
        self.tblViewHome.register(nibWithCellClass: HomeScreenFirstCell.self)
        self.tblViewHome.register(nibWithCellClass: HomeScreenNoSparshnaTableCell.self)
        self.tblViewHome.register(nibWithCellClass: HomeScreenExploreTableCell.self)
        self.tblViewHome.register(nibWithCellClass: HomeScreen_PluseTestTableCell.self)
        self.tblViewHome.register(nibWithCellClass: HomeScreen_RewardsTableCell.self)
        self.tblViewHome.register(nibWithCellClass: HomeScreenTodayGoalTableCell.self)
        self.tblViewHome.register(nibWithCellClass: HomeScreenKriyaMudraTableCell.self)
        self.tblViewHome.register(nibWithCellClass: HomeScreenFoodHerbsTableCell.self)
        self.tblViewHome.register(nibWithCellClass: HomeScreenDailyPlanner.self)
        self.tblViewHome.register(nibWithCellClass: HomeScreenVoucherTableCell.self)
        self.tblViewHome.register(nibWithCellClass: ShukhamBannerTableCell.self)
        self.tblViewHome.register(nibWithCellClass: WeightTrackerTableCell.self)
    }
    
    //MARK: UITableViewCell
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = self.arr_section[indexPath.row]
        switch rowType {
        case .noTestDone, .noSparshnaTest, .noQuestionnaires, .noQuestionnairesVikrati, .lastAssessment, .pedometer, .weightTracker, .explore, .rewards, .todaygoal_header, .goal_Meditation, .explore_foodHerb, .voucher, .shop_banner, .meeLohaBanner:
            return UITableView.automaticDimension
        case .ayumonk:
            if UserDefaults.user.is_main_subscription {
                return 195
            }
            return 245
        case .homeremedies_banner:
            return UITableView.automaticDimension
        case .subscription, .wellnessPlan, .daily_planner:
            return 190
        default:
            return 210
        }
    }
    
    //MARK: TableViewDelegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = self.arr_section[indexPath.row]
        switch rowType {
            
        case .noTestDone(let title, let isSparshna, let isParshna):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenFirstCell") as? HomeScreenFirstCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setupmainLabel(title_text: title, is_sparshna: isSparshna, is_prashna: isParshna)
            return cell
            
        case .noSparshnaTest(let isSparshna, let isParshna):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenNoSparshnaTableCell") as? HomeScreenNoSparshnaTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setupForPluseAssessment(is_sparshna: isSparshna, is_parshna: isParshna)
            
            //Try Now Tapped
            cell.didTappedonTryNow = {(sender) in
                self.didTappedOnClickTryNowEvent(true, is_assessment: true)
            }
            
            return cell
            
        case .noQuestionnaires(let isSparshna, let isParshna):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenNoSparshnaTableCell") as? HomeScreenNoSparshnaTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setupForQuestionnaires(is_sparshna: isSparshna, is_parshna: isParshna)
            
            //Try Now Tapped
            cell.didTappedonTryNow = {(sender) in
                self.didTappedOnClickTryNowEvent(true, is_assessment: false)
            }
            
            return cell
            
        case .noQuestionnairesVikrati:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenNoSparshnaTableCell") as? HomeScreenNoSparshnaTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setupForQuestionnairesVikrati()
            
            //Try Now Tapped
            cell.didTappedonTryNow = {(sender) in
                self.showPrashna()
            }
            
            return cell
            
            
        case .explore:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenExploreTableCell") as? HomeScreenExploreTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            return cell
            
        case .explore_foodHerb:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenFoodHerbsTableCell") as? HomeScreenFoodHerbsTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            
            cell.didTappedonFood = {(sender) in
                self.showFood_HerbsScreen(sectionType: .Food)
            }
            
            cell.didTappedonHearbs = {(sender) in
                self.showFood_HerbsScreen(sectionType: .Herbs)
            }
            
            return cell

        case .lastAssessment(_):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreen_PluseTestTableCell") as? HomeScreen_PluseTestTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configureUI(value: self.lastAssessmentValue)

            let strTextMsg = getDisplayMessage_LastAssessment().0.localized()
            var strKPVPrensentage = getDisplayMessage_LastAssessment().1.localized()
            var strKPV = getDisplayMessage_LastAssessment().2.localized()

            var fullText = String(format: strTextMsg.localized(), strKPV, strKPVPrensentage)
            
            if let dic_userInfo = UserDefaults.user.get_user_info_result_data["Userinfo"] as? [String: Any] {
                strKPVPrensentage = ""
                strKPV = dic_userInfo["aggravation"] as? String ?? ""
                fullText = String(format: "Your %@ is aggravated".localized(), strKPV.capitalized)
            }

            setupAttributedText(str_FullText: fullText,
                                fullTextFont: UIFont.AppFontSemiBold(16),
                                fullTextColor: UIColor.fromHex(hexString: "#777777"),
                                highlightText1: strKPV,
                                highlightText1Font: UIFont.AppFontSemiBold(16),
                                highlightText1Color: UIColor.fromHex(hexString: "#2F2E2E"),
                                highlightText2: strKPVPrensentage,
                                highlightText2Font: UIFont.AppFontSemiBold(16),
                                highlightText2Color: UIColor.fromHex(hexString: "#2F2E2E"),
                                lbl_attribute: cell.lbl_kpvText)

            self.setup_KPV_colors(img_aggrivation: cell.img_kpv, imgKPV: cell.img_kpv_full, view_aggrivation: cell.view_img_kpv, lbl_Text: cell.lbl_kpvText, img_arrow: cell.img_kpv_arrow)
            

            cell.did_TappedRetestClicked = { (sender) in
                let storyboard = UIStoryboard(name: "MyHome", bundle: nil)
                let retestController = storyboard.instantiateViewController(withIdentifier:"RetestViewController" ) as! RetestViewController
                retestController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(retestController, animated: true)
            }
            
            cell.did_TappedPulseTestClicked = { (sender) in
                let objBalVC = Story_LoginSignup.instantiateViewController(withIdentifier: "CurrentImbalanceVC") as! CurrentImbalanceVC
                objBalVC.hidesBottomBarWhenPushed = true
                objBalVC.isBackButtonHide = false
                self.navigationController?.pushViewController(objBalVC, animated: true)
            }
            
            cell.did_TappedInfoClicked = { (sender) in
                let strHeaderText = fullText.replacingOccurrences(of: "\n", with: " ")
                
                let objVC = Story_MyHome.instantiateViewController(withIdentifier: "MyHomeDetailViewController") as! MyHomeDetailViewController
                objVC.hidesBottomBarWhenPushed = true
                objVC.str_Kpv = strKPV
                objVC.str_Header = strHeaderText
                objVC.str_KpvPrensentage = strKPVPrensentage
                self.navigationController?.pushViewController(objVC, animated: true)
            }
            
            return cell
            
        case .todaysGoalLoading:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableCell") as? LoadingTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none

            return cell
            
        case .todaygoal_header:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenTodayGoalTableCell") as? HomeScreenTodayGoalTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            
            
            cell.didTappedonEdit = {(sender) in
                let storyBoard = UIStoryboard(name: "Survey", bundle: nil)
                let nvc = storyBoard.instantiateViewController(withIdentifier: "SurveyMainNVC")
                nvc.modalPresentationStyle = .fullScreen
                self.present(nvc, animated: true, completion: nil)
            }
            
            return cell
            
        case .goal_Meditation(let goal_type, let dic_data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenKriyaMudraTableCell") as? HomeScreenKriyaMudraTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.progressView.clockwise = true
            cell.progressView.setProgress(progress: 0)
            cell.lbl_ayuseed.text = "\(dic_data?.goal_data?.ayuseeds ?? 0)"
            cell.lbl_Title.text = dic_data?.favorite_asana_type ?? ""
            cell.lbl_subTitle.text = dic_data?.goal_data?.user_watch_count ?? ""
            cell.lbl_bottom.text = dic_data?.goal_data?.total_people_completed ?? ""

            let doneCount = dic_data?.goal_data?.user_watch_count_done ?? 0
            let totalCount = dic_data?.goal_data?.user_watch_count_total ?? 0
            if doneCount == 0 && totalCount == 0 {
                cell.progressView.setProgress(progress: 0)
            }
            else {
                let double_doneCount: Double = Double(doneCount)
                let double_totalCount: Double = Double(totalCount)
                let progess: Double = ((100/double_totalCount)*double_doneCount).rounded(.up)
                cell.progressView.setProgress(progress: progess/100)
            }

            if goal_type == .Meditation {
                cell.img_Type.image = UIImage.init(named: "icon_meditation")
                cell.view_BG.backgroundColor = UIColor.fromHex(hexString: "#FFCCD9")
                cell.progressView.progressShapeColor = UIColor.fromHex(hexString: "#FFCCD9")
            }
            else if goal_type == .Yogasana {
                cell.img_Type.image = UIImage.init(named: "icon_yogasana")
                cell.view_BG.backgroundColor = UIColor.fromHex(hexString: "#DFCEFD")
                cell.progressView.progressShapeColor = UIColor.fromHex(hexString: "#DFCEFD")
            }
            else if goal_type == .Pranayama {
                cell.img_Type.image = UIImage.init(named: "icon_pranayama")
                cell.view_BG.backgroundColor = UIColor.fromHex(hexString: "#CCDDFF")
                cell.progressView.progressShapeColor = UIColor.fromHex(hexString: "#CCDDFF")
            }
            else if goal_type == .Kriyas {
                cell.img_Type.image = UIImage.init(named: "icon_kriya")
                cell.view_BG.backgroundColor = UIColor.fromHex(hexString: "#C4EEE0")
                cell.progressView.progressShapeColor = UIColor.fromHex(hexString: "#C4EEE0")
            }
            else if goal_type == .Mudras {
                cell.img_Type.image = UIImage.init(named: "icon_mudra")
                cell.view_BG.backgroundColor = UIColor.fromHex(hexString: "#FFE9B2")
                cell.progressView.progressShapeColor = UIColor.fromHex(hexString: "#FFE9B2")
            }

            
            //============================================================================//
            cell.didTappedonCell = {(sender) in
                let vc = HerbList_NewVC.instantiate(fromAppStoryboard: .DailyPlanner)
                vc.recommendationVikriti = RecommendationType(rawValue: self.recommendationType) ?? RecommendationType.kapha
                vc.sectionType = goal_type
                vc.dic_goalData = dic_data
                vc.isFromHome = true
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            //***************************************************************************//
            //***************************************************************************//
            
            return cell
            
        case .ayumonk:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeAyuMonkTableCell") as? HomeAyuMonkTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setupCellData()
            
            if UserDefaults.user.is_main_subscription {
                cell.btn_prime.isHidden = true
                cell.btn_prime.isHidden = false
                cell.btn_unlock_ayumonk.isHidden = true
                cell.btn_prime.setTitle("Explore Now".localized(), for: .normal)
            }
            else {
                if UserDefaults.user.is_ayumonk_subscribed {
                    cell.btn_prime.isHidden = false
                    cell.btn_unlock_ayumonk.isHidden = false
                    cell.btn_unlock_ayumonk.setTitle("Explore Now".localized(), for: .normal)
                }
                else {
                    if UserDefaults.user.free_ayumonk_question == UserDefaults.user.ayumonk_trial ||
                        UserDefaults.user.free_ayumonk_question < UserDefaults.user.ayumonk_trial {
                        cell.btn_prime.isHidden = false
                        cell.btn_unlock_ayumonk.isHidden = false
                        cell.btn_prime.setTitle("Join Prime Club".localized(), for: .normal)
                        cell.btn_unlock_ayumonk.setTitle("Unlock AyuMonk".localized(), for: .normal)
                    }
                    else {
                        cell.btn_prime.isHidden = false
                        cell.btn_unlock_ayumonk.isHidden = false
                        cell.btn_unlock_ayumonk.setTitle("Free Trial".localized(), for: .normal)
                    }
                }
            }
                        
            //Button Action
            cell.didTappedPrimeButton = { (sender) in
                if UserDefaults.user.is_main_subscription {
                    let obj = AyuMonkVC.instantiate(fromAppStoryboard: .FaceNaadi)
                    obj.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(obj, animated: true)
                }
                else {
                    let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.isNavigationBarHidden = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            
            cell.didTappedUnlockAyuMonkButton = { (sender) in
                if UserDefaults.user.is_ayumonk_subscribed {
                    self.ayumonk_Clicked()
                }
                else {
                    if UserDefaults.user.free_ayumonk_question == UserDefaults.user.ayumonk_trial ||
                        UserDefaults.user.free_ayumonk_question < UserDefaults.user.ayumonk_trial {
                        
                        let obj = FaceNaadiSubscriptionListVC.instantiate(fromAppStoryboard: .FaceNaadi)
                        obj.str_screenFrom = .from_AyuMonk_Only
                        obj.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(obj, animated: true)
                    }
                    else {
                        self.ayumonk_Clicked()
                    }
                }
            }

            return cell
            
        case .homeremedies_banner:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeRemediesTableCell") as? HomeRemediesTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setupCellData()
            
            if UserDefaults.user.is_main_subscription {
                cell.btn_prime.isHidden = true
                cell.img_arrow.isHidden = false
                cell.btn_click.isHidden = false
                cell.btn_unlock_remedies.isHidden = true
            }
            else {
                if UserDefaults.user.is_remedies_subscribed {
                    cell.btn_prime.isHidden = true
                    cell.img_arrow.isHidden = false
                    cell.btn_click.isHidden = false
                    cell.btn_unlock_remedies.isHidden = true
                }
                else {
                    if UserDefaults.user.free_remedies_count == UserDefaults.user.home_remedies_trial ||
                        UserDefaults.user.free_remedies_count < UserDefaults.user.home_remedies_trial {
                        cell.btn_click.isHidden = true
                        cell.btn_prime.isHidden = false
                        cell.img_arrow.isHidden = true
                        cell.btn_unlock_remedies.isHidden = false
                        cell.btn_unlock_remedies.setTitle("Unlock Home Remedies".localized(), for: .normal)
                    }
                    else {
                        cell.btn_click.isHidden = true
                        cell.btn_prime.isHidden = false
                        cell.img_arrow.isHidden = true
                        cell.btn_unlock_remedies.isHidden = false
                        cell.btn_unlock_remedies.setTitle("Free Trial".localized(), for: .normal)
                    }
                }
            }
            
            cell.btn_click.addTarget(self, action: #selector(self.homeRemedies_Clicked), for: .touchUpInside)
            
            //Button Action
            cell.didTappedPrimeButton = { (sender) in
                let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
                vc.hidesBottomBarWhenPushed = true
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            cell.didTappedUnlockRemediesButton = { (sender) in
                if UserDefaults.user.free_remedies_count == UserDefaults.user.home_remedies_trial ||
                    UserDefaults.user.free_remedies_count < UserDefaults.user.home_remedies_trial {
                    let obj = FaceNaadiSubscriptionListVC.instantiate(fromAppStoryboard: .FaceNaadi)
                    obj.str_screenFrom = .from_home_remedies
                    obj.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(obj, animated: true)
                }
                else {
                    self.homeRemedies_Clicked()
                }
                
            }

            return cell
            
        case .subscription:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionTableViewCell") as? SubscriptionTableViewCell else { return UITableViewCell() }
            cell.subscriptionBtn.addTarget(self, action: #selector(subscribeBtnClicked(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            cell.setupData()
            return cell
            
        case .pedometer:
            let cell = tableView.dequeueReusableCell(withClass: ARPedometerBannerCell.self, for: indexPath)
            cell.setupUI()
            cell.selectionStyle = .none
            return cell
            
        case .weightTracker:
            let cell = tableView.dequeueReusableCell(withClass: WeightTrackerTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            cell.setupCell()
            
            
            cell.didTappedAdd_WeightButton = { (sender) in
                self.showActivityIndicator()
                let newWeight = Shared.sharedInstance.userWeight + 1
                ARLog("updateWeightBy : \(1), new weight : \(newWeight)")
                ARBPLDeviceManager.updateUserWeight(by: newWeight) { success, message, measurements  in
                    if success {
                        self.tblViewHome.reloadData()
                        self.hideActivityIndicator()
                    } else {
                        self.hideActivityIndicator(withMessage: message)
                    }
                }
            }
            
            cell.didTappedSubstack_WeightButton = { (sender) in
                self.showActivityIndicator()
                let newWeight = Shared.sharedInstance.userWeight - 1
                ARLog("updateWeightBy : \(1), new weight : \(newWeight)")
                ARBPLDeviceManager.updateUserWeight(by: newWeight) { success, message, measurements  in
                    if success {
                        self.tblViewHome.reloadData()
                        self.hideActivityIndicator()
                    } else {
                        self.hideActivityIndicator(withMessage: message)
                    }
                }
            }

            return cell
            
        case .rewards:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreen_RewardsTableCell") as? HomeScreen_RewardsTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            
            cell.didTappedonRewards = {(sender) in
                EarnAyuseedVC.showScreen(fromVC: self)
            }
            
            cell.didTappedonTrackProgress = {(sender) in
                ResultHistoryViewController.showScreen(fromVC: self)
            }
            
            return cell
            
        case .wellnessPlan:
            let cell = tableView.dequeueReusableCell(withClass: ARWellnessPlanBannerCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.setupCell_Data()
            return cell
            
        case .shop_banner:
            let cell = tableView.dequeueReusableCell(withClass: ShukhamBannerTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.view_blank.isHidden = true
            cell.btn_download.isHidden = true
            cell.constraint_view_Height.constant = 135
            
            let str_imgURL = UserDefaults.user.get_user_info_result_data["discount_offer_background"] as? String ?? ""
            if str_imgURL != "" {
                cell.img_banner.sd_setImage(with: URL.init(string: str_imgURL), placeholderImage: UIImage.init(named: "icon_Empty_state"), progress: nil)
            }
            else {
                cell.img_banner.image = UIImage.init(named: "icon_Empty_state")
            }
            
            return cell
            
        case .meeLohaBanner:
            let cell = tableView.dequeueReusableCell(withClass: ShukhamBannerTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.view_blank.isHidden = false
            cell.btn_download.isHidden = false
            cell.img_banner.contentMode = .scaleAspectFill
            
            let str_imgURL = UserDefaults.user.get_user_info_result_data["melooha_background"] as? String ?? ""
            if str_imgURL != "" {
                cell.constraint_view_Height.constant = 175
                cell.img_banner.sd_setImage(with: URL.init(string: str_imgURL), placeholderImage: UIImage.init(named: "icon_Empty_state"), progress: nil)
            }
            else {
                cell.img_banner.image = UIImage.init(named: "icon_Empty_state")
            }
            
            let str_button_bg = UserDefaults.user.get_user_info_result_data["melooha_buttonbgcolor"] as? String ?? ""
            let str_button_Text = UserDefaults.user.get_user_info_result_data["melooha_buttontext"] as? String ?? ""
            let str_button_TextColor = UserDefaults.user.get_user_info_result_data["melooha_buttontextcolor"] as? String ?? ""
            let str_click_url = UserDefaults.user.get_user_info_result_data["melooha_play_store_url"] as? String ?? ""
            
            cell.lbl_download.text = str_button_Text
            cell.lbl_download.textColor = UIColor.fromHex(hexString: str_button_TextColor)
            cell.btn_download.backgroundColor = UIColor.fromHex(hexString: str_button_bg)
            
            //Did Tapped
            cell.didTappedonDownload = { (sender) in
                Utils.startActivityIndicatorInView(self.view, userInteraction: true)
                self.callAPIforClickMeLoohaBanner { success in
                    Utils.stopActivityIndicatorinView(self.view)
                    DispatchQueue.main.async {
                        guard let url = URL(string: str_click_url) else {
                          return //be safe
                        }

                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            }
            
            return cell

        case .daily_planner:
            let cell = tableView.dequeueReusableCell(withClass: HomeScreenDailyPlanner.self, for: indexPath)
            cell.selectionStyle = .none
            cell.setupCell_Data()
            return cell
            
        case .voucher:
            let cell = tableView.dequeueReusableCell(withClass: HomeScreenVoucherTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_Title.text = "Vouchers".localized()
            cell.voucherData = self.arrVoucherCoupon
            cell.strCompanyName = self.arrVoucherCoupon.first?.companyName ?? ""
            
            cell.didTappedonSelectedCoupon = { (coupon) in
                self.fetchAyuSeedsDetailsAndSetupUI(coupon)
            }
            
            return cell

        }
    }
    
    func fetchAyuSeedsDetailsAndSetupUI(_ dic_Data: CouponModel) {
        showActivityIndicator()
        AyuSeedsRedeemManager.fetchAvailableSeedsInfo { (isSuccess, message, lifetimeSeeds, spentSeeds) in
            self.hideActivityIndicator()
            let str_totalAvailableSeed = String(lifetimeSeeds - spentSeeds)

            if let availableSeeds = Float(str_totalAvailableSeed), let redeemSeeds = Float(dic_Data.ayuseeds) {
                let progress = availableSeeds/redeemSeeds
                if progress < 1 {
                    BuyAyuSeedsViewController.showScreen(presentingVC: self.tabBarController)
                } else {
                    let vc = CouponDetailViewController.instantiateFromStoryboard("Coupons")
                    vc.coupon = dic_Data
                    vc.couponCompany = self.arrVoucherCoupon.first
                    vc.totalAvailableSeed = str_totalAvailableSeed
                    self.navigationController?.isNavigationBarHidden = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowType = self.arr_section[indexPath.row]
        switch rowType {
        case .lastAssessment:
            showSparshnaResult()

        case .pedometer:
            ARStepsDeatilsVC.showScreen(fromVC: self)

        case .wellnessPlan:
            self.gotoDietPlanFlow()
            
        case .shop_banner:
            
            self.callAPIforClickSukhamBanner { success in
                if success {
                    //Shop Section
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                        UIApplication.topViewController?.tabBarController?.selectedIndex = 2
                    }
                }
            }
            
        case .meeLohaBanner:
            
            let str_videoURL = UserDefaults.user.get_user_info_result_data["melooha_background_video"] as? String ?? ""
            if str_videoURL != "" {
                if let url = URL.init(string: str_videoURL) {
                    let player = AVPlayer(url: url)
                    self.playerController.player = player
                    self.present(self.playerController, animated: true) {
                        player.play()
                    }
                }
            }
            
            
            
            
//            self.callAPIforClickSukhamBanner { success in
//                if success {
//                    //Shop Section
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
//                        UIApplication.topViewController?.tabBarController?.selectedIndex = 2
//                    }
//                }
//            }
        
        case .daily_planner:
            DailyPlannerVC.showScreen(fromVC: self)

        case .noSparshnaTest( _, _):
            self.didTappedOnClickTryNowEvent(true, is_assessment: true)
            
        case .explore:
            if let parent = kSharedAppDelegate.window?.rootViewController {
                let objDialouge = GenericContentDialouge(nibName:"GenericContentDialouge", bundle:nil)
                objDialouge.delegate = self
                parent.addChild(objDialouge)
                objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
                parent.view.addSubview((objDialouge.view)!)
                objDialouge.didMove(toParent: parent)
            }
            
            
        default:
            break
        }
    }
    
    @objc func videoDidEndNotif(notif: Notification) {
        //print(">>>> videoDidEndNotif : ", notif.object)
        self.playerController.dismiss(animated: true)
    }
    
    
    func gotoDietPlanFlow() {
        if UserDefaults.user.is_main_subscription {
            ARWellnessPlanVC.showScreen(fromVC: self)
        }
        else {
            if UserDefaults.user.is_diet_plan_subscribed {
                ARWellnessPlanVC.showScreen(fromVC: self)
            }
            else {
                DietPlanLandingVC.showScreen(fromVC: self)
            }
        }
    }
    
    func showSparshnaResult() {
        
//        let storyBoard = UIStoryboard(name: "SparshnaResult", bundle: nil)
//                            let objDescription = storyBoard.instantiateViewController(withIdentifier: "SparshnaResult") as! SparshnaResult
//                            self.navigationController?.pushViewController(objDescription, animated: true)
        
        LastAssessmentVC.showScreen(isFromOnBoarding: true, fromVC: self)
    }
    
    @IBAction func btn_floating_action(_ sender: UIButton) {
        if self.is_openFloating {
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut) {
                self.btn_floating.transform = .identity
                self.btn_ayumonk_floating.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
                self.btn_facenaadi_floating.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
                self.is_openFloating = false
            }
            
        }
        else {
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut) {
                self.btn_floating.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
                self.btn_ayumonk_floating.transform = .identity
                self.btn_facenaadi_floating.transform = .identity
                self.is_openFloating = true
            }
            
            if (kUserDefaults.bool(forKey: is_showcase_3) == false) {
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    let showcase1 = MaterialShowcase()
                    showcase1.tag = 420
                    showcase1.setTargetView(view: self.btn_facenaadi_floating)
                    showcase1.primaryText = "Dosha analysis via selfie video!"
                    showcase1.secondaryText = ""
                    showcase1.shouldSetTintColor = false
                    showcase1.backgroundPromptColor = AppColor.app_DarkGreenColor
                    showcase1.backgroundPromptColorAlpha = 0.75
                    showcase1.isTapRecognizerForTargetView = false
                    
                    let showcase2 = MaterialShowcase()
                    showcase2.tag = 421
                    showcase2.setTargetView(view: self.btn_ayumonk_floating)
                    showcase2.primaryText = "Ayurvedic insights: AI enabled now!"
                    showcase2.secondaryText = ""
                    showcase2.shouldSetTintColor = false
                    showcase2.backgroundPromptColor = AppColor.app_DarkGreenColor
                    showcase2.backgroundPromptColorAlpha = 0.75
                    showcase2.isTapRecognizerForTargetView = false
                    
                    showcase1.delegate = self
                    showcase2.delegate = self
                    self.sequence_floating.temp(showcase1).temp(showcase2).start()
                }
            }
        }
    }
    
    @IBAction func btn_ayumonk_action(_ sender: UIControl) {
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut) {
            self.btn_floating.transform = .identity
            self.btn_ayumonk_floating.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.btn_facenaadi_floating.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.is_openFloating = false
        }
        
        let obj = AyuMonkVC.instantiate(fromAppStoryboard: .FaceNaadi)
        obj.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btn_facenaadi_action(_ sender: UIControl) {
        let is_ayumonk = kUserDefaults.object(forKey: k_ayumonk_hide) as? Bool ?? false
        if is_ayumonk {

            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut) {
                self.btn_floating.transform = .identity
                self.btn_ayumonk_floating.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
                self.btn_facenaadi_floating.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
                self.is_openFloating = false
            }

        }
        self.facenaadi_clk()
    }
    
    func goToFaceNaadiScreen() {
        //Go To FaceNaadi Screen
        let objBalVC = Story_LoginSignup.instantiateViewController(withIdentifier: "CurrentImbalanceVC") as! CurrentImbalanceVC
        objBalVC.isBackButtonHide = false
        objBalVC.is_DirectFaceNaadi = true
        objBalVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(objBalVC, animated: true)
    }
    
    func goToSubscriptionDialouge() {
        if let parent = appDelegate.window?.rootViewController {
            let objDialouge = FaceNaadiDialouge(nibName:"FaceNaadiDialouge", bundle:nil)
            objDialouge.delegate = self
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
            parent.view.addSubview((objDialouge.view)!)
            objDialouge.didMove(toParent: parent)
        }
    }
    
    func facenaadi_clk() {
        if UserDefaults.user.is_main_subscription {
            self.goToFaceNaadiScreen()
        }
        else {
            if UserDefaults.user.is_facenaadi_subscribed {
                self.goToFaceNaadiScreen()
            }
            else {
                self.goToSubscriptionDialouge()
            }
        }
        
        
        
        
        //Temp Comment
        /*
        let is_facenaadi_subscribed = kUserDefaults.object(forKey: k_facenaadi_subscribed) as? Bool ?? false
        if is_facenaadi_subscribed {
            if appDelegate.facenaadi_doctor_coupon_code == "" {
                self.goToFaceNaadiScreen()
            }
            else {
                self.callAPIforCheckFacenaadiCouponValid { success, str_msg in
                    if success {
                        self.goToFaceNaadiScreen()
                    }
                    else {
                        self.goToSubscriptionDialouge()
                    }
                }
            }
        }
        else {
            self.goToSubscriptionDialouge()
        }
        */
    }
    
    @IBAction func viewDetailsClicked(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "MyHome", bundle: nil)
        let objAssesment = storyBoard.instantiateViewController(withIdentifier: "MyHomeDetailViewController") as! MyHomeDetailViewController
        //objAssesment.increasedValues = self.increasedValues
        self.navigationController?.pushViewController(objAssesment, animated: true)
    }
    
    @IBAction func completePrakritiClicked(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "InitialFlow", bundle: nil)
        let objDescription = storyBoard.instantiateViewController(withIdentifier: "PrakritiViewController") as! PrakritiViewController
        self.navigationController?.pushViewController(objDescription, animated: true)
    }
    
    @IBAction func completeVikritiClicked(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "InitialFlow", bundle: nil)
        let objDescription = storyBoard.instantiateViewController(withIdentifier: "KPVDescriptionViewController") as! KPVDescriptionViewController
        self.navigationController?.pushViewController(objDescription, animated: true)
    }
    
    @IBAction func fingerPrintClicked(_ sender: Any) {
        showSparshna()
    }
    
    @IBAction func completeNowClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyHome", bundle: nil)
        let retestController = storyboard.instantiateViewController(withIdentifier:"RetestViewController" ) as! RetestViewController
        self.navigationController?.pushViewController(retestController, animated: true)
    }
    
    @IBAction func searchBtnClicked(_ sender: Any) {
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view recommendations", controller: self)
            return
        }
        let storyBoard = UIStoryboard(name: "MyHome", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "GlobalSearchViewController") as? GlobalSearchViewController else {
            return
        }
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }
    
    @IBAction func surveyBtnClicked(_ sender: Any) {
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view recommendations", controller: self)
            return
        }
        //let surveyVC = SurveyMainViewController.instantiateFromStoryboard("Survey")
        let storyBoard = UIStoryboard(name: "Survey", bundle: nil)
        let nvc = storyBoard.instantiateViewController(withIdentifier: "SurveyMainNVC")
        nvc.modalPresentationStyle = .fullScreen
        (nvc as! SurveyMainViewController).superVC = self
        self.present(nvc, animated: true, completion: nil)
    }
    
    @objc func ayumonk_Clicked() {
        let obj = AyuMonkVC.instantiate(fromAppStoryboard: .FaceNaadi)
        obj.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @objc func homeRemedies_Clicked() {
        let vc = HomeRemediesViewController.instantiate(fromAppStoryboard: .HomeRemedies)
        vc.isFromAyuverseContentLibrary = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func subscribeBtnClicked(_ sender: UIButton) {
        let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func showFood_HerbsScreen(sectionType: TodayGoal_Type) {
        let vc = HerbList_NewVC.instantiate(fromAppStoryboard: .DailyPlanner)
        vc.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        vc.sectionType = sectionType
        vc.isFromHome = true
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showDetailScreen(sectionType: ForYouSectionType, data: [NSManagedObject]) {

        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "HOEYogaListVC") as? HOEYogaListVC else {
            return
        }
        objFoodView.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        objFoodView.sectionType = sectionType
        if sectionType == .food || sectionType == .herbs {
            objFoodView.isFromHome = true
        } else {
            objFoodView.dataArray = data
        }
        self.navigationController?.pushViewController(objFoodView, animated: true)

    }
    
    func showYogaPlayListScreen(data: [Yoga]) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        objPlayList.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        objPlayList.yogaArray = data
        objPlayList.istype = .yoga
        objPlayList.isFromHomeScreen = true
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }
    
    func showMeditationPlayListScreen(data: [Meditation]) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        objPlayList.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        objPlayList.meditationArray = data
        objPlayList.istype = .meditation
        objPlayList.isFromHomeScreen = true
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }

    func showPranayamaPlayListScreen(data: [Pranayama]) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        objPlayList.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        objPlayList.pranayamaArray = data
        objPlayList.istype = .pranayama
        objPlayList.isFromHomeScreen = true
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }
    
    func showMudraPlayListScreen(data: [Mudra]) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        objPlayList.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        objPlayList.mudraArray = data
        objPlayList.istype = .mudra
        objPlayList.isFromHomeScreen = true
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }

    func showkriyaPlayListScreen(data: [Kriya]) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        objPlayList.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        objPlayList.kriyaArray = data
        objPlayList.istype = .kriya
        objPlayList.isFromHomeScreen = true
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }
    
    //MARK: - FaceNaadi Click Manage
    func subscribe_tryNow_click(_ success: Bool, type: ScreenType) {
        if success {
            if type == ScreenType.from_AyuMonk_Only || type == ScreenType.fromFaceNaadi {
                let obj = FaceNaadiSubscriptionListVC.instantiate(fromAppStoryboard: .FaceNaadi)
                obj.str_screenFrom = type
                obj.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(obj, animated: true)
            }
            else if type == ScreenType.from_PrimeMember {
                let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if type == ScreenType.from_facenaadi_free_trial {
                //Go To FaceNaadi Screen
                let objBalVC = Story_LoginSignup.instantiateViewController(withIdentifier: "CurrentImbalanceVC") as! CurrentImbalanceVC
                objBalVC.isBackButtonHide = false
                objBalVC.is_DirectFaceNaadi = true
                objBalVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(objBalVC, animated: true)
            }
            else {
                //Temp Comment
                /*
                let is_facenaadi_done = kUserDefaults.object(forKey: k_facenaadi_done) as? Bool ?? false
                let is_facenaadi_subscribed = kUserDefaults.object(forKey: k_facenaadi_subscribed) as? Bool ?? false
                if is_facenaadi_done && is_facenaadi_subscribed == false {
                    let obj = FaceNaadiSubscriptionListVC.instantiate(fromAppStoryboard: .FaceNaadi)
                    obj.hidesBottomBarWhenPushed = true
                    obj.str_screenFrom = .fromFaceNaadi
                    self.navigationController?.pushViewController(obj, animated: true)
                }
                else
                */
            }
        }
    }


    //MARK: Register Delegate
    func registerClicked() {
        kSharedAppDelegate.showSignUpScreen()
    }
    
    @IBAction func registerClicked(_ sender: UIButton) {
        kSharedAppDelegate.showSignUpScreen()
    }

    func facenaadiOptionSelection(_ success: Bool, selected_option: FacenaadiSelectionOption) {
        if success {
            if selected_option == .fingerSparshna {
                SparshnaAlert.showSparshnaTestScreen(isBackBtnVisible: true, fromVC: self)
            }
            else {
                let obj = CustomCameraVC.instantiate(fromAppStoryboard: .SparshnaTestInfo)
                self.navigationController?.pushViewController(obj, animated: true)
                
                /*
                let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
                let objAlert = storyBoard.instantiateViewController(withIdentifier: "SparshnaAlert") as! SparshnaAlert
                objAlert.is_facenaadi = true
                objAlert.modalPresentationStyle = .overCurrentContext
                objAlert.completionHandler = {
                    let obj = CustomCameraVC.instantiate(fromAppStoryboard: .SparshnaTestInfo)
                    self.navigationController?.pushViewController(obj, animated: true)
                }
                self.present(objAlert, animated: true)
                */
            }
        }
    }

    func clickonGenericContent(_ success: Bool, clickComplteNow: Bool, clickLater: Bool) {
        if success {
            if clickComplteNow {
                var isPrakritiPrashna = false
                if let prashnaResult = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String, !prashnaResult.isEmpty {
                    isPrakritiPrashna = true
                }

                let isSparshnaTestGiven = kUserDefaults.bool(forKey: kVikritiSparshanaCompleted)
                if !isSparshnaTestGiven {
                    self.didTappedOnClickTryNowEvent(true, is_assessment: true)
                    return
                }
                
                if !isPrakritiPrashna {
                    self.didTappedOnClickTryNowEvent(true, is_assessment: false)
                    return
                }

            }
        }
    }
    
    
    //
    //MARK: -
    func messageClicked(_ inAppMessage: InAppMessagingDisplayMessage) {
        // ...
        let appData = inAppMessage.appData
    }
    
    func messageDismissed(_ inAppMessage: InAppMessagingDisplayMessage, dismissType: FIRInAppMessagingDismissType) {
        // ...
    }
    
    func impressionDetected(for inAppMessage: InAppMessagingDisplayMessage) {
        // ...
    }
    
    func displayError(for inAppMessage: InAppMessagingDisplayMessage, error: Error) {
        // ...
    }

}

extension MyHomeViewController: PendingTestDelegate {
    
    func completePendingTestDelegate(isSparshna: Bool) {
        if isSparshna {
            showSparshna()
        } else {
            showPrashna()
        }
    }
    
    func showSparshna() {
        SparshnaAlert.showSparshnaTestScreen(isBackBtnVisible: true, fromVC: self)
    }
    
    func showPrashna() {
        Vikrati30QuestionnaireVC.showScreen(fromVC: self)
    }
}

extension MyHomeViewController {
    func checkForNewVersion(from data: [String: Any]) {
        let existingVersion = Bundle.main.releaseVersionNumber ?? "1.0"
        
        //Check appstore update
        if let versionName = data["iosVersionName"] as? String, let versionStatus = data["iosVersionStatus"] as? String  {
            if existingVersion.versionCompare(versionName) == .orderedAscending {
                //new update, show alert for update
                print("update available")
                showVersionUpdateAlert(isMandatory: versionStatus)
            }
        }
        
        //Store app current version and update app install or update status
        if let savedAppCurrentVersion = Keychain.appCurrentVersion {
            if savedAppCurrentVersion != existingVersion {
                //app updated
                print("@@@@ app updated")
                Keychain.appCurrentVersion = existingVersion
                //Temo Comment//MoEngageHelper.shared.updateAppStatusUpdate()
            } else {
                //reinstall app or relaunch app
                print("@@@@ reinstall app or relaunch app")
            }
        } else {
            //first time app install
            print("@@@@ first time app install")
            Keychain.appCurrentVersion = existingVersion
            //Temo Comment//MoEngageHelper.shared.updateAppStatusInstall()
        }
    }
    
    func showVersionUpdateAlert(isMandatory: String) {
        let alert = UIAlertController(title: APP_NAME, message: "A new version is available. Please update to continue.".localized(), preferredStyle: .alert)
        
        let updateNow = UIAlertAction(title: "Update".localized(), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Update Now")
            self.openAppInAppStore()
        })
        alert.addAction(updateNow)
        if isMandatory == "1" {
            //Mandatory update, show exit, update now option
            let exit = UIAlertAction(title: "Exit".localized(), style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
                self.exitApp()
            })
            alert.addAction(exit)
        } else {
            //show update, update later option
            let updateLater = UIAlertAction(title: "Update Later".localized(), style: .default, handler: nil)
            alert.addAction(updateLater)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func exitApp() {
        exit(0)
    }
    
    func openAppInAppStore() {
        let urlString = "https://apps.apple.com/us/app/ayurthym/id1401306733?ls=1"
        guard let url = URL(string: urlString) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension MyHomeViewController {
        
    func allDataFetchCompleted() {

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            
            if (kUserDefaults.bool(forKey: is_showcase_1) == false) {
                let showcase1 = MaterialShowcase()
                showcase1.setTargetView(view: self.btn_floating)
                showcase1.primaryText = "Your Ayurvedic wellness companion"
                showcase1.secondaryText = ""
                showcase1.shouldSetTintColor = false // It should be set to false when button uses image.
                showcase1.backgroundPromptColor = AppColor.app_DarkGreenColor
                showcase1.backgroundPromptColorAlpha = 0.75
                showcase1.isTapRecognizerForTargetView = false
                showcase1.delegate = self
                self.sequence.temp(showcase1).start()
            }
        }
        
        
        
        
        
        
        
        
        
        //kUserDefaults.set(false, forKey: kisShowLastAssesmentShowcase)    //just for testing
        
//        if !lastAssessmentValue.isEmpty && (kUserDefaults.bool(forKey: kisShowLastAssesmentShowcase) == false) {
            //kUserDefaults.set(true, forKey: kisShowLastAssesmentShowcase)
//        } else {
//            //SurveyData.shared.contentTypeIDs.removeAll()
//            //kUserDefaults.set(false, forKey: kisShowPreferencesShowcase)    //just for testing
//
//            if let _ = navigationItem.rightBarButtonItems?.first(where: { $0.tag == 100 }) {
//                if kUserDefaults.bool(forKey: kisShowPreferencesShowcase) == false {
//                    if SurveyData.shared.contentTypeIDs.isEmpty && kSharedAppDelegate.isShowPreferencesShowcase == false {
//                        kSharedAppDelegate.isShowPreferencesShowcase = true
//
//                        kUserDefaults.set(true, forKey: kisShowPreferencesShowcase) //don't SurveyShowcase after one time show
//                    } else {
//                        kUserDefaults.set(true, forKey: kisShowPreferencesShowcase)
//                    }
//                }
//            }
//        }
        
        if kSharedAppDelegate.isReminderLocalNotification {
            showAlert(title: "Follow Your Rhythm!".localized(), message: "Let's start your wellness routine and move towards a balanced lifestyle.".localized())
            kSharedAppDelegate.isReminderLocalNotification = false
        }
    }
}

extension MyHomeViewController {
    func handlePushNotificationDeepLink() {
        if let notificationInfo = kSharedAppDelegate.notificationInfo, notificationInfo.tabSelectedIndex == 0 {
            switch notificationInfo.redirectEvent {
            case .Personalisation:
                if let surveyButtonItem = navigationItem.rightBarButtonItems?.first(where: { $0.tag == 100 }) {
                    surveyBtnClicked(surveyButtonItem)
                }
                
            case .Offers:
                print("open Offers page")
                FloatingButton.showOfferScreen(from: self.view)
                
            case .Retest, .Sparshna:
                showSparshna()
                
            case .ResultHistory:
                let vc = ResultHistoryViewController.instantiateFromStoryboard("ResultHistory")
                //present(vc, animated: true, completion: nil)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
                
            case .Yogasana:
                showYogaPlayListScreen(data: [])
                
            case .Pranayama:
                showPranayamaPlayListScreen(data: [])
                
            case .Meditation:
                showMeditationPlayListScreen(data: [])
            
            case .Kriyas:
                showkriyaPlayListScreen(data: [])
                
            case .Mudras:
                showMudraPlayListScreen(data: [])
                
            case .Food:
                showDetailScreen(sectionType: .food, data: [])
                
            case .Herbs:
                showDetailScreen(sectionType: .herbs, data: [])
                
            default:
                break
            }
            kSharedAppDelegate.notificationInfo = nil
        }
    }
}

extension SparshnaAlert {
    static func showSparshnaTestScreen(isBackBtnVisible: Bool = false, fromVC: UIViewController) {
        if ARBPLDeviceManager.shared.isAnyBluetoothEnableOximeterRegistered() {
            ARBPLDeviceInstructionVC.showScreen(deviceType: .oximeter, fromVC: fromVC)
        } else {
            if kUserDefaults.bool(forKey: kDoNotShowTestInfo) {
                let vc = CameraViewController.instantiate(fromAppStoryboard: .Camera)
                vc.hidesBottomBarWhenPushed = true
                fromVC.navigationController?.pushViewController(vc, animated: true)
                /*
                let objAlert = SparshnaAlert.instantiate(fromAppStoryboard: .Alert)
                objAlert.hidesBottomBarWhenPushed = true
                objAlert.modalPresentationStyle = .overCurrentContext
                objAlert.completionHandler = {
                    let vc = CameraViewController.instantiate(fromAppStoryboard: .Camera)
                    vc.hidesBottomBarWhenPushed = true
                    fromVC.navigationController?.pushViewController(vc, animated: true)
                }
                fromVC.present(objAlert, animated: true)
                */
            } else {
                let vc = SparshnaTestInfoViewController.instantiate(fromAppStoryboard: .SparshnaTestInfo)
                vc.isBackBtnVisible = isBackBtnVisible
                vc.hidesBottomBarWhenPushed = true
                fromVC.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension MyHomeViewController {
    func fetchAndUpdatePedometerBannerData() {
        ARPedometerManager.shared.fetchPedometerDataFromHealthKit()
    }
}

extension MyHomeViewController {
    func addNotifcationObservers() {
        NotificationCenter.default.addObserver(forName: .refreshPedometerData, object: nil, queue: nil) { [weak self] notif in
            if let stringSelf = self, (stringSelf.isViewLoaded && (stringSelf.view.window != nil)) {
                // viewController is visible
                stringSelf.tblViewHome.reloadData()
                /*let row = RecommendationCellType.pedometer.sortOrder
                if self?.dataArray.indices.contains(row) ?? false {
                    self?.tblViewHome.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                }*/
            }
        }
    }
    
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Setup Text
extension MyHomeViewController {
    
    func setupAttributeText(Text_label: UILabel, full_Text: String, aggrivation_type: String, kpv: String) {
        //let fullText = "\(full_Text) \(kpv)"
        let fullText = String(format: full_Text, aggrivation_type, kpv)
        let newText = NSMutableAttributedString.init(string: fullText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.26 // Whatever line spacing you want in points
        paragraphStyle.alignment = .left

        newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontSemiBold(16), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#777777"), range: NSRange.init(location: 0, length: newText.length))

        let textRange = NSString(string: fullText)
        let highlight_range = textRange.range(of: aggrivation_type)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontSemiBold(16), range: highlight_range)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#2F2E2E"), range: highlight_range)
        
        let highlight_rangeKPV = textRange.range(of: kpv)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontSemiBold(16), range: highlight_rangeKPV)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fromHex(hexString: "#2F2E2E"), range: highlight_rangeKPV)
        
        Text_label.attributedText = newText
    }
    
    func populateHeader(img_aggrivation: UIImageView, imgKPV: UIImageView, view_aggrivation: UIView, lbl_Text: UILabel, img_arrow: UIImageView) {

        imgKPV.isHidden = true
        img_arrow.isHidden = false
        
//        let currentKPVStatus = Utils.getYourCurrentKPVState(isHandleBalanced: false)
        var currentKPVStatus = ""
        
        if let dic_userInfo = UserDefaults.user.get_user_info_result_data["Userinfo"] as? [String: Any] {
            currentKPVStatus = dic_userInfo["aggravation"] as? String ?? ""
        }
        
        if currentKPVStatus.lowercased() == CurrentKPVStatus.Kapha.rawValue.lowercased() {
            img_aggrivation.image = UIImage(named: "Kaphaa")
            
            let kapha_colors = [#colorLiteral(red: 0.4235294118, green: 0.7529411765, blue: 0.4078431373, alpha: 1), #colorLiteral(red: 0.7411764706, green: 0.8392156863, blue: 0.1882352941, alpha: 1), #colorLiteral(red: 1, green: 0.862745098, blue: 0.1882352941, alpha: 1)]  //6CC068, //BDD630, //FFDC30
            if let kapha_gradientColor = CAGradientLayer.init(frame: view_aggrivation.frame, colors: kapha_colors, direction: GradientDirection.Top).creatGradientImage() {
                view_aggrivation.layer.borderColor = UIColor.init(patternImage: kapha_gradientColor).cgColor
            }
        }
        else if currentKPVStatus.lowercased() == CurrentKPVStatus.Pitta.rawValue.lowercased() {
            img_aggrivation.image = UIImage(named: "PittaN")
            
            let pitta_colors = [#colorLiteral(red: 0.9882352941, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.7960784314, blue: 0.1647058824, alpha: 1)]  //FC0000, //FFCB2A
            if let pitta_gradientColor = CAGradientLayer.init(frame: view_aggrivation.frame, colors: pitta_colors, direction: GradientDirection.Top).creatGradientImage() {
                view_aggrivation.layer.borderColor = UIColor.init(patternImage: pitta_gradientColor).cgColor
            }
        }
        else if currentKPVStatus.lowercased() == CurrentKPVStatus.Vata.rawValue.lowercased() {
            img_aggrivation.image = UIImage(named: "VataN")
            
            let vata_colors = [#colorLiteral(red: 0.2352941176, green: 0.568627451, blue: 0.9019607843, alpha: 1), #colorLiteral(red: 0.737254902, green: 0.4078431373, blue: 0.7529411765, alpha: 1), #colorLiteral(red: 0.2352941176, green: 0.568627451, blue: 0.9019607843, alpha: 1)]  //3C91E6, //BC68C0, //3C91E6
            if let vata_gradientColor = CAGradientLayer.init(frame: view_aggrivation.frame, colors: vata_colors, direction: GradientDirection.Right).creatGradientImage() {
                view_aggrivation.layer.borderColor = UIColor.init(patternImage: vata_gradientColor).cgColor
            }
        }
        else if currentKPVStatus.lowercased() == CurrentKPVStatus.Kapha_Pitta.rawValue.lowercased() {
            imgKPV.image = UIImage(named: "icon_kapha_pitta_kp")
            img_aggrivation.image = UIImage(named: "")
        }
        else if currentKPVStatus.lowercased() == CurrentKPVStatus.Pitta_Vata.rawValue.lowercased() {
            imgKPV.image = UIImage(named: "icon_pitta_vata_pv")
            img_aggrivation.image = UIImage(named: "")
        }
        else if currentKPVStatus.lowercased() == CurrentKPVStatus.Vata_Kapha.rawValue.lowercased() {
            imgKPV.image = UIImage(named: "icon_vata_kapha_vk")
            img_aggrivation.image = UIImage(named: "")
        }
        else if currentKPVStatus.lowercased() == CurrentKPVStatus.Kapha_Pitta_Vata.rawValue.lowercased() {
            imgKPV.image = UIImage(named: "icon_kapah_pitta_vata_kpv")
            img_aggrivation.image = UIImage(named: "")
        }
        else {
            imgKPV.isHidden = false
            img_arrow.isHidden = true
            img_aggrivation.image = UIImage(named: "")
            imgKPV.image = UIImage(named: "icon_balance")
            lbl_Text.text = "You have reached the balance".localized()
            view_aggrivation.layer.borderColor = UIColor.clear.cgColor
        }
    }
}


//MARK: - Login for KPV (Increase Decrease)
extension MyHomeViewController {

    func checkAggravatedValue() {
        
        func setStatus(prakriti: Double, vikriti: Double, kpvType: KPVType) {
            if abs(vikriti - prakriti) <= 5 {
                //if value is less than or equal to 5 then normal
                //Normal Aggravated
            } else if vikriti > prakriti {
                //If vikriti value is higher than prakriti= aggrevated
                //Increased Aggravated
                arrIncreaseValue.append(kpvType)
            } else {
                //imbalance
                //Decreased Aggravated
            }
        }
        
        var kaphaP = 0.0
        var pittaP = 0.0
        var vataP = 0.0
        
        if let strPrashna = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaP = Double(arrPrashnaScore[0]) ?? 0
                pittaP = Double(arrPrashnaScore[1]) ?? 0
                vataP = Double(arrPrashnaScore[2]) ?? 0
            }
        } else {
            return
        }
        
        if let strPrashna = kUserDefaults.value(forKey: RESULT_VIKRITI) as? String {
            let arrPrashnaScore = strPrashna.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                let kapha = Double(arrPrashnaScore[0]) ?? 0
                let pitta = Double(arrPrashnaScore[1]) ?? 0
                let vata = Double(arrPrashnaScore[2]) ?? 0
                // new - original / original *100
                let percentIncreaseK = (kapha - kaphaP) //*100/kaphaP
                let percentIncreaseP = (pitta - pittaP) //*100/pittaP
                let percentIncreaseV = (vata - vataP) //*100/vataP
                
                self.KpvPer1 = "\(Int(abs(round(percentIncreaseK))))%"
                self.KpvPer2 = "\(Int(abs(round(percentIncreaseP))))%"
                self.KpvPer3 = "\(Int(abs(round(percentIncreaseV))))%"
                
                setStatus(prakriti: kaphaP, vikriti: kapha, kpvType: .KAPHA)
                setStatus(prakriti: pittaP, vikriti: pitta, kpvType: .PITTA)
                setStatus(prakriti: vataP, vikriti: vata, kpvType: .VATA)
            }
        }
    }
    
    func getDisplayMessage_LastAssessment() -> (String, String, String) {
        if self.arrIncreaseValue.contains(.VATA) {
            return ("Your %@ is aggravated\nby %@".localized(), self.KpvPer3, "Vata".localized())
        } else if self.arrIncreaseValue.contains(.PITTA) {
            return ("Your %@ is aggravated\nby %@".localized(), self.KpvPer2, "Pitta".localized())
        } else if self.arrIncreaseValue.contains(.KAPHA) {
            return ("Your %@ is aggravated\nby %@".localized(), self.KpvPer1, "Kapha".localized())
        } else {
            return ("You have reached the balance".localized(), "", "")
        }
    }
    
    //MARK: - Setup Text
    func setup_KPV_colors(img_aggrivation: UIImageView, imgKPV: UIImageView, view_aggrivation: UIView, lbl_Text: UILabel, img_arrow: UIImageView) {
        
        imgKPV.isHidden = true
        img_arrow.isHidden = true
                
        if let dic_userInfo = UserDefaults.user.get_user_info_result_data["Userinfo"] as? [String: Any] {
            
            let str_aggravation = dic_userInfo["aggravation"] as? String ?? ""
            
            debugPrint(str_aggravation)
            
            if str_aggravation.lowercased() == CurrentKPVStatus.Kapha.stringValue.lowercased() {
                img_aggrivation.image = UIImage(named: "Kaphaa")
                
                if let kapha_gradientColor = CAGradientLayer.init(frame: view_aggrivation.frame, colors: kapha_colors, direction: GradientDirection.Top).creatGradientImage() {
                    view_aggrivation.layer.borderColor = UIColor.init(patternImage: kapha_gradientColor).cgColor
                }
            }
            else if str_aggravation.lowercased() == CurrentKPVStatus.Pitta.stringValue.lowercased() {
                img_aggrivation.image = UIImage(named: "PittaN")
                
                if let pitta_gradientColor = CAGradientLayer.init(frame: view_aggrivation.frame, colors: pitta_colors, direction: GradientDirection.Top).creatGradientImage() {
                    view_aggrivation.layer.borderColor = UIColor.init(patternImage: pitta_gradientColor).cgColor
                }
            }
            else if str_aggravation.lowercased() == CurrentKPVStatus.Vata.stringValue.lowercased() {
                img_aggrivation.image = UIImage(named: "VataN")
                
                if let vata_gradientColor = CAGradientLayer.init(frame: view_aggrivation.frame, colors: vata_colors, direction: GradientDirection.Right).creatGradientImage() {
                    view_aggrivation.layer.borderColor = UIColor.init(patternImage: vata_gradientColor).cgColor
                }
            }
            else if str_aggravation.lowercased() == CurrentKPVStatus.Kapha_Pitta.stringValue.lowercased() {
                imgKPV.isHidden = false
                imgKPV.image = UIImage(named: "icon_kapha_pitta_kp")
                img_aggrivation.image = UIImage(named: "")
                view_aggrivation.layer.borderColor = UIColor.clear.cgColor
            }
            else if str_aggravation.lowercased() == CurrentKPVStatus.Pitta_Vata.stringValue.lowercased() {
                imgKPV.isHidden = false
                imgKPV.image = UIImage(named: "icon_pitta_vata_pv")
                img_aggrivation.image = UIImage(named: "")
                view_aggrivation.layer.borderColor = UIColor.clear.cgColor
            }
            else if str_aggravation.lowercased() == CurrentKPVStatus.Vata_Kapha.stringValue.lowercased() {
                imgKPV.isHidden = false
                imgKPV.image = UIImage(named: "icon_vata_kapha_vk")
                img_aggrivation.image = UIImage(named: "")
                view_aggrivation.layer.borderColor = UIColor.clear.cgColor
            }
            else if str_aggravation.lowercased() == CurrentKPVStatus.Kapha_Pitta_Vata.stringValue.lowercased() {
                imgKPV.isHidden = false
                imgKPV.image = UIImage(named: "icon_kapah_pitta_vata_kpv")
                img_aggrivation.image = UIImage(named: "")
                view_aggrivation.layer.borderColor = UIColor.clear.cgColor
            }
            else {
                imgKPV.isHidden = false
                img_arrow.isHidden = true
                img_aggrivation.image = UIImage(named: "")
                imgKPV.image = UIImage(named: "icon_balance")
                lbl_Text.text = "You have reached the balance".localized()
                view_aggrivation.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
}


extension MyHomeViewController: MaterialShowcaseDelegate {
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        sequence.showCaseWillDismis()
        sequence_floating.showCaseWillDismis()
        if showcase.tag == 420 {
            kUserDefaults.set(true, forKey: is_showcase_3)
        }
        else if showcase.tag == 421 {
            kUserDefaults.set(true, forKey: is_showcase_4)
        }
        else {
            kUserDefaults.set(true, forKey: is_showcase_1)
        }
        
        if (kUserDefaults.bool(forKey: is_showcase_2) == false) {
        
        if self.arr_TodayGoalData.count != 0 {
            if let indx = self.arr_section.firstIndex(where: { dic_type in
                return dic_type.sortOrder == 11
            }) {
                self.tblViewHome.scrollToRow(at: IndexPath.init(row: indx, section: 0), at: .bottom, animated: true)
                if let currentCell = self.tblViewHome.cellForRow(at: IndexPath.init(row: indx, section: 0)) as? HomeScreenTodayGoalTableCell {
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                        
                        let showcase = MaterialShowcase()
                        showcase.setTargetView(view: currentCell.btn_edit)
                        showcase.primaryText = "\n     Click here to set your\n     preferences"
                        showcase.secondaryText = ""
                        showcase.shouldSetTintColor = false
                        showcase.backgroundPromptColor = AppColor.app_DarkGreenColor
                        showcase.backgroundPromptColorAlpha = 0.75
                        showcase.backgroundRadius = 300
                        showcase.isTapRecognizerForTargetView = false
                        showcase.show(completion: {
                            print("==== completion Action 1.1 ====")
                            // You can save showcase state here
                            kUserDefaults.set(true, forKey: is_showcase_2)
                        })
                    }
                }
            }
        }
        }
    }
}


extension MyHomeViewController {
    
    func callAPIforCheckFacenaadiCouponValid(completion: @escaping (Bool, String?)->Void ) {
        self.showActivityIndicator()
        let params = ["coupon_code": appDelegate.facenaadi_doctor_coupon_code] as [String : Any]
        doAPICall(endPoint: .checkFaceNaadiSubscriptionPromocode, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            var str_validity_msg = ""
            if isSuccess {
                if let dic_res = responseJSON?["response"].dictionary {
                    str_validity_msg = dic_res["validity_message"]?.stringValue ?? ""
                }
                self?.hideActivityIndicator()
                completion(isSuccess, str_validity_msg)
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
                completion(isSuccess, "")
            }
        }
    }
}
