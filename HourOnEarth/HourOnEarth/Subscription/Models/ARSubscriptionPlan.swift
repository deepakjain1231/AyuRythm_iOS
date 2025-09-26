//
//  ARSubscriptionPlan.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 06/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class ARSubscriptionPlanModel {
    
    var aboutThisPack : String = ""
    var amount : String = ""
    var bonusPercentage : String = ""
    var bonusType : String = ""
    var bonusValue : String = ""
    var id : String = ""
    var iosIapIdentifier : String = ""
    var packDescription : String = ""
    var packMonths : Int = 0
    var packName : String = ""
    var packNotes : String = ""
    var packTrail : String = ""
    var packValidity : String = ""
    var regularAmount : String = ""
    var pauseMaxDays : String = ""
    var pauseTotalCount : String = ""
    var pack_id: String = ""
    var subscription_name: String = ""
    
    var aboutPlans: [String] {
        return aboutThisPack.newlineSeperatedValues
    }
    
    var notes: [String] {
        return packNotes.newlineSeperatedValues
    }


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        aboutThisPack = json["about_this_pack"].stringValue
        amount = json["amount"].stringValue
        bonusPercentage = json["bonus_percentage"].stringValue
        bonusType = json["bonus_type"].stringValue
        bonusValue = json["bonus_value"].stringValue
        id = json["favorite_id"].stringValue
        iosIapIdentifier = json["ios_iap_identifier"].stringValue
        packDescription = json["pack_description"].stringValue
        packMonths = json["pack_months"].intValue
        packName = json["pack_name"].stringValue
        packNotes = json["pack_notes"].stringValue
        packTrail = json["pack_trail"].stringValue
        packValidity = json["pack_validity"].stringValue
        regularAmount = json["regular_amount"].stringValue
        pauseMaxDays = json["pause_max_days"].stringValue
        pauseTotalCount = json["pause_total_count"].stringValue
        pack_id = json["pack_id"].stringValue
        subscription_name = json["subscription_name"].stringValue
    }
    
}

extension ARSubscriptionPlanModel {
    var mainOffer: NSAttributedString {
        let attr: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.fromHex(hexString: "#BC1736"), .font : UIFont.systemFont(ofSize: 21, weight: .bold)]
        switch id {
        case "2":
            return NSAttributedString(string: "1 month".localized()) + NSAttributedString(string: "\nEXTRA!".localized(), attributes: attr)
        case "3":
            return NSAttributedString(string: "1 FREE".localized(), attributes: attr) + NSAttributedString(string: "\nlive session!".localized())
        case "4":
            return NSAttributedString(string: "2 FREE".localized(), attributes: attr) + NSAttributedString(string: "\nlive session!".localized())
        default:
            return NSAttributedString(string: "UNLOCK".localized(), attributes: attr) + NSAttributedString(string: "\neverything".localized())
        }
    }
    
    func getBGImageAndColor(row: Int) -> (image: UIImage, color: UIColor) {
        let idIntValue = row //Int(id) ?? 1
        
        if idIntValue%3 == 0 {
            return (#imageLiteral(resourceName: "plan-stared"), UIColor.fromHex(hexString: "#5CA3EA"))
        } else if idIntValue%2 == 0 {
            return (#imageLiteral(resourceName: "plan-normal"), UIColor.fromHex(hexString: "#84CB81"))
        } else {
            return (#imageLiteral(resourceName: "plan-most-popular"), UIColor.fromHex(hexString: "#F4B800"))
        }
    }
}
