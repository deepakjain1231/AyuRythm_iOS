//
//  MPFilterModel.swift
//  HourOnEarth
//
//  Created by Maulik Vora on 13/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import ObjectMapper

//class MPFilterData: Mappable{
//
//    var title: String = ""
//    var isSelect: Bool = false
//
//    init() {
//    }
//
//    required init?(map: Map) {
//    }
//
//    // Mappable
//    func mapping(map: Map) {
//        title <- map["title"]
//    }
//}



//For My Order List
class MPFilterModel: Mappable {
    
    var status: String = ""
    var data: [MPFilterData] = []
    var singleData: MPFilterData?
    
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


class MPFilterData: Mappable{
    
    var id: Int = 0
    var title: String = ""
    var display_order: Int = 0
    var status: Bool = false
    var created_at: String = ""
    var updated_at: String = ""
    var filter_selection_type: String = ""
    var filter_value: [MPFilterSubDataOption] = []

    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        display_order <- map["display_order"]
        status <- map["status"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        filter_value <- map["filter_value"]
        filter_selection_type <- map["filter_selection_type"]
    }
}

class MPFilterSubDataOption: Mappable{
    
    var id: Int = 0
    var name: String = ""
    var isSelect: Bool = false
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        isSelect <- map["isSelect"]
    }
}












//MARK: - API Call
extension MPFilterVC {
    
    func callapiforgetFilterOption() {
        self.showActivityIndicator()
        var params = [String: Any]()
        var nameAPI: endPoint = .mp_product_filterOption
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_product_filterOption
            getHeader = MPLoginLocalDB.getHeaderToken()
            params["screen_name"] = self.str_Screen_Name
            params["screen_id"] = str_ScreenID
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: params, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                self.arr_FiltterOption.removeAll()
                let mPProductModel = MPFilterModel(JSON: responseJSON?.rawValue as! [String : Any])!
                if mPProductModel.data.count > 0{
                    self.arr_FiltterOption.append(mPProductModel)
                }
                self.setupPreviousSelection()
                self.tableView_Type.reloadData()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    
    func setupPreviousSelection() {
        
        if let arrMainData = self.arr_FiltterOption.first?.data {
            var key_Name = ""
            var main_DataIndx = 0
            for main_data in arrMainData {
                let mainDataTitle = main_data.title
                let multiselection = main_data.filter_selection_type
                if multiselection == "multiple" {
                    if mainDataTitle.lowercased().contains("brand") {
                        key_Name = "brand_filter"
                    }
                    else if mainDataTitle.lowercased().contains("category") {
                        key_Name = "category_filter"
                    }
                    
                    if key_Name != "" {
                        var subDataIndx = 0
                        let branids = self.dic_FilterSelection[key_Name] as? String ?? ""
                        for subfilterDic in main_data.filter_value {
                            let iddss = "\(subfilterDic.id)"
                            if branids == iddss {
                                self.arr_FiltterOption.first?.data[main_DataIndx].filter_value[subDataIndx].isSelect = true
                            }
                            else {
                                self.arr_FiltterOption.first?.data[main_DataIndx].filter_value[subDataIndx].isSelect = false
                            }
                            subDataIndx = subDataIndx + 1
                        }
                    }
                }
                main_DataIndx = main_DataIndx + 1
            }
        }
        
        
    }
}
