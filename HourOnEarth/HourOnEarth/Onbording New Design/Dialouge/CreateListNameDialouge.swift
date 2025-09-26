//
//  CreateListNameDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 18/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

protocol delegate_CreateList {
    func create_listname(_ success: Bool, listname: String)
}

import UIKit

class CreateListNameDialouge: UIViewController, UITextFieldDelegate {

    var is_update = false
    var str_listName = ""
    var delegate: delegate_CreateList?
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var btn_close: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var txt_listName: UITextField!
    @IBOutlet weak var btn_create: UIControl!
    @IBOutlet weak var lbl_create_list: UILabel!
    @IBOutlet weak var constraint_btn_bottom: NSLayoutConstraint!
    @IBOutlet weak var constraint_viewMain_bottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupText()
        self.constraint_viewMain_bottom.constant = -screenHeight
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK:- KEYBOARD METHODS
    @objc func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        let userinfo:NSDictionary = (notification.userInfo as NSDictionary?)!
        if let keybordsize = (userinfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constraint_viewMain_bottom.constant = keybordsize.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        print("keyboardWillHide")
        self.constraint_viewMain_bottom.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewMain_bottom.constant = 0
            self.view_Main.roundCorners(corners: [.topLeft, .topRight], radius: 22)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose(_ isAction: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewMain_bottom.constant = -screenHeight
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if isAction {
                self.delegate?.create_listname(true, listname: self.txt_listName.text ?? "")
            }
        }
    }
    
    func setupText() {
        self.txt_listName.delegate = self
        self.lbl_title.text = "Name your List".localized()
        self.lbl_subtitle.text = "Give your list a memorable name".localized()
        
        if self.is_update {
            self.lbl_create_list.text = "Save".localized()
            self.lbl_title.text = "Rename your List".localized()
            self.txt_listName.placeholder = "New List Name".localized()
        }
        let bottomsafeArea: CGFloat = appDelegate.window?.safeAreaInsets.bottom ?? 0
        if bottomsafeArea != 0 {
            self.constraint_btn_bottom.constant = 30
        }
        else {
            self.constraint_btn_bottom.constant = 20
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
    
    @IBAction func btn_close_Action(_ sender: Any) {
        self.clkToClose()
    }
    
    @IBAction func btn_create_list(_ sender: UIControl) {
        let str_name = self.txt_listName.text ?? ""
        if str_name.trimed() == "" {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter a valid list name".localized(), controller: self)
            return
        }
        self.view.endEditing(true)
        self.clkToClose(true)
    }

}

