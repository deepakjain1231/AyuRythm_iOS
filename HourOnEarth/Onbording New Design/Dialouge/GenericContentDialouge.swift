//
//  GenericContentDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 04/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

protocol delegateCompleteNow {
    func clickonGenericContent(_ success: Bool, clickComplteNow: Bool, clickLater: Bool)
}

import UIKit

class GenericContentDialouge: UIViewController {

    var delegate: delegateCompleteNow?
    var screenFrom = ScreenType.k_none
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var img_header: UIImageView!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var lbl_btn_title1: UILabel!
    @IBOutlet weak var lbl_btn_title2: UILabel!
    
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
        if self.screenFrom == .for_Reminder {
            self.lbl_title.text = "Set health goals"
            self.img_header.image = UIImage.init(named: "icon_healthGoal")
            self.lbl_subtitle.text = "Set your health goals to get more\npersonalized and selected results"
            self.lbl_btn_title1.text = "Maybe later"
            self.lbl_btn_title2.text = "Set preferences"
        }
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
    
    func clkToClose(_ isAction: Bool = false, clickCompleteNow: Bool = false, clickLater: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewHeader_Bottom.constant = -screenHeight
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if isAction {
                self.delegate?.clickonGenericContent(isAction, clickComplteNow: clickCompleteNow, clickLater: clickLater)
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
    
    @IBAction func btn_Close_Action(_ sender: UIButton) {
        self.clkToClose()
    }
    
    @IBAction func btn_MayBeLater_Action(_ sender: UIButton) {
        self.clkToClose(true, clickCompleteNow: false, clickLater: true)
    }
    
    @IBAction func btn_Complete_Now_Action(_ sender: UIButton) {
        self.clkToClose(true, clickCompleteNow: true, clickLater: false)
    }

}
