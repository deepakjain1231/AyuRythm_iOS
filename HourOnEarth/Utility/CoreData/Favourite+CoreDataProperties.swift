//
//  Favourite+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Apple on 19/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData


extension Favourite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favourite> {
        return NSFetchRequest<Favourite>(entityName: "Favourite")
    }

    @NSManaged public var count: Int64
    @NSManaged public var favourite_type: String?
    @NSManaged public var favKriya: NSSet?
    @NSManaged public var favMeditation: NSSet?
    @NSManaged public var favMudra: NSSet?
    @NSManaged public var favPranayama: NSSet?
    @NSManaged public var favRemedies: NSSet?
    @NSManaged public var favYoga: NSSet?
    @NSManaged public var favFood: NSSet?
    @NSManaged public var favHerb: NSSet?
}

// MARK: Generated accessors for favKriya
extension Favourite {

    @objc(addFavKriyaObject:)
    @NSManaged public func addToFavKriya(_ value: FavouriteKriya)

    @objc(removeFavKriyaObject:)
    @NSManaged public func removeFromFavKriya(_ value: FavouriteKriya)

    @objc(addFavKriya:)
    @NSManaged public func addToFavKriya(_ values: NSSet)

    @objc(removeFavKriya:)
    @NSManaged public func removeFromFavKriya(_ values: NSSet)

}

// MARK: Generated accessors for favMeditation
extension Favourite {

    @objc(addFavMeditationObject:)
    @NSManaged public func addToFavMeditation(_ value: FavouriteMeditation)

    @objc(removeFavMeditationObject:)
    @NSManaged public func removeFromFavMeditation(_ value: FavouriteMeditation)

    @objc(addFavMeditation:)
    @NSManaged public func addToFavMeditation(_ values: NSSet)

    @objc(removeFavMeditation:)
    @NSManaged public func removeFromFavMeditation(_ values: NSSet)

}

// MARK: Generated accessors for favMudra
extension Favourite {

    @objc(addFavMudraObject:)
    @NSManaged public func addToFavMudra(_ value: FavouriteMudra)

    @objc(removeFavMudraObject:)
    @NSManaged public func removeFromFavMudra(_ value: FavouriteMudra)

    @objc(addFavMudra:)
    @NSManaged public func addToFavMudra(_ values: NSSet)

    @objc(removeFavMudra:)
    @NSManaged public func removeFromFavMudra(_ values: NSSet)

}

// MARK: Generated accessors for favPranayama
extension Favourite {

    @objc(addFavPranayamaObject:)
    @NSManaged public func addToFavPranayama(_ value: FavouritePranayama)

    @objc(removeFavPranayamaObject:)
    @NSManaged public func removeFromFavPranayama(_ value: FavouritePranayama)

    @objc(addFavPranayama:)
    @NSManaged public func addToFavPranayama(_ values: NSSet)

    @objc(removeFavPranayama:)
    @NSManaged public func removeFromFavPranayama(_ values: NSSet)

}

// MARK: Generated accessors for favRemedies
extension Favourite {

    @objc(addFavRemediesObject:)
    @NSManaged public func addToFavRemedies(_ value: FavouriteHomeRemedies)

    @objc(removeFavRemediesObject:)
    @NSManaged public func removeFromFavRemedies(_ value: FavouriteHomeRemedies)

    @objc(addFavRemedies:)
    @NSManaged public func addToFavRemedies(_ values: NSSet)

    @objc(removeFavRemedies:)
    @NSManaged public func removeFromFavRemedies(_ values: NSSet)

}

// MARK: Generated accessors for favYoga
extension Favourite {

    @objc(addFavYogaObject:)
    @NSManaged public func addToFavYoga(_ value: FavouriteYoga)

    @objc(removeFavYogaObject:)
    @NSManaged public func removeFromFavYoga(_ value: FavouriteYoga)

    @objc(addFavYoga:)
    @NSManaged public func addToFavYoga(_ values: NSSet)

    @objc(removeFavYoga:)
    @NSManaged public func removeFromFavYoga(_ values: NSSet)

}

// MARK: Generated accessors for favFood
extension Favourite {

    @objc(addFavFoodObject:)
    @NSManaged public func addToFavFood(_ value: FavouriteFood)

    @objc(removeFavFoodObject:)
    @NSManaged public func removeFromFavFood(_ value: FavouriteFood)

    @objc(addFavFood:)
    @NSManaged public func addToFavFood(_ values: NSSet)

    @objc(removeFavFood:)
    @NSManaged public func removeFromFavFood(_ values: NSSet)

}

// MARK: Generated accessors for favHerb
extension Favourite {

    @objc(addFavHerbObject:)
    @NSManaged public func addToFavHerb(_ value: FavouriteHerb)

    @objc(removeFavHerbObject:)
    @NSManaged public func removeFromFavHerb(_ value: FavouriteHerb)

    @objc(addFavHerb:)
    @NSManaged public func addToFavHerb(_ values: NSSet)

    @objc(removeFavHerb:)
    @NSManaged public func removeFromFavHerb(_ values: NSSet)

}
