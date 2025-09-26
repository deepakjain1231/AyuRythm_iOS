//
//  seasons+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 18/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import Foundation
import CoreData

extension Seasons {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Seasons> {
        return NSFetchRequest<Seasons>(entityName: "Seasons")
    }
    @NSManaged public var id: Int
    @NSManaged public var image: String?
    @NSManaged public var season_name: String?
}
