//
//  NadiGuruFillDetailsVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 28/04/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import Razorpay

class NadiGuruFillDetailsVC: UIViewController, didSelectOptionSuccess_Failed {

    var int_fees = 0
    var fees_withGST = 0
    var str_orderr_ID = ""
    var str_qualification = ""
    var is_spotSelection = false
    var str_registation_Type = ""
    var is_qualificationSelection = false
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_name: UITextField!
    @IBOutlet weak var txt_whatsAppNumber: UITextField!
    @IBOutlet weak var txt_answer: UITextView!
    @IBOutlet weak var lbl_btnText: UILabel!
    
    @IBOutlet weak var img_courrse1: UIImageView!
    @IBOutlet weak var img_courrse2: UIImageView!
    @IBOutlet weak var img_courrse3: UIImageView!
    @IBOutlet weak var img_courrse4: UIImageView!
    @IBOutlet weak var img_courrse5: UIImageView!
    
    @IBOutlet weak var img_qualification1: UIImageView!
    @IBOutlet weak var img_qualification2: UIImageView!
    @IBOutlet weak var img_qualification3: UIImageView!
    @IBOutlet weak var img_qualification4: UIImageView!
    
    var razorpayObj : RazorpayCheckout? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.txt_answer.text = ""
        self.title = "Fill details"
        self.lbl_btnText.text = "Pay"
        
        guard var empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            return
        }
        self.txt_name.text = empData["name"] as? String ?? ""
        self.txt_email.text = empData["email"] as? String ?? ""
        self.txt_whatsAppNumber.text = empData["mobile"] as? String ?? ""
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func spotRegistation_action1(_ sender: UIControl) {
        self.int_fees = 1200
        self.is_spotSelection = true
        self.lbl_btnText.text = "Pay ₹1200"
        self.str_registation_Type = "Only Course"
        self.img_courrse1.image = UIImage.init(named: "nadi_option_selected")
        self.img_courrse2.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse3.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse4.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse5.image = UIImage.init(named: "nadi_option_unselected")
    }
    
    @IBAction func spotRegistation_action2(_ sender: UIControl) {
        self.int_fees = 1700
        self.is_spotSelection = true
        self.lbl_btnText.text = "Pay ₹1700"
        self.str_registation_Type = "Course with access to recording"
        self.img_courrse1.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse2.image = UIImage.init(named: "nadi_option_selected")
        self.img_courrse3.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse4.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse5.image = UIImage.init(named: "nadi_option_unselected")
    }
    
    @IBAction func spotRegistation_action3(_ sender: UIControl) {
        self.int_fees = 1800
        self.is_spotSelection = true
        self.lbl_btnText.text = "Pay ₹1800"
        self.str_registation_Type = "Course with soft copy book, Workbook & Certificate"
        self.img_courrse1.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse2.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse3.image = UIImage.init(named: "nadi_option_selected")
        self.img_courrse4.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse5.image = UIImage.init(named: "nadi_option_unselected")
    }
    
    @IBAction func spotRegistation_action4(_ sender: UIControl) {
        self.int_fees = 2300
        self.is_spotSelection = true
        self.lbl_btnText.text = "Pay ₹2300"
        self.str_registation_Type = "Course with soft copies of book , Workbook, Certificate & Recording"
        self.img_courrse1.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse2.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse3.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse4.image = UIImage.init(named: "nadi_option_selected")
        self.img_courrse5.image = UIImage.init(named: "nadi_option_unselected")
    }
    
    @IBAction func spotRegistation_action5(_ sender: UIControl) {
        self.int_fees = 4000
        self.is_spotSelection = true
        self.lbl_btnText.text = "Pay ₹4000"
        self.str_registation_Type = "Course with soft copy of  Nadi E samhita, Certificate & Recording"
        self.img_courrse1.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse2.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse3.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse4.image = UIImage.init(named: "nadi_option_unselected")
        self.img_courrse5.image = UIImage.init(named: "nadi_option_selected")
    }
    
    @IBAction func btn_qualification1(_ sender: UIControl) {
        self.str_qualification = "BAMS"
        self.is_qualificationSelection = true
        self.img_qualification1.image = UIImage.init(named: "nadi_option_selected")
        self.img_qualification2.image = UIImage.init(named: "nadi_option_unselected")
        self.img_qualification3.image = UIImage.init(named: "nadi_option_unselected")
        self.img_qualification4.image = UIImage.init(named: "nadi_option_unselected")
    }
    
    @IBAction func btn_qualification2(_ sender: UIControl) {
        self.str_qualification = "MD/MS/Phd in Ayurved"
        self.is_qualificationSelection = true
        self.img_qualification1.image = UIImage.init(named: "nadi_option_unselected")
        self.img_qualification2.image = UIImage.init(named: "nadi_option_selected")
        self.img_qualification3.image = UIImage.init(named: "nadi_option_unselected")
        self.img_qualification4.image = UIImage.init(named: "nadi_option_unselected")
    }
    
    @IBAction func btn_qualification3(_ sender: UIControl) {
        self.str_qualification = "Other medical Qualification"
        self.is_qualificationSelection = true
        self.img_qualification1.image = UIImage.init(named: "nadi_option_unselected")
        self.img_qualification2.image = UIImage.init(named: "nadi_option_unselected")
        self.img_qualification3.image = UIImage.init(named: "nadi_option_selected")
        self.img_qualification4.image = UIImage.init(named: "nadi_option_unselected")
    }
    
    @IBAction func btn_qualification4(_ sender: UIControl) {
        self.str_qualification = "Non medical Qualification"
        self.is_qualificationSelection = true
        self.img_qualification1.image = UIImage.init(named: "nadi_option_unselected")
        self.img_qualification2.image = UIImage.init(named: "nadi_option_unselected")
        self.img_qualification3.image = UIImage.init(named: "nadi_option_unselected")
        self.img_qualification4.image = UIImage.init(named: "nadi_option_selected")
    }
    
    @IBAction func btn_Pay_Action(_ sender: UIControl) {
        if self.txt_email?.text?.isEmpty ?? true  || self.is_spotSelection == false || self.is_qualificationSelection == false || self.txt_name?.text?.isEmpty ?? true || self.txt_whatsAppNumber?.text?.isEmpty ?? true {
            Utils.showAlertWithTitleInController(APP_NAME, message: "All fields are mandatory!", controller: self)
        }
        else if !Utils.isValidEmail(testStr: (self.txt_email?.text ?? "")) {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter valid email.".localized(), controller: self)
        }
        else {
            //Pay
            DispatchQueue.main.async {
                self.view.endEditing(true)
            }
            self.callAPIforSubmitForm()
        }
        
    }
    
    
    func callAPIforSubmitForm() {
        
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.nadiGuruForm.rawValue
            
            
            let params = ["registration_type": self.str_registation_Type,
                          "email": self.txt_email.text ?? "",
                          "fees": "\(self.int_fees)",
                          "name": self.txt_name.text ?? "",
                          "whatsapp_no": self.txt_whatsAppNumber.text ?? "",
                          "qualification": self.str_qualification,
                          "learn_answer": self.txt_answer.text ?? "",
                          "currency": "INR"]
            
            print(params)
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default).responseJSON  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    
                    if dicResponse["status"] as? String == "fail" {
                        DispatchQueue.main.async(execute: {
                            Utils.stopActivityIndicatorinView(self.view)
                            Utils.showAlertWithTitleInController(APP_NAME, message: dicResponse["message"] as? String ?? "Already registered".localized(), controller: self)
                            
                        })
                        return
                    }
                    
                    Utils.stopActivityIndicatorinView(self.view)
                    self.fees_withGST = self.int_fees
                    self.str_orderr_ID = dicResponse["order_id"] as? String ?? ""
                    if let dic_order_data = dicResponse["order_data"] as? [String: Any] {
                        self.fees_withGST = dic_order_data["amount"] as? Int ?? 0
                    }
                    self.showPaymentForm(course_fee: self.fees_withGST)
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
        
    }

    
    func callAPIforUpdatePayment(paymentID: String, signature: String) {
        
        if Utils.isConnectedToNetwork() {
            //Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.updateNadiGuruPayment.rawValue

            let params = ["payment_id":  paymentID,
                          "order_id":  self.str_orderr_ID,
                          "signature": signature]

            print(params)
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default).responseJSON  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    
                    if dicResponse["status"] as? String == "fail" {
                        DispatchQueue.main.async(execute: {
                            Utils.stopActivityIndicatorinView(self.view)
                            Utils.showAlertWithTitleInController(APP_NAME, message: dicResponse["message"] as? String ?? "Payment error".localized(), controller: self)
                            
                        })
                        return
                    }

                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
        
    }
    
}


//MARK:- RazorPay
extension NadiGuruFillDetailsVC {
    
    internal func showPaymentForm(course_fee: Int) {
        
        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            return
        }
        let ayutythmUserName = empData["name"] as? String ?? ""
        let ayutythmUserPhone = empData["mobile"] as? String ?? ""
        let ayutythmUserEmail = empData["email"] as? String ?? ""
        
        //--
        self.razorpayObj = RazorpayCheckout.initWithKey(kRazorpayKey_Subscription, andDelegateWithData: self)
        let options: [String:Any] = ["timeout":900,
                                     "currency": "INR",
                                     "description": "NADI GURU Registation",
                                     "name": "NADI GURU Registation",
                                     //"order_id": self.str_orderr_ID,
                                     "razorpay_order_id": self.str_orderr_ID,
                                     "amount": course_fee,
                                     "image": UIImage.init(named: "Splashlogo")!,
                                     "prefill": ["contact": ayutythmUserPhone,
                                                 "email": ayutythmUserEmail],
                                     "theme": ["color": "#F37254"]]

        if let rzp = self.razorpayObj {
            rzp.open(options)
        } else {
            print("Unable to initialize")
        }
    }
}


extension NadiGuruFillDetailsVC: RazorpayPaymentCompletionProtocol {
    
    func onPaymentError(_ code: Int32, description str: String) {
        print("error1111: ", code, str)
        Utils.showAlertWithTitleInController(APP_NAME, message: str, controller: self)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        print("success: ", payment_id)
    }
}

extension NadiGuruFillDetailsVC: RazorpayPaymentCompletionProtocolWithData {
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        print("error: ", code)
        //self.presentAlert(withTitle: "Alert", message: str)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            Utils.showAlertWithTitleInController(APP_NAME, message: str, controller: self)
        }
    }
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        print("success1223: ", payment_id)
        let signature = response?["razorpay_signature"] as? String ?? ""

        self.callAPIforUpdatePayment(paymentID: payment_id, signature: signature)

        let objDialouge = MPPaymentSuccessFailedVC(nibName: "MPPaymentSuccessFailedVC", bundle: nil)
        objDialouge.delegate = self
        objDialouge.modalPresentationStyle = .overCurrentContext
        objDialouge.price = "\(self.fees_withGST)"
        objDialouge.is_screenfrrom = "NadiGuru"
        objDialouge.screenfrom = .MP_PaymentSuccess
        self.present(objDialouge, animated: false, completion: nil)
    }
    
    func did_selectPaymentOption(_ seccess: Bool, is_payment_success: Bool) {
        if seccess {
            if is_payment_success {
                if let stackVCs = self.navigationController?.viewControllers {
                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == MyHomeViewController.self }) {
                        self.navigationController?.popToViewController(activeSubVC, animated: false)
                    }
                }
            }
        }
    }
}
