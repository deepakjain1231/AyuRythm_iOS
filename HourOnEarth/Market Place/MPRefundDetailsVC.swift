//
//  MPRefundDetailsVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 21/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MPRefundDetailsVC: UIViewController {

    var str_OrderID = ""
    var selectedOption = ""
    var str_ReasonComment = ""
    var is_ReturnProduct = false
    var dic_OrderDetail: MPMyOrderProductDetail?
    @IBOutlet weak var tblView: UITableView!
    var arr_Options = ["To original source of payment mode (UPI/Card)"]//"To my wallet",
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tblView.register(nibWithCellClass: MPReasonTableCell.self)
        self.setupValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    
    func setupValue() {
        self.tblView.reloadData()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

    // MARK: - IBAction
    @IBAction func btn_Submit_Action(_ sender: UIControl) {
        if self.selectedOption == "" {
            self.showToast(message: "Please select option")
            return
        }
        
        let vc = OrderCancelledVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.dic_OrderDetail = self.dic_OrderDetail
        vc.str_RefunfOption = self.selectedOption
        vc.is_ReturnProduct = self.is_ReturnProduct
        self.navigationController?.pushViewController(vc, animated: true)
        
        //self.callAPIforOrdercancel()
    }
    
    
    func callAPIforOrdercancel() {
        
        let refund_option = self.selectedOption == "To my wallet" ? "wallet" : "bank or UPI"
        
        var param = ["ifsc_code": "",
                     "bank_account_number": "",
                     "reason": self.selectedOption,
                     "refund_option": refund_option,
                     "comment": self.str_ReasonComment,
                     "order_id": self.str_OrderID,
                     "product_id": self.dic_OrderDetail?.id ?? 0] as [String: Any]

        showActivityIndicator()
        var nameAPI: endPoint = .mp_UserCancelOrder
        
        if self.is_ReturnProduct {
            nameAPI = .mp_userReturnOrder
            param["refund_option"] = "UPI"
        }
        
        Utils.doAPICallMartketPlace(endPoint: nameAPI.rawValue, method: .post, parameters: param, headers: MPLoginLocalDB.getHeaderToken()) {  isSuccess, status, message, responseJSON in
            self.hideActivityIndicator()
            if isSuccess {
                let vc = OrderCancelledVC.instantiate(fromAppStoryboard: .MarketPlace)
                vc.dic_OrderDetail = self.dic_OrderDetail
                vc.str_RefunfOption = self.selectedOption
                vc.is_ReturnProduct = self.is_ReturnProduct
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if status == "Token is Expired" {
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }
}

extension MPRefundDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withClass: MPReasonTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.lbl_Underline.isHidden = true
        cell.lbl_Title.text = self.arr_Options[indexPath.row]

        let reason_title = self.arr_Options[indexPath.row]
        if self.selectedOption == reason_title {
            cell.img_selection.image = UIImage(named: "icon_radio_button_checked")
        }
        else {
            cell.img_selection.image = UIImage(named: "icon_radio_button_unchecked")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reason_title = self.arr_Options[indexPath.row]
        self.selectedOption = reason_title
        self.tblView.reloadData()
    }
}
