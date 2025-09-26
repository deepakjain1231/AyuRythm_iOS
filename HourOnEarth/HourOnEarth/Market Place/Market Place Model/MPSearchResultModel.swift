//
//  MPSearchResultModel.swift
//  HourOnEarth
//
//  Created by Maulik Vora on 23/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import ObjectMapper

class MPSearchResultModel: Mappable{

    var data: [MPSearchResultData] = []
    

    init() {
    }

    required init?(map: Map) {
    }

    // Mappable
    func mapping(map: Map) {
        data <- map["data"]
    }
}
class MPSearchResultData: Mappable{

    var id: Int = 0
    var search_type: String = ""
    var title: String = ""
    

    required init?(map: Map) {
    }

    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        search_type <- map["search_type"]
        title <- map["title"]
        
    }
}








//MARK: - Product Search Result
extension MPSearchVC{
    
    func callAPIfor_search_item(term: String) {
        let params = ["term" : term] as [String : Any]
        let nameAPI: endPoint = .mp_search_item
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: params) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                
                self.mpSearchResultModel = MPSearchResultModel(JSON: responseJSON?.rawValue as! [String : Any])!
                self.manageSearchResult()
                
                if self.mpSearchResultModel.data.count == 0 {
                    self.showNoDataSearch(hideDoYouMean: true)
                    self.callAPIfor_search_item_do_you_mean(term: term)
                }else{
                    self.hideNoDataSearch()
                    if self.isSpeakSearchApiCall {
                        if let dic_First = self.mpSearchResultModel.data.first {
                            if dic_First.search_type == MPSearchResultType.SearchBrand.rawValue {
                                //--
                                let dicCategroy = MPCategoryData()
                                dicCategroy.id = dic_First.id
                                dicCategroy.name = dic_First.title

                                //--
                                let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
                                vc.str_Title = dic_First.title
                                vc.selectCategory = dicCategroy
                                vc.screenFrom = .MP_brandProductOnly
                                vc.mpDataType = .brandAllProduct
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            else if dic_First.search_type == MPSearchResultType.SearchCategory.rawValue {
                                //--
                                let dicCategroy = MPCategoryData()
                                dicCategroy.id = dic_First.id
                                dicCategroy.name = dic_First.title

                                //--
                                let vc = MPProductViewAllVC.instantiate(fromAppStoryboard: .MarketPlace)
                                vc.str_Title = dic_First.title
                                vc.selectCategory = dicCategroy
                                vc.screenFrom = .MP_categoryProductOnly
                                vc.mpDataType = .categoryAllProduct
                                vc.selected_productID = "\(dic_First.id)"
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            else{
                                //--
                                self.mpSearchResultModel = MPSearchResultModel()
                                self.manageSearchResult()
                                let vc = MPProductDetailVC.instantiate(fromAppStoryboard: .MarketPlace)
                                vc.str_productID = "\(dic_First.id)"
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                    
                }
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_search_item_do_you_mean(term: String) {
        let params = ["term" : term] as [String : Any]
        let nameAPI: endPoint = .mp_search_item_do_you_mean
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: params) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                
                self.mpDoyouMeanModel = MPSearchResultModel(JSON: responseJSON?.rawValue as! [String : Any])!
                self.manageSearchResult()

                if self.mpDoyouMeanModel.data.count == 0{
                    self.showNoDataSearch(hideDoYouMean: true)
                }else{
                    self.showNoDataSearch(hideDoYouMean: false)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if self.mpDoyouMeanModel.data.count == 0{
                        self.showNoDataSearch(hideDoYouMean: true)
                    }else{
                        self.showNoDataSearch(hideDoYouMean: false)
                    }
                }
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
}
