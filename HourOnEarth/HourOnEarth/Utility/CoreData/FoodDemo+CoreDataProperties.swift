//
//  FoodDemo+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Apple on 04/03/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData


extension FoodDemo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodDemo> {
        return NSFetchRequest<FoodDemo>(entityName: "FoodDemo")
    }

    @NSManaged public var id: Int64
    @NSManaged public var foodType: String?
    @NSManaged public var image: String?

}
