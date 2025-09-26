//
//  TrainerPackage+CoreDataProperties.swift
//  
//
//  Created by Paresh Dafda on 30/11/20.
//
//

import Foundation
import CoreData


extension TrainerPackage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrainerPackage> {
        return NSFetchRequest<TrainerPackage>(entityName: "TrainerPackage")
    }

    @NSManaged public var available_week_days: String?
    @NSManaged public var descriptions: String?
    @NSManaged public var dis_per_session_price: String?
    @NSManaged public var dis_per_session_price_usd: String?
    @NSManaged public var discount_per: Float
    @NSManaged public var discount_per_usd: Float
    @NSManaged public var favorite_id: Int32
    @NSManaged public var max_session_week: Int16
    @NSManaged public var max_week: Int16
    @NSManaged public var name: String?
    @NSManaged public var price_per_session: String?
    @NSManaged public var price_per_session_usd: String?
    @NSManaged public var session_type: String?
    @NSManaged public var time_per_session: String?
    @NSManaged public var total_cost: String?
    @NSManaged public var total_cost_usd: String?
    @NSManaged public var total_session: Int16
    @NSManaged public var seed_discount_price: Float
    @NSManaged public var seed_discount_price_usd: Float
    @NSManaged public var seeds_used_usd: Int32
    @NSManaged public var seeds_used: Int32
    @NSManaged public var timeslot: NSSet?
    @NSManaged public var trainer: Trainer?

}

// MARK: Generated accessors for timeslot
extension TrainerPackage {

    @objc(addTimeslotObject:)
    @NSManaged public func addToTimeslot(_ value: PackageTimeSlot)

    @objc(removeTimeslotObject:)
    @NSManaged public func removeFromTimeslot(_ value: PackageTimeSlot)

    @objc(addTimeslot:)
    @NSManaged public func addToTimeslot(_ values: NSSet)

    @objc(removeTimeslot:)
    @NSManaged public func removeFromTimeslot(_ values: NSSet)

}
