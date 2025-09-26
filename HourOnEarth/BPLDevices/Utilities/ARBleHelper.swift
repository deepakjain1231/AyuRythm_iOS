//
//  ARBleHelper.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 18/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class EasyBleHelper: NSObject {
    //data to hexstring
    static func hexString(data: Data) -> String {
        return data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: data.count)
            return buffer.map{String(format: "%02hhx", $0)}.reduce("", {$0 + $1})
            
        }
    }
    //hextstring to string
    static func stringFromHexString(hex: String) -> String? {
        var hex = hex
        var data = Data()
        while hex.count > 0 {
            let c: String = String(hex[hex.startIndex..<hex.index(hex.startIndex, offsetBy: 2)])
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 2)..<hex.endIndex])
            var ch: uint = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return String(data: data, encoding: .utf8)
    }
    //hexstring to nsnumber
    static func numberFromHexString(hex: String) -> NSNumber? {
        var number: uint = 0
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        scanner.scanHexInt32(&number)
        return NSNumber(value: number)
    }
    //hexData to mac address
    static func macAddressFromHexData(hexData: Data) -> String? {
        var hexStr = EasyBleHelper.hexString(data: hexData)
        for index in [2, 5, 8, 11, 14] {
            hexStr.insert(":", at: hexStr.index(hexStr.startIndex, offsetBy: index))
        }
        return hexStr
    }
}

// MARK: - Helper Extensions
extension StringProtocol {
    var hexa: [UInt8] {
        var startIndex = self.startIndex
        return (0..<count/2).compactMap { _ in
            let endIndex = index(after: startIndex)
            defer { startIndex = index(after: endIndex) }
            return UInt8(self[startIndex...endIndex], radix: 16)
        }
    }
}

extension DataProtocol {
    var data: Data { .init(self) }
    var hexa: String { map { .init(format: "%02x", $0) }.joined() }
}
