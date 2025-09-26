//
//  ARWellnessPlanDietItemCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 25/04/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARWellnessPlanDietItemCell: UITableViewCell {
    
    var arr_benifits_tag = [String]()
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var infoL: UILabel!
    @IBOutlet weak var lbl_calories: UILabel!
    @IBOutlet weak var view_top: UIView!
    @IBOutlet weak var img_veg_nonveg: UIImageView!
    @IBOutlet weak var view_bottom: UIView!
    @IBOutlet weak var view_Timing: UIView!
    @IBOutlet weak var lbl_Timing: UILabel!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var constraint_view_Top: NSLayoutConstraint!
    @IBOutlet weak var constraint_Stackview_Top: NSLayoutConstraint!
    @IBOutlet weak var constraint_Stackview_Bottom: NSLayoutConstraint!
    @IBOutlet weak var lbl_underline: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageIV.image = nil
    }
    
    var dietItem: ARDietItemModel? {
        didSet {
            guard let dietItem = dietItem else { return }
            imageIV.af_setImage(withURLString: dietItem.image)
            nameL.text = dietItem.name
            
            var str_kcal = dietItem.calary
            if dietItem.calary == "" {
                str_kcal = "0 Kcal"
            }
            else {
                str_kcal = "\(str_kcal) Kcal"
            }
            lbl_calories.text = str_kcal
            
            
            if dietItem.food_type != "Vegetarian" {
                self.img_veg_nonveg.image = UIImage.init(named: "icon_nonveg")
            }
            else {
                self.img_veg_nonveg.image = UIImage.init(named: "icon_veg")
            }

            if !dietItem.info.isEmpty {
                self.infoL.isHidden = false
                infoL.text = "(" + dietItem.info + ")"
                self.constraint_Stackview_Top.constant = 5
                self.constraint_Stackview_Bottom.constant = 16
            } else {
                infoL.text = dietItem.info
                self.infoL.isHidden = true
                self.constraint_Stackview_Top.constant = 5
                self.constraint_Stackview_Bottom.constant = 25
            }
            let str_benifits = dietItem.food_tags
            self.arr_benifits_tag = str_benifits.components(separatedBy: ",")
        }
    }
}

