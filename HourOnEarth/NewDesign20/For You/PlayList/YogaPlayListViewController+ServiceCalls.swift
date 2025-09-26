//
//  YogaPlayListViewController+ServiceCalls.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 16/09/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

extension YogaPlayListViewController {
    
    func fetchDataFromServer(type: IsSectionType, completion: @escaping ()->Void) {
        if type == .yoga {
            getYogaFromServer(goal_type: .Yogasana, completion: completion)
        }
        else if type == .pranayama {
            getYogaFromServer(goal_type: .Pranayama, completion: completion)
        }
        else if type == .meditation {
            getYogaFromServer(goal_type: .Meditation, completion: completion)
        }
        else if type == .mudra {
            getYogaFromServer(goal_type: .Mudras, completion: completion)
        }
        else if type == .kriya {
            getYogaFromServer(goal_type: .Kriyas, completion: completion)
        }
    }
    
//    func getYogaFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            let urlString = kBaseNewURL + endPoint.getForYouYoga.rawValue
//            let params = ["type": recommendationVikriti, "language_id" : Utils.getLanguageId()] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print(response)
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    let dataArray = arrResponse.compactMap{ Yoga.createYogaData(dicYoga: $0) }.sorted(by: {$0.access_point < $1.access_point})
//                    self.yogaArray = dataArray
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController("", message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            getYogaDataFromDB()
//            completion()
//        }
//    }
    
//    func getPranayamaFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            let urlString = kBaseNewURL + endPoint.getPranayamaios.rawValue
//            let params = ["type": recommendationVikriti, "language_id" : Utils.getLanguageId()] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print(response)
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Pranayama")
//                    let dataArray = arrResponse.compactMap{ Pranayama.createPranayamaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
//                    self.pranayamaArray = dataArray
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            self.getPranayamaDataFromDB()
//            completion()
//        }
//    }
    
//    func getMeditationFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            let urlString = kBaseNewURL + endPoint.getMeditationios.rawValue
//            let params = ["type": recommendationVikriti, "language_id" : Utils.getLanguageId()] as [String : Any]
//            
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print(response)
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Meditation")
//                    let dataArray = arrResponse.compactMap{ Meditation.createMeditationData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
//                    self.meditationArray = dataArray
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            self.getMeditationDataFromDB()
//            completion()
//        }
//    }
    
//    func getMudraFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            let urlString = kBaseNewURL + endPoint.getMudraios.rawValue
//            let params = ["type": recommendationVikriti, "language_id" : Utils.getLanguageId()] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print(response)
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Mudra")
//                    let dataArray = arrResponse.compactMap{ Mudra.createMudraData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
//                    self.mudraArray = dataArray
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            self.getMudraDataFromDB()
//            completion()
//        }
//    }
    
    
//    func getKriyaFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            let urlString = kBaseNewURL + endPoint.getKriyaios.rawValue
//            let params = ["type": recommendationVikriti, "language_id" : Utils.getLanguageId()] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print(response)
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Kriya")
//                    let dataArray = arrResponse.compactMap{ Kriya.createKriyaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
//                    self.kriyaArray = dataArray
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            self.getKriyaDataFromDB()
//            completion()
//        }
//    }
}

//MARK: Database calls
extension YogaPlayListViewController {
    func getYogaDataFromDB() {
        let predicate = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        guard let arrYoga = CoreDataHelper.sharedInstance.getListOfEntityWithName("Yoga", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Yoga] else {
            return
        }
        
        let arrSorted = arrYoga.sorted { (obj1, obj2) -> Bool in
            return obj1.access_point < obj2.access_point
        }
        self.yogaArray = arrSorted
    }
    
    func getPranayamaDataFromDB() {
        let predicate = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        guard let arrPrananyam = CoreDataHelper.sharedInstance.getListOfEntityWithName("Pranayama", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Pranayama] else {
            return
        }
        
        let arrSorted = arrPrananyam.sorted { (obj1, obj2) -> Bool in
            return obj1.access_point < obj2.access_point
        }

        self.pranayamaArray = arrSorted
    }
    
    func getMeditationDataFromDB() {
        let predicate = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        guard let arrMeditation = CoreDataHelper.sharedInstance.getListOfEntityWithName("Meditation", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Meditation] else {
            return
        }
        let arrSorted = arrMeditation.sorted { (obj1, obj2) -> Bool in
            return obj1.access_point < obj2.access_point
        }

        self.meditationArray = arrSorted
    }
    
    func getMudraDataFromDB() {
        let predicate = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        guard let arrMudra = CoreDataHelper.sharedInstance.getListOfEntityWithName("Mudra", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Mudra] else {
            return
        }
        self.mudraArray = arrMudra
    }
    
    func getKriyaDataFromDB() {
        let predicate = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        guard let arrKriya = CoreDataHelper.sharedInstance.getListOfEntityWithName("Kriya", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Kriya] else {
            return
        }
        self.kriyaArray = arrKriya
    }
}



//MARK: - API Call
extension YogaPlayListViewController {
    
    func getYogaFromServer (goal_type: TodayGoal_Type, completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.getKriyaiOS_NewAPI.rawValue
            
            var params = ["from": "foryou",
                          "today_keys": "",//Video fav ID from Todaysgoal api
                          "list_type": "",
                          "type": recommendationVikriti.rawValue,
                          "typetwo": Utils.getYourCurrentPrakritiStatus().rawValue,
                          "language_id" : Utils.getLanguageId()] as [String : Any]
            
#if !APPCLIP
        params["type"] = appDelegate.cloud_vikriti_status
#endif
            
            if goal_type == .Yogasana {
                params["list_type"] = "yogasana"
            }
            else if goal_type == .Pranayama {
                params["list_type"] = "pranayam"
            }
            else if goal_type == .Meditation {
                params["list_type"] = "meditation"
            }
            else if goal_type == .Kriyas {
                params["list_type"] = "kriya"
            }
            else if goal_type == .Mudras {
                params["list_type"] = "mudra"
            }
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let arrResponse = (value as? [[String: Any]]) else {
                        completion()
                        return
                    }
                    if goal_type == .Yogasana {

                        let dataArray = arrResponse.compactMap{ Yoga.createYogaData(dicYoga: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        self.yogaArray = dataArray

                    }
                    else if goal_type == .Pranayama {
                        
                        let dataArray = arrResponse.compactMap{ Pranayama.createPranayamaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        self.pranayamaArray = dataArray
                        
                    }
                    else if goal_type == .Meditation {

                        let dataArray = arrResponse.compactMap{ Meditation.createMeditationData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        self.meditationArray = dataArray
                        
                    }
                    else if goal_type == .Kriyas {

                        let dataArray = arrResponse.compactMap{ Kriya.createKriyaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        self.kriyaArray = dataArray
                        
                    }
                    else if goal_type == .Mudras {
                        
                        let dataArray = arrResponse.compactMap{ Mudra.createMudraData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        self.mudraArray = dataArray

                    }

                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                completion()
            }
        } else {
            if goal_type == .Yogasana {
                getYogaDataFromDB()
            }
            else if goal_type == .Pranayama {
                self.getPranayamaDataFromDB()
            }
            else if goal_type == .Meditation {
                self.getMeditationDataFromDB()
            }
            else if goal_type == .Kriyas {
                self.getKriyaDataFromDB()
            }
            else if goal_type == .Mudras {
                self.getMudraDataFromDB()
            }
            completion()
        }
    }
}
