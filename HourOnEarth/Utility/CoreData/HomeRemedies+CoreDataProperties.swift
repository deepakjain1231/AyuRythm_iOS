//
//  HomeRemedies+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Apple on 19/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData

extension HomeRemedies {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HomeRemedies> {
        return NSFetchRequest<HomeRemedies>(entityName: "HomeRemedies")
    }

    @NSManaged public var id: Int64
    @NSManaged public var image: String?
    @NSManaged public var item: String?
    @NSManaged public var status: String?
    @NSManaged public var color: String?
    @NSManaged public var subcategory: NSSet?

}

// MARK: Generated accessors for subcategory
extension HomeRemedies {

    @objc(addSubcategoryObject:)
    @NSManaged public func addToSubcategory(_ value: HomeRemediesDetail)

    @objc(removeSubcategoryObject:)
    @NSManaged public func removeFromSubcategory(_ value: HomeRemediesDetail)

    @objc(addSubcategory:)
    @NSManaged public func addToSubcategory(_ values: NSSet)

    @objc(removeSubcategory:)
    @NSManaged public func removeFromSubcategory(_ values: NSSet)

}
