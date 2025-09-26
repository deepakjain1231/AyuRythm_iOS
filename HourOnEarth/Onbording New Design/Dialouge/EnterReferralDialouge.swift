//
//  EnterReferralDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 21/07/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

protocol didTappedReferral {
    func didTappedClose_referralSelected(_ success: Bool, referralCode: String)
}

import UIKit
import Alamofire

class EnterReferralDialouge: UIViewController {
    
    var presentingVC: UIViewController?
    var delegate: didTappedReferral?
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var txt_Referral: UITextField!
    @IBOutlet weak var btn_Skip: UIButton!
    @IBOutlet weak var btn_Continue: UIControl!
    @IBOutlet weak var lbl_btn_Continue: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setup()
        self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func setup() {
        self.lbl_btn_Continue.text = "Confirm".localized()
        self.lbl_title.text = "enter_referral_code".localized()
        self.btn_Skip.setTitle("SKIP".localized().capitalized, for: .normal)
        self.txt_Referral.placeholder = "Enter code here".localized()
        self.lbl_subtitle.text = "referral_code_msg".localized()
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Main.transform = .identity
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose(_ action: Bool, code: String) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if action {
                self.delegate?.didTappedClose_referralSelected(action, referralCode: code)
            }
        }
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func btn_Close_Action(_ sender: UIButton) {
        self.clkToClose(false, code: "")
    }
    
    @IBAction func btn_Continue_Action(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let referralCode = self.txt_Referral.text, !referralCode.isEmpty else {
            showErrorMessage()
            return
        }
        
        print("Referral Code : ", referralCode)
        validateReferralCodeFromServer(code: referralCode)
    }
    
    func updateReferralTF(isValidReferralCode: Bool) {
        if isValidReferralCode {
            self.txt_Referral.rightView = UIImageView(image: #imageLiteral(resourceName: "referral-code-success"))
            self.clkToClose(true, code: txt_Referral.text ?? "")
        }
    }
    
    func showErrorMessage(title: String? = nil, message: String? = nil) {
        if let title = title, let message = message {
            presentingVC?.showAlert(title: title, message: message)
        } else {
            presentingVC?.showAlert(title: "Invalid Referral Code", message: "Please check the code you entered and try again")
        }
    }
    
    func validateReferralCodeFromServer(code: String) {
        guard let presentingVC = presentingVC else { return }
        
        if !Utils.isConnectedToNetwork() {
            return presentingVC.hideActivityIndicator(withMessage: NO_NETWORK)
        }
        
        presentingVC.showActivityIndicator()

        let urlString = kBaseNewURL + endPoint.v2.referralcodeValidation.rawValue
        let params = ["referral_code": code]

        AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default).responseJSON  { [weak self] response in
            switch response.result {
            case .success(let value):
                print(response)
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    return
                }

                if dicResponse["status"] as? String == "failed" {
                    self?.presentingVC?.hideActivityIndicator()
                        self?.updateReferralTF(isValidReferralCode: false)
                    self?.showErrorMessage(title: dicResponse["title"] as? String, message: dicResponse["message"] as? String)
                    return
                }

                self?.updateReferralTF(isValidReferralCode: true)
            case .failure(let error):
                print(error)
                self?.presentingVC?.showAlert(error: error)
            }
            self?.presentingVC?.hideActivityIndicator()
        }
    }
    
}

// MARK: - UITextField Delegate Method
extension EnterReferralDialouge: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txt_Referral {
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= 8
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
}


