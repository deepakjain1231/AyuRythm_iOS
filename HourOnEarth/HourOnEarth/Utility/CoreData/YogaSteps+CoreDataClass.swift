//
//  YogaSteps+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/16/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(YogaSteps)
public class YogaSteps: NSManagedObject {
    class func createYogaStepsData(dicData: [String: Any]) {
        guard let id = dicData["id"] as? String, let entity = CoreDataHelper.sharedInstance.createEntityWithName("YogaSteps", uniqueKey: "id", value: id) as? YogaSteps else {
            return
        }
        entity.id = Int64(id) ?? 0
        entity.step_image = dicData["step_image"] as? String ?? ""
        entity.step_no = dicData["step_no"] as? String ?? ""
        entity.steps = dicData["steps"] as? String ?? ""
        entity.yoga_id = Int64(dicData["yoga_id"] as? String ?? "-1")  ?? 0
        CoreDataHelper.sharedInstance.saveContext()
    }
}
