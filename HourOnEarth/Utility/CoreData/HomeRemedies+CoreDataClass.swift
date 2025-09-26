//
//  HomeRemedies+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/18/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(HomeRemedies)
public class HomeRemedies: NSManagedObject {
    class func createHomeRemediesData(dicData: [String: Any]) {
        //change "id" with "favorite_id", bcoz "id" change in hindi language api and "favorite_id" will be remain same in all language api
        guard let id = dicData["favorite_id"] as? String, let entity = CoreDataHelper.sharedInstance.createEntityWithName("HomeRemedies", uniqueKey: "id", value: id) as? HomeRemedies else {
            return
        }
        entity.id = Int64(id) ?? 0
        entity.item = dicData["item"] as? String ?? ""
        entity.status = dicData["status"] as? String ?? ""
        entity.image = dicData["image"] as? String ?? ""
        entity.color = dicData["color"] as? String ?? ""
        
        let details = dicData["sub"] as? [[String: Any]] ?? []
        var arrRemedies = [HomeRemediesDetail]()
        for detail in details {
            if let entity =  HomeRemediesDetail.createHomeRemediesDetailData(dicData: detail) {
                arrRemedies.append(entity)
            }
        }
        entity.addToSubcategory( NSSet(array: arrRemedies))
        
        CoreDataHelper.sharedInstance.saveContext()
    }
}
