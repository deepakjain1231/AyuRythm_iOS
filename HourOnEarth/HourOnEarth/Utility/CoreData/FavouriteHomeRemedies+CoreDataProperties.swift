//
//  FavouriteHomeRemedies+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Apple on 23/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData


extension FavouriteHomeRemedies {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouriteHomeRemedies> {
        return NSFetchRequest<FavouriteHomeRemedies>(entityName: "FavouriteHomeRemedies")
    }

    @NSManaged public var category: String?
    @NSManaged public var categoryimage: String?
    @NSManaged public var createdate: String?
    @NSManaged public var desc_id: String?
    @NSManaged public var descriptionDetail: String?
    @NSManaged public var option_name: String?
    @NSManaged public var remedies_id: String?
    @NSManaged public var subcategory: String?
    @NSManaged public var updatedate: String?
    @NSManaged public var colour: String?

}
