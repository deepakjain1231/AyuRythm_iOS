//
//  ARBPLDeviceModel.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 14/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import SwiftyJSON

// MARK: -
class ARBPLDeviceData: Codable {
    var devices: [ARBPLDeviceModel] = []
    
    internal init(devices: [ARBPLDeviceModel]) {
        self.devices = devices
    }
}

// MARK: -
class ARBPLDeviceModel: Codable {
    enum DeviceType: String {
        case registerNewDevice
        case oximeter = "Oximeter"
        case enterOximeterResult
        case bpMonitor = "BP Meter"
        case enterBPMonitorResult
        case weighingScale = "Weighing Scale"
        case enterWeighingScaleResult
        case other
    }
    
    var deviceType = DeviceType.other
    var deviceTypeString: String
    var serialNo: String
    var isBluetoothEnabled = false
    var deviceModel: String
    
    var displayOrder: Int {
        switch deviceType {
        case .registerNewDevice:
            return 0
        case .oximeter:
            return 1
        case .enterOximeterResult:
            return 2
        case .bpMonitor:
            return 3
        case .enterBPMonitorResult:
            return 4
        case .weighingScale:
            return 5
        case .enterWeighingScaleResult:
            return 6
        case .other:
            return 7
        }
    }
    
    var displayString: String {
        switch deviceType {
        case .registerNewDevice, .enterOximeterResult, .enterBPMonitorResult, .enterWeighingScaleResult:
            return deviceTypeString
        case .oximeter:
            return "BPL Oximeter"
        case .bpMonitor:
            return "BPL BP Monitor"
        case .weighingScale:
            return "Weighing Scale Machine"
        case .other:
            return "Other"
        }
        //return deviceTypeString.localized()
    }
    
    internal init(deviceType: ARBPLDeviceModel.DeviceType, deviceTypeString: String = "", serialNo: String = "", deviceModel: String = "", bluetoothEnabled: Bool = false) {
        self.deviceType = deviceType
        self.deviceTypeString = deviceTypeString
        self.serialNo = serialNo
        self.isBluetoothEnabled = bluetoothEnabled
        self.deviceModel = deviceModel
    }
    
    enum CodingKeys: String, CodingKey {
        case deviceType
        case deviceTypeString
        case serialNo
        case isBluetoothEnabled
        case deviceModel
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deviceType.rawValue, forKey: .deviceType)
        try container.encode(deviceTypeString, forKey: .deviceTypeString)
        try container.encode(serialNo, forKey: .serialNo)
        try container.encode(isBluetoothEnabled, forKey: .isBluetoothEnabled)
        try container.encode(deviceModel, forKey: .deviceModel)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let typeValue = try values.decodeIfPresent(String.self, forKey: .deviceType) ?? "other"
        deviceType = DeviceType(rawValue: typeValue) ?? .other
        deviceTypeString = try values.decodeIfPresent(String.self, forKey: .deviceTypeString) ?? ""
        serialNo = try values.decodeIfPresent(String.self, forKey: .serialNo) ?? ""
        isBluetoothEnabled = try values.decodeIfPresent(Bool.self, forKey: .isBluetoothEnabled) ?? false
        deviceModel = try values.decodeIfPresent(String.self, forKey: .deviceModel) ?? ""
    }
    
    init(fromJson json: JSON!){
        self.deviceType = DeviceType(rawValue: json["device_type"].stringValue) ?? .other
        self.deviceTypeString = json["bpl_devicetype"].stringValue
        self.serialNo = json["bpl_batchcode"].stringValue
        self.isBluetoothEnabled =  json["device_bluetooth"].boolValue
        self.deviceModel = json["bpl_devicemodel"].stringValue
        
        //self.isBluetoothEnabled = false
    }
}

extension ARBPLDeviceModel: Equatable {
    static func == (lhs: ARBPLDeviceModel, rhs: ARBPLDeviceModel) -> Bool {
        return lhs.deviceType == rhs.deviceType
    }
}
