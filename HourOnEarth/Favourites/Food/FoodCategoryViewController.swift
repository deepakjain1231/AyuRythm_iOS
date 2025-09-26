//
//  FoodCategoryViewController.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 19/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import UIKit
import CoreData
import Alamofire

class FoodCategoryViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var constraintSearchHeight: NSLayoutConstraint!
    var dataArray = [FavouriteFood]()
    var dataArrayNew:[Favourite] = [Favourite]()

    private var filteredDataArray = [FavouriteFood] ()
    private var sendDataArray = [FavouriteFood] ()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Food".localized()
        constraintSearchHeight.constant = 0.0
       // navigationItem.title = headerTitle.isEmpty ? sectionType.title : headerTitle
        collectionview.register(UINib(nibName: "HOEFoodCell", bundle: nil), forCellWithReuseIdentifier: "HOEFoodCell")


                self.filteredDataArray = []
        
                for dict in dataArray
                {
                    if self.filteredDataArray.first(where: { $0.category == dict.category }) != nil {
                    }
                    else
                    {
                        self.filteredDataArray.append(dict)
                    }
                }
                
        //        self.filteredDataArray = dataArray
                collectionview.reloadData()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    //MARK: CollectionViewDataSource/Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEFoodCell", for: indexPath as IndexPath) as? HOEFoodCell else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
             let food = filteredDataArray[indexPath.row] 
            cell.configureUI(foodFav: food)
            return cell
            
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
//        guard let objFoodDetails = storyBoard.instantiateViewController(withIdentifier: "FoodDetailViewController") as? FoodDetailViewController else {
//            return
//        }
//        objFoodDetails.modalPresentationStyle = .fullScreen
//
//        objFoodDetails.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
//        objFoodDetails.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
//        objFoodDetails.dataFood = foodArray[index!]
//        self.present(objFoodDetails, animated: true, completion: nil)

        let storyBoard = UIStoryboard(name: "Favourites", bundle: nil)
        let favouriteDetail1VC = storyBoard.instantiateViewController(withIdentifier: "FoodListViewController") as! FoodListViewController
        favouriteDetail1VC.arrAllFoods = self.dataArrayNew[indexPath.item].favFood?.allObjects as! [FavouriteFood]
        self.navigationController?.pushViewController(favouriteDetail1VC, animated: true)

//        let food = filteredDataArray[indexPath.row]
//        let filteredArray = self.dataArray.filter({ (text) -> Bool in
//            let tmp: FavouriteFood = text
//            let strp : NSString = tmp.category! as NSString
//            let range = strp.range(of: food.category!, options: NSString.CompareOptions.caseInsensitive)
//            return range.location != NSNotFound
//        })
//        let storyBoard = UIStoryboard(name: "Favourites", bundle: nil)
//        let favouriteDetail1VC = storyBoard.instantiateViewController(withIdentifier: "FoodListViewController") as! FoodListViewController
//        favouriteDetail1VC.arrAllFoods = filteredArray
//        favouriteDetail1VC.navigationTitle = food.category ?? ""
//        self.navigationController?.pushViewController(favouriteDetail1VC, animated: true)
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 30
            let collectionViewSize = collectionView.frame.size.width - padding
            return CGSize(width: collectionViewSize/2, height: collectionViewSize/2 - 20)
      
    }
}
