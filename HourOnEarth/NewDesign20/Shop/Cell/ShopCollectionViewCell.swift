//
//  ShopCollectionViewCell.swift
//  HourOnEarth
//
//  Created by hardik mulani on 13/02/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import AlamofireImage

class ShopCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var _img: UIImageView!
    @IBOutlet weak var lblProduct: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureUI(dicCategory: [String: Any]) {
        self.lblProduct.text = dicCategory["name"] as? String ?? ""
        let imageUrl = dicCategory["image"] as? String ?? ""
        self._img.imageFromServerURL(imageUrl, placeHolder: UIImage(named: "product3"))
    }
}
