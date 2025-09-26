//
//  LetsStartViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 5/29/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit

class LetsStartViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let objInstructions = storyBoard.instantiateViewController(withIdentifier: "MeasurementsViewController") as! MeasurementsViewController
        objInstructions.isFromTryAsGuest = true
        self.navigationController?.pushViewController(objInstructions, animated: true)
    }
    
    @IBAction func loginButtonClick(_ sender: UIButton) {
        let objLoginView: LoginViewController = Story_LoginSignup.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(objLoginView, animated: true)

    }
    
}
