//
//  MPProductModel.swift
//  HourOnEarth
//
//  Created by Maulik Vora on 01/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import ObjectMapper

class MPProductModel: Mappable{
    
    var status: String = ""
    var is_lock: String = ""
    var data: [MPProductData] = []
    var singleData: MPProductData?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        status <- map["status"]
        is_lock <- map["is_lock"]
        data <- map["data"]
        singleData <- map["data"]
    }
}


class MPOfferListModel: Mappable{
    
    var status: String = ""
    var data: [MPOfferData] = []
    var singleData: MPOfferData?
    
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

class MPOfferData: Mappable{
    
    var id: Int = 0
    var category_id: Int = 0
    var image: String = ""
    var is_featured: Int = 0
    var name: String = ""
    var percentage: Int = 0
    var status: Int = 0
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        category_id <- map["category_id"]
        image <- map["image"]
        is_featured <- map["is_featured"]
        name <- map["name"]
        percentage <- map["percentage"]
        status <- map["status"]
    }
}





class MPCartData: Mappable{
    var sizes: String = ""
    var discount: String = ""
    var sizes_wise_previous_price: String = ""
    var sizes_wise_price: String = ""
    var available_size_quantity: String = ""
    var size_price: String = ""
    var sizes_key: String = ""
    var added_quantity: Int = 0
    var random_id: String = ""
    var color_code: String = ""
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        color_code <- map["colors"]
        discount <- map["discount"]
        random_id <- map["random_id"]
        sizes <- map["sizes"]
        sizes_wise_previous_price <- map["sizes_wise_previous_price"]
        sizes_wise_price <- map["sizes_wise_price"]
        available_size_quantity <- map["available_size_quantity"]
        size_price <- map["size_price"]
        added_quantity <- map["added_quantity"]
        
    }
}

class MPProductData: Mappable{
    
    var id: Int = 0
    var cart_id: Int = 0
    var title: String = ""
    var ayurvedic_name: String = ""
    var is_variable_product: String = ""
    var simple_product_size_label: String = ""
    var thumbnail: String = ""
    var rating: Double = 0.0
    var current_price: Double = 0 //Temp
    var previous_price: Double = 0 //Temp
    var estimated_shipping_time: String = ""
    var simple_product_stock: Int = 0
    var colors: [String] = []
    var sizes: [String] = []
    var size_quantity: [String] = []
    var size_price: [String] = []
    var sizes_wise_price: [String] = []
    var sizes_wise_previous_price: [String] = []
    var size_price_in_int: [Int] = []
    var sizes_wise_price_in_int: [Int] = []
    var sizes_wise_previous_price_in_int: [Int] = []
    var created_at: [MPProductCreated_At] = []
    var updated_at: [MPProductCreated_At] = []
    var DISCOUNT: Int = 0
    var WISHLIST: Int = 0
    var CART: Int = 0
    var NOTIFY_FOR_THIS_ITEM: String = ""
    var details: String = ""
    var direction_to_use: String = ""
    var benefits_n_uses: String = ""
    var key_ingredients: String = ""
    var images:[MPProductImages] = []
    var videos:[MPProductVideos] = []
    var related_products: [MPProductData] = []
    var cartData: MPCartData?
    var best_before: String = ""
    var brand: String = ""
    var is_addedInCart: Bool = false
    var shop: MPShopData?
    var reviews: [MPReviewData] = []
    var total_rating_received: Int?
    var total_review_received: Int?
    var total_ratings: [MP_ProductTotalRatings] = []
    var CART_DETAIL: [MPProductCART_DETAIL] = []
    var rating_conditions: MPProductRatingCondition?
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        reviews <- map["reviews"]
        shop <- map["shop"]
        brand <- map["brand"]
        best_before <- map["best_before"]
        direction_to_use <- map["direction_to_use"]
        benefits_n_uses <- map["benefits_n_uses"]
        key_ingredients <- map["key_ingredients"]
        details <- map["details"]
        cartData <- map["cartData"]
        id <- map["id"]
        cart_id <- map["cart_id"]
        is_addedInCart <- map["is_addedInCart"]
        title <- map["title"]
        ayurvedic_name <- map["ayurvedic_name"]
        simple_product_size_label <- map["simple_product_size_label"]
        is_variable_product <- map["is_variable_product"]
        thumbnail <- map["thumbnail"]
        rating <- map["rating"]
        current_price <- map["current_price"]
        previous_price <- map["previous_price"]
        estimated_shipping_time <- map["estimated_shipping_time"]
        simple_product_stock <- map["simple_product_stock"]
        colors <- map["colors"]
        sizes <- map["sizes"]
        size_quantity <- map["size_quantity"]
        size_price <- map["size_price"]
        sizes_wise_price <- map["sizes_wise_price"]
        sizes_wise_previous_price <- map["sizes_wise_previous_price"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        DISCOUNT <- map["DISCOUNT"]
        WISHLIST <- map["WISHLIST"]
        CART <- map["CART"]
        CART_DETAIL <- map["CART_DETAIL"]
        NOTIFY_FOR_THIS_ITEM <- map["NOTIFY_FOR_THIS_ITEM"]
        images <- map["images"]
        videos <- map["videos"]
        related_products <- map["related_products"]
        size_price_in_int <- map["size_price"]
        sizes_wise_price_in_int <- map["sizes_wise_price"]
        sizes_wise_previous_price_in_int <- map["sizes_wise_previous_price"]
        rating_conditions <- map["rating_conditions"]
        total_rating_received <- map["total_rating_received"]
        total_review_received <- map["total_review_received"]
        total_ratings <- map["total_ratings"]
    }
}

class MP_ProductTotalRatings: Mappable{
    var rating: Int = 0
    var total_rate: Int = 0
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        rating <- map["rating"]
        total_rate <- map["total_rate"]
    }
}

class MPProductRatingCondition: Mappable{
    
    var if_review_or_not: String = ""
    var rating_given_or_not: String = ""
    var rating_review_id: Int = 0
    var rating_given: Int = 0
    var review_given_or_not: String = ""
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        if_review_or_not <- map["if_review_or_not"]
        rating_given_or_not <- map["rating_given_or_not"]
        rating_review_id <- map["rating_review_id"]
        rating_given <- map["rating_given"]
        review_given_or_not <- map["review_given_or_not"]
    }
}

class MPProductCART_DETAIL: Mappable{
    
    var ADDED_COLOR: String = ""
    var ADDED_QUANTITY: Int = 0
    var ADDED_SIZE: String = ""
    var ADDED_SIZE_KEY: String = "0"
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        ADDED_COLOR <- map["ADDED_COLOR"]
        ADDED_QUANTITY <- map["ADDED_QUANTITY"]
        ADDED_SIZE <- map["ADDED_SIZE"]
        ADDED_SIZE_KEY <- map["ADDED_SIZE_KEY"]
    }
}

class MPProductCreated_At: Mappable{
    
    var date: String = ""
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        date <- map["date"]
    }
}

class MPShopData: Mappable{
    
    var id: Int = 0
    var items: String = ""
    var name: String = ""
    var manufacturer_by: String = ""
    var country_of_origin: String = ""
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        items <- map["items"]
        name <- map["name"]
        manufacturer_by <- map["manufacturer_by"]
        country_of_origin <- map["country_of_origin"]
    }
}

class MPReviewDetailModel: Mappable{
    
    var id: Int = 0
    var name: String = ""
    var rating: Int = 0
    var review: String = ""
    var review_date: String = ""
    var user_id: Int = 0
    var user_image: String = ""
    var created_at: String = ""
    var review_images: [String] = []

    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        created_at <- map["created_at"]
        id <- map["id"]
        name <- map["name"]
        rating <- map["rating"]
        review <- map["review"]
        review_date <- map["review_date"]
        user_id <- map["user_id"]
        user_image <- map["user_image"]
        review_images <- map["review_images"]
    }
}

class MPReviewData: Mappable{
    
    var review: MPReviewDetailModel?
    var user: MPReviewUserDetailModel?

    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        review <- map["review"]
        user <- map["user"]
    }
}

class MPReviewUserDetailModel: Mappable{
    
    var user_id: Int = 0
    var user_name: String = ""
    var user_photo: String = ""

    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        user_id <- map["user_id"]
        user_name <- map["user_name"]
        user_photo <- map["user_photo"]
    }
}

class MPReviewModel: Mappable{
    
    var data: [MPReviewData] = []
    var status: Int = 0
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        data <- map["data"]
        status <- map["status"]
    }
}


class MPProductImages: Mappable{
    
    var id: Int = 0
    var image: String = ""
    var video: String = ""
    
    required init?() {
    }

    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        image <- map["image"]
        video <- map["video"]
        
    }
}

class MPProductVideos: Mappable{
    
    var id: Int = 0
    var video: String = ""
    
    required init?() {
    }

    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        video <- map["video"]
        
    }
}


class MPProductSortModel: Mappable{
    
    var status: String = ""
    var data: [MPSortingData] = []
    
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

class MPSortingData: Mappable{
    
    var id: Int = 0
    var title: String = ""
    var created_at: String = ""
    var updated_at: String = ""
    var display_order: Int = 0
    var status: Int = 0
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        status <- map["status"]
        display_order <- map["display_order"]
    }
}


//For My Order List
class MPMyOrderProductModel: Mappable {
    
    var status: String = ""
    var data: [MPOrderProductData] = []
    var singleData: MPOrderProductData?
    
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

class MPOrderProductData: Mappable{
    
    var id: Int = 0
    //var can_cancel_or_not: String = ""
    //var can_return_or_not: String = ""
    var invoice_url: String = ""
    var order_note: String = ""
    var order_number: String = ""
    var payment_method: String = ""
    var customer_info: [MPCustomerInfo] = []
    var price_details: MPPriceDetail?
    var rate: String = ""
    var total: String = ""
    var created_at: [String: Any] = [:]
    var updated_at: [String: Any] = [:]
    var shipping_info: MPShippingInfo?
    var products: [MPMyOrderProductDetail] = []
//    var single_products: MPMyOrderProductDetail?
    //var single_products: [String: Any] = [:]
//    var single_products: [MPMyOrderProductDetail] = []

    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        //can_cancel_or_not <- map["can_cancel_or_not"]
        //can_return_or_not <- map["can_return_or_not"]
        invoice_url <- map["invoice_url"]
        order_note <- map["order_note"]
        order_number <- map["order_number"]
        payment_method <- map["payment_method"]
        customer_info <- map["customer_info"]
        price_details <- map["price_details"]
        rate <- map["rate"]
        total <- map["total"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        shipping_info <- map["shipping_info"]
        products <- map["products"]
//        single_products <- map["products"]
    }
}

class MPCustomerInfo: Mappable{
    
    var customer_address: String = ""
    var customer_city: String = ""
    var customer_name: String = ""
    var customer_phone: String = ""
    var customer_zip: String = ""
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        customer_address <- map["customer_address"]
        customer_city <- map["customer_city"]
        customer_name <- map["customer_name"]
        customer_phone <- map["customer_phone"]
        customer_zip <- map["customer_zip"]
    }
}

class MPPriceDetail: Mappable{
    
    var Applied_Coupon_Amount: String = ""
    var Applied_Coupon_Code: String = ""
    var Ayuseeds_Applied_Coupon_Amount: Int = 0
    var Ayuseeds_Applied_Coupon_Code: String = ""
    var Delivery_Charge: Double = 0.0
    var Discount: Double = 0.0
    var Taxes: Double = 0.0
    var Total_MRP: Double = 0.0
    var Total_Order_Amount: Double = 0.0
    var Total_Payable: Double = 0.0
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        Applied_Coupon_Amount <- map["Applied-Coupon-Amount"]
        Applied_Coupon_Code <- map["Applied-Coupon-Code"]
        
        Ayuseeds_Applied_Coupon_Amount <- map["Ayuseeds-Applied-Coupon-Amount"]
        Ayuseeds_Applied_Coupon_Code <- map["Ayuseeds-Applied-Coupon-Code"]
        
        Delivery_Charge <- map["Delivery-Charge"]
        Discount <- map["Discount"]
        Taxes <- map["Taxes"]
        Total_MRP <- map["Total-MRP"]
        Total_Order_Amount <- map["Total-Order-Amount"]
        Total_Payable <- map["Total-Payable"]
    }
}


class MPShippingInfo: Mappable{
    
    var shipping_address: String = ""
    var shipping_address_type: String = ""
    var shipping_building_name: String = ""
    var shipping_city: String = ""
    var shipping_country: String = ""
    var shipping_email: String = ""
    var shipping_landmark: String = ""
    var shipping_name: String = ""
    var shipping_phone: String = ""
    var shipping_state: String = ""
    var shipping_zip: String = ""
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        shipping_address <- map["shipping_address"]
        shipping_address_type <- map["shipping_address_type"]
        shipping_building_name <- map["shipping_building_name"]
        shipping_city <- map["shipping_city"]
        shipping_country <- map["shipping_country"]
        shipping_email <- map["shipping_email"]
        shipping_landmark <- map["shipping_landmark"]
        shipping_name <- map["shipping_name"]
        shipping_phone <- map["shipping_phone"]
        shipping_state <- map["shipping_state"]
        shipping_zip <- map["shipping_zip"]
    }
}


class MPMyOrderProductDetail: Mappable{
    
    var id: Int = 0
    var color: String = ""
    var size: String = ""
    var feature_image: String = ""
    var if_rating: String = ""
    var if_review_or_not: String = ""
    var rating_review_id: Int = 0
    var rating_given_or_not: String = ""
    var review_given_or_not: String = ""
    var item_price: NSNumber = 0
    var item_previous_price: Int = 0
    var item_tax: NSNumber = 0
    var keys: String = ""
    var name: String = ""
    var rating: Int = 0
    var size_key: String = ""
    var size_price: String = ""
    var size_qty: String = ""
    var status: String = ""
    var stock: String = ""
    var type: String = ""
    var values: String = ""
    var vendor_id: Int = 0
    var total_price: NSNumber = 0
    var qty: String = ""
    var previous_price: Int = 0
    var item_coupon_code: String = ""
    var item_coupon_amount: NSNumber = 0
    var item_delivery_charge: NSNumber = 0
    var item_discount: NSNumber = 0
    var item_mrp: NSNumber = 0
    var item_tax_paid: Int = 0
    
    var easyecom_vendor_token: String = ""
    var item_wise_walled_applied: String = ""
    var item_wise_wallet_amount: NSNumber = 0
    
    var can_cancel_or_not: String = ""
    var can_return_or_not: String = ""

    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        color <- map["color"]
        size <- map["size"]
        feature_image <- map["feature_image"]
        if_rating <- map["if_rating"]
        if_review_or_not <- map["if_review_or_not"]
        rating_review_id <- map["rating_review_id"]
        rating_given_or_not <- map["rating_given_or_not"]
        review_given_or_not <- map["review_given_or_not"]
        item_price <- map["item_price"]
        item_previous_price <- map["item_previous_price"]
        item_tax <- map["item_tax"]
        keys <- map["keys"]
        name <- map["name"]
        rating <- map["rating"]
        size_key <- map["size_key"]
        size_price <- map["size_price"]
        size_qty <- map["size_qty"]
        status <- map["status"]
        stock <- map["stock"]
        type <- map["type"]
        values <- map["values"]
        vendor_id <- map["vendor_id"]
        total_price <- map["total_price"]
        qty <- map["qty"]
        previous_price <- map["previous_price"]
        item_coupon_amount <- map["item_coupon_amount"]
        item_mrp <- map["item_mrp"]
        item_tax_paid <- map["item_tax_paid"]
        item_coupon_code <- map["item_coupon_code"]
        item_delivery_charge <- map["item_delivery_charge"]
        item_discount <- map["item_discount"]
        item_wise_walled_applied <- map["item_wise_walled_applied"]
        item_wise_wallet_amount <- map["item_wise_wallet_amount"]
        easyecom_vendor_token <- map["easyecom_vendor_token"]
        can_cancel_or_not <- map["can_cancel_or_not"]
        can_return_or_not <- map["can_return_or_not"]
    }
}




//MARK: - Home Screen API CALLING
extension MPHomeVC {
    func callAPIfor_GETCATEGORY() {
        
        var param = [String: Any]()
        var nameAPI: endPoint = .mp_categories
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_categories
            getHeader = MPLoginLocalDB.getHeaderToken()
            let str_doshaType = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
            param = ["doshas": str_doshaType.rawValue.capitalized]
        }
        else {
            self.callAPIfor_recommendedProducts()
            return
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_Category.removeAll()
                let mPCategoryModel = MPCategoryModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPCategoryModel.data.count != 0{
                    self.arr_Category.append(mPCategoryModel)
                }
                
                if mPCategoryModel.is_lock.lowercased() == "yes" {
                    self.personilizedProductsLocked = false
                }
                else {
                    self.personilizedProductsLocked = true
                }
                
                self.manageSection()
                
                //--
                if kSharedAppDelegate.userId == "" {
                    self.recommendedProductsLocked = false
                    self.callAPIfor_popularProducts()
                }
                else {
                    self.callAPIfor_recommendedProducts()
                }
                                
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.hideActivityIndicator()
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_recommendedProducts() {
        
        var nameAPI: endPoint = .mp_recommendedProducts
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_recommendedProducts
            getHeader = MPLoginLocalDB.getHeaderToken()
        }
        else {
            self.manageSection()
            
            //--
            self.callAPIfor_product_OfflersList()
            self.callAPIfor_popularProducts()
            return
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, headers: getHeader) { [self]  isSuccess, status, message, responseJSON in
            
            if isSuccess {
                self.arr_RecmmendedProduct.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_RecmmendedProduct.append(mPProductModel)
                }
                
                if mPProductModel.is_lock.lowercased() == "yes" {
                    self.recommendedProductsLocked = false
                }
                else {
                    self.recommendedProductsLocked = true
                }
                
                self.manageSection()
                
                //--
                self.callAPIfor_product_OfflersList()
                self.callAPIfor_popularProducts()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
        
    func callAPIfor_popularProducts() {
        
        var nameAPI: endPoint = .mp_popularProducts
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_popularProducts
            getHeader = MPLoginLocalDB.getHeaderToken()
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, headers: getHeader) {  isSuccess, status, message, responseJSON in
            
            if isSuccess {
                self.arr_PopularProducts.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_PopularProducts.append(mPProductModel)
                }
                self.manageSection()
                
                //--
                self.callAPIfor_featured_brands()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    func callAPIfor_featured_brands() {
        
        var nameAPI: endPoint = .mp_featured_brands
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_featured_brands
            getHeader = MPLoginLocalDB.getHeaderToken()
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_PopularBrand.removeAll()
                let mPCategoryModel = MPCategoryModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPCategoryModel.data.count != 0{
                    self.arr_PopularBrand.append(mPCategoryModel)
                }
                self.manageSection()
                
                //--
                self.callAPIfor_product_tranding()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_product_tranding() {
        
        var nameAPI: endPoint = .mp_product_tranding
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_product_tranding
            getHeader = MPLoginLocalDB.getHeaderToken()
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_ProductTranding.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_ProductTranding.append(mPProductModel)
                }
                self.manageSection()
                
                //--
                self.callAPIfor_product_topProducts()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    func callAPIfor_product_topProducts() {
        
        var nameAPI: endPoint = .mp_product_topProducts
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_product_topProducts
            getHeader = MPLoginLocalDB.getHeaderToken()
        }
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_TopDealsForYou.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_TopDealsForYou.append(mPProductModel)
                }
                self.manageSection()
                
                //--
                self.callAPIfor_product_newlylaunched()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    func callAPIfor_product_newlylaunched() {
        
        var nameAPI: endPoint = .mp_product_newlylaunched
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_product_newlylaunched
            getHeader = MPLoginLocalDB.getHeaderToken()
        }
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_Newlylaunched.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_Newlylaunched.append(mPProductModel)
                }
                self.manageSection()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_product_OfflersList() {
        
        let nameAPI: endPoint = .mp_user_offersList
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            getHeader = MPLoginLocalDB.getHeaderToken()
            
            Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .get, headers: getHeader) {  isSuccess, status, message, responseJSON in
                if isSuccess {
                    self.arr_OfferBanner.removeAll()
                    let mPProductModel = MPOfferListModel(JSON: responseJSON?.rawValue as! [String : Any])!
                    debugPrint(mPProductModel.data)
                    if mPProductModel.data.count != 0{
                        for offer_data in mPProductModel.data {
                            self.arr_OfferBanner.append(offer_data)
                        }
                    }
                    self.manageSection()
                    
                }else if status == "Token is Expired"{
                    callAPIfor_LOGIN()
                } else {
                    self.showAlert(title: status, message: message)
                }
            }
        }
    }
}

//MARK: - ProductViewAll
extension MPProductViewAllVC{
    func callAPIfor_brands() {
        
        var nameAPI: endPoint = .mp_brands
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_brands
            getHeader = MPLoginLocalDB.getHeaderToken()
        }
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_PopularBrand.removeAll()
                let mPCategoryModel = MPCategoryModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPCategoryModel.data.count != 0{
                    self.arr_PopularBrand.append(mPCategoryModel)
                }
                self.manageSection()
                
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_listBrandWise(brandID: String) {
        
        var nameAPI: endPoint = .mp_listBrandWise
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_listBrandWise
            getHeader = MPLoginLocalDB.getHeaderToken()
        }
        
        let finlName = String(format: nameAPI.rawValue, brandID)
        Utils.doAPICallMartketPlace(endPoint: finlName, method: .post, parameters: getProductAPIParam(), headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_Products.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_Products.append(mPProductModel)
                }
                self.manageSection()
                
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_listCategoryWise(categoryID: String, SuperVC: UIViewController) {
        
        if Connectivity.isConnectedToInternet {
            SuperVC.showActivityIndicator()
            
            var param = [String: Any]()
            var nameAPI: endPoint = .mp_listCategoryWise
            var getHeader = MPLoginLocalDB.getHeader_GuestUser()
            
            if kSharedAppDelegate.userId != "" {
                nameAPI = .mp_user_listCategoryWise
                getHeader = MPLoginLocalDB.getHeaderToken()
                let str_doshaType = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
                
                param = getProductAPIParam()
                param["doshas"] = str_doshaType.rawValue.capitalized
            }
            
            let finlName = String(format: nameAPI.rawValue, categoryID)
            Utils.doAPICallMartketPlace(endPoint: finlName, method: .post, parameters: getProductAPIParam(), headers: getHeader) {  isSuccess, status, message, responseJSON in
                if isSuccess {
                    self.arr_Products.removeAll()
                    let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                    if mPProductModel.data.count != 0{
                        self.arr_Products.append(mPProductModel)
                    }
                    self.manageSection()
                    
                }else if status == "Token is Expired"{
                    callAPIfor_LOGIN()
                } else {
                    self.showAlert(title: status, message: message)
                }
            }
        }
        else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: SuperVC)
        }
    }
    
    func callAPIfor_SimilarProducts(productID: String) {

        let nameAPI: endPoint = .mp_user_Similar_products
        let getHeader = MPLoginLocalDB.getHeaderToken()
        let finlName = String(format: nameAPI.rawValue, productID)

        Utils.doAPICallMartketPlace(endPoint: finlName, method: .post, parameters: getProductAPIParam(), headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_Products.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_Products.append(mPProductModel)
                }
                self.manageSection()
                
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    
    //Call For Sort And Filter
    func getProductAPIParam() -> [String : Any]{
        var params:[String : Any] = [:]
        params["sort_by"] = selectedSortBy
        
        if MPApplyFilter {
            debugPrint(self.dic_Filter)
            
            let brand_ids = self.dic_Filter["brand_filter"] as? String ?? ""
            let category_ids = self.dic_Filter["category_filter"] as? String ?? ""
            let PriceRange = self.dic_Filter["price_range"] as? String ?? ""
            let DeliveryTime = self.dic_Filter["delivery_time"] as? String ?? ""
            let Discounts = self.dic_Filter["discount"] as? String ?? ""
            
            params["brand_filter"] = brand_ids
            params["category_filter"] = category_ids
            params["price_range"] = PriceRange
            params["delivery_time"] = DeliveryTime
            params["discount"] = Discounts
            
            /*
            let selectBrandId = arr_PopularBrand.first?.data.filter { mPCategoryData in
                mPCategoryData.isSelect == true
            }.map { mPCategoryData in
                "\(mPCategoryData.id)"
            }.joined(separator: ",")
            
            let selectCatId = arr_Category.first?.data.filter { mPCategoryData in
                mPCategoryData.isSelect == true
            }.map { mPCategoryData in
                "\(mPCategoryData.id)"
            }.joined(separator: ",")
            
            params["brand_filter"] = selectBrandId
            params["category_filter"] = selectCatId
            params["price_range"] = mpFilter_Selected_PriceRange
            params["delivery_time"] = mpFilter_Selected_DeliveryTime
            params["discount"] = mpFilter_Selected_Discounts
            */
        }
        
        return params
    }
    func callAPIfor_popular_herbs() {
        
        var nameAPI: endPoint = .mp_popular_herbs
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_popular_herbs
            getHeader = MPLoginLocalDB.getHeaderToken()
        }
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: getProductAPIParam(), headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_HerbsProducts.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_HerbsProducts.append(mPProductModel)
                }
                self.manageSection()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_recent_products() {
        
        var nameAPI: endPoint = .mp_recently_product
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_recently_product
            getHeader = MPLoginLocalDB.getHeaderToken()
        }
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: getProductAPIParam(), headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                self.arr_RecentProducts.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_RecentProducts.append(mPProductModel)
                }
                self.manageSection()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_RecommendedProduct() {
        
        var nameAPI: endPoint = .mp_recommendedProducts
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_recommendedProducts
            getHeader = MPLoginLocalDB.getHeaderToken()
        }
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: getProductAPIParam(), headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_RecmmendedProduct.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_RecmmendedProduct.append(mPProductModel)
                }
                self.manageSection()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_popularProducts() {
        
        var nameAPI: endPoint = .mp_popularProducts
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_popularProducts
            getHeader = MPLoginLocalDB.getHeaderToken()
        }
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: getProductAPIParam(), headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_PopularProducts.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_PopularProducts.append(mPProductModel)
                }
                self.manageSection()
                
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }

    func callAPIfor_product_tranding() {
        
        var nameAPI: endPoint = .mp_product_tranding
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_product_tranding
            getHeader = MPLoginLocalDB.getHeaderToken()
        }
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: getProductAPIParam(), headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_ProductTranding.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_ProductTranding.append(mPProductModel)
                }
                self.manageSection()
                
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    func callAPIfor_product_topProducts() {
        
        var nameAPI: endPoint = .mp_product_topProducts
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_product_topProducts
            getHeader = MPLoginLocalDB.getHeaderToken()
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: getProductAPIParam(), headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_TopDealsForYou.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_TopDealsForYou.append(mPProductModel)
                }
                self.manageSection()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    func callAPIfor_product_newlylaunched() {
        
        var nameAPI: endPoint = .mp_product_newlylaunched
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_product_newlylaunched
            getHeader = MPLoginLocalDB.getHeaderToken()
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: getProductAPIParam(), headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_Newlylaunched.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_Newlylaunched.append(mPProductModel)
                }
                self.manageSection()
                
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    
}

//MARK: - Product Detail
extension MPProductDetailVC{
    
    func callAPIfor_product_details(pID: String) {
        
        showActivityIndicator()
        var nameAPI: endPoint = .mp_product_details
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_product_details
            getHeader = MPLoginLocalDB.getHeaderToken()
        }

        let finlName = String(format: nameAPI.rawValue, pID)
        Utils.doAPICallMartketPlace(endPoint: finlName, method: .get, headers: getHeader) {  isSuccess, status, message, responseJSON in
            DispatchQueue.main.async {
                self.hideActivityIndicator()
            }
            if isSuccess {
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                self.mpSelectProductData = mPProductModel.singleData
                self.reviewImages = self.mpSelectProductData?.images ?? []
                if self.mpSelectProductData?.images.count ?? 0 <= 0 {
                    let data = MPProductImages()
                    data?.image = self.mpSelectProductData?.thumbnail ?? ""
                    self.mpSelectProductData?.images.append(data!)
                }
                self.setProductData()
                if kSharedAppDelegate.userId != "" {
                    self.callAPIfor_product_Ratings(pID: pID)
                }
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_product_Ratings(pID: String) {
        let nameAPI: endPoint = .mp_user_get_product_review
        let finlName = String(format: nameAPI.rawValue, pID)

        Utils.doAPICallMartketPlace(endPoint: finlName, method: .get, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            if isSuccess {

                let mPProductReview = MPReviewModel(JSON: responseJSON?.rawValue as! [String : Any])!
                self.productReviews = mPProductReview
                self.setProductData()
                
            }else if status.lowercased() == "Token is Expired".lowercased() || status.lowercased() == "Authorization Token not found".lowercased(){
                callAPIfor_LOGIN()
                Utils.showAlertWithTitleInControllerWithCompletion("", message: "Something went wrong! Please try again.".localized(), okTitle: "Ok".localized(), controller: findtopViewController()!) {}
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    
    func callAPIfor_AddRecentlyProduct(pID: String) {

        var nameAPI: endPoint = .mp_user_add_recently_products
        var getHeader = MPLoginLocalDB.getHeaderToken()
        
        let param = ["product_id": pID]

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
            }else if status == "Token is Expired"{
            } else {
            }
        }
    }
}

//MARK:- Product Review
extension MPAllReviewVC{
    func callAPIfor_product_Ratings(pID: String) {
        let nameAPI: endPoint = .mp_user_get_product_review
        let finlName = String(format: nameAPI.rawValue, pID)

        Utils.doAPICallMartketPlace(endPoint: finlName, method: .get, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {

                let mPProductReview = MPReviewModel(JSON: responseJSON?.rawValue as! [String : Any])!
                self.productReviews = mPProductReview
                self.setProductData()
                
            }else if status.lowercased() == "Token is Expired".lowercased() || status.lowercased() == "Authorization Token not found".lowercased(){
                callAPIfor_LOGIN()
                Utils.showAlertWithTitleInControllerWithCompletion("", message: "Something went wrong! Please try again.".localized(), okTitle: "Ok".localized(), controller: findtopViewController()!) {}
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
}

//MARK: - Product Search
extension MPSearchVC{
    
    func callAPIfor_popular_herbs() {
        let nameAPI: endPoint = .mp_popular_herbs
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                //self.arr_HerbsProducts.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    //self.arr_HerbsProducts.append(mPProductModel)
                }
                self.manageSection()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_RecentlyProduct() {

        let nameAPI = endPoint.mp_recently_product
        let getHeader = MPLoginLocalDB.getHeaderToken()
        
        let params = ["sort_by": "", "sort_by_id": "", "brand_filter": "", "category_filter": "", "price_range": "", "delivery_time": "", "discount": ""]
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: params, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                self.arr_RecentlyProducts.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_RecentlyProducts.append(mPProductModel)
                }
                self.manageSection()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
}


//MARK: - Home Screen API CALLING
extension MPCartVC {
    func callAPIfor_popular_herbs() {
        let nameAPI: endPoint = .mp_popular_herbs
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_HerbsProducts.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_HerbsProducts.append(mPProductModel)
                }
                //self.manageSection()
                self.callAPIfor_popularProducts()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_popularProducts() {
        let nameAPI: endPoint = .mp_popularProducts
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post) {  isSuccess, status, message, responseJSON in
                    
            if isSuccess {
                self.arr_PopularProducts.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_PopularProducts.append(mPProductModel)
                }
                //self.manageSection()
                
                //--
                self.callAPIfor_product_tranding()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_product_tranding() {
        let nameAPI: endPoint = .mp_product_tranding
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.arr_ProductTranding.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_ProductTranding.append(mPProductModel)
                }
                //self.manageSection()
                
                //--
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                //self.collectionProductlist_EmptyCart.isHidden = false
            }
        }
    }
}


//MARK: - Favorite Screen
extension MPFavoriteVC {
    
    func callAPIforGetWishListProduct() {
        
        self.showActivityIndicator()
        var nameAPI: endPoint = .mp_none
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_Wishlist
            getHeader = MPLoginLocalDB.getHeaderToken()
        }
        else {
            callAPIfor_product_tranding()
            return
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .get, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                self.arr_FavoriteProduct.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_FavoriteProduct.append(mPProductModel)
                }
                
                if self.arr_FavoriteProduct.count == 0 {
                    self.callAPIfor_product_tranding()
                }
                else {
                    self.manageSection()
                }
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_product_tranding() {
        
        self.showActivityIndicator()
        var nameAPI: endPoint = .mp_product_tranding
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_product_tranding
            getHeader = MPLoginLocalDB.getHeaderToken()
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                self.arr_ProductTranding.removeAll()
                let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count != 0{
                    self.arr_ProductTranding.append(mPProductModel)
                }
                self.manageSection()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
}
