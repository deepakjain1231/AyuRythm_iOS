//
//  SurveyData.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 26/09/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import Foundation

class SurveyData : Codable {

    static let shared = SurveyData()
    
    var curetedListIDs = [Int]()
    var contentTypeIDs = [Int]()
    var levelID = 0
    let defaultLevelID = 0
    var timeSlot = 5
    let defaultTimeSlot = 1
    var reminderTime = ""
    var repetedDay = [Int]()

    enum CodingKeys: String, CodingKey {
        case curetedListIDs = "curetedListIDs"
        case contentTypeIDs = "contentTypeIDs"
        case levelID = "levelID"
        case timeSlot = "timeSlot"
        case reminderTime = "reminderTime"
        case repetedDay = "repetedDay"
    }
    
    init() {
        if let obj = kUserDefaults.retrieve(object: SurveyData.self, fromKey: "SurveyData") {
            self.curetedListIDs = obj.curetedListIDs
            self.contentTypeIDs = obj.contentTypeIDs
            self.levelID = obj.levelID
            self.timeSlot = obj.timeSlot
            self.reminderTime = obj.reminderTime
            self.repetedDay = obj.repetedDay
        }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        curetedListIDs = try values.decodeIfPresent([Int].self, forKey: .curetedListIDs) ?? []
        contentTypeIDs = try values.decodeIfPresent([Int].self, forKey: .contentTypeIDs) ?? []
        levelID = try values.decodeIfPresent(Int.self, forKey: .levelID) ?? defaultLevelID
        timeSlot = try values.decodeIfPresent(Int.self, forKey: .timeSlot) ?? defaultTimeSlot
        reminderTime = try values.decodeIfPresent(String.self, forKey: .reminderTime) ?? ""
        repetedDay = try values.decodeIfPresent([Int].self, forKey: .repetedDay) ?? []
    }
}

extension SurveyData {
    func apiParams() -> [String: Any] {
//        var focusOn = [String]()
//        contentTypeIDs.forEach{
//            if let contentType = SurveyStep3ViewController.ContentType(rawValue: $0) {
//                focusOn.append(contentType.stringValue)
//            }
//        }
        let levelParamID = LevelType(rawValue: levelID)?.levelParamID ?? defaultLevelID
        let goad_ids = curetedListIDs.compactMap{String($0)}.commaSeperatedString
        let acive_ids = contentTypeIDs.compactMap{String($0)}.commaSeperatedString
        let reportedTime_ids = repetedDay.compactMap{String($0)}.commaSeperatedString
        
        let recommendationPrakriti = Utils.getYourCurrentPrakritiStatus()
        let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        
        var paramm = ["goal_ids": goad_ids,
                      "focus_on": "Yogasana,Pranayama,Meditation,Mudras,Kriyas",
                      "experience_level": levelParamID,
                      "time_slot": "5",
                      "goal_achieve_by": acive_ids, //comma saprate
                      "selected_time": reminderTime, //hh:mm a
                      "selected_days": reportedTime_ids,
                      "type": recommendationVikriti.rawValue,
                      "typetwo": recommendationPrakriti.rawValue] as [String : Any] //0 = Mon, 1 = Tue, 2 = Wed, 3 = Thu, 4 = Fri, 5 = Sat, 6 = Sun
        
#if !APPCLIP
        paramm["type"] = appDelegate.cloud_vikriti_status
#endif
//        let params = ["experience_level": levelParamID, "time_slot": timeSlot, "focus_on": focusOn.commaSeperatedString, "goal_ids": goad_ids] as [String: Any]
        print("-->> Survey Params : ", paramm)
        return paramm
    }
    
    func updateData(from dict: [String: Any]) {
        if let userGoals = dict["UserGoal"] as? [[String: Any]], let userGoal = userGoals.first  {
            if let levelIDStr = userGoal["experience_level"] as? String, let levelIDInt = Int(levelIDStr) {
                levelID = LevelType.levelType(from: levelIDInt).rawValue
            }
            if let focusOnStr = userGoal["focus_on"] as? String {
                let focusOnArray = focusOnStr.commaSeperatedValues
//                contentTypeIDs = focusOnArray.map{ SurveyStep3ViewController.ContentType.contentTypeValue(from: $0).rawValue }
            }
            if let goalIDsStr = userGoal["goad_ids"] as? String {
                let goalIDsArray = goalIDsStr.commaSeperatedValues
                curetedListIDs = goalIDsArray.compactMap{ Int($0) }
            }
            if let goalachieveIDsStr = userGoal["goal_achieve_by"] as? String {
                let goalachieveIDsArray = goalachieveIDsStr.commaSeperatedValues
                contentTypeIDs = goalachieveIDsArray.compactMap{ Int($0) }
            }
            if let timeSlotStr = userGoal["time_slot"] as? String, let timeSlotInt = Int(timeSlotStr) {
                timeSlot = timeSlotInt
            }
            if let repeatedIDsStr = userGoal["selected_days"] as? String {
                let repetedIDsArray = repeatedIDsStr.commaSeperatedValues
                repetedDay = repetedIDsArray.compactMap{ Int($0) }
            }
            saveData()
        } else {
            clearData()
        }
    }
    
//    func isContentAvailable(type: SurveyStep3ViewController.ContentType) -> Bool {
//        return contentTypeIDs.isEmpty || contentTypeIDs.contains(type.rawValue)
//    }
}

extension SurveyData {
    func resetData() {
        if let obj = kUserDefaults.retrieve(object: SurveyData.self, fromKey: "SurveyData") {
            self.curetedListIDs = obj.curetedListIDs
            self.contentTypeIDs = obj.contentTypeIDs
            self.levelID = obj.levelID
            self.timeSlot = obj.timeSlot
            self.reminderTime = obj.reminderTime
            self.repetedDay = obj.repetedDay
        }
    }
    
    func saveData() {
        print("---->>> save SurveyData")
        kUserDefaults.save(customObject: self, inKey: "SurveyData")
    }
    
    func clearData() {
        curetedListIDs.removeAll()
        contentTypeIDs.removeAll()
        levelID = defaultLevelID
        timeSlot = defaultTimeSlot
        reminderTime = ""
        repetedDay.removeAll()
        
        saveData()
    }
}
