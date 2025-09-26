//
//  PackageTimeSlot+CoreDataProperties.swift
//  
//
//  Created by Ayu on 22/08/20.
//
//

import Foundation
import CoreData


extension PackageTimeSlot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PackageTimeSlot> {
        return NSFetchRequest<PackageTimeSlot>(entityName: "PackageTimeSlot")
    }

    @NSManaged public var start_time: String?
    @NSManaged public var end_time: String?
    @NSManaged public var week_days: String?
    @NSManaged public var package: TrainerPackage?

}
