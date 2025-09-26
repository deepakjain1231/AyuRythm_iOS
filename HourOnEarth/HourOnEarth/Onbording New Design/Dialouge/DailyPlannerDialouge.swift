//
//  DailyPlannerDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 31/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit

class DailyPlannerDialouge: UIViewController {

    var dic_Value = [String: Any]()
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var lbl_description: UILabel!
    
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var constraint_viewHeader_Bottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setup()
        self.constraint_viewHeader_Bottom.constant = -screenHeight
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func setup() {
        self.lbl_title.text = self.dic_Value["daily_plans_title"] as? String ?? ""

        let str_imgIcon = self.dic_Value["details_image"] as? String ?? ""
        self.img_icon.sd_setImage(with: URL(string: str_imgIcon), placeholderImage: nil)
        self.lbl_description.text = self.dic_Value["details"] as? String ?? ""
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewHeader_Bottom.constant = 0
            self.view_Main.roundCorners(corners: [.topLeft, .topRight], radius: 22)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewHeader_Bottom.constant = -screenHeight
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
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
    
    @IBAction func btn_Close_Action(_ sender: UIButton) {
        self.clkToClose()
    }

}
