//
//  MPAddressModel.swift
//  HourOnEarth
//
//  Created by Sachin Patoliya on 03/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import ObjectMapper


class MPAddressModel: Mappable{
    
    var status: String = ""
    var data: [MPAddressData] = []
    
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

class MPAddressData: Mappable{
    
    var address: String = ""
    var address_type: String = ""
    var building_no: String = ""
    var city: String = ""
    var full_name: String = ""
    var id: Int = 0
    var landmark: String = ""
    var phone_number: String = ""
    var pincode: String = ""
    var state: String = ""
    var email: String = ""

    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        address <- map["address"]
        address_type <- map["address_type"]
        building_no <- map["building_no"]
        city <- map["city"]
        full_name <- map["full_name"]
        id <- map["id"]
        landmark <- map["landmark"]
        phone_number <- map["phone_number"]
        email <- map["email"]
        pincode <- map["pincode"]
        state <- map["state"]
    }
}


//MARK:- Add Address
extension MPAddressVC {
    func callAPIfor_GetAddress() {
        let nameAPI: endPoint = .mp_user_mycart_getUserAddress
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .get, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            if isSuccess {
//
                let mPaddressData = MPAddressModel(JSON: responseJSON?.rawValue as! [String : Any])!
                self.addressData = mPaddressData
                if self.isLoadFirstTime{
                    self.isLoadFirstTime = false
                    let data = MPAddressLocalDB.getAddress()
                    for i in 0..<(self.addressData?.data.count ?? 0){
                        if self.addressData?.data[i].id == data.id{
                            self.selectedAddress = i
                            MPAddressLocalDB.saveAddress(strData: self.addressData?.data[safe: self.selectedAddress]?.toJSONString() ?? "")
                        }
                    }
                }
                self.setAddressData()
                
            }else if status.lowercased() == "Token is Expired".lowercased() || status.lowercased() == "Authorization Token not found".lowercased(){
                callAPIfor_LOGIN()
                Utils.showAlertWithTitleInControllerWithCompletion("", message: "Something went wrong! Please try again.".localized(), okTitle: "Ok".localized(), controller: findtopViewController()!) {}
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_AddEditAddress() {
        let nameAPI: endPoint = isEditAddress ? .mp_user_mycart_editUserAddress : .mp_user_mycart_addNewUserAddress
        var param = addAddressDict
        if isEditAddress{
            param["id"] = addressData?.data[selectedAddress].id ?? 0
        }
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.callAPIfor_GetAddress()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    
    func callAPIfor_DeleteAddress() {
        self.showActivityIndicator()
        let nameAPI: endPoint = .mp_user_DeleteAddress

        let param = ["id": addressData?.data[selectedAddress].id ?? 0]
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                self.callAPIfor_GetAddress()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
}


//MARK:- Add Address
extension MPMyAddressVC {
    func callAPIfor_GetAddress() {
        self.showActivityIndicator()
        
        let nameAPI: endPoint = .mp_user_mycart_getUserAddress
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .get, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            if isSuccess {
//
                let mPaddressData = MPAddressModel(JSON: responseJSON?.rawValue as! [String : Any])!
                self.addressData = mPaddressData
                if self.isLoadFirstTime{
                    self.isLoadFirstTime = false
                    let data = MPAddressLocalDB.getAddress()
                    for i in 0..<(self.addressData?.data.count ?? 0){
                        if self.addressData?.data[i].id == data.id{
                            self.selectedAddress = i
                            MPAddressLocalDB.saveAddress(strData: self.addressData?.data[safe: self.selectedAddress]?.toJSONString() ?? "")
                        }
                    }
                }
                self.setAddressData()
                
            }else if status.lowercased() == "Token is Expired".lowercased() || status.lowercased() == "Authorization Token not found".lowercased(){
                callAPIfor_LOGIN()
                Utils.showAlertWithTitleInControllerWithCompletion("", message: "Something went wrong! Please try again.".localized(), okTitle: "Ok".localized(), controller: findtopViewController()!) {}
            } else {
                self.showAlert(title: status, message: message)
            }
            self.hideActivityIndicator()
        }
    }
    
    func callAPIfor_AddEditAddress() {
        let nameAPI: endPoint = isEditAddress ? .mp_user_mycart_editUserAddress : .mp_user_mycart_addNewUserAddress
        var param = addAddressDict
        if isEditAddress{
            param["id"] = addressData?.data[selectedAddress].id ?? 0
        }
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                self.callAPIfor_GetAddress()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    
    func callAPIfor_DeleteAddress() {
        self.showActivityIndicator()
        let nameAPI: endPoint = .mp_user_DeleteAddress

        let param = ["id": addressData?.data[selectedAddress].id ?? 0]
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                self.callAPIfor_GetAddress()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
}



class MPAddressLocalDB: NSObject
{
    class func saveAddress(strData: String)
    {
        //--
        UserDefaults.standard.set(strData, forKey: "selectedaddress")
        UserDefaults.standard.synchronize()
    }
    class func getAddress() -> MPAddressData
    {
        let login_response = UserDefaults.standard.object(forKey: "selectedaddress") as? String ?? ""
        if login_response.count != 0
        {
            return MPAddressData(JSONString: login_response)!
        }
        else
        {
            return MPAddressData()
        }
    }
    
    class func redirectToSelectAddress(completion: (() -> ())?){
        let vc = MPAddressVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.isFromChangeAddress = true
        vc.completionSelectAddress = {
            completion?()
        }
        findtopViewController()!.navigationController?.pushViewController(vc, animated: true)
    }
    
    class func showWholeAddress(addressModel: MPAddressData?) -> String {
        var address = ""
        if addressModel == nil{
            return ""
        }
        if addressModel?.building_no != "" {
            address = addressModel?.building_no ?? ""
        }
        
        if addressModel?.address != "" {
            address = address + ", " + (addressModel?.address ?? "")
        }
        
        if addressModel?.city != "" {
            address = address + ", " + (addressModel?.city ?? "")
        }
        
        if addressModel?.state != "" {
            address = address + "\n" + (addressModel?.state ?? "")
        }
        if addressModel?.pincode != "" {
            address = address + " - " + (addressModel?.pincode ?? "")
        }
        
        if addressModel?.landmark != "" {
            address = address + "\nLandmark: " + (addressModel?.landmark ?? "")
        }
        
        if addressModel?.phone_number != "" {
            address = address + "\n" + (addressModel?.phone_number ?? "")
        }
        
        
        
        return address
    }
    
    class func showWholeAddressForEnterPincodeScreen(addressModel: MPAddressData?) -> String {
        var address = ""
        if addressModel == nil{
            return ""
        }
        if addressModel?.building_no != "" {
            address = addressModel?.building_no ?? ""
        }

        if addressModel?.address != "" {
            address = address + ", " + (addressModel?.address ?? "")
        }

        if addressModel?.city != "" {
            address = address + ", " + (addressModel?.city ?? "")
        }
        
        if addressModel?.state != "" {
            address = address + ", " + (addressModel?.state ?? "")
        }
        if addressModel?.pincode != "" {
            address = address + ", " + (addressModel?.pincode ?? "")
        }
        if addressModel?.phone_number != "" {
            address = address + ", " + (addressModel?.phone_number ?? "")
        }
        
        if addressModel?.landmark != "" {
            address = address + "\nLandmark: " + (addressModel?.landmark ?? "")
        }
        
        return address
    }
}

