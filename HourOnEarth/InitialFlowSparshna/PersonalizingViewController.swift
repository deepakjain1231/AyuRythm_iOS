//
//  PersonalizingViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 1/15/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//

import UIKit

class PersonalizingViewController: BaseViewController {

    @IBOutlet weak var viewVikriti: RoundView!
    @IBOutlet weak var btnRegister: RoundedButton!
    @IBOutlet weak var viewPrakriti: RoundView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnRegister.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeView()
    }
    
    func initializeView() {
        if let strPrashna = kUserDefaults.value(forKey: RESULT_VIKRITI) as? String {
            //VIKRITI IS ANSWERED BY USER
            viewVikriti.addShadow(offset: CGSize.init(width: 0, height: 2), color: UIColor.black, radius: 2.0, opacity: 0.25)
            viewPrakriti.addShadow(offset: CGSize.init(width: 0, height: 2), color: UIColor.black, radius: 2.0, opacity: 0.25)
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                let kapha = Double(arrPrashnaScore[0]) ?? 0
                let pitta = Double(arrPrashnaScore[1]) ?? 0
                let vata = Double(arrPrashnaScore[2]) ?? 0
            }
        } else {
            return
        }
        
        if let strPrashna = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String {
            //VIKRITI IS ANSWERED BY USER
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                self.btnRegister.isHidden = false
            }
        } else {
//            btnPrakriti.isUserInteractionEnabled = true
//            viewPrakriti.backgroundColor = kAppColorGreen
//            stackViewPrakriti.isHidden = true
//            topConstraintPrakriti.constant = 10
        }
    }
    
    @IBAction func registerClicked(_ sender: Any) {
        kSharedAppDelegate.showSignUpScreen()
    }
    
    
    @IBAction func vikritiClicked(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "InitialFlow", bundle: nil)
        
      let objDescription = storyBoard.instantiateViewController(withIdentifier: "KPVDescriptionViewController") as! KPVDescriptionViewController
        self.navigationController?.pushViewController(objDescription, animated: true)
     
    }
    
    @IBAction func prakritiClicked(_ sender: Any) {
        startPrakritiTestFlow()
    }

}
