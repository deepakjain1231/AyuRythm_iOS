//
//  Food+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/14/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Food)
public class Food: NSManagedObject {
    class func createFoodData(dicData: [String: Any], needToSave:Bool = true) -> Food? {
        //change "id" with "favorite_id", bcoz "id" change in hindi language api and "favorite_id" will be remain same in all language api
        let id = dicData["favorite_id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("Food", uniqueKey: "id", value: id) as? Food else {
            return nil
        }
        
        entity.id = Int64(id) ?? 0
        entity.food_name = dicData["food_name"] as? String ?? ""
        entity.star = dicData["star"] as? String ?? "no"
        entity.vertical_image = dicData["vertical_image"] as? String ?? ""
        entity.status = Int32(dicData["status"] as? String ?? "0") ?? 0
        entity.season = dicData["season"] as? String ?? ""
        entity.food_type_id = dicData["food_type_id"] as? String ?? ""
        entity.item_type = dicData["item_type"] as? String ?? ""
        entity.food_properties = dicData["food_properties"] as? String ?? ""
        entity.benefits = dicData["benefits"] as? String ?? ""
        entity.ayurvedic_parameters = dicData["ayurvedic_parameters"] as? String ?? ""
        entity.food_status = dicData["food_status"] as? String ?? ""
        entity.url = dicData["url"] as? String ?? ""
        entity.image = dicData["image"] as? String ?? ""
 
        //Save seasons
        var arrSeasons = [Seasons]()
        if let savedSeasons = entity.seasons?.allObjects as? [Seasons] {
            arrSeasons.append(contentsOf: savedSeasons)
        }
        if let seasons = dicData["seasons"] as? [[String: Any]] {
            for seasons in seasons {
                if let entity =  Seasons.createSeasonsData(dicData: seasons) {
                    if arrSeasons.first(where: { $0.id == entity.id }) == nil {
                        arrSeasons.append(entity)
                    }
                }
            }
        }
        entity.addToSeasons(NSSet(array: arrSeasons))
        

        //Save when to eat
        var arrWhen_to_eat = [When_to_eat]()
        if let savedWhen_to_eat = entity.when_to_eat?.allObjects as? [When_to_eat] {
            arrWhen_to_eat.append(contentsOf: savedWhen_to_eat)
        }
        if let when_to_eat = dicData["when_to_eat"] as? [[String: Any]] {
            for when_to_eat in when_to_eat {
                if let entity =  When_to_eat.createWhen_to_eatData(dicData: when_to_eat) {
                    if arrWhen_to_eat.first(where: { $0.id == entity.id }) == nil {
                        arrWhen_to_eat.append(entity)
                    }
                }
            }
        }
        entity.addToWhen_to_eat(NSSet(array: arrWhen_to_eat))
        
        if needToSave {
            CoreDataHelper.sharedInstance.saveContext()
        }
        
        return entity
    }
}
