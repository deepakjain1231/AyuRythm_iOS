//
//  TodayRecommendationMyPlan+CoreDataProperties.swift
//  HourOnEarth
//
//  Created by Apple on 12/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//
//

import Foundation
import CoreData


extension TodayRecommendationMyPlan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodayRecommendationMyPlan> {
        return NSFetchRequest<TodayRecommendationMyPlan>(entityName: "TodayRecommendationMyPlan")
    }

    @NSManaged public var food_name: String?
    @NSManaged public var food_status: String?
    @NSManaged public var food_type_id: Int64
    @NSManaged public var image: String?
    @NSManaged public var item_type: String?
    @NSManaged public var status: Int64
    @NSManaged public var url: String?
    @NSManaged public var foodId: Int64
    @NSManaged public var attribute: NSObject?
    @NSManaged public var descriptionYoga: String?
    @NSManaged public var english_name: String?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var video_duration: String?
    @NSManaged public var video_link: String?
    @NSManaged public var yogaId: Int64
    @NSManaged public var recommendationType: String?

}
