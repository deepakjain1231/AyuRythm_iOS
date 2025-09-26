//
//  MPLoginModel.swift
//  HourOnEarth
//
//  Created by Maulik Vora on 31/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import ObjectMapper


class MPLoginDataModel: Mappable {

    var token: String = ""
    var user: String = ""

    init() {
    }

    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        token <- map["token"]
        user <- map["user"]
        
    }
}
class MPLoginUser: Mappable {
    
    var id: String = ""
    var full_name: String = ""
    var phone: String = ""
    var email: String = ""
    var fax: String = ""
    var propic: String = ""
    var zip_code: String = ""
    var city: String = ""
    var country: String = ""
    var address: String = ""
    var balance: String = ""
    var email_verified: String = ""
    var affilate_code: String = ""
    var affilate_income: String = ""
    var affilate_link: String = ""
    var ban: String = ""
    var type: String = ""
    var package_end_date: String = ""

    init() {
    }

    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        
        id <- map["id"]
        full_name <- map["full_name"]
        phone <- map["phone"]
        email <- map["email"]
        fax <- map["fax"]
        propic <- map["propic"]
        zip_code <- map["zip_code"]
        city <- map["city"]
        country <- map["country"]
        address <- map["address"]
        balance <- map["balance"]
        email_verified <- map["email_verified"]
        affilate_code <- map["affilate_code"]
        affilate_income <- map["affilate_income"]
        affilate_link <- map["affilate_link"]
        ban <- map["ban"]
        type <- map["type"]
        package_end_date <- map["package_end_date"]
     
    }
}

//MARK: - API CALLING
//extension MPHomeVC {
func callAPIfor_LOGIN(completion: (() -> ())? = nil) {
    
    if completion != nil{
        completion?()
    }
    /*
    guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
        return
    }
    let ayutythmUserEmail = empData["email"] as? String ?? ""
    
    let nameAPI: endPoint = .mp_login
    let params = ["email" : ayutythmUserEmail,
                  "password": "12345678"] as [String : Any]
    Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: params) {  isSuccess, status, message, responseJSON in
        //self.hideActivityIndicator()
        if isSuccess, let dataJSON = responseJSON?["data"] {
            let result = MPLoginDataModel(JSON: dataJSON.rawValue as! [String : Any])!
            
            //--
            if let jsonSTR = result.toJSONString(){
                MPLoginLocalDB.saveLoginInfo(strData: jsonSTR)
//                let data = MPCartManager.getCartData()
//                if data.data.count > 0{
//                    MPCartManager.removeCartData()
//                    addProductToCart(productData: data.data) { status in
//                        MPCartManager.notifyCartUpdation()
//                    }
//                }
            }
            if completion != nil{
                completion?()
            }
            
        } else {
            //self.showAlert(title: status, message: message)
        }
    }*/
}
//}
