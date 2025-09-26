//
//  EditReminderDialouge.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 15/12/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class EditReminderDialouge: UIViewController {

    
    @IBOutlet weak var view_Bg: UIView!
    @IBOutlet weak var btn_close: UIButton!
    @IBOutlet weak var btn_bg_close: UIButton!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var constrainit_view_Main_Height: NSLayoutConstraint!
    
    var screenFrom = ScreenType.k_none
    var superVC = UIViewController()
    var arr_SelectedSlot = [String]()
    var arr_TimeSlot = [WeeklyPlanner_TimeSlot]()
    var arr_ProductList = [WeeklyPlanner_ProductModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Register Table Cell
        self.tblView.register(nibWithCellClass: TimeSlotTableCell.self)
        self.tblView.register(nibWithCellClass: ProductReminderTableCell.self)
        
        self.setupDetail()
        self.setRoundedCorner()
        self.constrainit_view_Main_Height.constant = 0
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            var extr_Height: CGFloat = 75
            var get_TotalHeight: CGFloat = 0
            let bottomSafrArea = kSharedAppDelegate.window?.safeAreaInsets.bottom ?? 0
            if self.screenFrom == .MP_EditReminder {
                if (self.arr_TimeSlot.first?.data.count ?? 0) <= 2 {
                    extr_Height = 150
                }
                get_TotalHeight = CGFloat(((self.arr_TimeSlot.first?.data.count ?? 0) * 72)) + bottomSafrArea + extr_Height
            }
            else {
                if (self.arr_ProductList.first?.data.count ?? 0) <= 2 {
                    extr_Height = 150
                }
                get_TotalHeight = CGFloat(((self.arr_ProductList.first?.data.count ?? 0) * 51)) + bottomSafrArea + extr_Height
            }
            self.constrainit_view_Main_Height.constant = get_TotalHeight
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.view.layoutIfNeeded()
            self.setRoundedCorner()
        }) { (success) in
            self.lbl_title.text = "Edit reminder"
        }
    }
    
    func setRoundedCorner() {
        self.view_Bg.roundCorners(corners: [UIRectCorner.topLeft, UIRectCorner.topRight], radius: 30)
        self.view.layoutIfNeeded()
    }
    
    
    func setupDetail() {
        if self.screenFrom == .MP_EditReminder {
            if let arr_detail = self.arr_TimeSlot.first?.data {
                for dic in arr_detail {
                    if dic.is_reminder_set {
                        self.arr_SelectedSlot.append(dic.title)
                    }
                }
            }
        }
    }
    
    func clkToClose() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constrainit_view_Main_Height.constant = 0
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
    
    // MARK: - UIButton Action
    @IBAction func btn_Close_Action(_ sender: UIButton) {
        self.clkToClose()
    }

}


//MARK: - UITableView Delegate DataSource Method
extension EditReminderDialouge: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.screenFrom == .MP_EditReminder {
            return self.arr_TimeSlot.first?.data.count ?? 0
        }
        return self.arr_ProductList.first?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.screenFrom == .MP_EditReminder {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSlotTableCell", for: indexPath) as! TimeSlotTableCell
            cell.selectionStyle = .none
            
            var strTitlee = ""
            if let dic_detail = self.arr_TimeSlot.first?.data[indexPath.row] as? WeeklyPlannerTimeSlotData {
                strTitlee = dic_detail.title
                cell.lbl_Title.text = dic_detail.title
                cell.lbl_subTitle.text = "(\(dic_detail.duration))"
                cell.btn_Switch.isOn = dic_detail.is_reminder_set
            }
            
            //Tapped Switch button
            cell.didTappedonSwitch = { (sender) in
                if sender.isOn {
                    if !self.arr_SelectedSlot.contains(strTitlee) {
                        self.arr_SelectedSlot.append(strTitlee)
                    }
                }
                else {
                    if let indx = self.arr_SelectedSlot.firstIndex(of: strTitlee) {
                        self.arr_SelectedSlot.remove(at: indx)
                    }
                }
                self.callAPIfor_SetUserReminder(str_shift: self.arr_SelectedSlot.joined(separator: ","))
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductReminderTableCell", for: indexPath) as! ProductReminderTableCell
        cell.selectionStyle = .none
        
        var str_rowID = ""
        if let dic_detail = self.arr_ProductList.first?.data[indexPath.row] as? WeeklyPlannerProductData {
            str_rowID = "\(dic_detail.row_id)"
            cell.lbl_Title.text = dic_detail.product_name
            cell.btn_Switch.isOn = dic_detail.reminder
        }
        
        //Tapped Switch button
        cell.didTappedonSwitch = { (sender) in
            let strOnOff = sender.isOn ? "On" : "Off"
            self.callAPIfor_SetProductReminder(on_offSatus: strOnOff, str_rowID: str_rowID)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MP_ProductReminderVC.instantiate(fromAppStoryboard: .WeeklyPlaner)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: - API Call
extension EditReminderDialouge {
    
    func callAPIfor_SetProductReminder(on_offSatus: String, str_rowID: String) {
        
        let nameAPI: endPoint = .mp_setProductReminder
        let getHeader = MPLoginLocalDB.getHeaderToken()
        
        let param = ["row_id": str_rowID, "reminder_status": on_offSatus]
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                (self.superVC as? MP_Product_CategoryVC)?.callAPIfor_GETProductList()
            }else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIfor_SetUserReminder(str_shift: String) {
        
        let nameAPI: endPoint = .mp_setuserReminder
        let getHeader = MPLoginLocalDB.getHeaderToken()
        
        let param = ["shift": str_shift]
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                (self.superVC as? MP_ProductReminderVC)?.callAPIfor_GETTimeSlot()
            }else {
                self.showAlert(title: status, message: message)
            }
        }
    }
}
