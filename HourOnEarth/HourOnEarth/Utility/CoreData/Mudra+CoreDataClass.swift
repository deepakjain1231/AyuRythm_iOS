//
//  Mudra+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 17/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import Foundation
import CoreData

@objc(Mudra)
public class Mudra: NSManagedObject {
    class func createMudraData(dicData: [String: Any], needToSave:Bool = true) -> Mudra? {
        //change "id" with "favorite_id", bcoz "id" change in hindi language api and "favorite_id" will be remain same in all language api
        let id = dicData["favorite_id"] as? String ?? ""
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("Mudra", uniqueKey: "id", value: id) as? Mudra else {
            return nil
        }
           entity.id = Int(id) ?? 0
        entity.content_id = dicData["id"] as? String ?? ""
            entity.english_name = dicData["english_name"] as? String ?? ""
            entity.image = dicData["image"] as? String ?? ""
            entity.type = dicData["type"] as? String ?? ""
            entity.status = Int32(dicData["status"] as? String ?? "0") ?? 0
            entity.name = dicData["name"] as? String ?? ""
            entity.video_duration = dicData["video_duration"] as? String ?? ""
            entity.video_link = dicData["video_link"] as? String ?? ""
            entity.descriptionMudra = dicData["description"] as? String ?? ""
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
            entity.listids = dicData["listids"] as? String ?? ""
            entity.favorite_id = dicData["favorite_id"] as? String ?? ""
        let accessPoints = dicData["access_point"] as? String ?? ""
        entity.access_point = Int16(accessPoints) ?? 0
        entity.redeemed = dicData["redeemed"] as? Bool ?? false
        entity.watchStatus = dicData["watch_status"] as? Bool ?? false
        entity.is_video_watch = dicData["is_video_watch"] as? String ?? ""

        if let benefits = dicData["benefits"] as? [[String: Any]], !benefits.isEmpty {
            for benefit in benefits {
                if let benefitEntity = Benefits.createBenefits(dic: benefit) {
                    entity.addToBenefits(benefitEntity)  // ✅ add one at a time
                }
            }
        }
        
//        if let benefits = dicData["benefits"] as? [[String: Any]]
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
    
    class func updateMudraForMyList(id: String, selectedList: String) {
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("Mudra", uniqueKey: "id", value: id) as? Mudra else {
            return
        }
        entity.listids = selectedList
        
        CoreDataHelper.sharedInstance.saveContext()
    }
}
