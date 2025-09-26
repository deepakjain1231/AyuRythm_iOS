//
//  ARAccountSettingsVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 14/03/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARAccountSettingsVC: BaseViewController {
    
    enum ARSettings: Int {
        case deleteAccount

        var title: String {
            switch self {
            case .deleteAccount:
                return "Delete Account"
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier = "AccountSettingCell"
    let settings: [ARSettings] = [.deleteAccount]
    
    // MARK: View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Account Settings".localized()
        tableView.tableFooterView = UIView()
        setupUI()
    }
    
    // MARK: Custom Methods
    
    @objc func setupUI() {
        tableView.reloadData()
    }
    
    func showDeleteAccountWarningAlert() {
        let title = "Delete Account".localized()
        let message = "This will delete all the records and information associated with the account. Data cannot be retrieved again.".localized()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes".localized(), style: .destructive, handler: { (_) in
            self.showDeleteAccountComfirmationAlert()
        }))
        alertController.addAction(UIAlertAction(title: "No".localized(), style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showDeleteAccountComfirmationAlert() {
        let message = "Are you sure you want to delete your account?".localized()
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes".localized(), style: .destructive, handler: { (_) in
            self.callDeleteAccountAPI()
        }))
        alertController.addAction(UIAlertAction(title: "No".localized(), style: .default))
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

// MARK: UITableView Delegate and DataSource Methods
extension ARAccountSettingsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else {
            return UITableViewCell()
        }
        
        let setting = settings[indexPath.row]
        cell.textLabel?.text = setting.title.localized()
        if setting == .deleteAccount {
            cell.textLabel?.textColor = .systemRed
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = settings[indexPath.row]
        switch setting {
        case .deleteAccount:
            print("delete Account")
            showDeleteAccountWarningAlert()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ARAccountSettingsVC {
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
