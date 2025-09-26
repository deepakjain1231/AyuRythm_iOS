//
//  FaceNaadiSubscriptionListVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 03/11/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import Razorpay
import SwiftyStoreKit

class FaceNaadiSubscriptionListVC: BaseViewController, UITextFieldDelegate, delegatePaymentOption, didTappedDelegate {
    
    var strOrderID = ""
    var is_inappPayment = true
    var is_razorpayPayment = false
    var razorpayObj : RazorpayCheckout? = nil
    
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Header_Title: UILabel!
    @IBOutlet weak var lbl_sub_Title: UILabel!
    @IBOutlet weak var tbl_View: UITableView!
    
    var strplanID = ""
    var arr_section = [[String: Any]]()
    var str_screenFrom = ScreenType.k_none
    var arr_plans = [ARSubscriptionPlanModel]()
    //var selectedIndexPath: IndexPath?
    var selectedPlan: ARSubscriptionPlanModel?
    var isViewPresented = false
    var did_completation: ((String)->Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_Header_Title.text = "Choose Plan".localized()
        self.lbl_Title.text = "Join us today".localized()
        self.navigationController?.isNavigationBarHidden = true
        
        if self.str_screenFrom == .from_AyuMonk_Only {
            self.lbl_sub_Title.text = "Chat with AyuMonk, your AI companion for tailored diet plans, recipe and holistic life advice.".localized()
        }
        else if self.str_screenFrom == .from_home_remedies {
            self.lbl_sub_Title.text = "Personalized home remedies, aligned with your doshas.".localized()
        }
        else if self.str_screenFrom == .from_finger_assessment {
            self.lbl_sub_Title.text = "Unveil your unique dosha balance effortlessly with our quick 30-second pulse assessment, by simple touch of your finger on your smartphone camera.".localized()
        }
        else if self.str_screenFrom == .from_dietplan {
            self.lbl_sub_Title.text = "Unlock curated diet plans with benefits, nutritional info, and detailed recipes with optimal meal times.".localized()
        }
        else {
            self.lbl_sub_Title.text = "Uncover your current dosha harmony effortlessly with our exclusive 30-second selfie video pulse assessment.".localized()
        }
        
        setBackButtonTitle()
        if isViewPresented {
            let cancelBarBtn = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(cancelBtnPressed(_:)))
            self.navigationItem.rightBarButtonItem = cancelBarBtn
        }
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if appDelegate.facenaadi_subscriptionDone {
            appDelegate.facenaadi_subscriptionDone = false
            appDelegate.sparshanAssessmentDone = true
            
            var is_navigate = false
            if let stackVCs = self.navigationController?.viewControllers {
                if let activeSubVC = stackVCs.first(where: { type(of: $0) == MyHomeViewController.self }) {
                    is_navigate = true
                    self.navigationController?.popToViewController(activeSubVC, animated: false)
                }
            }
            
            if is_navigate == false {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func cancelBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        self.tbl_View.register(nibWithCellClass: FaceNaadiPromocodeTableCell.self)
        self.tbl_View.register(nibWithCellClass: FaceNaadiSubcriptionPackTableCell.self)
        fetchPlanList()
    }
    
//    func updatePlanUI(at indexPath: IndexPath?) {
//        guard let indexPath = indexPath else { return }
//
//        let plan = plans[indexPath.row]
//        selectedPlan = plan
//    }

    
    // MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FaceNaadiSubscriptionListVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_section.removeAll()
        
        if self.arr_plans.count != 0 {
            for dic_plan in self.arr_plans {
                self.arr_section.append(["identifier" : "plan_data", "title": "", "value": dic_plan])
            }
        }
        
        if let is_SBIPromop = UserDefaults.user.get_user_info_result_data["isSBIPromocodeUsed"] as? Bool  {
            if is_SBIPromop {
                self.arr_section.append(["identifier" : "promo_code", "title": ""])
            }
        }

        self.tbl_View.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let str_identifier = self.arr_section[indexPath.row]["identifier"] as? String ?? ""
        
        if str_identifier == "promo_code" {
            let cell = tableView.dequeueReusableCell(withClass: FaceNaadiPromocodeTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.txt_coupon.delegate = self
            cell.txt_coupon.autocapitalizationType = .allCharacters
            cell.btn_Apply.setTitleColor(.lightGray, for: .normal)
            cell.txt_coupon.addTarget(self, action: #selector(self.text_FieldDidChange_Editing(_:)), for: .editingChanged)
            
            self.did_completation = { (txt_promo) in
                if txt_promo.count > 4 {
                    cell.btn_Apply.setTitleColor(AppColor.app_DarkGreenColor, for: .normal)
                }
                else {
                    cell.btn_Apply.setTitleColor(.lightGray, for: .normal)
                }
            }
            
            cell.didTappedApplyButton = { (sender) in
                self.view.endEditing(true)
                self.btn_apply_Pressed(sender, str_PromoCode: cell.txt_coupon.text ?? "")
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withClass: FaceNaadiSubcriptionPackTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.bgView.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.bgView.layer.borderWidth = 1
        cell.bgView.layer.borderColor = UIColor.fromHex(hexString: "#89BF89").cgColor
        
        if let dic_data = self.arr_section[indexPath.row]["value"] as? ARSubscriptionPlanModel {
            let months = dic_data.packMonths 
            let monthStr = "\(months) " + (months > 1 ? "Months".localized() : "Month".localized())
            cell.titleL.text = dic_data.amount.priceValueString + "/ " + monthStr
            cell.subtitleL.text = dic_data.aboutThisPack 
            
            cell.statusBtn.isSelected = ((self.selectedPlan?.id ?? "") == (dic_data.id))
            
            cell.bgView.layer.borderWidth = ((self.selectedPlan?.id ?? "") == (dic_data.id)) ? 2 : 1
            cell.bgView.layer.borderColor = ((self.selectedPlan?.id ?? "") == (dic_data.id)) ? UIColor.fromHex(hexString: "#89BF89").cgColor : UIColor.fromHex(hexString: "#E6E6E6").cgColor
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str_identifier = self.arr_section[indexPath.row]["identifier"] as? String ?? ""
        if str_identifier == "plan_data" {
            if let dic_data = self.arr_section[indexPath.row]["value"] as? ARSubscriptionPlanModel {
                self.selectedPlan = dic_data
            }
            self.tbl_View.reloadData()

            let objDialouge = FaceNaadiPlanDetailVC(nibName:"FaceNaadiPlanDetailVC", bundle:nil)
            objDialouge.delegate = self
            objDialouge.screen_From = self.str_screenFrom
            objDialouge.selectedPlan = selectedPlan
            self.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
            self.view.addSubview((objDialouge.view)!)
            objDialouge.didMove(toParent: self)
        }
    }
    
    func btn_apply_Pressed(_ sender: UIButton, str_PromoCode: String) {
        if str_PromoCode.trimed() != "" {
            if sender.currentTitleColor == AppColor.app_DarkGreenColor {
                self.view.endEditing(true)
                self.callAPIforCheck_Apply_Promocode(promocode: str_PromoCode) { is_sucess, strMSG in
                    if is_sucess {
                        
                        let alertController = UIAlertController(title: "", message: strMSG, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { (_) in
                            
                            if self.str_screenFrom == .from_AyuMonk_Only {
                                UserDefaults.user.set_ayumonk_Subscribed(data: true)
                                self.navigationController?.popViewController(animated: true)
                            }
                            else if self.str_screenFrom == .from_home_remedies {
                                UserDefaults.user.set_home_remedies_Subscribed(data: true)
                                self.navigationController?.popViewController(animated: true)
                            }
                            else if self.str_screenFrom == .from_finger_assessment {
                                UserDefaults.user.set_finger_Subscribed(data: true)

                                if let stackVCs = self.navigationController?.viewControllers {
                                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == CurrentImbalanceVC.self }) {
                                        (activeSubVC as? CurrentImbalanceVC)?.is_subscriptionPurchased_Finger = true
                                    }
                                }

                                self.navigationController?.popViewController(animated: true)
                            }
                            else if self.str_screenFrom == .from_dietplan {
                                appDelegate.is_start_dietPlan = true
                                appDelegate.facenaadi_subscriptionDone = true
                                UserDefaults.user.set_diet_plan_Subscribed(data: true)

                                if let stackVCs = self.navigationController?.viewControllers {
                                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == MyHomeViewController.self }) {
                                        self.navigationController?.popToViewController(activeSubVC, animated: true)
                                    }
                                }
                            }
                            else {
                                var is_screenFound = false
                                UserDefaults.user.set_facenaadi_Subscribed(data: true)
                                
                                if let stackVCs = self.navigationController?.viewControllers {
                                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == CurrentImbalanceVC.self }) {
                                        is_screenFound = true
                                        (activeSubVC as? CurrentImbalanceVC)?.is_subscriptionPurchased_Facenadi = true
                                    }
                                }
                                
                                if is_screenFound {
                                    self.navigationController?.popViewController(animated: true)
                                }
                                else {
                                    //Go To FaceNaadi Screen
                                    let objBalVC = Story_LoginSignup.instantiateViewController(withIdentifier: "CurrentImbalanceVC") as! CurrentImbalanceVC
                                    objBalVC.isBackButtonHide = false
                                    objBalVC.is_DirectFaceNaadi = true
                                    self.navigationController?.pushViewController(objBalVC, animated: true)
                                }
                            }
                            
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //MARK: - UITextFiled Delegate Method
    @objc func text_FieldDidChange_Editing(_ textField: UITextField) {
        if let str_promo = textField.text {
            self.did_completation?(str_promo)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= 10
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
            
}

extension FaceNaadiSubscriptionListVC: delegate_buyPlan {
    
    func fetchPlanList() {
        self.showActivityIndicator()
        let currency = Locale.current.paramCurrencyCode
        let params = ["currency": currency, "language_id" : Utils.getLanguageId(), "device_type": "ios"] as [String : Any]
        
        var endpointt: endPoint = .getFacenaadiSubscriptionPacks
        
        if self.str_screenFrom == .from_AyuMonk_Only {
            endpointt = .getAyumonkSubscriptionPacks
        }
        else if self.str_screenFrom == .from_home_remedies {
            endpointt = .getRemediesSubscriptionPacks
        }
        else if self.str_screenFrom == .from_finger_assessment {
            endpointt = .getFingerSubscriptionPacks
        }
        else if self.str_screenFrom == .from_dietplan {
            endpointt = .getDietPlanSubscriptionPacks
        }
        
        doAPICall(endPoint: endpointt, parameters: params, headers: headers) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                self?.is_inappPayment = responseJSON?["in_app"].bool ?? true
                self?.is_razorpayPayment = responseJSON?["razorpay"].bool ?? false
                let plans = responseJSON?["data"].array?.compactMap{ ARSubscriptionPlanModel(fromJson: $0) } ?? []
                self?.arr_plans = plans
                self?.manageSection()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
            }
        }
    }
    
    func didTappedClose(_ success: Bool, product_id: String) {
        Self.requestBuyProduct(productId: product_id, fromVC: self)
    }
    
    
    func chooseFaceNaadiPlan(_ success: Bool, plan_product_id: String) {
        if success {
            if self.is_inappPayment && self.is_razorpayPayment == false {
                self.inapppurchseBuyProduct(plan_product_id: self.selectedPlan?.pack_id ?? "")
            }
            else if self.is_inappPayment == false && self.is_razorpayPayment == false {
                self.inapppurchseBuyProduct(plan_product_id: self.selectedPlan?.pack_id ?? "")
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
                    self.inapppurchseBuyProduct(plan_product_id: self.selectedPlan?.pack_id ?? "")
                }
            }
        }
    }
    
    func inapppurchseBuyProduct(plan_product_id: String) {
        let objDialouge = WellnessJourneyDialouge(nibName:"WellnessJourneyDialouge", bundle:nil)
        objDialouge.str_product_ID = plan_product_id
        objDialouge.screen_from = .from_subscription
        objDialouge.delegate =  self
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }
    
    func chaoosePaymentOption(_ success: Bool, optionn: PaymentOption) {
        if success {
            if optionn == .inapppurchase {
                self.inapppurchseBuyProduct(plan_product_id: self.selectedPlan?.pack_id ?? "")
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
                      "favorite_id": self.selectedPlan?.id ?? ""] as [String : Any]
        
        var enddPoint: endPoint = .addDietPlanRazorpaySubscription
        
        if self.str_screenFrom == .from_finger_assessment {
            enddPoint = .addSparshnaRazorpaySubscription
        }
        else if self.str_screenFrom == .from_AyuMonk_Only {
            enddPoint = .addAyumonkRazorpaySubscription
        }
        else if self.str_screenFrom == .from_home_remedies {
            enddPoint = .addHomeRemediesRazorpaySubscription
        }
        else if self.str_screenFrom == .fromFaceNaadi {
            enddPoint = .addFaceNaadiRazorpaySubscription
        }
        else if self.str_screenFrom == .from_dietplan {
            enddPoint = .addDietPlanRazorpaySubscription
        }

        doAPICall(endPoint: enddPoint, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
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

// MARK: - RazorpayPaymentCompletionProtocol Methods
extension FaceNaadiSubscriptionListVC: RazorpayPaymentCompletionProtocol, RazorpayPaymentCompletionProtocolWithData {
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
            
            var enddPoint: endPoint = .updateDietPlanRazorpaySubscription
            
            if self.str_screenFrom == .from_finger_assessment {
                enddPoint = .updateSparshnaRazorpaySubscription
            }
            else if self.str_screenFrom == .from_AyuMonk_Only {
                enddPoint = .updateAyumonkRazorpaySubscription
            }
            else if self.str_screenFrom == .from_home_remedies {
                enddPoint = .updateHomeRemediesRazorpaySubscription
            }
            else if self.str_screenFrom == .fromFaceNaadi {
                enddPoint = .updateFaceNaadiRazorpaySubscription
            }
            else if self.str_screenFrom == .from_dietplan {
                enddPoint = .updateDietPlanRazorpaySubscription
            }

            doAPICall(endPoint: enddPoint, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
                if isSuccess {
                    self?.hideActivityIndicator()
                    guard let strongSelf = self else{ return }
                    let orderDetails = ARSubsOrderDetailModel(fromJson: responseJSON)
                    orderDetails.orderDetails?.orderId = self?.strOrderID ?? ""
                    SubscriptionOrderStatusVC.showScreen(plan: strongSelf.selectedPlan, orderDetails: orderDetails, status: isSuccess, fromVC: strongSelf, screnn_from: strongSelf.str_screenFrom)
                }
                else {
                    if let fromvc = self {
                        fromvc.hideActivityIndicator()
                        fromvc.showErrorAlert(message: "Fail to prime subscription, please try after some time".localized())
                    }
                    
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
                                     "description": "Subscription Plan",
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

extension FaceNaadiSubscriptionListVC {
    
    func callAPIforCheck_Apply_Promocode(promocode: String, completion: @escaping (Bool, String?)->Void ) {
        self.showActivityIndicator()
        var params = ["coupon_code": promocode,
                      "language_id": Utils.getLanguageId()] as [String : Any]
        
        if self.str_screenFrom == .from_finger_assessment {
            params["subscription_type"] = "finger_assessment"
        }
        else if self.str_screenFrom == .from_AyuMonk_Only {
            params["subscription_type"] = "ayumonk"
        }
        else if self.str_screenFrom == .from_home_remedies {
            params["subscription_type"] = "home_remedies"
        }
        else if self.str_screenFrom == .fromFaceNaadi {
            params["subscription_type"] = "facenaadi"
        }
        else if self.str_screenFrom == .from_dietplan {
            params["subscription_type"] = "diet_plan"
        }
        
        doAPICall(endPoint: .checkFaceNaadiSubscriptionPromocode, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            var str_validity_msg = ""
            if isSuccess {
                if let dic_res = responseJSON?["response"].dictionary {
                    str_validity_msg = dic_res["validity_message"]?.stringValue ?? ""
                }
                appDelegate.sparshanAssessmentDone = true
                self?.hideActivityIndicator()
                completion(isSuccess, str_validity_msg)
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
                completion(isSuccess, "")
            }
        }
    }
}

// MARK: - In App Purchase Helper
extension FaceNaadiSubscriptionListVC {
    
    static func inAppPurchaseSccess(for identifier: String, fromVC: UIViewController? = nil) {
        if let fromVC = fromVC as? FaceNaadiSubscriptionListVC {
            let receiptString = Self.fetchIAPTransactionReceipt()
            //print(">>> receiptString : ", receiptString.count)
            fromVC.callMakeOrderAPI(receipt: receiptString) { status, orderDetail in
                appDelegate.sparshanAssessmentDone = true
                SubscriptionOrderStatusVC.showScreen(plan: fromVC.selectedPlan, orderDetails: orderDetail, status: status, fromVC: fromVC, screnn_from: fromVC.str_screenFrom)
            }
        }
    }
    
    //Temp comment//
    static func requestBuyProduct(productId: String, fromVC: UIViewController?) {
        let str_BuyProduct_ID = productId//Temp
        fromVC?.showActivityIndicator()
        SwiftyStoreKit.purchaseProduct(str_BuyProduct_ID, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
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
            }
        }
    }
    
    static func fetchIAPTransactionReceipt() -> String {
        //This helper can be used to retrieve the (encrypted) local receipt data:
        let receiptData = SwiftyStoreKit.localReceiptData
        let receiptString = receiptData?.base64EncodedString(options: []) ?? ""
        return receiptString
    }
    
    static func completeAnyPendingIAPTransactions() {
        //Non-Atomic: to be used when the content is delivered by the server.
        //Atomic: to be used when the content is delivered immediately.
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    print(">>> Purchase Success: \(purchase.productId)")
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                    
                @unknown default:
                    break // do nothing
                }
            }
        }
    }
}


extension FaceNaadiSubscriptionListVC {
    func callMakeOrderAPI(receipt: String, completion: @escaping (Bool, ARSubsOrderDetailModel?)->Void ) {
        self.showActivityIndicator()
        let params = ["currency": Locale.current.paramCurrencyCode,
                      "language_id" : Utils.getLanguageId(),
                      "device_type": "ios",
                      "favorite_id": self.selectedPlan?.id ?? "",
                      "payment_receipt": receipt] as [String : Any]

        var api_end_Point: endPoint = .placeFacenaddiSubscriptionOrderIOS

        if self.str_screenFrom == .from_AyuMonk_Only {
            api_end_Point = .placeAyumonkSubscriptionOrderIOS
        }
        else if self.str_screenFrom == .from_home_remedies {
            api_end_Point = .placeHomeRemediesSubscriptionOrderIOS
        }
        else if self.str_screenFrom == .from_finger_assessment {
            api_end_Point = .placeFingerSubscriptionOrderIOS
        }
        else if self.str_screenFrom == .from_dietplan {
            api_end_Point = .placeDietPlanSubscriptionOrderIOS
        }
        
        doAPICall(endPoint: api_end_Point, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                let orderDetails = ARSubsOrderDetailModel(fromJson: responseJSON)
                self?.hideActivityIndicator()
                completion(isSuccess, orderDetails)
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
                completion(isSuccess, nil)
            }
        }
    }
    
    static func showScreen(plan: ARSubscriptionPlanModel?, isReadOnly: Bool = false, fromVC: UIViewController) {
        let vc = SubscriptionDetailVC.instantiate(fromAppStoryboard: .Subscription)
        vc.plan = plan
        vc.isReadOnly = isReadOnly
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}
