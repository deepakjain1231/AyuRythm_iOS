//
//  HOEHerbCell.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 12/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

class HOEHerbCell: UICollectionViewCell {
    
    // MARK: - UILabel @IBOutlet
    @IBOutlet weak var foodImage: UIImageView!
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
    
    func configureUI(herb: Herb) {
        guard let urlString = herb.image, let url = URL(string: urlString) else {
            return
        }
        lockView.isHidden = true
        self.foodImage.af.setImage(withURL: url)
    }
    
    func configureUI(herbType: HerbType) {
        guard let urlString = herbType.image, let url = URL(string: urlString) else {
            return
        }
        lockView.isHidden = true
        self.foodImage.af.setImage(withURL: url)
    }
    
    func configureUI(favouriteHerb: FavouriteHerb) {
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
