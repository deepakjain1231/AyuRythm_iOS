//
//  FavouriteHomeRemedies+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Apple on 14/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(FavouriteHomeRemedies)
public class FavouriteHomeRemedies: NSManagedObject {
    class func createHomeRemediesData(dicData: [String: Any]) -> FavouriteHomeRemedies? {
        //replace "desc_id" with "favorite_id", bcoz "favorite_id" will be same and unique in all language
        guard let desc_id = dicData["favorite_id"] as? String, let entity = CoreDataHelper.sharedInstance.createEntityWithName("FavouriteHomeRemedies", uniqueKey: "desc_id", value: desc_id) as? FavouriteHomeRemedies else {
            return nil
        }
        entity.desc_id = desc_id
        entity.createdate = dicData["createdate"] as? String ?? ""
        entity.descriptionDetail = dicData["description"] as? String ?? ""
        entity.updatedate = dicData["updatedate"] as? String ?? ""
        entity.remedies_id = dicData["remedies_id"] as? String ?? ""
        entity.subcategory = dicData["subcategory"] as? String ?? ""
        entity.option_name = dicData["option_name"] as? String ?? ""
        entity.category = dicData["category"] as? String ?? ""
        entity.categoryimage = dicData["categoryimage"] as? String ?? ""
        entity.colour = dicData["colour"] as? String ?? ""
        return entity
    }
}
