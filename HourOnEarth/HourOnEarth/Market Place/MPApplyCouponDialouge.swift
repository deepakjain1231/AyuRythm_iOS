//
//  MPApplyCouponDialouge.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 16/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class MPApplyCouponDialouge: UIViewController, UITextFieldDelegate {
    
    var is_bothCoupon = false
    var arr_selectedCoupon = [MPCouponData]()
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var btn_Close: UIButton!
    @IBOutlet weak var lblCoupon: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var txtCoupon: UITextField!
    @IBOutlet weak var btn_ApplyCopon: UIControl!
    
    var couponsList: MPCouponModel?
    var orderTotal = ""
    var totalQty = ""
    var selectedCouponCode = ""
    var completion: ((Int, String, Int, String) -> ())!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.btn_ApplyCopon.isHidden = true
        self.view_Main.layer.cornerRadius = 12
        self.btn_Close.setTitle("", for: .normal)
        self.tblView.register(nibWithCellClass: MPCouponTableCell.self)
        self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
        self.tblView.reloadData()
        txtCoupon.delegate = self
        callAPIfor_couponlist()
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.view_Main.transform = .identity
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.view.layoutIfNeeded()
        } completion: { success in
        }
    }
    
    @objc func close_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        } completion: { success in
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
    
    //MARK: - UIButton Method Action
    @IBAction func btn_Close_Action(_ sender: UIControl) {
        self.close_animation()
    }
    
    @IBAction func btn_apply_Action(_ sender: UIControl) {
        if txtCoupon.text == ""{
            return
        }else{
            self.view.endEditing(true)
            applyCouponCode(couponCode: txtCoupon.text ?? "", couponId: 0)
        }
    }
    
    @IBAction func btn_multiple_copon_apply_Action(_ sender: UIControl) {
        if self.arr_selectedCoupon.count != 0 {
            self.view.endEditing(true)
            
            var ayuseedCoponID = 0
            var ayuseedCoponCode = ""
            var marketplaceCoponID = 0
            var marketplaceCoponCode = ""
            
            for dicCopon in self.arr_selectedCoupon {
                if dicCopon.is_ayuseeds_coupon == 1 {
                    ayuseedCoponID = dicCopon.id
                    ayuseedCoponCode = dicCopon.code
                }
                else {
                    marketplaceCoponID = dicCopon.id
                    marketplaceCoponCode = dicCopon.code
                }
            }
            
            
            self.applyCouponCode(couponCode: marketplaceCoponCode, couponId: marketplaceCoponID, ayuseeds_coupon_code: ayuseedCoponCode, ayuseed_couponId: ayuseedCoponID)
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lblCoupon.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if txtCoupon.text == ""{
            lblCoupon.text = "Enter Coupon/Discount/Promo/Referel Code"
        }else{
            lblCoupon.text = ""
        }
    }
}



//MARK: - UITableView Datasource Delegate Method
extension MPApplyCouponDialouge: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return couponsList?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: MPCouponTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.view_disable.isHidden = true
        let data = couponsList!.data[indexPath.row]
        let is_ayuseeds_coupon = data.is_ayuseeds_coupon
        
        cell.lblTitle.text = data.title
        cell.lblSaveUpto.text = data.description
        cell.lblOffCoupon.text = "\(data.amount_percentage)% OFF"
        
        if data.is_ayuseeds_coupon == 1 {
            cell.lblOffCoupon.text = data.title
        }
        
        if self.is_bothCoupon {
            cell.btn_Apply.isHidden = true
            cell.img_checkmark.isHidden = false
            cell.view_disable.isHidden = true
            
            if self.arr_selectedCoupon.count == 0 {
                cell.view_disable.isHidden = true
            }
            else {
                let arrSelected_0 = self.arr_selectedCoupon.filter({ did_coupon in
                    return did_coupon.is_ayuseeds_coupon == 0
                })
                let arrSelected_1 = self.arr_selectedCoupon.filter({ did_coupon in
                    return did_coupon.is_ayuseeds_coupon == 1
                })

                if is_ayuseeds_coupon == 1 {
                    
                    if arrSelected_1.count == 0 {
                        cell.view_disable.isHidden = true
                    }
                    else {
                        if (self.arr_selectedCoupon.first(where: { dic_copon in
                            return dic_copon.id == data.id
                        }) != nil) {
                            cell.view_disable.isHidden = true
                            cell.img_checkmark.image = UIImage.init(named: "icon_tick_blue")
                        }
                        else {
                            cell.view_disable.isHidden = false
                            cell.img_checkmark.image = UIImage.init(named: "icon_unselected_blue")
                        }
                    }
                }
                else {
                    if arrSelected_0.count == 0 {
                        cell.view_disable.isHidden = true
                    }
                    else {
                        if (self.arr_selectedCoupon.first(where: { dic_copon in
                            return dic_copon.id == data.id
                        }) != nil) {
                            cell.view_disable.isHidden = true
                            cell.img_checkmark.image = UIImage.init(named: "icon_tick_blue")
                        }
                        else {
                            cell.view_disable.isHidden = false
                            cell.img_checkmark.image = UIImage.init(named: "icon_unselected_blue")
                        }
                    }
                }
            }

        }
        else {
            cell.btn_Apply.isHidden = false
            cell.img_checkmark.isHidden = true
            cell.view_disable.isHidden = true
            cell.view_disable.isHidden = true
        }
//        var saveupto = "Save upto"
//        //if data.apply_on_min_amount > 0{
//            saveupto = "\(saveupto) ₹\(data.amount_percentage)"
//        //}
//        
//        if data.apply_on_max_amount > 0{
//            saveupto = "\(saveupto)  on order above ₹\(data.apply_on_max_amount)"
//        }
//        else {
//            saveupto = "\(saveupto)  on order above ₹200"
//        }
//            
//        cell.lblSaveUpto.text = saveupto
        
        let strEndDate = data.end_date
        let dateformatt = DateFormatter()
        dateformatt.dateFormat = "yyyy-MM-dd"
        if let dateee = dateformatt.date(from: strEndDate) {
            let getDateSuffix = self.daySuffix(from: dateee)
            dateformatt.dateFormat = "dd"
            var str_expDate = dateformatt.string(from: dateee)
            str_expDate = str_expDate + getDateSuffix
            dateformatt.dateFormat = "MMM yyyy"
            str_expDate = "\(str_expDate) \(dateformatt.string(from: dateee))"
            cell.lblExpiryOn.text = "Expires on \(str_expDate)"
        }
        else {
            cell.lblExpiryOn.text = "Expires on \(strEndDate)"
        }
        
        cell.lblCouponCode.text = "Code: \(data.code)".uppercased()
        cell.completion = {
            self.view.endEditing(true)
            if data.is_ayuseeds_coupon == 1 {
                self.applyCouponCode(couponCode: "", couponId: 0, ayuseeds_coupon_code: data.code, ayuseed_couponId: data.id)
            }
            else {
                self.applyCouponCode(couponCode: data.code, couponId: data.id)
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180// UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.is_bothCoupon {
            let data = couponsList!.data[indexPath.row]
            let is_ayuseeds_coupon = data.is_ayuseeds_coupon

            if is_ayuseeds_coupon == 1 {

                if let indx = self.arr_selectedCoupon.firstIndex(where: { did_coupon in
                    return did_coupon.is_ayuseeds_coupon == 1
                }) {
                    self.arr_selectedCoupon.remove(at: indx)
                    self.arr_selectedCoupon.append(data)
                }
                else {
                    self.arr_selectedCoupon.append(data)
                }

            }
            else {

                if let indx = self.arr_selectedCoupon.firstIndex(where: { did_coupon in
                    return did_coupon.is_ayuseeds_coupon == 0
                }) {
                    self.arr_selectedCoupon.remove(at: indx)
                    self.arr_selectedCoupon.append(data)
                }
                else {
                    self.arr_selectedCoupon.append(data)
                }
            }

            self.btn_ApplyCopon.isHidden = false
            self.tblView.reloadData()
        }
    }
    
    
    func daySuffix(from date: Date) -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
}


//MARK: - Coupon List
extension MPApplyCouponDialouge{
    
    func callAPIfor_couponlist() {
        
        
        self.showActivityIndicator()
        var nameAPI: endPoint = .mp_front_coupon_getList
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_coupon_getList
            getHeader = MPLoginLocalDB.getHeaderToken()
        }

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .get, headers: getHeader) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            
            if isSuccess {
                self.couponsList = MPCouponModel(JSON: responseJSON?.rawValue as! [String : Any])!
                
                var int_marketplace_coupon_count = 0
                var int_ayuseeds_coupon_count = 0
                if let arr_data = self.couponsList?.data {
                    for dicCouponlist in arr_data {
                        let is_ayuseeds_coupon = dicCouponlist.is_ayuseeds_coupon
                        if is_ayuseeds_coupon == 1 {
                            int_ayuseeds_coupon_count = int_ayuseeds_coupon_count + 1
                        }
                        else {
                            int_marketplace_coupon_count = int_marketplace_coupon_count + 1
                        }
                    }
                    
                    if arr_data.count == int_ayuseeds_coupon_count {
                        self.is_bothCoupon = false
                    }
                    else if arr_data.count == int_marketplace_coupon_count {
                        self.is_bothCoupon = false
                    }
                    else {
                        self.is_bothCoupon = true
                    }
                }

                print("response")
                self.tblView.reloadData()
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func applyCouponCode(couponCode: String, couponId: Int, ayuseeds_coupon_code: String = "", ayuseed_couponId: Int = 0) {
        var int_couponId = couponId
        var nameAPI: endPoint = .mp_front_coupon_applyCoupon
        var getHeader = MPLoginLocalDB.getHeader_GuestUser()
        
        if kSharedAppDelegate.userId != "" {
            nameAPI = .mp_user_coupon_applyCoupon
            getHeader = MPLoginLocalDB.getHeaderToken()
        }

        let params = ["code" : couponCode,
                      "order_total": orderTotal,
                      "order_quantity": totalQty,
                      "ayuseeds_coupon_code": ayuseeds_coupon_code] as [String : Any]

        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: params, headers: getHeader) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                let data = responseJSON?.rawValue as! [String : Any]
                if data["error"] as? Int != 1{
                    self.selectedCouponCode = couponCode
                    if couponId == 0 {
                        if let dic_data = data["data"] as? [String: Any] {
                            int_couponId = dic_data["coupon_id"] as? Int ?? 0
                        }
                    }
                    self.completion(int_couponId, couponCode, ayuseed_couponId, ayuseeds_coupon_code)
                    self.close_animation()
                }
                else {
                    let strMsg = data["message"] as? String ?? ""
                    if strMsg != "" {
                        self.view.endEditing(true)
                        kSharedAppDelegate.window?.rootViewController?.showToast(message: strMsg)
                    }
                }
                print("response")
            }else if status == "Token is Expired"{
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }

}
