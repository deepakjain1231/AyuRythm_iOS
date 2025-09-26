//
//  Herb+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/14/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Herb)
public class Herb: NSManagedObject {
    class func createHerbData(dicData: [String: Any], needToSave:Bool = true) -> Herb? {
        //change "id" with "favorite_id", bcoz "id" change in hindi language api and "favorite_id" will be remain same in all language api
        let id = dicData["favorite_id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("Herb", uniqueKey: "id", value: id) as? Herb else {
            return nil
        }
        
        entity.id = Int64(id) ?? 0
        entity.herbs_name = dicData["herbs_name"] as? String ?? ""
        entity.star = dicData["star"] as? String ?? "no"
        entity.vertical_image = dicData["vertical_image"] as? String ?? ""
        entity.status = Int32(dicData["status"] as? String ?? "0") ?? 0
        entity.item_type = dicData["item_type"] as? String ?? ""
        let description = dicData["description"] as? String ?? ""
        entity.benefits = description.replacingOccurrences(of: "&nbsp;", with: " ")
        entity.image = dicData["image"] as? String ?? ""
        
        if needToSave {
            CoreDataHelper.sharedInstance.saveContext()
        }
        
        return entity
    }
}
