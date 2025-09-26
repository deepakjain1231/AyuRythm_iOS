//
//  FavouriteFood+CoreDataProperties.swift
//  
//
//  Created by Paresh Dafda on 17/10/20.
//
//

import Foundation
import CoreData


extension FavouriteFood {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouriteFood> {
        return NSFetchRequest<FavouriteFood>(entityName: "FavouriteFood")
    }

    @NSManaged public var ayurvedic_parameters: String?
    @NSManaged public var benefits: String?
    @NSManaged public var category: String?
    @NSManaged public var categoryimage: String?
    @NSManaged public var food_name: String?
    @NSManaged public var food_properties: String?
    @NSManaged public var food_status: String?
    @NSManaged public var food_type_id: String?
    @NSManaged public var id: Int
    @NSManaged public var image: String?
    @NSManaged public var item_type: String?
    @NSManaged public var season: String?
    @NSManaged public var star: String?
    @NSManaged public var status: Int32
    @NSManaged public var url: String?
    @NSManaged public var vertical_image: String?
    @NSManaged public var seasons: NSSet?
    @NSManaged public var when_to_eat: NSSet?

}

// MARK: Generated accessors for seasons
extension FavouriteFood {

    @objc(addSeasonsObject:)
    @NSManaged public func addToSeasons(_ value: Seasons)

    @objc(removeSeasonsObject:)
    @NSManaged public func removeFromSeasons(_ value: Seasons)

    @objc(addSeasons:)
    @NSManaged public func addToSeasons(_ values: NSSet)

    @objc(removeSeasons:)
    @NSManaged public func removeFromSeasons(_ values: NSSet)

}

// MARK: Generated accessors for when_to_eat
extension FavouriteFood {

    @objc(addWhen_to_eatObject:)
    @NSManaged public func addToWhen_to_eat(_ value: When_to_eat)

    @objc(removeWhen_to_eatObject:)
    @NSManaged public func removeFromWhen_to_eat(_ value: When_to_eat)

    @objc(addWhen_to_eat:)
    @NSManaged public func addToWhen_to_eat(_ values: NSSet)

    @objc(removeWhen_to_eat:)
    @NSManaged public func removeFromWhen_to_eat(_ values: NSSet)

}
