//
//  MyList+CoreDataProperties.swift
//  
//
//  Created by Ayu on 28/07/20.
//
//

import Foundation
import CoreData


extension MyList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyList> {
        return NSFetchRequest<MyList>(entityName: "MyList")
    }

    @NSManaged public var id: Int32
    @NSManaged public var list_name: String?
    @NSManaged public var userid: String?
    @NSManaged public var image: String?
    @NSManaged public var yoga: NSSet?
    @NSManaged public var pranayama: NSSet?
    @NSManaged public var mudras: NSSet?
    @NSManaged public var meditation: NSSet?
    @NSManaged public var kriyas: NSSet?
}

// MARK: Generated accessors for yoga
extension MyList {

    @objc(addYogaObject:)
    @NSManaged public func addToYoga(_ value: Yoga)

    @objc(removeYogaObject:)
    @NSManaged public func removeFromYoga(_ value: Yoga)

    @objc(addYoga:)
    @NSManaged public func addToYoga(_ values: NSSet)

    @objc(removeYoga:)
    @NSManaged public func removeFromYoga(_ values: NSSet)

}

// MARK: Generated accessors for pranayama
extension MyList {

    @objc(addPranayamaObject:)
    @NSManaged public func addToPranayama(_ value: Pranayama)

    @objc(removePranayamaObject:)
    @NSManaged public func removeFromPranayama(_ value: Pranayama)

    @objc(addPranayama:)
    @NSManaged public func addToPranayama(_ values: NSSet)

    @objc(removePranayama:)
    @NSManaged public func removeFromPranayama(_ values: NSSet)

}

// MARK: Generated accessors for mudras
extension MyList {

    @objc(addMudrasObject:)
    @NSManaged public func addToMudras(_ value: Mudra)

    @objc(removeMudrasObject:)
    @NSManaged public func removeFromMudras(_ value: Mudra)

    @objc(addMudras:)
    @NSManaged public func addToMudras(_ values: NSSet)

    @objc(removeMudras:)
    @NSManaged public func removeFromMudras(_ values: NSSet)

}

// MARK: Generated accessors for meditation
extension MyList {

    @objc(addMeditationObject:)
    @NSManaged public func addToMeditation(_ value: Meditation)

    @objc(removeMeditationObject:)
    @NSManaged public func removeFromMeditation(_ value: Meditation)

    @objc(addMeditation:)
    @NSManaged public func addToMeditation(_ values: NSSet)

    @objc(removeMeditation:)
    @NSManaged public func removeFromMeditation(_ values: NSSet)

}

// MARK: Generated accessors for kriyas
extension MyList {

    @objc(addKriyasObject:)
    @NSManaged public func addToKriyas(_ value: Kriya)

    @objc(removeKriyasObject:)
    @NSManaged public func removeFromKriyas(_ value: Kriya)

    @objc(addKriyas:)
    @NSManaged public func addToKriyas(_ values: NSSet)

    @objc(removeKriyas:)
    @NSManaged public func removeFromKriyas(_ values: NSSet)

}
