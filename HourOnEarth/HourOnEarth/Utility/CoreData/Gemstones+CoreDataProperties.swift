//
//  Gemstones+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/16/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

extension Gemstones {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gemstones> {
        return NSFetchRequest<Gemstones>(entityName: "Gemstones")
    }

    @NSManaged public var action: String?
    @NSManaged public var gem: String?
    @NSManaged public var gem_hindi: String?
    @NSManaged public var gem_image: String?
    @NSManaged public var id: Int64
    @NSManaged public var kapha: String?
    @NSManaged public var pitta: String?
    @NSManaged public var planet: String?
    @NSManaged public var remedies: String?
    @NSManaged public var status: String?
    @NSManaged public var vata: String?

}
