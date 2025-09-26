//
//  ARTodaysGoalModel.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 27/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import Foundation
import Alamofire


class TodaysGoalViewModel {
    
    func getTodaysGoal(body: [String: Any]?, endpoint: endPoint, completion: @escaping (_ status: Status, _ result: TodayGoalResponseModel?, _ error: Error?) -> Void) {
        
        let request = APIRequest(baseURL: kBaseNewURL, endpoint: endpoint, httpMethod: .POST, requestBody: body)
        APIService.shared.execute(request, responseType: TodayGoalResponseModel.self, apiType: .none) { result in
            DispatchQueue.main.async {
                completion(Status.loading, nil, nil)
            }
            switch(result) {
            case .success(let s):
                DispatchQueue.main.async {
                    completion(Status.success, s, nil)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(Status.error, nil, error)
                }
            }
        }
    }
    
        
    func getCouponsFromServer(completion: @escaping (Bool, String, [CouponCompanyModel])->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.getAllThirdPartyCouponsList.rawValue
            
            AF.request(urlString, method: .post, parameters: ["language_id" : Utils.getLanguageId()], encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        completion(false, "", [CouponCompanyModel]())
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? "Fail to get coupons, please try after some time".localized()
                    var data = [CouponCompanyModel]()
                    if let dataArray = dicResponse["data"] as? [[String: Any]] {
                        data = dataArray.map{ CouponCompanyModel(fromDictionary: $0) }
                    }
                    let isSuccess = (status.lowercased() == "Success".lowercased())
                    completion(isSuccess, message, data)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription, [CouponCompanyModel]())
                }
            }
        } else {
            completion(false, NO_NETWORK, [CouponCompanyModel]())
        }
    }
    
    
}

//MARK: - TODAYS GOAL

struct TodayGoalResponseModel: Codable {
    let status: String?
    let message: String?
    let data: [response_Data]?
}

struct response_Data: Codable {
    let id: String?
    let asana_type: String?
    let favourite_type: String?
    let favorite_id: String?
    let language_id: String?
    let goal_asana_type: String?
    let favorite_asana_type: String?
    let description: String?
    let image: String?
    let status: String?
    let goal_data: goal_data?
}

struct goal_data: Codable {
    let user_watch_count: String?
    let user_watch_count_done: Int?
    let user_watch_count_total: Int?
    let user_video_favorit_id: String?
    let watch_video_id: String?
    let ayuseeds: Int?
    let total_people_completed: String?
}
