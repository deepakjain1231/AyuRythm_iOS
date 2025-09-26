//
//  PlayList+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Apple on 18/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData


extension PlayList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayList> {
        return NSFetchRequest<PlayList>(entityName: "PlayList")
    }

    @NSManaged public var ayurid: Int64
    @NSManaged public var name: String?
    @NSManaged public var image: String?
    @NSManaged public var detail_image: String?
    @NSManaged public var id: Int64
    @NSManaged public var type: String?
    @NSManaged public var access_point: Int16
    @NSManaged public var count: Int16
    @NSManaged public var favorite_id: String?
    @NSManaged public var redeemed: Bool
    @NSManaged public var item: String?

}
