//
//  RemoveSubscriptionVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 14/12/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class RemoveSubscriptionVC: UIViewController {

    var str_type = ""
    @IBOutlet weak var btn_remove_finger: UIButton!
    @IBOutlet weak var btn_remove_facenaadi: UIButton!
    @IBOutlet weak var btn_remove_ayumonk: UIButton!
    @IBOutlet weak var btn_remove_remedies: UIButton!
    @IBOutlet weak var btn_remove_diet_plan: UIButton!
    @IBOutlet weak var btn_remove_main_subscription: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
    }

    func callAPIforRemoveSubscription(typeee: String) {
        self.showActivityIndicator()
        let params = ["subscription_type": typeee] as [String : Any]
        
        doAPICall(endPoint: .delete_subscription, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                self?.hideActivityIndicator()
                appDelegate.sparshanAssessmentDone = true
                self?.showAlert(message: "Subscription deleted successfully!")
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(title: status, message: message)
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
    
    // MARK: - UIBUtton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_remove_finger_action(_ sender: UIButton) {
        self.str_type = "finger"
        self.callAPIforRemoveSubscription(typeee: "finger_assessment")
    }
    
    @IBAction func btn_remove_facenaadi_action(_ sender: UIButton) {
        self.str_type = "facenaadi"
        self.callAPIforRemoveSubscription(typeee: "facenaadi")
    }

    @IBAction func btn_remove_ayumonk_action(_ sender: UIButton) {
        self.str_type = "ayumonk"
        self.callAPIforRemoveSubscription(typeee: "ayumonk")
    }
    
    @IBAction func btn_remove_remedies_action(_ sender: UIButton) {
        self.str_type = "home_remedies"
        self.callAPIforRemoveSubscription(typeee: "home_remedies")
    }
    
    @IBAction func btn_remove_diet_plan_action(_ sender: UIButton) {
        self.str_type = "diet_plan"
        self.callAPIforRemoveSubscription(typeee: "diet_plan")
    }
    
    @IBAction func btn_remove_main_subscription_action(_ sender: UIButton) {
        self.callAPIforRemoveSubscription(typeee: "main_subscription")
    }
}
