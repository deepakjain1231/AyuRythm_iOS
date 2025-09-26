//
//  FoodFav+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 19/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import Foundation
import CoreData

@objc(FoodFav)
public class FoodFav: NSManagedObject {
    class func createFoodFavData(dicData: [String: Any]) {
        let id = dicData["id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("FoodFav", uniqueKey: "id", value: id) as? FoodFav else {
            return
        }

        entity.id = Int64(id) ?? 0
        entity.food_name = dicData["food_name"] as? String ?? ""
        entity.category = dicData["category"] as? String ?? ""
        entity.categoryimage = dicData["categoryimage"] as? String ?? ""
        entity.star = dicData["star"] as? String ?? "no"
        entity.vertical_image = dicData["vertical_image"] as? String ?? ""
        entity.status = Int32(dicData["status"] as? String ?? "0") ?? 0
        entity.season = dicData["season"] as? String ?? ""
        entity.food_type_id = dicData["food_type_id"] as? String ?? ""
        entity.item_type = dicData["item_type"] as? String ?? ""
        entity.benefits = dicData["benefits"] as? String ?? ""
        entity.ayurvedic_parameters = dicData["ayurvedic_parameters"] as? String ?? ""
        entity.food_status = dicData["food_status"] as? String ?? ""
        entity.url = dicData["url"] as? String ?? ""
        entity.image = dicData["image"] as? String ?? ""
 
        if let seasons = dicData["season"] as? [[String: Any]], !seasons.isEmpty {
            for seasons in seasons {
                if let seasonEntity = Seasons.createSeasonsData(dicData: seasons) {
                    entity.addToSeasons(seasonEntity)  // ✅ add one at a time
                }
            }
        }
        
//        if let seasons = dicData["seasons"] as? [[String: Any]]
//        {
//            var arrSeasons = [Seasons]()
//            for seasons in seasons {
//                if let entity =  Seasons.createSeasonsData(dicData: seasons) {
//                    arrSeasons.append(entity)
//                }
//            }
//            entity.addToSeasons(NSSet(array: arrSeasons))
//        }
//        else
//        {
//            let arrSeasons = [Seasons]()
//            entity.addToSeasons(NSSet(array: arrSeasons))
//        }
        
        if let arrWhen_to_eat = dicData["when_to_eat"] as? [[String: Any]], !arrWhen_to_eat.isEmpty {
            for when_to_eat in arrWhen_to_eat {
                if let when_to_eatEntity = When_to_eat.createWhen_to_eatData(dicData: when_to_eat) {
                    entity.addToWhen_to_eat(when_to_eatEntity)  // ✅ add one at a time
                }
            }
        }

//        if let when_to_eat = dicData["when_to_eat"] as? [[String: Any]]
//           {
//               var arrWhen_to_eat = [When_to_eat]()
//               for when_to_eat in when_to_eat {
//                   if let entity =  When_to_eat.createWhen_to_eatData(dicData: when_to_eat) {
//                       arrWhen_to_eat.append(entity)
//                   }
//               }
//               entity.addToWhen_to_eat(NSSet(array: arrWhen_to_eat))
//           }
//           else
//           {
//               let arrWhen_to_eat = [When_to_eat]()
//               entity.addToWhen_to_eat(NSSet(array: arrWhen_to_eat))
//           }
        
        CoreDataHelper.sharedInstance.saveContext()
    }
}
