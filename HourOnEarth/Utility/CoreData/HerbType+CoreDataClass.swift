//
//  HerbType+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Apple on 04/03/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(HerbType)
public class HerbType: NSManagedObject {
    
    class func createHerbData(dicData: [String: Any]) -> HerbType? {
        //change "id" with "favorite_id", bcoz "id" change in hindi language api and "favorite_id" will be remain same in all language api
        let id = dicData["favorite_id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("HerbType", uniqueKey: "id", value: id) as? HerbType else {
            return nil
        }
        
        entity.id = Int64(id)  ?? 0
        entity.herbs_types = dicData["herbs_types"] as? String ?? ""
        entity.image = dicData["image"] as? String ?? ""
        CoreDataHelper.sharedInstance.saveContext()
        
        return entity
    }
}
