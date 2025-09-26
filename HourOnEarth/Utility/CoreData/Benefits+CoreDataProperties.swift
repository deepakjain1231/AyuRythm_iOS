//
//  Benefits+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Apple on 05/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData


extension Benefits {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Benefits> {
        return NSFetchRequest<Benefits>(entityName: "Benefits")
    }

    @NSManaged public var benefitsimage: String?
    @NSManaged public var benefitsname: String?

}
