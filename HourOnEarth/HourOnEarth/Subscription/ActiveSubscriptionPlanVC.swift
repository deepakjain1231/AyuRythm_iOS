//
//  ActiveSubscriptionPlanVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 03/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class ActiveSubscriptionPlanVC: UIViewController {
    
    var arr_Section = [[String: Any?]]()
    @IBOutlet weak var lbl_Nav_Title: UILabel!
    @IBOutlet weak var img_Bg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var planTitleL: UILabel!
    @IBOutlet weak var usernameL: UILabel!
    @IBOutlet weak var expireDateL: UILabel!
    @IBOutlet weak var activePlanView: UIView!
    
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var dayL: UILabel!
    @IBOutlet weak var hourL: UILabel!
    
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var renewNowBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    
    var activeSubscription: ARActiveSubscription?
    var activePlan: ARSubscriptionPlanModel?
    var arr_plans = [ARSubscriptionPlanModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Active Plans".localized()
        self.lbl_Nav_Title.text = "Active Plans".localized()
        self.navigationController?.isNavigationBarHidden = true
        if UserDefaults.user.is_main_subscription {
            self.img_Bg.image = UIImage.init(named: "icon_prime_subscription_bg")
        }
        else {
            self.img_Bg.image = UIImage.init(named: "icon_normal_subscription_bg")
        }
        
        //Register Table Cell
        self.tableView.register(nibWithCellClass: Active_Plan_TableCell.self)
        self.tableView.register(nibWithCellClass: TitleHeaderTableCell.self)
        
        setBackButtonTitle()
        setupUI()
        
        NotificationCenter.default.addObserver(forName: .refreshActiveSubscriptionData, object: nil, queue: nil) { [weak self] notif in
            self?.fetchActiveSubscription()
        }
    }
    
    
    func setupUI() {
        let attrText = NSAttributedString(string: "Pause".localized()).underlined
        pauseBtn.setAttributedTitle(attrText, for: .normal)
        tableView.register(nibWithCellClass: MoreSubscriptionPlanCell.self)
        
        //updateUI()
        fetchActiveSubscription()
    }
    
    func updateUI() {
        guard let plan = activeSubscription else {
            print(">>> no activeSubscription found")
            activePlanView.isHidden = true
            return
        }
        
        planTitleL.text = plan.packName
        usernameL.text = Utils.getLoginUserUsername()
        expireDateL.text = plan.planExpiryDateString
        if let planExipresData = plan.getPlanExpiresInData() {
            dayL.text = planExipresData.days.stringValue
            hourL.text = planExipresData.hours.stringValue
            timerView.isHidden = false
        } else {
            timerView.isHidden = true
        }
        
        pauseBtn.isHidden = true
        renewNowBtn.isHidden = true
        infoBtn.isHidden = false
        activePlanView.isUserInteractionEnabled = true
        if !plan.isPlanExpired || timerView.isHidden {
            renewNowBtn.setTitle("Renew Now".localized(), for: .normal)
            renewNowBtn.isSelected = false
            renewNowBtn.isHidden = false
        } else {
            if plan.isPlanPaused {
                renewNowBtn.setTitle("Resume Subscription".localized(), for: .normal)
                renewNowBtn.isSelected = true
                renewNowBtn.isHidden = false
            } else {
                pauseBtn.isHidden = false
            }
        }
        
        if plan.favoriteId == "0" {
            //Free plan from Promocode
            pauseBtn.isHidden = true
            renewNowBtn.isHidden = true
            infoBtn.isHidden = true
            activePlanView.isUserInteractionEnabled = false
        }
        
        activePlanView.isHidden = false
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        updateUI()
    }
    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pauseBtnPressed(sender: UIButton) {
        PauseSubscriptionPopupVC.showScreen(from: self) { [weak self] in
            let vc = PauseSubscriptionVC.instantiate(fromAppStoryboard: .Subscription)
            vc.activeSubscription = self?.activeSubscription
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func planInfoBtnPressed(sender: UIButton) {
        SubscriptionDetailVC.showScreen(plan: activePlan, isReadOnly: true, fromVC: self)
    }
    
    @IBAction func renewBtnPressed(sender: UIButton) {
        self.btn_renewPress(sender)
    }
    
    func btn_renewPress(_ sender: UIButton) {
        if sender.isSelected {
            //resume paused plan
            Self.showResumeSubscriptionAlert(subscriptionHistoryId: activeSubscription?.id ?? "", fromVC: self) { [weak self] isSuccess, title, message in
                if isSuccess {
                    self?.fetchActiveSubscription()
                }
            }
        } else {
            //means renew plan
            //SubscriptionDetailVC.showScreen(plan: activePlan, fromVC: self)
            let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
            vc.selectedPlan = activePlan
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ActiveSubscriptionPlanVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Section.count// plans.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let str_identifier = self.arr_Section[indexPath.row]["identifier"] as? String ?? ""
        
        if str_identifier == "active_plan_Data" {
            let cell = tableView.dequeueReusableCell(withClass: Active_Plan_TableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.btn_pause.isHidden = true
            cell.timerView.isHidden = true
            cell.btn_renew_Now.isHidden = true
            cell.lbl_plan_title.text = "Prime Club".localized()
            cell.constraint_btn_pause_top.constant = 0
            cell.constraint_btn_pause_height.constant = 0
            cell.constraint_btn_renew_Now_top.constant = 0
            cell.constraint_btn_renew_Now_height.constant = 0
            cell.lbl_plan_title.textColor = UIColor.fromHex(hexString: "#D88100")
            cell.view_Base.layer.borderColor = UIColor.fromHex(hexString: "#D88100").cgColor
            
            if let dic_plan = self.arr_Section[indexPath.row]["value"] as? ARActiveSubscription {
                cell.updateUI(dic_active_plan: dic_plan)
            }
            
            //Button Action
            cell.didTappedPauseButton = { (sender) in
                PauseSubscriptionPopupVC.showScreen(from: self) { [weak self] in
                    let vc = PauseSubscriptionVC.instantiate(fromAppStoryboard: .Subscription)
                    vc.activeSubscription = self?.activeSubscription
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            cell.didTappedRenewButton = { (sender) in
                self.btn_renewPress(sender)
            }

            return cell
        }
        else if str_identifier == "header" {
            let cell = tableView.dequeueReusableCell(withClass: TitleHeaderTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.constraint_lbl_Title_top.constant = 12
            cell.constraint_lbl_Title_bottom.constant = 5
            cell.lbl_Title.textColor = .black
            cell.lbl_Title.font = UIFont.AppFontSemiBold(18)
            cell.lbl_Title.text = self.arr_Section[indexPath.row]["title"] as? String ?? ""
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withClass: MoreSubscriptionPlanCell.self, for: indexPath)
        if let dic_plan = self.arr_Section[indexPath.row]["value"] as? ARSubscriptionPlanModel {
            cell.plan = dic_plan
        }
        //cell.plan = plans[indexPath.row]
        cell.updateCellBG(for: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str_identifier = self.arr_Section[indexPath.row]["identifier"] as? String ?? ""
        if str_identifier == "active_plan_Data" {
            SubscriptionDetailVC.showScreen(plan: activePlan, isReadOnly: true, fromVC: self)
        }
        else if str_identifier == "other_plan_Data" {
            if let dic_plan = self.arr_Section[indexPath.row]["value"] as? ARSubscriptionPlanModel {
                SubscriptionDetailVC.showScreen(plan: dic_plan, fromVC: self)
            }
        }
    }
}

extension ActiveSubscriptionPlanVC {
    func fetchActiveSubscription() {
        self.showActivityIndicator()
        let params = ["currency": Locale.current.paramCurrencyCode, "language_id" : Utils.getLanguageId(), "device_type": "ios"] as [String : Any]
        
        Utils.doAPICall(endPoint: .getActiveSubscription, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                self?.activeSubscription = responseJSON?["data"].arrayValue.compactMap{ ARActiveSubscription(fromJson: $0) }
                .first
                let activeSubId = self?.activeSubscription?.favoriteId ?? ""
                var plans = responseJSON?["plans"].arrayValue.compactMap{ ARSubscriptionPlanModel(fromJson: $0) } ?? []
                if let removeIndex = plans.firstIndex(where: { $0.id == activeSubId}) {
                    self?.activePlan = plans.remove(at: removeIndex)
                }
                self?.arr_plans = plans
                self?.updateUI()
                self?.manageSection()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
            }
        }
    }
    
    /*func callResumeSubscriptionApi() {
        self.showActivityIndicator()
        let params = ["subscription_history_id": activeSubscription?.id ?? ""] as [String: Any]
        Utils.doAPICall(endPoint: .resumeScription, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                self?.fetchActiveSubscription()
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
            }
        }
    }*/
    
    static func showResumeSubscriptionAlert(subscriptionHistoryId: String, fromVC: UIViewController, completion: @escaping (_ isSuccess: Bool, _ title: String, _ message: String)->Void) {
        let alert = UIAlertController(title: "Resume Subscription".localized(), message: "Are you sure you want resume your subscription?".localized(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default, handler: { _ in
            fromVC.showActivityIndicator()
            Self.callResumeSubscriptionApi(subscriptionHistoryId: subscriptionHistoryId) { isSuccess, status, message in
                fromVC.hideActivityIndicator()
                if isSuccess {
                    completion(isSuccess, status, message)
                } else {
                    fromVC.showAlert(title: status, message: message)
                }
            }
        }))
        fromVC.present(alert, animated: true, completion: nil)
    }
    
    static func callResumeSubscriptionApi(subscriptionHistoryId: String, completion: @escaping (_ isSuccess: Bool, _ status: String, _ message: String)->Void) {
        let params = ["subscription_history_id": subscriptionHistoryId] as [String: Any]

        Utils.doAPICall(endPoint: .resumeScription, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            completion(isSuccess, status, message)
        }
    }
}


//MARK: - UITableView Delegate DataSource Method
extension ActiveSubscriptionPlanVC {
    
    func manageSection() {
        self.arr_Section.removeAll()
        
        self.arr_Section.append(["identifier" : "header", "title": "Active Subscriptions".localized()])
        self.arr_Section.append(["identifier" : "active_plan_Data", "title": "Subscriptions", "value": self.activeSubscription])
        
        
        if self.arr_plans.count != 0 {
            self.arr_Section.append(["identifier" : "header", "title": "More Plans".localized()])
            
            for dic_plan in self.arr_plans {
                self.arr_Section.append(["identifier" : "other_plan_Data", "title": "Subscriptions", "value": dic_plan])
            }
        }
        
        self.tableView.reloadData()
    }
}
