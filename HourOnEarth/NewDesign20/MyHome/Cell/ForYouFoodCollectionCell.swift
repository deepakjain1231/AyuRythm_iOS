//
//  ForYouFoodCollectionCell.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 02/10/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

class ForYouFoodCollectionCell: UICollectionViewCell {

    // MARK: - UILabel @IBOutlet
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var btnLock: UIButton!

    var delegate: RecommendationSeeAllDelegate?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.foodImage.layer.cornerRadius = 12.0;
        self.foodImage.clipsToBounds = true
        self.foodImage.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        foodImage.image = nil
    }
        
    func configureUI(foodType: FoodDemo) {
        foodImage.contentMode = .scaleAspectFill
        lblTitle.text = foodType.foodType ?? ""
        guard let urlString = foodType.image, let url = URL(string: urlString) else {
            return
        }
        lockView.isHidden = true
        self.foodImage.af.setImage(withURL: url)
    }

    func configureUI(food: Food) {
        foodImage.contentMode = .scaleAspectFill
        lblTitle.text = food.food_name ?? ""
        guard let urlString = food.image, let url = URL(string: urlString) else {
            return
        }
        lockView.isHidden = true
        self.foodImage.af.setImage(withURL: url)
    }

    func configureUI(foodFav: FavouriteFood) {
        foodImage.contentMode = .scaleAspectFill
        lblTitle.text = foodFav.category ?? ""
        guard let urlString = foodFav.categoryimage, let url = URL(string: urlString)
        else {
            return
        }
        self.foodImage.af.setImage(withURL: url)
    }

    func configureUI(herb: Herb) {
        foodImage.contentMode = .scaleAspectFit
        lblTitle.text = herb.herbs_name ?? ""
        guard let urlString = herb.image, let url = URL(string: urlString) else {
            return
        }
        lockView.isHidden = true
        self.foodImage.af.setImage(withURL: url)
    }

    func configureUI(herbType: HerbType) {
        foodImage.contentMode = .scaleAspectFit
        lblTitle.text = herbType.herbs_types ?? ""
        
        guard let urlString = herbType.image, let url = URL(string: urlString) else {
            return
        }
        lockView.isHidden = true
        self.foodImage.af.setImage(withURL: url)
    }
        
    func configureUI(favouriteHerb: FavouriteHerb) {
        foodImage.contentMode = .scaleAspectFit
        lblTitle.text = favouriteHerb.category ?? ""
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
