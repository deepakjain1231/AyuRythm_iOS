//
//  ARBPLDeviceManager.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 13/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SwiftyJSON

class ARBPLDeviceManager {
    static let BPLDeviceRegisterCodes = ["BPL45D", "BPL15D"]

    static let shared = ARBPLDeviceManager()
    var deviceData: ARBPLDeviceData
    var appliedPromocode: ARBPLPromocode?
    
    var appliedPromocodeValue: String {
        return appliedPromocode?.couponCode ?? (Self.BPLDeviceRegisterCodes.first ?? "")
    }
    
    var appliedPromocodeDays: String {
        return appliedPromocode?.couponValidity ?? ""
    }
    
    init() {
        //Make it true to print BLE device logs like device connect, data received and etc
        ARBleConfig.enableLog = false
        deviceData = Self.fetchSavedBPLDeviceDataFromUserDefauld()
    }
    
    func addBPLDevice(_ device: ARBPLDeviceModel) {
        if let index = deviceData.devices.firstIndex(where: { $0.deviceType == device.deviceType }) {
            deviceData.devices[index] = device
        } else {
            deviceData.devices.append(device)
        }
        addEnterDeviceResultEntry(device: device)
        deviceData.devices.sort(by: {$0.displayOrder < $1.displayOrder})
        saveBPLDeviceDataInUserDefault()
    }
    
    func addEnterDeviceResultEntry(device: ARBPLDeviceModel) {
        var newDevice: ARBPLDeviceModel?
        switch device.deviceType {
        case .oximeter:
            newDevice = ARBPLDeviceModel(deviceType: .enterOximeterResult, deviceTypeString: "Enter Oximeter Result")
        case .bpMonitor:
            newDevice = ARBPLDeviceModel(deviceType: .enterBPMonitorResult, deviceTypeString: "Enter BP Monitor Result")
        /*case .weighingScale:
            newDevice = ARBPLDeviceModel(deviceType: .enterWeighingScaleResult, deviceTypeString: "Enter Weighing Scale Result")*/
        default:
            print("")
        }
        if let newDevice = newDevice {
            if deviceData.devices.contains(newDevice) {
                if device.isBluetoothEnabled {
                    deviceData.devices.remove(object: newDevice)
                }
            } else {
                if !device.isBluetoothEnabled {
                    deviceData.devices.append(newDevice)
                }
            }
        }
    }
    
    func isAnyBluetoothEnableOximeterRegistered() -> Bool {
        if let oximeter = deviceData.devices.first(where: { $0.deviceType == .oximeter }) {
            if oximeter.isBluetoothEnabled {
                return true
            }
        }
        return false
    }
    
    func isAnyBluetoothEnableWeighingMachineRegistered() -> Bool {
        if let oximeter = deviceData.devices.first(where: { $0.deviceType == .weighingScale }) {
            if oximeter.isBluetoothEnabled {
                return true
            }
        }
        return false
    }
}

extension ARBPLDeviceManager {
    func startBPLDeviceAddProcess(isFromDeviceEdit: Bool = false, fromVC: UIViewController) {
        if isFromDeviceEdit {
            ARBPLEnterSerialNoVC.showScreen(fromVC: fromVC)
        } else {
            Self.showEnterPromocodeAlert(fromVC: fromVC)
        }
    }
    
    func enterBPLDeviceResult(device: ARBPLDeviceModel, fromVC: UIViewController) {
        ARBPLEnterDeviceResultVC.showScreen(deviceType: device.deviceType, fromVC: fromVC)
    }
    
    static func showEnterPromocodeAlert(fromVC: UIViewController) {
        let alert = UIAlertController(title: "Promo Code".localized(), message: "Please enter promo code".localized(), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter here".localized()
            textField.autocapitalizationType = .allCharacters
        }
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .destructive))
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { [weak alert] (_) in
            let promocode = alert?.textFields?.first?.text ?? ""
            print(">> promocode : \(promocode)")
            fromVC.showActivityIndicator()
            Self.validateBPLPromocode(code: promocode) { success, message, promocodeData in
                ARBPLDeviceManager.shared.appliedPromocode = promocodeData
                if success {
                    fromVC.hideActivityIndicator()
                    ARBPLEnterSerialNoVC.showScreen(fromVC: fromVC)
                } else {
                    fromVC.hideActivityIndicator(withTitle: "Promo Code".localized(), Message: message) 
                }
            }
            /*if promocode.caseInsensitiveEqualTo(ARBPLDeviceManager.BPLDeviceRegisterCode) {
                ARBPLEnterSerialNoVC.showScreen(fromVC: fromVC)
            } else {
                fromVC.showAlert(title: "Promo Code".localized(), message: "Invalid promo code".localized())
            }*/
        }))
        fromVC.present(alert, animated: true, completion: nil)
    }
    
    func saveBPLDeviceDataInUserDefault() {
        if let data = try? JSONEncoder().encode(deviceData) {
            kUserDefaults.set(data, forKey: "kBPLDeviceData")
        }
    }
    
    static func fetchSavedBPLDeviceDataFromUserDefauld() -> ARBPLDeviceData {
        var deviceData = ARBPLDeviceData(devices: [ARBPLDeviceModel(deviceType: .registerNewDevice, deviceTypeString: "Register New BPL Device", serialNo: "", deviceModel: "Register New BPL Device")])
        if let data = kUserDefaults.data(forKey: "kBPLDeviceData"), let savedDeviceData = try? JSONDecoder().decode(ARBPLDeviceData.self, from: data) {
            deviceData = savedDeviceData
        }
        return deviceData
    }
    
    static func clearSavedBPLDeviceDataFromUserDefauld() {
        kUserDefaults.removeObject(forKey: "kBPLDeviceData")
    }
}

extension ARBPLDeviceManager {
    static func validateBPLPromocode(code: String, completion: @escaping (_ success: Bool, _ message: String,_ promocodeData: ARBPLPromocode?)->Void) {
        let params = ["language_id" : Utils.getLanguageId(), "coupon_code": code] as [String : Any]
        Utils.doAPICall(endPoint: .fetchBplCouponCode, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            let type = responseJSON?["type"].string ?? ""
            if isSuccess, let responseJSON = responseJSON, type.caseInsensitiveEqualTo("BPL") {
                let data =  ARBPLPromocode(fromJson: responseJSON["data"])
                completion(isSuccess, message, data)
            } else {
                completion(isSuccess, message, nil)
            }
        }
    }
    
    static func updateOximeterResult(value: Int, completion: @escaping (_ success: Bool, _ message: String)->Void) {
        let params = ["language_id" : Utils.getLanguageId(), "sp02_value": value] as [String : Any]
        Utils.doAPICall(endPoint: .setBplOximeterValue, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess {
                completion(isSuccess, message)
            } else {
                completion(isSuccess, message)
            }
        }
    }
    
    static func updateBPMonitorResult(params: [String: Any], completion: @escaping (_ success: Bool, _ message: String)->Void) {
        Utils.doAPICall(endPoint: .setBplBpMonitorValue, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess {
                completion(isSuccess, message)
            } else {
                completion(isSuccess, message)
            }
        }
    }
    
    static func updateUserWeight(by value: Double, completion: @escaping (Bool, String, String)->Void) {
        let params = ["language_id" : Utils.getLanguageId(), "weight": value] as [String : Any]
        Utils.doAPICall(endPoint: .setBplWeightValue, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess {
                var measurements = responseJSON?["newdata"]["measurements"].stringValue ?? ""
                if measurements.isEmpty {
                    measurements = responseJSON?["data"]["measurements"].stringValue ?? ""
                }
                //update local values
                Shared.sharedInstance.userWeight = value
                if var empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any], !measurements.isEmpty {
                    empData["measurements"] = measurements
                    kUserDefaults.setValue(empData, forKey: USER_DATA)
                }
                completion(isSuccess, message, measurements)
            } else {
                completion(isSuccess, message, "")
            }
        }
    }
}
