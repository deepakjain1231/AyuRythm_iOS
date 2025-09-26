//
//  OrderCancelledVC.swift
//  HourOnEarth
//
//  Created by Deepak Jain on 21/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class OrderCancelledVC: UIViewController {

    var is_ReturnProduct = false
    var str_RefunfOption = ""
    var str_patment_method = ""
    var dic_OrderDetail: MPMyOrderProductDetail?
    
    @IBOutlet weak var lbl_orderCancalTitle: UILabel!
    @IBOutlet weak var lbl_itmCancel: UILabel!
    
    @IBOutlet weak var img_product: UIImageView!
    @IBOutlet weak var lbl_product_Title: UILabel!
    @IBOutlet weak var lbl_product_subTitle: UILabel!
    @IBOutlet weak var lbl_refundAmount: UILabel!
    @IBOutlet weak var lbl_refundOption: UILabel!
    @IBOutlet weak var lbl_refundAmountText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.setupValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: #selector(self.back(sender:)))
    }
    
    
    func setupValue() {
        if self.is_ReturnProduct {
            self.title = "Return Order"
            self.lbl_orderCancalTitle.text = "Order Returned"
            self.lbl_itmCancel.text = "1 item returned"
        }
        
        self.lbl_refundOption.text = self.str_RefunfOption
        
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
        
        if self.str_patment_method.lowercased() == "cash on delivery" {
            self.lbl_refundAmountText.text = ""
        }
        else {
            self.lbl_refundAmountText.text = "Refund amount of \(self.settwo_desimalValue(self.dic_OrderDetail?.total_price)) will be credited to account in 7 days "
        }
    }

    func settwo_desimalValue(_ value: NSNumber?) -> String {
        return String(format: "₹ %.2f", value?.doubleValue ?? 0.0)
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
    @IBAction func btn_Done_Action(_ sender: UIControl) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func back(sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }

}
