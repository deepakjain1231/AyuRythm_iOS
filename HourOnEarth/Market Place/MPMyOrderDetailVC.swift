//
//  MPMyOrderDetailVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 20/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import SafariServices
import AlamofireImage

class MPMyOrderDetailVC: UIViewController {

    var str_ClickedProductID = ""
    var dic_ParticularProduct: MPMyOrderProductDetail?
    var dic_OrderDetail: MPOrderProductData?
    @IBOutlet weak var lbl_OrderID: UILabel!
    @IBOutlet weak var img_product: UIImageView!
    @IBOutlet weak var lbl_product_Title: UILabel!
    @IBOutlet weak var lbl_product_subTitle: UILabel!
    @IBOutlet weak var btn_Help: UIControl!
    @IBOutlet weak var btn_Cancel: UIControl!
    @IBOutlet weak var lbl_CancelText: UILabel!
    @IBOutlet weak var lbl_CenterIndicator: UILabel!
    @IBOutlet weak var constraint_btn_Cancel_Width: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_ExtraItemTitle: UILabel!
    @IBOutlet weak var lbl_ExtraItemOrderID: UILabel!
    @IBOutlet weak var view_ExtraItem: UIView!
    @IBOutlet weak var tblView_Product: UITableView!
    @IBOutlet weak var constraint_tblView_Product_Height: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_PaymentMode: UILabel!
    @IBOutlet weak var lbl_Username: UILabel!
    @IBOutlet weak var lbl_Address: UILabel!
    @IBOutlet weak var lbl_OrderPlaceDate: UILabel!
    @IBOutlet weak var lbl_OrderShippedDate: UILabel!
    @IBOutlet weak var lbl_OrderOutOfDeliveryDate: UILabel!
    @IBOutlet weak var lbl_OrderDeliveredDate: UILabel!
    
    @IBOutlet weak var lbl_OrderPlace: UILabel!
    @IBOutlet weak var lbl_OrderShipped: UILabel!
    @IBOutlet weak var lbl_OrderOutOfDelivery: UILabel!
    @IBOutlet weak var lbl_OrderDelivered: UILabel!
    @IBOutlet weak var lbl_OrderShipped_subTitle: UILabel!
    
    
    @IBOutlet weak var img_OrderPlace: UIImageView!
    @IBOutlet weak var img_OrderShipped: UIImageView!
    @IBOutlet weak var img_OrderOutOfDelivery: UIImageView!
    @IBOutlet weak var img_OrderDelivered: UIImageView!
    @IBOutlet weak var lbl_OrderPlaceIndicator: UILabel!
    @IBOutlet weak var lbl_OrderShippedIndicator: UILabel!
    @IBOutlet weak var lbl_OrderOutOfDeliveryIndicator: UILabel!
    
    @IBOutlet weak var stack_OrderShipped: UIStackView!
    @IBOutlet weak var stack_OrderOutOfDelivery: UIStackView!
    @IBOutlet weak var stack_OrderDelivered: UIStackView!
    @IBOutlet weak var view_Order_status_HEIGHT: NSLayoutConstraint!
    
    
    @IBOutlet weak var lbl_ItemCount: UILabel!
    @IBOutlet var viewCartPricing: UIView!
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblCGST: UILabel!
    @IBOutlet weak var lblDeliveryCharge: UILabel!
    @IBOutlet weak var lblApplyCouponPrice: UILabel!
    @IBOutlet weak var lblApplyCouponPrice_Title: UILabel!
    @IBOutlet weak var lblTotalPayableAmount: UILabel!
    @IBOutlet weak var stackview_forCouponCode: UIStackView!
    
    @IBOutlet weak var lbl_Download: UILabel!
    @IBOutlet weak var btn_Download: UIControl!
    @IBOutlet weak var img_Download: UIImageView!
    @IBOutlet weak var lbl_saperator: UILabel!
    @IBOutlet weak var lbl_Share: UILabel!
    @IBOutlet weak var btn_Share: UIControl!
    @IBOutlet weak var img_Share: UIImageView!
    
    var arr_Extra_Product = [MPMyOrderProductDetail]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_ExtraItemTitle.text = ""
        self.lbl_ExtraItemOrderID.text = ""
        self.view_ExtraItem.isHidden = true
        self.constraint_tblView_Product_Height.constant = 0
        
        self.setupValue()
        self.img_Share.setImageColor(color: kAppBlueColor)
        self.img_Download.setImageColor(color: kAppBlueColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setupValue() {
        self.constraint_btn_Cancel_Width.constant = UIScreen.main.bounds.width/2
        let strOrderID = (self.dic_OrderDetail?.order_number ?? "").uppercased()
        self.lbl_OrderID.text = "ORDER ID: \(strOrderID)"
        
        if (self.dic_OrderDetail?.products.count ?? 0) == 1, let dic_Product = self.dic_OrderDetail?.products.first {
            self.dic_ParticularProduct = dic_Product
            self.setupProductData()
        }
        else {
            if let arrAllProduct = self.dic_OrderDetail?.products {
                self.arr_Extra_Product.removeAll()
                for dicPro in arrAllProduct {
                    let productid = "\(dicPro.id)"
                    if productid == self.str_ClickedProductID {
                        self.dic_ParticularProduct = dicPro
                        self.setupProductData()
                    }
                    else {
                        self.arr_Extra_Product.append(dicPro)
                    }
                }
                self.tblView_Product.reloadData()
                self.view_ExtraItem.isHidden = false
                self.lbl_ExtraItemTitle.text = "Other items in this order"
                self.lbl_ExtraItemOrderID.text = "ORDER ID: \(strOrderID)"
                self.constraint_tblView_Product_Height.constant = CGFloat((self.arr_Extra_Product.count * 105))
                self.view.layoutIfNeeded()
            }
        }

        if let dic_ShippingInfo = self.dic_OrderDetail?.shipping_info {
            var address = ""
            self.lbl_Username.text = "\(dic_ShippingInfo.shipping_name)"

            if dic_ShippingInfo.shipping_building_name != "" {
                address = dic_ShippingInfo.shipping_building_name
            }

            if dic_ShippingInfo.shipping_address != "" {
                if address != "" {
                    address = address + ", "
                }
                address = address + dic_ShippingInfo.shipping_address
            }

            if dic_ShippingInfo.shipping_landmark != "" {
                if address != "" {
                    address = address + ", "
                }
                address = address + dic_ShippingInfo.shipping_landmark
            }

            if dic_ShippingInfo.shipping_city != "" {
                if address != "" {
                    address = address + ", "
                }
                address = address + dic_ShippingInfo.shipping_city
            }

            if dic_ShippingInfo.shipping_state != "" {
                address = address + ", " + dic_ShippingInfo.shipping_state
            }
            if dic_ShippingInfo.shipping_zip != "" {
                address = address + " - " + dic_ShippingInfo.shipping_zip
            }

            if dic_ShippingInfo.shipping_phone != "" {
                address = address + "\n" + (dic_ShippingInfo.shipping_phone)
            }

            self.lbl_Address.text = address
            //self.lbl_Address.text =  "\(dic_ShippingInfo.shipping_address), \(dic_ShippingInfo.shipping_city) - \(dic_ShippingInfo.shipping_zip)"
        }
        
        let paymentMode = self.dic_OrderDetail?.payment_method ?? ""
        if paymentMode.lowercased() == "cash on delivery" {
            self.lbl_PaymentMode.text = "Mode of payment: \(paymentMode)"
        }
        else {
            self.lbl_PaymentMode.text = "Mode of payment: Online"
        }

        if let dic_getCreatedDate = self.dic_OrderDetail?.created_at as? [String: Any] {
            var strcreatedate = dic_getCreatedDate["date"] as? String ?? ""
            strcreatedate = strcreatedate.replacingOccurrences(of: "th,", with: "")
            strcreatedate = strcreatedate.replacingOccurrences(of: "st,", with: "")
            strcreatedate = strcreatedate.replacingOccurrences(of: "nd,", with: "")
            strcreatedate = strcreatedate.replacingOccurrences(of: "rd,", with: "")
            let strCreatedDate = convertStringToDate(strDate: strcreatedate, fromFormat: MPDateFormat.dd_MMM_yyyy_hh_mm_AM_PM, toFormat: MPDateFormat.EEE_ddMMMYYYYhhmma)
            self.lbl_OrderPlaceDate.text = "On \(strCreatedDate)"
        }
        
        if let dic_getUpdatedDate = self.dic_OrderDetail?.updated_at as? [String: Any] {
            var strupdatedate = dic_getUpdatedDate["date"] as? String ?? ""
            strupdatedate = strupdatedate.replacingOccurrences(of: "th,", with: "")
            strupdatedate = strupdatedate.replacingOccurrences(of: "st,", with: "")
            strupdatedate = strupdatedate.replacingOccurrences(of: "nd,", with: "")
            strupdatedate = strupdatedate.replacingOccurrences(of: "rd,", with: "")
            let strUpdatedDate = convertStringToDate(strDate: strupdatedate, fromFormat: MPDateFormat.dd_MMM_yyyy_hh_mm_AM_PM, toFormat: MPDateFormat.EEE_ddMMMYYYYhhmma)
            self.lbl_OrderShippedDate.text = "On \(strUpdatedDate)"
            self.lbl_OrderOutOfDeliveryDate.text = "On \(strUpdatedDate)"
            self.lbl_OrderDeliveredDate.text = "On \(strUpdatedDate)"
        }
        self.setUpPricing()
    }
    
    func setupProductData() {
        let strImgPrroduct = self.dic_ParticularProduct?.feature_image ?? ""
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
        self.lbl_product_Title.text = self.dic_ParticularProduct?.name
        self.lbl_product_subTitle.text = self.dic_ParticularProduct?.size
    }
    
    func setUpPricing() {
        //if let dic_Detail = self.dic_OrderDetail?.price_details {
        self.lbl_ItemCount.text = "Price details  (1 Items)"
        let totalMRP = self.dic_ParticularProduct?.item_mrp
        if totalMRP == 0 {
            self.lblSubtotal.text = self.settwo_desimalValue(totalMRP)
        }

        self.lblSubtotal.text = self.settwo_desimalValue(totalMRP)
        self.lblDiscount.text = self.settwo_desimalValue(self.dic_ParticularProduct?.item_discount)
        self.lblDeliveryCharge.text = self.settwo_desimalValue(self.dic_ParticularProduct?.item_delivery_charge)
        self.lblCGST.text = self.settwo_desimalValue(self.dic_ParticularProduct?.item_tax)
        self.lblTotalPayableAmount.text = self.settwo_desimalValue(self.dic_ParticularProduct?.total_price)
        let couponPrice = self.dic_ParticularProduct?.item_coupon_amount ?? 0
        self.lblApplyCouponPrice.text = "-" + self.settwo_desimalValue(couponPrice)

        if couponPrice == 0 {
            self.stackview_forCouponCode.isHidden = true
            
            if self.dic_ParticularProduct?.item_wise_walled_applied == "Yes" {
                self.stackview_forCouponCode.isHidden = false
                self.lblApplyCouponPrice_Title.text = "Wallet amount"
                let walletPrice = self.dic_ParticularProduct?.item_wise_wallet_amount ?? 0
                self.lblApplyCouponPrice.text = "-" + self.settwo_desimalValue(walletPrice)
            }
        }
        //}
        self.setUpOderStatusIcon()
    }
    
    func settwo_desimalValue(_ value: NSNumber?) -> String {
        return String(format: "₹ %.2f", value?.doubleValue ?? 0.0)
    }
    
    func setUpOderStatusIcon() {
        
        let str_invoiceLink = self.dic_OrderDetail?.invoice_url ?? ""
        if URL.init(string: str_invoiceLink) != nil {
            self.lbl_saperator.isHidden = false
            self.btn_Download.isHidden = false
        }

        if let dic_product = self.dic_ParticularProduct {
            let stt_ProductStatus = dic_product.status
            if stt_ProductStatus.lowercased() == "pending" {
            }
            else if stt_ProductStatus == "Processing" || stt_ProductStatus == "Shipped" {
                self.stack_OrderShipped.isHidden = false
                self.img_OrderShipped.image = MP_appImage.img_Order_Status_selected
            }
            else if stt_ProductStatus == "On delivery" || stt_ProductStatus == "Out For Delivery" {
                self.stack_OrderOutOfDelivery.isHidden = false
                self.img_OrderShipped.image = MP_appImage.img_Order_Status_selected
                self.img_OrderOutOfDelivery.image = MP_appImage.img_Order_Status_selected
                self.lbl_OrderShippedIndicator.backgroundColor = UIColor.fromHex(hexString: "#6CC068")
            }
            else if stt_ProductStatus == "Delivered" {
                
                if self.dic_ParticularProduct?.can_cancel_or_not.lowercased() == "yes" {
                    self.lbl_CancelText.text = "CANCEL"
                    self.stack_OrderDelivered.isHidden = false
                }
                else if self.dic_ParticularProduct?.can_return_or_not.lowercased() == "yes" {
                    self.lbl_CancelText.text = "RETURN"
                    self.stack_OrderDelivered.isHidden = false
                }
                else {
                    self.stack_OrderDelivered.isHidden = true
                }

                self.img_OrderShipped.image = MP_appImage.img_Order_Status_selected
                self.img_OrderOutOfDelivery.image = MP_appImage.img_Order_Status_selected
                self.img_OrderDelivered.image = MP_appImage.img_Order_Status_selected
                self.lbl_OrderShippedIndicator.backgroundColor = UIColor.fromHex(hexString: "#6CC068")
                self.lbl_OrderOutOfDeliveryIndicator.backgroundColor = UIColor.fromHex(hexString: "#6CC068")
            }
            else if stt_ProductStatus == "Return Requested" {
                self.btn_Cancel.isHidden = true
                self.lbl_CenterIndicator.isHidden = true
                self.lbl_OrderShipped.text = stt_ProductStatus
                self.lbl_OrderShippedIndicator.isHidden = true
                self.lbl_OrderShipped_subTitle.text = "Your order is Return Requested"
                self.stack_OrderShipped.isHidden = false
                self.stack_OrderOutOfDelivery.isHidden = true
                self.stack_OrderDelivered.isHidden = true
                self.view_Order_status_HEIGHT.constant = 190
                self.img_OrderShipped.setImageColor(color: .red)
                self.constraint_btn_Cancel_Width.constant = 0
            }
            else {
                self.btn_Cancel.isHidden = true
                self.lbl_CenterIndicator.isHidden = true
                self.lbl_OrderShipped.text = "Cancelled"
                self.lbl_OrderShippedIndicator.isHidden = true
                self.lbl_OrderShipped_subTitle.text = "Your order is Cancelled"
                self.stack_OrderShipped.isHidden = false
                self.stack_OrderOutOfDelivery.isHidden = true
                self.stack_OrderDelivered.isHidden = true
                self.view_Order_status_HEIGHT.constant = 190
                self.img_OrderShipped.setImageColor(color: .red)
                self.constraint_btn_Cancel_Width.constant = 0
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
    
    //MARK: - UIButton Method
    
    @IBAction func btn_Help_Action(_ sender: UIControl) {
        let vc = MpHelpVC.instantiate(fromAppStoryboard: .MarketPlace)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_CurrentProduct_Action(_ sender: UIControl) {
        let vc = HowToUseProductVC.instantiate(fromAppStoryboard: .WeeklyPlaner)
        vc.is_MyProduct = true
        vc.str_ProductID = self.str_ClickedProductID
        self.navigationController?.pushViewController(vc, animated: true)
//        let vc = MPProductDetailVC.instantiate(fromAppStoryboard: .MarketPlace)
//        vc.str_productID = self.str_ClickedProductID
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_Cancel_Action(_ sender: UIControl) {
        if self.lbl_CancelText.text?.lowercased() == "cancel" {
            let str_Cancel = self.dic_ParticularProduct?.can_cancel_or_not ?? ""
            if str_Cancel.lowercased() == "no" {
                self.showAlert(message: "Order cancellation allowed with 24 hrs of order placement or if sellers allows")
            }
            else {
                let vc = MPCancelOrderVC.instantiate(fromAppStoryboard: .MarketPlace)
                vc.str_OrderID = "\(self.dic_OrderDetail?.id ?? 0)"
                vc.dic_OrderDetail = self.dic_ParticularProduct
                vc.str_patment_method = self.dic_OrderDetail?.payment_method ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            let str_Cancel = self.dic_ParticularProduct?.can_return_or_not ?? ""
            if str_Cancel.lowercased() == "no" {
                self.showAlert(message: "Order return allowed with 24 hrs of order delivered or if sellers allows")
            }
            else {
                let vc = MPCancelOrderVC.instantiate(fromAppStoryboard: .MarketPlace)
                vc.is_ReturnProduct = true
                vc.str_OrderID = "\(self.dic_OrderDetail?.id ?? 0)"
                vc.dic_OrderDetail = self.dic_ParticularProduct
                vc.str_patment_method = self.dic_OrderDetail?.payment_method ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
    }
    
    @IBAction func btn_Download_Action(_ sender: UIControl) {
        let str_invoiceLink = self.dic_OrderDetail?.invoice_url ?? ""
        if let invoice_url = URL.init(string: str_invoiceLink) {
            let safariVC = SFSafariViewController(url: invoice_url)
            present(safariVC, animated: true, completion: nil)
        }
        else {
            self.showToast(message: "Invoice url incorrect")
        }
    }
    
    @IBAction func btn_Share_Action(_ sender: UIControl) {
        let str_invoiceLink = self.dic_OrderDetail?.invoice_url ?? ""
        if str_invoiceLink != "" {
            self.shareProductOrderDetails(text: str_invoiceLink)
        }
        else {
            self.showToast(message: "Invoice url not found")
        }
    }

    
    func shareProductOrderDetails(text: String) {
        let finalShareText = text
        let shareAll = [ finalShareText ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}



//MARK: - UITableView Delegate Datasource
extension MPMyOrderDetailVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Extra_Product.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withClass: MPOrderSummaryTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        
        //if
            let dic_Product = self.arr_Extra_Product[indexPath.row] //{ self.dic_OrderDetail?.products[indexPath.row] {
            let strImgPrroduct = dic_Product.feature_image
            if strImgPrroduct != "" {
                if let url = URL(string: strImgPrroduct) {
                    cell.img_product.af_setImage(withURL: url, placeholderImage: UIImage.init(named: "default_image"))
                }
                else {
                    cell.img_product.image = UIImage.init(named: "default_image")
                }
            }
            else {
                cell.img_product.image = UIImage.init(named: "default_image")
            }
            cell.lbl_Title.text = dic_Product.name
            cell.lbl_SubTitle.text = dic_Product.size
        //}
        
        
        
        
//            let estimated_shipping_time = data.estimated_shipping_time
//            cell.lbl_bottomTItle.text = ""// estimated_shipping_time.count == 0 ? "" : "Est. Delivery in \(estimated_shipping_time)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic_Product = self.arr_Extra_Product[indexPath.row]
        let vc = MPProductDetailVC.instantiate(fromAppStoryboard: .MarketPlace)
        vc.str_productID = "\(dic_Product.id)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}




