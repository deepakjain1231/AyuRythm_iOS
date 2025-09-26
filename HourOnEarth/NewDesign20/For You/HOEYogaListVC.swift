//
//  HOEYogaListVC.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 12/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class HOEYogaListVC: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var constraintSearchHeight: NSLayoutConstraint!

    var dataArray = [NSManagedObject]()
    var sectionType : ForYouSectionType = .food
    var recommendationVikriti: RecommendationType = .kapha
    var recommendationPrakriti: RecommendationType = .kapha
    var isStatusVisible = true
    var isFromHome = false
    var headerTitle: String = ""
    var isFromAyuverseContentLibrary = false

    private var filteredDataArray = [NSManagedObject] ()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let rightButtonItem = UIBarButtonItem(image: UIImage(named: "invalidName_menu"), style: .plain, target: self, action: #selector(rightButtonAction(sender:)))
//        self.navigationItem.rightBarButtonItem = rightButtonItem
        if sectionType == .food {
            constraintSearchHeight.constant = 0.0
        }
        
        navigationItem.title = headerTitle.isEmpty ? sectionType.title : headerTitle
        setBackButtonTitle()
        
        collectionview.register(UINib(nibName: "HOEYogaCell", bundle: nil), forCellWithReuseIdentifier: "HOEYogaCell")
        collectionview.register(UINib(nibName: "HOEFoodCell", bundle: nil), forCellWithReuseIdentifier: "HOEFoodCell")
        collectionview.register(UINib(nibName: "HOEHerbCell", bundle: nil), forCellWithReuseIdentifier: "HOEHerbCell")

        self.filteredDataArray = dataArray
        collectionview.reloadData()
        
        recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        
        switch self.sectionType {
        case .yoga:
            searchBar.placeholder = "Yogasanas".localized()
        case .food:
            searchBar.placeholder = "Food".localized()
        case .yogaFavourite:
            searchBar.placeholder = "Yogasanas".localized()
        case .meditationFavourite:
            searchBar.placeholder = "Meditation".localized()
        case .pranayamaFavourite:
            searchBar.placeholder = "Pranayama".localized()
        case .mudraFavourite:
            searchBar.placeholder = "Mudras".localized()
        case .kriyaFavourite:
            searchBar.placeholder = "Kriyas".localized()
        case .herbs:
            searchBar.placeholder = "Herbs".localized()
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
        
        switch sectionType {
        case .food:
            if isFromHome {
                getFoodFromServer { }
            }
        case .herbs:
            if isFromHome {
                getHerbTypesFromServer { }
            }
        case .yoga:
            break
        case .yogaFavourite:
            break
        case .meditationFavourite:
            break
        case .pranayamaFavourite:
            break
        case .mudraFavourite:
            break
        case .kriyaFavourite:
            break
       
        default:
            break
        }
    }
    
    //MARK: Actions
    @objc func rightButtonAction(sender: UIBarButtonItem) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objFilterView = storyBoard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController else {
            return
        }
        objFilterView.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(objFilterView, animated: true)
        //present(objFilterView, animated: true, completion: nil)
    }
    
    //MARK: CollectionViewDataSource/Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch self.sectionType {
        case .yoga:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath as IndexPath) as? HOEYogaCell else {
                return UICollectionViewCell()
            }
            guard let yoga = filteredDataArray[indexPath.row] as? Yoga else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.btnLock.tag = indexPath.row
            cell.configureUI(yoga: yoga, isStatusVisible: isStatusVisible, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti )
            return cell
            
        case .food:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEFoodCell", for: indexPath as IndexPath) as? HOEFoodCell else {
                return UICollectionViewCell()
            }
            guard let food = filteredDataArray[indexPath.row] as? FoodDemo else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.btnLock.tag = indexPath.row
            cell.configureUI(foodType: food)
            return cell
            
        case .herbs:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEHerbCell", for: indexPath as IndexPath) as? HOEHerbCell else {
                return UICollectionViewCell()
            }
            guard let herbType = filteredDataArray[indexPath.row] as? HerbType else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.btnLock.tag = indexPath.row
            cell.configureUI(herbType: herbType)
            return cell
            
        case .yogaFavourite:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath as IndexPath) as? HOEYogaCell else {
                return UICollectionViewCell()
            }
            guard let yoga = filteredDataArray[indexPath.row] as? FavouriteYoga else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.btnLock.tag = indexPath.row
            cell.configureUI(yoga: yoga, isStatusVisible: isStatusVisible, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti )
            return cell
            
            case .meditationFavourite:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath as IndexPath) as? HOEYogaCell else {
                    return UICollectionViewCell()
                }
                guard let meditation = filteredDataArray[indexPath.row] as? FavouriteMeditation else {
                    return UICollectionViewCell()
                }
                cell.lockView.isHidden = true
                cell.btnLock.tag = indexPath.row
                cell.configureUIMeditationFav(meditation: meditation, isStatusVisible: isStatusVisible, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti )
                return cell

            case .pranayamaFavourite:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath as IndexPath) as? HOEYogaCell else {
                    return UICollectionViewCell()
                }
                guard let pranayama = filteredDataArray[indexPath.row] as? FavouritePranayama else {
                    return UICollectionViewCell()
                }
                cell.lockView.isHidden = true
                cell.btnLock.tag = indexPath.row
                cell.configureUIPranayamaFav(Pranayama: pranayama, isStatusVisible: isStatusVisible, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti )
                return cell

            case .mudraFavourite:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath as IndexPath) as? HOEYogaCell else {
                    return UICollectionViewCell()
                }
                guard let mudra = filteredDataArray[indexPath.row] as? FavouriteMudra else {
                    return UICollectionViewCell()
                }
                cell.lockView.isHidden = true
                cell.configureUIMudraFav(mudra: mudra, isStatusVisible: isStatusVisible, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti )
                return cell

            case .kriyaFavourite:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEYogaCell", for: indexPath as IndexPath) as? HOEYogaCell else {
                    return UICollectionViewCell()
                }
                guard let kriya = filteredDataArray[indexPath.row] as? FavouriteKriya else {
                    return UICollectionViewCell()
                }
                cell.lockView.isHidden = true
                cell.btnLock.tag = indexPath.row
                cell.configureUIKriyaFav(kriya: kriya, isStatusVisible: isStatusVisible, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti )
                return cell

            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 30
        switch sectionType {
        case .yoga, .yogaFavourite, .kriyaFavourite, .meditationFavourite, .mudraFavourite, .pranayamaFavourite:
            let collectionViewSize = collectionView.frame.size.width - padding
            let width = collectionViewSize/2
            return CGSize(width: width, height: (width < 190 ? 190 : width))
            
        case .food, .herbs:
            let collectionViewSize = collectionView.frame.size.width - padding
            return CGSize(width: collectionViewSize/2, height: collectionViewSize/2 - 20)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch sectionType {
        case .yoga, .yogaFavourite:
            let yoga = filteredDataArray[indexPath.item]
            yogaSelectedAtIndex(index: indexPath.item, yoga: yoga)
        case .meditationFavourite:
            let yoga = filteredDataArray[indexPath.item]
            meditationSelectedAtIndex(index: indexPath.item, yoga: yoga)
            case .pranayamaFavourite:
                let yoga = filteredDataArray[indexPath.item]
                pranayamaSelectedAtIndex(index: indexPath.item, yoga: yoga)
            case .kriyaFavourite:
                let yoga = filteredDataArray[indexPath.item]
                kriyaSelectedAtIndex(index: indexPath.item, yoga: yoga)
            case .mudraFavourite:
                let yoga = filteredDataArray[indexPath.item]
                mudraSelectedAtIndex(index: indexPath.item, yoga: yoga)

        case .food:
            foodSelectedAtIndex(index: indexPath.item)
        case .herbs:
            herbSelectedAtIndex(index: indexPath.item)
        default:
            break
        }
    }
    
    func foodSelectedAtIndex(index: Int) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "FoodsViewController") as? FoodsViewController else {
            return
        }
        guard let foodDemo = filteredDataArray[index] as? FoodDemo else {
            return
        }
        objFoodView.type = self.recommendationVikriti
        objFoodView.selectedType = foodDemo.foodType ?? ""
        objFoodView.selectedId = Int(foodDemo.id)
        objFoodView.isFromAyuverseContentLibrary = isFromAyuverseContentLibrary
        self.navigationController?.pushViewController(objFoodView, animated: true)
    }
    
    func herbSelectedAtIndex(index: Int) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let herbType = filteredDataArray[index] as? HerbType, let vc = storyBoard.instantiateViewController(withIdentifier: "HerbsViewController") as? HerbsViewController else {
            return
        }
        vc.type = self.recommendationVikriti
        vc.selectedType = herbType.herbs_types ?? ""
        vc.selectedId = Int(herbType.id)
        vc.isFromAyuverseContentLibrary = isFromAyuverseContentLibrary
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func yogaSelectedAtIndex(index: Int, yoga: NSManagedObject) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.yoga = yoga
        objYoga.recommendationVikriti = self.recommendationVikriti
        objYoga.recommendationPrakriti = self.recommendationPrakriti
        objYoga.isFromForYou = false
        objYoga.istype = .yoga

        self.present(objYoga, animated: true, completion: nil)
    }
    func meditationSelectedAtIndex(index: Int, yoga: NSManagedObject) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.meditation = yoga
        objYoga.recommendationVikriti = self.recommendationVikriti
        objYoga.recommendationPrakriti = self.recommendationPrakriti
        objYoga.isFromForYou = false
        objYoga.istype = .meditation
        self.present(objYoga, animated: true, completion: nil)
    }
    func pranayamaSelectedAtIndex(index: Int, yoga: NSManagedObject) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.pranayama = yoga
        objYoga.recommendationVikriti = self.recommendationVikriti
        objYoga.recommendationPrakriti = self.recommendationPrakriti
        objYoga.isFromForYou = false
        objYoga.istype = .pranayama
        self.present(objYoga, animated: true, completion: nil)
    }
    func kriyaSelectedAtIndex(index: Int, yoga: NSManagedObject) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.kriya = yoga
        objYoga.recommendationVikriti = self.recommendationVikriti
        objYoga.recommendationPrakriti = self.recommendationPrakriti
        objYoga.isFromForYou = false
        objYoga.istype = .kriya
        self.present(objYoga, animated: true, completion: nil)
    }
    func mudraSelectedAtIndex(index: Int, yoga: NSManagedObject) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.mudra = yoga
        objYoga.recommendationVikriti = self.recommendationVikriti
        objYoga.recommendationPrakriti = self.recommendationPrakriti
        objYoga.isFromForYou = false
        objYoga.istype = .mudra
        self.present(objYoga, animated: true, completion: nil)
    }

}

extension HOEYogaListVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        filteredDataArray.removeAll()
        filteredDataArray = dataArray
        self.collectionview.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        if searchText == "" {
            filteredDataArray.removeAll()
            filteredDataArray = dataArray
        } else {
            filteredDataArray =  dataArray.filter { (data: NSManagedObject) -> Bool in
                var stringToCompare = ""
                var stringToCompare2 = ""
                switch self.sectionType {
                case .yoga:
                    stringToCompare = (data as? Yoga)?.english_name ?? ""
                    stringToCompare2 = (data as? Yoga)?.name ?? ""
                case .food:
                    stringToCompare = (data as? FoodDemo)?.foodType ?? ""
                case .herbs:
                    stringToCompare = (data as? HerbType)?.herbs_types ?? ""
                case .yogaFavourite:
                    stringToCompare = (data as? FavouriteYoga)?.english_name ?? ""
                    stringToCompare2 = (data as? Yoga)?.name ?? ""
                case .meditationFavourite:
                    stringToCompare = (data as? FavouriteMeditation)?.english_name ?? ""
                    stringToCompare2 = (data as? Meditation)?.name ?? ""
                case .pranayamaFavourite:
                    stringToCompare = (data as? FavouritePranayama)?.english_name ?? ""
                    stringToCompare2 = (data as? Pranayama)?.name ?? ""
                case .mudraFavourite:
                    stringToCompare = (data as? FavouriteMudra)?.english_name ?? ""
                    stringToCompare2 = (data as? Mudra)?.name ?? ""
                case .kriyaFavourite:
                    stringToCompare = (data as? FavouriteKriya)?.english_name ?? ""
                    stringToCompare2 = (data as? Kriya)?.name ?? ""
                    
                default:
                    break
                }
                
                if stringToCompare.uppercased().contains(searchText.uppercased()) || stringToCompare2.uppercased().contains(searchText.uppercased()) {
                    return true
                } else {
                    return false
                }
            }
        }
        self.collectionview.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        filteredDataArray.removeAll()
        filteredDataArray = dataArray
        collectionview.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


extension HOEYogaListVC {
    func getFoodFromServer(completion: @escaping ()-> Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.v2.getFoodType.rawValue
            let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in

                defer {
                    completion()
                }
                switch response.result {

                case .success(let value):
                    print(response)
                    guard let arrQuestions = (value as? [[String: AnyObject]]) else {

                        return
                    }
                    CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "FoodDemo")
                    for dic in arrQuestions {
                        FoodDemo.createFoodData(dicData: dic)
                    }
                    self.getFoodFromDB()

                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        } else {
            self.getFoodFromDB()
            completion()
        }
    }

    func getFoodFromDB() {
        guard let arrFood = CoreDataHelper.sharedInstance.getListOfEntityWithName("FoodDemo", withPredicate: nil, sortKey: nil, isAscending: false) as? [FoodDemo] else {
            return
        }
        dataArray = arrFood
        self.filteredDataArray = dataArray
        self.collectionview.reloadData()
    }
    
    func getHerbTypesFromServer(completion: @escaping ()-> Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            var params = ["type": recommendationVikriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
            params["type"] = appDelegate.cloud_vikriti_status
            
            let urlString = kBaseNewURL + endPoint.getHerbsTypes.rawValue
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                defer {
                    completion()
                }
                switch response.result {
                
                case .success(let value):
                    print(response)
                    guard let arrResponse = value as? [[String: AnyObject]] else {
                        return
                    }
                    
                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "HerbType")
                    let dataArray = arrResponse.compactMap{ HerbType.createHerbData(dicData: $0) }
                    self.dataArray = dataArray
                    self.filteredDataArray = dataArray
                    self.collectionview.reloadData()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        } else {
            self.getHerbTypesFromDB()
            completion()
        }
    }
    
    func getHerbTypesFromDB() {
        guard let arrHerb = CoreDataHelper.sharedInstance.getListOfEntityWithName("HerbType", withPredicate: nil, sortKey: nil, isAscending: false) as? [HerbType] else {
            return
        }
        self.dataArray = arrHerb
        self.filteredDataArray = arrHerb
        self.collectionview.reloadData()
    }
}

