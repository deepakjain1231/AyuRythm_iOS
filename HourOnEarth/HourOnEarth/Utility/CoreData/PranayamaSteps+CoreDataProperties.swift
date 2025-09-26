//
//  PranayamaSteps+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/16/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

extension PranayamaSteps {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PranayamaSteps> {
        return NSFetchRequest<PranayamaSteps>(entityName: "PranayamaSteps")
    }

    @NSManaged public var id: Int64
    @NSManaged public var pranayam_id: Int64
    @NSManaged public var step_image: String?
    @NSManaged public var step_no: String?
    @NSManaged public var steps: String?

}
