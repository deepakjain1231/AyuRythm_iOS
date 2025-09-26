//
//  ContactUsViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 3/15/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class ContactUsViewController: BaseViewController,UITextViewDelegate {
    
    @IBOutlet weak var txtSubject: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var scrollBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    var placeholderLabel : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Contact Us".localized()
        txtDescription.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Message".localized()
        placeholderLabel.font = UIFont.boldSystemFont(ofSize: 17)
        placeholderLabel.sizeToFit()
        txtDescription.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 15, y: (txtDescription.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.3)
        placeholderLabel.isHidden = !txtDescription.text.isEmpty
        self.navigationController?.isNavigationBarHidden = false
        
       // NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
      //  NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
       // self.roundedTextView()
      //  self.hideKeyboardWhenTappedAround()
    }
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ContactUsViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func roundedTextView() {
        txtDescription.layer.borderColor = UIColor.lightGray.cgColor
        txtDescription.layer.borderWidth = 1.0
        txtDescription.layer.cornerRadius = 5.0
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        self.scrollBottomConstraint.constant = keyboardFrame.size.height - 50
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        self.scrollBottomConstraint.constant = 0.0
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        if txtSubject?.text?.isEmpty ?? true {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter subject.".localized(), controller: self)
        } else if txtDescription?.text?.isEmpty ?? true {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter description.".localized(), controller: self)
        } else {
            updateContactUsOnServer()
        }
    }
    
    func updateContactUsOnServer() {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.contactus.rawValue
            guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please register first to contact us.".localized(), controller: self)
                return
            }
            let name = empData["name"] as? String ?? ""
            let email = empData["email"] as? String ?? ""
            
            let params = ["name": name, "email": email, "subject": self.txtSubject.text ?? "", "message": self.txtDescription.text ?? ""]
//            let getHeaders : HTTPHeaders = [
//
//                "Authorization": userDefault.getHeaders()
//            ]

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success:
                    Utils.showAlertWithTitleInController(APP_NAME, message: "Thank you for contacting us.".localized(), controller: self)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
            }
        } else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
}
