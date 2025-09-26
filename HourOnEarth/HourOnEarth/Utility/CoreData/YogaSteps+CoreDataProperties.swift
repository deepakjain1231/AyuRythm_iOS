//
//  YogaSteps+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/16/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData


extension YogaSteps {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<YogaSteps> {
        return NSFetchRequest<YogaSteps>(entityName: "YogaSteps")
    }

    @NSManaged public var id: Int64
    @NSManaged public var step_image: String?
    @NSManaged public var step_no: String?
    @NSManaged public var steps: String?
    @NSManaged public var yoga_id: Int64

}
