//
//  Yoga+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Apple on 05/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData


extension Yoga {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Yoga> {
        return NSFetchRequest<Yoga>(entityName: "Yoga")
    }

    @NSManaged public var benefit_description: String?
    @NSManaged public var descriptionYoga: String?
    @NSManaged public var english_name: String?
    @NSManaged public var experiencelevel: String?
    @NSManaged public var favorite_id: String?
    @NSManaged public var experiencelevelimage: String?
    @NSManaged public var id: Int32
    @NSManaged public var content_id: String?
    @NSManaged public var image: String?
    @NSManaged public var is_video_watch: String?
    @NSManaged public var image_grey: String?
    @NSManaged public var listids: String?
    @NSManaged public var name: String?
    @NSManaged public var precautions: String?
    @NSManaged public var shortdescription: String?
    @NSManaged public var star: String?
    @NSManaged public var status: Int32
    @NSManaged public var steps: String?
    @NSManaged public var type: String?
    @NSManaged public var types_flag: String?
    @NSManaged public var verticleimage: String?
    @NSManaged public var video_duration: String?
    @NSManaged public var video_link: String?
    @NSManaged public var benefits: NSSet?
    @NSManaged public var access_point: Int16
    @NSManaged public var redeemed: Bool
    @NSManaged public var watchStatus: Bool

}

// MARK: Generated accessors for benefits
extension Yoga {

    @objc(addBenefitsObject:)
    @NSManaged public func addToBenefits(_ value: Benefits)

    @objc(removeBenefitsObject:)
    @NSManaged public func removeFromBenefits(_ value: Benefits)

    @objc(addBenefits:)
    @NSManaged public func addToBenefits(_ values: NSSet)

    @objc(removeBenefits:)
    @NSManaged public func removeFromBenefits(_ values: NSSet)

}
