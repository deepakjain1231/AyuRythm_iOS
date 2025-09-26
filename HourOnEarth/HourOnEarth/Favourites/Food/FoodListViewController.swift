//
//  FoodListViewController.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 19/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import CoreData

class FoodListViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var arrAllFoods = [NSManagedObject]()
    var navigationTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = navigationTitle
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrAllFoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellFood = collectionView.dequeueReusableCell(withReuseIdentifier: "foodCell", for: indexPath) as? FoodCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let item = arrAllFoods[indexPath.item] as? FavouriteFood {
            let foodName = item.food_name ?? ""
            let imageName = item.image
            cellFood.configureFoodCell(foodName: foodName, image: imageName)
        } else if let item = arrAllFoods[indexPath.item] as? FavouriteHerb {
            let foodName = item.herbs_name ?? ""
            let imageName = item.image
            cellFood.configureFoodCell(foodName: foodName, image: imageName)
        }
        return cellFood
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let item = arrAllFoods[indexPath.item] as? FavouriteFood {
            //show food detail screen
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objFoodDetails = storyBoard.instantiateViewController(withIdentifier: "FoodDetailViewController") as? FoodDetailViewController else {
                return
            }
            objFoodDetails.modalPresentationStyle = .fullScreen
            
            //objFoodDetails.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
            //objFoodDetails.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
            objFoodDetails.isFromFav = true
            objFoodDetails.dataFoodFav = item
            self.present(objFoodDetails, animated: true, completion: nil)
        } else if let item = arrAllFoods[indexPath.item] as? FavouriteHerb {
            //show herb detail screen
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let herbDetails = storyBoard.instantiateViewController(withIdentifier: "HerbDetailViewController") as? HerbDetailViewController else {
                return
            }
            herbDetails.modalPresentationStyle = .fullScreen

//            herbDetails.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
//            herbDetails.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
            herbDetails.favHerbDetail = item
            self.present(herbDetails, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGFloat = (kDeviceWidth - 40) / 3.0
        return CGSize(width: size, height: size)
    }
    
    
}
