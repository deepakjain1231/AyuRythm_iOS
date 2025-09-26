//
//  MPCartManager.swift
//  HourOnEarth
//
//  Created by CodeInfoWay CodeInfoWay on 6/25/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation
import UIKit
//import MoEngage

class MPWishlistManager: NSObject
{
    
    class func addToWishList(product: MPProductData, completion: (() -> ())?){

        if product.WISHLIST == 0 {
            checkUserLoginOrNot_addWishList(product: product) {
                completion!()
            }
        }
        else {
            removeWishlistProduct(product: product) {
                completion!()
            }
        }
        
        
    }
    
    class func removeWishlistProduct(product: MPProductData, completion: (() -> ())?) {
        if MPLoginLocalDB.isUserLoggedIn(){
            removeProductFromWishList(productId: "\(product.id)") { status in
                if status{
                    completion!()
                }
            }
        }
    }
    
    class func setWishlistButtonTitle(btnWishlist: UIButton, product: MPProductData){
        DispatchQueue.main.async {
            
            if product.WISHLIST == 0 {
                btnWishlist.setImage(UIImage.init(named: "favorite"), for: .normal)
            }
            else {
                btnWishlist.setImage(UIImage.init(named: "icon_wishlist_selected"), for: .normal)
            }
            
            

//            let isAvail = checkIfProductAvailable(productId: product.id)
//            btnWishlist.setImage(isAvail ? UIImage.init(named: "like-selected") : UIImage.init(named: "favorite"), for: .normal)
        }
    }
    
    class func addToWishlistButton_Action(btnWishlist: UIButton, productData: MPProductData?, completion: (() -> ())? = nil) {
        MPWishlistManager.addToWishList(product: productData!) {
            if completion != nil {
                let producccc = productData
                if productData?.WISHLIST == 0 {
                    producccc?.WISHLIST = 1
                }
                else {
                    producccc?.WISHLIST = 0
                }
                MPWishlistManager.setWishlistButtonTitle(btnWishlist: btnWishlist, product: producccc!)
                completion!()
            }else{
                let producccc = productData
                if productData?.WISHLIST == 0 {
                    producccc?.WISHLIST = 1
                }
                else {
                    producccc?.WISHLIST = 0
                }
                MPWishlistManager.setWishlistButtonTitle(btnWishlist: btnWishlist, product: producccc!)
                completion?()
            }
        }
    }
    
    class func checkUserLoginOrNot_addWishList(product: MPProductData, completion: (() -> ())?){
        if MPLoginLocalDB.isUserLoggedIn(){
            addProductToWishlist(productData: product) { status in
                if status{
                    completion!()
                }
            }
        }else{
            completion!()
        }
    }
}

func addProductToWishlist(productData: MPProductData, completion: ((Bool) -> ())?){
    findtopViewController()!.showActivityIndicator()
    let nameAPI: endPoint = .mp_user_addWishlist_product

    let params = ["product_id": productData.id] as [String : Any]

    Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: params, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
        findtopViewController()!.hideActivityIndicator()
        if isSuccess {
            
            let dic: NSMutableDictionary = ["product_id": productData.id]
            //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.ItemaddedWishlist.rawValue, properties: MOProperties.init(attributes: dic))
            
            let res = responseJSON?.rawValue as? [String: Any] ?? [:]
            let errorRes = res["error"] as? [String: Any] ?? [:]
            let msg = errorRes["message"] as? String ?? MPCartString.something_went_wrong
            if let data = res["data"] as? [String: Any]{
                if data.count > 0{
                    completion?(true)
                    return
                }
            }else if let data = res["data"] as? [[String: Any]]{
                if data.count > 0{
                    completion?(true)
                    return
                }
            }
            completion?(false)
        }else if status == "Token is Expired"{
            completion?(false)
        } else {
            completion?(false)
        }
    }
}


func removeProductFromWishList(productId: String, completion: ((Bool) -> ())?){
    findtopViewController()!.showActivityIndicator()
    let nameAPI: endPoint = .mp_user_removeWishlist_product
    let finlName = String(format: nameAPI.rawValue, productId)
    Utils.doAPICallMartketPlace(endPoint: finlName, method: .get, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
        findtopViewController()!.hideActivityIndicator()
        if isSuccess {
            
            let dic: NSMutableDictionary = ["product_id": productId]
            //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.ItemremoveWishlist.rawValue, properties: MOProperties.init(attributes: dic))
            
            
            let res = responseJSON?.rawValue as? [String: Any] ?? [:]
            let errorRes = res["error"] as? [String: Any] ?? [:]
            let msg = errorRes["message"] as? String ?? MPCartString.something_went_wrong
            if let data = res["data"] as? [String: Any]{
                if data.count > 0{
                    findtopViewController()!.showToast(message: MPWishListString.removed_successfully)
                    completion?(true)
                    return
                }
            }else if let data = res["data"] as? [[String: Any]]{
                if data.count > 0{
                    findtopViewController()!.showToast(message: MPWishListString.removed_successfully)
                    completion?(true)
                    return
                }
            }
            findtopViewController()!.showToast(message: msg)
            completion?(false)
        }else if status == "Token is Expired"{
            completion?(false)
            findtopViewController()!.showToast(message: MPWishListString.please_login)
            callAPIfor_LOGIN()
        } else {
            completion?(false)
            findtopViewController()!.showToast(message: message)
        }
    }
}

func getProductFromWishlist(completion: ((Bool, MPProductModel?) -> ())?){
    let nameAPI: endPoint = .mp_user_Wishlist
    Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .get, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
        if isSuccess {
            let mPProductModel = MPProductModel(JSON: responseJSON?.rawValue as! [String : Any])!
            if mPProductModel.data.count > 0{
                let cartData = setUpCart(data: mPProductModel)
                completion?(true, cartData)
            }else{
                completion?(false, nil)
            }
        }else if status == "Token is Expired"{
            completion?(false, nil)
            callAPIfor_LOGIN()
        } else {
            completion?(false, nil)
            findtopViewController()!.showAlert(title: status, message: message)
        }
    }
}

