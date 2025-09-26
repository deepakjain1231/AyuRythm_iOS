//
//  ARBPLDeviceInfoVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 13/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARBPLDeviceInfoVC: UIViewController {

    @IBOutlet var blurView: UIVisualEffectView! {
        didSet {
            blurView.layer.cornerRadius = 12
            blurView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var serialNoTF: UITextField!
    @IBOutlet weak var deviceTypeTF: UITextField!
    @IBOutlet weak var deviceModelTF: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var device: ARBPLDeviceModel?
    var isFromDeviceListingScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        serialNoTF.text = device?.serialNo
        deviceTypeTF.text = device?.deviceTypeString
        deviceModelTF.text = device?.deviceModel
        if isFromDeviceListingScreen {
            confirmBtn.setTitle("Edit".localized(), for: .normal)
        }
    }
    
    @IBAction func cancelBtnPressed(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func confirmBtnPressed(sender: UIButton) {
        if isFromDeviceListingScreen {
            let fromVC = self.presentingViewController
            self.dismiss(animated: true) {
                ARBPLDeviceManager.shared.startBPLDeviceAddProcess(isFromDeviceEdit: true, fromVC: fromVC ?? self)
            }
        } else {
            registerDevice(device)
        }
    }
}

extension ARBPLDeviceInfoVC {
    func registerDevice(_ device: ARBPLDeviceModel?) {
        guard let device = device else { return }
        
        self.showActivityIndicator()
        let params = ["bpldevicetype": device.deviceTypeString,
                      "bplbatchcode": device.serialNo,
                      "bpldevicemodel": device.deviceModel,
                      "referral_code": ARBPLDeviceManager.shared.appliedPromocodeValue,
                      "language_id" : Utils.getLanguageId()] as [String : Any]
        doAPICall(endPoint: .setBplDeviceInfo, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                ARBPLDeviceManager.shared.addBPLDevice(device)
                NotificationCenter.default.post(name: .refreshBPLDeviceList, object: nil)
                self?.hideActivityIndicator()
                let fromVC = self?.presentingViewController
                self?.dismiss(animated: true) {
                    guard let self = self else { return }
                    let isGetSubscripitionCoupon = message.caseInsensitiveContains("Activated")
                    ARBPLDeviceRegisterSuccessVC.showScreen(isGetSubscripitionCoupon: isGetSubscripitionCoupon, fromVC: fromVC ?? self)
                }
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    static func showScreen(device: ARBPLDeviceModel, isFromDeviceListingScreen: Bool = false, fromVC: UIViewController) {
        let vc = ARBPLDeviceInfoVC.instantiate(fromAppStoryboard: .BPLDevices)
        vc.device = device
        vc.isFromDeviceListingScreen = isFromDeviceListingScreen
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        fromVC.present(vc, animated: true, completion: nil)
    }
}
