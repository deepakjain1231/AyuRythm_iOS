//
//  ARReferralCodeView.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 20/07/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class ARReferralCodeView: UIView {
    @IBOutlet weak var txtReferralCode: UITextField!
    @IBOutlet weak var redeemBtn: UIButton!
    var referralCode: String?
    weak var presentingVC: UIViewController?
    
    @IBAction func redeemBtnPressed(sender: UIButton) {
        presentingVC?.view.endEditing(true)
        guard let referralCode = txtReferralCode.text, !referralCode.isEmpty else {
            updateReferralTF(isValidReferralCode: false)
            showErrorMessage()
            return
        }
        
        print("Referral Code : ", referralCode)
        validateReferralCodeFromServer(code: referralCode)
    }
    
    func updateRedeemButton(isEnable: Bool) {
        redeemBtn.backgroundColor = isEnable ? kAppGreenD2Color : kAppMidGreyColor
        redeemBtn.isUserInteractionEnabled = isEnable
    }
    
    func updateUIForReferralCode(code: String?) {
        referralCode = code
        txtReferralCode.text = code
        if let code = code {
            print("Referral Code : ", code)
            validateReferralCodeFromServer(code: code)
        } else {
            textFieldDidEndEditing(txtReferralCode)
        }
    }
    
    private func updateReferralTF(isValidReferralCode: Bool) {
        if isValidReferralCode {
            txtReferralCode.rightView = UIImageView(image: #imageLiteral(resourceName: "referral-code-success"))
            referralCode = txtReferralCode.text
            updateRedeemButton(isEnable: false)
        } else {
            txtReferralCode.rightView = UIImageView(image: #imageLiteral(resourceName: "referral-code-fail"))
            updateRedeemButton(isEnable: true)
            referralCode = nil
            
        }
        txtReferralCode.rightViewMode = .always
    }
    
    private func showErrorMessage(title: String? = nil, message: String? = nil) {
        if let title = title, let message = message {
            presentingVC?.showAlert(title: title, message: message)
        } else {
            presentingVC?.showAlert(title: "Invalid Referral Code", message: "Please check the code you entered and try again")
        }
    }
    
    private func validateReferralCodeFromServer(code: String) {
        if Utils.isConnectedToNetwork() {
            presentingVC?.showActivityIndicator()
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
        } else {
            presentingVC?.showAlert(message: NO_NETWORK)
        }
    }
}

extension ARReferralCodeView {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtReferralCode {
            txtReferralCode.rightViewMode = .never
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtReferralCode {
            if let referralCode = referralCode, referralCode == textField.text {
                txtReferralCode.rightViewMode = .always
                updateRedeemButton(isEnable: false)
            } else {
                referralCode = nil
                txtReferralCode.rightViewMode = .never
                updateRedeemButton(isEnable: true)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
        case txtReferralCode:
            if prospectiveText.count > 5 {
                redeemBtn.backgroundColor = kAppGreenD2Color
            }
            else {
                redeemBtn.backgroundColor = kAppMidGreyColor
            }
            
            return true
        default:
            return true
        }
    }
}
