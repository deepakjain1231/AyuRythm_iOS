//
//  MeditationSteps+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/16/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

extension MeditationSteps {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeditationSteps> {
        return NSFetchRequest<MeditationSteps>(entityName: "MeditationSteps")
    }

    @NSManaged public var createdate: String?
    @NSManaged public var id: Int64
    @NSManaged public var updatedate: String?
    @NSManaged public var wellness_id: Int64
    @NSManaged public var discription: String?

}
