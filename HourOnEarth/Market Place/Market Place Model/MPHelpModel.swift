//
//  HomeModel.swift
//  driver
//
//  Created by Deepak Jain on 27/02/21.
//

import Foundation
import ObjectMapper


class MPHelpFaqModel: Mappable{
    
    var status: String = ""
    var data: [MPHelpFaqData] = []
    
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

class MPHelpFaqData: Mappable{
    
    var id: Int = 0
    var title: String = ""
    var details: String = ""
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        details <- map["details"]
    }
}




//MARK: - API CALlLING
//HOME SCREEN ..........................

extension MpHelpVC {
    
    func callAPIforGetFaq() {

        showActivityIndicator()
        let nameAPI: endPoint = .mp_UserOrderHelpFaq
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .get, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
                self.hideActivityIndicator()
                if isSuccess {
                    self.arr_HelpData.removeAll()
                    let mPHelpModel = MPHelpFaqModel(JSON: responseJSON?.rawValue as! [String : Any])!
                    if mPHelpModel.data.count > 0{
                        self.arr_HelpData.append(mPHelpModel)
                    }
                    self.tbl_View.reloadData()
                }else if status == "Token is Expired" {
                    callAPIfor_LOGIN()
                } else {
                    self.showAlert(title: status, message: message)
                }
            }

        
        
        
        
        
        
        
        
        
        
        
//        ServiceCustom.shared.requestURL(URL_FAQ, Method: .get, parameters: nil, progress: true, current_view: self) { json, success, error in
//
//            if let errorr = error {
//                Utils.showAlertWithTitleInController(APP_NAME, message: errorr.localizedDescription, controller: self)
//                return
//            }
//            else {
//                if let response = json {
//                    let status = response["status"] as? Bool ?? false
//                    if status {
//                        self.arr_HelpData.removeAll()
//                        let mPHelpModel = MPHelpFaqModel(JSON: response)!
//                        if mPHelpModel.data.count != 0{
//                            self.arr_HelpData.append(mPHelpModel)
//                        }
//                        self.tbl_View.reloadData()
//                    }
//                    else {
//                        self.showAlert(title: "", message: "Something went wrong".localized())
//                    }
//                }
//            }
//        }
    }
}
