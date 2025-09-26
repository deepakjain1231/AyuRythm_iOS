//
//  AyuSeedsRedeemManager.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 27/10/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AyuSeedsRedeemManager {
    
    typealias Completion = (_ success: Bool, _ isSubscriptionResumeSuccess: Bool,_ title: String, _ message: String)->Void
    
    var available_ayuseed = 0
    var lifetimeSeeds = 0
    var spentSeeds = 0
    
    var accessPoint = 0
    var name = ""
    var category: String?
    var promoCode = ""
    var favID = 0
    var isShowSuccessAlert = true
    var extraParam: [String: Any]?
    
    var isSubscription = false
    var isSubscriptionPaused = false
    var subscriptionHistoryId = ""
    
    weak var presentingVC: UIViewController?
    var completion: Completion?
    
    static let shared = AyuSeedsRedeemManager()
    
    func redeemItem(accessPoint: Int, name: String, category: String? = nil, favID: Int, presentingVC: UIViewController, isShowSuccessAlert: Bool = true, extraParam: [String: Any]? = nil, completion: @escaping Completion) {
        self.accessPoint = accessPoint
        self.name = name
        self.category = category
        self.favID = favID
        self.presentingVC = presentingVC
        self.isShowSuccessAlert = isShowSuccessAlert
        self.extraParam = extraParam
        self.completion = completion
        
        //fetchTransactionHistory()
        fetchAvailableSeeds()
    }
}

// MARK: - API calls
extension AyuSeedsRedeemManager {
    
    //MARK:- API call to retrive transaction history
    func fetchTransactionHistory() {
        guard let presentingVC = presentingVC else { return }
        
        if !Utils.isConnectedToNetwork() {
            return presentingVC.hideActivityIndicator(withMessage: NO_NETWORK)
        }
        
        presentingVC.showActivityIndicator()
        let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
        Utils.doAPICall(endPoint: .transactionhistoryV2, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let transHistory = responseJSON["response"].arrayValue
                self.isSubscription = responseJSON["is_subscription"].boolValue
                self.isSubscriptionPaused = responseJSON["is_subscription_pause"].boolValue
                self.subscriptionHistoryId = responseJSON["subscription_history_id"].stringValue
                
                self.spentSeeds = 0
                self.lifetimeSeeds = 0
                transHistory.forEach { trans in
                    if let trancType = trans["type"].string {
                        let points = trans["points"].intValue
                        if trancType == "spent" {
                            self.spentSeeds += points
                        } else {
                            self.lifetimeSeeds += points
                        }
                    }
                }
                presentingVC.hideActivityIndicator()
                if self.isSubscription && self.isSubscriptionPaused {
                    ActiveSubscriptionPlanVC.showResumeSubscriptionAlert(subscriptionHistoryId: self.subscriptionHistoryId, fromVC: presentingVC) { success, title, message in
                        if success {
                            self.completion?(success, true, title, message)
                        } else {
                            presentingVC.hideActivityIndicator(withTitle: title, Message: message)
                        }
                    }
                } else {
                    self.openRedeemPopUP(available_seed: self.lifetimeSeeds - self.spentSeeds)
                }
            } else {
                presentingVC.hideActivityIndicator(withTitle: status, Message: message)
            }
        }
    }
    
    //MARK:- API call to fatch available seeds
    func fetchAvailableSeeds() {
        guard let presentingVC = presentingVC else { return }
        
        if !Utils.isConnectedToNetwork() {
            return presentingVC.hideActivityIndicator(withMessage: NO_NETWORK)
        }
        
        presentingVC.showActivityIndicator()
        let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
        Utils.doAPICall(endPoint: .Available_ayuseedinfo, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let ayuseeds = responseJSON["ayuseeds"].intValue
                self.isSubscription = responseJSON["is_subscription"].boolValue
                self.isSubscriptionPaused = responseJSON["is_subscription_pause"].boolValue
                self.subscriptionHistoryId = responseJSON["subscription_history_id"].stringValue

                presentingVC.hideActivityIndicator()
                if self.isSubscription && self.isSubscriptionPaused {
                    ActiveSubscriptionPlanVC.showResumeSubscriptionAlert(subscriptionHistoryId: self.subscriptionHistoryId, fromVC: presentingVC) { success, title, message in
                        if success {
                            self.completion?(success, true, title, message)
                        } else {
                            presentingVC.hideActivityIndicator(withTitle: title, Message: message)
                        }
                    }
                } else {
                    self.openRedeemPopUP(available_seed: ayuseeds)
                }

            } else {
                presentingVC.hideActivityIndicator(withTitle: status, Message: message)
            }
        }
    }
    
    
    func openRedeemPopUP(available_seed: Int) {
        let alert = UIAlertController(title: "Content Locked!".localized(), message: String(format: "Use your seeds to unlock\nYou have %d points \n\nPoints needed to unlock:\n%d".localized(), available_seed, accessPoint), preferredStyle: .alert)
        let buySeedAndUnlock = UIAlertAction(title: "Buy Seeds & Unlock".localized(), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Buy Seeds & Unlock")
            self.promoCode = ""
            BuyAyuSeedsViewController.showScreen(presentingVC: self.presentingVC) { [weak self] (isSuccess, message) in
                if isSuccess, let strongSelf = self {
                    strongSelf.callRedeemAPI(fav_type: strongSelf.name, fav_id: strongSelf.favID, access_point: strongSelf.accessPoint)
                }
            }
        })
        let redeem = UIAlertAction(title: "Redeem & Unlock".localized(), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Redeem & Unlock")
            self.promoCode = ""
            self.callRedeemAPI(fav_type: self.name, fav_id: self.favID, access_point: self.accessPoint)
        })
        let promocode = UIAlertAction(title: "Have a promo code?".localized(), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Have a promo code?")
            let alert = UIAlertController(title: "Enter promo code".localized(), message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Promo code".localized()
            }

            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .destructive, handler: { [weak self] (_) in
                self?.openRedeemPopUP(available_seed: available_seed)
            }))
            alert.addAction(UIAlertAction(title: "Redeem".localized(), style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                print("Text field: \(textField!.text ?? "")")
                self.promoCode = textField!.text ?? ""
                self.validateReferralCodeFromServer(code: textField?.text ?? "")
            }))
            self.presentingVC?.present(alert, animated: true, completion: nil)
        })

        let cancel = UIAlertAction(title: "Cancel".localized(), style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        })
        if available_seed < accessPoint {
        //if (lifetimeSeeds - spentSeeds) < accessPoint {
            alert.addAction(buySeedAndUnlock)
        } else {
            alert.addAction(redeem)
        }
        alert.addAction(promocode)
        alert.addAction(cancel)
        self.presentingVC?.present(alert, animated: true, completion: nil)
    }

    func callRedeemAPI(fav_type: String, fav_id: Int, access_point: Int) {
        guard let presentingVC = presentingVC else { return }
        
        presentingVC.showActivityIndicator()
        var params = ["favorite_type": fav_type, "favorite_id": fav_id, "access_points": access_point, "promocode": promoCode, "language_id" : Utils.getLanguageId()] as [String : Any]
        if let extraParam = extraParam {
            params.merge(extraParam) { (_, new) in new }
        }
        
        Utils.doAPICall(endPoint: .redeemPoints, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                //complete progress here
                let title = responseJSON?["title"].string ?? status
                self.completion?(true, false, title, message)
                
                presentingVC.hideActivityIndicator()
                if self.isShowSuccessAlert {
                    let category = self.category ?? self.name
                    self.showUnlockItemSuccessMessage(category: category, response: responseJSON?.dictionaryObject)
                }
            } else {
                let title = responseJSON?["title"].string ?? status
                presentingVC.hideActivityIndicator(withTitle: title, Message: message)
            }
        }
    }
    
    private func validateReferralCodeFromServer(code: String) {
        guard let presentingVC = presentingVC else { return }
        
        if !Utils.isConnectedToNetwork() {
            return presentingVC.hideActivityIndicator(withMessage: NO_NETWORK)
        }
        
        presentingVC.showActivityIndicator()
        let params = ["referral_code": code, "type": "1"] as [String : Any]
        Utils.doAPICall(endPoint: .referralcodeValidation, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                
                presentingVC.hideActivityIndicator()
                print("Valid referral code so now Redeem & Unlock content")
                self.callRedeemAPI(fav_type: self.name, fav_id: self.favID, access_point: self.accessPoint)
            } else {
                let title = responseJSON?["title"].string ?? status
                presentingVC.hideActivityIndicator(withTitle: title, Message: message)
            }
        }
    }
    
    static func fetchAvailableSeedsInfo(completion: @escaping (Bool, String, Int, Int)->Void) {
        let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
        var lifetimeSeeds = 0
        var spentSeeds = 0
        Utils.doAPICall(endPoint: .transactionhistoryV2, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let transHistory = responseJSON["response"].arrayValue
                transHistory.forEach { trans in
                    if let trancType = trans["type"].string {
                        let points = trans["points"].intValue
                        if trancType == "spent" {
                            spentSeeds += points
                        } else {
                            lifetimeSeeds += points
                        }
                    }
                }
            }
            completion(isSuccess, message, lifetimeSeeds, spentSeeds)
        }
    }
    
    static func callRedeemAPI(fav_type: String, fav_id: Int, access_point: Int, promoCode: String = "", extraParam: [String: Any]?, completion: @escaping (Bool, String, String)->Void) {
        let urlString = kBaseNewURL + endPoint.redeemPoints.rawValue
        
        var params = ["favorite_type": fav_type, "favorite_id": fav_id, "access_points": access_point, "promocode": promoCode, "language_id" : Utils.getLanguageId()] as [String : Any]
        if let extraParam = extraParam {
            params.merge(extraParam) { (_, new) in new }
        }
        print("API URL:====\(urlString)\n\nParams : \(params)")
        
        AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
            
            switch response.result {
            case .success( _):
                print(response)
                guard let dicResponse = (response.value as? [String: AnyObject]) else {
                    return completion(false, "Error".localized(), "")
                }
                let status = dicResponse["status"] as? String
                let title = dicResponse["title"] as? String ?? ""
                let message = dicResponse["message"] as? String ?? ""
                
                let isSuccess = !(status == "failed" || status == "error")
                completion(isSuccess, title, message)
                
            case .failure(let error):
                print(error)
                return completion(false, "Error".localized(), error.localizedDescription)
            }
        }
    }
}

extension AyuSeedsRedeemManager {
    func showUnlockItemSuccessMessage(category: String, response: [String: Any]? = nil) {
        guard let presentingVC = presentingVC else { return }
        
        let status = response?["status"] as? String ?? ""
        let isSubscribe = response?["isSubscribe"] as? String ?? String(response?["isSubscribe"] as? Int ?? 0)
        var message = "unlocked successfully, valid for 1 month".localized()
        if status == "success", isSubscribe == "1" {
            message = response?["Message"] as? String ?? (response?["message"] as? String ?? "unlocked successfully".localized())
        } else {
            message = category.capitalizingFirstLetter().localized() + " " + message
        }
        print("----> message : ", message)
        Utils.showAlertWithTitleInController("Success".localized(), message: message, controller: presentingVC)
    }
}
