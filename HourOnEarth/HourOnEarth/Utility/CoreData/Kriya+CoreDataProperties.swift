//
//  Kriya+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 17/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import Foundation
import CoreData

extension Kriya {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Kriya> {
        return NSFetchRequest<Kriya>(entityName: "Kriya")
    }
    
    @NSManaged public var benefit_description: String?
    @NSManaged public var descriptionKriya: String?
    @NSManaged public var english_name: String?
    @NSManaged public var experiencelevel: String?
    @NSManaged public var favorite_id: String?
    @NSManaged public var experiencelevelimage: String?
    @NSManaged public var id: Int
    @NSManaged public var content_id: String?
    @NSManaged public var image: String?
    @NSManaged public var listids: String?
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
    @NSManaged public var benefits: NSSet?
    @NSManaged public var access_point: Int16
    @NSManaged public var redeemed: Bool
    @NSManaged public var watchStatus: Bool
    @NSManaged public var is_video_watch: String?

}
// MARK: Generated accessors for benefits
extension Kriya {

    @objc(addBenefitsObject:)
    @NSManaged public func addToBenefits(_ value: Benefits)

    @objc(removeBenefitsObject:)
    @NSManaged public func removeFromBenefits(_ value: Benefits)

    @objc(addBenefits:)
    @NSManaged public func addToBenefits(_ values: NSSet)

    @objc(removeBenefits:)
    @NSManaged public func removeFromBenefits(_ values: NSSet)

}
