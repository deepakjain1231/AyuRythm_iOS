//
//  ARWellnessPlanVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 18/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
//import IGVimeoExtractor
import AVKit

class ARWellnessPlanVC: UIViewController {
    
    enum WellnessPlanSection: Int {
        case activities
        case diet
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var view_HeaderButtonBG: UIView!
    @IBOutlet weak var lbl_NoData: UILabel!
    @IBOutlet weak var lbl_nav_Header: UILabel!
    @IBOutlet weak var view_ayumonk_BG: UIControl!
    @IBOutlet weak var lbl_ayumonk_Title: UILabel!
    @IBOutlet weak var lbl_ayumonk_subTitle: UILabel!
    
    @IBOutlet weak var img_ayumonk_arrow: UIImageView!
    
    @IBOutlet weak var dayL: UILabel!
    @IBOutlet weak var dateL: UILabel!
    @IBOutlet weak var preferenceBtn: UIBarButtonItem!
    @IBOutlet weak var btn_preferences: UIButton!
    @IBOutlet weak var btn_Activities: UIControl!
    @IBOutlet weak var btn_DietPlan: UIControl!
    
    @IBOutlet weak var lbl_Activities: UILabel!
    @IBOutlet weak var lbl_DietPlan: UILabel!
    
    var activePlanSection = WellnessPlanSection.diet
    var currentSeletedDay: ARWellnessDay?
    var wellnessPlan: ARWellnessPlanModel?
    var days = [ARWellnessDay]()
    var activities = [ARWellnessPlanActivityModel]()
    var dietSections = [ARDietSubSectionModel]()
    
    var autoPlayVideoItems = [ARPlayerItem]()
    
    var isWellnessPlanLocked: Bool {
        guard let currentSeletedDay = currentSeletedDay else {
            return false
        }
        
        return currentSeletedDay.isToday ? false : currentSeletedDay.isLocked
    }
    
    var isWellnessPlanLockedForPauseSubscription: Bool {
        guard let currentSeletedDay = currentSeletedDay else {
            return false
        }
        
        return isWellnessPlanLocked && currentSeletedDay.isSubscriptionPaused
    }
    
    var todayDateString: String {
        return Date().string(withFormat: App.dateFormat.yyyyMMdd)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let userFirstName = Utils.getLoginUserUsername().components(separatedBy: " ").first ?? "You".localized()
        self.title = String(format: "Plan for %@".localized(), userFirstName)
        self.lbl_nav_Header.text = String(format: "Plan for %@".localized(), userFirstName)
        setupUI()
        
        let BGColors1 = [UIColor.fromHex(hexString: "#13492D"), UIColor.fromHex(hexString: "#00C65C")]
        if let gradientColor = CAGradientLayer.init(frame: self.view_ayumonk_BG.frame, colors: BGColors1, direction: GradientDirection.Right).creatGradientImage() {
            self.view_ayumonk_BG.backgroundColor = UIColor.init(patternImage: gradientColor)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.user.is_ayumonk_subscribed {
            self.img_ayumonk_arrow.image = UIImage.init(named: "icon_next_arrow_white")
        }
        else {
            self.img_ayumonk_arrow.image = UIImage.init(named: "icon_list_lock_white")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fixAutoHeightTableHeader(of: tableView)
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupUI() {
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
        self.tableView.register(nibWithCellClass: ARWellnessPlanActivityCell.self)
        self.tableView.register(nibWithCellClass: ARWellnessPlanHeaderCell.self)
        self.tableView.register(nibWithCellClass: ARWellnessPlanHeader2Cell.self)
        self.tableView.register(nibWithCellClass: ARWellnessPlanDietItemCell.self)
        self.tableView.register(nibWithCellClass: ARWellnessPlanBuySubscriptionCell.self)
        self.tableView.register(nibWithCellClass: DietPlan_HeaderTableCell.self)
        
        NotificationCenter.default.addObserver(forName: .refreshWellnessPlanData, object: nil, queue: nil) { [weak self] notif in
            guard let self = self else { return }
            
            if let screen = notif.object as? String, screen == "wellness_preference" {
                self.currentSeletedDay = nil
                self.getWellnessPlan(for: self.todayDateString)
            } else if let day = self.currentSeletedDay {
                self.getWellnessPlan(for: day.date)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEndNotif(notif:)), name:
            NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        updateUI()
        self.view_ayumonk_BG.isHidden = true
        self.view_HeaderButtonBG.isHidden = true
        getWellnessPlan(for: todayDateString)
    }
    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Activities_Action(_ sender: UIControl) {
        self.activePlanSection = .activities
        self.lbl_NoData.isHidden = self.activities.count == 0 ? false : true
        self.btn_Activities.backgroundColor = AppColor.app_DarkGreenColor
        self.btn_DietPlan.backgroundColor = UIColor.white
        self.lbl_Activities.textColor = UIColor.white
        self.lbl_DietPlan.textColor = UIColor.black
        self.tableView.reloadData()
    }
    
    @IBAction func btn_DietPlan_Action(_ sender: UIControl) {
        self.activePlanSection = .diet
        self.lbl_NoData.isHidden = true
        self.btn_DietPlan.backgroundColor = AppColor.app_DarkGreenColor
        self.btn_Activities.backgroundColor = UIColor.white
        self.lbl_DietPlan.textColor = UIColor.white
        self.lbl_Activities.textColor = UIColor.black
        self.tableView.reloadData()
    }
    
    @IBAction func btn_ayumonk_action(_ sender: UIControl) {
        let obj = AyuMonkVC.instantiate(fromAppStoryboard: .FaceNaadi)
        obj.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(obj, animated: true)
    }
}

extension ARWellnessPlanVC {
    func updateUI() {
        activities = wellnessPlan?.activity ?? []
        dietSections = wellnessPlan?.allDietSubSection ?? []
        if currentSeletedDay == nil {
            days = wellnessPlan?.dates ?? []
            currentSeletedDay = days.first
        }
        dateL.text = currentSeletedDay?.dateValue?.string(withFormat: "EEEE, dd MMMM") ?? ""
        if currentSeletedDay?.isToday ?? false {
            self.dayL.isHidden = true
            dayL.text = "Today".localized()
        } else {
            //dayL.text = String(format: "Day %d".localized(), currentSeletedDay?.days ?? 1)
            dayL.text = ""
            self.dayL.isHidden = true
            //wellnessPlan?.isLocked = true
        }
        self.view_ayumonk_BG.isHidden = isWellnessPlanLocked
        self.view_HeaderButtonBG.isHidden = isWellnessPlanLocked
        
        if UserDefaults.user.is_ayumonk_subscribed {
            self.img_ayumonk_arrow.image = UIImage.init(named: "icon_next_arrow_white")
        }
        else {
            self.img_ayumonk_arrow.image = UIImage.init(named: "icon_list_lock_white")
        }
        
        collectionView.reloadData()
        tableView.reloadData()
        
        //Set Ayumonk Banner
        self.lbl_ayumonk_Title.text = self.wellnessPlan?.ayumonk_banner?.title ?? ""
        self.lbl_ayumonk_subTitle.text = self.wellnessPlan?.ayumonk_banner?.description ?? ""
    }
    
    func showBuySubscriptionScreen() {
        ChooseSubscriptionPlanVC.showScreen(fromVC: self)
    }
    
    func playActivityVideos(startActivity: ARWellnessPlanActivityModel) {
        var notDoneActivities = activities.filter{ $0.isComplete == false }
        if let matchedIndex = notDoneActivities.firstIndex(where: { $0.id == startActivity.id && $0.activityType == startActivity.activityType }) {
            let removedActivity = notDoneActivities.remove(at: matchedIndex)
            notDoneActivities.insert(removedActivity, at: 0)
        } else {
            //means already watched activity
            notDoneActivities.insert(startActivity, at: 0)
        }
        let dispatchGroup = DispatchGroup()
        
        autoPlayVideoItems.removeAll()
        notDoneActivities.forEach { activity in
            dispatchGroup.enter()
            activity.extractVimeoURL(current_vc: self) { url, playerItem  in
                if let playerItem = playerItem {
                    self.autoPlayVideoItems.append(playerItem)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print(">> videoURLs : ", self.autoPlayVideoItems)
            let player = AVQueuePlayer(items: self.autoPlayVideoItems)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                player.play()
            }
        }
    }
    
    @objc func videoDidEndNotif(notif: Notification) {
        //print(">>>> videoDidEndNotif : ", notif.object)
        if let videoItem = notif.object as? ARPlayerItem {
            print(">>> Finished video of ID : ", videoItem.activityId)
            Utils.completeDailyTask(favorite_id: videoItem.activityId, taskType: videoItem.activityType.dailyTaskType)
            autoPlayVideoItems.remove(object: videoItem)
            
            if autoPlayVideoItems.isEmpty {
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func preferenceBtnDidPressed(_ sender: Any) {
        ARWellnessPreferencesVC.showScreen(fromVC: self)
    }
    
    @IBAction func subscribeNowBtnPressed(sender: UIButton) {
        if sender.isSelected {
            resumePausedSubscription()
        } else {
            showBuySubscriptionScreen()
        }
    }
    
    @IBAction func showDietPrecausionBtnPressed(sender: UIButton) {
        ARDietPrecautionVC.showScreen(precautions: wellnessPlan?.precautions ?? [], fromVC: self)
    }
    
    @IBAction func autoplaySwitchValueDidChange(sender: UISwitch) {
        print(">> auto play status : ", sender.isOn)
        kUserDefaults.isWellnessActivityAutoplayOn = sender.isOn
    }
}

extension ARWellnessPlanVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isWellnessPlanLocked {
            return 1
        } else {
            if activePlanSection == .activities {
                return 1
            } else {
                return dietSections.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isWellnessPlanLocked {
            return 1
        } else {
            if activePlanSection == .activities {
                return activities.count
            } else {
                return dietSections[section].items.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isWellnessPlanLocked {
            let cell = tableView.dequeueReusableCell(withClass: ARWellnessPlanBuySubscriptionCell.self, for: indexPath)
            cell.subscribeNowBtn.isSelected = isWellnessPlanLockedForPauseSubscription
            cell.subscribeNowBtn.addTarget(self, action: #selector(subscribeNowBtnPressed(sender:)), for: .touchUpInside)
            return cell
        } else {
            if activePlanSection == .activities {
                let cell = tableView.dequeueReusableCell(withClass: ARWellnessPlanActivityCell.self, for: indexPath)
                cell.activity = activities[indexPath.row]
                return cell
            } else {
                let item = dietSections[indexPath.section].items[indexPath.row]
                let cell = tableView.dequeueReusableCell(withClass: ARWellnessPlanDietItemCell.self, for: indexPath)
                cell.dietItem = item

                if (dietSections[indexPath.section].items.count) == 1 {
                    cell.view_top.isHidden = true
                    cell.view_bottom.isHidden = true
                    cell.view_Timing.isHidden = false
                    cell.constraint_view_Top.constant = 0
                    cell.lbl_Timing.text = dietSections[indexPath.section].food_eat_time
                }
                else {
                    if indexPath.row == 0 {
                        cell.view_top.isHidden = true
                        cell.view_bottom.isHidden = false
                        cell.view_Timing.isHidden = false
                        cell.constraint_view_Top.constant = 0
                        cell.lbl_Timing.text = dietSections[indexPath.section].food_eat_time
                    }
                    else if indexPath.row == (dietSections[indexPath.section].items.count - 1) {
                        cell.view_top.isHidden = false
                        cell.view_Timing.isHidden = true
                        cell.view_bottom.isHidden = true
                        cell.constraint_view_Top.constant = 0
                    }
                    else {
                        cell.view_top.isHidden = false
                        cell.view_Timing.isHidden = true
                        cell.view_bottom.isHidden = false
                        cell.constraint_view_Top.constant = 0
                    }
                }
                
                
                //self.show_view_Recipe(titlee: item.name, recipe_Text: item.recipes)
                
                
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !isWellnessPlanLocked {
            if activePlanSection == .activities {
                let cell = tableView.dequeueReusableCell(withClass: ARWellnessPlanHeaderCell.self)
                cell.nameL.text = "My List".localized()
                cell.autoplayView.isHidden = false
                cell.autoplaySwitch?.isOn = kUserDefaults.isWellnessActivityAutoplayOn
                cell.autoplaySwitch?.addTarget(self, action: #selector(autoplaySwitchValueDidChange(sender:)), for: .valueChanged)
                cell.layoutIfNeeded()
                return cell
            } else {
                let deitSection = dietSections[section]
                if let sectionStartImage = deitSection.sectionStartImage {
                    let cell = tableView.dequeueReusableCell(withClass: DietPlan_HeaderTableCell.self)
                    cell.lbl_Name.text = deitSection.subsection
                    cell.lbl_infoText.text = deitSection.description_info
                    cell.img_header.af_setImage(withURLString: sectionStartImage)
                    cell.view_DietHeader.isHidden = (section != 0)
                    //cell.stack_view.spacing = (section == 0) ? 0 : 15
                    cell.infoBtn.addTarget(self, action: #selector(showDietPrecausionBtnPressed(sender:)), for: .touchUpInside)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withClass: ARWellnessPlanHeaderCell.self)
                    cell.nameL.text = deitSection.subsection
                    return cell
                }
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isWellnessPlanLocked {
            if activePlanSection == .activities {
                let activity = activities[indexPath.row]
                if kUserDefaults.isWellnessActivityAutoplayOn {
                    playActivityVideos(startActivity: activity)
                } else {
                    showActivityDetailScreen(activity: activity)
                }
            } else {
                let item = dietSections[indexPath.section].items[indexPath.row]
                let str_DayName = dietSections[indexPath.section].day_name ?? ""
                let str_subsection = dietSections[indexPath.section].subsection ?? ""
                print(">> selected diet item : ", item.name)
                self.callAPIforGetAlternativesItem(foodID: item.id, foodName: str_subsection, dayName: str_DayName) { is_success, arr_data in
                    self.show_view_Recipe(substactionName: str_subsection, dayname: str_DayName, dic_item: item, alternative_Data: arr_data)
                }
            }
        }
    }
    
    func show_view_Recipe(substactionName: String, dayname: String, dic_item: ARDietItemModel, alternative_Data: [ARDietItemModel]?) {
        let objDialouge = View_RecipeBottomSheet(nibName:"View_RecipeBottomSheet", bundle:nil)
        objDialouge.dic_DietItem = dic_item
        objDialouge.str_FoodDay = dayname
        objDialouge.str_FoodSubstaction = substactionName
        objDialouge.arr_alternativeData = alternative_Data
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
        
//        objDialouge.view.translatesAutoresizingMaskIntoConstraints = false
//        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
//        gestureRecognizer.cancelsTouchesInView = false
//        objDialouge.view.addGestureRecognizer(gestureRecognizer)
    }
    
//    @objc func handlePanGesture(gesture:UIPanGestureRecognizer) {
//
//            if gesture.state == .began {
//                print("Began")
//            }else if gesture.state == .changed {
//                print("changed")
//                let translation = gesture.translation(in: self.view)
//                
//                gesture.view!.center = CGPoint(x: gesture.view!.center.x,
//                y: gesture.view!.center.y + translation.y)
//                
//                gesture.setTranslation(CGPoint.zero, in: self.view)
//                
//                }else if gesture.state == .ended {
//                print("Ended")
//            }
//        }
    
    func showActivityDetailScreen(activity: ARWellnessPlanActivityModel) {
        let vc = YogaDetailViewController.instantiate(fromAppStoryboard: .ForYou)
        vc.modalPresentationStyle = .fullScreen
        if activity.activityType == .yoga {
            vc.yoga = activity.managedObject as! Yoga
        }
        else if activity.activityType == .pranayama {
            vc.pranayama = activity.managedObject as! Pranayama
        }
        else if activity.activityType == .meditation {
            vc.meditation = activity.managedObject as! Meditation
        }
        else if activity.activityType == .mudra {
            vc.mudra = activity.managedObject as! Mudra
        }
        else if activity.activityType == .kriya {
            vc.kriya = activity.managedObject as! Kriya
        }
        vc.istype = activity.activityType
        self.present(vc, animated: true, completion: nil)
    }
    
    func callAPIforGetAlternativesItem(foodID: String, foodName: String, dayName: String, completion: @escaping (Bool, [ARDietItemModel]?) -> ()) {
        let params = ["language_id" : Utils.getLanguageId(),
                      "food_id": foodID,
                      "food_day": dayName,
                      "food_subsection": foodName] as [String : Any]
        self.showActivityIndicator()
        Utils.doAPICall(endPoint: .getAlternativeFoodNames, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let dic_alternative = AlternaiveFoodModel(fromJson: responseJSON)
                completion(true, dic_alternative.data)
                self?.hideActivityIndicator()
            } else {
                completion(false, nil)
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
}

extension ARWellnessPlanVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let cellWidth = collectionView.widthOfItemCellFor(noOfCellsInRow: days.count)
        let cellWidth: CGFloat = 42
        return CGSize(width: cellWidth, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: WellnessPlanDayCell.self, for: indexPath)
        let day = days[indexPath.row]
        cell.titleL.text = day.days.stringValue
        cell.updateCell(isDaySelected: day.days == currentSeletedDay?.days)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = days[indexPath.row]
        currentSeletedDay = day
        print(">> selected day : ", day.date ?? "")
        if isWellnessPlanLocked {
            preferenceBtn.isEnabled = false
            self.btn_preferences.isEnabled = false
            updateUI()
            if isWellnessPlanLocked {
                self.lbl_NoData.isHidden = true
            }
            else {
                self.lbl_NoData.isHidden = self.activities.count == 0 ? false : true
            }
        } else {
            preferenceBtn.isEnabled = true
            self.btn_preferences.isEnabled = true
            getWellnessPlan(for: day.date)
        }
    }
}

extension ARWellnessPlanVC {
    func getWellnessPlan(for date: String) {
        let params = ["language_id" : Utils.getLanguageId(), "date": date] as [String : Any]
        self.showActivityIndicator()
        Utils.doAPICall(endPoint: .getWellnessDataByUser, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                self?.wellnessPlan = ARWellnessPlanModel(fromJson: responseJSON["data"])
                self?.wellnessPlan?.isSubscription = responseJSON["is_subscription"].boolValue
                self?.wellnessPlan?.subscriptionHistoryId = responseJSON["subscription_history_id"].stringValue
                self?.updateUI()
                if self?.activePlanSection == .activities {
                    if self?.isWellnessPlanLocked == true {
                        self?.lbl_NoData.isHidden = true
                    }
                    else {
                        self?.lbl_NoData.isHidden = self?.activities.count == 0 ? false : true
                    }
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    func resumePausedSubscription() {
        guard let subscriptionHistoryId = wellnessPlan?.subscriptionHistoryId else {
            let message = "No subscription_history_id found to resume subscription".localized()
            ARLog("??? \(message)")
            showAlert(title: "Error".localized(), message: message)
            return
        }
        
        ActiveSubscriptionPlanVC.showResumeSubscriptionAlert(subscriptionHistoryId: subscriptionHistoryId, fromVC: self) { [weak self] isSuccess, title, message in
            if isSuccess, let self = self {
                //to refresh whole day array, and start from today date
                self.currentSeletedDay = nil
                self.getWellnessPlan(for: self.todayDateString)
                /*if let day = self?.currentSeletedDay {
                    self?.getWellnessPlan(for: day.date)
                }*/
            }
        }
    }
}

extension ARWellnessPlanVC {
    static func showScreen(fromVC: UIViewController) {
        if !kUserDefaults.isWellnessPreferenceSet {
            ARWellnessPreferencesVC.showScreen(isFirstTimeShow: !kUserDefaults.isWellnessPreferenceSet, fromVC: fromVC)
        } else {
            let vc = ARWellnessPlanVC.instantiate(fromAppStoryboard: .WellnessPlan)
            vc.hidesBottomBarWhenPushed = true
            fromVC.navigationController?.isNavigationBarHidden = true
            fromVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
