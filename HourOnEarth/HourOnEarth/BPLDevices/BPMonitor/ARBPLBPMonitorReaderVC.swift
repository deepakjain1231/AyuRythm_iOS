//
//  ARBPLBPMonitorReaderVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 23/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import CoreBluetooth

// MARK: - BP Monitor
enum BPLBPMonitorParams {
    static let SupportedBPLBPMonitorDeviceNames = ["AL_WBP"]
    
    // services and charcteristics Identifiers
    static let BloodPressureServiceUUID = CBUUID.init(string: "FFF0")
    static let BloodPressureCharacteristicUUID = CBUUID.init(string: "FFF4")
}

// MARK: -
class ARBPLBPMonitorReaderVC: UIViewController {
    
    @IBOutlet weak var currentBPL: UILabel!
    @IBOutlet weak var sysDiaBPL: UILabel!
    @IBOutlet weak var pulseL: UILabel!
    @IBOutlet weak var currentBPView: UIView!
    
    var device: ARBleDevice?
    var readingChar: CBCharacteristic?
    
    var isDataReadingDone = false
    
    var readingBPValue = 0
    var sysBPValue = 0
    var diaBPValue = 0
    var pulseValue = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "BPL BP Monitor".localized()
        setBackButtonTitle()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startBleScanning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ARBleManager.shareInstance.delegate = self
        ARBleManager.shareInstance.scanForDevices()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopReadingBPMonitorDevice()
        ARBleManager.shareInstance.delegate = nil
    }
    
    deinit {
        DebugLog("-")
        stopReadingBPMonitorDevice()
    }
    
    func setupUI() {
        setupBleDevice()
    }
    
    func updateUI() {
        currentBPL.attributedText = self.getValueWithUnitAttribText(value: readingBPValue.stringValue, unit: "mmHg", valueColor: .red)
        if isDataReadingDone {
            currentBPView.isHidden = true
            let value = sysBPValue.stringValue + "/" + diaBPValue.stringValue
            sysDiaBPL.attributedText = self.getValueWithUnitAttribText(value: value, unit: "mmHg")
            pulseL.attributedText = self.getValueWithUnitAttribText(value: pulseValue.stringValue, unit: "bpm")
        }
    }
    
    func getValueWithUnitAttribText(value: String, unit: String, valueColor: UIColor = .black) -> NSAttributedString {
        return NSAttributedString(string: value, attributes: [.foregroundColor: valueColor]) +
        NSAttributedString(string: " " + unit, attributes: [.foregroundColor: UIColor.fromHex(hexString: "#777777"), .font : UIFont.systemFont(ofSize: 14, weight: .medium)])
    }
    
    @IBAction func doneBtnPressed(sender: UIButton) {
        //API call
        updateBPMonitorResultOnServer()
    }
}

extension ARBPLBPMonitorReaderVC {
    func processOnBPMonitorData(_ data: [UInt8]) {
        ARBle_debug_log("did rececive data : \(data), count : \(data.count)")
        guard data.count >= 2 else {
            ARBle_debug_log("No proper data found")
            return
        }
        
        guard data[0] == 170 else {
            ARBle_debug_log("Not BP Monitor related data")
            return
        }
        
        let packageType = data[2]
        if packageType == 40, data.count == 7 {
            readingBPValue = Int(data[3])
        } else if packageType == 41, data.count == 15 {
            sysBPValue = Int(data[5])
            diaBPValue = Int(data[6])
            pulseValue = Int(data[8])
            isDataReadingDone = true
        }
        updateUI()
        
        if isDataReadingDone {
            stopReadingBPMonitorDevice()
        }
    }
    
    func closeScreen() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showOkAlert(title: String = "", message: String) {
        Utils.showAlertWithTitleInControllerWithCompletion(title, message: message, okTitle: "Ok".localized(), controller: self) {
            DispatchQueue.delay(.milliseconds(100), closure: {
                self.closeScreen()
            })
        }
    }
    
    func updateBPMonitorResultOnServer() {
        if isDataReadingDone {
            showActivityIndicator()
            let params = ["bpm": pulseValue, "sp": sysBPValue, "dp": diaBPValue, "bala": (sysBPValue - diaBPValue)]
            ARBPLDeviceManager.updateBPMonitorResult(params: params) { success, message in
                if success {
                    self.hideActivityIndicator()
                    self.showOkAlert(message: message)
                } else {
                    self.hideActivityIndicator(withMessage: message)
                }
            }
        } else {
            self.closeScreen()
        }
    }
}

extension ARBPLBPMonitorReaderVC: ARBleManagerDelegate {
    func manager(_ manager: ARBleManager, didStateChange state: ARBleState) {
        ARBle_debug_log("status change : \(state)")
    }
    
    func manager(_ manager: ARBleManager, didScan device: ARBleDevice) {
        ARBle_debug_log("scanned BP Monitor : \(device.name)")
        self.device = device
        ARBleManager.shareInstance.connectDevice(device)
    }
    
    func managerDidScanTimeout(_ manager: ARBleManager) {
        ARBle_debug_log("scan timeout")
    }
    
    func manager(_ manager: ARBleManager, didConnect device: ARBleDevice) {
        ARBle_debug_log("oximeter did connect : \(device.name)")
    }
    
    func manager(_ manager: ARBleManager, didConnectTimeout device: ARBleDevice) {
        ARBle_debug_log("connect timeout : \(device.name)")
    }
    
    func manager(_ manager: ARBleManager, didFailToConnect device: ARBleDevice, error: Error?) {
        ARBle_debug_log("did fail to connect : \(device.name), error: \(error?.localizedDescription ?? "-")")
    }
    
    func manager(_ manager: ARBleManager, didDisconnect device: ARBleDevice, error: Error?) {
        ARBle_debug_log("did disconnect : \(device.name), error: \(error?.localizedDescription ?? "-")")
    }
    
    func manager(_ manager: ARBleManager, didReceiveAdvertisementData data: Data) {
        let finalData = [UInt8](data)
        ARBle_debug_log("did rececive adv data : \(finalData), count : \(finalData.count)")
    }
    
    func manager(_ manager: ARBleManager, deviceDidReady device: ARBleDevice) {
        ARBle_debug_log("oximeter did ready : \(device.name)")
    }
    
    func manager(_ manager: ARBleManager, device: ARBleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        ARBle_debug_log("did discover characteristics for service : \(service.uuid.uuidString)")
        guard self.device == device else { return }
        
        if let char = device.allCharacteristics.first(where: { $0.uuid == BPLBPMonitorParams.BloodPressureCharacteristicUUID }) {
            readingChar = char
            device.setNotification(for: char, enable: true)
        }
    }
    
    func manager(_ manager: ARBleManager, device: ARBleDevice, didUpdateValueFor characteristic: CBCharacteristic, value: Data?, error: Error?) {
        guard let data = value, !data.isEmpty else { return }
        DispatchQueue.main.async {
            self.processOnBPMonitorData([UInt8](data))
        }
    }
    
    func setupBleDevice() {
        ARBleConfig.continueScan = true
        ARBleConfig.acceptableDeviceNames = BPLBPMonitorParams.SupportedBPLBPMonitorDeviceNames
        ARBleConfig.acceptableDeviceServiceUUIDs = [BPLBPMonitorParams.BloodPressureServiceUUID.uuidString]
        ARBleManager.shareInstance.delegate = self
    }
    
    func startBleScanning() {
        if let device = device, device.isConnected {
            ARBle_debug_log("already connected to BP Monitor, don't start scan")
            return
        }
        
        if isDataReadingDone {
            ARBle_debug_log("already done reading BP Monitor data, don't start scan")
            return
        }
        
        if ARBleManager.shareInstance.isBleEnable {
            ARBle_debug_log("scanning ...")
            ARBleManager.shareInstance.scanForDevices()
        } else {
            ARBle_debug_log("Bluetooth is OFF")
        }
    }
    
    func stopReadingBPMonitorDevice() {
        if let device = device {
            if device.isConnected {
                device.setNotification(for: readingChar, enable: false)
            }
            ARBleManager.shareInstance.disonnectDevice(device)
        }
        device = nil
        ARBleManager.shareInstance.stopScan()
    }
}

extension ARBPLBPMonitorReaderVC {
    static func showScreen(device: ARBleDevice? = nil, fromVC: UIViewController) {
        let vc = ARBPLBPMonitorReaderVC.instantiate(fromAppStoryboard: .BPLDevices)
        vc.device = device
        if let fromVC = fromVC as? UINavigationController {
            fromVC.pushViewController(vc, animated: true)
        } else {
            fromVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
