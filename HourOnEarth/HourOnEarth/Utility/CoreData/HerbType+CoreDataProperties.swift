//
//  HerbType+CoreDataProperties.swift
//  
//
//  Created by Paresh Dafda on 17/10/20.
//
//

import Foundation
import CoreData


extension HerbType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HerbType> {
        return NSFetchRequest<HerbType>(entityName: "HerbType")
    }

    @NSManaged public var herbs_types: String?
    @NSManaged public var id: Int64
    @NSManaged public var image: String?

}
