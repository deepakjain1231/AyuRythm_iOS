//
//  MPPaymentModeVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 26/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import Razorpay
//import MoEngage

protocol delegatePlaceOrder {
    func placeorderOptionSelection(_ success: Bool, selected_PlaceOrderOption: String)
}

class MPPaymentModeVC: UIViewController {

    var orderId = ""
    var selectedOption = ""
    var totalPayableAmount = ""
    var address_Data: MPAddressData?
    var delivery_Model: MPCartDeliveryModel?
    var delegate: delegatePlaceOrder?
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lbl_totalPayble: UILabel!
    @IBOutlet weak var lbl_totalPayble_Title: UILabel!
    var arr_Options = ["Cash On Delivery",
                       "Online Payment"]
    
    var razorpayObj : RazorpayCheckout? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Payment Mode"
        self.tblView.register(nibWithCellClass: MPReasonTableCell.self)
        self.setupValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    
    func setupValue() {
        self.lbl_totalPayble.text = self.totalPayableAmount
        self.tblView.reloadData()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

    // MARK: - IBAction
    @IBAction func btn_PlaceOrder_Action(_ sender: UIControl) {
        if self.selectedOption == "" {
            kSharedAppDelegate.window?.rootViewController?.showToast(message: "Please select option")
            return
        }
        
        if self.selectedOption == "Cash On Delivery" {
            
            //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.CODPaymentOption.rawValue)
            
            self.saveOrderForCashOnDelivery()
        }
        else {
            
            //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.OnlinePaymentOption.rawValue)
            
            self.saveDataForRazorPay()
        }
    }
}

extension MPPaymentModeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withClass: MPReasonTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.lbl_Underline.isHidden = true
        cell.lbl_Title.text = self.arr_Options[indexPath.row]

        let reason_title = self.arr_Options[indexPath.row]
        if self.selectedOption == reason_title {
            cell.img_selection.image = MP_appImage.img_CheckBox_selected
        }
        else {
            cell.img_selection.image = MP_appImage.img_CheckBox_unselected
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reason_title = self.arr_Options[indexPath.row]
        self.selectedOption = reason_title
        self.tblView.reloadData()
    }
}


//MARK:- RazorPay
extension MPPaymentModeVC {
    
    internal func showPaymentForm(orderId: String) {
        
        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            return
        }
        let ayutythmUserName = empData["name"] as? String ?? ""
        let ayutythmUserPhone = empData["mobile"] as? String ?? ""
        let ayutythmUserEmail = empData["email"] as? String ?? ""
        
        //--
        let total_Amount = delivery_Model?.singleData?.Total_Payable.floatValue.rounded(toPlaces: 2) ?? 0
        
        self.razorpayObj = RazorpayCheckout.initWithKey(kRazorpayKey_Marketplace, andDelegateWithData: self)
        let options: [String:Any] = ["timeout":900,
                                     "currency": "INR",
                                     "description": "",
                                     "name": ayutythmUserName,
                                     "razorpay_order_id": orderId,
                                     "amount": "\(total_Amount*100)",
                                     "image": UIImage.init(named: "Splashlogo")!,
                                     "prefill": ["contact": ayutythmUserPhone,
                                                 "email": ayutythmUserEmail],
                                     "theme": ["color": "#3c91e6"]]

        if let rzp = self.razorpayObj {
            rzp.open(options)
        } else {
            print("Unable to initialize")
        }
    }
}


extension MPPaymentModeVC: RazorpayPaymentCompletionProtocol {
    
    func onPaymentError(_ code: Int32, description str: String) {
        print("error1111: ", code, str)
        
        let dic: NSMutableDictionary = ["order_id": orderId]
        //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.OnlinePaymentFailed.rawValue, properties: MOProperties.init(attributes: dic))
        
        let objDialouge = MPPaymentSuccessFailedVC(nibName: "MPPaymentSuccessFailedVC", bundle: nil)
        objDialouge.modalPresentationStyle = .overCurrentContext
        objDialouge.price = delivery_Model?.singleData?.Total_Payable.stringValue ?? ""
        objDialouge.screenfrom = .MP_PaymentFailed
        self.present(objDialouge, animated: false, completion: nil)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        print("success: ", payment_id)
    }
}

extension MPPaymentModeVC: RazorpayPaymentCompletionProtocolWithData {
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        print("error: ", code)
        //self.presentAlert(withTitle: "Alert", message: str)
    }
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        print("success1223: ", payment_id)
        orderSuccessfullySentToServer(paymentId: payment_id)
        
        let dic: NSMutableDictionary = ["payment_id": payment_id, "order_id": orderId]
        //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.OnlinePaymentSuccess.rawValue, properties: MOProperties.init(attributes: dic))
        
        let objDialouge = MPPaymentSuccessFailedVC(nibName: "MPPaymentSuccessFailedVC", bundle: nil)
        objDialouge.modalPresentationStyle = .overCurrentContext
        objDialouge.price = delivery_Model?.singleData?.Total_Payable.stringValue ?? ""
        objDialouge.screenfrom = .MP_PaymentSuccess
        self.present(objDialouge, animated: false, completion: nil)
    }
}

//MARK: - API CALL
extension MPPaymentModeVC {
    
    func saveOrderForCashOnDelivery() {
        self.showActivityIndicator()
        let nameAPI: endPoint = .mp_user_order_SaveOrderCOD
        
        var param = ["dp": "0",
                     "txnid": "0",
                     "packing_cost": "0",
                     "vendor_packing_id": "0",
                     "vendor_shipping_id": "0",
                     "shipping_city": self.address_Data?.city ?? "",
                     "shipping_zip": self.address_Data?.pincode ?? "",
                     "shipping_state": self.address_Data?.state ?? "",
                     "shipping_name": self.address_Data?.full_name ?? "",
                     "shipping_address": self.address_Data?.address ?? "",
                     "shipping_landmark": self.address_Data?.landmark ?? "",
                     "shipping_phone": self.address_Data?.phone_number ?? "",
                     "tax": delivery_Model?.singleData?.Taxes.stringValue ?? "0",
                     "shipping_building_name": self.address_Data?.building_no ?? "",
                     "shipping_address_type": self.address_Data?.address_type ?? "",
                     "total_payable": delivery_Model?.singleData?.Total_Payable.stringValue ?? "0",
                     "shipping_cost": delivery_Model?.singleData?.Delivery_Charge.stringValue ?? "0",
                     "coupon_discount": delivery_Model?.singleData?.Applied_Coupon_Amount.stringValue ?? "0",
                     "coupon_id": "\(self.delivery_Model?.singleData?.Applied_Coupon_ID ?? 0)",
                     "coupon_code": delivery_Model?.singleData?.Applied_Coupon_Code ?? "",
                     "is_wallet_applied": delivery_Model?.singleData?.Wallet_Applied ?? "No",
                     "Total_MRP": delivery_Model?.singleData?.Total_MRP ?? 0,
                     "Discount": self.delivery_Model?.singleData?.Discount ?? 0] as [String : Any]
        
        param["ayuseeds_coupon_id"] = "\(self.delivery_Model?.singleData?.Applied_Ayuseed_Coupon_ID ?? 0)"
        param["ayuseeds_coupon_code"] = self.delivery_Model?.singleData?.Applied_Ayuseed_Coupon_Code ?? ""
        param["ayuseeds_coupon_discount"] = self.delivery_Model?.singleData?.Ayuseeds_Applied_Coupon_Amount ?? ""
        
        if (self.delivery_Model?.singleData?.Applied_Coupon_ID ?? 0) == 0 {
            param["coupon_id"] = ""
        }
        
        if (self.delivery_Model?.singleData?.Applied_Ayuseed_Coupon_ID ?? 0) == 0 {
            param["ayuseeds_coupon_id"] = ""
        }
        
        if delivery_Model?.singleData?.Wallet_Applied == "Yes" {
            let amount_used = delivery_Model?.singleData?.Wallet_Amount_Used ?? 0
            param["wallet_applied_amount"] = amount_used
        }
        else {
            param["wallet_applied_amount"] = 0
        }
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                
                if let response = responseJSON?.rawValue as? [String : Any]{
                    if let data = response["data"] as? [String: Any] {
                        let vc = MPOrderConfirmedVC.instantiate(fromAppStoryboard: .MarketPlace)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    
    func saveDataForRazorPay() {
        self.showActivityIndicator()
        let nameAPI: endPoint = .mp_user_order_SaveOrder
        
        var param = ["dp": "0",
                     "txnid": "0",
                     "packing_cost": "0",
                     "vendor_packing_id": "0",
                     "vendor_shipping_id": "0",
                     "shipping_city": self.address_Data?.city ?? "",
                     "shipping_zip": self.address_Data?.pincode ?? "",
                     "shipping_state": self.address_Data?.state ?? "",
                     "shipping_name": self.address_Data?.full_name ?? "",
                     "shipping_address": "\(self.address_Data?.building_no ?? "") \(self.address_Data?.address ?? "")",
                     "shipping_landmark": self.address_Data?.landmark ?? "",
                     "shipping_phone": self.address_Data?.phone_number ?? "",
                     "tax": delivery_Model?.singleData?.Taxes.stringValue ?? "0",
                     "shipping_building_name": self.address_Data?.building_no ?? "",
                     "shipping_address_type": self.address_Data?.address_type ?? "",
                     "total_payable": delivery_Model?.singleData?.Total_Payable.stringValue ?? "0",
                     "shipping_cost": delivery_Model?.singleData?.Delivery_Charge.stringValue ?? "0",
                     "coupon_discount": delivery_Model?.singleData?.Applied_Coupon_Amount.stringValue ?? "0",
                     "coupon_id": "\(self.delivery_Model?.singleData?.Applied_Coupon_ID ?? 0)",
                     "ayuseed_coupon_id": "\(self.delivery_Model?.singleData?.Ayuseeds_Applied_Coupon_ID ?? 0)",
                     "coupon_code": delivery_Model?.singleData?.Applied_Coupon_Code ?? "",
                     "is_wallet_applied": delivery_Model?.singleData?.Wallet_Applied ?? "No",
                     "Total_MRP": delivery_Model?.singleData?.Total_MRP ?? 0,
                     "Discount": self.delivery_Model?.singleData?.Discount ?? 0] as [String : Any]

        param["ayuseeds_coupon_id"] = "\(self.delivery_Model?.singleData?.Applied_Ayuseed_Coupon_ID ?? 0)"
        param["ayuseeds_coupon_code"] = self.delivery_Model?.singleData?.Applied_Ayuseed_Coupon_Code
        param["ayuseeds_coupon_discount"] = self.delivery_Model?.singleData?.Ayuseeds_Applied_Coupon_Amount
        
        if (self.delivery_Model?.singleData?.Applied_Coupon_ID ?? 0) == 0 {
            param["coupon_id"] = ""
        }
        
        if (self.delivery_Model?.singleData?.Applied_Ayuseed_Coupon_ID ?? 0) == 0 {
            param["ayuseeds_coupon_id"] = ""
        }
        
        if delivery_Model?.singleData?.Wallet_Applied == "Yes" {
            param["wallet_applied_amount"] = delivery_Model?.singleData?.Wallet_Amount_Used
        }
        else {
            param["wallet_applied_amount"] = 0
        }
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {

                if let response = responseJSON?.rawValue as? [String : Any]{
                    if let data = response["data"] as? [String: Any]{
                        self.orderId = "\(data["order_id"] as? Int ?? 0)"
                        self.showPaymentForm(orderId: "\(data["order_id"] as? Int ?? 0)")
                    }
                }
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    
    func orderSuccessfullySentToServer(paymentId: String) {
        let nameAPI: endPoint = .mp_user_order_UpdateRazorpayPaymentStatus
        let param = ["order_id": self.orderId,
                     "razorpay_payment_id": paymentId,
                     "razorpay_order_id" : self.orderId] as [String : Any]
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                debugPrint(responseJSON ?? [])
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
}
