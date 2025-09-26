//
//  AKPedometerData.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 02/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import Alamofire

let DefaultStepGoalValue: Int = 4000

// MARK: -
class ARPedometerDataModel: Codable, Equatable {
    static func == (lhs: ARPedometerDataModel, rhs: ARPedometerDataModel) -> Bool {
        return lhs.date == rhs.date
    }
    
    var stepCount: Double {
        didSet {
            calorie = ARPedometerData.getCalories(from: stepCount)
            //distance = ARPedometerData.getDistanceInKm(from: stepCount)
        }
    }
    var distance: Double
    var calorie: Double
    
    //Old logic to get calorie and distance from healthkit
    /*var stepCount: Double {
        didSet {
            if calorie == 0 {
                calorie = ARPedometerData.getCalories(from: stepCount)
            }
        }
    }
    var distance: Double
    var calorie: Double {
        willSet {
            if newValue == 0, stepCount > 0 {
                self.calorie = ARPedometerData.getCalories(from: stepCount)
            }
        }
    }*/
    var goal = DefaultStepGoalValue
    var date = ""
    
    internal init(stepCount: Double, distance: Double, calorie: Double) {
        self.stepCount = stepCount
        self.distance = distance
        self.calorie = calorie
    }
    
    static func emptyModel() -> ARPedometerDataModel {
        return ARPedometerDataModel(stepCount: 0, distance: 0, calorie: 0)
    }
    
    var isEmptyModel: Bool {
        if stepCount == 0, distance == 0, calorie == 0 {
            return true
        } else {
            return false
        }
    }
    
    func toDictionary() -> [String: Any] {
        return ["date": date,
                "steps": stepCount,
                "distance": distance,
                "calories": calorie,
                "goal": goal]
    }
}

extension ARPedometerDataModel: CustomStringConvertible {
    var description: String {
        var desc = ">>>> [\(date)] :"
        desc += " [stepCount : \(stepCount)],"
        desc += " [distance : \(distance)],"
        desc += " [calorie : \(calorie)],"
        desc += " [goal : \(goal)]"
        return desc
    }
}

// MARK: -
class ARPedometerData: Codable {
    
    var dataHistory = [ARPedometerDataModel]() {
        didSet {
            saveToUserDefault()
        }
    }
    var goal: Int = DefaultStepGoalValue {
        didSet {
            saveToUserDefault()
        }
    }
    var lastSyncDate: Date? {
        didSet {
            saveToUserDefault()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case dataHistory = "dataHistory"
        case goal = "goal"
        case lastSyncDate = "lastSyncDate"
    }
    
    init() {
        if let obj = kUserDefaults.retrieve(object: ARPedometerData.self, fromKey: kPedometerData) {
            self.dataHistory = obj.dataHistory
            self.goal = obj.goal
            self.lastSyncDate = obj.lastSyncDate
        }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dataHistory = try values.decodeIfPresent([ARPedometerDataModel].self, forKey: .dataHistory) ?? []
        goal = try values.decodeIfPresent(Int.self, forKey: .goal) ?? DefaultStepGoalValue
        lastSyncDate = try values.decodeIfPresent(Date.self, forKey: .lastSyncDate)
    }
}

extension ARPedometerData {
    func saveToUserDefault() {
        kUserDefaults.save(customObject: self, inKey: kPedometerData)
    }
    
    static func deleteFromUserDefault() {
        kUserDefaults.removeObject(forKey: kPedometerData)
    }
    
    static func loadUserFromUserDefault() -> ARPedometerData {
        return kUserDefaults.retrieve(object: ARPedometerData.self, fromKey: kPedometerData) ?? ARPedometerData()
    }
}

extension ARPedometerData {
    var todaysData: ARPedometerDataModel {
        let dateStr = Date().pedometerDataSaveDateKey
        if let data = dataHistory.first(where: { $0.date == dateStr }) {
            return data
        } else {
            return ARPedometerDataModel.emptyModel()
        }
    }
    
    var todayData_StepsProgressString: String {
        return String(format: "%@".localized(), todaysData.stepCount.stringWithCommas)
    }
    
    var todayData_TotalStepsProgressString: String {
        return String(format: "/%@".localized(), goal.stringWithCommas)
    }
    
    var todayStepsProgressString: String {
        return String(format: "%@/%@\nsteps".localized(), todaysData.stepCount.stringWithCommas, goal.stringWithCommas)
    }
    
    var todayStepsProgressValue: Double {
        let progress = todaysData.stepCount/Double(goal)
        return progress > 1 ? 1 : progress
    }
    
    var todayDistanceStringValue: String {
        //return String(format: "%.2f km".localized(), todaysData.distance)
        let data = Self.distanceValueInLocal(distanceInKm: todaysData.distance)
//        return "\(data.value) \(data.unit)"
        return "\(data.value)"
    }
    
    var todayDistanceTypeStringValue: String {
        //return String(format: "%.2f km".localized(), todaysData.distance)
        let data = Self.distanceValueInLocal(distanceInKm: todaysData.distance)
        return "\(data.unit)"
    }
    
    var todayCalorieStringValue: String {
        //return String(format: "%.0f kcal".localized(), todaysData.calorie)
//        return String(format: "%@ kcal".localized(), todaysData.calorie.stringWithCommas)
        return String(format: "%@".localized(), todaysData.calorie.stringWithCommas)
    }
    
    var todayTimeStringValue: String {
        return String(format: "%02d min".localized(), 0)
    }
    
    var todayPaceStringValue: String {
        return String(format: "%02d:%02d min/km".localized(), 0, 0)
    }
}

extension ARPedometerData {
    func updateDatas(_ datas: [ARPedometerDataModel]) {
        datas.forEach{ data in
            if let existingData = dataHistory.first(where: { $0.date == data.date }) {
                if data.stepCount > 0 {
                    existingData.stepCount = data.stepCount
                }
                if data.distance > 0 {
                    existingData.distance = data.distance
                }
                if data.calorie > 0 {
                    existingData.calorie = data.calorie
                }
            } else {
                dataHistory.append(data)
            }
        }
        print(self)
    }
    
    func getDataToSyncOnserver() -> String? {
        let todayDateStr = Date().pedometerDataSaveDateKey
        let dataToSync = dataHistory.filter{ $0.date != todayDateStr }
        if !dataToSync.isEmpty {
            let finalData = dataToSync.compactMap{ $0.toDictionary() }
            return finalData.jsonStringRepresentation
        } else {
            return nil
        }
    }
    
    func removeSyncedData() {
        let todayDateStr = Date().pedometerDataSaveDateKey
        dataHistory.removeAll(where: { $0.date != todayDateStr })
        lastSyncDate = Date()
        print(self)
    }
}

extension ARPedometerData: CustomStringConvertible {
    var description: String {
        var desc = ">>>> PedometerData : "
        desc += "\ndataHistory : "
        dataHistory.forEach{ print($0) }
        desc += "\ngoal : \(goal)"
        desc += "\nlastSyncDate : \(lastSyncDate)\n"
        return desc
    }
}

// MARK: - Utils methods
extension ARPedometerData {
    static func getCalories(from steps: Double) -> Double {
        //return steps * 0.4 //old formula
        
        //https://www.verywellfit.com/pedometer-steps-to-calories-converter-3882595
        //Your calories per step will depend on your weight and height. A typical 160-pound person of average height will burn about 40 calories per 1,000 steps. This is the equivalent of 0.04 calories per step
        return steps * 0.04
    }
    
    static func getDistanceInKm(from steps: Double) -> Double {
        //Solution 1
        //Determine your stride length using your height. While this is not as accurate as some other methods, it can give you a close estimate of your stride length. For women, simply multiply 0.413 by your height in centimeters. Men should multiply 0.415 by their height in centimeters. Round off the answer to the nearest whole number and this equals your stride length in centimeters.
        let strideInMetre = (Utils.getLoginUserHeightIncCM() * (kUserDefaults.isGenderFemale ? 0.413 : 0.415))/100
        let distanceInMeters = steps * strideInMetre
        return distanceInMeters/1000
        
        //Solution 2
        //Distance covered with a stride of length 0.762 metre or 2.5 feet is mathematically defined as 1 unit of step.
        //let distanceInMeters = steps * 0.762
        //return distanceInMeters/1000
    }
    
    static func distanceValueInLocal(distanceInKm: Double) -> (value: String, unit: String) {
        let distanceInMeters = distanceInKm * 1000
        let distanceMeters = Measurement(value: distanceInMeters, unit: UnitLength.meters)

        if Locale.current.usesMetricSystem {
            return (distanceInKm.stringWithCommas, "km")
        } else {
            let miles = distanceMeters.converted(to: UnitLength.miles).value
            return (miles.stringWithCommas, "mile")
        }
        
//        let formatter = MeasurementFormatter()
//        formatter.unitOptions = .naturalScale
//        return formatter.string(from: Measurement(value: distanceInMeters, unit: UnitLength.meters)) // 0.621 mi
    }
}

// MARK: -
extension Date {
    var pedometerDataSaveDateKey: String {
        let df = DateFormatter()
        df.dateFormat = App.dateFormat.ddMMyyyy
        return df.string(from: self)
    }
    
}
extension Date {
    @available(iOS 13.0, *)
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
