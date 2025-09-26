//
//  SurveyStep1ViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 17/09/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class SurveyStep1ViewController: UIViewController {
    
    @IBOutlet weak var titleL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] else {
            return
        }
        let username = empData["name"] as? String ?? "Unknown".localized()
        titleL.text = String(format: "Hi %@!".localized(), username)
    }
}

extension SurveyStep1ViewController: DataValidateable {
    func validateData() -> (Bool, String) {
        return (true, "")
    }
}
