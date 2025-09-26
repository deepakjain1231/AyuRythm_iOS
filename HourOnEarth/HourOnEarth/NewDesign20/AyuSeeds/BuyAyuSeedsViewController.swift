//
//  BuyAyuSeedsViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 09/10/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import Razorpay

class BuyAyuSeedsViewController: BaseViewController {

    @IBOutlet weak var totalSeedsL: UILabel!
    @IBOutlet weak var totalDueL: UILabel!
    @IBOutlet weak var bonusTitleL: UILabel!
    @IBOutlet weak var bonusValueL: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    var razorpay: RazorpayCheckout!
    var ayuSeedsData: BuyAyuSeedInfo?
    var completion : ((Bool, String)->Void)?
    
    var totalSeeds: Float = 0.0
    var totalAmount: Float = 0.0
    var bonusSeeds: Float = 0.0
    var orderID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        
        setupUI()
    }
    
    func setupUI() {
        razorpay = RazorpayCheckout.initWithKey(kRazorpayKey_Subscription, andDelegateWithData: self)
        
        guard let ayuSeedsData = ayuSeedsData else { return }
        
        bonusTitleL.text = ayuSeedsData.bonusTitle
        bonusValueL.text = ayuSeedsData.bonusMessage
        updateUI(for: Float(stepper.value))
    }
    
    func updateUI(for value: Float) {
        guard let ayuSeedsData = ayuSeedsData else { return }
        
        totalSeeds = ayuSeedsData.multiplesAmount * value
        totalSeedsL.text = totalSeeds.nonDecimalStringValue
        totalAmount = ayuSeedsData.amount * value
        totalDueL.text = "Total Due: ".localized() + totalAmount.priceValueString
        if totalAmount >= ayuSeedsData.minimumBonusAmount {
            bonusSeeds = totalSeeds * (ayuSeedsData.bonusPercentage/100)
        }
        print("Bonus Seeds : ", bonusSeeds)
    }
    
    @IBAction func cancelBtnPressed(sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.completion?(false, "")
        }
        
    }
    
    @IBAction func stepperValueDidChange(sender: UIStepper) {
        print("stepper value : ", sender.value)
        updateUI(for: Float(sender.value))
    }
    
    @IBAction func confirmAndBayBtnPressed(sender: UIButton) {
        guard let ayuSeedsData = ayuSeedsData else { return }
        
        //amount=25&bonus_percentage=10&total_amount=100&multiples_amount=1000&bonus_amount=400&qty=4&total_ayuseeds=4400&currency=INR
        let params = ["amount": ayuSeedsData.amount!,
                      "bonus_percentage": ayuSeedsData.bonusPercentage!,
                      "multiples_amount": ayuSeedsData.multiplesAmount!,
                      "total_amount": totalAmount,
                      "bonus_amount": bonusSeeds,
                      "total_ayuseeds": (totalSeeds + bonusSeeds),
                      "qty": stepper.value,
                      "currency": ayuSeedsData.currency!,
                      "language_id" : Utils.getLanguageId()] as [String : Any]
        print(params)
        //self.orderID = "123"
        //self.showPaymentForm()
        placeBuyAyuSeedsOrder(params: params) { [weak self] (isSuccess, message, orderID) in
            if isSuccess {
                self?.orderID = orderID
                self?.showPaymentForm()
            } else {
                self?.showErrorAlert(message: message)
            }
        }
    }
    
    static func showScreen(presentingVC: UIViewController?, completion: ((Bool, String)->Void)? = nil) {
        presentingVC?.showActivityIndicator()
        getAyuSeedsInfoFromServer { (isSuccess, message, data) in
            presentingVC?.hideActivityIndicator()
            if isSuccess {
                let vc = BuyAyuSeedsViewController.instantiateFromStoryboard("AyuSeeds")
                vc.ayuSeedsData = data
                vc.completion = completion
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                presentingVC?.present(vc, animated: true, completion: nil)
            } else {
                presentingVC?.showErrorAlert(message: message)
            }
        }
    }
}

// MARK: - RazorpayPaymentCompletionProtocol Methods
extension BuyAyuSeedsViewController: RazorpayPaymentCompletionProtocol, RazorpayPaymentCompletionProtocolWithData {
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
        
        //transaction_status=2&payment_id=test123456789123&order_id=Ayuseeds_202010A00001&signature=asssadadddddddddddddd&ayuseeds_points=4400&language_id=1
        //Optional([AnyHashable("razorpay_order_id"): order_FnuzOwBTK0RMH0, AnyHashable("razorpay_payment_id"): pay_Fnv0xvo1rqrZxS, AnyHashable("razorpay_signature"): 0f99259a2614ed07f0f083a3428706c1f4402e641f2823eb42ce7e8a5af101e0])
        showActivityIndicator()
        if let response = response, let paymentID = response["razorpay_payment_id"] as? String, let orderID = response["razorpay_order_id"] as? String, let signature = response["razorpay_signature"] as? String {
            let params = ["transaction_status": 1,
                          "payment_id":  paymentID,
                          "order_id":  orderID,
                          "signature": signature,
                          "ayuseeds_points": (totalSeeds + bonusSeeds),
                          "language_id" : Utils.getLanguageId()] as [String: Any]
            updateBuyAyuSeedsOrder(params: params) { [weak self] (isSuccess, message, title) in
                guard let strongSelf = self else{ return }
                strongSelf.hideActivityIndicator()
                Utils.showAlertWithTitleInControllerWithCompletion(title, message: message, okTitle: "Ok".localized(), controller: strongSelf) { [weak self] in
                    if isSuccess {
                        self?.dismiss(animated: true) { [weak self] in
                            self?.completion?(isSuccess, message)
                        }
                    }
                }
            }
        } else {
            hideActivityIndicator()
            showErrorAlert(message: "Fail to place buy AyuSeeds order, please try after some time".localized())
        }
    }
    
    func showPaymentForm() {
        var options: [String:Any] = [
            "description": "Buy AyuSeeds".localized(),
            //"razorpay_order_id": orderID ?? "",
            "order_id": orderID ?? "",
            "name": "Total AyuSeeds : ".localized() + totalSeeds.nonDecimalStringValue,
            
            "theme": ["color": "#F37254"]
        ]
        
        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
            options["prefill"] = ["contact":  empData["mobile"], "email": empData["email"]]
        }
        
        options["currency"] = ayuSeedsData?.currency
        //options["amount"] = totalAmount
        razorpay.open(options, displayController: self)
    }
}

// MARK: - API calls
extension BuyAyuSeedsViewController {
    func updateBuyAyuSeedsOrder(params: [String: Any], completion: @escaping (Bool, String, String?)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.updateAyuseedsOrderDetails.rawValue
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        completion(false, "", nil)
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? "Fail to place buy AyuSeeds order, please try after some time".localized()
                    let title = dicResponse["title"] as? String
                    
                    let isSuccess = (status.lowercased() == "Success".lowercased())
                    completion(isSuccess, message, title)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription, nil)
                }
            }
        } else {
            completion(false, NO_NETWORK, nil)
        }
    }
    
    func placeBuyAyuSeedsOrder(params: [String: Any], completion: @escaping (Bool, String, String?)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.AddAyuseedsOrderDetails.rawValue
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        completion(false, "", nil)
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? "Fail to place buy AyuSeeds order, please try after some time".localized()
                    let orderID = dicResponse["order_id"] as? String
                    
                    let isSuccess = (status.lowercased() == "Success".lowercased())
                    completion(isSuccess, message, orderID)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription, nil)
                }
            }
        } else {
            completion(false, NO_NETWORK, nil)
        }
    }
    
    static func getAyuSeedsInfoFromServer(completion: @escaping (Bool, String, BuyAyuSeedInfo?)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.getAyuseedsInfo.rawValue
            let params = ["currency": Locale.current.isCurrencyCodeInINR ? "INR" : "USD", "language_id" : Utils.getLanguageId()] as [String : Any]

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        completion(false, "", nil)
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? "Fail to get AyuSeeds info, please try after some time".localized()
                    var ayuSeedInfo: BuyAyuSeedInfo?
                    if let dataArray = dicResponse["data"] as? [[String: Any]],let data = dataArray.first {
                        ayuSeedInfo = BuyAyuSeedInfo(fromDictionary: data)
                    }
                    let isSuccess = (status.lowercased() == "Success".lowercased())
                    completion(isSuccess, message, ayuSeedInfo)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription, nil)
                }
            }
        } else {
            completion(false, NO_NETWORK, nil)
        }
    }
}
