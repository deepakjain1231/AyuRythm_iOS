//
//  FavouritesViewController.swift
//  HourOnEarth
//
//  Created by Debu on 05/03/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class FavouritesViewController: BaseViewController {
    
    @IBOutlet weak var view_noData: UIView!
    @IBOutlet weak var favouritesCollectionView: UICollectionView!
    var arrFavData:[Favourite] = [Favourite]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view_noData.isHidden = true
        self.favouritesCollectionView.register(UINib(nibName: "FavouritesViewCompactListCell", bundle: nil), forCellWithReuseIdentifier: "favCompactList")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
        Utils.startActivityIndicatorInView(self.view, userInteraction: true)
        self.getFavFromServer {
            self.getFavouriteFromDB()
            Utils.stopActivityIndicatorinView(self.view)
        }
    }
}

extension FavouritesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFavData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favCompactList", for: indexPath) as! FavouritesCell
        let type = self.arrFavData[indexPath.item].favourite_type ?? ""
        cell.favTypeLbl.text = self.titleFor(type: type)
        cell.noOfItemsLbl.text = "\(self.arrFavData[indexPath.item].count) " + "items"
        cell.img3.image = self.getImagesFor(type: self.arrFavData[indexPath.item].favourite_type ?? "")
        return cell
    }
    
    func getImagesFor(type: String) -> UIImage? {
        if type == "Yoga" {
            return UIImage(named: "yogaFav")
        }
        else if type == "Meditation" {
            return UIImage(named: "meditation")
        }
        else if type == "Pranayama" {
            return UIImage(named: "pranayama")
        }
        else if type == "Mudras" {
            return UIImage(named: "mudras")
        }
        else if type == "Kriyas" {
            return UIImage(named: "kriyas")
        }
        else if type == "Food" {
            return UIImage(named: "food")
        }
        else if type == "Herbs" {
            return UIImage(named: "fav-herbs")
        }
        else {
            return UIImage(named: "home-remediesFav")
        }
    }
    
    func titleFor(type: String) -> String {
        if type == "Yoga" {
            return "Yoga".localized()
        }
        else if type == "Meditation" {
            return "Meditation".localized()
        }
        else if type == "Pranayama" {
            return "Pranayama".localized()
        }
        else if type == "Mudras" {
            return "Mudras".localized()
        }
        else if type == "Kriyas" {
            return "Kriyas".localized()
        }
        else if type == "Food" {
            return "Food".localized()
        }
        else if type == "Herbs" {
            return "Herbs".localized()
        }
        else {
            return "Home Remedies".localized()
        }
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = self.arrFavData[indexPath.item].favourite_type ?? ""
        if type == "Yoga" {
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "HOEYogaListVC") as? HOEYogaListVC else {
                return
            }
            objFoodView.dataArray = self.arrFavData[indexPath.item].favYoga?.allObjects as! [NSManagedObject]
            objFoodView.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
            objFoodView.recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
            objFoodView.sectionType = .yogaFavourite
            objFoodView.isStatusVisible = true
            self.navigationController?.pushViewController(objFoodView, animated: true)
        }
        else if type == "Meditation" {
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "HOEYogaListVC") as? HOEYogaListVC else {
                return
            }
            
            objFoodView.dataArray = self.arrFavData[indexPath.item].favMeditation?.allObjects as! [NSManagedObject]

            objFoodView.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
            objFoodView.recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
            objFoodView.sectionType = .meditationFavourite
            objFoodView.isStatusVisible = true
            self.navigationController?.pushViewController(objFoodView, animated: true)
        }
        else if type == "Pranayama" {
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "HOEYogaListVC") as? HOEYogaListVC else {
                return
            }
            objFoodView.dataArray = self.arrFavData[indexPath.item].favPranayama?.allObjects as! [NSManagedObject]
            objFoodView.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
            objFoodView.recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
            objFoodView.sectionType = .pranayamaFavourite
            objFoodView.isStatusVisible = true
            self.navigationController?.pushViewController(objFoodView, animated: true)
        }
        else if type == "Mudras" {
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "HOEYogaListVC") as? HOEYogaListVC else {
                return
            }
            objFoodView.dataArray = self.arrFavData[indexPath.item].favMudra?.allObjects as! [NSManagedObject]
            objFoodView.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
            objFoodView.recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
            objFoodView.sectionType = .mudraFavourite
            objFoodView.isStatusVisible = true
            self.navigationController?.pushViewController(objFoodView, animated: true)
        }
        else if type == "Kriyas" {
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "HOEYogaListVC") as? HOEYogaListVC else {
                return
            }
            objFoodView.dataArray = self.arrFavData[indexPath.item].favKriya?.allObjects as! [NSManagedObject]
            objFoodView.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
            objFoodView.recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
            objFoodView.sectionType = .kriyaFavourite
            objFoodView.isStatusVisible = true
            self.navigationController?.pushViewController(objFoodView, animated: true)
        }
        else if type == "Food" {
            let storyBoard = UIStoryboard(name: "Favourites", bundle: nil)
            let favouriteDetail1VC = storyBoard.instantiateViewController(withIdentifier: "FoodListViewController") as! FoodListViewController
            favouriteDetail1VC.arrAllFoods = self.arrFavData[indexPath.item].favFood?.allObjects as! [FavouriteFood]
//            let favouriteDetail1VC = storyBoard.instantiateViewController(withIdentifier: "FoodCategoryViewController") as! FoodCategoryViewController
//            favouriteDetail1VC.dataArray = self.arrFavData[indexPath.item].favFood?.allObjects as! [FavouriteFood]
//            favouriteDetail1VC.dataArrayNew = self.arrFavData
            self.navigationController?.pushViewController(favouriteDetail1VC, animated: true)
        }
        else if type == "Herbs" {
            let storyBoard = UIStoryboard(name: "Favourites", bundle: nil)
            let favouriteDetail1VC = storyBoard.instantiateViewController(withIdentifier: "FoodListViewController") as! FoodListViewController
            favouriteDetail1VC.arrAllFoods = self.arrFavData[indexPath.item].favHerb?.allObjects as! [FavouriteHerb]
            self.navigationController?.pushViewController(favouriteDetail1VC, animated: true)
        }
        else {
            let storyBoard = UIStoryboard(name: "Favourites", bundle: nil)
            let favouriteDetail1VC = storyBoard.instantiateViewController(withIdentifier: "FavouriteDetails1ViewController") as! FavouriteDetails1ViewController
            favouriteDetail1VC.remediesArray = self.arrFavData[indexPath.item].favRemedies?.allObjects as! [FavouriteHomeRemedies]
            self.navigationController?.pushViewController(favouriteDetail1VC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:UIScreen.main.bounds.width, height:112)
    }
    
    func getFavFromServer (completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.v2.getfetchFavouriteIOS.rawValue
            let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success(let value):
                    guard let arrResponse = (value as? [[String: Any]]) else {
                        completion()
                        return
                    }
                    print(arrResponse)
                    CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Favourite")
                    Favourite.createFavouriteData(arrData: arrResponse)
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                completion()
            }
        }else {
            completion()
           // Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func getFavouriteFromDB() {
        guard let arrFavData = CoreDataHelper.sharedInstance.getListOfEntityWithName("Favourite", withPredicate: nil, sortKey: nil, isAscending: false) as? [Favourite] else {
            return
        }
        self.arrFavData = arrFavData.sorted(by: { (data1, data2) -> Bool in
            data1.favourite_type ?? "" > data2.favourite_type ?? ""
        })
        var arrTemp = self.arrFavData
        arrTemp.removeAll()
        for dict in self.arrFavData {
            if dict.count != 0 {
                arrTemp.append(dict)
            }
        }
        self.arrFavData = arrTemp
        self.view_noData.isHidden = self.arrFavData.count == 0 ? false : true
        self.favouritesCollectionView.reloadData()
    }
}
