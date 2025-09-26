//
//  SurveyMainViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 17/09/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire

protocol DataValidateable {
    func validateData() -> (Bool, String)
}

class SurveyMainViewController: BaseViewController, delegate_nextPressed, didTappedDelegate {
    
    var superVC = UIViewController()
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var btn_Skip: UIButton!
    @IBOutlet var progressBtns: [UIButton]!
    
    var pageViewController: UIPageViewController!
    var stepVCs = [UIViewController]()
    var currentSurveyStepIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.btn_Skip.setTitle("SKIP".localized().capitalized, for: .normal)
        setupServeySteps()
        setupPageViewController()
    }
    
    func setupServeySteps() {
        //stepVCs.append(SurveyStep1ViewController.instantiateFromStoryboard("Survey"))
        let vc1 = SurveyStep2ViewController.instantiateFromStoryboard("Survey")
        vc1.delegate = self
        
        let vc2 = SurveyStep3ViewController.instantiateFromStoryboard("Survey")
        vc2.delegate = self
        vc2.super_view = self
        
        let vc3 = SurveyStep5ViewController.instantiateFromStoryboard("Survey")
        vc3.delegate = self
        
        stepVCs.append(vc1)
        stepVCs.append(vc2)
        //stepVCs.append(SurveyStep4ViewController.instantiateFromStoryboard("Survey"))
        stepVCs.append(vc3)
    }
    
    func setupPageViewController() {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.delegate = self
        pageController.dataSource = self
        
        pageController.setViewControllers([stepVCs[0]], direction: .forward, animated: false, completion: nil)
        
        addChild(pageController)
        containerView.addSubview(pageController.view)
        pageController.view.fillToSuperview()
        pageController.didMove(toParent: self)
        
        pageViewController = pageController
        
        
        for view in self.pageViewController!.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
        
    }
    
    func selectSurveyStep(at index: Int) {
        if stepVCs.indices.contains(index) {
            if let currentVC = pageViewController.viewControllers?.first, let currentIndex = stepVCs.firstIndex(of: currentVC) {
                pageViewController.setViewControllers([stepVCs[index]], direction: index > currentIndex ? .forward : .reverse, animated: true, completion: nil)
                currentSurveyStepIndex = index
            }
        }
    }
    
    func nextPress() {
        if currentSurveyStepIndex == (stepVCs.count - 1) {
            //lets done it
            showActivityIndicator()
            saveSurveyDataToServer(params: SurveyData.shared.apiParams()) { (isSuccess, status, message) in
                self.hideActivityIndicator()
                if isSuccess {
                    print("message : ", message)
                    SurveyData.shared.saveData()
                    self.scheduleLocalNotification()
                    TodayRecommendations.shared.clearData()

                    let objDialouge = WellnessJourneyDialouge(nibName:"WellnessJourneyDialouge", bundle:nil)
                    objDialouge.delegate = self
                    self.addChild(objDialouge)
                    objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
                    self.view.addSubview((objDialouge.view)!)
                    objDialouge.didMove(toParent: self)
    
                    
                    
                    
                    
//                    Utils.showAlertWithTitleInControllerWithCompletion("Enjoy your wellness journey!".localized(), message: "Thank you for helping us tailor the app for you!\nEnjoy your journey to a balanced lifestyle :)".localized(), okTitle: "Ok".localized(), controller: self) { [weak self] in
//                        self?.dismiss(animated: true, completion: nil)
//                    }
                } else {
                    self.showAlert(title: status, message: message)
                }
            }
        } else {
            validateAndProccedToNext(index: currentSurveyStepIndex)
        }
    }
    
    func clear_ExitPressed() {
        Utils.showAlertWithTitleInControllerWithCompletion("", message: "Are you sure, you want to clear your customisation?\n\nYou can always come back and set your preferences at any time!".localized(), cancelTitle: "Cancel".localized(), okTitle: "Ok".localized(), controller: self, completionHandler: { [weak self] in
            self?.showActivityIndicator()
            self?.clearSurveyDataToServer() { (isSuccess, status, message) in
                if isSuccess {
                    print("message : ", message)
                    TodayRecommendations.shared.clearData()
                    SurveyData.shared.clearData()
                    SurveyMainViewController.clearScheduledLocalNotification()
                    self?.hideActivityIndicator()
                    self?.dismiss(animated: true, completion: nil)
                } else {
                    self?.hideActivityIndicator()
                    self?.showAlert(title: status, message: message)
                }
            }
        }) {
            
        }
    }
    
    @IBAction func nextBtnPressed(sender: UIButton) {
        self.nextPress()
    }
    
    func validateAndProccedToNext(index: Int) {
        if let vc = stepVCs[index] as? DataValidateable {
            let validationData = vc.validateData()
            if validationData.0 == true {
                selectSurveyStep(at: index + 1)
            } else {
                showAlert(message: validationData.1)
            }
        }
    }
    
    @IBAction func surveyStepBtnPressed(sender: UIButton) {
        let index = sender.tag
        if index <= currentSurveyStepIndex {
            selectSurveyStep(at: index)
        }
    }
    
    @IBAction func cancelBtnPressed(sender: UIBarButtonItem) {
        Utils.showAlertWithTitleInControllerWithCompletion("", message: "Cancel the customisation?\n\nYou can always come back and set your preferences at any time!".localized(), okTitle: "Ok".localized(), controller: self) { [weak self] in
            SurveyData.shared.resetData()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func clearAndExitBtnPressed(sender: UIBarButtonItem) {
        self.clear_ExitPressed()
    }
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        if self.currentSurveyStepIndex != 0 {
            self.selectSurveyStep(at: self.currentSurveyStepIndex - 1)
        }
        else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func btn_Skip_Action(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func nextpressed(_ success: Bool) {
        self.nextPress()
    }
    
    func clear_exitpressed(_ success: Bool) {
        self.clear_ExitPressed()
    }
    
    func didTappedClose(_ success: Bool, product_id: String) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: -
extension SurveyMainViewController: UIPageViewControllerDataSource {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return stepVCs.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = stepVCs.firstIndex(of: viewController) ?? 0
        if currentIndex <= 0 {
            return nil
        }
        return stepVCs[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = stepVCs.firstIndex(of: viewController) ?? 0
        if currentIndex >= stepVCs.count - 1 {
            return nil
        }
        return stepVCs[currentIndex + 1]
    }
}

extension SurveyMainViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentVC = pageViewController.viewControllers?.first, let index = stepVCs.firstIndex(of: currentVC) {
                print("selected index : ", index)
                currentSurveyStepIndex = index
//                updateNextBtnTitle()
                //segmentedControl.setIndex(index: index)
            }
        }
    }
}

extension SurveyMainViewController {
    func saveSurveyDataToServer(params: [String: Any], completion: @escaping (Bool, String, String)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.saveTodaysGoals.rawValue

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        completion(false, "", "")
                        return
                    }
                    appDelegate.apiCallingAsperDataChage = true
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["Message"] as? String ?? ""
                    let isSuccess = (status.lowercased() == "Success".lowercased())
                    completion(isSuccess, status, message)
                case .failure(let error):
                    print(error)
                    completion(false, "", error.localizedDescription)
                }
            }
        } else {
            completion(false, "", NO_NETWORK)
        }
    }
    
    func clearSurveyDataToServer(completion: @escaping (Bool, String, String)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.resetUserGoals.rawValue

            AF.request(urlString, method: .post, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        completion(false, "", "")
                        return
                    }
                    appDelegate.apiCallingAsperDataChage = true
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["Message"] as? String ?? ""
                    let isSuccess = (status.lowercased() == "Success".lowercased())
                    completion(isSuccess, status, message)
                case .failure(let error):
                    print(error)
                    completion(false, "", error.localizedDescription)
                }
            }
        } else {
            completion(false, "", NO_NETWORK)
        }
    }
}

let localNotificationIdentifier = APP_NAME + "-101"
extension SurveyMainViewController {
    func scheduleLocalNotification() {
        
        UNUserNotificationCenter.current().getNotificationSettings(){ (settings) in
            
            DispatchQueue.main.async {
                switch settings.alertSetting{
                case .enabled:
                    //Permissions are granted
                    self.addLocalNotification()
                    
                case .disabled:
                    //Permissions are not granted
                    print("notification permissions are not granted")
                    self.showAlert(message: "Notification permission is not granted, please enable it from settings".localized())
                    
                case .notSupported:
                    //The application does not support this notification type
                    print("The application does not support this notification type")
                @unknown default:
                    print("The application does not support this notification type")
                }
            }
        }
    }
    
    static func clearScheduledLocalNotification() {
        
        UNUserNotificationCenter.current().getNotificationSettings(){ (settings) in
            
            DispatchQueue.main.async {
                switch settings.alertSetting{
                case .enabled:
                    //Permissions are granted
                    clearLocalNotification()
                    
                case .disabled:
                    //Permissions are not granted
                    print("notification permissions are not granted")
                    UIApplication.topViewController()?.showAlert(message: "Notification permission is not granted, please enable it from settings".localized())
                    
                case .notSupported:
                    //The application does not support this notification type
                    print("The application does not support this notification type")
                @unknown default:
                    print("The application does not support this notification type")
                }
            }
        }
    }
    
    static func clearLocalNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [localNotificationIdentifier])
    }
    
    func addLocalNotification() {
        let reminderTimeStr = SurveyData.shared.reminderTime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" //"yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        
        let notificationCenter = UNUserNotificationCenter.current()
        guard !reminderTimeStr.isEmpty, let reminderTime = dateFormatter.date(from: reminderTimeStr) else {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [localNotificationIdentifier])
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Your wellness reminder".localized()
        content.body = "Head to AyuRythm and check out your recommendations for the day!".localized()
        content.sound = UNNotificationSound.default
        content.userInfo = ["isReminderLocalNotification" : true]
        content.badge = 1
        
        //let date = Date().adding(.minute, value: 1)
        let triggerDate = Calendar.current.dateComponents([.hour,.minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        let request = UNNotificationRequest(identifier: localNotificationIdentifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
            print("### Local Notif : \(content.title) - \(content.body) - \(reminderTime)")
        }
    }
}
