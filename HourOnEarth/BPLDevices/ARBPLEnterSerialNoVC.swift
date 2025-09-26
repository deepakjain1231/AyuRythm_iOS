//
//  ARBPLEnterSerialNoVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 13/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARBPLEnterSerialNoVC: UIViewController {
    
    @IBOutlet var blurView: UIVisualEffectView! {
        didSet {
            blurView.layer.cornerRadius = 12
            blurView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var serialNoTF: UITextField!
    @IBOutlet weak var continueBtn: UIButton!
    
    var serialNo = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        serialNoTF.autocapitalizationType = .allCharacters
        serialNoTF.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
        continueBtn.isEnabled = false
    }
    
    @IBAction func cancelBtnPressed(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func continueBtnPressed(sender: UIButton) {
        fetchDeviceInfo()
    }
    
    func showNextScreen(device: ARBPLDeviceModel) {
        let fromVC = self.presentingViewController
        self.dismiss(animated: true) {
            ARBPLDeviceInfoVC.showScreen(device: device, fromVC: fromVC ?? self)
        }
    }
}

extension ARBPLEnterSerialNoVC {
    @objc func textFieldTextDidChange(_ textField: UITextField) {
        serialNo = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if serialNo.count >= 10 {
            continueBtn.isEnabled = true
        } else {
            continueBtn.isEnabled = false
        }
    }
    
    func fetchDeviceInfo() {
        self.showActivityIndicator()
        let params = ["bplbatchcode": serialNo, "language_id" : Utils.getLanguageId()] as [String : Any]
        doAPICall(endPoint: .fetchBplDeviceInfo, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let device = ARBPLDeviceModel(fromJson: responseJSON["data"])
                self?.hideActivityIndicator()
                self?.showNextScreen(device: device)
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
}

extension ARBPLEnterSerialNoVC {
    static func showScreen(fromVC: UIViewController) {
        let vc = ARBPLEnterSerialNoVC.instantiate(fromAppStoryboard: .BPLDevices)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        fromVC.present(vc, animated: true, completion: nil)
    }
}
