//
//  MPCouponModel.swift
//  HourOnEarth
//
//  Created by CodeInfoWay CodeInfoWay on 6/28/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import ObjectMapper

class MPCouponModel: Mappable{
    
    var status: String = ""
    var data: [MPCouponData] = []
    var singleData: MPCouponData?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        status <- map["status"]
        data <- map["data"]
        singleData <- map["data"]
    }
}

class MPCouponData: Mappable{
    var title: String = ""
    var amount_percentage: Int = 0
    var apply_on_max_amount: Int = 0
    var apply_on_min_amount: Int = 0
    var apply_on_min_qnty: String = ""
    var code: String = ""
    var coupon_type: String = ""
    var end_date: String = ""
    var id: Int = 0
    var start_date: String = ""
    var description: String = ""
    var is_ayuseeds_coupon: Int = 0

    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        title <- map["title"]
        amount_percentage <- map["amount_percentage"]
        apply_on_max_amount <- map["apply_on_max_amount"]
        apply_on_min_amount <- map["apply_on_min_amount"]
        apply_on_min_qnty <- map["apply_on_min_qnty"]
        code <- map["code"]
        coupon_type <- map["coupon_type"]
        end_date <- map["end_date"]
        id <- map["id"]
        start_date <- map["start_date"]
        description <- map["description"]
        is_ayuseeds_coupon <- map["is_ayuseeds_coupon"]

    }
}


class MPCartDeliveryModel: Mappable{
    var status: String = ""
    var data: [MPCartDeliveryData] = []
    var singleData: MPCartDeliveryData?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        status <- map["status"]
        data <- map["data"]
        singleData <- map["data"]
    }
}

class MPCartDeliveryData: Mappable{
    var Applied_Coupon_ID: Int = 0
    var Applied_Ayuseed_Coupon_ID: Int = 0
    var Add_Item_For_Free_Shipping_Charge: NSNumber = 0
    var Applied_Coupon_Amount: NSNumber = 0
    var Ayuseeds_Applied_Coupon_ID: Int = 0
    var Ayuseeds_Applied_Coupon_Amount: String = ""
    var Applied_Coupon_Code: String = ""
    var Applied_Ayuseed_Coupon_Code: String = ""
    var Delivery_Charge: NSNumber = 0
    var Discount: NSNumber = 0
    var PrimeDiscount: NSNumber = 0
    var PrimeDiscountPercentage: NSNumber = 0
    var Taxes: NSNumber = 0
    var Total_MRP: NSNumber = 0
    var Total_Order_Amount: NSNumber = 0
    var Total_Payable: NSNumber = 0
    
    var str_Total_Order_Amount: String = ""
    var str_Total_Payable: String = ""
    
    var Wallet_Applied: String = ""
    var Wallet_Display_Text: String = ""
    var Wallet_Remaining_Balance: NSNumber = 0
    var Wallet_Amount_Used: NSNumber = 0
    var Wallet_Max_Save: NSNumber = 0
    
    
    var product: [MPCartDeliveryProductData] = []
    
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        product <- map["product"]
        Applied_Coupon_ID <- map["Applied_Coupon_ID"]
        Add_Item_For_Free_Shipping_Charge <- map["Add-Item-For-Free-Shipping-Charge"]
        Applied_Coupon_Amount <- map["Applied-Coupon-Amount"]
        Applied_Coupon_Code <- map["Applied-Coupon-Code"]
        Applied_Ayuseed_Coupon_Code <- map["Ayuseeds-Applied-Coupon-Code"]
        Ayuseeds_Applied_Coupon_Amount <- map["Ayuseeds-Applied-Coupon-Amount"]
        Ayuseeds_Applied_Coupon_ID <- map["Ayuseeds_Applied_Coupon_ID"]
        Delivery_Charge <- map["Delivery-Charge"]
        Discount <- map["Discount"]
        PrimeDiscount <- map["Prime-Discount"]
        PrimeDiscountPercentage <- map["Prime-Discount-Percentage"]
        Taxes <- map["Taxes"]
        Total_MRP <- map["Total-MRP"]
        Total_Order_Amount <- map["Total-Order-Amount"]
        Total_Payable <- map["Total-Payable"]
        
        str_Total_Order_Amount <- map["Total-Order-Amount"]
        str_Total_Payable <- map["Total-Payable"]
        
        Wallet_Display_Text <- map["Wallet-Display-Text"]
        Wallet_Remaining_Balance <- map["Wallet-Remaining-Balance"]
        Wallet_Amount_Used <- map["Wallet-Amount-Used"]
        Wallet_Max_Save <- map["Wallet-Max-Save"]
        Wallet_Applied <- map["Wallet-Applied"]
    }
}


class MPCartDeliveryProductData: Mappable{
    var cart_quantity: String = ""
    var cart_size_code: String = ""
    var current_quantity: String = ""
    var product_id: String = ""
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        cart_quantity <- map["cart_quantity"]
        cart_size_code <- map["cart_size_code"]
        current_quantity <- map["current_quantity"]
        product_id <- map["product_id"]
    }
}









