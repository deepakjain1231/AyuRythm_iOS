//
//  FavouritePranayama+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 17/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//


import Foundation
import CoreData


extension FavouritePranayama {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouritePranayama> {
        return NSFetchRequest<FavouritePranayama>(entityName: "FavouritePranayama")
    }

    @NSManaged public var benefit_description: String?
    @NSManaged public var descriptionPranayama: String?
    @NSManaged public var english_name: String?
    @NSManaged public var experiencelevel: String?
    @NSManaged public var experiencelevelimage: String?
    @NSManaged public var id: Int
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var precautions: String?
    @NSManaged public var shortdescription: String?
    @NSManaged public var star: String?
    @NSManaged public var status: Int32
    @NSManaged public var steps: String?
    @NSManaged public var type: String?
    @NSManaged public var verticleimage: String?
    @NSManaged public var video_duration: String?
    @NSManaged public var video_link: String?
    @NSManaged public var benefits_ids: String?
    @NSManaged public var preparation: String?

}
