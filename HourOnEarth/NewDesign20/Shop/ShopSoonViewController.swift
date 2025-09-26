//
//  ShopSoonViewController.swift
//  HourOnEarth
//
//  Created by hardik mulani on 13/02/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit

class ShopSoonViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @available(iOS 10.0, *)
    @IBAction func shopClicked(_ sender: UIButton) {
        let urlString = "https://youtu.be/aVYt5hIfVJE"
        guard let url = URL(string: urlString) else {
            return
        }
        UIApplication.shared.open(url, options: [:]) { (_) in
            
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

}
