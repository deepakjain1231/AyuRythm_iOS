//
//  MyListDetails+CoreDataProperties.swift
//  
//
//  Created by Ayu on 28/07/20.
//
//

import Foundation
import CoreData


extension MyListDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyListDetails> {
        return NSFetchRequest<MyListDetails>(entityName: "MyListDetails")
    }

    @NSManaged public var id: Int32
    @NSManaged public var favourite_id: String?
    @NSManaged public var favourite_type: String?
    @NSManaged public var listid: String?
    @NSManaged public var yoga: Yoga?
    @NSManaged public var pranayama: Pranayama?
    @NSManaged public var mudras: Mudra?
    @NSManaged public var meditation: Meditation?
    @NSManaged public var kriyas: Kriya?
}

