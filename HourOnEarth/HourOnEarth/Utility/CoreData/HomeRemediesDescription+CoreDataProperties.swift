//
//  HomeRemediesDescription+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Apple on 23/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData


extension HomeRemediesDescription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HomeRemediesDescription> {
        return NSFetchRequest<HomeRemediesDescription>(entityName: "HomeRemediesDescription")
    }

    @NSManaged public var createdate: String?
    @NSManaged public var desc_id: Int64
    @NSManaged public var discription: String?
    @NSManaged public var option_name: String?
    @NSManaged public var remedies_id: Int64
    @NSManaged public var star: String?
    @NSManaged public var updatedate: String?
    @NSManaged public var colour: String?

}
