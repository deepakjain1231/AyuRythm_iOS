//
//  ChooseLanguageViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 16/07/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class ChooseLanguageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var isInitialLaunch = true
    var currentLanguage = "en"
    
    // MARK: View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        if let lang = kUserDefaults.string(forKey: kAppLanguage) {
            currentLanguage = lang
        }
    }
    
    // MARK: Action Methods
    
    // MARK: Custom Methods
    
    @objc func setupUI() {
        tableView.reloadData()
    }
    
    // MARK: UITableView Delegate and DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell") else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "English"
            cell.accessoryType = currentLanguage == "en" ? .checkmark : .none
        } else {
            cell.textLabel?.text = "हिंदी"
            cell.accessoryType = currentLanguage == "hi" ? .checkmark : .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: "Application will restart for the language change to reflect in the app".localized(), cancelTitle: "Cancel".localized(), okTitle: "Ok".localized(), controller: self, completionHandler: {
            if indexPath.row == 0 {
                if self.currentLanguage != "en" {
                    Localize.setCurrentLanguage("en")
                    kUserDefaults.set("en", forKey: kAppLanguage)
                    self.clearDataAndExitApp()
                }
            } else {
                if self.currentLanguage != "hi" {
                    Localize.setCurrentLanguage("hi")
                    kUserDefaults.set("hi", forKey: kAppLanguage)
                    self.clearDataAndExitApp()
                }
            }
        }) {}
    }
    
    func clearDataAndExitApp() {
        Utils.clearUserDataBaseData()
        exit(0)
    }
}
