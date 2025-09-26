//
//  PDBluetoothHelper.swift
//  WatchDemoApp
//
//  Created by Paresh Dafda on 21/05/22.
//

import UIKit
import CoreBluetooth

// MARK: -
class BTDevice {
    var name:  String
    var uuid: String?
    var peripheral: CBPeripheral?
    
    internal init(peripheral: CBPeripheral? = nil, name: String = "", uuid: String? = nil) {
        self.name = name
        self.uuid = uuid
        self.peripheral = peripheral
        
        if let peripheral = peripheral {
            if name.isEmpty {
                self.name = peripheral.name ?? "No Name"
            }
            if uuid == nil {
                self.uuid = peripheral.identifier.uuidString
            }
        }
    }
}

extension BTDevice: Equatable, CustomStringConvertible {
    var description: String {
        let desc = "'\(name)' : '\(uuid ?? "No UUID")'\n"
        return desc
    }
    
    static func == (lhs: BTDevice, rhs: BTDevice) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

// MARK: -
protocol PDBluetoothHelperDelegate {
    func bluetoothHelper(helper: PDBluetoothHelper, didUpdateBluetoothState status: CBManagerState)
    func bluetoothHelper(helper: PDBluetoothHelper, didDiscover devices: [BTDevice])
    func bluetoothHelper(helper: PDBluetoothHelper, didReceiveAdData advertisementData: Data?, serviceUUIDs: [CBUUID])
    func bluetoothHelper(helper: PDBluetoothHelper, didConnect device: BTDevice)
    func bluetoothHelper(helper: PDBluetoothHelper, didDisconnect device: BTDevice, error: Error?)
}

extension PDBluetoothHelperDelegate {
    func bluetoothHelper(helper: PDBluetoothHelper, didUpdateBluetoothState status: CBManagerState) {}
    func bluetoothHelper(helper: PDBluetoothHelper, didDiscover devices: [BTDevice]) {}
    func bluetoothHelper(helper: PDBluetoothHelper, didReceiveAdData advertisementData: Data?, serviceUUIDs: [CBUUID]) {}
    func bluetoothHelper(helper: PDBluetoothHelper, didConnect device: BTDevice) {}
    func bluetoothHelper(helper: PDBluetoothHelper, didDisconnect device: BTDevice, error: Error?) {}
}

class PDBluetoothHelper: NSObject {
    
    static let shared = PDBluetoothHelper()
    
    var centralManager: CBCentralManager!
    var delegate: PDBluetoothHelperDelegate?
    
    var isiOSBluetoothOn = false
    var btDevices = [BTDevice]()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func isBluetoothPermissionGiven(fromVC: UIViewController) -> Bool {
        delegate?.bluetoothHelper(helper: self, didUpdateBluetoothState: centralManager.state)
        if !isiOSBluetoothOn {
            if centralManager.state == .poweredOff {
                openAppOrSystemSettingsAlert(title: "Bluetooth seems to be Off. Please switch on Bluetooth from the settings.", message: "", fromVC: fromVC)
               return false
            }
            
            if #available(iOS 13.0, *) {
                if (CBCentralManager().authorization != .allowedAlways) {   //System will automatically ask user to turn on iOS system Bluetooth if this returns false
                    openAppOrSystemSettingsAlert(title: "Bluetooth permission is currently disabled for the application. Enable Bluetooth from the application settings.", message: "", fromVC: fromVC)
                    return false
                }
            } else {
                let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
                openAppOrSystemSettingsAlert(title: "\"\(appName ?? "You Application Nam")\" would like to use Bluetooth for new connections", message: "You can allow new connections in Settings", fromVC: fromVC)
                return false
            }
        }
        return true
    }
    
    func openAppOrSystemSettingsAlert(title: String, message: String, fromVC: UIViewController) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        fromVC.present(alertController, animated: true, completion: nil)
    }
}

extension PDBluetoothHelper {
    func startScan(withServices: [CBUUID]? = nil) {
        centralManager.scanForPeripherals(withServices: withServices, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
    func stopScan() {
        if centralManager.isScanning {
            centralManager.stopScan()
        }
    }
    
    func connect(device: BTDevice) {
        if let peripheral = device.peripheral {
            centralManager.connect(peripheral)
        }
    }
}

extension PDBluetoothHelper: CBCentralManagerDelegate {
    // If we're powered on, start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.bluetoothHelper(helper: self, didUpdateBluetoothState: central.state)
        if central.state != .poweredOn {
            print(">> Bluetooth OFF or permission not given")
            isiOSBluetoothOn = false
        } else {
            print(">> Bluetooth ON")
            isiOSBluetoothOn = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let newDevice = BTDevice(peripheral: peripheral)
        if !btDevices.contains(newDevice) {
            btDevices.append(newDevice)
            print(">> All Device \n", btDevices)
            delegate?.bluetoothHelper(helper: self, didDiscover: btDevices)
        }
        print(">> BT device searching....")
        //print(">> advertisementData : ", advertisementData)
        //let isConnectable = advertisementData["kCBAdvDataIsConnectable"] as! Bool
        let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data
        let serviceUUIDs = advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID] ?? []
        delegate?.bluetoothHelper(helper: self, didReceiveAdData: manufacturerData, serviceUUIDs: serviceUUIDs)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let device = btDevices.first(where: { $0.peripheral == peripheral }) {
            delegate?.bluetoothHelper(helper: self, didConnect: device)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let device = btDevices.first(where: { $0.peripheral == peripheral }) {
            delegate?.bluetoothHelper(helper: self, didDisconnect: device, error: error)
        }
    }
}
