//
//  HomeRemediesViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 1/21/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class HomeRemediesViewController:  BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout, delegate_click_event, delegateFaceNaadi
{
    var trial_DialogSingleTime = false
    var is_remedies_subscription = UserDefaults.user.is_remedies_subscribed
    @IBOutlet private weak var collectionViewRemedies: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!

    var dataArray: [HomeRemedies] = [HomeRemedies]()
    var allDataArray: [HomeRemedies] = [HomeRemedies]()
    var searchData: [[String: Any]] = [[String: Any]]()
    var isSearching = false
    var isFromAyuverseContentLibrary = false
    var collection_bgColor = ["#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB", "#CFF1E6", "#F1EDFC", "#FFECE7", "#FDF4E2", "#E5EFFB"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "Search".localized()// "Home Remedies".localized()
        collectionViewRemedies.delegate = self
        self.navigationItem.rightBarButtonItems = nil
        collectionViewRemedies.register(UINib(nibName: "RemediesNewCell", bundle: nil), forCellWithReuseIdentifier: "RemediesNewCell")
        collectionViewRemedies.register(UINib(nibName: "HomeRemediesCollectionCell", bundle: nil), forCellWithReuseIdentifier: "HomeRemediesCollectionCell")
        
        
        //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.home_remedies.rawValue)
        if isFromAyuverseContentLibrary {
            //self.title = "Select Content"
            self.navigationItem.leftBarButtonItem = nil
            setBackButtonTitle()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.is_remedies_subscription = UserDefaults.user.is_remedies_subscribed
        
        if isSearching {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            searchHomeRemediesFromServer(text: searchBar.text ?? "") { (success) in
                Utils.stopActivityIndicatorinView(self.view)
            }
        } else {
            getRemediesFromServer()
        }
        if !isFromAyuverseContentLibrary {
            self.NotificationFromServer()
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? searchData.count : dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: HomeRemediesCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeRemediesCollectionCell", for: indexPath) as? HomeRemediesCollectionCell else {
            return UICollectionViewCell()
        }
        cell.view_Base_BG.layer.cornerRadius = cell.view_Base_BG.frame.size.height/2
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            cell.view_Base_BG.layer.cornerRadius = cell.view_Base_BG.frame.size.height/2
        }
        cell.view_Base_BG.backgroundColor = UIColor.fromHex(hexString: self.collection_bgColor[indexPath.row])
        
        if isSearching {
            let dicDetail = searchData[indexPath.row]
            
            let heading = dicDetail["categoryname"] as? String ?? ""
            cell.lblName.text = heading
            if let imageUrl = dicDetail["categoryimage"] as? String, let url = URL(string: imageUrl) {
                cell.imgView.sd_setImage(with: url, placeholderImage: UIImage(named: "home-remediesFav"))
            }

            cell.view_Base_BG.backgroundColor = UIColor.fromHex(hexString: dicDetail["color"] as? String ?? self.collection_bgColor[indexPath.row])
            
            return cell
        } else {
            let dicDetail = dataArray[indexPath.row]
            
            let heading = dicDetail.item ?? ""
            cell.lblName.text = heading
            if let imageUrl = dicDetail.image, let url = URL(string: imageUrl) {
                cell.imgView.sd_setImage(with: url, placeholderImage: UIImage(named: "home-remediesFav"))
            }
            
            cell.view_Base_BG.backgroundColor = UIColor.fromHex(hexString: dicDetail.color ?? self.collection_bgColor[indexPath.row])
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size:CGFloat = ((kDeviceWidth - 36) / 3.0)
        return CGSize(width: size - 12, height: size + 35)
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSearching {
            if self.is_remedies_subscription == false {
                self.setupSubscriptionDialouge(indx: indexPath.item)
            }
            else {
                self.gotoDetailSreen(indx_itm: indexPath.item)
            }
        } else {
            let dicRemedy = dataArray[indexPath.row]
            let storyBoard = UIStoryboard(name: "HomeRemedies", bundle: nil)
            let objRemedyView:HomeRemediesSubListViewController = storyBoard.instantiateViewController(withIdentifier: "HomeRemediesSubListViewController") as! HomeRemediesSubListViewController
            objRemedyView.bg_color = self.collection_bgColor[indexPath.row]
            objRemedyView.bg_color = dicRemedy.color ?? self.collection_bgColor[indexPath.row]
            objRemedyView.arrData = dicRemedy.subcategory?.allObjects as? [HomeRemediesDetail] ?? []
            objRemedyView.titleHeading = dicRemedy.item ?? ""
            objRemedyView.isFromAyuverseContentLibrary = isFromAyuverseContentLibrary
            self.navigationController?.pushViewController(objRemedyView, animated: true)
        }
    }

    
    func setupSubscriptionDialouge(indx: Int) {
        if UserDefaults.user.free_remedies_count == UserDefaults.user.home_remedies_trial {
            if self.trial_DialogSingleTime == false {
                self.trial_DialogSingleTime = true
                self.dialouge_trial_ended()
            }
            else {
                self.dialouge_subscription()
            }
            return
        }
        
        if UserDefaults.user.free_remedies_count < UserDefaults.user.home_remedies_trial {
            self.dialouge_subscription()
            return
        }
        
        self.gotoDetailSreen(indx_itm: indx)
    }
    
    func dialouge_trial_ended() {
        if let parent = appDelegate.window?.rootViewController {
            let objDialouge = FreeTrialEndedDialouge(nibName:"FreeTrialEndedDialouge", bundle:nil)
            objDialouge.screen_from = ScreenType.from_home_remedies
            objDialouge.delegate = self
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
            parent.view.addSubview((objDialouge.view)!)
            objDialouge.didMove(toParent: parent)
        }
    }
    
    func handle_dialouge_btn_click_event(_ success: Bool) {
        if success {
            self.dialouge_subscription()
        }
    }
    
    //MARK: - DIALOUGE DELEGATE HANDLE
    func dialouge_subscription() {
        if let parent = appDelegate.window?.rootViewController {
            let objDialouge = HomeRemediesDialouge(nibName:"HomeRemediesDialouge", bundle:nil)
            objDialouge.screen_from = ScreenType.from_home_remedies
            objDialouge.delegate = self
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
            parent.view.addSubview((objDialouge.view)!)
            objDialouge.didMove(toParent: parent)
        }
    }
    
    func subscribe_tryNow_click(_ success: Bool, type: ScreenType) {
        if success {
            if type == ScreenType.from_home_remedies {
                let obj = FaceNaadiSubscriptionListVC.instantiate(fromAppStoryboard: .FaceNaadi)
                obj.str_screenFrom = type
                self.navigationController?.pushViewController(obj, animated: true)
            }
            else if type == ScreenType.from_PrimeMember {
                let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //*****************************************************//
    
    
    
    func gotoDetailSreen(indx_itm: Int) {
        let heading = searchData[indx_itm]["categoryname"] as? String ?? ""
        let remedies = searchData[indx_itm]["remedies"] as? [[String: Any ]] ?? [[:]]
        let storyBoard = UIStoryboard(name: "Favourites", bundle: nil)
        let objRemedyView: FavRemediesDetailViewController = storyBoard.instantiateViewController(withIdentifier: "FavRemediesDetailViewController") as! FavRemediesDetailViewController
         objRemedyView.titleRemedy = heading
        objRemedyView.isFromFavourites = false
        objRemedyView.searchArr = remedies
        self.navigationController?.pushViewController(objRemedyView, animated: true)
    }
}

extension HomeRemediesViewController  {
    func getRemediesFromServer () {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.v2.homeRemediesCat.rawValue
            AF.request(urlString, method: .post, parameters: ["language_id" : Utils.getLanguageId()], encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let arrResponse = (value as? [[String: Any]]) else {
                        return
                    }
                    CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "HomeRemedies")
                    for dic in arrResponse {
                        HomeRemedies.createHomeRemediesData(dicData: dic)
                    }
                    self.getRemediesDataFromDB()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        }else {
            getRemediesDataFromDB()
        }
    }
    
    func getRemediesDataFromDB() {
        guard let arrRemedies = CoreDataHelper.sharedInstance.getListOfEntityWithName("HomeRemedies", withPredicate: nil, sortKey: nil, isAscending: true) as? [HomeRemedies] else {
            return
        }
        self.dataArray = arrRemedies
        self.dataArray = arrRemedies.sorted(by: { (item1, item2) -> Bool in
            return (item1.item ?? "").compare(item2.item ?? "") == ComparisonResult.orderedAscending
        })
        
        self.allDataArray = self.dataArray
        self.collectionViewRemedies.reloadData()
    }
}


extension HomeRemediesViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        self.dataArray = self.allDataArray
        self.collectionViewRemedies.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        if searchText == "" {
            self.dataArray = self.allDataArray
            self.isSearching = false
        } else {
            self.isSearching = true
            self.searchHomeRemediesFromServer(text: searchText) { (success) in
                self.collectionViewRemedies.reloadData()
            }
            
//            self.dataArray = allDataArray.filter { (data: HomeRemedies) -> Bool in
//                let heading = data.item ?? ""
//
//                if heading.uppercased().contains(searchText.uppercased()) {
//                    return true
//                } else {
//                    return false
//                }
//            }
        }
        self.collectionViewRemedies.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       clearSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func clearSearch() {
        self.isSearching = false
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.dataArray = self.allDataArray
        collectionViewRemedies.reloadData()
    }
    
    func searchHomeRemediesFromServer (text: String, completion: @escaping (Bool)->Void) {
        
        let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        let recommendationPrakriti = Utils.getYourCurrentPrakritiStatus()
        
        
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.allHomeRemedies.rawValue
            //let params = ["searchkey": text]
            var params = ["keyword": text,
                          "type": recommendationVikriti.rawValue,
                          "typetwo": recommendationPrakriti.rawValue,
                          "language_id" : Utils.getLanguageId()] as [String : Any]
            
#if !APPCLIP
        params["type"] = appDelegate.cloud_vikriti_status
#endif
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success(let value):
                    guard let arrRemedies = (value as? [[String: Any]]) else {
                        return
                    }
                    self.searchData = arrRemedies
                    print(self.searchData)
                    completion(true)
                case .failure(_):
                    completion(false)
                }
            }
        }else {
            completion(false)
        }
    }
}
