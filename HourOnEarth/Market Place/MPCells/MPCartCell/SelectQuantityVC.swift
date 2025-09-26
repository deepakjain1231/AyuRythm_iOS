//
//  SelectQuantityVC.swift
//  HourOnEarth
//
//  Created by CodeInfoWay CodeInfoWay on 6/25/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class SelectQuantityVC: UIViewController {

    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tblSelectQuanity: UITableView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    
    
    var didTappedQuantity: ((MPCartData)->Void)? = nil
    var productData: MPProductData?
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("===============================")
        print(MPCartManager.getCartData())
        print("===============================")
        tblSelectQuanity.register(nibWithCellClass: SelectQuantityCell.self)

        // Do any additional setup after loading the view.
        self.view_Main.layer.cornerRadius = 12
        self.view_Main.clipsToBounds = true
        
        self.view_Main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
            
        self.heightTableView.constant = CGFloat(self.productData?.sizes.count ?? 0 > 5 ? 300 : (self.productData?.sizes.count ?? 0) * 55)
        self.view.updateConstraintsIfNeeded()
        self.view.layoutIfNeeded()
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
    
    //MARK: - UIButton Method Action
    @IBAction func btn_Close_Action(_ sender: UIControl) {
        self.close_animation()
    }
}

//MARK:- TableView Deleaget and Datasource
extension SelectQuantityVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productData?.sizes.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblSelectQuanity.dequeueReusableCell(withClass: SelectQuantityCell.self, for: indexPath)
        cell.selectionStyle = .none
        var prv_Price = ""
        cell.lbl_OutOfStock.text = ""
        cell.lbl_Prev_Price.isHidden = true
        
        let currentProductSize = self.productData?.sizes[indexPath.row] ?? ""
        cell.lbl_Size.text = currentProductSize
        cell.lbl_CurrentPrice.text = "₹ \(productData?.sizes_wise_price_in_int[indexPath.row] ?? 0)"
        
        cell.btnRadioSelection.setImage(selectedIndex == indexPath.row ? MP_appImage.img_RadioBox_selected : MP_appImage.img_RadioBox_unselected, for: .normal)
        
        cell.lbl_CurrentPrice.font = UIFont.systemFont(ofSize: 13, weight: selectedIndex == indexPath.row ? .semibold : .regular)
        
        cell.lbl_CurrentPrice.textColor = selectedIndex == indexPath.row ? UIColor.black : UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1.0)

        
        if self.productData?.sizes_wise_previous_price_in_int.count ?? 0 > 0 {
            cell.lbl_Prev_Price.isHidden = false
            prv_Price = "₹ \(productData?.sizes_wise_previous_price_in_int[indexPath.row] ?? 0)"
        }
        cell.setAttributeText(prv_Price)
        
        
        //Out of Stock Logic=================================================//
        var int_productQuentity: Int = Int(productData?.size_quantity[indexPath.row] ?? "0") ?? 0
        if int_productQuentity <= 0 {
            cell.lbl_OutOfStock.text = "Out of stock"
        }
        else {
            if int_productQuentity > 0 {
                
                if let arr_cartDetail = self.productData?.CART_DETAIL {
                    for dic_cart in arr_cartDetail {
                        let ADDED_SIZE = dic_cart.ADDED_SIZE
                        let ADDED_QUANTITY = dic_cart.ADDED_QUANTITY
                        if currentProductSize == ADDED_SIZE {
                            int_productQuentity = int_productQuentity - ADDED_QUANTITY
                        }
                    }
                }
                
                if int_productQuentity <= 0 {
                    cell.lbl_OutOfStock.text = "Out of stock"
                }
                
            }
        }
        //===================================================================//

        

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        self.tblSelectQuanity.reloadData()
        
        //Out of Stock Logic=================================================//
        let currentProductSize = self.productData?.sizes[indexPath.row] ?? ""
        var int_productQuentity: Int = Int(productData?.size_quantity[indexPath.row] ?? "0") ?? 0
        if int_productQuentity <= 0 {
            return
        }
        else {
            if int_productQuentity > 0 {
                
                if let arr_cartDetail = self.productData?.CART_DETAIL {
                    for dic_cart in arr_cartDetail {
                        let ADDED_SIZE = dic_cart.ADDED_SIZE
                        let ADDED_QUANTITY = dic_cart.ADDED_QUANTITY
                        if currentProductSize == ADDED_SIZE {
                            int_productQuentity = int_productQuentity - ADDED_QUANTITY
                        }
                    }
                }
                
                if int_productQuentity <= 0 {
                    return
                }
                
            }
        }
        //===================================================================//
        
        let cartData = MPCartData()
        cartData.sizes_key = "\(indexPath.row)"
        cartData.sizes = "\(productData?.sizes[indexPath.row] ?? "")"
        if productData?.sizes_wise_previous_price_in_int.count ?? 0 > indexPath.row {
            cartData.sizes_wise_previous_price = "\(productData?.sizes_wise_previous_price_in_int[indexPath.row] ?? 0)"
        }else{
            cartData.sizes_wise_previous_price = "0"
        }
        if productData?.sizes_wise_price_in_int.count ?? 0 > indexPath.row {
            cartData.sizes_wise_price = "\(productData?.sizes_wise_price_in_int[indexPath.row] ?? 0)"
        }else{
            cartData.sizes_wise_price = "0"
        }

        if productData?.colors.count ?? 0 > indexPath.row{
            cartData.color_code = productData?.colors[indexPath.row] ?? ""
        }

        cartData.discount = "\(productData?.DISCOUNT)"
        cartData.size_price = "\(productData?.size_price[indexPath.row] ?? "")"
        cartData.available_size_quantity = "\(productData?.size_quantity[indexPath.row] ?? "")"
        cartData.added_quantity = 1
        didTappedQuantity!(cartData)
        self.close_animation()
    }
}
