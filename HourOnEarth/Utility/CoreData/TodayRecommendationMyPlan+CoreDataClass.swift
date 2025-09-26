//
//  TodayRecommendationMyPlan+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Apple on 12/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

enum TodayRecommendationType: String {
    case yoga
    case fruit
}

@objc(TodayRecommendationMyPlan)
public class TodayRecommendationMyPlan: NSManagedObject {
    
    class func createYogaRecommendation(dicYoga: [String: Any]) {
        let id = dicYoga["id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("TodayRecommendationMyPlan", uniqueKey: "yogaId", value: id) as? TodayRecommendationMyPlan else {
            return
        }
        entity.yogaId = Int64(id) ?? 0
        entity.english_name = dicYoga["english_name"] as? String ?? ""
        entity.image = dicYoga["image"] as? String ?? ""
        entity.type = dicYoga["type"] as? String ?? ""
        entity.status = Int64(dicYoga["status"] as? Int ?? 0)
        entity.name = dicYoga["name"] as? String ?? ""
        entity.video_duration = dicYoga["video_duration"] as? String ?? ""
        entity.video_link = dicYoga["video_link"] as? String ?? ""
        entity.descriptionYoga = dicYoga["description"] as? String ?? ""
        entity.recommendationType = TodayRecommendationType.yoga.rawValue
        CoreDataHelper.sharedInstance.saveContext()
    }
    
    class func createFruitsRecommendation(dicData: [String: Any]) {
        let id = dicData["id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("TodayRecommendationMyPlan", uniqueKey: "foodId", value: id) as? TodayRecommendationMyPlan else {
            return
        }
        entity.foodId = Int64(id)  ?? 0
        entity.food_name = dicData["food_name"] as? String ?? ""
        entity.food_status = dicData["food_status"] as? String ?? ""
        entity.image = dicData["image"] as? String ?? ""
        entity.food_type_id = Int64(dicData["food_type_id"] as? Int ?? 0)
        entity.status = Int64(dicData["status"] as? Int ?? 0)
        entity.url = dicData["url"] as? String ?? ""
        entity.item_type = dicData["item_type"] as? String ?? ""
        entity.recommendationType = TodayRecommendationType.fruit.rawValue
        CoreDataHelper.sharedInstance.saveContext()
    }
    
}
