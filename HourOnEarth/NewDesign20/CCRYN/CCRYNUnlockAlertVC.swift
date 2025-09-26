//
//  CCRYNUnlockAlertVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 01/07/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class CCRYNUnlockAlertVC: UIViewController {
    
    @IBOutlet var blurView: UIVisualEffectView! {
        didSet {
            blurView.layer.cornerRadius = 12
            blurView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var consent1Lbl: UILabel!
    @IBOutlet weak var consent2Lbl: UILabel!
    @IBOutlet weak var consent3Lbl: UILabel!
    
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var term1Btn: UIButton!
    @IBOutlet weak var term2Btn: UIButton!
    @IBOutlet weak var term3Btn: UIButton!
    
    @IBOutlet weak var unlockBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var completion : ((Bool, String)->Void)?
    var isNadiBandProject = false

    override func viewDidLoad() {
        super.viewDidLoad()
        unlockBtn.isEnabled = false
        
        if isNadiBandProject {
            titleLbl.text = "Nadi Band Project".localized()
            codeTF.placeholder = "Enter code".localized()
            messageLbl.text = "INSTRUCTIONS\nComplete Digital Nadi using AyuRythm in presence of assigned nadi experts. It is important that both digital nadi recording and recording by nadi expert should be done simultaneously or one after the other with minimum delay.".localized()
            consent1Lbl.text = "I understand that AyuRythm disclaims any responsibility or liability in connection to my voluntary participation in this study and I accept the same.".localized()
            consent2Lbl.text = "I understand the purpose of this study is data collection and analysis only. I understand that for any treatment I have to take expert guidance.".localized()
            consent3Lbl.text = "I consent to share the de-identified data with AyuRythm and Nadi experts for research purposes.".localized()
            unlockBtn.setTitle("Unlock".localized(), for: .normal)
        }
    }
    
    static func showScreen(isNadiBandProject: Bool = false, presentingVC: UIViewController?, completion: ((Bool, String)->Void)? = nil) {
        let vc = CCRYNUnlockAlertVC.instantiateFromStoryboard("CCRYN")
        vc.completion = completion
        vc.isNadiBandProject = isNadiBandProject
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        presentingVC?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unlockChallengeBtnPressed(sender: UIButton) {
        //call unlock api
        let code = codeTF.text ?? ""
        print("CCRYN Code: \(code)")
        
        if !code.isEmpty {
            self.showActivityIndicator()
            MyHomeViewController.checkCCRYNCode(isNadiBandProject: isNadiBandProject, code: code) { [weak self] (success, message) in
                self?.hideActivityIndicator()
                if success {
                    if let strongSelf = self, strongSelf.isNadiBandProject {
                        kUserDefaults.isNadiBandProjectUnlocked = true
                    } else {
                        kUserDefaults.isCCRYNChallengeUnlocked = true
                    }
                    self?.dismiss(animated: true) { [weak self] in
                        self?.completion?(true, message)
                    }
                } else {
                    self?.completion?(false, message)
                }
            }
        } else {
            self.completion?(false, "Please enter the correct code".localized())
            /*Utils.showAlertWithTitleInControllerWithCompletion("", message: "Please enter valid CCRYN code".localized(), okTitle: "Ok", controller: self) {
                self.showCCRYNUnlockAlert()
            }*/
        }
    }
    
    @IBAction func termsBtnPressed(sender: UIButton) {
        sender.isSelected.toggle()
        updateUnlockButtonStatus()
    }
    
    @IBAction func textFieldDidEditChange(sender: UITextField) {
        updateUnlockButtonStatus()
    }
    
    func updateUnlockButtonStatus() {
        if term1Btn.isSelected, term2Btn.isSelected, term3Btn.isSelected, let code = codeTF.text, !code.isEmpty {
            unlockBtn.isEnabled = true
        } else {
            unlockBtn.isEnabled = false
        }
    }
}

extension CCRYNUnlockAlertVC {
    static func unlockAndAddCCYNCount(isBackBtnVisible: Bool = false, fromVC: UIViewController) {
        onetimeCallModuleToResetSuryahonUnlock()
        if kUserDefaults.isCCRYNChallengeUnlocked {
            showAddCCYNCountAlert(isBackBtnVisible: isBackBtnVisible, fromVC: fromVC)
        } else {
            CCRYNUnlockAlertVC.showScreen(presentingVC: fromVC) { (success, message) in
                if success {
                    showAddCCYNCountAlert(isBackBtnVisible: isBackBtnVisible, fromVC: fromVC)
                } else {
                    fromVC.showAlert(message: message)
                }
            }
        }
    }
    
    static func showAddCCYNCountAlert(isBackBtnVisible: Bool = false, fromVC: UIViewController) {
        showAddCCRYNCountAlert(from: fromVC) { (success, message) in
            if success {
                if let homeVC = fromVC as?  MyHomeViewController {
                    homeVC.tblViewHome.reloadData()
                }
                SparshnaAlert.showSparshnaTestScreen(isBackBtnVisible: isBackBtnVisible, fromVC: fromVC)
            } else {
                fromVC.showAlert(message: message)
            }
        }
    }
    
    static func onetimeCallModuleToResetSuryahonUnlock() {
        //print(">>>> isResetSuryathonUnlockStatus : ", kUserDefaults.isResetSuryathonUnlockStatus)
        if !kUserDefaults.isResetSuryathonUnlockStatus {
            kUserDefaults.isCCRYNChallengeUnlocked = false
            kUserDefaults.isResetSuryathonUnlockStatus = true
        }
    }
    
    static func showAddCCRYNCountAlert(from vc: UIViewController, completion: ((Bool, String)->Void)? = nil) {
        let alert = UIAlertController(title: "Suryathon by CCRYN\n\nTrack your Progress!".localized(), message: "Great job!!\n\nHow many Surya Namaskars did you complete today?".localized(), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "How many Surya Namaskars did you complete today?".localized()
            textField.keyboardType = .numberPad
        }

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .destructive))
        alert.addAction(UIAlertAction(title: "Test Now".localized(), style: .default, handler: { [weak alert] (_) in
            let value = alert?.textFields?.first?.text ?? ""
            print("CCRYN Value: \(value)")
            
            if !value.isEmpty, let intValue = Int(value) {
                //store and increase count localy
                /*var suryaCounts = kUserDefaults.suryaNamaskarCount
                suryaCounts += intValue
                kUserDefaults.suryaNamaskarCount = suryaCounts
                print(">>>> suryaNamaskarCount : ", suryaCounts)
                completion?(true, "success")*/
                //call api to update value
                vc.showActivityIndicator()
                MyHomeViewController.updateCCRYNValue(value: value) { (success, message) in
                    vc.hideActivityIndicator()
                    Shared.sharedInstance.suryaNamaskarCount += intValue
                    //NotificationCenter.default.post(name: .refreshDailyTaskList, object: nil)
                    completion?(success, message)
                }
            } else {
                Utils.showAlertWithTitleInControllerWithCompletion("", message: "Please enter valid count value".localized(), okTitle: "Ok".localized(), controller: vc) {
                    showAddCCRYNCountAlert(from: vc, completion: completion)
                }
            }
        }))
        vc.present(alert, animated: true, completion: nil)
    }
}
