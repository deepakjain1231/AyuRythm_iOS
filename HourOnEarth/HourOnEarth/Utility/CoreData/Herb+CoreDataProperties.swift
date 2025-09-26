//
//  Herb+CoreDataProperties.swift
//  
//
//  Created by Paresh Dafda on 21/10/20.
//
//

import Foundation
import CoreData


extension Herb {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Herb> {
        return NSFetchRequest<Herb>(entityName: "Herb")
    }

    @NSManaged public var benefits: String?
    @NSManaged public var herbs_name: String?
    @NSManaged public var id: Int64
    @NSManaged public var image: String?
    @NSManaged public var item_type: String?
    @NSManaged public var star: String?
    @NSManaged public var status: Int32
    @NSManaged public var vertical_image: String?

}
