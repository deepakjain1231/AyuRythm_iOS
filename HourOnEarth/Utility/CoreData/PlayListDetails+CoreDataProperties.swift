//
//  PlayListDetails+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Apple on 18/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData


extension PlayListDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayListDetails> {
        return NSFetchRequest<PlayListDetails>(entityName: "PlayListDetails")
    }

    @NSManaged public var type: String?
    @NSManaged public var count: Int64
    @NSManaged public var yoga: NSSet?
    @NSManaged public var pranayama: NSSet?
    @NSManaged public var mudras: NSSet?
    @NSManaged public var meditation: NSSet?
    @NSManaged public var kriyas: NSSet?

}

// MARK: Generated accessors for yoga
extension PlayListDetails {

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
extension PlayListDetails {

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
extension PlayListDetails {

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
extension PlayListDetails {

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
extension PlayListDetails {

    @objc(addKriyasObject:)
    @NSManaged public func addToKriyas(_ value: Kriya)

    @objc(removeKriyasObject:)
    @NSManaged public func removeFromKriyas(_ value: Kriya)

    @objc(addKriyas:)
    @NSManaged public func addToKriyas(_ values: NSSet)

    @objc(removeKriyas:)
    @NSManaged public func removeFromKriyas(_ values: NSSet)

}
