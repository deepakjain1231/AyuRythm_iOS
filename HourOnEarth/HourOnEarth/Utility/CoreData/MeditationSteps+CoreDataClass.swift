//
//  MeditationSteps+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/16/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MeditationSteps)
public class MeditationSteps: NSManagedObject {
    class func createMeditationStepsData(dicData: [String: Any]) {
        guard let id = dicData["id"] as? String, let entity = CoreDataHelper.sharedInstance.createEntityWithName("MeditationSteps", uniqueKey: "id", value: id) as? MeditationSteps else {
            return
        }
        entity.id = Int64(id) ?? 0
        entity.createdate = dicData["createdate"] as? String ?? ""
        entity.updatedate = dicData["updatedate"] as? String ?? ""
        entity.wellness_id = Int64(dicData["wellness_id"] as? String ?? "0") ?? 0
        entity.discription = dicData["description"] as? String ?? ""
        CoreDataHelper.sharedInstance.saveContext()
    }
}
