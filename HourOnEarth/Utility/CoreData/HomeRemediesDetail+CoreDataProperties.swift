//
//  HomeRemediesDetail+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Apple on 19/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData


extension HomeRemediesDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HomeRemediesDetail> {
        return NSFetchRequest<HomeRemediesDetail>(entityName: "HomeRemediesDetail")
    }

    @NSManaged public var id: Int64
    @NSManaged public var parent_id: String?
    @NSManaged public var item: String?
    @NSManaged public var image: String?
    @NSManaged public var status: String?
    @NSManaged public var color: String?

}
