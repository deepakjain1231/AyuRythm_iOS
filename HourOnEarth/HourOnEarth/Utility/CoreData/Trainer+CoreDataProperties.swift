//
//  Trainer+CoreDataProperties.swift
//  
//
//  Created by Ayu on 15/08/20.
//
//

import Foundation
import CoreData


extension Trainer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trainer> {
        return NSFetchRequest<Trainer>(entityName: "Trainer")
    }

    @NSManaged public var access_point: Int16
    @NSManaged public var about: String?
    @NSManaged public var id: Int64
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var redeemed: Bool
    @NSManaged public var package: NSSet?

}

// MARK: Generated accessors for Package
extension Trainer {

    @objc(addPackageObject:)
    @NSManaged public func addToPackage(_ value: TrainerPackage)

    @objc(removePackageObject:)
    @NSManaged public func removeFromPackage(_ value: TrainerPackage)

    @objc(addPackage:)
    @NSManaged public func addToPackage(_ values: NSSet)

    @objc(removePackage:)
    @NSManaged public func removeFromPackage(_ values: NSSet)

}
