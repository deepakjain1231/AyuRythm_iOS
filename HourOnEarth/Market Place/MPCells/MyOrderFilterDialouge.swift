//
//  MyOrderFilterDialouge.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 20/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

protocol filter_delegate {
    func didTappedOnFilterSelectionType(_ success: Bool, type: String)
}

class MyOrderFilterDialouge: UIViewController {

    var filter_Type = ""
    var delegate: filter_delegate?
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    @IBOutlet weak var img_Type1: UIImageView!
    @IBOutlet weak var img_Type2: UIImageView!
    @IBOutlet weak var img_Type3: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupValue()
        self.view_Main.layer.cornerRadius = 12

        self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func setupValue() {
        self.img_Type1.setImageColor(color: kAppBlueColor)
        if self.filter_Type == "All" {
            self.img_Type1.image = MP_appImage.img_RadioBox_selected
            self.img_Type2.image = MP_appImage.img_RadioBox_unselected
            self.img_Type3.image = MP_appImage.img_RadioBox_unselected
        }
        else if self.filter_Type == "Open" {
            self.img_Type1.image = MP_appImage.img_RadioBox_unselected
            self.img_Type2.image = MP_appImage.img_RadioBox_selected
            self.img_Type3.image = MP_appImage.img_RadioBox_unselected
        }
        else {
            self.img_Type1.image = MP_appImage.img_RadioBox_unselected
            self.img_Type2.image = MP_appImage.img_RadioBox_unselected
            self.img_Type3.image = MP_appImage.img_RadioBox_selected
        }
        self.img_Type1.setImageColor(color: kAppBlueColor)
        self.img_Type2.setImageColor(color: kAppBlueColor)
        self.img_Type3.setImageColor(color: kAppBlueColor)
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.view_Main.transform = .identity
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        } completion: { success in
        }
    }
    
    @objc func close_animation(_ Action: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        } completion: { success in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if Action {
                self.delegate?.didTappedOnFilterSelectionType(true, type: self.filter_Type)
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
    
    //MARK: - UIButton Method Action
    @IBAction func btn_Close_Action(_ sender: UIControl) {
        self.close_animation()
    }
    
    @IBAction func btn_FilterOption1_Action(_ sender: UIControl) {
        if self.filter_Type == "All" {
            self.close_animation()
        }
        else {
            self.filter_Type = "All"
            self.setupValue()
            self.close_animation(true)
        }
    }
    
    @IBAction func btn_FilterOption2_Action(_ sender: UIControl) {
        if self.filter_Type == "Open" {
            self.close_animation()
        }
        else {
            self.filter_Type = "Open"
            self.setupValue()
            self.close_animation(true)
        }
    }
    
    @IBAction func btn_FilterOption3_Action(_ sender: UIControl) {
        if self.filter_Type == "Old" {
            self.close_animation()
        }
        else {
            self.filter_Type = "Old"
            self.setupValue()
            self.close_animation(true)
        }
        
    }
    
}

