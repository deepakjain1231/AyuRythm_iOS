//
//  HomeRemediesDetail+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/18/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(HomeRemediesDetail)
public class HomeRemediesDetail: NSManagedObject {
    class func createHomeRemediesDetailData(dicData: [String: Any]) -> HomeRemediesDetail? {
        //change "id" with "favorite_id", bcoz "id" change in hindi language api and "favorite_id" will be remain same in all language api
        guard let id = dicData["favorite_id"] as? String, let entity = CoreDataHelper.sharedInstance.createEntityWithName("HomeRemediesDetail", uniqueKey: "id", value: id) as? HomeRemediesDetail else {
            return nil
        }
        entity.id = Int64(id) ?? 0
        entity.parent_id = dicData["parent_id"] as? String ?? ""
        entity.item = dicData["item"] as? String ?? ""
        entity.image = dicData["image"] as? String ?? ""
        entity.status = dicData["status"] as? String ?? ""
        entity.color = dicData["color"] as? String ?? ""
        return entity
    }
}
