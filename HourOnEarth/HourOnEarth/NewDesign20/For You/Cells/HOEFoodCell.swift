//
//  HOEFoodCell.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 12/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

class HOEFoodCell: UICollectionViewCell {
    
    // MARK: - UILabel @IBOutlet
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var btnLock: UIButton!
    
    var delegate: RecommendationSeeAllDelegate?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        foodImage.image = nil
    }
    
    func configureUI(foodType: FoodDemo) {
        lblTitle.text = foodType.foodType ?? ""
        lblSubTitle.text = ""
        guard let urlString = foodType.image, let url = URL(string: urlString) else {
            return
        }
        lockView.isHidden = true
        self.foodImage.af.setImage(withURL: url)
    }
    
    func configureUI(food: Food) {
        lblTitle.text = food.food_name ?? ""
        lblSubTitle.text = food.food_status?.capitalized ?? ""
        guard let urlString = food.image, let url = URL(string: urlString) else {
            return
        }
        lockView.isHidden = true
        self.foodImage.af.setImage(withURL: url)
    }
    
    func configureUI(foodFav: FavouriteFood) {
        lblTitle.text = foodFav.category ?? ""
        lblSubTitle.text = ""
        guard let urlString = foodFav.categoryimage, let url = URL(string: urlString) else {
            return
        }
        self.foodImage.af.setImage(withURL: url)
    }
    
    func configureUI(herb: Herb) {
        lblTitle.text = herb.herbs_name ?? ""
        lblSubTitle.text = ""
        guard let urlString = herb.image, let url = URL(string: urlString) else {
            return
        }
        lockView.isHidden = true
        self.foodImage.af.setImage(withURL: url)
    }
    
    func configureUI(herbType: HerbType) {
        lblTitle.text = herbType.herbs_types ?? ""
        lblSubTitle.text = ""
        guard let urlString = herbType.image, let url = URL(string: urlString) else {
            return
        }
        lockView.isHidden = true
        self.foodImage.af.setImage(withURL: url)
    }
    
    func configureUI(favouriteHerb: FavouriteHerb) {
        lblTitle.text = favouriteHerb.category ?? ""
        lblSubTitle.text = ""
        guard let urlString = favouriteHerb.categoryimage, let url = URL(string: urlString) else {
            return
        }
        self.foodImage.af.setImage(withURL: url)
    }

    @IBAction func lockClicked(_ sender: UIButton) {
        guard let indexPath = self.indexPath else {
            return
        }
        delegate?.didSelectedSelectRow(indexPath: indexPath, index: nil)
    }
}
