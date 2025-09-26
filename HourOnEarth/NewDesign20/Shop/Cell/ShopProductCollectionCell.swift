//
//  ShopProductCollectionCell.swift
//  HourOnEarth
//
//  Created by Apple on 05/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import AlamofireImage

class ShopProductCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var lblProductDesc: UILabel!
    @IBOutlet weak var lblPrice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureUI(dicCategory: [String: Any]) {
        self.lblProduct.text = dicCategory["name"] as? String ?? ""
        self.lblPrice.text =  "\(dicCategory["price"] as? Int ?? 0)"
        
        if let customAttributes = dicCategory["custom_attributes"] as? [[String: Any]] {
            for attributes in customAttributes {
                if let key = attributes["attribute_code"] as? String, key == "image" {
                    let imageUrl = attributes["value"] as? String ?? ""
                    self.imageProduct.imageFromServerURL(kBaseUrlShopImages + imageUrl, placeHolder: UIImage(named: "product3"))
                }
                
                if let key = attributes["attribute_code"] as? String, key == "description" {
                    let value = attributes["value"] as? String ?? ""
                    self.lblProductDesc.text = value
                }
            }
        }
    }

}
