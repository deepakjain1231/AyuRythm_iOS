//
//  MPCancelOrderVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 21/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MPCancelOrderVC: UIViewController, UITextViewDelegate {

    var is_ReturnProduct = false
    
    var selectedReason = ""
    var str_OrderID = ""
    var str_patment_method = ""
    var placeHoderText = "Additional comments (Optional)"
    var dic_OrderDetail: MPMyOrderProductDetail?
    @IBOutlet weak var txt_View: UITextView!
    @IBOutlet weak var img_product: UIImageView!
    @IBOutlet weak var lbl_product_Title: UILabel!
    @IBOutlet weak var lbl_product_subTitle: UILabel!
    @IBOutlet weak var lbl_refundAmount: UILabel!
    @IBOutlet weak var tblView_reason: UITableView!
    @IBOutlet weak var constraint_tblView_reason_Height: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_ReasonTitle: UILabel!
    @IBOutlet weak var lbl_ReasonSubTitle: UILabel!
    @IBOutlet weak var lbl_cancelOrderBtn: UILabel!
    
    
    var arr_Reasons = ["Duplicate Order",
                       "Ordered by mistake",
                       "Expected delivery is too long ",
                       "Product not required any more",
                       "I have purchased product elsewhere",
                       "Want to change phone no and address"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.txt_View.delegate = self
        self.txt_View.layer.borderWidth = 1
        self.txt_View.layer.cornerRadius = 12
        self.tblView_reason.register(nibWithCellClass: MPReasonTableCell.self)
        self.txt_View.layer.borderColor = UIColor.fromHex(hexString: "#E5E5E5").cgColor
        self.txt_View.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        self.setupValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    
    func setupValue() {
        if self.is_ReturnProduct {
            self.title = "Return Order"
            self.lbl_ReasonTitle.text = "Reason for return"
            self.lbl_ReasonSubTitle.text = "Please let us know the reason for return. This information will help us to improve your shopping experience & our services"
            self.lbl_cancelOrderBtn.text = "RETURN ORDER"
        }
        
        
        let strImgPrroduct = self.dic_OrderDetail?.feature_image ?? ""
        if strImgPrroduct != "" {
            if let url = URL(string: strImgPrroduct) {
                self.img_product.af_setImage(withURL: url, placeholderImage: UIImage.init(named: "default_image"))
            }
            else {
                self.img_product.image = UIImage.init(named: "default_image")
            }
        }
        else {
            self.img_product.image = UIImage.init(named: "default_image")
        }
        self.lbl_product_Title.text = self.dic_OrderDetail?.name
        self.lbl_product_subTitle.text = self.dic_OrderDetail?.size
        self.lbl_refundAmount.text = self.settwo_desimalValue(self.dic_OrderDetail?.total_price)

        self.constraint_tblView_reason_Height.constant = CGFloat(self.arr_Reasons.count * 45)
        self.tblView_reason.reloadData()
        self.view.layoutIfNeeded()
    }

    func settwo_desimalValue(_ value: NSNumber?) -> String {
        return String(format: "₹ %.2f", value?.doubleValue ?? 0.0)
    }
    
    
    // MARK: - UITextView Delegate Method
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let statext = textView.text {
            if statext == placeHoderText {
                textView.text = ""
                textView.textColor = .black
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let statext = textView.text {
            if statext == placeHoderText || statext == "" {
                textView.text = placeHoderText
                textView.textColor = .lightGray
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

    // MARK: - IBAction
    @IBAction func btn_CancelOrder(_ sender: UIControl) {
        if self.selectedReason == "" {
            if self.is_ReturnProduct {
                self.showToast(message: "Please select reason for return order.")
            }
            else {
                self.showToast(message: "Please select reason for cancel order.")
            }
            return
        }
        
        var resonCommet = self.txt_View.text ?? ""
        resonCommet = resonCommet == placeHoderText ? "" : resonCommet

        if self.str_patment_method.lowercased() == "cash on delivery" {
            self.callAPIforOrdercancel(resonCommet)
        }
        else {
            let vc = MPRefundDetailsVC.instantiate(fromAppStoryboard: .MarketPlace)
            vc.str_OrderID = self.str_OrderID
            vc.str_ReasonComment = resonCommet
            vc.dic_OrderDetail = self.dic_OrderDetail
            vc.is_ReturnProduct = self.is_ReturnProduct
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func callAPIforOrdercancel(_ commentt: String) {

        var param = ["ifsc_code": "",
                     "bank_account_number": "",
                     "reason": self.selectedReason,
                     "refund_option": "",
                     "comment": commentt,
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
                vc.str_RefunfOption = self.selectedReason
                vc.str_patment_method = self.str_patment_method
                self.navigationController?.pushViewController(vc, animated: true)
            }else if status == "Token is Expired" {
                callAPIfor_LOGIN()
            } else {
                self.showAlert(title: status, message: message)
            }
        }
    }

}

extension MPCancelOrderVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Reasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withClass: MPReasonTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.lbl_Underline.isHidden = true
        cell.lbl_Title.text = self.arr_Reasons[indexPath.row]

        let reason_title = self.arr_Reasons[indexPath.row]
        if self.selectedReason == reason_title {
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
        let reason_title = self.arr_Reasons[indexPath.row]
        self.selectedReason = reason_title
        self.tblView_reason.reloadData()
    }
}
