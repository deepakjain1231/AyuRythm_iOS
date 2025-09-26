//
//
////
////  ViewProfileViewController.swift
////  HourOnEarth
////
////  Created by Pradeep on 6/4/18.
////  Copyright © 2018 Pradeep. All rights reserved.
////
//
//import UIKit
//
//class ViewProfileViewController: UIViewController {
//    @IBOutlet weak var txtName: UITextField!
//    @IBOutlet weak var txtEmail: UITextField!
//    @IBOutlet weak var txtMobile: UITextField!
//    @IBOutlet weak var txtDOB: UITextField!
//    @IBOutlet weak var txtHeight: UITextField!
//    @IBOutlet weak var txtWeight: UITextField!
//    @IBOutlet weak var txtGender: UITextField!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
//            return
//        }
//
//        self.txtName.text = " Name : "  + (empData["name"] as? String ?? "")
//        self.txtEmail.text = " Email : " + (empData["email"] as? String ?? "")
//        self.txtMobile.text = " Mobile : " + (empData["mobile"] as? String ?? "")
//        self.txtDOB.text = " Date Of Birth : " + (empData["dob"] as? String ?? "")
//        self.txtGender.text = " Gender : " + (empData["gender"] as? String ?? "")
//
//        guard let measurement = empData["measurements"] as? String else {
//            return
//        }
//        self.txtHeight.text = ""
//        self.txtWeight.text = ""
//        let arrMeasurement = Utils.parseValidValue(string: measurement).components(separatedBy: ",")
//        if arrMeasurement.count >= 2 {
//            self.txtHeight.text = arrMeasurement[0].replacingOccurrences(of: "\"", with: "")
//            self.txtWeight.text = arrMeasurement[1].replacingOccurrences(of: "\"", with: "")
//        }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    //MARK: - Naigationbar button click action
//    @IBAction func backClicked(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//    }
//
//}
