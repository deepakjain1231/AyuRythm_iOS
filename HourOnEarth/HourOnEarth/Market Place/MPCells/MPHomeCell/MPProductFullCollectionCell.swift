//
//  MPProductFullCollectionself.swift
//  HourOnEarth
//
//  Created by Maulik Vora on 09/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MPProductFullCollectionCell: UICollectionViewCell {

    var current_vc = UIViewController()
    @IBOutlet weak var view_DefaultBG: UIView!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var img_product: UIImageView!
    @IBOutlet weak var lbl_off: UILabel!
    @IBOutlet weak var lbl_old_Price: UILabel!
    @IBOutlet weak var lbl_currentPrice: UILabel!
    @IBOutlet weak var btn_AddTocart: UIButton!
    @IBOutlet weak var view_AddTocartBG: UIView!
    @IBOutlet weak var lblEstDeliveryTime: UILabel!
    @IBOutlet weak var lblOutOfStock: UILabel!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var viewOutOfStock: UIView!
    @IBOutlet weak var viewOutOfStockGradientColor: UIView!
    
    @IBOutlet weak var btnRating: UIButton!
    @IBOutlet weak var btnRating_BG: UIView!
    
    var isAvailable = false
    var productData: MPProductData? {
        didSet{
            self.viewOutOfStockGradientColor.backgroundColor = UIColor.clear
            self.viewOutOfStockGradientColor.isHidden = true
            self.viewOutOfStockGradientColor.removeOutOfStockGradient()
            self.lblOutOfStock.text = ""
            self.isAvailable = MPCartManager.checkIfProductAvailable(productId: productData?.id ?? 0)
            self.setUpData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func addToCartAction(_ sender: UIButton) {
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to add to cart".localized(), controller: (kSharedAppDelegate.window?.rootViewController)!)
            return
        }
        MPCartManager.addToCartButtonAction(btnCart: sender, view_AddTocartBG: view_AddTocartBG, productData: productData, current_vc: self.current_vc)
    }
    
    
    @IBAction func addToWishList_Action(_ sender: UIButton){
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to add to favourite".localized(), controller: (kSharedAppDelegate.window?.rootViewController)!)
            return
        }
        MPWishlistManager.addToWishlistButton_Action(btnWishlist: sender, productData: productData)
    }
    
    func showOutOfStock(is_check: Bool = false)  {
        
        if is_check {
            btn_AddTocart.tag = 1231
        }
        else {
            let product = productData!
            if product.is_variable_product.lowercased() == "yes" && product.size_quantity.count > 0 && product.size_quantity.filter({Int($0) ?? 0 > 0}).count > 0 {
                btn_AddTocart.tag = self.isAvailable ? 1 : 0//1 for availble in cart and 0 for not available in cart
            }else if product.simple_product_stock > 0{
                btn_AddTocart.tag = self.isAvailable ? 1 : 0//1 for availble in cart and 0 for not available in cart
            }else{
                btn_AddTocart.tag = 2//2 for notify me
            }
        }
        
        setDisbaleCellForOutOfStock()
    }
    
    
    
    
    
    
    
    
    func setUpData()  {
        if isAvailable{
            productData?.cartData = MPCartManager.getSelectedProductsByProductId(product: productData!)?.cartData
        }

        var is_ShowingDiscount = false
        var cruPrice: Double = self.isAvailable ? Double(self.productData?.cartData?.sizes_wise_price.floatValue ?? 0) : Double(self.productData?.current_price ?? 0)
        var prvPrice: Double = self.isAvailable ? Double(self.productData?.cartData?.sizes_wise_previous_price.floatValue ?? 0) : Double(self.productData?.previous_price ?? 0)
        
        var cruSize = self.productData?.sizes.first ?? ""
        if self.isAvailable {
            cruSize = self.productData?.cartData?.sizes ?? ""
        }
        
        
        //==Logic for Out Of Strock Product==========================================================================================//
        debugPrint("Product Title:======\(self.productData?.title ?? "")")
        let dic_temp = self.checkProductQuentity_andSetData(current_Sizr: cruSize, current_Price: cruPrice, previous_Price: prvPrice)
        cruSize = dic_temp["cruSize"] as? String ?? ""
        cruPrice = dic_temp["cruPrice"] as? Double ?? 0.0
        prvPrice = dic_temp["prvPrice"] as? Double ?? 0.0
        let is_localCalculation = dic_temp["is_localCalculation"] as? Bool ?? false
        let int_productQuentity = dic_temp["productQuentity"] as? Int ?? 0
        //***************************************************************************************************************************//
        
        
        self.titleL.text = self.productData?.title ?? ""
        self.lbl_subTitle.text = self.productData?.ayurvedic_name ?? ""
        
        
        self.lbl_currentPrice.text = "₹ \(Int(cruPrice))"
        self.lblSize.text = cruSize
        if self.productData?.is_variable_product.lowercased() == "no" {
            self.lblSize.text = self.productData?.simple_product_size_label ?? ""
        }
        
        if prvPrice > 0 && prvPrice > cruPrice {
            is_ShowingDiscount = true
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: "MRP ₹ \(Int(prvPrice))")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
            self.lbl_old_Price.attributedText = attributeString
        }else{
            self.lbl_off.text = ""
            self.lbl_old_Price.text = ""
        }
        
        //showing Rating
        let int_rating = self.productData?.rating ?? 0
        if int_rating == 0 {
            self.btnRating_BG.isHidden = true
        }
        else {
            self.btnRating_BG.isHidden = false
            self.btnRating.setTitle("\(int_rating)", for: .normal)
        }
        
        //Showing Discount
        if is_ShowingDiscount {
            let getDiscount = ((cruPrice * 100)/prvPrice).rounded(.up)
            let intDiscont: Int = Int(100 - getDiscount)
            if 0 < intDiscont {
                self.lbl_off.text = "\(intDiscont)% OFF"
            }
            else {
                self.lbl_off.text = ""
            }
        } else{
            self.lbl_off.text = ""
        }
        
        let estimated_shipping_time = self.productData?.estimated_shipping_time ?? ""
        self.lblEstDeliveryTime.text = estimated_shipping_time.count == 0 ? "" : "Est. Delivery in \(estimated_shipping_time)"
        
        let urlString = self.productData?.thumbnail ?? ""
        if let url = URL(string: urlString) {
            self.img_product.sd_setImage(with: url, placeholderImage: appImage.default_image_placeholder)
        }
        
        var strButtonTitle = ""
        if int_productQuentity == 0 {
            if is_localCalculation {
                strButtonTitle = "Go to cart"
            }
        }
        
        MPCartManager.setCartButtonTitle(btnCart: self.btn_AddTocart, view_AddTocartBG: self.view_AddTocartBG, product: self.productData!, button_Title: strButtonTitle)
        self.showOutOfStock()
        self.btn_AddTocart.isHidden = false
        
        MPWishlistManager.setWishlistButtonTitle(btnWishlist: self.btnFav, product: self.productData!)
        
        
        //==Logic for Out Of Strock Product==========================================================================================//
        //===========================================================================================================================//
        if int_productQuentity == 0 {
            debugPrint("Producrt is Out of stock")
            btn_AddTocart.tag = 1231
            showOutOfStock(is_check: true)
            self.btn_AddTocart.setTitle("Go to cart", for: .normal)
            self.view_AddTocartBG.backgroundColor = UIColor.systemBlue
            self.view_AddTocartBG.layer.borderColor = UIColor.systemBlue.cgColor
            self.btn_AddTocart.setTitleColor(UIColor.white, for: .normal)
        }
        //***************************************************************************************************************************//
        //***************************************************************************************************************************//

    }
    
    func setDisbaleCellForOutOfStock()  {
        self.viewOutOfStockGradientColor.isHidden = btn_AddTocart.tag == 2 ? false : true
        btn_AddTocart.tag == 2 ? self.viewOutOfStockGradientColor.setGradientBackground() : viewOutOfStockGradientColor.removeOutOfStockGradient()
        self.viewOutOfStock.isHidden = btn_AddTocart.tag == 2 ? false : true
        self.titleL.textColor = btn_AddTocart.tag == 2 ? UIColor.gray : UIColor.black
        self.lbl_currentPrice.textColor = btn_AddTocart.tag == 2 ? UIColor.gray : UIColor.black
        self.lbl_off.textColor = btn_AddTocart.tag == 2 ? UIColor.gray : UIColor.red
        self.lblOutOfStock.text = ""
    }
    
    
    func checkProductQuentity_andSetData(current_Sizr: String, current_Price: Double, previous_Price: Double) -> [String: Any] {
        
        var int_productQuentity: Int = 0
        var cruSize = current_Sizr
        var cruPrice = current_Price
        var prvPrice = previous_Price
        var is_localCalculation = false
        
        //Check Veriavle Product
        var int_Indx = 0
        if self.productData?.is_variable_product.lowercased() == "yes" {
            if let arr_size_Quentity = self.productData?.size_quantity {
                for product_quentity in arr_size_Quentity {
                    int_productQuentity = Int(product_quentity) ?? 0
                    if int_productQuentity > 0 {
                        cruSize = self.productData?.sizes[int_Indx] ?? ""
                        cruPrice = Double(self.productData?.sizes_wise_price_in_int[int_Indx] ?? 0)
                        prvPrice = Double(self.productData?.sizes_wise_previous_price_in_int[int_Indx] ?? 0)
                        
                        if let arr_cartDetail = self.productData?.CART_DETAIL {
                            for dic_cart in arr_cartDetail {
                                let ADDED_SIZE = dic_cart.ADDED_SIZE
                                let ADDED_QUANTITY = dic_cart.ADDED_QUANTITY
                                if cruSize == ADDED_SIZE {
                                    is_localCalculation = true
                                    int_productQuentity = int_productQuentity - ADDED_QUANTITY
                                }
                            }
                        }
                        
                        //==========================//
                        if int_productQuentity > 0 {
                            if int_productQuentity <= 5 {
                                self.lblOutOfStock.text = "Only \(int_productQuentity) left!"
                            }
                            else {
                                self.lblOutOfStock.text = ""
                            }
                            break
                        }
                        //**************************//
                    }
                    int_Indx = int_Indx + 1
                }
            }
        }
        else {
            int_productQuentity = self.productData?.simple_product_stock ?? 0
            if int_productQuentity > 0 {
                if let arr_cartDetail = self.productData?.CART_DETAIL {
                    for dic_cart in arr_cartDetail {
                        is_localCalculation = true
                        let ADDED_QUANTITY = dic_cart.ADDED_QUANTITY
                        int_productQuentity = int_productQuentity - ADDED_QUANTITY
                    }
                }

                if int_productQuentity <= 5 {
                    self.lblOutOfStock.text = "Only \(int_productQuentity) left!"
                }
                else {
                    self.lblOutOfStock.text = ""
                }
            }
        }
        
        return ["cruSize": cruSize, "cruPrice":cruPrice, "prvPrice": prvPrice, "is_localCalculation": is_localCalculation, "productQuentity": int_productQuentity]
    }
}


