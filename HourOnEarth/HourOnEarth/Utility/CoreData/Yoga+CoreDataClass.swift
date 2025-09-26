//
//  Yoga+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/12/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Yoga)
public class Yoga: NSManagedObject {
    
    class func createYogaData(dicYoga: [String: Any], needToSave:Bool = true) -> Yoga? {
        //change "id" with "favorite_id", bcoz "id" change in hindi language api and "favorite_id" will be remain same in all language api
        let id = dicYoga["favorite_id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("Yoga", uniqueKey: "id", value: id) as? Yoga else {
            return nil
        }
        entity.id = Int32(id)  ?? 0
        entity.content_id = dicYoga["id"] as? String ?? ""
        entity.english_name = dicYoga["english_name"] as? String ?? ""
        entity.image_grey = dicYoga["image_grey"] as? String ?? ""
        entity.image = dicYoga["image"] as? String ?? ""
        entity.type = dicYoga["type"] as? String ?? ""
        entity.status = Int32(dicYoga["status"] as? String ?? "0") ?? 0 
        entity.name = dicYoga["name"] as? String ?? ""
        entity.video_duration = dicYoga["video_duration"] as? String ?? ""
        entity.video_link = dicYoga["video_link"] as? String ?? ""
        entity.descriptionYoga = dicYoga["description"] as? String ?? ""
        entity.star = dicYoga["star"] as? String ?? "no"
        entity.types_flag = dicYoga["types_flag"] as? String ?? ""
        entity.experiencelevel = dicYoga["experiencelevel"] as? String ?? ""
        entity.benefit_description = dicYoga["benefit_description"] as? String ?? ""
        entity.precautions = dicYoga["precautions"] as? String ?? ""
        entity.experiencelevel = dicYoga["experiencelevel"] as? String ?? ""
        entity.steps = dicYoga["steps"] as? String ?? ""
        entity.shortdescription = dicYoga["shortdescription"] as? String ?? ""
        entity.verticleimage = dicYoga["verticleimage"] as? String ?? ""
        entity.experiencelevelimage = dicYoga["experiencelevelimage"] as? String ?? ""
        entity.listids = dicYoga["listids"] as? String ?? ""
        entity.favorite_id = dicYoga["favorite_id"] as? String ?? ""
        let accessPoints = dicYoga["access_point"] as? String ?? ""
        entity.access_point = Int16(accessPoints) ?? 0
        entity.redeemed = dicYoga["redeemed"] as? Bool ?? false
        entity.watchStatus = dicYoga["watch_status"] as? Bool ?? false
        entity.is_video_watch = dicYoga["is_video_watch"] as? String ?? ""

        // ✅ Fix here
        if let benefits = dicYoga["benefits"] as? [[String: Any]], !benefits.isEmpty {
            for benefit in benefits {
                if let benefitEntity = Benefits.createBenefits(dic: benefit) {
                    entity.addToBenefits(benefitEntity)  // ✅ add one at a time
                }
            }
        }
        
//        if let benefits = dicYoga["benefits"] as? [[String: Any]]
//        {
//            var arrBenefits = [Benefits]()
//            for benefit in benefits {
//                if let entity =  Benefits.createBenefits(dic: benefit) {
//                    arrBenefits.append(entity)
//                }
//            }
//            entity.addToBenefits(NSSet(array: arrBenefits))
//        }
//        else
//        {
//            let arrBenefits = [Benefits]()
//            entity.addToBenefits(NSSet(array: arrBenefits))
//        }
        
        if needToSave {
            CoreDataHelper.sharedInstance.saveContext()
        }
        return entity
    }
    
    class func updateYogaForMyList(id: String, selectedList: String) {
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("Yoga", uniqueKey: "id", value: id) as? Yoga else {
            return
        }
        entity.listids = selectedList
        
        CoreDataHelper.sharedInstance.saveContext()
    }
    
}
