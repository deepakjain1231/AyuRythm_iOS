//
//  MyProgress+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Pradeep on 4/16/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

extension MyProgress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyProgress> {
        return NSFetchRequest<MyProgress>(entityName: "MyProgress")
    }

    @NSManaged public var date: String?
    @NSManaged public var duid: String?
    @NSManaged public var id: Int64
    @NSManaged public var percentage: String?
    @NSManaged public var result: String?

}
