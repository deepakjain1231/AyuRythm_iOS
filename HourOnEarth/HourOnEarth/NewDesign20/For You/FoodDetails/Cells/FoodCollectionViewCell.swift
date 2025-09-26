//
//  FoodCollectionViewCell.swift
//  HourOnEarth
//
//  Created by Pradeep on 29/05/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class FoodCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgViewFood: UIImageView!
    @IBOutlet weak var lblFoodName: UILabel!
    @IBOutlet weak var selectionBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureFoodCell(foodName: String, image: String?) {
        imgViewFood.image = UIImage(named: "")
        if let urlString = image, let url = URL(string: urlString)
        {
            imgViewFood.af.setImage(withURL: url)
        }
        lblFoodName.text = foodName
    }
    
    func setCornerRadius() {
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentView.layer.masksToBounds = true
    }
}
