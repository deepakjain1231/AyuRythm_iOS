//
//  ReviewOrderViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 16/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import Razorpay
import SwiftDate

class ReviewOrderViewController: BaseViewController, RazorpayPaymentCompletionProtocol, RazorpayPaymentCompletionProtocolWithData {

    var str_couponcode = ""
    var int_couponPrice: Float = 0.0
    var is_couponSelected = false
    var is_ayuseedSelected = false
    var super_view = UIViewController()
    @IBOutlet weak var lbl_title: UILabel!
    
    @IBOutlet weak var lbl_program_name: UILabel!
    @IBOutlet weak var lbl_trainer_name: UILabel!
    @IBOutlet weak var lbl_timing_label: UILabel!
    @IBOutlet weak var lbl_timeing_slots: UILabel!
    @IBOutlet weak var lbl_date_title: UILabel!
    @IBOutlet weak var lbl_session_date: UILabel!
    @IBOutlet weak var lbl_applyCoupon: UILabel!
    @IBOutlet weak var lbl_ayuseed:UILabel!
    @IBOutlet weak var lbl_coupon_ayuseed:UILabel!
    @IBOutlet weak var lbl_session_cost: UILabel!
    @IBOutlet weak var lbl_session_count: UILabel!
    @IBOutlet weak var lbl_subtotal_count: UILabel!
    @IBOutlet weak var lbl_taxes_count: UILabel!
    @IBOutlet weak var lbl_total_cost: UILabel!
    @IBOutlet weak var btn_Edit: UIButton!
    @IBOutlet weak var btn_Pay: UIButton!
    @IBOutlet weak var lbl_discount_cost: UILabel!
    @IBOutlet weak var txt_couponCode: UITextField!
    
    @IBOutlet weak var view_ApplyCoupon: UIView!
    @IBOutlet weak var view_AppltAyuseed: UIView!
    @IBOutlet weak var constraint_view_Main_Bottom: NSLayoutConstraint!
    
    @IBOutlet weak var view_MainBG: UIView!
    @IBOutlet weak var view_CouponBG: UIView!
    @IBOutlet weak var constraint_view_Coupon_Leading: NSLayoutConstraint!
//    @IBOutlet weak var discountApplyButton: UIButton!
//    @IBOutlet weak var discountApplyCheckmarkButton: UIButton!
//
//    @IBOutlet weak var usedSeedsLabel: UILabel!
//    @IBOutlet weak var usedSeedsPriceLabel: UILabel!
    
    var razorpay: RazorpayCheckout!
    var trainer: Trainer?
    var package: TrainerPackage?
    var sessionDetails : [String : Any]?
    var selectedDate: [Int]?
    var orderId = String()
    var endDateValue: Date?
    var startDateValue: Date?
    var finalTotalCost: Float = 0.0
    
    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.txt_couponCode.placeholder = "Enter coupon code".localized()
        self.constraint_view_Main_Bottom.constant = -screenHeight
        self.constraint_view_Coupon_Leading.constant = screenWidth
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
        self.view_CouponBG.roundCorners(corners: [.topLeft, .topRight], radius: 22)
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_Main_Bottom.constant = 0
            self.view_MainBG.roundCorners(corners: [.topLeft, .topRight], radius: 22)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose(_ isAction: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_Main_Bottom.constant = -screenHeight
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    // MARK: - Action Methods
    @IBAction func btn_close_Action(_ sender: UIButton) {
        self.clkToClose()
    }
    
    @IBAction func btn_remove_ayuseed_Action(_ sender: UIButton) {
        if self.is_ayuseedSelected {
            self.is_ayuseedSelected = false
            calculatePriceTotal(isAyuSeedUsed: false)
            self.view_AppltAyuseed.isHidden  = true
            self.view_ApplyCoupon.isHidden = false
            self.lbl_applyCoupon.text = "Apply coupon or AyuSeeds"
        }
        else {
            self.str_couponcode = ""
            calculatePriceTotal(isAyuSeedUsed: false)
            self.view_AppltAyuseed.isHidden  = true
            self.view_ApplyCoupon.isHidden = false
        }
    }
    
    @IBAction func btn_apply_ayuseed_Action(_ sender: UIButton) {
        self.is_ayuseedSelected = true
        calculatePriceTotal(isAyuSeedUsed: true)
        self.view_AppltAyuseed.isHidden  = false
        self.view_ApplyCoupon.isHidden = true
        self.lbl_applyCoupon.text = self.lbl_coupon_ayuseed.text ?? ""
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_Coupon_Leading.constant = screenWidth
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    @IBAction func btn_validate_coupon(_ sender: UIButton) {
        if let txt_code = self.txt_couponCode.text {
            if txt_code.trimed() == "" {
                return
            }
            else {
                self.view.endEditing(true)
                self.callAPIforCoupon_Validate(coupon_code: txt_code)
            }
        }
    }
    
    @IBAction func editOrderButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        placeTrainerOrder()
    }
    
    @IBAction func btn_Apply_Coupon(_ sender: UIControl) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_Coupon_Leading.constant = 0
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    @IBAction func btn_Back_Coupon(_ sender: UIButton) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_Coupon_Leading.constant = screenWidth
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    @IBAction func discountApplyBtnPressed(sender: UIButton) {
        sender.isSelected.toggle()
        //discountApplyCheckmarkButton.isSelected.toggle()
        calculatePriceTotal(isAyuSeedUsed: sender.isSelected)
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        razorpay = RazorpayCheckout.initWithKey(kRazorpayKey_Subscription, andDelegateWithData: self)
        
        guard let package = package, let sessionDetails = sessionDetails else {
            return
        }
        self.lbl_program_name.text = package.name
        self.lbl_trainer_name.text = "with".localized() + " " + (trainer?.name ?? "")
        
        if let startTimeStr = sessionDetails["startTime"] as? String, let endTimeStr = sessionDetails["endTime"] as? String {
            let start = startTimeStr.UTCToLocal(incomingFormat: "HH:mm:ss", outGoingFormat: MyBookingTimeFormat)
            let end = endTimeStr.UTCToLocal(incomingFormat: "HH:mm:ss", outGoingFormat: MyBookingTimeFormat)
            self.lbl_timeing_slots.text = start + " - " + end
        }

        var days = [String]()
        for day in selectedDate! {
            if day == 1 {
                days.append("Monday")
            } else if day == 2 {
                days.append("Tuesday")
            } else if day == 3 {
                days.append("Wednesday")
            } else if day == 4 {
                days.append("Thursday")
            } else if day == 5 {
                days.append("Friday")
            } else if day == 6 {
                days.append("Saturday")
            } else if day == 7 {
                days.append("Sunday")
            }
        }
        
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.dateFormat = "EEEE"
        df.locale = Locale(identifier: "en")

        var session = 0
        let numberOfSessions = Int(package.total_session)
        let chooseDateValue = (sessionDetails["startDate"] as? String)?.toDate(("yyyy-MM-dd"))?.date
        if var chooseDateValue = chooseDateValue {
            //print("Start Date : ", startDateValue)
            repeat {
                let day = df.string(from: chooseDateValue)
                //print(day)
                if days.contains(day) {
                    session = session + 1
                    if session == 1 {
                        startDateValue = chooseDateValue
                        //print("Final Start Date : ", startDateValue)
                    }
                    //print(day, " √")
                    if session != numberOfSessions {
                        chooseDateValue = Calendar.current.date(byAdding: .day, value: 1, to: chooseDateValue)!
                        //print("New Date : ", startDateValue)
                    }
                } else {
                    chooseDateValue = Calendar.current.date(byAdding: .day, value: 1, to: chooseDateValue)!
                }
            } while session != numberOfSessions
            //print("Final End Date : ", chooseDateValue)
            endDateValue = chooseDateValue
        }
        let sessionStartDate = startDateValue?.toString(.custom("dd-MM-yyyy")) ?? ""
        let sessionEndDate = endDateValue?.toString(.custom("dd-MM-yyyy")) ?? ""
        self.lbl_session_date.text = "\(sessionStartDate) to \(sessionEndDate)"
        
        let localizedDays = days.map{ $0.localized() }
        self.lbl_timeing_slots.text = "\(self.lbl_timeing_slots.text ?? "") " + "Every ".localized() + localizedDays.joined(separator: ", ")
        
        self.lbl_session_cost.text = package.final_price_per_session.priceValueString
        self.lbl_session_count.text = "\(package.total_session)"
        
        self.lbl_ayuseed.text = "\(String(package.final_seeds_used)) AYUSEEDS ( \(package.final_seed_discount_price.priceValueString) ) "
        self.lbl_coupon_ayuseed.text = "\(String(package.final_seeds_used)) AYUSEEDS ( \(package.final_seed_discount_price.priceValueString) ) "
        
//        if package.final_seed_discount_price == 0.0 {
            self.is_ayuseedSelected = false
            self.view_AppltAyuseed.isHidden = true
            self.view_ApplyCoupon.isHidden = false
            self.calculatePriceTotal(isAyuSeedUsed: false)
//        }
//        else {
//            self.is_ayuseedSelected = true
//            self.view_AppltAyuseed.isHidden = false
//            self.view_ApplyCoupon.isHidden = true
//            self.calculatePriceTotal(isAyuSeedUsed: true)
//        }
    }
    
    func calculatePriceTotal(isAyuSeedUsed: Bool = false, isApply_coupon: Bool = false) {
        guard let package = package else { return }
        
        let taxPercentage: Float = 0.18 //18% GST
        let totalCost = Float(package.final_total_cost) ?? 0
        let subTotal = totalCost/(1 + taxPercentage)
        var tax = subTotal * taxPercentage
        self.lbl_subtotal_count.text = subTotal.priceValueString
        self.lbl_total_cost.text = totalCost.priceValueString
        if isAyuSeedUsed {
            //Apply AyuSeed
            let discount = package.final_seed_discount_price
            let total_withDis = totalCost - discount

            let subTotal = total_withDis/(1 + taxPercentage)
            tax = total_withDis - subTotal
            self.lbl_subtotal_count.text = subTotal.priceValueString
            self.lbl_discount_cost.text = "-" + package.final_seed_discount_price.priceValueString
            self.lbl_total_cost.text = total_withDis.priceValueString
        }
        else if isApply_coupon {
            //Apply coupon
            let total_withDis = totalCost - self.int_couponPrice
            
            let subTotal = total_withDis/(1 + taxPercentage)
            tax = total_withDis - subTotal
            self.lbl_subtotal_count.text = subTotal.priceValueString
            self.lbl_discount_cost.text = "-\(int_couponPrice.priceValueString)"
            self.lbl_total_cost.text = total_withDis.priceValueString
        }
        else {
            self.lbl_discount_cost.text = "0".priceValueString
        }
        self.lbl_taxes_count.text = tax.priceValueString
        
//        self.finalTotalCost = totalCost
        
        
        
        
        //let tax_logic = (100.0 + taxPercentage)/100.0
        /*
        if isAyuSeedUsed {
            //Apply AyuSeed
            let discount = package.final_seed_discount_price
            let dis_price = totalCost - discount
            let subTotal = dis_price/tax_logic
            let tax_value = dis_price - subTotal
            self.lbl_discount_cost.text = "-" + package.final_seed_discount_price.priceValueString
        }
        else if isApply_coupon {
            //Apply coupon
            let dis_price = totalCost - self.int_couponPrice
            let subTotal = dis_price/tax_logic
            let tax_value = dis_price - subTotal
            self.lbl_discount_cost.text = "-\(int_couponPrice.priceValueString)"
        }
        else {
            self.lbl_discount_cost.text = "0".priceValueString
        }
        */
        
        
//        let subTotal = totalCost/(1 + taxPercentage)
//        var tax = subTotal * taxPercentage
//        self.lbl_subtotal_count.text = subTotal.priceValueString
        if isAyuSeedUsed {
            //after discount
//            let discount = package.final_seed_discount_price
//            let newSubTotal = subTotal - discount
//            tax = newSubTotal * taxPercentage
//            totalCost = newSubTotal + tax
//            self.lbl_discount_cost.text = "-" + package.final_seed_discount_price.priceValueString
        }
//        else if isApply_coupon {
//            let newSubTotal = subTotal - self.int_couponPrice
//            tax = newSubTotal * taxPercentage
//            totalCost = newSubTotal + tax
//            self.lbl_discount_cost.text = "-\(int_couponPrice.priceValueString)"
//        } else {
//            self.lbl_discount_cost.text = "0".priceValueString
//        }
//        self.lbl_taxes_count.text = tax.priceValueString
//        self.lbl_total_cost.text = totalCost.priceValueString
//        self.finalTotalCost = totalCost
    }
    
    func placeTrainerOrder() {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        sessionDetails?["endDate"] = endDateValue?.toString(.custom("yyyy-MM-dd"))
        
        let urlString = kBaseNewURL + endPoint.placeTrainerOrder.rawValue
        var params = [
            "trainer_id" : trainer?.id ?? 0,
            "package_id" : package?.favorite_id ?? 0,
            "start_date" : startDateValue?.toString(.custom("yyyy-MM-dd")) ?? "",
            "end_date" : endDateValue?.toString(.custom("yyyy-MM-dd")) ?? "",
            "start_time" : sessionDetails?["startTime"] ?? "0",
            "end_time" : sessionDetails?["endTime"] ?? "0",
            "language_id" : Utils.getLanguageId(),
            "location" : sessionDetails?["location"] ?? "Others",
            "information_for_trainer" : sessionDetails?["information_for_trainer"] ?? "",
            "is_seeds_used" : self.is_ayuseedSelected ? "1" : "0",
            "coupon_code": "\(self.str_couponcode)"
        ] as [String : Any]
        
        let locale = Locale.current
        if locale.currencyCode == "INR" {
            params["currency"] = "INR"
        } else {
            params["currency"] = "USD"
        }
        
        var days = [String]()
        for day in selectedDate! {
            if day == 1 {
                days.append("Monday")
            } else if day == 2 {
                days.append("Tuesday")
            } else if day == 3 {
                days.append("Wednesday")
            } else if day == 4 {
                days.append("Thursday")
            } else if day == 5 {
                days.append("Friday")
            } else if day == 6 {
                days.append("Saturday")
            } else if day == 7 {
                days.append("Sunday")
            }
        }
        
        params["selected_days"] = days.joined(separator: ",")
        
        AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.book_trainer.rawValue)
                debugPrint(response)
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    Utils.stopActivityIndicatorinView(self.view)
                    return
                }
                
                if dicResponse["status"] as? String ?? "" == "Success" {
                    Utils.stopActivityIndicatorinView(self.view)
                    let message = dicResponse["message"] as? String ?? ""
                    guard let dataResponse = (dicResponse["response"] as? [String : Any]) else {
                        Utils.stopActivityIndicatorinView(self.view)
                        return
                    }
                    self.orderId = dataResponse["orderId"] as? String ?? ""
                    self.showPaymentForm()
                } else {
                    Utils.stopActivityIndicatorinView(self.view)
                    Utils.showAlertWithTitleInControllerWithCompletion("", message: (dicResponse["Message"] as? String ?? "Failed to place order.".localized()), okTitle: "Ok".localized(), controller: self.super_view) {
                        
                    }
                }
            case .failure(let error):
                debugPrint(error)
                Utils.stopActivityIndicatorinView(self.view)
                Utils.showAlertWithTitleInController("", message: error.localizedDescription, controller: self.super_view)
            }
        }
    }
    
    func showPaymentForm() {
        var options: [String:Any] = [
            "description": package?.descriptions ?? "",
            "order_id": self.orderId,
            "name": package?.name ?? "",
            
            "theme": [
                "color": "#F37254"
            ]
        ]
        
        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
            options["prefill"] = [
                "contact":  empData["mobile"],
                "email": empData["email"]
            ]
        }
        
        let locale = Locale.current
        if locale.currencyCode == "INR" {
            options["currency"] = "INR" //We support more that 92 international currencies.
            //options["amount"] = finalTotalCost.priceValueStringWithoutCurrencySymbol //This is in currency subunits. 100 = 100 paise= INR 1.
        } else {
            options["currency"] = "USD"
            //options["amount"] = finalTotalCost.priceValueStringWithoutCurrencySymbol
        }

        razorpay.open(options)
    }
    
    func completePayment(response: [AnyHashable : Any]?) {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.paymentResponse.rawValue
        
        AF.request(urlString, method: .post, parameters: response as! Parameters, encoding:URLEncoding.default,headers: headers).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                debugPrint(response)
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    return
                }
                
                if dicResponse["status"] as? String ?? "" == "Success" {
                    Utils.stopActivityIndicatorinView(self.view)
                    
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    
                    guard let dataResponse = (dicResponse["response"] as? [String : Any]) else {
                        return
                    }
                    
                    self.showConfirmOrderScreen(paymentDetails: dataResponse)
                } else {
                    Utils.stopActivityIndicatorinView(self.view)
                    Utils.showAlertWithTitleInControllerWithCompletion("", message: (dicResponse["Message"] as? String ?? "Failed to place order.".localized()), okTitle: "Ok".localized(), controller: self.super_view) {
                        
                    }
                }
            case .failure(let error):
                debugPrint(error)
                Utils.stopActivityIndicatorinView(self.view)
                Utils.showAlertWithTitleInController("", message: error.localizedDescription, controller: self.super_view)
            }
        }
    }
    
    func showConfirmOrderScreen(paymentDetails: [String : Any]) {
        let storyBoard = UIStoryboard(name: "Booking", bundle: nil)
        guard let confirmOrderViewController = storyBoard.instantiateViewController(withIdentifier: "ConfirmOrderViewController") as? ConfirmOrderViewController else {
            return
        }
        
        confirmOrderViewController.package = package
        confirmOrderViewController.sessionDetails = sessionDetails
        confirmOrderViewController.selectedDate = selectedDate!
        confirmOrderViewController.paymentDetails = paymentDetails
        //self.navigationController?.pushViewController(confirmOrderViewController, animated: true)
        confirmOrderViewController.modalPresentationStyle = .overCurrentContext
        confirmOrderViewController.modalTransitionStyle = .crossDissolve
        present(confirmOrderViewController, animated: true, completion: nil)
    }
    
    
    // MARK: - RazorpayPaymentCompletionProtocol Methods
    
    public func onPaymentError(_ code: Int32, description str: String) {
        Utils.showAlertWithTitleInController("Error".localized(), message: str, controller: self.super_view)
    }

    public func onPaymentSuccess(_ payment_id: String) {
//        Utils.showAlertWithTitleInController("SUCCESS", message: "Payment Id \(payment_id)", controller: self)
        
//        {
//          "razorpay_payment_id": "pay_29QQoUBi66xm2f",
//          "razorpay_order_id": "order_9A33XWu170gUtm",
//          "razorpay_signature": "9ef4dffbfd84f1318f6739a3ce19f9d85851857ae648f114332d8401e0949a3d"
//        }
    }
    
    public func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        completePayment(response: response)
    }
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        let alertController = UIAlertController(title: "Error".localized(), message: str, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok".localized(), style: UIAlertAction.Style.default, handler: nil))
        self.super_view.present(alertController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    func callAPIforCoupon_Validate(coupon_code: String) {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.trainer_coupon_validation.rawValue
        let params = ["coupon_code" : coupon_code,
                      "order_amount": package?.final_total_cost ?? ""] as [String : Any]

        AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):

                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    Utils.stopActivityIndicatorinView(self.view)
                    return
                }

                if dicResponse["status"] as? String ?? "" == "Success" {
                    Utils.stopActivityIndicatorinView(self.view)
                    let message = dicResponse["message"] as? String ?? ""

                    guard let dataResponse = (dicResponse["response"] as? [String : Any]) else {
                        Utils.stopActivityIndicatorinView(self.view)
                        return
                    }
                    self.txt_couponCode.text = ""
                    self.str_couponcode = coupon_code
                    let coupon_amount = dataResponse["coupon_amount"] as? String ?? ""
                    self.int_couponPrice = Float(coupon_amount) ?? 0
                    
                    self.view_AppltAyuseed.isHidden  = false
                    self.view_ApplyCoupon.isHidden = true
                    self.calculatePriceTotal(isApply_coupon: true)
                    self.lbl_ayuseed.text = "Applied -> \(coupon_code)"
                    self.lbl_ayuseed.textColor = AppColor.app_DarkGreenColor
                    UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                        self.constraint_view_Coupon_Leading.constant = screenWidth
                        self.view.layoutIfNeeded()
                    }) { (success) in
                    }
                    
                } else {
                    Utils.stopActivityIndicatorinView(self.view)
                    Utils.showAlertWithTitleInControllerWithCompletion("", message: (dicResponse["Message"] as? String ?? "Failed to validate coupon.".localized()), okTitle: "Ok".localized(), controller: self.super_view) { }
                    }
            case .failure(let error):
                debugPrint(error)
                Utils.stopActivityIndicatorinView(self.view)
                Utils.showAlertWithTitleInController("", message: error.localizedDescription, controller: self.super_view)
            }
        }
        
    }
}
