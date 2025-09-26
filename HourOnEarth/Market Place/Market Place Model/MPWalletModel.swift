//
//  MPWalletModel.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 29/08/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import Foundation
import ObjectMapper

class MPWalletModel: Mappable {
    
    var status: String = ""
    var data: [MPWalletData] = []
    var singleData: MPWalletData?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        status <- map["status"]
        data <- map["data"]
        singleData <- map["data"]
    }
}

class MPWalletData: Mappable{
    var referal: String = ""
    var wallet_balance: NSNumber = 0
    var cashback_guarantee: String = ""
    
    var All: [MPAll_WalletData] = []
    var Paid: [MPAll_WalletData] = []
    var Received: [MPAll_WalletData] = []

    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        All <- map["All"]
        Paid <- map["Paid"]
        referal <- map["referal"]
        Received <- map["Received"]
        wallet_balance <- map["wallet_balance"]
        cashback_guarantee <- map["cashback_guarantee"]
    }
}


class MPAll_WalletData: Mappable{
    var id: Int = 0
    var amount: Int = 0
    var created_at: String = ""
    var expiring_on: String = ""
    var narration: String = ""
    var transaction_id: String = ""
    var transaction_title: String = ""

    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        amount <- map["amount"]
        created_at <- map["created_at"]
        expiring_on <- map["expiring_on"]
        narration <- map["narration"]
        transaction_id <- map["transaction_id"]
        transaction_title <- map["transaction_title"]
    }
}
