//
//  FavouriteKriya+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 17/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import Foundation
import CoreData

@objc(FavouriteKriya)
public class FavouriteKriya: NSManagedObject {
    class func createKriyaData(dicData: [String: Any]) -> FavouriteKriya? {
        //change "id" with "favorite_id", bcoz "id" change in hindi language api and "favorite_id" will be remain same in all language api
        let id = dicData["favorite_id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("FavouriteKriya", uniqueKey: "id", value: id) as? FavouriteKriya else {
            return nil
        }
           entity.id = Int(id) ?? 0
            entity.english_name = dicData["english_name"] as? String ?? ""
            entity.image = dicData["image"] as? String ?? ""
            entity.type = dicData["type"] as? String ?? ""
            entity.status = Int32(dicData["status"] as? String ?? "0") ?? 0
            entity.name = dicData["name"] as? String ?? ""
            entity.video_duration = dicData["video_duration"] as? String ?? ""
            entity.video_link = dicData["video_link"] as? String ?? ""
            entity.descriptionKriya = dicData["description"] as? String ?? ""
            entity.star = dicData["star"] as? String ?? "no"
            entity.experiencelevel = dicData["experiencelevel"] as? String ?? ""
            entity.benefit_description = dicData["benefit_description"] as? String ?? ""
            entity.precautions = dicData["precautions"] as? String ?? ""
            entity.benefits_ids = dicData["benefits_ids"] as? String ?? ""
            entity.steps = dicData["steps"] as? String ?? ""
            entity.shortdescription = dicData["shortdescription"] as? String ?? ""
            entity.preparation = dicData["preparation"] as? String ?? ""
            entity.verticleimage = dicData["verticleimage"] as? String ?? ""
            entity.experiencelevelimage = dicData["experiencelevelimage"] as? String ?? ""

        return entity
    }
}
