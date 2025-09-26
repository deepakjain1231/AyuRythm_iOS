//
//  FavouriteYoga+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Apple on 23/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData


extension FavouriteYoga {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouriteYoga> {
        return NSFetchRequest<FavouriteYoga>(entityName: "FavouriteYoga")
    }

    @NSManaged public var descriptionYoga: String?
    @NSManaged public var english_name: String?
    @NSManaged public var id: Int32
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var status: Int32
    @NSManaged public var type: String?
    @NSManaged public var video_duration: String?
    @NSManaged public var video_link: String?
    @NSManaged public var benefit_description: String?
    @NSManaged public var experiencelevel: String?
    @NSManaged public var precautions: String?
    @NSManaged public var shortdescription: String?
    @NSManaged public var steps: String?
    @NSManaged public var star: String?
    @NSManaged public var verticleimage: String?

}
