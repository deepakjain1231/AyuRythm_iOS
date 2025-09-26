//
//  ARBPLEnterDeviceResultVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 13/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARBPLEnterDeviceResultVC: UIViewController {
    
    @IBOutlet var blurView: UIVisualEffectView! {
        didSet {
            blurView.layer.cornerRadius = 12
            blurView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var resultTF: UITextField!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!

    var resultValue = 0
    var resultMinValue = 0
    var resultMaxValue = 5000
    var deviceType = ARBPLDeviceModel.DeviceType.other
    
    var defaultResultValue: Int {
        if deviceType == .enterOximeterResult {
            return 98
        } else if deviceType == .enterWeighingScaleResult {
            return 40
        } else {
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultTF.delegate = self
        setupUI()
    }
    
    func setupUI() {
        if deviceType == .enterOximeterResult {
            //SPO2 limit : 85 to 100, default 98
            resultValue = defaultResultValue
            resultMinValue = 85
            resultMaxValue = 100
        } else if deviceType == .enterWeighingScaleResult {
            resultValue = defaultResultValue
        }
        updateUI()
    }
    
    func updateUI() {
        resultTF.text = "\(resultValue)"
    }
    
    func showSaveSuccessMessage() {
        let successMessage = "Device result saved successfully.".localized()
        Utils.showAlertWithTitleInControllerWithCompletion("", message: successMessage, okTitle: "Ok".localized(), controller: self) {
            self.closeScreen()
        }
    }
    
    @IBAction func plusBtnPressed(sender: UIButton) {
        resultValue += 1
        updateUI()

        minusBtn.isEnabled = (resultValue > resultMinValue)
        plusBtn.isEnabled = !(resultValue > resultMaxValue)
    }
    
    @IBAction func minusBtnPressed(sender: UIButton) {
        resultValue -= 1
        updateUI()
        if resultValue <= 0 {
            minusBtn.isEnabled = false
        }
        minusBtn.isEnabled = (resultValue > resultMinValue)
    }
    
    @IBAction func cancelBtnPressed(sender: UIButton) {
        self.closeScreen()
    }
    
    @IBAction func confirmBtnPressed(sender: UIButton) {
        self.view.endEditing(true)
        updateResultOnServer()
    }
}

extension ARBPLEnterDeviceResultVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        resultValue = Int(textField.text ?? "\(defaultResultValue)") ?? defaultResultValue
        updateUI()
    }
}

extension ARBPLEnterDeviceResultVC {
    func closeScreen() {
        self.dismiss(animated: true)
    }
    
    func updateResultOnServer() {
        if deviceType == .enterOximeterResult {
            showActivityIndicator()
            ARBPLDeviceManager.updateOximeterResult(value: resultValue) { success, message in
                if success {
                    self.hideActivityIndicator()
                    self.showSaveSuccessMessage()
                } else {
                    self.hideActivityIndicator(withMessage: message)
                }
            }
        } else if deviceType == .enterWeighingScaleResult {
            showActivityIndicator()
            ARBPLDeviceManager.updateUserWeight(by: Double(resultValue)) { success, message, measurements  in
                if success {
                    self.hideActivityIndicator()
                    self.showSaveSuccessMessage()
                } else {
                    self.hideActivityIndicator(withMessage: message)
                }
            }
        } else {
            self.closeScreen()
        }
    }
    
    static func showScreen(deviceType: ARBPLDeviceModel.DeviceType, fromVC: UIViewController) {
        let vc = ARBPLEnterDeviceResultVC.instantiate(fromAppStoryboard: .BPLDevices)
        vc.deviceType = deviceType
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        fromVC.present(vc, animated: true, completion: nil)
    }
}
