//
//  FoodDemo+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Apple on 04/03/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(FoodDemo)
public class FoodDemo: NSManagedObject {
    
    class func createFoodData(dicData: [String: Any]) -> FoodDemo? {
        //change "id" with "favorite_id", bcoz "id" change in hindi language api and "favorite_id" will be remain same in all language api
        let id = dicData["favorite_id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("FoodDemo", uniqueKey: "id", value: id) as? FoodDemo else {
            return nil
        }
        
        entity.id = Int64(id)  ?? 0
        entity.foodType = dicData["food_types"] as? String ?? ""
        entity.image = dicData["image"] as? String ?? ""
        CoreDataHelper.sharedInstance.saveContext()
        
        return entity
    }
}
