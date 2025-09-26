//
//  ResetPasswordViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 8/30/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class ResetPasswordViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var constraintBottomScrollView: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!

    var phoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
       // NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
       // self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
   
    @IBAction func passwordButtonClicked(sender: UIButton) {
        
        if (self.txtPassword?.isSecureTextEntry == true)
        {
            self.txtPassword?.isSecureTextEntry = false;
            sender.setImage(UIImage(named: "imageShow"), for: .normal)

        }
        else
        {
            self.txtPassword?.isSecureTextEntry = true;
            sender.setImage(UIImage(named: "imageHide"), for: .normal)

        }
    }
    
    @IBAction func confirmpasswordButtonClicked(sender: UIButton) {
       
        if (self.txtNewPassword?.isSecureTextEntry == true)
             {
                 self.txtNewPassword?.isSecureTextEntry = false;
                sender.setImage(UIImage(named: "imageShow"), for: .normal)

             }
             else
             {
                 self.txtNewPassword?.isSecureTextEntry = true;
                sender.setImage(UIImage(named: "imageHide"), for: .normal)

             }
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView?.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        scrollView?.contentOffset = CGPoint(x:0, y:keyboardFrame.size.height)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextClicked(_ sender: UIButton) {
        if self.txtPassword.text != self.txtNewPassword.text {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter same password", controller: self)
        } else {
            resetPasswordFromServer()
        }
    }
}


extension ResetPasswordViewController {
    func resetPasswordFromServer() {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.changePassword.rawValue
            let params = ["user_number": phoneNumber,"confirmpassword": txtPassword.text ?? "", "password": txtPassword.text ?? ""]
          

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                    
                case .success:
                    print(response)
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: "Password changed successfully", okTitle: "Ok".localized(), controller: self, completionHandler: {
                        for controller in self.navigationController?.viewControllers ?? [] {
                            if controller is LoginViewController {
                                self.navigationController?.popToViewController(controller, animated: true)
                                break
                            }
                        }
                    })
                    
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
