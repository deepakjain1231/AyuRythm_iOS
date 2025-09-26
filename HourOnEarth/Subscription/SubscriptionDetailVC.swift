//
//  SubscriptionDetailVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 03/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import Razorpay
import SwiftyStoreKit

class SubscriptionDetailVC: UIViewController, UITextFieldDelegate, delegatePaymentOption, didTappedDelegate {
    
    var is_inappPayment = true
    var is_razorpayPayment = false
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var planTitleL: UILabel!
    @IBOutlet weak var planOffL: UILabel!
    @IBOutlet weak var planOfferL: UILabel!
    @IBOutlet weak var planPriceL: UILabel!
    @IBOutlet weak var planDiscountPriceL: UILabel!
    @IBOutlet weak var buyNowBtn: UIButton!
    @IBOutlet weak var view_promocode_TOP_bg: UIView!
    @IBOutlet weak var view_promocode_bg: UIView!
    @IBOutlet weak var txtPromocode: UITextField!
    @IBOutlet weak var btn_Apply: UIButton!
    @IBOutlet weak var img_Applied: UIImageView!
    
    var strOrderID = ""
    var is_applied_promo = false
    var plan: ARSubscriptionPlanModel?
    var isReadOnly = false
    var aboutPlans = [String]()
    var notes = [String]()
    var razorpayObj : RazorpayCheckout? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.img_Applied.isHidden = true
        self.txtPromocode.delegate = self
        self.view_promocode_bg.isHidden = true
        self.view_promocode_TOP_bg.isHidden = true
        self.lbl_Title.text = "Join Prime Club".localized()
        self.txtPromocode.placeholder = "Have a promo code?".localized()
        self.txtPromocode.autocapitalizationType = .allCharacters
        self.btn_Apply.setTitleColor(.lightGray, for: .normal)
        self.txtPromocode.addTarget(self, action: #selector(self.text_FieldDidChange_Editing(_:)), for: .editingChanged)
                
        setBackButtonTitle()
        setupUI()
        
        NotificationCenter.default.addObserver(forName: .refreshActiveSubscriptionData, object: nil, queue: nil) { [weak self] notif in
            if let data = notif.object as? [String: Any],
               let isFromOrderSummeryScreen = data["isFromOrderSummeryScreen"] as? Bool,
               isFromOrderSummeryScreen,
               let stackVCs = self?.navigationController?.viewControllers {
                //print(">>> isFromOrderSummeryScreen : poping views to active sub screen")
                if let activeSubVC = stackVCs.first(where: { type(of: $0) == ActiveSubscriptionPlanVC.self }) {
                    self?.navigationController?.popToViewController(activeSubVC, animated: false)
                } else {
                    self?.navigationController?.popToRootViewController(animated: false)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }
    
    func setupUI() {
        tableView.register(nibWithCellClass: ChooseSubscriptionPlanCell.self)
        
        if let plan = plan {
            self.title = plan.packName
            planTitleL.text = plan.packName
            planOffL.text = "\(plan.bonusPercentage ?? "") OFF!"
            planPriceL.attributedText = NSAttributedString(string: plan.regularAmount.priceValueString).struckthrough
            planDiscountPriceL.text = plan.amount.priceValueString
            buyNowBtn.isHidden = isReadOnly

            if let is_SBIPromop = UserDefaults.user.get_user_info_result_data["isSBIPromocodeUsed"] as? Bool  {
                if is_SBIPromop {
                    self.view_promocode_bg.isHidden = self.isReadOnly
                    self.view_promocode_TOP_bg.isHidden = self.isReadOnly
                }
            }

            aboutPlans = plan.aboutPlans
            notes = plan.notes
            planOfferL.attributedText = plan.mainOffer
            tableView.reloadData()
        }
    }
    
    func inapppurchseBuyProduct() {
        let objDialouge = WellnessJourneyDialouge(nibName:"WellnessJourneyDialouge", bundle:nil)
        objDialouge.screen_from = .from_subscription
        objDialouge.delegate =  self
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }
    
    //Delegate handle
    func didTappedClose(_ success: Bool, product_id: String) {
        if success {
            self.clickConfirmation_BuyNow()
        }
    }
    
    func clickConfirmation_BuyNow() {
        if self.is_applied_promo {
            var sbi_identifier = ""
            if (self.plan?.id ?? "") == "1" {
                sbi_identifier = Locale.current.paramCurrencyCode == "INR" ? "com.hoe.houronearth.1_month_ind_sbi_dis" : "com.hoe.houronearth.1_month_subscription_sbi"
            }
            else if (self.plan?.id ?? "") == "2" {
                sbi_identifier = Locale.current.paramCurrencyCode == "INR" ? "com.hoe.houronearth.3_month_ind_sbi_dis" : "com.hoe.houronearth.3_month_subscription_sbi"
            }
            if (self.plan?.id ?? "") == "3" {
                sbi_identifier = Locale.current.paramCurrencyCode == "INR" ? "com.hoe.houronearth.6_month_ind_sbi_dis" : "com.hoe.houronearth.6_month_subscription_sbi"
            }
            if (self.plan?.id ?? "") == "4" {
                sbi_identifier = Locale.current.paramCurrencyCode == "INR" ? "com.hoe.houronearth.12_month_ind_sbi_dis" : "com.hoe.houronearth.12_month_subscription_sbi"
            }
            sbi_identifier = sbi_identifier == "" ? plan?.iosIapIdentifier ?? "" : sbi_identifier
            debugPrint(sbi_identifier)
            debugPrint(plan?.iosIapIdentifier ?? "" )
            Self.requestBuyProduct(productId: sbi_identifier, fromVC: self)
        }
        else {
            Self.requestBuyProduct(productId: plan?.iosIapIdentifier ?? "", fromVC: self)
        }
    }
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buyNowBtnPressed(sender: UIButton) {
        if self.is_inappPayment && self.is_razorpayPayment == false {
            self.inapppurchseBuyProduct()
        }
        else if self.is_inappPayment == false && self.is_razorpayPayment == false {
            self.inapppurchseBuyProduct()
        }
        else {
            if Locale.current.isCurrencyCodeInINR {
                if let parent = appDelegate.window?.rootViewController {
                    let objDialouge = ChoosePaymentOptionDialouge(nibName:"ChoosePaymentOptionDialouge", bundle:nil)
                    objDialouge.delegate = self
                    objDialouge.is_inappPayment = self.is_inappPayment
                    objDialouge.is_razorpayPayment = self.is_razorpayPayment
                    parent.addChild(objDialouge)
                    objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
                    parent.view.addSubview((objDialouge.view)!)
                    objDialouge.didMove(toParent: parent)
                }
            }
            else {
                //Out of India
                self.inapppurchseBuyProduct()
            }
        }
    }
    
    @IBAction func apply_promo_codePressed(sender: UIButton) {
        let str_promo = self.txtPromocode.text ?? ""
        if str_promo.trimed() != "" {
            if self.btn_Apply.currentTitleColor == AppColor.app_DarkGreenColor {
                if self.is_applied_promo == false {
                    self.view.endEditing(true)
                    self.btn_Apply.isUserInteractionEnabled = false
                    self.callAPIforCheckPromocode(promocode: str_promo) { is_sucess in
                        if is_sucess {
                            self.is_applied_promo = true
                            self.txtPromocode.textColor = .darkGray
                            self.btn_Apply.isUserInteractionEnabled = true
                        }
                    }
                }
                else {
                    self.view.endEditing(true)
                    self.is_applied_promo = false
                    self.btn_Apply.setTitle("Apply", for: .normal)
                    self.txtPromocode.text = ""
                    self.txtPromocode.textColor = .black
                    self.img_Applied.isHidden = true
                    self.txtPromocode.isUserInteractionEnabled = true
                }
            }
        }
        
        
    }
    
    //MARK: - UITextFiled Delegate Method
    @objc func text_FieldDidChange_Editing(_ textField: UITextField) {
        if let str_promo = textField.text {
            if str_promo.count > 5 {
                self.btn_Apply.setTitleColor(AppColor.app_DarkGreenColor, for: .normal)
            }
            else {
                self.btn_Apply.setTitleColor(.lightGray, for: .normal)
            }
        }
        else {
            self.btn_Apply.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtPromocode {
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= 10
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    //MARK: - Delegate Payment Option
    func chaoosePaymentOption(_ success: Bool, optionn: PaymentOption) {
        if success {
            if optionn == .inapppurchase {
                self.inapppurchseBuyProduct()
            }
            else if optionn == .krazorpay {
                self.callAPIforRazorpay()
            }
        }
    }
    
    //MARK: - API CALL
    func callAPIforRazorpay() {
        self.showActivityIndicator()
        let params = ["currency": Locale.current.paramCurrencyCode,
                      "language_id" : Utils.getLanguageId(),
                      "device_type": "ios",
                      "favorite_id": plan?.id ?? ""] as [String : Any]
        doAPICall(endPoint: .addRazorpaySubscriptionOrderDetails, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                self?.hideActivityIndicator()
                if (responseJSON?["status"].string ?? "") == "success" {
                    var int_amount = 0.0
                    if let dic_paymnt_info = responseJSON?["Payment_info"].dictionary {
                        int_amount = dic_paymnt_info["amount"]?.double ?? 0
                    }
                    self?.strOrderID = responseJSON?["order_id"].string ?? ""
                    self?.showPaymentForm(amount: int_amount)
                }
                else {
                    let strmsg = (responseJSON?["message"].string ?? "")
                    if strmsg != "" {
                        self?.showAlert(title: status, message: strmsg)
                    }
                }
                
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
            }
        }
        
    }
}

extension SubscriptionDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return aboutPlans.count
        } else {
            return notes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AboutSubPlanDetailCell.self, for: indexPath)
        if indexPath.section == 0 {
            //section title
            cell.titleL.text = aboutPlans[indexPath.row]
        } else {
            //details
            cell.titleL.text = notes[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withClass: AboutSubPlanCell.self)
        cell.titleL.attributedText = NSAttributedString(string: (section == 0) ? "About this plan:".localized() : "Please Note:".localized()).underlined
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }*/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension SubscriptionDetailVC {
    
    func callAPIforCheckPromocode(promocode: String, completion: @escaping (Bool)->Void ) {
        self.showActivityIndicator()
        let params = ["currency": Locale.current.paramCurrencyCode,
                      "language_id" : Utils.getLanguageId(),
                      "promocode": promocode,
                      "device_type": "ios",
                      "favourite_id": plan?.id ?? "",
                      "amount": plan?.amount ?? ""] as [String : Any]
        doAPICall(endPoint: .checkSubscriptionPromocode, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                self?.is_applied_promo = true
                self?.img_Applied.isHidden = false
                self?.txtPromocode.isUserInteractionEnabled = false
                self?.btn_Apply.setTitle("Remove", for: .normal)
                self?.hideActivityIndicator()
                completion(isSuccess)
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
                completion(isSuccess)
            }
        }
    }
    
    func callMakeOrderAPI(receipt: String, completion: @escaping (Bool, ARSubsOrderDetailModel?)->Void ) {
        self.showActivityIndicator()
        let params = ["currency": Locale.current.paramCurrencyCode,
                      "language_id" : Utils.getLanguageId(),
                      "user_id": kSharedAppDelegate.userId,
                      "device_type": "ios",
                      "favorite_id": plan?.id ?? "",
                      "promocode": self.is_applied_promo ? self.txtPromocode.text ?? "" : "",
                      "receipt": receipt] as [String : Any]
        doAPICall(endPoint: .placeSubscriptionOrderIOS, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                let orderDetails = ARSubsOrderDetailModel(fromJson: responseJSON)
                self?.hideActivityIndicator()
                completion(isSuccess, orderDetails)
                //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.buy_subscriptions.rawValue)
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
                completion(isSuccess, nil)
            }
        }
    }
    
    static func showScreen(plan: ARSubscriptionPlanModel?, isReadOnly: Bool = false, fromVC: UIViewController, in_app: Bool = true, razorpay: Bool = false) {
        let vc = SubscriptionDetailVC.instantiate(fromAppStoryboard: .Subscription)
        vc.plan = plan
        vc.isReadOnly = isReadOnly
        vc.is_inappPayment = in_app
        vc.is_razorpayPayment = razorpay
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - In App Purchase Helper
extension SubscriptionDetailVC {
    static func inAppPurchaseSccess(for identifier: String, fromVC: UIViewController? = nil) {
        if let fromVC = fromVC as? SubscriptionDetailVC {
            let receiptString = Self.fetchIAPTransactionReceipt()
            //print(">>> receiptString : ", receiptString.count)
            fromVC.callMakeOrderAPI(receipt: receiptString) { status, orderDetail in
                SubscriptionOrderStatusVC.showScreen(plan: fromVC.plan, orderDetails: orderDetail, status: status, fromVC: fromVC)
            }
        }
    }
    
    static func requestBuyProduct(productId: String, fromVC: UIViewController?) {
        fromVC?.showActivityIndicator()
        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.buy_subscriptions.rawValue)
                print(">>> Purchase Success: \(purchase.productId)")
                fromVC?.hideActivityIndicator()
                Self.inAppPurchaseSccess(for: purchase.productId, fromVC: fromVC)
                
            case .error(let error):
                var errorMsg = "Unknown error. Please contact support"
                switch error.code {
                case .unknown: errorMsg = "Unknown error. Please contact support"
                case .clientInvalid: errorMsg = "Not allowed to make the payment"
                case .paymentCancelled: errorMsg = "Payment cancelled".localized()
                case .paymentInvalid: errorMsg = "The purchase identifier was invalid"
                case .paymentNotAllowed: errorMsg = "The device is not allowed to make the payment"
                case .storeProductNotAvailable: errorMsg = "The product is not available in the current storefront"
                case .cloudServicePermissionDenied: errorMsg = "Access to cloud service information is not allowed"
                case .cloudServiceNetworkConnectionFailed: errorMsg = "Could not connect to the network"
                case .cloudServiceRevoked: errorMsg = "User has revoked permission to use this cloud service"
                default: errorMsg = (error as NSError).localizedDescription
                }
                print(">>> IAP Error : ", errorMsg)
                fromVC?.hideActivityIndicator(withMessage: errorMsg)
                
                if error.code == .clientInvalid ||
                    error.code == .paymentCancelled ||
                    error.code == .paymentInvalid ||
                    error.code == .paymentNotAllowed ||
                    error.code == .storeProductNotAvailable ||
                    error.code == .cloudServicePermissionDenied ||
                    error.code == .cloudServiceNetworkConnectionFailed ||
                    error.code == .cloudServiceRevoked {
                    print(">>> IAP Error : \(error.code), Error Message===>", errorMsg)
                }
                else {
                    var is_navigate = false
                    if let stackVCs = fromVC?.navigationController?.viewControllers {
                        if let activeSubVC = stackVCs.first(where: { type(of: $0) == MyHomeViewController.self }) {
                            is_navigate = true
                            fromVC?.navigationController?.popToViewController(activeSubVC, animated: false)
                        }
                    }
                    
                    if is_navigate == false {
                        fromVC?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    static func fetchIAPTransactionReceipt() -> String {
        //This helper can be used to retrieve the (encrypted) local receipt data:
        let receiptData = SwiftyStoreKit.localReceiptData
        let receiptString = receiptData?.base64EncodedString(options: []) ?? ""
        return receiptString
        
        //Other solution
        //However, the receipt file may be missing or outdated. Use this method to get the updated receipt:
        /*SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                print("Fetch receipt success:\n\(encryptedReceipt)")
            case .error(let error):
                print("Fetch receipt failed: \(error)")
            }
        }*/
    }
    
    static func completeAnyPendingIAPTransactions(fromVC: UIViewController?) {
        //Non-Atomic: to be used when the content is delivered by the server.
        //Atomic: to be used when the content is delivered immediately.
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            debugPrint(purchases)
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    print(">>> Purchase Success: \(purchase.productId)")
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                    Self.inAppPurchaseSccess(for: purchase.productId, fromVC: fromVC)
                    
                case .failed, .purchasing, .deferred:
                    break // do nothing
                    
                @unknown default:
                    break // do nothing
                }
            }
        }
    }
    
    
    static func restore_subscription() {
        SwiftyStoreKit.restorePurchases { resulll in
            debugPrint(resulll)
        }
    }

}

// MARK: - RazorpayPaymentCompletionProtocol Methods
extension SubscriptionDetailVC: RazorpayPaymentCompletionProtocol, RazorpayPaymentCompletionProtocolWithData {
    func onPaymentError(_ code: Int32, description str: String) {
        showErrorAlert(message: str)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        print("Payment success : ", payment_id)
    }
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        showErrorAlert(message: str)
    }
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        print("Payment success with data : ", response)
        if let response = response, let paymentID = response["razorpay_payment_id"] as? String {
            showActivityIndicator()
            
            let params = ["transaction_status": 1,
                          "payment_id":  paymentID,
                          "order_id":  self.strOrderID,
                          "signature": "",
                          "device_type": "ios",
                          "language_id" : Utils.getLanguageId()] as [String: Any]
            
            doAPICall(endPoint: .updateRazorpaySubscriptionOrderDetail, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
                if isSuccess {
                    self?.hideActivityIndicator()
                    guard let strongSelf = self else{ return }
                    let orderDetails = ARSubsOrderDetailModel(fromJson: responseJSON)
                    orderDetails.orderDetails?.orderId = self?.strOrderID ?? ""
                    SubscriptionOrderStatusVC.showScreen(plan: strongSelf.plan, orderDetails: orderDetails, status: isSuccess, fromVC: strongSelf)
                }
                else {
                    self?.hideActivityIndicator()
                    self?.showErrorAlert(message: "Fail to prime subscription, please try after some time".localized())
                }
            }
        }
    }
    
    func showPaymentForm(amount: Double) {

        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            return
        }
        let ayutythmUserName = empData["name"] as? String ?? ""
        let ayutythmUserPhone = empData["mobile"] as? String ?? ""
        let ayutythmUserEmail = empData["email"] as? String ?? ""

        let total_Amount = amount

        self.razorpayObj = RazorpayCheckout.initWithKey(kRazorpayKey_Subscription, andDelegateWithData: self)
        let options: [String:Any] = ["timeout":900,
                                     "currency": Locale.current.paramCurrencyCode,
                                     "description": "Prime Plan",
                                     "name": ayutythmUserName,
                                     "razorpay_order_id": self.strOrderID,
                                     "amount": "\(total_Amount*100)",
                                     "image": UIImage.init(named: "Splashlogo")!,
                                     "prefill": ["contact": ayutythmUserPhone,
                                                 "email": ayutythmUserEmail],
                                     "theme": ["color": "#019345"]]

        if let rzp = self.razorpayObj {
            rzp.open(options)
        } else {
            print("Unable to initialize")
        }

    }
}




// MARK: -
class AboutSubPlanCell: UITableViewCell {
    @IBOutlet weak var titleL: UILabel!
}

class AboutSubPlanDetailCell: UITableViewCell {
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var titleL: UILabel!
}
