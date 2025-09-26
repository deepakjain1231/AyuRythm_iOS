//
//  HomeModel.swift
//  driver
//
//  Created by Deepak Jain on 27/02/21.
//

import Foundation

//struct ProductsModel {
//    var current_price:Int?
//    var id:Int?
//    var previous_price:Int?
//    var rating:Int?
//    var thumbnail:String?
//    var sale_end_date: String?
//    var title:String?
//}

//struct CategoryListModel {
//    var attributes: String?
//    var count: String?
//    var icon: String?
//    var id: Int?
//    var name: String?
//    var image: String?
//    var products: [ProductsModel]?
//}


/*
 import ObjectMapper
//MARK: --- ORDER  ----
struct CategoryListModel: Mappable{
    
    internal var attributes: String?
    internal var count: String?
    internal var icon: String?
    internal var id: Int?
    internal var name: String?
    internal var image: String?
    internal var products: [ProductsModel]?

    
    init?(map:Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map:Map){
        attributes <- map["attributes"]
        count <- map["count"]
        icon <- map["icon"]
        id <- map["id"]
        name <- map["name"]
        image <- map["image"]
        products <- map["products"]
    }
}


//MARK: --- PRODUCT  ----
struct ProductsModel: Mappable{
    
    internal var current_price:Int?
    internal var id:Int?
    internal var previous_price:Int?
    internal var rating:Int?
    internal var thumbnail:String?
    internal var sale_end_date: String?
    internal var title:String?
        
    init?(map:Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map:Map){
        id <- map["id"]
        title <- map["title"]
        rating <- map["rating"]
        thumbnail <- map["thumbnail"]
        sale_end_date <- map["sale_end_date"]
        current_price <- map["current_price"]
        previous_price <- map["previous_price"]
    }
}*/



//MARK: - API CALlLING
//PRODUCT DETAIL SCREEN ..........................

extension MPProductDetailVC {
    
    func callAPIforGetProductDetail(product_id: String) {
        
        let str_URL = String(format: URL_Product_Detail, product_id)
        
        ServiceCustom.shared.requestURL(str_URL, Method: .get, parameters: nil, progress: true, current_view: self) { json, success, error in
            
            if let errorr = error {
                Utils.showAlertWithTitleInController(APP_NAME, message: errorr.localizedDescription, controller: self)
                return
            }
            else {
                if let response = json {
                    if let arr_Data = response["data"] as? [[String: Any]] {

                    }
                }
            }
        }
    }
    
}
