//
//  HealthKitManagerClass.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 28/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Foundation
import HealthKit

class HealthKitManager {
    
    static var HealthkitURL = "App-prefs:"
    static var stepPermissionNotFound = "No steps data found or check HealthKit Steps permissions from setting => Health => Data Access & Devices => AyuRythm App and Turn All Steps Categories On".localized()
    typealias HealthParametersCompletion = (_ heightInCmString: String?, _ weightInKgsString: String?, _ dob: String?, _ gender: String) -> Void
    let dispatchGroup = DispatchGroup()
    
    static let shared = HealthKitManager()
    var storage = HKHealthStore()
    
    var chekStatusDateOfBirth = false
    var chekStatusGender    = false
    var chekStatusHeight     = false
    var chekStatusWeight     = false
    
    init(){
        // self.checkAuthorization()
    }
    
    func checkAuthorization(completion:@escaping (_ isSuccess :Bool)-> Void){
        // Default to assuming that we're authorized
        
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable(){
            // We have to request each data type explicitly
            
            let healthkitTypesToRead = NSSet(array: [
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex) ?? "",
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height) ?? "",
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass) ?? "",HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth) ?? "",
            ])
            
            
            
            // Now we can request authorization for step count data
            storage.requestAuthorization(toShare: healthkitTypesToRead as? Set, read: healthkitTypesToRead as? Set) { (success, error) in
                
                print("error=",error as Any)
                
                DispatchQueue.main.async {
                    if error != nil {
                        // deal with the error
                        completion(false)
                        return
                    }
                    
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func checkAllPermission(completion:@escaping (_ isSuccess : Bool)-> Void){
        checkAuthorizationStatus(of: HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)) { (issuccess) in
            print(">> dateOfBirthCheckPermission : \(issuccess)")
            self.chekStatusDateOfBirth = issuccess
        }
        
        checkAuthorizationStatus(of: HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)) { (issuccess) in
            print(">> genderCheckPermission : \(issuccess)")
            self.chekStatusGender = issuccess
        }
        checkAuthorizationStatus(of: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)) { (issuccess) in
            print(">> heightrCheckPermission : \(issuccess)")
            self.chekStatusHeight = issuccess
        }
        checkAuthorizationStatus(of: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)) { (issuccess) in
            print(">> weightrCheckPermission : \(issuccess)")
            self.chekStatusWeight = issuccess
        }
        if self.chekStatusDateOfBirth == true && self.chekStatusGender == true && self.chekStatusHeight == true && self.chekStatusWeight == true{
            completion(true)
        }
        completion(false)
    }
    
    func checkAuthorizationStatus(of type: HKObjectType?, completion:@escaping (_ isSuccess : Bool)-> Void){
        guard let type = type else {
            completion(false)
            return
        }
        
        let status = storage.authorizationStatus(for: type)
        switch status {
        case .sharingAuthorized:
            completion(true)
        case .sharingDenied:
            completion(false)
        case .notDetermined:
            completion(false)
        default:
            completion(false)
        }
    }
    
    
    func healthDateOfBirth(completion:@escaping (_ dateOfBirthString : String)-> Void) {
        // Date of Birth
        guard let dateOfBirths = try? storage.dateOfBirthComponents() else {
            return completion("")
        }
        
        DispatchQueue.main.async {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            if let date = dateOfBirths.date {
                let dateString = dateFormatter.string(from: date)
                completion(dateString)
            } else {
                completion("")
            }
        }
    }
    
    func healthGender() -> String{
        let gender = try? (storage.biologicalSex() as AnyObject).biologicalSex == HKBiologicalSex.female ? "Female" : "Male"
        return gender ?? "Male"
    }
    
    func healthHeight(completion:@escaping (_ height : String)-> Void){
        // Height
        let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        
        let queryheight = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 100, sortDescriptors: nil) { (query, results, error) in
            DispatchQueue.main.async {
                if let result = results?.last as? HKQuantitySample {
                    completion("\(result.quantity)")
                } else {
                    completion("")
                }
            }
        }
        storage.execute(queryheight)
    }
    
    func healthWeight(completion:@escaping (_ weight : String)-> Void){
        //weight
        let bodyMass = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let queryweight = HKSampleQuery(sampleType: bodyMass, predicate: nil, limit: 100, sortDescriptors: nil) { (query, results, error) in
            DispatchQueue.main.async {
                if let result = results?.last as? HKQuantitySample{
                    completion("\(result.quantity)")
                }else{
                    completion("")
                }
            }
        }
        storage.execute(queryweight)
    }
    
    func openUrl(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let appSettingUrl = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(appSettingUrl, options: [:], completionHandler: nil)
        }
    }
    
    func showOpenHealthKitSettingAlert(fromVC: UIViewController?) {
        guard let fromVC = fromVC else {
            return
        }

        Utils.showAlertWithTitleInControllerWithCompletion(Healthkit, message: "You can turn on HealthKit permissions from setting => Health => Data Access & Devices => AyuRythm App and Turn All Categories On".localized(), cancelTitle: "Cancel".localized(), okTitle: "Go To".localized(), controller: fromVC, completionHandler: {
            self.openUrl(urlString: Self.HealthkitURL)
        }) {}
    }
}

// MARK: - Added by Paresh
extension HealthKitManager {
    func checkAuthorizationStatusAndGetHealthParameters(fromVC: UIViewController, isAllParamReqired: Bool = false, completion:@escaping HealthParametersCompletion){
        checkAuthorization { isSuccess in
            if isSuccess {
                fromVC.showActivityIndicator()
                self.getHealthParameters { heightInCmString, weightInKgsString, dob, gender in
                    fromVC.hideActivityIndicator()
                    if !isAllParamReqired, heightInCmString == nil, weightInKgsString == nil, dob == nil {
                        //all params are nil means user not fiven healthkit permission, show alert
                        self.showOpenHealthKitSettingAlert(fromVC: fromVC)
                    } else {
                        let debugString = String(format: ">>> heightInCmString : %@\nweightInKgsString : %@\ndob : %@\ngender : %@", heightInCmString ?? "", weightInKgsString ?? "", dob ?? "", gender)
                        print(debugString)
                        completion(heightInCmString, weightInKgsString, dob, gender)
                    }
                }
            } else {
                self.showOpenHealthKitSettingAlert(fromVC: fromVC)
            }
        }
    }
    
    func getHealthParameters(completion: @escaping HealthParametersCompletion) {
        var heightInCmString: String?
        var weightInKgsString: String?
        var dob: String?
        let gender = self.healthGender()
        
        dispatchGroup.enter()
        self.healthHeight { (height) in
            //Height in cm
            if !height.isEmpty {
                heightInCmString = String(height.dropLast(1)) == "m" ? "\(Int(String(height.dropLast(3)))! * 100)":  String(height.dropLast(1)) == "ft" ? "\(Double(String(height.dropLast(3)))! * 30.48)" : String(height.dropLast(3))
            }
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.healthWeight { (weight) in
            //Weight in Kgs
            if !weight.isEmpty {
                let lbsString = String(weight.dropLast(3))
                let stString = String(weight.dropLast(2))
                weightInKgsString = lbsString == "lbs" ? Utils.convertPoundsToKg(lb: String(weight.dropLast(4))) : stString == "st" ? "\(Double(String(weight.dropLast(3)))! * 6.35029)" : String(weight.dropLast(3))
            }
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.healthDateOfBirth { (dateOfBirth) in
            //DOB in "dd-MM-yyyy"
            if !dateOfBirth.isEmpty {
                dob = dateOfBirth
            }
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(heightInCmString, weightInKgsString, dob, gender)
        }
    }
}

extension HealthKitManager {
    func checkPermissionForStepsAndGetSteps(fromVC: UIViewController?, forDate: Date = Date(), completion:@escaping (Double) -> Void){
        checkPermissionForSteps { isSuccess in
            if isSuccess {
                self.getStepsCount(forSpecificDate: forDate, completion: completion)
                /*self.checkAuthorizationStatus(of: HKQuantityType.quantityType(forIdentifier: .stepCount)) { (issuccess) in
                    print(">> Steps Authorization Status : \(issuccess)")
                    if issuccess {
                        self.getStepsCount(forSpecificDate: forDate, completion: completion)
                    } else {
                        self.showOpenHealthKitSettingAlert(fromVC: fromVC)
                    }
                }*/
            } else {
                self.showOpenHealthKitSettingAlert(fromVC: fromVC)
            }
        }
    }
    
    func checkPermissionForSteps(completion:@escaping (_ isSuccess :Bool)-> Void) {
        DispatchQueue.delay(.microseconds(100)) {
            guard HKHealthStore.isHealthDataAvailable() else {
                completion(false)
                return
            }
            
            let stepsCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            let burntCalorie = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
            let distance = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
            let parmissionSet: Set = [stepsCount, burntCalorie, distance]
            self.storage.requestAuthorization(toShare: nil, read: parmissionSet) { (success, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        // deal with the error
                        completion(false)
                        return
                    }
                    
                    print("Permission \(success).")
                    completion(success)
                }
            }
        }
    }
        
    func checkPermissionForStepsOld(completion:@escaping (_ isSuccess :Bool)-> Void) {
        DispatchQueue.delay(.microseconds(100)) {
            guard HKHealthStore.isHealthDataAvailable() else {
                completion(false)
                return
            }
            
            let stepsCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            self.storage.requestAuthorization(toShare: [], read: [stepsCount]) { (success, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        // deal with the error
                        completion(false)
                        return
                    }
                    
                    print("Permission \(success).")
                    completion(success)
                }
            }
        }
    }
    
    func getStepsCount(forSpecificDate:Date, completion: @escaping (Double) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let (start, end) = self.getWholeDate(date: forSpecificDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            DispatchQueue.main.async {
                guard let result = result, let sum = result.sumQuantity() else {
                    completion(0.0)
                    return
                }
                completion(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        self.storage.execute(query)
    }
    
    func getWholeDate(date : Date) -> (startDate:Date, endDate: Date) {
        var startDate = date
        var length = TimeInterval()
        _ = Calendar.current.dateInterval(of: .day, start: &startDate, interval: &length, for: startDate)
        let endDate:Date = startDate.addingTimeInterval(length)
        return (startDate,endDate)
    }
}

extension HealthKitManager {
    
    typealias PedometerDataCompletion = (_ startDate: Date, _ endDate: Date, _ data: [ARPedometerDataModel]) -> Void
    /*
     fetchPedometerData - fetch pedometer data like steps, distance and calorie from healthkit
     =====================================
     duration: over what time period (0 is all time, rest is number of days to include, 1 means today data)
     completion: run completed code when done
     */
    func fetchPedometerData(startDate: Date = Date(), endDate: Date = Date(), completion: @escaping PedometerDataCompletion) {
        let stepsCount = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let burntCalorie = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let parmissionSet: Set = [stepsCount, burntCalorie, distance]
        let data = ARPedometerDataModel.emptyModel()
        
        getRequestPermissionStatus(read: parmissionSet) { success in
            if success {
                self.requestPermission(read: parmissionSet) { success in
                    guard success else {
                        print(">>> No Permission: \(success).")
                        DispatchQueue.main.async {
                            completion(startDate, endDate, [data])
                        }
                        return
                    }
                    self.readPedometerData(startDate: startDate, endDate: endDate, completion: completion)
                }
            } else {
                self.readPedometerData(startDate: startDate, endDate: endDate, completion: completion)
            }
        }
    }
    
    fileprivate func readPedometerData(startDate: Date, endDate: Date, completion: @escaping PedometerDataCompletion) {
        
        var datas = [ARPedometerDataModel]()
        let dispatchGroup = DispatchGroup()
        let dateRange = Date.dateRange(from: startDate, to: endDate)
        dateRange.forEach { date in
            dispatchGroup.enter()
            readPedometerData(date: date) { startD, data in
                datas.append(data)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(startDate, endDate, datas)
        }
    }
    
    fileprivate func readPedometerData(date: Date, completion: @escaping (_ startDate: Date, _ data: ARPedometerDataModel) -> Void) {
        let data = ARPedometerDataModel.emptyModel()
        let dispatchGroup = DispatchGroup()
        let newStartDate = date.startOfDay
        let newEndDate = date.endOfDay
        // Activity totals
        dispatchGroup.enter()
        self.fetchDataWithDateRange(identifier: HKObjectType.quantityType(forIdentifier: .stepCount)!, unit: "count", startDate: newStartDate, endDate: newEndDate) { value in
            print("Steps: \(value)")
            data.stepCount = value
            dispatchGroup.leave()
        }
        // Burnt Calorie
        dispatchGroup.enter()
        self.fetchDataWithDateRange(identifier: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!, unit: "kcal", startDate: newStartDate, endDate: newEndDate) { value in
            print("Burnt Calorie: \(value) kcal")
            data.calorie = value
            dispatchGroup.leave()
        }
        // Walking
        dispatchGroup.enter()
        self.fetchDataWithDateRange(identifier: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, unit: "meter", startDate: newStartDate, endDate: newEndDate) { value in
            print("Distance: \(value) meter")
            data.distance = value/1000
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            data.date = date.pedometerDataSaveDateKey
            data.goal = ARPedometerManager.shared.pedometerData.goal
            
            //Manual data entry by formula
            if data.calorie == 0 {
                data.calorie = ARPedometerData.getCalories(from: data.stepCount)
            }
            
            completion(date, data)
        }
    }
    
    func requestPermission(toShare typesToShare: Set<HKSampleType>? = nil, read typesToRead: Set<HKObjectType>?, completion:@escaping (_ isSuccess :Bool)-> Void) {
        DispatchQueue.delay(.microseconds(100)) {
            guard HKHealthStore.isHealthDataAvailable() else {
                completion(false)
                return
            }
            
            self.storage.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print(">>> ERROR: \(error)")
                        completion(false)
                    } else {
                        print(">>> Permission: \(success).")
                        completion(success)
                    }
                }
            }
        }
    }
    
    func getRequestPermissionStatus(toShare typesToShare: Set<HKSampleType>? = nil, read typesToRead: Set<HKObjectType>?, completion:@escaping (_ isSuccess :Bool)-> Void) {
        DispatchQueue.delay(.microseconds(100)) {
            guard HKHealthStore.isHealthDataAvailable() else {
                completion(false)
                return
            }
            
            if #available(iOS 12.0, *) {
                self.storage.getRequestStatusForAuthorization(toShare: typesToShare ?? [], read: typesToRead ?? []) { status, error in
                    print(">>> status : \(status), error : ", error)
                    if status != .unnecessary {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                // Fallback on earlier versions
                completion(true)
            }
        }
    }
    
    /*
     fetchData - fetch data from healthkit
     =====================================
     identifier: property to fetch
     unit: measuring unit to return result in
     duration: over what time period (0 is all time, rest is number of days to include)
     completion: run completed code when done
     */
    private func fetchData(identifier: HKQuantityType, unit: String, duration: Int, completion: @escaping (_ value: Double) -> ()){
        let calendar = NSCalendar.current
        let interval = NSDateComponents()
        interval.day = 1
        
        var anchorComponents = calendar.dateComponents([.day, .month, .year], from: NSDate() as Date)
        anchorComponents.hour = 0
        let anchorDate = calendar.date(from: anchorComponents)
        
        // Define 1-day intervals starting from 0:00
        let stepsQuery = HKStatisticsCollectionQuery(quantityType: identifier, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate!, intervalComponents: interval as DateComponents)
        
        // Set the results handler
        stepsQuery.initialResultsHandler = {query, results, error in
            let endDate = NSDate()
            
            var startDate  = Date()
            
            if(duration == 0) {
                startDate = Date(timeIntervalSince1970: 0)
            } else {
                startDate = Date().addingTimeInterval(TimeInterval(-3600 * 24 * duration))
            }
            
            var total = 0.0
            
            if let myResults = results{
                myResults.enumerateStatistics(from: startDate, to: endDate as Date) { statistics, stop in
                    if let quantity = statistics.sumQuantity(){
                        //                        print(statistics)
                        
                        var value: Double = 0
                        
                        switch(unit) {
                        case "count":
                            value = quantity.doubleValue(for: HKUnit.count())
                        case "hour":
                            value = quantity.doubleValue(for: HKUnit.hour())
                        case "meter":
                            value = quantity.doubleValue(for: HKUnit.meter())
                        case "mile":
                            value = quantity.doubleValue(for: HKUnit.mile())
                        case "kcal":
                            value = quantity.doubleValue(for: HKUnit.kilocalorie())
                        case "km":
                            value = quantity.doubleValue(for: HKUnit.meter())/1000
                        default:
                            print("Error unit not specified")
                            fatalError("Unit not specified")
                        }
                        
                        total += value
                        // Get date for each day if required
                        //let date = statistics.endDate
                        //print("\(date): value = \(value)")
                    }
                } //end block
                completion(total) // return after loop has ran
            } //end if let
        }
        storage.execute(stepsQuery)
    }
    
    private func fetchDataWithDateRange(identifier: HKQuantityType, unit: String, startDate: Date, endDate: Date, completion: @escaping (_ value: Double) -> ()){
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        //print(">>> startDate : \(startDate) - endDate : \(endDate)")
        let query = HKStatisticsQuery(quantityType: identifier, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            var total = 0.0
            
            guard let result = result, let sum = result.sumQuantity() else {
                completion(total)
                return
            }
            
            switch(unit) {
            case "count":
                total = sum.doubleValue(for: HKUnit.count())
            case "hour":
                total = sum.doubleValue(for: HKUnit.hour())
            case "meter":
                total = sum.doubleValue(for: HKUnit.meter())
            case "mile":
                total = sum.doubleValue(for: HKUnit.mile())
            case "kcal":
                total = sum.doubleValue(for: HKUnit.kilocalorie())
            default:
                print("Error unit not specified")
                fatalError("Unit not specified")
            }
            
            completion(total)
        }
        
        self.storage.execute(query)
    }
}

extension HealthKitManager {
    enum ARHealthSampleType {
        case stepCount
        case distance
        case energy
        
        var sampleType: HKObjectType {
            switch self {
            case .stepCount:
                return HKObjectType.quantityType(forIdentifier: .stepCount)!
            case .distance:
                return HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
            case .energy:
                return HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
            }
        }
        
        var unitType: HKUnit {
            switch self {
            case .stepCount:
                return HKUnit.count()
            case .distance:
                return HKUnit.meter()
            case .energy:
                return HKUnit.kilocalorie()
            }
        }
    }
    
    typealias ARPedometerDataFetchCompletion = (_ isUpdate: Bool, _ data: [ARPedometerDataModel]) -> Void
    
    func fetchLatestPedometerData(fromDate: Date = Date(), completion: @escaping ARPedometerDataFetchCompletion) {
        let parmissionSet: Set = [ARHealthSampleType.stepCount.sampleType, ARHealthSampleType.distance.sampleType/*, ARHealthSampleType.distance.sampleType, ARHealthSampleType.energy.sampleType*/]
        
        getRequestPermissionStatus(read: parmissionSet) { success in
            if success {
                self.requestPermission(read: parmissionSet) { success in
                    guard success else {
                        print(">>> No Permission: \(success).")
                        DispatchQueue.main.async {
                            completion(false, [ARPedometerDataModel.emptyModel()])
                        }
                        return
                    }
                    self.readPedometerData(fromDate: fromDate, completion: completion)
                }
            } else {
                self.readPedometerData(fromDate: fromDate, completion: completion)
            }
        }
    }
    
    fileprivate func readPedometerData(fromDate: Date, completion: @escaping ARPedometerDataFetchCompletion) {
        
        getSampleDataFor(fromDate: fromDate, sampleType: .stepCount) { sampleType, isUpdate, values in
            print("### final setp count data arrives : \(values)")
            self.createDataSourcseArray(sampleType, isUpdate, values, completion: completion)
        }
        
        getSampleDataFor(fromDate: fromDate, sampleType: .distance) { sampleType, isUpdate, values in
            print("### final distance data arrives : \(values)")
            self.createDataSourcseArray(sampleType, isUpdate, values, completion: completion)
        }
        
        /*getSampleDataFor(fromDate: fromDate, sampleType: .distance) { sampleType, isUpdate, values in
            print("### final distance data arrives : \(values)")
            self.createDataSourcseArray(sampleType, isUpdate, values, completion: completion)
        }
        
        getSampleDataFor(fromDate: fromDate, sampleType: .energy) { sampleType, isUpdate, values in
            print("### final energy data arrives : \(values)")
            self.createDataSourcseArray(sampleType, isUpdate, values, completion: completion)
        }*/
    }
    
    fileprivate func createDataSourcseArray(_ sampleType: ARHealthSampleType, _ isUpdate: Bool, _ values: [String: Double], completion: @escaping ARPedometerDataFetchCompletion) {
        var pedoDatas = [ARPedometerDataModel]()
        for (key, value) in values {
            let pedoData = ARPedometerDataModel.emptyModel()
            pedoData.date = key
            switch sampleType {
            case .stepCount:
                pedoData.stepCount = value
            case .distance:
                pedoData.distance = value/1000
            case .energy:
                pedoData.calorie = value
            }
            pedoDatas.append(pedoData)
        }
        DispatchQueue.main.async {
            completion(isUpdate, pedoDatas)
        }
    }
    
    fileprivate typealias ARDataFetchCompletion = (_ sampleType: ARHealthSampleType, _ isUpdate: Bool, _ values: [String: Double])-> Void
    fileprivate func getSampleDataFor(fromDate: Date, sampleType: ARHealthSampleType, completion:@escaping ARDataFetchCompletion){
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = 1

        var otherDateComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        otherDateComponents.hour = 0
        let anchorDate = calendar.date(from: otherDateComponents)
        
        otherDateComponents = calendar.dateComponents([.day, .month, .year], from: fromDate)
        otherDateComponents.hour = 0
        let fromDateStart = calendar.date(from: otherDateComponents) ?? fromDate

        let stepsCumulativeQuery = HKStatisticsCollectionQuery(quantityType: sampleType.sampleType as! HKQuantityType, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate!, intervalComponents: dateComponents
        )

        // Set the results handler
        stepsCumulativeQuery.initialResultsHandler = {query, results, error in
            self.enumerateStatisticsDataFor(sampleType: sampleType, fromDate: fromDateStart, results: results, completion: completion)
        }
        // Set the data update handler
        stepsCumulativeQuery.statisticsUpdateHandler = {query, statistics, results, error in
            self.enumerateStatisticsDataFor(sampleType: sampleType, results: results, isUpdate: true, completion: completion)
        }
        HKHealthStore().execute(stepsCumulativeQuery)
    }
    
    fileprivate func enumerateStatisticsDataFor(sampleType: ARHealthSampleType, fromDate: Date = Date(), toDate: Date = Date(), results: HKStatisticsCollection?, isUpdate: Bool = false, completion: @escaping ARDataFetchCompletion) {
        var datas = [String: Double]()
        if let myResults = results{
            myResults.enumerateStatistics(from: fromDate, to: toDate as Date) { statistics, stop in
                if let quantity = statistics.sumQuantity(){
                    let dateStr = statistics.startDate.pedometerDataSaveDateKey
                    let value = quantity.doubleValue(for: sampleType.unitType)
                    datas[dateStr] = value
                    //print("### type: \(sampleType) - \(dateStr): value = \(value)")
                }
            }
            //print("### datas : ", datas)
            completion(sampleType, isUpdate, datas)
        }
    }
}
