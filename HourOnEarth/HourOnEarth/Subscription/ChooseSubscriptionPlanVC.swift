//
//  ChooseSubscriptionPlanVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 03/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChooseSubscriptionPlanVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    var is_razorpayPayment = false
    var is_inappPayment = true
    var arr_Section = [[String: Any]]()
    var arr_plans = [ARSubscriptionPlanModel]()
    var selectedPlan: ARSubscriptionPlanModel?
    var isViewPresented = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Choose Plan".localized()
        self.lbl_Title.text = "Join Prime Club".localized()
        setBackButtonTitle()
        if isViewPresented {
            let cancelBarBtn = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(cancelBtnPressed(_:)))
            self.navigationItem.rightBarButtonItem = cancelBarBtn
        }
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func cancelBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        self.tableView.register(nibWithCellClass: ChooseSubscriptionPlanCell.self)
        self.tableView.register(nibWithCellClass: PrimeSubscriptionHeaderTableCell.self)
        self.fetchPlanList()
    }
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - UITableView Delegate Datasource Method

extension ChooseSubscriptionPlanVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_Section.removeAll()
        self.arr_Section.append(["id": "header"])
        
        var int_indx = 0
        for dic_plan in self.arr_plans {
            if int_indx == 1 {
                self.selectedPlan = dic_plan
            }
            self.arr_Section.append(["id": "plan_data", "value": dic_plan])
            int_indx = int_indx + 1
        }
        
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let str_identifier = self.arr_Section[indexPath.row]["id"] as? String ?? ""
        
        if str_identifier == "header" {
            let cell = tableView.dequeueReusableCell(withClass: PrimeSubscriptionHeaderTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.planTitleL.text = self.selectedPlan?.packName
            cell.planDetailL.setHtmlText(text: self.selectedPlan?.packDescription ?? "")

            //Button Action
            cell.didTappedSubscribeButton = { (sender) in
                SubscriptionDetailVC.showScreen(plan: self.selectedPlan, fromVC: self, in_app: self.is_inappPayment, razorpay: self.is_razorpayPayment)
            }
            //*********************************************************//
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withClass: ChooseSubscriptionPlanCell.self, for: indexPath)
            cell.selectionStyle = .none
            let dic_detail = self.arr_Section[indexPath.row]["value"] as? ARSubscriptionPlanModel
            cell.data = dic_detail
            cell.updateUI(isSelected: (self.selectedPlan?.id == dic_detail?.id))
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str_identifier = self.arr_Section[indexPath.row]["id"] as? String ?? ""
        if str_identifier == "header" {
        }
        else {
            let dic_detail = self.arr_Section[indexPath.row]["value"] as? ARSubscriptionPlanModel
            self.selectedPlan = dic_detail
            self.tableView.reloadData()
        }
    }
}

extension ChooseSubscriptionPlanVC {
    func fetchPlanList() {
        self.showActivityIndicator()
        let params = ["currency": Locale.current.paramCurrencyCode, "language_id" : Utils.getLanguageId(), "device_type": "ios"] as [String : Any]
        doAPICall(endPoint: .getSubscriptionPacks, parameters: params, headers: headers) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                self?.is_inappPayment = responseJSON?["in_app"].bool ?? true
                self?.is_razorpayPayment = responseJSON?["razorpay"].bool ?? false
                
                let plans = responseJSON?["data"].array?.compactMap{ ARSubscriptionPlanModel(fromJson: $0) } ?? []
                self?.arr_plans = plans
                self?.manageSection()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
            }
        }
    }
    
    static func showScreen(isPresent: Bool = false, fromVC: UIViewController) {
        let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
        vc.isViewPresented = isPresent
        if isPresent {
            let nvc = UINavigationController(rootViewController: vc)
            nvc.modalPresentationStyle = .fullScreen
            fromVC.present(nvc, animated: true, completion: nil)
        } else {
            fromVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
