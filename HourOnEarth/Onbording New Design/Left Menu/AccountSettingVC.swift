//
//  AccountSettingVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 11/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class AccountSettingVC: UIViewController {
    
    var arr_Section = [D_SideMenuData]()
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_Title.text = "Account Settings".localized()
        
        //Register Table Cell
        self.tbl_View.register(nibWithCellClass: SideMenuOptionTableCell.self)
        self.tbl_View.register(nibWithCellClass: SideMenuBlankTableCell.self)
        self.tbl_View.register(nibWithCellClass: TitleHeaderTableCell.self)
        
        manageSection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


//MARK: - UITableView Delegate DataSource Method
extension AccountSettingVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_Section.removeAll()
        
        self.arr_Section.append(D_SideMenuData.init(key: .none, title: .kAppSetting, identifier: .header))
        
        self.arr_Section.append(D_SideMenuData.init(key: .kLinkSocial, title: .kLinkSocial, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kChangeLang, title: .kChangeLang, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kDeleteAccount, title: .kDeleteAccount, identifier: .label))
        
        self.arr_Section.append(D_SideMenuData.init(key: .none, title: .kGeneral, identifier: .header))
        
        self.arr_Section.append(D_SideMenuData.init(key: .kAboutUs, title: .kAboutUs, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kCertificates, title: .kCertificates, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kTermsCondition, title: .kTermsCondition, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kPrivacyPolicy, title: .kPrivacyPolicy, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kHowITWork, title: .kHowITWork, identifier: .label))
        self.arr_Section.append(D_SideMenuData.init(key: .kRateApp, title: .kRateApp, identifier: .label))
        
        self.tbl_View.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let str_ID = self.arr_Section[indexPath.row].identifier
        let str_Title = self.arr_Section[indexPath.row].title ?? .none
        
        if str_ID == .header {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleHeaderTableCell", for: indexPath) as! TitleHeaderTableCell
            cell.selectionStyle = .none
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.constraint_lbl_Title_top.constant = 25
            cell.constraint_lbl_Title_bottom.constant = 12
            cell.lbl_Title.font = UIFont.AppFontSemiBold(14)
            cell.lbl_Title.text = str_Title?.rawValue.localized()
            cell.lbl_Title.textColor = UIColor.fromHex(hexString: "#6E6E6E")
            
            return cell
            
        }
        else if str_ID == .label {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuOptionTableCell", for: indexPath) as! SideMenuOptionTableCell
            cell.selectionStyle = .none
            cell.lbl_title.text = str_Title?.rawValue.localized()
            
            return cell
            
        }
        else if str_ID == .blank {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuBlankTableCell", for: indexPath) as! SideMenuBlankTableCell
            cell.selectionStyle = .none
            
            return cell
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let objNavVC = self.navigationController else {
            return
        }
        objNavVC.isNavigationBarHidden = false
        
        guard Utils.isConnectedToNetwork() else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
            return
        }
        
        let str_Key = self.arr_Section[indexPath.row].key ?? .none
        
        if str_Key == .kLinkSocial {
            
            let objSettings = Story_Profile.instantiateViewController(withIdentifier: "SocialMediaLinkViewController") as! SocialMediaLinkViewController
            objNavVC.pushViewController(objSettings, animated: true)
            
        }
        else if str_Key == .kChangeLang {
            
            let storyBoard = UIStoryboard(name: "ChooseLanguage", bundle: nil)
            guard let chooseLanguageViewController = storyBoard.instantiateViewController(withIdentifier: "ChooseLanguageViewController") as? ChooseLanguageViewController else {
                return
            }
            
            chooseLanguageViewController.isInitialLaunch = false
            objNavVC.pushViewController(chooseLanguageViewController, animated: true)
            
        }
        else if str_Key == .kDeleteAccount {
            self.navigationController?.isNavigationBarHidden = true
            showDeleteAccountWarningAlert()
        }
        else if str_Key == .kAboutUs {
            let obj = Story_Profile.instantiateViewController(withIdentifier: "HOEAboutUS") as! HOEAboutUS
            objNavVC.pushViewController(obj, animated: true)
        }
        else if str_Key == .kCertificates {
            let obj = Story_Certificate.instantiateViewController(withIdentifier: "HOECertificates") as! HOECertificates
            objNavVC.pushViewController(obj, animated: true)
            
            return
        }
        else if str_Key == .kTermsCondition {
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            let obj = Story_Profile.instantiateViewController(withIdentifier: "WebVIewViewController") as! WebVIewViewController
            obj.webViewType = .termsOfUse
            objNavVC.pushViewController(obj, animated: true)
        }
        else if str_Key == .kPrivacyPolicy {
            guard Utils.isConnectedToNetwork() else {
                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
                return
            }
            let obj = Story_Profile.instantiateViewController(withIdentifier: "WebVIewViewController") as! WebVIewViewController
            obj.webViewType = .privacyPolicy
            objNavVC.pushViewController(obj, animated: true)
        }
        else if str_Key == .kHowITWork {
            self.navigationController?.isNavigationBarHidden = true
            
            let obj = Story_ChooseLang.instantiateViewController(withIdentifier: "SlideShowViewController") as! SlideShowViewController
            obj.isFromSettings = true
            obj.title = (self.arr_Section[indexPath.row].title ?? .none)?.rawValue.localized()
            obj.hidesBottomBarWhenPushed = true
            objNavVC.pushViewController(obj, animated: true)
        }
        else if str_Key == .kRateApp {
            self.navigationController?.isNavigationBarHidden = true
            let urlString = "https://apps.apple.com/us/app/ayurthym/id1401306733?ls=1"
            guard let url = URL(string: urlString) else {
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    func pleaseRegisterFirst(_ strText: String) {
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please register first to view \(strText).".localized(), controller: self)
            return
        }
    }
    
    
}


//MARK: - Delete Account Method
extension AccountSettingVC {
    
    func showDeleteAccountWarningAlert() {
        let title = "Delete Account".localized()
        let message = "This will delete all the records and information associated with the account. Data cannot be retrieved again.".localized()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No".localized(), style: .default))
        alertController.addAction(UIAlertAction(title: "Yes".localized(), style: .destructive, handler: { (_) in
            self.showDeleteAccountComfirmationAlert()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showDeleteAccountComfirmationAlert() {
        let message = "Are you sure you want to delete your account?".localized()
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No".localized(), style: .default))
        alertController.addAction(UIAlertAction(title: "Yes".localized(), style: .destructive, handler: { (_) in
            self.callDeleteAccountAPI()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func processAccountDelete(message: String) {
        let newMessage = "Account deleted successfully.".localized()
        Utils.showAlertWithTitleInControllerWithCompletion("", message: newMessage, okTitle: "Ok".localized(), controller: self) {
            //back to the login screen
            SideMenuViewController.clearUserDefaultsData()
            kUserDefaults.synchronize()
            kSharedAppDelegate.showLoginScreen()
        }
    }
}


//MARK: - Delete Accont
extension AccountSettingVC {
    func callDeleteAccountAPI() {
        self.showActivityIndicator()
        let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
        doAPICall(endPoint: .DeleteMyAccount, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                self?.hideActivityIndicator()
                self?.processAccountDelete(message: message)
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
            }
        }
    }
}
