//
//  PranayamaSteps+CoreDataClass.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/16/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PranayamaSteps)
public class PranayamaSteps: NSManagedObject {
    class func createPranayamaStepsData(dicData: [String: Any]) {
        guard let id = dicData["id"] as? String, let entity = CoreDataHelper.sharedInstance.createEntityWithName("PranayamaSteps", uniqueKey: "id", value: id) as? PranayamaSteps else {
            return
        }
        entity.id = Int64(id) ?? 0
        entity.step_image = dicData["step_image"] as? String ?? ""
        entity.step_no = dicData["step_no"] as? String ?? ""
        entity.steps = dicData["steps"] as? String ?? ""
        entity.pranayam_id = Int64(dicData["pranayam_id"] as? String ?? "-1")  ?? 0
        CoreDataHelper.sharedInstance.saveContext()
    }
}
