//
//  ARStreakDayModel.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 10/02/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SwiftyJSON

// MARK: -
class ARStreakDayModel {

    var date : String!
    var key : Int!
    var isToday = false

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        date = json["date"].stringValue
        key = json["key"].intValue
        
        if let dateValue = date.UTCToLocalDate(incomingFormat: "yyyy-MM-dd") {
            isToday = Calendar.current.isDateInToday(dateValue)
        }
    }

}

extension ARStreakDayModel {
    var isSparshanNotDone: Bool {
        return key == 0
    }
    
    func getDayColors() -> (bgColor: UIColor, textColor: UIColor) {
        /*if isToday {
            return (bgColor: UIColor.fromHex(hexString: "#3E8B3A"), textColor: .white)
        }*/
        
        /* user_streak > key param means

         0 means = not done,
         1 means done
         2 means = date not arrived.. */
        switch key {
        case 0:
            return (bgColor: UIColor.fromHex(hexString: "#EA526F"), textColor: .white)
        
        case 1:
            return (bgColor: UIColor.fromHex(hexString: "#6CC068"), textColor: .white)
            
        default:
            return (bgColor: UIColor.fromHex(hexString: "#EEEEEE"), textColor: .black)
        }
    }
}
