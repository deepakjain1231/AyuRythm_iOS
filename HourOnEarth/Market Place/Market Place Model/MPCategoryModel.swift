//
//  HomeModel.swift
//  driver
//
//  Created by Deepak Jain on 27/02/21.
//

import Foundation
import ObjectMapper

class MPCategoryModel: Mappable{
    
    var status: String = ""
    var is_lock: String = ""
    var data: [MPCategoryData] = []
    
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        status <- map["status"]
        is_lock <- map["is_lock"]
        data <- map["data"]
    }
}

class MPCategoryData: Mappable{
    
    var image: String = ""
    var name: String = ""
    var count: String = ""
    var icon: String = ""
    var subcategories: String = ""
    var attributes: String = ""
    var id: Int = 0
    var isSelect: Bool = false
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        
        image <- map["image"]
        name <- map["name"]
        count <- map["count"]
        icon <- map["icon"]
        subcategories <- map["subcategories"]
        attributes <- map["attributes"]
        id <- map["id"]
    }
}


////MARK: --- PRODUCT  ----
//struct ProductsModel: Mappable{
//    
//    internal var current_price:Int?
//    internal var id:Int?
//    internal var previous_price:Int?
//    internal var rating:Int?
//    internal var thumbnail:String?
//    internal var sale_end_date: String?
//    internal var title:String?
//    
//    init?(map:Map) {
//        mapping(map: map)
//    }
//    
//    mutating func mapping(map:Map){
//        id <- map["id"]
//        title <- map["title"]
//        rating <- map["rating"]
//        thumbnail <- map["thumbnail"]
//        sale_end_date <- map["sale_end_date"]
//        current_price <- map["current_price"]
//        previous_price <- map["previous_price"]
//    }
//}


