//
//  WeeklyPlannerModel.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 12/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import ObjectMapper

class WeeklyPlanner_CategoryModel: Mappable{
    
    var status: String = ""
    var data: [WeeklyPlannerCategoryData] = []
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        status <- map["status"]
        data <- map["data"]
    }
}

class WeeklyPlannerCategoryData: Mappable{
    
    var id: Int = 0
    var attributes: String = ""
    var count: String = ""
    var icon: String = ""
    var image: String = ""
    var name: String = ""
    var purchased_product_count: Int = 0
    var subcategories: String = ""
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        
        id <- map["id"]
        attributes <- map["attributes"]
        count <- map["count"]
        icon <- map["icon"]
        image <- map["image"]
        name <- map["name"]
        subcategories <- map["subcategories"]
        purchased_product_count <- map["purchased_product_count"]
    }
}



class WeeklyPlanner_ProductModel: Mappable{
    
    var status: String = ""
    var data: [WeeklyPlannerProductData] = []
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        status <- map["status"]
        data <- map["data"]
    }
}

class WeeklyPlannerProductData: Mappable{
    
    var id: Int = 0
    var is_variable_product: String = ""
    var product_id: Int = 0
    var product_name: String = ""
    var product_sub_name: String = ""
    var ayurvedic_name: String = ""
    var simple_product_size_label: String = ""
    var reminder: Bool = false
    var row_id = 0
    var started_using: Bool = false
    var thumbnail: String = ""
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        
        id <- map["id"]
        is_variable_product <- map["is_variable_product"]
        product_id <- map["product_id"]
        product_name <- map["product_name"]
        product_sub_name <- map["product_sub_name"]
        ayurvedic_name <- map["ayurvedic_name"]
        started_using <- map["started_using"]
        thumbnail <- map["thumbnail"]
        row_id <- map["row_id"]
        reminder <- map["reminder"]
        simple_product_size_label <- map["simple_product_size_label"]
    }
    
    
}



class WeeklyPlanner_TimeSlot: Mappable{
    
    var status: String = ""
    var data: [WeeklyPlannerTimeSlotData] = []
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        status <- map["status"]
        data <- map["data"]
    }
}

class WeeklyPlannerTimeSlotData: Mappable{
    
    var id: Int = 0
    var title: String = ""
    var duration: String = ""
    var is_reminder_set: Bool = false
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
        duration <- map["duration"]
        is_reminder_set <- map["is_reminder_set"]
    }
    
    
}
