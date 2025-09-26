//
//  PatientID_DialogVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 17/03/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire


protocol delegate_patienID {
    func addPatientID_subscription(_ success: Bool, patientID: String)
}

class PatientID_DialogVC: BaseViewController {
    
    var super_viewVC = UIViewController()
    var delegate: delegate_patienID?
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var txt_PatientID: UITextField!
    @IBOutlet weak var btn_Text: UILabel!
    @IBOutlet weak var btn_Submit: UIControl!
    @IBOutlet weak var constraint_viewMain_Bottom: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        self.view_Main.roundCorners(corners: [UIRectCorner.topLeft, .topRight], radius: 12)
        self.constraint_viewMain_Bottom.constant = -UIScreen.main.bounds.height
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.2)
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewMain_Bottom.constant = 0
            self.view_Main.roundCorners(corners: [UIRectCorner.topLeft, .topRight], radius: 22)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.view_Main.roundCorners(corners: [UIRectCorner.topLeft, .topRight], radius: 22)
        }
    }
    
    
    func clkToClose(_ is_Action: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewMain_Bottom.constant = -UIScreen.main.bounds.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if is_Action {
                self.delegate?.addPatientID_subscription(true, patientID: self.txt_PatientID.text ?? "")
            }
            else {
                self.delegate?.addPatientID_subscription(false, patientID: "")
            }
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        UIView.animate(withDuration: 0.3) {
            self.constraint_viewMain_Bottom.constant = keyboardFrame.size.height - 25
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.constraint_viewMain_Bottom.constant = 0
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
    
    // MARK: - UIButton Action
    @IBAction func btn_Close_Action(_ sender: UIButton) {
        self.view.endEditing(true)
        self.clkToClose(false)
    }
    
    
    @IBAction func btn_Submit_Action(_ sender: UIControl) {
        self.view.endEditing(true)
        
        if let strPatientID = self.txt_PatientID.text {
            if strPatientID == "" {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter sanaay patient id.", controller: self.super_viewVC)
            }
            else {
                self.callAPIforPatientValidation(patient_id: strPatientID)
            }
        }
        
    }

    
    //MARK: - API CALL
    
    func callAPIforPatientValidation(patient_id: String) {

        if Utils.isConnectedToNetwork() {
//438373
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.patient_validation.rawValue
            let params = ["patient_id": patient_id, "language_id": Utils.getLanguageId()] as [String : Any]

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    let status = dicResponse["status"] as? String
                    if status?.lowercased() == "success" {

                        UserDefaults.standard.set(patient_id, forKey: kSanaayPatientID)
                        UserDefaults.standard.synchronize()
                        
                        self.clkToClose(true)
                        
                    } else {
                        Utils.showAlertWithTitleInController(status ?? APP_NAME, message: (dicResponse["message"] as? String ?? "Patient Id Not Match".localized()), controller: self)
                    }
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self.super_viewVC)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self.super_viewVC)
        }
    }
}


