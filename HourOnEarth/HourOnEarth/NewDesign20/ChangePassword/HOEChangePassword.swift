//
//  HOEChangePassword.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 20/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class HOEChangePassword: BaseViewController,UITextFieldDelegate
{

    @IBOutlet weak var txtExistingPassword: UITextField!
    
    @IBOutlet weak var txtNewPassword: UITextField!
    
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.txtExistingPassword.delegate = self
        self.txtNewPassword.delegate = self
        self.txtConfirmPassword.delegate = self
        
      //  self.hideKeyboardWhenTappedAround()
        navigationController!.navigationBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        navigationItem.title = "Change Password".localized()

        // Do any additional setup after loading the view.
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view?.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    @IBAction func oldPasswordButton(_ sender: UIButton)
    {
        if (self.txtExistingPassword?.isSecureTextEntry == true)
        {
            self.txtExistingPassword?.isSecureTextEntry = false;
            sender.setImage(UIImage(named: "imageShow"), for: .normal)
        }
        else
        {
            self.txtExistingPassword?.isSecureTextEntry = true;
            sender.setImage(UIImage(named: "imageHide"), for: .normal)
        }
    }
    
    @IBAction func newPasswordButton(_ sender: UIButton)
    {
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
    
    @IBAction func confirmPasswordButton(_ sender: UIButton)
    {
        if (self.txtConfirmPassword?.isSecureTextEntry == true)
        {
            self.txtConfirmPassword?.isSecureTextEntry = false;
            sender.setImage(UIImage(named: "imageShow"), for: .normal)
        }
        else
        {
            self.txtConfirmPassword?.isSecureTextEntry = true;
            sender.setImage(UIImage(named: "imageHide"), for: .normal)
        }

    }
    
    @IBAction func confirmButtonClicked(_ sender: RoundedButton)
    {
        if self.txtNewPassword.text != self.txtConfirmPassword.text {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter same password", controller: self)
        } else {
            changePasswordFromServer()
        }
    }
    
}
extension HOEChangePassword {
    func changePasswordFromServer() {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.changePasswordAfterLogin.rawValue
            let params = ["oldpassword": txtExistingPassword.text ?? "","password": txtNewPassword.text ?? "", "confirmpassword": txtConfirmPassword.text ?? ""]
          

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                    
                case .success:
                    print(response)
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: "Password changed successfully".localized(), okTitle: "Ok".localized(), controller: self, completionHandler: {
                        self.navigationController?.popViewController(animated: true)
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
