//
//  ARWellnessPlanModel.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 02/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import CoreData

// MARK: -
class AyumonkBannerModel {
    var id : String = ""
    var title: String = ""
    var description: String = ""
}

class ARWellnessPlanModel{
    
    //var date : String!
    var diet : [ARWellnessDietSectionModel]!
    var dates : [ARWellnessDay]!
    var precautions : [ARDietItemModel]!
    var activity: [ARWellnessPlanActivityModel]!
    var isSubscription : Bool!
    var subscriptionHistoryId : String!
    var ayumonk_banner: AyumonkBannerModel?
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        //date = json["date"].stringValue
        dates = [ARWellnessDay]()
        let dateArray = json["date"].arrayValue
        for dateJson in dateArray{
            let value = ARWellnessDay(fromJson: dateJson)
            dates.append(value)
        }
        diet = [ARWellnessDietSectionModel]()
        let dietArray = json["diet"].arrayValue
        for dietJson in dietArray{
            let value = ARWellnessDietSectionModel(fromJson: dietJson)
            diet.append(value)
        }
        precautions = [ARDietItemModel]()
        let precautionsArray = json["precautions"].arrayValue
        for precautionsJson in precautionsArray{
            let value = ARDietItemModel(fromJson: precautionsJson)
            precautions.append(value)
        }
        
        let dic_ayumonk_banner = json["ayumonk_banner"]
        let banner = AyumonkBannerModel.init()
        banner.id = dic_ayumonk_banner["id"].string ?? ""
        banner.title = dic_ayumonk_banner["title"].string ?? ""
        banner.description = dic_ayumonk_banner["description"].string ?? ""
        ayumonk_banner = banner
        
        //Add different activities
        activity = [ARWellnessPlanActivityModel]()
        var dataArray = json["activity"]["yogasana"].arrayValue
        var dataArrayObj: [NSManagedObject] = dataArray.compactMap{ Yoga.createYogaData(dicYoga: $0.dictionaryObject ?? [:], needToSave: false) }
        activity.append(contentsOf: dataArrayObj.compactMap{ ARWellnessPlanActivityModel(managedObject: $0) })
        
        dataArray = json["activity"]["pranayam"].arrayValue
        dataArrayObj = dataArray.compactMap{ Pranayama.createPranayamaData(dicData: $0.dictionaryObject ?? [:], needToSave: false) }
        activity.append(contentsOf: dataArrayObj.compactMap{ ARWellnessPlanActivityModel(managedObject: $0) })
        
        dataArray = json["activity"]["meditation"].arrayValue
        dataArrayObj = dataArray.compactMap{ Meditation.createMeditationData(dicData: $0.dictionaryObject ?? [:], needToSave: false) }
        activity.append(contentsOf: dataArrayObj.compactMap{ ARWellnessPlanActivityModel(managedObject: $0) })
        
        dataArray = json["activity"]["mudra"].arrayValue
        dataArrayObj = dataArray.compactMap{ Mudra.createMudraData(dicData: $0.dictionaryObject ?? [:], needToSave: false) }
        activity.append(contentsOf: dataArrayObj.compactMap{ ARWellnessPlanActivityModel(managedObject: $0) })
        
        dataArray = json["activity"]["kriya"].arrayValue
        dataArrayObj = dataArray.compactMap{ Kriya.createKriyaData(dicData: $0.dictionaryObject ?? [:], needToSave: false) }
        activity.append(contentsOf: dataArrayObj.compactMap{ ARWellnessPlanActivityModel(managedObject: $0) })

        prepareData()
    }
}

class AlternaiveFoodModel {
    var status: String?
    var message: String?
    var data : [ARDietItemModel]?

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        status = json["status"].string ?? ""
        message = json["message"].string ?? ""
        data = [ARDietItemModel]()
        if let data_Array = json["data"].array {
            for dicJson in data_Array{
                let value = ARDietItemModel(fromJson: dicJson)
                data?.append(value)
            }
        }
    }
}



extension ARWellnessPlanModel {
    func prepareData() {
        //remove seen days from dates array
        dates.removeAll(where: { $0.status == 0 })
        //move all completed activity at bottom
        activity.sort(by: {!$0.isComplete && $1.isComplete})
    }
    
    var allDietSubSection: [ARDietSubSectionModel] {
        var data = [ARDietSubSectionModel]()
        diet.forEach { section in
            data.append(contentsOf: section.getAllDietSubSections())
        }
        return data
    }
}

// MARK: -
class ARWellnessDay{
    
    /*
     Status:
     0 - seen day
     1 - today
     2 - upcoming day
     */
    
    var date : String!
    var days : Int!
    var status : Int!
    var isLocked : Bool!
    var isSubscriptionPaused : Bool!
    var isSelcted = false
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        date = json["date"].stringValue
        days = json["days"].intValue
        isLocked = json["is_lock"].boolValue
        isSubscriptionPaused = json["is_pause"].boolValue
        status = json["status"].intValue
    }
    
}

extension ARWellnessDay {
    var dateValue: Date? {
        return date.UTCToLocalDate(incomingFormat: App.dateFormat.yyyyMMdd)
    }
    
    var isToday: Bool {
        return status == 1
    }
}
