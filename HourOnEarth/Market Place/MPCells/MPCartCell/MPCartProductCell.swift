//
//  MPCartProductCell.swift
//  HourOnEarth
//
//  Created by CodeInfoWay CodeInfoWay on 6/26/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class MPCartProductCell: UITableViewCell {

    var current_vc = UIViewController()
    @IBOutlet weak var view_DefaultBG: UIView!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var img_product: UIImageView!
    @IBOutlet weak var view_img_productBG: UIView!
    @IBOutlet weak var lbl_off: UILabel!
    @IBOutlet weak var lbl_old_Price: UILabel!
    @IBOutlet weak var lbl_currentPrice: UILabel!
    @IBOutlet weak var lbl_Quantity: UILabel!
    @IBOutlet weak var btn_Remove: UIButton!
    @IBOutlet weak var btn_AddToFavourite: UIButton!
    @IBOutlet weak var lblEstDeliveryTime: UILabel!
    @IBOutlet weak var viewRemoveBackground: UIView!
    @IBOutlet weak var btn_Plus: UIButton!
    @IBOutlet weak var btn_Minus: UIButton!
    @IBOutlet weak var lbl_outOfStockProduct: UILabel!
    @IBOutlet weak var constraint_img_Height: NSLayoutConstraint!
    
    var addedSizeQuentity = 0
    var availableSizeQuentity = 0
    var productData: MPProductData?
    var completioCountUpdate: ((Int, Bool) -> ())?
    var completioRemove: ((Bool) -> ())?
    var completioAddToFav: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeAction(_ sender: UIButton){
        MPCartManager.removeCartSingleProduct(product: productData!, current_vc: self.current_vc, productRandomId: productData?.cartData?.random_id ?? "")
        completioRemove!(true)
    }
    
    @IBAction func addToFavAction(_ sender: UIButton){
        self.completioAddToFav!()
    }
    
    @IBAction func plusAction(_ sender: UIButton) {
        self.addedSizeQuentity = self.productData?.cartData?.added_quantity ?? 0
        self.availableSizeQuentity = Int(self.productData?.cartData?.available_size_quantity ?? "0") ?? 0
        if self.availableSizeQuentity > 0 {
            qtyCounter(increment: true)
        }
    }
    
    @IBAction func minusAction(_ sender: UIButton) {
        self.addedSizeQuentity = self.productData?.cartData?.added_quantity ?? 0
        self.availableSizeQuentity = Int(self.productData?.cartData?.available_size_quantity ?? "0") ?? 0
        
        if self.addedSizeQuentity <= 1{
            MPCartManager.removeCartSingleProduct(product: productData!, current_vc: self.current_vc, productRandomId: productData?.cartData?.random_id ?? "")
            completioRemove!(true)
        }else{
            qtyCounter(increment: false)
        }
    }
    
    func qtyCounter(increment: Bool) {
        self.current_vc.showActivityIndicator()
        MPCartManager.updateQuantity(productData: productData!, isIncrease: increment) { count in
            self.current_vc.hideActivityIndicator()
            self.lbl_Quantity.text = "\(count)"
            self.completioCountUpdate!(count, increment)
            self.productData?.cartData?.added_quantity = count
            if increment {
                self.productData?.cartData?.available_size_quantity = "\(self.addedSizeQuentity + 1)"
                self.productData?.cartData?.available_size_quantity = "\(self.availableSizeQuentity - 1)"
            }
            else {
                self.productData?.cartData?.available_size_quantity = "\(self.addedSizeQuentity - 1)"
                self.productData?.cartData?.available_size_quantity = "\(self.availableSizeQuentity + 1)"
            }
            self.checkCountToDisplayDeleteIcon()
        }
    }
    
    func checkCountToDisplayDeleteIcon() {
        if self.productData?.cartData?.added_quantity ?? 0 <= 1{
            self.btn_Minus.setImage(UIImage (named: "icon_trash"), for: .normal)
            self.btn_Minus.setTitle("", for: .normal)
        }else{
            self.btn_Minus.setImage(UIImage (named: ""), for: .normal)
            self.btn_Minus.setTitle("-", for: .normal)
        }
    }
}
