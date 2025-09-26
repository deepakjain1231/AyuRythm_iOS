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

class MPCartManager: NSObject
{
    class func saveCartData(jsonObject: MPProductData, isFromSaveCartApi: Bool = false){
        //--
        let cart_data_model = getCartData()
        var itemDetail: MPProductData?
        var index = 0
        if cart_data_model.data.filter({$0.id == jsonObject.id}).count > 0{
            for item in cart_data_model.data{
//                if item.id == jsonObject.id{
//                    item.cartData?.added_quantity =  (item.cartData?.added_quantity ?? 1)//Temp comment + 1
//                    jsonObject.cartData?.added_quantity = item.cartData?.added_quantity ?? 1
//                    itemDetail = jsonObject
//                    break
//                }
                index += 1
            }
            if itemDetail != nil{
                if itemDetail?.cartData?.available_size_quantity ?? "" != "" && Int(itemDetail?.cartData?.available_size_quantity ?? "0") ?? 0 < cart_data_model.data[index].cartData?.added_quantity ?? 0{
                    return
                }
                cart_data_model.data[index] = itemDetail!
            }else{
                jsonObject.cartData?.random_id = random(digits: 10)
                cart_data_model.data.append(jsonObject)
            }
        }else{
            jsonObject.cartData?.random_id = random(digits: 10)
            cart_data_model.data.append(jsonObject)
        }
        UserDefaults.standard.set(cart_data_model.toJSON().nullKeyRemoval(), forKey: "cart_data")
        UserDefaults.standard.synchronize()
        if !isFromSaveCartApi{
            notifyCartUpdation()
        }
    }
    
    class func notifyCartUpdation() {
        NotificationCenter.default.post(name: Notification.Name("productAddedToCart"), object: nil)
    }
    
    class func getCartData() -> MPProductModel{
        if let cart_data = UserDefaults.standard.object(forKey: "cart_data") as? [String: Any]{
            let data = MPProductModel(JSON: cart_data)
            return data!
        }else{
            return MPProductModel()
        }
    }
    
    class func updateQuantity(productData: MPProductData, isIncrease: Bool, completion: ((Int) -> ())?) {
        DispatchQueue.main.async {
            if MPLoginLocalDB.isUserLoggedIn(){
                let oldQuantity = productData.cartData?.added_quantity ?? 0
                let count = isIncrease ? oldQuantity + 1 : oldQuantity - 1
                productData.cartData?.added_quantity = count
                upDateProductToCart(productData: productData) { status in
                    if status{
                        updateQty(productData: productData, isIncrease: isIncrease) { count in
                            completion!(count)
                        }
                    }else{
                        completion!(oldQuantity)
                    }
                }
            }else{
                updateQty(productData: productData, isIncrease: isIncrease) { count in
                    completion!(count)
                }
            }
        }
    }
    
    class private func updateQty(productData: MPProductData, isIncrease: Bool, completion: ((Int) -> ())?)  {
        let cart_data_model = getCartData()
        var itemDetail: MPProductData?
        var index = 0
        if cart_data_model.data.filter({$0.id == productData.id}).count > 0{
            for item in cart_data_model.data{
                if item.id == productData.id{
                    if isIncrease{
//                        item.cartData?.added_quantity =  (item.cartData?.added_quantity ?? 1) + 1
//                        productData.cartData?.added_quantity = item.cartData?.added_quantity ?? 1
                        itemDetail = productData
                    }else{
                        itemDetail = productData
                    }
                    break
                }
                index += 1
            }
            if itemDetail != nil{
                if isIncrease{
                    if itemDetail?.cartData?.available_size_quantity ?? "" != "" && Int(itemDetail?.cartData?.available_size_quantity ?? "0") ?? 0 < cart_data_model.data[index].cartData?.added_quantity ?? 0{
                        if !MPLoginLocalDB.isUserLoggedIn(){
                            findtopViewController()!.showToast(message: MPCartString.quantity_not_availabel)
                        }
                        //return
                    }
                    cart_data_model.data[index] = itemDetail!
                }else {
                    if cart_data_model.data[index].cartData?.added_quantity ?? 0 > 0{
//                        itemDetail?.cartData?.added_quantity -= 1
                    }
                    cart_data_model.data[index] = itemDetail!
                }
            }else{

            }
        }else{

        }
        UserDefaults.standard.set(cart_data_model.toJSON().nullKeyRemoval(), forKey: "cart_data")
        UserDefaults.standard.synchronize()
        completion!(productData.cartData?.added_quantity ?? 0)//.data[index].cartData?.added_quantity ?? 0)
    }
    
    class func removeCartData() {
        UserDefaults.standard.removeObject(forKey: "cart_data")
        UserDefaults.standard.synchronize()
        notifyCartUpdation()
    }
    
    class func addToCart(product: MPProductData, current_vc: UIViewController, completion: (() -> ())?){
        if product.is_variable_product.lowercased() == "no" || product.sizes.count == 1{
            if product.sizes.count == 1{
                let cartData = MPCartData()
                cartData.sizes = "\(product.sizes[0])"
                cartData.discount = "\(product.DISCOUNT)"
                cartData.sizes_wise_previous_price = "\(product.previous_price)"
                cartData.size_price = "\(product.current_price)"
                cartData.sizes_wise_price = "\(product.current_price)"
                cartData.available_size_quantity = "\(product.size_quantity[0])"
                cartData.added_quantity = 1
                cartData.sizes_key = "0"
                product.cartData = cartData
                if product.colors.count > 0{
                    cartData.color_code = product.colors[0]
                }
                checkUserLoginOrNot(product: [product], current_vc: current_vc) {
                    completion!()
                }
            }else{
                let cartData = MPCartData()
                cartData.sizes = ""
                cartData.sizes_key = "0"
                cartData.discount = "\(product.DISCOUNT)"
                cartData.sizes_wise_previous_price = "\(product.previous_price)"
                cartData.size_price = "\(product.current_price)"
                cartData.sizes_wise_price = "\(product.current_price)"
                cartData.available_size_quantity = "\(product.simple_product_stock)"
                cartData.added_quantity = 1
                cartData.color_code = ""
                product.cartData = cartData
                checkUserLoginOrNot(product: [product], current_vc: current_vc) {
                    completion!()
                }
            }
        }else{
            if let parent = kSharedAppDelegate.window?.rootViewController {
                let productData = product
                
                //Check Veriavle Product
                var int_Indx = 0
                if productData.is_variable_product.lowercased() == "yes" {
                    for product_quentity in productData.size_quantity {
                        var int_productQuentity: Int = Int(product_quentity) ?? 0
                        if int_productQuentity > 0 {
                            let cruSize = productData.sizes[int_Indx]

                            for dic_cart in productData.CART_DETAIL {
                                let ADDED_SIZE = dic_cart.ADDED_SIZE
                                let ADDED_QUANTITY = dic_cart.ADDED_QUANTITY
                                if cruSize == ADDED_SIZE {
                                    int_productQuentity = int_productQuentity - ADDED_QUANTITY
                                }
                            }

                            if int_productQuentity > 0 {
                                break
                            }
                        }
                        int_Indx = int_Indx + 1
                    }
                }
                //*********************************************************************************//
                //*********************************************************************************//
                
                let objQuantity = SelectQuantityVC(nibName: "SelectQuantityVC", bundle: nil)
                objQuantity.productData = productData
                objQuantity.selectedIndex = int_Indx
                parent.addChild(objQuantity)
                objQuantity.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                parent.view.addSubview((objQuantity.view)!)
                parent.view.bringSubviewToFront(objQuantity.view)
                objQuantity.didMove(toParent: parent)
                objQuantity.didTappedQuantity = { cartData in
                    productData.cartData = cartData
                    checkUserLoginOrNot(product: [productData], current_vc: current_vc) {
                        completion!()
                    }
                }
            }
        }
    }
    
    class func addToNotifiyMe(product: MPProductData, current_vc: UIViewController, completion: (() -> ())?){
        checkProductNotifyMe(product: product, current_vc: current_vc) {
            completion!()
        }
    }
    
    class func getSelectedProducts(productRandom_id: String) -> MPProductData? {
        let cart_data_model = getCartData()
        let datas = cart_data_model.data.filter({$0.cartData?.random_id == productRandom_id})
        return datas.count > 0 ? datas.first : nil
    }
    
    class func getSelectedProductsByProductId(product: MPProductData) -> MPProductData? {
        let cart_data_model = getCartData()
        let datas = cart_data_model.data.filter({$0.id == product.id})
        return datas.count > 0 ? datas.first : nil
    }
    
    class func removeCartSingleProduct(product: MPProductData, current_vc: UIViewController, productRandomId: String){
        if MPLoginLocalDB.isUserLoggedIn(){
            removeProductFromCart(cart_id: "\(product.cart_id)", productId: "\(product.id)", current_vc: current_vc) { status in

                if status{
                    let cart_data_model = getCartData()
                    cart_data_model.data.removeAll { item in
                        item.cartData?.random_id == productRandomId
                    }
                    UserDefaults.standard.set(cart_data_model.toJSON().nullKeyRemoval(), forKey: "cart_data")
                    UserDefaults.standard.synchronize()
                    self.notifyCartUpdation()
                }
            }
        }else{
            let cart_data_model = getCartData()
            cart_data_model.data.removeAll { item in
                item.cartData?.random_id == productRandomId
            }
            //.filter({$0.cartData?.random_id == productRandom_id})
            UserDefaults.standard.set(cart_data_model.toJSON().nullKeyRemoval(), forKey: "cart_data")
            UserDefaults.standard.synchronize()
            self.notifyCartUpdation()
            findtopViewController()!.showToast(message: "Product removed successfully.")
        }
    }
    
    class func checkIfProductAvailable(productId: Int) -> Bool {
        let cart_data_model = getCartData()
        return cart_data_model.data.filter({$0.id == productId}).count > 0 ? true : false
    }
    
    class func setCartButtonTitle(btnCart: UIButton, view_AddTocartBG: UIView, product: MPProductData, button_Title: String = ""){
        DispatchQueue.main.async {
            if button_Title == "" {
                if product.is_variable_product.lowercased() == "yes" && product.size_quantity.count > 0 && product.size_quantity.filter({Int($0) ?? 0 > 0}).count > 0 {
                    //let isAvail = checkIfProductAvailable(productId: product.id)
                    let isAvail = product.is_addedInCart
                    btnCart.setTitle(isAvail ? "Go to cart" : "Add to cart", for: .normal)
                    btnCart.tag = isAvail ? 1 : 0//1 for availble in cart and 0 for not available in cart
                }else if product.simple_product_stock > 0{
                    //let isAvail = checkIfProductAvailable(productId: product.id)
                    let isAvail = product.is_addedInCart
                    btnCart.setTitle(isAvail ? "Go to cart" : "Add to cart", for: .normal)
                    btnCart.tag = isAvail ? 1 : 0//1 for availble in cart and 0 for not available in cart
                }else{
                    btnCart.setTitle("Notify me", for: .normal)
                    btnCart.tag = 2//2 for notify me
                }
            }
            else {
                btnCart.tag = 1231
                btnCart.setTitle("Go to cart", for: .normal)
            }

            
            //Set color
            if btnCart.tag == 0{//add to cart
                view_AddTocartBG.backgroundColor = .white
                view_AddTocartBG.layer.borderColor = UIColor.systemBlue.cgColor
                btnCart.setTitleColor(UIColor.systemBlue, for: .normal)
            }else if btnCart.tag == 1{// added to cart
                view_AddTocartBG.backgroundColor = UIColor.systemBlue
                view_AddTocartBG.layer.borderColor = UIColor.systemBlue.cgColor
                btnCart.setTitleColor(UIColor.white, for: .normal)
            }else if btnCart.tag == 2{//notify me
                view_AddTocartBG.backgroundColor = UIColor.white
                view_AddTocartBG.layer.borderColor = UIColor.red.cgColor
                btnCart.setTitleColor(UIColor.red, for: .normal)
            }
            else if btnCart.tag == 1231 {// added to cart
                view_AddTocartBG.backgroundColor = UIColor.systemBlue
                view_AddTocartBG.layer.borderColor = UIColor.systemBlue.cgColor
                btnCart.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    
    class func addToCartButtonAction(btnCart: UIButton, view_AddTocartBG: UIView, productData: MPProductData?, current_vc: UIViewController, completion: (() -> ())? = nil) {
        if btnCart.tag == 0{//Add to cart
            MPCartManager.addToCart(product: productData!, current_vc: current_vc) {

                if completion != nil{
                    completion!()
                }else{
                    MPCartManager.setCartButtonTitle(btnCart: btnCart, view_AddTocartBG: view_AddTocartBG, product: productData!)
                }
            }
        }else if btnCart.tag == 1 || btnCart.tag == 1231 {//Go to cart
            productData?.is_addedInCart = false
            let vc = MPCartVC.instantiate(fromAppStoryboard: .MarketPlace)
            findtopViewController()?.navigationController?.pushViewController(vc, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                NotificationCenter.default.post(name: .refreshProductData, object: nil)
            }
        }else if btnCart.tag == 2{//Notify Me
            if productData?.NOTIFY_FOR_THIS_ITEM.lowercased() == "yes" {
                kSharedAppDelegate.window?.rootViewController?.showToast(message: "You have already added this product for notifying you")
            }
            else {
                MPCartManager.addToNotifiyMe(product: productData!, current_vc: current_vc) {
                    kSharedAppDelegate.window?.rootViewController?.showToast(message: "You have added this product for notifying you")
                }
            }
            
        }
    }
    
    class func checkUserLoginOrNot(product: [MPProductData], current_vc: UIViewController, completion: (() -> ())?){
        if MPLoginLocalDB.isUserLoggedIn(){
            addProductToCart(productData: product, current_vc: current_vc) { status in
                if status{
                    product.first?.is_addedInCart = true
                    MPCartManager.saveCartData(jsonObject: product.first!)
                    completion!()
                }
            }
        }else{
            MPCartManager.saveCartData(jsonObject: product.first!)
            completion!()
        }
    }
    
    
    class func checkProductNotifyMe(product: MPProductData, current_vc: UIViewController, completion: (() -> ())?){
        if MPLoginLocalDB.isUserLoggedIn(){
            addProductToNotifyMe(productData: product, current_vc: current_vc) { status in
                if status{
                    completion!()
                }
            }
        }
    }
}


func addProductToNotifyMe(productData: MPProductData, current_vc: UIViewController, completion: ((Bool) -> ())?){
    current_vc.showActivityIndicator()
    let nameAPI: endPoint = .mp_userProductNotifyMe
    let params = ["product_id": productData.id] as [String : Any]

    Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: params, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
        current_vc.hideActivityIndicator()
        if isSuccess {
            let res = responseJSON?.rawValue as? [String: Any] ?? [:]
            let errorRes = res["error"] as? [String: Any] ?? [:]
            let msg = errorRes["message"] as? String ?? MPCartString.something_went_wrong
            let statusss = res["status"] as? Bool ?? false
            if statusss {
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
            }
            else {
                kSharedAppDelegate.window?.rootViewController?.showToast(message: msg)
            }
            completion?(true)
        }else if status == "Token is Expired"{
            completion?(false)
        } else {
            let res = responseJSON?.rawValue as? [String: Any] ?? [:]
            let errorRes = res["error"] as? [String: Any] ?? [:]
            let msg = errorRes["message"] as? String ?? MPCartString.something_went_wrong
            kSharedAppDelegate.window?.rootViewController?.showToast(message: msg)
            completion?(true)
        }
    }
}

func addProductToCart(productData: [MPProductData], current_vc: UIViewController, completion: ((Bool) -> ())?) {
    current_vc.showActivityIndicator()
    let nameAPI: endPoint = .mp_user_addProductcart // .mp_user_mycart_savecartdetails
    let productids = productData.map({"\($0.id)"})
    let size_code = productData.map({"\($0.cartData?.sizes ?? "")"})
    let size_code_key = productData.map({"\($0.cartData?.sizes_key ?? "")"})
    let color_code = productData.map({"\($0.cartData?.color_code ?? "")"})
    let price = productData.map({"\($0.cartData?.sizes_wise_price ?? "")"})
    let quantity = productData.map({"\($0.cartData?.added_quantity ?? 0)"})
    
    let params = ["product_id": productids.joined(separator: ","),
                  "color_code": color_code.joined(separator: ","),
                  "size_code": size_code.joined(separator: ","),
                  "size_key": size_code_key.joined(separator: ","),
                  "size_price": price.joined(separator: ","),
                  "quantity": quantity.joined(separator: ",")] as [String : Any]
    
    Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: params, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
        current_vc.hideActivityIndicator()
        if isSuccess {
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

func upDateProductToCart(productData: MPProductData, completion: ((Bool) -> ())?){
    let nameAPI: endPoint = .mp_user_mycart_changeQuantity
    
    var params = ["product_id": productData.id,
                  "size_code":"\(productData.CART_DETAIL.first?.ADDED_SIZE ?? "")",
                  "color_code": "\(productData.CART_DETAIL.first?.ADDED_COLOR ?? "")",
                  "price": "\(productData.cartData?.sizes_wise_price ?? "0")",
                  "quantity": productData.cartData?.added_quantity ?? 1] as [String : Any]

    if productData.is_variable_product.lowercased() == "yes" {
        params["size_key"] = productData.CART_DETAIL.first?.ADDED_SIZE_KEY ?? 0
    }
    
    Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: params, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
        if isSuccess {
            kSharedAppDelegate.window?.rootViewController?.showToast(message: MPCartString.qty_added_successfully)
            completion?(true)
        }else if status == "Token is Expired"{
            completion?(false)
            kSharedAppDelegate.window?.rootViewController?.showToast(message: MPCartString.please_login)
            callAPIfor_LOGIN()
        } else {
            completion?(false)
            kSharedAppDelegate.window?.rootViewController?.showToast(message: MPCartString.something_went_wrong)
        }
    }
}

func removeProductFromCart(cart_id: String, productId: String, current_vc: UIViewController, completion: ((Bool) -> ())?){
    current_vc.showActivityIndicator()
    let nameAPI: endPoint = .mp_user_removeProductcart
    let finlName = String(format: nameAPI.rawValue,cart_id , productId)
    Utils.doAPICallMartketPlace(endPoint: finlName, method: .get, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
        current_vc.hideActivityIndicator()
        if isSuccess {
            let res = responseJSON?.rawValue as? [String: Any] ?? [:]
            let errorRes = res["error"] as? [String: Any] ?? [:]
            let msg = errorRes["message"] as? String ?? MPCartString.something_went_wrong
            if let data = res["data"] as? [String: Any]{
                if data.count > 0{
                    kSharedAppDelegate.window?.rootViewController?.showToast(message: MPCartString.removed_successfully)
                    completion?(true)
                    return
                }
            }else if let data = res["data"] as? [[String: Any]]{
                if data.count > 0{
                    kSharedAppDelegate.window?.rootViewController?.showToast(message: MPCartString.removed_successfully)
                    completion?(true)
                    return
                }
            }
            kSharedAppDelegate.window?.rootViewController?.showToast(message: msg)
            completion?(false)
        }else if status == "Token is Expired"{
            completion?(false)
            kSharedAppDelegate.window?.rootViewController?.showToast(message: MPCartString.please_login)
            callAPIfor_LOGIN()
        } else {
            completion?(false)
            kSharedAppDelegate.window?.rootViewController?.showToast(message: message)
        }
    }
}

func getProductFromCart(completion: ((Bool, MPProductModel?) -> ())?){
    let nameAPI: endPoint = .mp_user_mycart
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

func setUpCart(data: MPProductModel) -> MPProductModel{
    let mPProductModel = data
//    let cartData = MPCartManager.getCartData()
    MPCartManager.removeCartData()
    for i in 0..<mPProductModel.data.count{
        if mPProductModel.data[i].is_variable_product.lowercased() == "no"{
            let D_cartData = MPCartData()
            D_cartData.discount = "\(mPProductModel.data[i].DISCOUNT)"
            D_cartData.sizes = mPProductModel.data[i].CART_DETAIL.first?.ADDED_SIZE ?? ""
            D_cartData.sizes_wise_previous_price = "\(mPProductModel.data[i].previous_price)"
            D_cartData.size_price = "\(mPProductModel.data[i].current_price)"
            D_cartData.sizes_wise_price = "\(mPProductModel.data[i].current_price)"
            D_cartData.color_code = mPProductModel.data[i].CART_DETAIL.first?.ADDED_COLOR ?? ""
            D_cartData.random_id = random(digits: 10)
            
            
            //Quentity Logic
            var int_productQuentity: Int = mPProductModel.data[i].simple_product_stock
            if int_productQuentity > 0 {
                if let dic_cart = mPProductModel.data[i].CART_DETAIL.first {
                    let ADDED_QUANTITY = dic_cart.ADDED_QUANTITY
                    int_productQuentity = int_productQuentity - ADDED_QUANTITY
                }
            }
            D_cartData.available_size_quantity = "\(int_productQuentity)"
            D_cartData.added_quantity = mPProductModel.data[i].CART_DETAIL.first?.ADDED_QUANTITY ?? 0
            
            
            //D_cartData.available_size_quantity = "\(mPProductModel.data[i].simple_product_stock)"
            
            
            mPProductModel.data[i].cartData = D_cartData
            //==
//            mPProductModel.data[i].cartData?.sizes = mPProductModel.data[i].CART_DETAIL?.ADDED_SIZE ?? ""
//            mPProductModel.data[i].cartData?.sizes_wise_previous_price = "\(mPProductModel.data[i].previous_price)"
//            mPProductModel.data[i].cartData?.size_price = "\(mPProductModel.data[i].current_price)"
//            mPProductModel.data[i].cartData?.sizes_wise_price = "\(mPProductModel.data[i].current_price)"
//            mPProductModel.data[i].cartData?.available_size_quantity = "\(mPProductModel.data[i].simple_product_stock)"
//            mPProductModel.data[i].cartData?.added_quantity = mPProductModel.data[i].CART_DETAIL?.ADDED_QUANTITY ?? 0
//            mPProductModel.data[i].cartData?.color_code = mPProductModel.data[i].CART_DETAIL?.ADDED_COLOR ?? ""
//            mPProductModel.data[i].cartData?.random_id = random(digits: 10)
        }else{
            for j in 0..<mPProductModel.data[i].sizes.count{
                let current_size_data = mPProductModel.data[i].sizes[j]
                if mPProductModel.data[i].CART_DETAIL.first?.ADDED_SIZE.lowercased() == current_size_data.lowercased(){
                    let crtData = MPCartData()
                    crtData.sizes = current_size_data
                    
                    crtData.sizes_wise_previous_price = mPProductModel.data[i].sizes_wise_previous_price_in_int.count > j && mPProductModel.data[i].sizes_wise_previous_price_in_int.count != 0 ? "\(mPProductModel.data[i].sizes_wise_previous_price_in_int[j])" : ""
                    
                    crtData.sizes_wise_price = mPProductModel.data[i].sizes_wise_price_in_int.count > j && mPProductModel.data[i].sizes_wise_previous_price_in_int.count != 0 ? "\(mPProductModel.data[i].sizes_wise_price_in_int[j])" : ""
                    
                    
                    //Quentity Logic
                    var addedQuentity = 0
                    var int_productQuentity: Int = Int(mPProductModel.data[i].size_quantity[j]) ?? 0
                    //Check Veriavle Product
                    if int_productQuentity > 0 {
                        for dic_cart in mPProductModel.data[i].CART_DETAIL {
                            let ADDED_SIZE = dic_cart.ADDED_SIZE
                            let ADDED_QUANTITY = dic_cart.ADDED_QUANTITY
                            if current_size_data == ADDED_SIZE {
                                addedQuentity = ADDED_QUANTITY
                                int_productQuentity = int_productQuentity - ADDED_QUANTITY
                            }
                            break
                        }
                    }
                                
                    crtData.available_size_quantity = "\(int_productQuentity)"
                    
                    crtData.size_price = mPProductModel.data[i].size_price.count > j && mPProductModel.data[i].size_price.count != 0 ? "\(mPProductModel.data[i].size_price[j])" : ""
                    crtData.added_quantity = addedQuentity
                    crtData.discount = "\(mPProductModel.data[i].DISCOUNT)"
                    crtData.random_id = random(digits: 10)
                    crtData.color_code = mPProductModel.data[i].colors.count > j && mPProductModel.data[i].colors.count != 0 ? "\(mPProductModel.data[i].colors[j])" : ""
                    mPProductModel.data[i].cartData = crtData

                    //crtData.available_size_quantity = mPProductModel.data[i].size_quantity.count > j && mPProductModel.data[i].size_quantity.count != 0 ? "\(mPProductModel.data[i].size_quantity[j])" : ""
                    //crtData.added_quantity = mPProductModel.data[i].CART_DETAIL.first?.ADDED_QUANTITY ?? 0
                }
            }
        }
        MPCartManager.saveCartData(jsonObject: mPProductModel.data[i], isFromSaveCartApi: true)
    }
    
    return mPProductModel
}
