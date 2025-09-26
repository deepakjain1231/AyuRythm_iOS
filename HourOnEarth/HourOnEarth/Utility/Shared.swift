//
//  Shared.swift
//  HourOnEarth
//
//  Created by Pradeep on 11/28/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import Foundation


class Shared {
    static let sharedInstance: Shared = Shared()
    
    var maxValue: Double = 160
    var suryaNamaskarCount: Int = 0
    var userWeight: Double = Utils.getLoginUserWeightInKg()

    var isMale: Bool = true
    var isInFt = false
    var isInKg = false
    var weigh = ""
    var inFt = ""
    var inInc = ""
    var dob = ""
    var name = ""
    var referralCode: String?
    var displayData:[String] = [String]()
    
    var filterRecommendation = [String]()
    var filterLevels = [String]()
    var filterTags = [String]()
    
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height

    func clearData() {
        Shared.sharedInstance.isInFt = false
        Shared.sharedInstance.weigh = ""
        Shared.sharedInstance.inFt = ""
        Shared.sharedInstance.inInc = ""
        Shared.sharedInstance.dob = ""
        Shared.sharedInstance.name = ""
        Shared.sharedInstance.referralCode = nil
        Shared.sharedInstance.filterLevels = [String]()
        Shared.sharedInstance.filterRecommendation = [String]()
        Shared.sharedInstance.filterTags = [String]()
        Shared.sharedInstance.displayData = [String]()
        Shared.sharedInstance.deleteAllDataFromUserDefaults()
    }
    
    func clearFilterData() {
        Shared.sharedInstance.filterLevels = [String]()
        Shared.sharedInstance.filterRecommendation = [String]()
        Shared.sharedInstance.filterTags = [String]()
    }
}

extension Shared {
    func saveAllDataToUserDefaults() {
        var sharedUserData = ["isMale": isMale, "isInFt": isInFt, "isInKg": isInKg, "weigh": weigh, "inFt": inFt, "inInc": inInc, "dob": dob, "name": name] as [String : Any]
        if let referralCode = referralCode {
            sharedUserData["referralCode"] = referralCode
        }
        kUserDefaults.setValue(sharedUserData, forKey: kSharedUserData)
        kUserDefaults.synchronize()
    }
    
    func fetchAllDataFromUserDefaults() {
        guard let sharedUserData = kUserDefaults.value(forKey: kSharedUserData) as? [String : Any] else {
            print("no shared user data found")
            return
        }
        isMale = (sharedUserData["isMale"] as? Bool) ?? true
        isInFt = (sharedUserData["isInFt"] as? Bool) ?? false
        isInKg = (sharedUserData["isInKg"] as? Bool) ?? false
        weigh = (sharedUserData["weigh"] as? String) ?? ""
        inFt = (sharedUserData["inFt"] as? String) ?? ""
        inInc = (sharedUserData["inInc"] as? String) ?? ""
        dob = (sharedUserData["dob"] as? String) ?? ""
        name = (sharedUserData["name"] as? String) ?? ""
        referralCode = sharedUserData["referralCode"] as? String
    }
    
    func deleteAllDataFromUserDefaults() {
        kUserDefaults.setValue(nil, forKey: kSharedUserData)
        kUserDefaults.synchronize()
    }
}

// MARK: -
class TodayRecommendations : Codable {
    
    enum Types {
        case yoga
        case pranayam
        case meditation
        case mudra
        case kriya
        case food
        case herbs
        case other
    }

    static let shared = TodayRecommendations()
    
    var yogaIDs : String? = nil {
        didSet {
            if yogaIDs != oldValue {
                saveData()
            }
        }
    }
    
    var pranayamIDs : String? = nil {
        didSet {
            if pranayamIDs != oldValue {
                saveData()
            }
        }
    }
    
    var meditationIDs : String? = nil {
        didSet {
            if meditationIDs != oldValue {
                saveData()
            }
        }
    }
    
    var mudraIDs : String? = nil {
        didSet {
            if mudraIDs != oldValue {
                saveData()
            }
        }
    }
    
    var kriyaIDs : String? = nil {
        didSet {
            if kriyaIDs != oldValue {
                saveData()
            }
        }
    }
    
    var foodIDs : String? = nil {
        didSet {
            if foodIDs != oldValue {
                saveData()
            }
        }
    }
    
    var herbIDs : String? = nil {
        didSet {
            if herbIDs != oldValue {
                saveData()
            }
        }
    }
    
    var lastRecommendationType : String? = nil {
        didSet {
            if lastRecommendationType != oldValue {
                clearData()
            }
        }
    }

    var lastSavedTodayRecommendationDate = Date()

    enum CodingKeys: String, CodingKey {
        case yogaIDs = "yogaIDs"
        case pranayamIDs = "pranayamIDs"
        case meditationIDs = "meditationIDs"
        case mudraIDs = "mudraIDs"
        case kriyaIDs = "kriyaIDs"
        case foodIDs = "foodIDs"
        case herbIDs = "herbIDs"
        case lastSavedTodayRecommendationDate = "lastSavedTodayRecommendationDate"
        case lastRecommendationType = "lastRecommendationType"
    }
    
    init() {
        if let obj = kUserDefaults.retrieve(object: TodayRecommendations.self, fromKey: "TodayRecommendations") {
            self.yogaIDs = obj.yogaIDs
            self.pranayamIDs = obj.pranayamIDs
            self.meditationIDs = obj.meditationIDs
            self.mudraIDs = obj.mudraIDs
            self.kriyaIDs = obj.kriyaIDs
            self.foodIDs = obj.foodIDs
            self.herbIDs = obj.herbIDs
            self.lastRecommendationType = obj.lastRecommendationType
            self.lastSavedTodayRecommendationDate = obj.lastSavedTodayRecommendationDate
            //print("===>> lastSavedTodayRecommendationDate : ", lastSavedTodayRecommendationDate)
//            self.lastSavedTodayRecommendationDate.addTimeInterval(1*24*60*60)
//            print("===>> lastSavedTodayRecommendationDate : ", lastSavedTodayRecommendationDate)
        }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        yogaIDs = try values.decodeIfPresent(String.self, forKey: .yogaIDs)
        pranayamIDs = try values.decodeIfPresent(String.self, forKey: .pranayamIDs)
        meditationIDs = try values.decodeIfPresent(String.self, forKey: .meditationIDs)
        mudraIDs = try values.decodeIfPresent(String.self, forKey: .mudraIDs)
        kriyaIDs = try values.decodeIfPresent(String.self, forKey: .kriyaIDs)
        foodIDs = try values.decodeIfPresent(String.self, forKey: .foodIDs)
        herbIDs = try values.decodeIfPresent(String.self, forKey: .herbIDs)
        lastRecommendationType = try values.decodeIfPresent(String.self, forKey: .lastRecommendationType)
        lastSavedTodayRecommendationDate = try values.decodeIfPresent(Date.self, forKey: .lastSavedTodayRecommendationDate)  ?? Date()
    }
    
    func todayRecommendationsParams(forType: Types) -> [String: Any] {
        if !Calendar.current.isDateInToday(lastSavedTodayRecommendationDate) {
            lastSavedTodayRecommendationDate = Date()
            clearData()
        }
        //print("===>>> TodayRecommendations : ", self.description)
        
        var params = ["from": "home"]
        switch forType {
        case .yoga:
            params["today_keys"] = yogaIDs
        case .pranayam:
            params["today_keys"] = pranayamIDs
        case .meditation:
            params["today_keys"] = meditationIDs
        case .mudra:
            params["today_keys"] = mudraIDs
        case .kriya:
            params["today_keys"] = kriyaIDs
        case .food:
            params["today_keys"] = foodIDs
        case .herbs:
            params["today_keys"] = herbIDs
        default:
            print("default case")
        }
        return params
    }
    
    func saveIDs(ids: String, forType: Types) {
        switch forType {
        case .yoga:
            yogaIDs = ids
        case .pranayam:
            pranayamIDs = ids
        case .meditation:
            meditationIDs = ids
        case .mudra:
            mudraIDs = ids
        case .kriya:
            kriyaIDs = ids
        case .food:
            foodIDs = ids
        case .herbs:
            herbIDs = ids
        default:
            print("default case")
        }
    }
    
    func saveData() {
        //print("---->>> save TodayRecommendations")
        kUserDefaults.save(customObject: self, inKey: "TodayRecommendations")
    }
    
    func clearData() {
        yogaIDs = nil
        pranayamIDs = nil
        meditationIDs = nil
        mudraIDs = nil
        kriyaIDs = nil
        foodIDs = nil
        herbIDs = nil
    }
}

extension TodayRecommendations: CustomStringConvertible {
    var description: String {
        var desc = ""
        desc += "\nyogaIDs : \(yogaIDs ?? "")"
        desc += "\npranayamIDs : \(pranayamIDs ?? "")"
        desc += "\nmeditationIDs : \(meditationIDs ?? "")"
        desc += "\nmudraIDs : \(mudraIDs ?? "")"
        desc += "\nkriyaIDs : \(kriyaIDs ?? "")"
        desc += "\nfoodIDs : \(foodIDs ?? "")"
        desc += "\nherbIDs : \(herbIDs ?? "")"
        desc += "\nlastSavedTodayRecommendationDate : \(lastSavedTodayRecommendationDate)"
        desc += "\nlastRecommendationType : \(lastRecommendationType ?? "")"
        return desc
    }
}
