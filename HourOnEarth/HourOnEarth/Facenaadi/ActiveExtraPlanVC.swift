//
//  ActiveExtraPlanVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 28/12/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class ActiveExtraPlanVC: UIViewController {

    var arr_Section = [[String: Any?]]()
    @IBOutlet weak var lbl_Nav_Title: UILabel!
    @IBOutlet weak var img_Bg: UIImageView!
    @IBOutlet weak var tbl_View: UITableView!

    //var activeSubscription: ARActiveSubscription?
    //var activePlan: ARSubscriptionPlanModel?
    var arr_plans = [ARSubscriptionPlanModel]()
    var arr_active_plans = [ARActiveSubscription]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_Nav_Title.text = "Active Plans".localized()
        self.navigationController?.isNavigationBarHidden = true
        self.img_Bg.image = UIImage.init(named: "icon_normal_subscription_bg")
        
        
        //Register Table Cell
        self.tbl_View.register(nibWithCellClass: ActiveExtraPlansTableCell.self)
        self.tbl_View.register(nibWithCellClass: MoreSubscriptionPlanTableCell.self)
        self.tbl_View.register(nibWithCellClass: TitleHeaderTableCell.self)
        self.tbl_View.register(nibWithCellClass: NoActivePlanTableCell.self)
        
        self.fetchActiveSubscription()
        
        NotificationCenter.default.addObserver(forName: .refreshActiveSubscriptionData, object: nil, queue: nil) { [weak self] notif in
            self?.fetchActiveSubscription()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
        
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension ActiveExtraPlanVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Section.count
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
            let cell = tableView.dequeueReusableCell(withClass: ActiveExtraPlansTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            if let dic_plan = self.arr_Section[indexPath.row]["value"] as? ARActiveSubscription {
                cell.updateUI(dic_active_plan: dic_plan)
            }
            
            return cell
        }
        else if str_identifier == "no_active_plan" {
            let cell = tableView.dequeueReusableCell(withClass: NoActivePlanTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
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
        
        let cell = tableView.dequeueReusableCell(withClass: MoreSubscriptionPlanTableCell.self, for: indexPath)
        cell.selectionStyle = .none

        if let dic_plan = self.arr_Section[indexPath.row]["value"] as? ARSubscriptionPlanModel {
            cell.updateUI(dic_plan_data: dic_plan)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str_identifier = self.arr_Section[indexPath.row]["identifier"] as? String ?? ""
        if str_identifier == "other_plan_Data" {
            var plan_typee = ScreenType.k_none
            if let dic_plan = self.arr_Section[indexPath.row]["value"] as? ARSubscriptionPlanModel {
                let str_subscription_name = dic_plan.subscription_name.lowercased()
                
                if str_subscription_name == kSubscription_Name_Type.prime.rawValue {
                    plan_typee = .from_PrimeMember
                }
                else if str_subscription_name == kSubscription_Name_Type.facenaadi.rawValue {
                    plan_typee = .fromFaceNaadi
                }
                else if str_subscription_name == kSubscription_Name_Type.sparshna.rawValue {
                    plan_typee = .from_finger_assessment
                }
                else if str_subscription_name == kSubscription_Name_Type.ayuMonk.rawValue {
                    plan_typee = .from_AyuMonk_Only
                }
                else if str_subscription_name == kSubscription_Name_Type.remedies.rawValue {
                    plan_typee = .from_home_remedies
                }
                if str_subscription_name == kSubscription_Name_Type.prime.rawValue {
                    let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.isNavigationBarHidden = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    let obj = FaceNaadiSubscriptionListVC.instantiate(fromAppStoryboard: .FaceNaadi)
                    obj.str_screenFrom = plan_typee
                    self.navigationController?.pushViewController(obj, animated: true)
                }
            }
        }
    }
}

extension ActiveExtraPlanVC {
    
    func fetchActiveSubscription() {
        self.showActivityIndicator()
        let params = ["currency": Locale.current.paramCurrencyCode, "language_id" : Utils.getLanguageId(), "device_type": "ios"] as [String : Any]
        
        Utils.doAPICall(endPoint: .getAllAvailableNActivePlans, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                self?.arr_active_plans = responseJSON?["active_plans"].arrayValue.compactMap{ ARActiveSubscription(fromJson: $0) } ?? []
                self?.arr_plans = responseJSON?["available_plans"].arrayValue.compactMap{ ARSubscriptionPlanModel(fromJson: $0) } ?? []
                self?.manageSection()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
            }
        }
    }
}

//MARK: - UITableView Delegate DataSource Method
extension ActiveExtraPlanVC {
    
    func manageSection() {
        self.arr_Section.removeAll()
        
        self.arr_Section.append(["identifier" : "header", "title": "Active Subscriptions".localized()])
        
        if self.arr_active_plans.count == 0 {
            self.arr_Section.append(["identifier" : "no_active_plan", "title": ""])
        }
        else {

            for dic_active_plan in self.arr_active_plans {
                self.arr_Section.append(["identifier" : "active_plan_Data", "title": "Subscriptions", "value": dic_active_plan])
            }
        }
        
        
        if self.arr_plans.count != 0 {
            self.arr_Section.append(["identifier" : "header", "title": "Available Subscriptions".localized()])
            
            for dic_plan in self.arr_plans {
                if let is_avaialble = self.arr_active_plans.firstIndex(where: { active_plan in
                    return active_plan.subscription_name.lowercased() == dic_plan.subscription_name.lowercased()
                }) {
                }
                else {
                    self.arr_Section.append(["identifier" : "other_plan_Data", "title": "Subscriptions", "value": dic_plan])
                }
            }
        }
        
        self.tbl_View.reloadData()
    }
}

