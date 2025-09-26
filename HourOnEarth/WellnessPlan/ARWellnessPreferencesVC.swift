//
//  ARWellnessPreferencesVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 22/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARWellnessPreferencesVC: UIViewController {

    @IBOutlet weak var lbl_title: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var constraint_btn_continue_Width: NSLayoutConstraint!
    
    var preferences = [ARWellnessPreferenceModel]()
    var isFirstTimeShow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tell us".localized()
        self.lbl_title.text = "Tell us".localized()
        self.constraint_btn_continue_Width.constant = screenWidth - 40
        setBackButtonTitle()
        self.navigationController?.isNavigationBarHidden = true
        
        tableView.register(nibWithCellClass: ARWellnessPreferenceHeaderCell.self)
        tableView.register(nibWithCellClass: ARWellnessPreferenceItemCell.self)
        
        updateUI()
    }
    
    func updateUI() {
        getCurrentWellnessPreference()
        if !isFirstTimeShow {
            continueBtn.setTitle("Submit".localized(), for: .normal)
            continueBtn.setImage(nil, for: .normal)
        }
    }
    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueBtnPressed(sender: UIButton) {
        setCurrentWellnessPreference()
    }
    
    func showSubscriptionAlert() {
        let alert = UIAlertController(title: "Subscription required".localized(), message: "To change your diet plan preferences please subscribe".localized(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default))
        alert.addAction(UIAlertAction(title: "Check Plans".localized(), style: .default, handler: { _ in
            ChooseSubscriptionPlanVC.showScreen(fromVC: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func processNext() {
        if isFirstTimeShow {
            kUserDefaults.isWellnessPreferenceSet = true
            ARWellnessPlanVC.showScreen(fromVC: self)
        } else {
            NotificationCenter.default.post(name: .refreshWellnessPlanData, object: "wellness_preference")
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension ARWellnessPreferencesVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return preferences.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferences[section].values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let preference = preferences[indexPath.section]
        let item = preference.values[indexPath.row]
        let cell = tableView.dequeueReusableCell(withClass: ARWellnessPreferenceItemCell.self, for: indexPath)
        cell.item = item
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withClass: ARWellnessPreferenceHeaderCell.self)
        cell.preference = preferences[section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withClass: ARWellnessPreferenceFooterCell.self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let preference = preferences[indexPath.section]
        preference.selectItem(at: indexPath.row)
        tableView.reloadData()
    }
}

extension ARWellnessPreferencesVC {
    static func showScreen(isFirstTimeShow: Bool = false, fromVC: UIViewController) {
        let vc = ARWellnessPreferencesVC.instantiate(fromAppStoryboard: .WellnessPlan)
        vc.isFirstTimeShow = isFirstTimeShow
        vc.hidesBottomBarWhenPushed = true
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ARWellnessPreferencesVC {
    func getCurrentWellnessPreference() {
        self.showActivityIndicator()
        let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
        Utils.doAPICall(endPoint: .getWellnessPreference, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                self?.preferences = responseJSON?["data"].array?.compactMap{ ARWellnessPreferenceModel(fromJson: $0) } ?? []
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    func setCurrentWellnessPreference() {
        var params = ["language_id" : Utils.getLanguageId()] as [String : Any]
        preferences.forEach { preference in
            if preference.id == "1" {
                params["wellness_plan"] = preference.getSelectedItemsString()
            } else {
                params["food_prefernce"] = preference.getSelectedItemsString()
            }
        }
        self.showActivityIndicator()
        Utils.doAPICall(endPoint: .addUserWellnessPreference, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.set_prefrence.rawValue)
                self?.hideActivityIndicator()
                self?.processNext()
            } else {
                if message.caseInsensitiveContains("subscription") || message.caseInsensitiveContains("subscribe") {
                    self?.hideActivityIndicator()
                    self?.showSubscriptionAlert()
                } else {
                    self?.hideActivityIndicator(withMessage: message)
                }
            }
        }
    }
}

// MARK: -
class ARWellnessPreferenceFooterCell: UITableViewCell {
}
