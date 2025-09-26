//
//  ARBPLDeviceSearchVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 27/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import CoreBluetooth

class ARBPLDeviceSearchVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var deviceNotFoundView: UIView!
    
    var deviceType = ARBPLDeviceModel.DeviceType.other
    var devices = [ARBleDevice]()
    var connectingDevice: ARBleDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopBleScanning()
        ARBleManager.shareInstance.delegate = nil
    }
    
    deinit {
        DebugLog("-")
        if let connectingDevice = connectingDevice {
            if connectingDevice.peripheral?.state == .connected {
                ARBleManager.shareInstance.disonnectDevice(connectingDevice)
            }
        }
        connectingDevice = nil
    }
    
    func setupUI() {
        self.title = "BPL BP Monitor".localized()
        setBackButtonTitle()
        searchBtn.setTitle("Searching...".localized(), for: .selected)
        setupBle()
    }
    
    func setupBle() {
        ARBleConfig.continueScan = false
        
        //For BP Monitor device search only
        ARBleConfig.acceptableDeviceNames = BPLBPMonitorParams.SupportedBPLBPMonitorDeviceNames
        ARBleConfig.acceptableDeviceServiceUUIDs = [BPLBPMonitorParams.BloodPressureServiceUUID.uuidString]
        
        ARBleManager.shareInstance.delegate = self
    }
    
    func startBleScanning() {
        ARBleManager.shareInstance.delegate = self
        if ARBleManager.shareInstance.isBleEnable {
            ARBle_debug_log("scanning ...")
            ARBleManager.shareInstance.scanForDevices()
        } else {
            ARBle_debug_log("Bluetooth is OFF")
        }
        searchBtn.isSelected = true
        /*devices.removeAll()
        tableView.reloadData()*/
    }
    
    func stopBleScanning() {
        ARBleManager.shareInstance.stopScan()
        searchBtn.isSelected = false
    }
    
    func showNextScreen(connectedDevice: ARBleDevice) {
        ARBPLBPMonitorReaderVC.showScreen(device: connectedDevice, fromVC: self)
    }
}

extension ARBPLDeviceSearchVC {
    static func showScreen(deviceType: ARBPLDeviceModel.DeviceType, fromVC: UIViewController) {
        let vc = ARBPLDeviceSearchVC.instantiate(fromAppStoryboard: .BPLDevices)
        vc.deviceType = deviceType
        if let fromVC = fromVC as? UINavigationController {
            fromVC.pushViewController(vc, animated: true)
        } else {
            fromVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ARBPLDeviceSearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ARBleSearchDeviceCell.self, for: indexPath)
        cell.device = devices[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showActivityIndicator()
        let device = devices[indexPath.row]
        stopBleScanning()
        ARBleManager.shareInstance.connectDevice(device)
        connectingDevice = device
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ARBPLDeviceSearchVC {
    @IBAction func searchBtnPressed(sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            startBleScanning()
        } else {
            stopBleScanning()
        }
    }
}

extension ARBPLDeviceSearchVC: ARBleManagerDelegate {
    func manager(_ manager: ARBleManager, didStateChange state: ARBleState) {
        ARBle_debug_log("status change : \(state)")
    }
    
    func manager(_ manager: ARBleManager, didScan device: ARBleDevice) {
        ARBle_debug_log("scanned device : \(device.name)")
        DispatchQueue.main.async {
            if !self.devices.contains(device) {
                self.devices.append(device)
                self.tableView.reloadData()
            }
        }
    }
    
    func managerDidScanTimeout(_ manager: ARBleManager) {
        ARBle_debug_log("scan timeout")
        DispatchQueue.main.async {
            self.stopBleScanning()
            if self.devices.isEmpty {
                self.hideActivityIndicator(withMessage: "Scan timeout".localized())
            }
        }
    }
    
    func manager(_ manager: ARBleManager, didConnect device: ARBleDevice) {
        ARBle_debug_log("device did connect : \(device.name)")
        DispatchQueue.main.async {
            //self.hideActivityIndicator(withMessage: "Device did connect : \(device.name)".localized())
            //self.hideActivityIndicator()
            //self.showNextScreen()
        }
    }
    
    func manager(_ manager: ARBleManager, didConnectTimeout device: ARBleDevice) {
        ARBle_debug_log("connect timeout : \(device.name)")
        DispatchQueue.main.async {
            self.hideActivityIndicator(withMessage: "Connect timeout".localized())
        }
    }
    
    func manager(_ manager: ARBleManager, didFailToConnect device: ARBleDevice, error: Error?) {
        ARBle_debug_log("did fail to connect : \(device.name), error: \(error?.localizedDescription ?? "-")")
        DispatchQueue.main.async {
            self.hideActivityIndicator(withTitle: "Fail to connect device".localized(), Message: error?.localizedDescription ?? "")
        }
    }
    
    func manager(_ manager: ARBleManager, device: ARBleDevice, didDiscoverServices error: Error?) {
        ARBle_debug_log("did discover services : \(device.allServices)")
        DispatchQueue.main.async {
            if device == self.connectingDevice {
                if let error = error {
                    self.hideActivityIndicator(withTitle: "Fail to connect device".localized(), Message: error.localizedDescription)
                } else if device.allServices.first(where: { $0.uuid == BPLBPMonitorParams.BloodPressureServiceUUID }) == nil {
                    self.hideActivityIndicator(withTitle: "Fail to connect device".localized(), Message: "No required service found on device".localized())
                }
            }
        }
    }
    
    func manager(_ manager: ARBleManager, device: ARBleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        ARBle_debug_log("did discover characteristics for service : \(service.uuid.uuidString)")
        DispatchQueue.main.async {
            if device == self.connectingDevice {
                if let char = device.allCharacteristics.first(where: { $0.uuid == BPLBPMonitorParams.BloodPressureCharacteristicUUID }) {
                    self.hideActivityIndicator()
                    self.showNextScreen(connectedDevice: device)
                } else {
                    self.hideActivityIndicator(withTitle: "Fail to connect device".localized(), Message: "No required service characteristic found on device".localized())
                }
            }
        }
    }
}

// MARK: -
class ARBleSearchDeviceCell: UITableViewCell {
    
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var serialNoL: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let bgView = UIView()
        bgView.backgroundColor = .clear
        selectedBackgroundView = bgView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    var device: ARBleDevice? {
        didSet {
            guard let device = device else { return }
            
            nameL.text = "Name".localized() + " : " + device.name
            serialNoL.text = "SN : " + ""
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        borderView.backgroundColor = selected ? .lightGray.withAlphaComponent(0.5) : .white
    }
}
