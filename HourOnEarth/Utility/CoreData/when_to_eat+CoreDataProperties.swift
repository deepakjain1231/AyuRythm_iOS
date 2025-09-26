//
//  when_to_eat+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 18/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import Foundation
import CoreData

extension When_to_eat {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<When_to_eat> {
        return NSFetchRequest<When_to_eat>(entityName: "When_to_eat")
    }
    @NSManaged public var id: Int
    @NSManaged public var image: String?
    @NSManaged public var besttime: String?
}
