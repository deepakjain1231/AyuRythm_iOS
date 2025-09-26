//
//  MyHomeViewController.swift
//  HourOnEarth
//
//  Created by Apple on 15/01/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class GlobalSearchViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tblSearch: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var dicResponse = [[String: Any]]()
    var dataArray: [RecommendationCellType] = [RecommendationCellType]()
    var unlockIndexPath = IndexPath()
    var unlockIndex = Int()
    var accessPoint = Int()
    var name = String()
    var favID = Int()
    var recommendationType = "Kapha"
    var isFromMyListSearch = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = nil
        registerCells()
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        recommendationType = Utils.getRecommendationType()
        
        if searchBar.text != "" {
            fetchSearchResultwithString(searchString: searchBar.text ?? "")
        }
    }
    
    
    func registerCells() {
        tblSearch.register(UINib(nibName: "HomeYogaCell", bundle: nil), forCellReuseIdentifier: "HomeYogaCell")
    }
    
    //MARK: UITableViewCell
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = self.dataArray[indexPath.row]
        switch rowType {
        case .yoga, .pranayam, .meditation, .mudra, .kriya:
            return 245
        case .register:
            return 370
        case .products:
            return 280
        case .food, .homeremedies, .herbs:
            return 218
        default:
            return UITableView.automaticDimension
        }
    }
    
    //MARK: TableViewDelegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = self.dataArray[indexPath.row]
        switch rowType {
            
        case .yoga(let title, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.isFromGlobalSearch = true
            cell.btnSeeMore.isHidden = true
            cell.delegate = self
            cell.indexPathNew = indexPath
            cell.collectionView.isHidden = false
            cell.globalCatLockView.isHidden = true
            cell.configureUI(title: title, data: data, cellType: .yoga(isStatusVisible: false, recPrakriti: .kapha, recVikriti: .kapha))
            cell.selectionStyle = .none
            return cell
            
        case .pranayam(let title, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.isFromGlobalSearch = true
            cell.btnSeeMore.isHidden = true
            cell.delegate = self
            cell.collectionView.isHidden = false
            cell.globalCatLockView.isHidden = true
            cell.indexPathNew = indexPath
            cell.configureUI(title: title, data: data, cellType: .pranayama(isStatusVisible: false, recPrakriti: .kapha, recVikriti: .kapha))
            cell.selectionStyle = .none
            return cell
            
        case .meditation(let title, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.isFromGlobalSearch = true
            cell.btnSeeMore.isHidden = true
            cell.delegate = self
            cell.collectionView.isHidden = false
            cell.globalCatLockView.isHidden = true
            cell.indexPathNew = indexPath
            cell.configureUI(title: title, data: data, cellType: .meditation(isStatusVisible: false, recPrakriti: .kapha, recVikriti: .kapha))
            cell.selectionStyle = .none
            return cell
            
        case .mudra(let title, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.isFromGlobalSearch = true
            cell.btnSeeMore.isHidden = true
            cell.delegate = self
            cell.indexPathNew = indexPath
            if data.count > 0 {
                if data[0].access_point > 0 {
                    cell.collectionView.isHidden = !data[0].redeemed
                    cell.globalCatLockView.isHidden = data[0].redeemed
                }
                else {
                    cell.collectionView.isHidden = false
                    cell.globalCatLockView.isHidden = true
                }
            }
            cell.configureUI(title: title, data: data, cellType: .mudra(isStatusVisible: false, recPrakriti: .kapha, recVikriti: .kapha))
            cell.selectionStyle = .none
            return cell
            
        case .kriya(let title, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.isFromGlobalSearch = true
            cell.btnSeeMore.isHidden = true
            cell.delegate = self
            cell.indexPathNew = indexPath
            if data.count > 0 {
                if data[0].access_point > 0 {
                    cell.collectionView.isHidden = !data[0].redeemed
                    cell.globalCatLockView.isHidden = data[0].redeemed
                }
                else {
                    cell.collectionView.isHidden = false
                    cell.globalCatLockView.isHidden = true
                }
            }
            cell.configureUI(title: title, data: data, cellType: .kriya(isStatusVisible: false, recPrakriti: .kapha, recVikriti: .kapha))
            cell.selectionStyle = .none
            return cell

        case .food(let title, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.btnSeeMore.isHidden = true
            cell.collectionView.isHidden = false
            cell.globalCatLockView.isHidden = true
            cell.isFromGlobalSearch = true
            cell.delegate = self
            cell.indexPathNew = indexPath
            cell.configureUI(title: title, data: data, cellType: .food)
            cell.selectionStyle = .none
             return cell
            
        case .herbs(let title, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.btnSeeMore.isHidden = true
            cell.collectionView.isHidden = false
            cell.globalCatLockView.isHidden = true
            cell.isFromGlobalSearch = true
            cell.delegate = self
            cell.indexPathNew = indexPath
            cell.configureUI(title: title, data: data, cellType: .herb)
            cell.selectionStyle = .none
             return cell
            
        case .homeremedies(let title, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.btnSeeMore.isHidden = true
            cell.collectionView.isHidden = false
            cell.globalCatLockView.isHidden = true
            cell.isFromGlobalSearch = true
            cell.delegate = self
            cell.indexPathNew = indexPath

            cell.lblTitle.text = title.localized()
            cell.dataArrayHomeRem = data
            cell.cellType = .homeremedies
            cell.collectionView.reloadData()

            cell.selectionStyle = .none
             return cell
            
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func didSelectedSelectRow(indexPath: IndexPath, index: Int?) {
        let rowType = self.dataArray[indexPath.row]
        switch rowType {
        case .yoga(_, let dataArray):
            guard let index = index else {
                //If index is not present then move to see all
                self.showYogaPlayListScreen(data: dataArray)
                return
            }

            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
                return
            }
            objYoga.modalPresentationStyle = .fullScreen
            objYoga.yoga = dataArray[index]
            objYoga.istype = .yoga
            self.present(objYoga, animated: true, completion: nil)

            case .pranayam(_, let dataArray):
                guard let index = index else {
                    //If index is not present then move to see all
                    self.showPranayamaPlayListScreen(data: dataArray)
                    return
                }

                let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
                guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
                    return
                }
                objYoga.modalPresentationStyle = .fullScreen
                objYoga.pranayama = dataArray[index]
                objYoga.istype = .pranayama
                self.present(objYoga, animated: true, completion: nil)

            case .meditation(_, let dataArray):
                guard let index = index else {
                    //If index is not present then move to see all
                    self.showMeditationPlayListScreen(data: dataArray)
                    return
                }

                let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
                guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
                    return
                }
                objYoga.modalPresentationStyle = .fullScreen
                objYoga.meditation = dataArray[index]
                objYoga.istype = .meditation
                self.present(objYoga, animated: true, completion: nil)

            case .mudra(_, let dataArray):
                guard let index = index else {
                    //If index is not present then move to see all
                    self.showMudraPlayListScreen(data: dataArray)
                    return
                }

                let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
                guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
                    return
                }
                objYoga.modalPresentationStyle = .fullScreen
                objYoga.mudra = dataArray[index]
                objYoga.istype = .mudra
                self.present(objYoga, animated: true, completion: nil)
            case .kriya(_, let dataArray):
                guard let index = index else {
                    //If index is not present then move to see all
                    self.showkriyaPlayListScreen(data: dataArray)
                    return
                }

                let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
                guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
                    return
                }
                objYoga.modalPresentationStyle = .fullScreen
                objYoga.kriya = dataArray[index]
                objYoga.istype = .kriya
                self.present(objYoga, animated: true, completion: nil)

        case .food(_, let foodArray):
            
            guard let _ = index else {
                //If index is not present then move to see all
                self.showDetailScreen(sectionType: .food, data: foodArray)
                return
            }
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objFoodDetails = storyBoard.instantiateViewController(withIdentifier: "FoodDetailViewController") as? FoodDetailViewController else {
                return
            }
            objFoodDetails.modalPresentationStyle = .fullScreen

            objFoodDetails.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
            objFoodDetails.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
            objFoodDetails.dataFood = foodArray[index!]
            self.present(objFoodDetails, animated: true, completion: nil)
            break
            
        case .herbs(_, let herbsArray):
            
            guard let _ = index else {
                //If index is not present then move to see all
                self.showDetailScreen(sectionType: .herbs, data: herbsArray)
                return
            }
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let herbDetails = storyBoard.instantiateViewController(withIdentifier: "HerbDetailViewController") as? HerbDetailViewController else {
                return
            }
            herbDetails.modalPresentationStyle = .fullScreen

            herbDetails.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
            herbDetails.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
            herbDetails.herbDetail = herbsArray[index!]
            self.present(herbDetails, animated: true, completion: nil)
            break

        case .products(_), .register:
            break
        
        case .homeremedies(_, let homeremediesArray):
            guard let index = index else {
                return
            }
            let heading = homeremediesArray[index]["categoryname"] as? String ?? ""
            let remedies = homeremediesArray[index]["remedies"] as? [[String: Any ]] ?? [[:]]
            let storyBoard = UIStoryboard(name: "Favourites", bundle: nil)
            let objRemedyView: FavRemediesDetailViewController = storyBoard.instantiateViewController(withIdentifier: "FavRemediesDetailViewController") as! FavRemediesDetailViewController
             objRemedyView.titleRemedy = heading
            objRemedyView.isFromFavourites = false
            objRemedyView.searchArr = remedies
            self.navigationController?.pushViewController(objRemedyView, animated: true)

        default:
            break
        }
    }
    
    func showYogaPlayListScreen(data: [Yoga]) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        objPlayList.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        objPlayList.yogaArray = data
        objPlayList.istype = .yoga
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }
    
    func showMeditationPlayListScreen(data: [Meditation]) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        objPlayList.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        objPlayList.meditationArray = data
        objPlayList.istype = .meditation
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }

    func showPranayamaPlayListScreen(data: [Pranayama]) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        objPlayList.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        objPlayList.pranayamaArray = data
        objPlayList.istype = .pranayama
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }
    
    func showMudraPlayListScreen(data: [Mudra]) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        objPlayList.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        objPlayList.mudraArray = data
        objPlayList.istype = .mudra
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }

    func showkriyaPlayListScreen(data: [Kriya]) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        objPlayList.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        objPlayList.kriyaArray = data
        objPlayList.istype = .kriya
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }

    func showDetailScreen(sectionType: ForYouSectionType, data: [NSManagedObject]) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "HOEYogaListVC") as? HOEYogaListVC else {
            return
        }
        objFoodView.recommendationVikriti = RecommendationType(rawValue: recommendationType) ?? RecommendationType.kapha
        objFoodView.sectionType = sectionType
        if sectionType == .food {
            objFoodView.isFromHome = true
        } else {
            objFoodView.dataArray = data
        }
        self.navigationController?.pushViewController(objFoodView, animated: true)
    }
}

extension GlobalSearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        tblSearch.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        fetchSearchResultwithString(searchString: searchBar.text ?? "")
    }
    
    //MARK:- API call to retrive transaction history
    func fetchSearchResultwithString(searchString: String) {
        
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + (isFromMyListSearch ? endPoint.listSearchForAll.rawValue : endPoint.globalSearch.rawValue)
        
        let trimmedString = searchString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        AF.request(urlString, method: .post, parameters: ["language_id" : Utils.getLanguageId(), "keyword" : trimmedString, "type" : Utils.getPrakritiIncreaseValue().rawValue], encoding:URLEncoding.default,headers: headers).responseJSON { response in
            
            DispatchQueue.main.async(execute: {
                Utils.stopActivityIndicatorinView(self.view)
            })
            switch response.result {
            case .success(let value):
                debugPrint(response)
                guard (value as? [String: Any]) != nil else {
                    return
                }
                
                self.dataArray.removeAll()
                self.dicResponse = (value as? [String: Any])!["response"] as! [[String : Any]]

                for dicObject in self.dicResponse {
                    if dicObject["type"] as? String == "Yoga" {
                        var managedObject = [Yoga]()
                        for dic in (dicObject["details"] as? [[String: Any]])! {
                            managedObject.append(Yoga.createYogaData(dicYoga: dic, needToSave: false)!)
                        }
                        if managedObject.count > 0 {
                            self.dataArray.append(.yoga(title: "Yoga", data: managedObject))
                        }
                    }
                    else if dicObject["type"] as? String == "Pranayama" {
                        var managedObject = [Pranayama]()
                        for dic in (dicObject["details"] as? [[String: Any]])! {
                            managedObject.append(Pranayama.createPranayamaData(dicData: dic)!)
                        }
                        if managedObject.count > 0 {
                            self.dataArray.append(.pranayam(title: "Pranayama", data: managedObject))
                        }
                    }
                    else if dicObject["type"] as? String == "Meditation" {
                        var managedObject = [Meditation]()
                        for dic in (dicObject["details"] as? [[String: Any]])! {
                            managedObject.append(Meditation.createMeditationData(dicData: dic, needToSave: false)!)
                        }
                        if managedObject.count > 0 {
                            self.dataArray.append(.meditation(title: "Meditation", data: managedObject))
                        }
                    }
                    else if dicObject["type"] as? String == "Mudra" {
                        var managedObject = [Mudra]()
                        for dic in (dicObject["details"] as? [[String: Any]])! {
                            managedObject.append(Mudra.createMudraData(dicData: dic, needToSave: false)!)
                        }
                        if managedObject.count > 0 {
                            self.dataArray.append(.mudra(title: "Mudra", data: managedObject))
                        }
                    }
                    else if dicObject["type"] as? String == "Kriya" {
                        var managedObject = [Kriya]()
                        for dic in (dicObject["details"] as? [[String: Any]])! {
                            managedObject.append(Kriya.createKriyaData(dicData: dic, needToSave: false)!)
                        }
                        if managedObject.count > 0 {
                            self.dataArray.append(.kriya(title: "Kriya", data: managedObject))
                        }
                    }
                    else if dicObject["type"] as? String == "Food" {
                        var managedObject = [Food]()
                        for dic in (dicObject["details"] as? [[String: Any]])! {
                            managedObject.append(Food.createFoodData(dicData: dic, needToSave: false)!)
                        }
                        if managedObject.count > 0 {
                            self.dataArray.append(.food(title: "Food", data: managedObject))
                        }
                    }
                    else if dicObject["type"] as? String == "Herbs" {
                        var managedObject = [Herb]()
                        for dic in (dicObject["details"] as? [[String: Any]])! {
                            managedObject.append(Herb.createHerbData(dicData: dic, needToSave: false)!)
                        }
                        if managedObject.count > 0 {
                            self.dataArray.append(.herbs(title: "Herbs", data: managedObject))
                        }
                    }
                    else if dicObject["type"] as? String == "homeremedies" {
                        guard let arrRemedies = (dicObject["details"] as? [[String: Any]]) else {
                            return
                        }
                        if arrRemedies.count > 0 {
                            self.dataArray.append(.homeremedies(title: "Home Remedies", data: arrRemedies))
                        }
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.tblSearch.reloadData()
                })
                
            case .failure(let error):
                debugPrint(error)
                Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
            }
        }
    }
}

extension GlobalSearchViewController: RecommendationSeeAllDelegate {
   
    func didSelectedSelectRowForRedeem(indexPath: IndexPath, index: Int?) {
        
        unlockIndexPath = indexPath
        unlockIndex = index ?? 0
        
        let rowType = self.dataArray[indexPath.row]
        switch rowType {
        case .yoga(_, let dataArray):
            guard let index = index else {
                return
            }
            accessPoint = Int(dataArray[index].access_point)
            name = "yoga"
            favID = Int(dataArray[index].id)
            
        case .pranayam(_, let dataArray):
            guard let index = index else {
                return
            }
            accessPoint = Int(dataArray[index].access_point)
            name = "pranayama"
            favID = Int(dataArray[index].id)
            
        case .meditation(_, let dataArray):
            guard let index = index else {
                return
            }
            accessPoint = Int(dataArray[index].access_point)
            name = "meditation"
            favID = Int(dataArray[index].id)

        case .mudra(_, let dataArray):
            accessPoint = Int(dataArray[0].access_point)
            name = "mudra"
            favID = 0

        case .kriya(_, let dataArray):
            accessPoint = Int(dataArray[0].access_point)
            name = "kriya"
            favID = 0
            
        default:
            break
        }
        
        AyuSeedsRedeemManager.shared.redeemItem(accessPoint: accessPoint, name: name, favID: favID, presentingVC: self.tabBarController ?? self) { [weak self] (isSuccess, isSubscriptionResumeSuccess, title, message) in
            guard let self = self else { return }
            self.fetchSearchResultwithString(searchString: self.searchBar.text ?? "")
        }
    }
}
