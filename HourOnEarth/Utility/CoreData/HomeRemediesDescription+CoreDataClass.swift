//
//  HomeRemediesDescription+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/18/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(HomeRemediesDescription)
public class HomeRemediesDescription: NSManagedObject {
    class func createHomeRemediesDescriptionData(dicData: [String: Any]) {
        //replace "desc_id" with "favorite_id", bcoz "favorite_id" will be same and unique in all language
        guard let desc_id = dicData["favorite_id"] as? String, let entity = CoreDataHelper.sharedInstance.createEntityWithName("HomeRemediesDescription", uniqueKey: "desc_id", value: desc_id) as? HomeRemediesDescription else {
            return
        }
        entity.desc_id = Int64(desc_id) ?? 0
        entity.createdate = dicData["createdate"] as? String ?? ""
        entity.discription = dicData["description"] as? String ?? ""
        entity.updatedate = dicData["updatedate"] as? String ?? ""
        entity.remedies_id = Int64(dicData["remedies_id"] as? String ?? "0") ?? 0
        entity.option_name = dicData["option_name"] as? String ?? ""
        entity.star = dicData["star"] as? String ?? "no"
        entity.colour = dicData["colour"] as? String ?? ""
        CoreDataHelper.sharedInstance.saveContext()
    }
}
