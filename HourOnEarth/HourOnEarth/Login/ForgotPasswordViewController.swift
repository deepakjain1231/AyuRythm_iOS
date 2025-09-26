//
//  ForgotPasswordViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 8/30/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
import SKCountryPicker

class ForgotPasswordViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var constraintBottomScrollView: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var viewcountryPicker: UIView!
    @IBOutlet weak var countrypicker: CountryPickerView!
    @IBOutlet weak var countryButton: UIButton!

    var countryCodes = "+91"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.countryPickerCallback()
        self.viewcountryPicker.isHidden = true

        
      //  NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
       // NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
       // self.hideKeyboardWhenTappedAround()
        txtPhoneNumber.delegate = self
        txtPhoneNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        // Do any additional setup after loading the view.
    }
    
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView?.addGestureRecognizer(tap)
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // here check you text field's input Type
        if #available(iOS 12.0, *) {
            if let phone = textField.text {
                self.txtPhoneNumber.text = phone.replacingOccurrences(of: self.countryCodes, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
//        scrollView?.contentOffset = CGPoint(x:0, y:keyboardFrame.size.height-150)
        self.constraintBottomScrollView.constant = -keyboardFrame.size.height
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        scrollView?.contentOffset = .zero
        self.constraintBottomScrollView.constant = 0.0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.scrollView?.scrollRectToVisible(CGRect(x: textField.frame.origin.x, y: textField.frame.origin.y, width: textField.frame.size.width, height: textField.frame.size.height + 50), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func backClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextClicked(_ sender: UIButton) {
        if (txtPhoneNumber.text?.isEmpty)! {
            Utils.showAlertWithTitleInController("", message: "Please enter mobile number", controller: self)
        } else {
            let objView:OTPViewController = Story_Main.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
            objView.phoneNumber = self.txtPhoneNumber.text ?? ""
            objView.countryCode = self.countryCodes
            self.navigationController?.pushViewController(objView, animated: true)
        }
    }
    
    @IBAction func countryPickerButtonClicked(_ sender: UIButton) {
          self.viewcountryPicker.isHidden = false
          self.view.endEditing(true)
      }
      
      func countryPickerCallback()
      {
          countrypicker.onSelectCountry { [weak self] (country) in
              guard let self = self,
                  let digitCountrycode = country.digitCountrycode else {
                  return
              }
              self.countryCodes = "+\(digitCountrycode)"
              self.countryButton.setTitle("+\(digitCountrycode)", for: .normal)
          }
      }
      
      @IBAction func pickerCountryDoneClicked(_ sender: UIBarButtonItem) {
          self.viewcountryPicker.isHidden = true
      }
}

//
//extension ForgotPasswordViewController {
//    func forgotPasswordFromServer() {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.UserOtp.rawValue
//
//            let params = ["user_number": txtPhoneNumber?.text ?? "","user_select": "generate"]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON { response in
//
//                switch response.result {
//
//                case .success:
//                    print(response)
//                    let objView:OTPViewController = Story_Main.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
//                    objView.phoneNumber = self.txtPhoneNumber.text ?? ""
//                    self.navigationController?.pushViewController(objView, animated: true)
//
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                DispatchQueue.main.async(execute: {
//                    Utils.stopActivityIndicatorinView(self.view)
//                })
//            }
//        }else {
//            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
//        }
//    }
//}
