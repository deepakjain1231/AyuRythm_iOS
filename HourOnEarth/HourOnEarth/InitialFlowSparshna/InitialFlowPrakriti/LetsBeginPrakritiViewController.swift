////
////  LetsBeginPrakritiViewController.swift
////  HourOnEarth
////
////  Created by Pradeep on 1/15/19.
////  Copyright © 2019 Pradeep. All rights reserved.
////
//
//import UIKit
//
//class LetsBeginPrakritiViewController: UIViewController {
//
//    @IBOutlet weak var btnContinue: UIButton!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        btnContinue.layer.borderColor = UIColor.white.cgColor
//        btnContinue.layer.borderWidth = 1.0
//
//        // Do any additional setup after loading the view.
//    }
//
//    @IBAction func letsBeginClicked(_ sender: Any) {
//        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
//        let objSlideView:PrakritiQuestionsViewController = storyBoard.instantiateViewController(withIdentifier: "PrakritiQuestionsViewController") as! PrakritiQuestionsViewController
//        objSlideView.isTryAsGuest = true
//        self.navigationController?.pushViewController(objSlideView, animated: true)
//    }
//}
