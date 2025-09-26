//
//  FoodDetailsCell.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 18/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import CoreData

protocol FoodDetailsDelegate: class {
    func starClicked()
    func cancelClicked()
    func shareClickedwith(hindiName: String, enName: String, desc: String) // Added by Aakash
}


class FoodDetailsCell: UITableViewCell {

    @IBOutlet weak var lblEnglishName: UILabel!
    @IBOutlet weak var btnFavoutite: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    weak var delegate: FoodDetailsDelegate?

    @IBOutlet weak var imgSeasons1: UIImageView!
    @IBOutlet weak var imgSeasons2: UIImageView!
    @IBOutlet weak var imgSeasons3: UIImageView!
    @IBOutlet weak var imgSeasons4: UIImageView!
    @IBOutlet weak var imgSeasons5: UIImageView!
    @IBOutlet weak var imgSeasons6: UIImageView!

    @IBOutlet weak var imgBTE1: UIImageView!
    @IBOutlet weak var imgBTE2: UIImageView!
    @IBOutlet weak var imgBTE3: UIImageView!
    @IBOutlet weak var imgBTE4: UIImageView!
    @IBOutlet weak var imgBTE5: UIImageView!
    @IBOutlet weak var imgBTE6: UIImageView!
    @IBOutlet weak var lblBenifites: UILabel!
    @IBOutlet weak var lblProperties: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblPV: UILabel!
    @IBOutlet weak var benifitesStackView: UIStackView!
    @IBOutlet weak var propertiesStackView: UIStackView!

    @IBOutlet weak var constraintSeasonsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constraintBestEatHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureUIFood(food: Food, isFavourite: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
       btnFavoutite.isSelected = isFavourite
        btnFavoutite.isHidden = food.food_status == "favor" ? false : true
        lblEnglishName.text = food.food_name
        let arrSeasons = food.seasons?.allObjects as! [Seasons]
        
        let arrWhen_to_eat = food.when_to_eat?.allObjects as! [When_to_eat]
        
        #if APPCLIP
        // Code your app clip may access.
        btnShare.isHidden = true
        btnFavoutite.isHidden = true
        #endif
        
        //constraintSeasonsHeight.constant = arrSeasons.count <= 3 ? 0 : 50
        // constraintBestEatHeight.constant = arrWhen_to_eat.count <= 3 ? 0 : 50
        var count = 0
        for arrCount in arrSeasons
        {
            if count == 0
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgSeasons1.af.setImage(withURL: url)
            }
            else if count == 1
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgSeasons2.af.setImage(withURL: url)
                
            }
            else if count == 2
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgSeasons3.af.setImage(withURL: url)
                
            }
            else if count == 3
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgSeasons4.af.setImage(withURL: url)
                
            }
            else if count == 4
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgSeasons5.af.setImage(withURL: url)
            }
            count += 1
        }
        
        var count1 = 0
        for arrCount in arrWhen_to_eat
        {
            if count1 == 0
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgBTE1.af.setImage(withURL: url)
            }
            else if count1 == 1
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgBTE2.af.setImage(withURL: url)
                
            }
            else if count1 == 2
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgBTE3.af.setImage(withURL: url)
                
            }
            else if count1 == 3
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgBTE4.af.setImage(withURL: url)
                
            }
            count1 += 1
        }
        
        if let types = food.item_type?.components(separatedBy: ","){
            if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                lblPV.text = "Prakriti/Vikriti".localized()
            } else if types.contains(recPrakriti.rawValue) {
                lblPV.text = "Prakriti".localized()
            } else if types.contains(recVikriti.rawValue) {
                lblPV.text = "Vikriti".localized()
            }
        }
        
        if let properies = food.food_properties, !properies.isEmpty {
            let textArray = properies.components(separatedBy: ",")
            lblProperties.setBulletListedAttributedText(stringList: textArray, bullet: "-")
            propertiesStackView.isHidden = false
        } else {
            lblProperties.attributedText = NSAttributedString(string: "-")
            propertiesStackView.isHidden = true
        }
        if let benefits = food.benefits, !benefits.isEmpty {
            let textArray = benefits.components(separatedBy: ",")
            lblDescription.setBulletListedAttributedText(stringList: textArray, bullet: "-")
            benifitesStackView.isHidden = false
        } else {
            lblDescription.attributedText = NSAttributedString(string: "-")
            benifitesStackView.isHidden = true
        }
        guard let urlString = food.vertical_image, let url = URL(string: urlString) else { return }
        imgView.af.setImage(withURL: url)
    }
    
    func configureUIFoodFav(food: FavouriteFood, isFavourite: Bool, recPrakriti: RecommendationType, recVikriti: RecommendationType) {
        btnFavoutite.isSelected = isFavourite
        btnFavoutite.isHidden = food.food_status == "favor" ? false : true
        lblEnglishName.text = food.food_name
        let arrSeasons = food.seasons?.allObjects as! [Seasons]
        
        let arrWhen_to_eat = food.when_to_eat?.allObjects as! [When_to_eat]
        
        // constraintSeasonsHeight.constant = arrSeasons.count <= 3 ? 0 : 50
        // constraintBestEatHeight.constant = arrWhen_to_eat.count <= 3 ? 0 : 50
        var count = 0
        for arrCount in arrSeasons
        {
            if count == 0
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgSeasons1.af.setImage(withURL: url)
            }
            else if count == 1
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgSeasons2.af.setImage(withURL: url)
                
            }
            else if count == 2
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgSeasons3.af.setImage(withURL: url)
                
            }
            else if count == 3
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgSeasons4.af.setImage(withURL: url)
                
            }
            else if count == 4
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgSeasons5.af.setImage(withURL: url)
            }
            count += 1
        }
        
        var count1 = 0
        for arrCount in arrWhen_to_eat
        {
            if count1 == 0
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgBTE1.af.setImage(withURL: url)
            }
            else if count1 == 1
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgBTE2.af.setImage(withURL: url)
                
            }
            else if count1 == 2
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgBTE3.af.setImage(withURL: url)
                
            }
            else if count1 == 3
            {
                guard let urlString = arrCount.image, let url = URL(string: urlString) else {
                    return
                }
                imgBTE4.af.setImage(withURL: url)
                
            }
            count1 += 1
        }
        
        if let types = food.item_type?.components(separatedBy: ","){
            if types.contains(recPrakriti.rawValue) && types.contains(recVikriti.rawValue) {
                lblPV.text = "Prakriti/Vikriti".localized()
            } else if types.contains(recPrakriti.rawValue) {
                lblPV.text = "Prakriti".localized()
            } else if types.contains(recVikriti.rawValue) {
                lblPV.text = "Vikriti".localized()
            }
        }
        
        if let properies = food.food_properties, !properies.isEmpty {
            let textArray = properies.components(separatedBy: ",")
            lblProperties.setBulletListedAttributedText(stringList: textArray, bullet: "-")
            propertiesStackView.isHidden = false
        } else {
            lblProperties.attributedText = NSAttributedString(string: "-")
            propertiesStackView.isHidden = true
        }
        if let benefits = food.benefits, !benefits.isEmpty {
            let textArray = benefits.components(separatedBy: ",")
            lblDescription.setBulletListedAttributedText(stringList: textArray, bullet: "-")
            benifitesStackView.isHidden = false
        } else {
            lblDescription.attributedText = NSAttributedString(string: "-")
            benifitesStackView.isHidden = true
        }
        guard let urlString = food.vertical_image, let url = URL(string: urlString) else { return }
        imgView.af.setImage(withURL: url)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func starClicked(_ sender: UIButton) {
        delegate?.starClicked()
    }
    
    @IBAction func dismissClicked(_ sender: UIButton) {
        delegate?.cancelClicked()
    }
    
    // Added by Aakash
    @IBAction func shareClicked(_ sender: UIButton) {
        delegate?.shareClickedwith(hindiName: self.lblEnglishName.text ?? "", enName: self.lblEnglishName.text ?? "", desc: lblDescription.text ?? "")
    }
}
