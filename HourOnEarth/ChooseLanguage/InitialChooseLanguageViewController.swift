//
//  InitialChooseLanguageViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 30/07/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

enum ARLanguages: Int {
    case english = 1
    case hindi
}

class InitialChooseLanguageViewController: BaseViewController {
    
    @IBOutlet var view_english_Btn: UIView!
    @IBOutlet var view_hindi_Btn: UIView!
    @IBOutlet var img_english_selection: UIImageView!
    @IBOutlet var img_hindi_selection: UIImageView!
    @IBOutlet var btn_continue: UIButton!
    
    var isInitialLaunch = true
    var selectedLanguage = ARLanguages.english
    
    // MARK: View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view_hindi_Btn.layer.borderWidth = 2
        self.view_english_Btn.layer.borderWidth = 2
        self.view_hindi_Btn.layer.borderColor = UIColor.fromHex(hexString: "#BBBBBB").cgColor
        self.view_english_Btn.layer.borderColor = AppColor.app_DarkGreenColor.cgColor
        
        
        //choose english as default language
        self.selectedLanguage = ARLanguages.english
    }
    
    // MARK: Action Methods
    @IBAction func btn_English_Action(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25) {
            self.img_hindi_selection.isHidden = true
            self.img_english_selection.isHidden = false
            self.selectedLanguage = ARLanguages.english
            self.view_hindi_Btn.backgroundColor = .clear
            self.btn_continue.setTitle("continue_with_english".localized(), for: .normal)
            self.view_english_Btn.backgroundColor = UIColor.fromHex(hexString: "#FFE7D6")
            self.view_hindi_Btn.layer.borderColor = UIColor.fromHex(hexString: "#BBBBBB").cgColor
            self.view_english_Btn.layer.borderColor = AppColor.app_DarkGreenColor.cgColor
        }
    }
    
    @IBAction func btn_Hindi_Action(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25) {
            self.img_hindi_selection.isHidden = false
            self.img_english_selection.isHidden = true
            self.selectedLanguage = ARLanguages.hindi
            self.view_english_Btn.backgroundColor = .clear
            self.btn_continue.setTitle("continue_with_hindi".localized(), for: .normal)
            self.view_hindi_Btn.backgroundColor = UIColor.fromHex(hexString: "#FFE7D6")
            self.view_hindi_Btn.layer.borderColor = AppColor.app_DarkGreenColor.cgColor
            self.view_english_Btn.layer.borderColor = UIColor.fromHex(hexString: "#BBBBBB").cgColor
        }
    }

    @IBAction func continueBtnClicked(_ sender: UIButton) {
        print("Selected Language : ", selectedLanguage)
        if selectedLanguage != .english {
            showPermissionAlert()
        } else {
            Localize.setCurrentLanguage("en")
            kUserDefaults.set("en", forKey: kAppLanguage)
            if kUserDefaults.value(forKey: kIsFirstLaunch) == nil {
                kSharedAppDelegate.showSlideShow()
            } else {
                kSharedAppDelegate.showLoginScreen()
            }
        }
    }
    
    // MARK: Custom Methods
    
    func showPermissionAlert() {
        Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: "Application will restart for the language change to reflect in the app".localized(), okTitle: "Ok".localized(), controller: self) {
            
            switch self.selectedLanguage {
            case .english:
                Localize.setCurrentLanguage("en")
                kUserDefaults.set("en", forKey: kAppLanguage)
                
            case .hindi:
                Localize.setCurrentLanguage("hi")
                kUserDefaults.set("hi", forKey: kAppLanguage)
            }
            
            exit(0)
        }
    }
}
