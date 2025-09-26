//
//  FavouriteHerb+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 18/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import Foundation
import CoreData

@objc(FavouriteHerb)
public class FavouriteHerb: NSManagedObject {
    class func createHerbData(dicData: [String: Any]) -> FavouriteHerb? {
        let id = dicData["favorite_id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("FavouriteHerb", uniqueKey: "id", value: id) as? FavouriteHerb else {
            return nil
        }
        entity.id = Int64(id) ?? 0
        entity.category = dicData["category"] as? String ?? ""
        entity.categoryimage = dicData["categoryimage"] as? String ?? ""

        entity.herbs_name = dicData["herbs_name"] as? String ?? ""
        entity.star = dicData["star"] as? String ?? "no"
        entity.vertical_image = dicData["vertical_image"] as? String ?? ""
        entity.status = Int32(dicData["status"] as? String ?? "0") ?? 0
        entity.item_type = dicData["item_type"] as? String ?? ""
        let description = dicData["description"] as? String ?? ""
        entity.benefits = description.replacingOccurrences(of: "&nbsp;", with: " ")
        entity.url = dicData["url"] as? String ?? ""
        entity.image = dicData["image"] as? String ?? ""

        return entity
    }
}
