//
//  FavouriteYoga+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Apple on 14/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(FavouriteYoga)
public class FavouriteYoga: NSManagedObject {
    class func createYogaData(dicYoga: [String: Any]) -> FavouriteYoga? {
        //change "id" with "favorite_id", bcoz "id" change in hindi language api and "favorite_id" will be remain same in all language api
        let id = dicYoga["favorite_id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("FavouriteYoga", uniqueKey: "id", value: id) as? FavouriteYoga else {
            return nil
        }
        entity.id = Int32(id)  ?? 0
        entity.english_name = dicYoga["english_name"] as? String ?? ""
        entity.image = dicYoga["image"] as? String ?? ""
        entity.type = dicYoga["type"] as? String ?? ""
        entity.status = Int32(dicYoga["status"] as? String ?? "0") ?? 0
        entity.name = dicYoga["name"] as? String ?? ""
        entity.video_duration = dicYoga["video_duration"] as? String ?? ""
        entity.video_link = dicYoga["video_link"] as? String ?? ""
        entity.descriptionYoga = dicYoga["description"] as? String ?? ""
        entity.benefit_description = dicYoga["benefit_description"] as? String ?? ""
        entity.experiencelevel = dicYoga["experiencelevel"] as? String ?? ""
        entity.precautions = dicYoga["precautions"] as? String ?? ""
        entity.shortdescription = dicYoga["shortdescription"] as? String ?? ""
        entity.star = dicYoga["star"] as? String ?? "no"
        entity.steps = dicYoga["steps"] as? String ?? ""
        entity.verticleimage = dicYoga["verticleimage"] as? String ?? ""

        return entity
    }
}
