//
//  PackageTimeSlot+CoreDataClass.swift
//  
//
//  Created by Ayu on 22/08/20.
//
//

import Foundation
import CoreData

@objc(PackageTimeSlot)
public class PackageTimeSlot: NSManagedObject {
    
    class func createPackageTimeSlotData(dicData: [String: Any]) -> PackageTimeSlot? {
        let start_time = dicData["start_time"] as? String ?? "0"
        guard let entity = CoreDataHelper.sharedInstance.createEntityWithName("PackageTimeSlot", uniqueKey: nil, value: nil) as? PackageTimeSlot else {
            return nil
        }
        entity.start_time = start_time
        entity.end_time = dicData["end_time"] as? String ?? ""
        entity.week_days = dicData["week_days"] as? String ?? ""
        
        CoreDataHelper.sharedInstance.saveContext()
        return entity
    }

}
