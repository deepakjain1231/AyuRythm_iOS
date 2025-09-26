//
//  PlayListViewController.swift
//  HourOnEarth
//
//  Created by Apple on 17/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class PlayListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, PlayListDelegate {

    var dataArray = [PlayList]()
    var allDataArray = [PlayList]()
    var listCount = 0
    var listName = ""
    var isMyList = false
    var index = 0

    var is_searchOpen = false
    @IBOutlet weak var tblPlayList: UITableView!
    @IBOutlet weak var create_lockView: UIView!
    @IBOutlet weak var create_btn_lockView: UIButton!
    @IBOutlet weak var my_listButton : UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var constrant_search_bar_Height: NSLayoutConstraint!
    
    
    var recommendationVikriti: RecommendationType = .kapha
    var isRequiredLoadingDataFromServer = false
    
    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lists".localized()
        searchBar.placeholder = "List".localized()
        self.tblPlayList.tableFooterView = UIView()
        self.tblPlayList.register(nibWithCellClass: MyListCategoryTableCell.self)
        tblPlayList.register(UINib(nibName: "PlayListRowCell", bundle: nil), forCellReuseIdentifier: "PlayListRowCell")
        allDataArray = dataArray
        
        debugPrint(allDataArray) 
        //updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        updateUI()
    }
    
    // MARK: - Action Methods
    @IBAction func btn_Back_Pressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Search_Action(_ sender: UIButton) {
        if self.is_searchOpen == false {
            self.is_searchOpen = true
            UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.constrant_search_bar_Height.constant = 44
                self.view.layoutIfNeeded()
            }) { (success) in
            }
        }
        else {
            self.is_searchOpen = false
            UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.constrant_search_bar_Height.constant = 0
                self.view.layoutIfNeeded()
            }) { (success) in
            }
        }
    }
    
    @IBAction func btn_myList_Action(_ sender: UIButton) {
        guard Utils.isConnectedToNetwork() else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
            return
        }
        
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please Register now to view My List section".localized(), controller: self)
            return
        }
        
        //If registered but not given test
        if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil && kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti and Vikriti assessment to view recommendations".localized(), controller: self)
            return
        } else if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti assessment to view recommendations".localized(), controller: self)
            return
        } else if kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Vikriti assessment to view recommendations".localized(), controller: self)
            return
        }
        
        let storyBoard = UIStoryboard(name: "MyLists", bundle: nil)
        guard let myListVC = storyBoard.instantiateViewController(withIdentifier: "MyListsViewController") as? MyListsViewController else {
            return
        }
        self.navigationController?.pushViewController(myListVC, animated: true)
        
        
    }
    
    @IBAction func lockButtonPressed(_ sender: UIButton) {
        // redeem view logic
        isMyList = true
        performUnlockItemProcess()
    }
    
    @IBAction func btn_fav_Action(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name:"Favourites", bundle:nil)
        guard let obj_fav = storyBoard.instantiateViewController(withIdentifier: "FavouritesViewController") as? FavouritesViewController else {
            return
        }
        self.navigationController?.pushViewController(obj_fav, animated: true)
    }
    
    // MARK: - Custom Methods
    func updateUI() {
        create_lockView.isHidden = kUserDefaults.bool(forKey: kUserListRedeemed)
        create_btn_lockView.isHidden = kUserDefaults.bool(forKey: kUserListRedeemed)
        
        my_listButton.isEnabled = kUserDefaults.bool(forKey: kUserListRedeemed)
        if kUserDefaults.bool(forKey: kUserListRedeemed) {
            my_listButton.setTitleColor(.systemBlue, for: .normal)
        } else {
            my_listButton.setTitleColor(.gray, for: .normal)
        }
        
        fetchMyLists()
        
        if isRequiredLoadingDataFromServer {
            showActivityIndicator()
            getPlayListFromServer {
                self.hideActivityIndicator()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            if listCount > 0 {
//                return 1
//            }
//            return 0
//        }
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListRowCell") as? PlayListRowCell else {
//            return UITableViewCell()
//        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyListCategoryTableCell", for: indexPath) as! MyListCategoryTableCell
        cell.selectionStyle = .none
        
        cell.delegate = self
        cell.indexPath = indexPath
//        if indexPath.section == 0 {
//            cell.lblTitle.text = "My Lists".localized()
//            let unlockPoints = kUserDefaults.integer(forKey: kUserListPoints)
//            if unlockPoints > 0 {
//                cell.lockView.isHidden = kUserDefaults.bool(forKey: kUserListRedeemed)
//                cell.imgView.isHidden = !kUserDefaults.bool(forKey: kUserListRedeemed)
//            }
//            else {
//                cell.lockView.isHidden = true
//                cell.imgView.isHidden = false
//            }
//            cell.lblSubTitle.text = "\(listCount) " + (listCount > 1 ? "Lists".localized() : "List".localized())
//            cell.imgView.image = #imageLiteral(resourceName: "my-lists.png")
//            return cell
//        } else {
            let playList = dataArray[indexPath.row]
            cell.configureUI(title: playList.name, subTitle: String(format: "%d \("items".localized())", playList.count), urlString: playList.image ?? "")
            if playList.access_point > 0 {
                cell.lockView.isHidden = playList.redeemed
                //cell.imgView.isHidden = !playList.redeemed
            }
            else {
                cell.lockView.isHidden = true
                //cell.imgView.isHidden = false
            }
            return cell
        //}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        if indexPath.section == 0 {
//            //tabBarController?.selectedIndex = 4
//
//            guard Utils.isConnectedToNetwork() else {
//                Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
//                return
//            }
//
//            guard !kSharedAppDelegate.userId.isEmpty else {
//                Utils.showAlertWithTitleInController(APP_NAME, message: "Please Register now to view My List section".localized(), controller: self)
//                return
//            }
//
//            //If registered but not given test
//            if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil && kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
//                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti and Vikriti assessment to view recommendations".localized(), controller: self)
//                return
//            } else if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil {
//                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti assessment to view recommendations".localized(), controller: self)
//                return
//            } else if kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
//                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Vikriti assessment to view recommendations".localized(), controller: self)
//                return
//            }
//
//            let storyBoard = UIStoryboard(name: "MyLists", bundle: nil)
//            guard let myListVC = storyBoard.instantiateViewController(withIdentifier: "MyListsViewController") as? MyListsViewController else {
//                return
//            }
//            self.navigationController?.pushViewController(myListVC, animated: true)
//
//        } else {
            let selectedItem = dataArray[indexPath.row];
            index = indexPath.row
            if let favID = dataArray[index].favorite_id, let playListId = Int(favID) {
                let storyBoard = UIStoryboard(name: "PlayList", bundle: nil)
                guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "PlayListDetailVC") as? PlayListDetailVC else {
                    return
                }
                objPlayList.playListId = playListId
                objPlayList.type = dataArray[index].type ?? ""
                objPlayList.navTitle = dataArray[index].name ?? ""
                self.navigationController?.pushViewController(objPlayList, animated: true)
            }
        //}
    }
    
    func lockMyListClicked(index: Int) {
        // update redeem
        isMyList = true
        performUnlockItemProcess()
    }
    
    func lockBenfitsClikced(indexPath: IndexPath) {
        isMyList = false
        index = indexPath.row
        performUnlockItemProcess()
    }
    
    func performUnlockItemProcess() {
        let playList = dataArray[index]
        var name = playList.item ?? "benefit"
        var favID = playList.favorite_id?.intValue ?? 0
        var accessPoint = Int(playList.access_point)
        var category: String? = "List"
        
        if self.isMyList {
            name = "User Defined List"
            favID = 0
            accessPoint = kUserDefaults.integer(forKey: kUserListPoints)
            category = nil
        }
        ARLog("Name : \(name), favID : \(favID), accessPoint: \(accessPoint), category: \(category)")
        
        AyuSeedsRedeemManager.shared.redeemItem(accessPoint: accessPoint, name: name, category: category, favID: favID, presentingVC: self.tabBarController ?? self, isShowSuccessAlert: !isMyList) { [weak self] (isSuccess, isSubscriptionResumeSuccess, title, message) in
            guard let self = self else { return }
            
            if isSuccess {
                if isSubscriptionResumeSuccess {
                    kUserDefaults.set(true, forKey: kUserListRedeemed)
                    self.isRequiredLoadingDataFromServer = true
                    self.updateUI()
                    return
                }
                
                if self.isMyList {
                    kUserDefaults.set(true, forKey: kUserListRedeemed)
                    self.isMyList = false
                    self.create_lockView.isHidden = true
                    self.create_btn_lockView.isHidden = true
                    self.my_listButton.isEnabled = true
                    self.my_listButton.setTitleColor(.systemBlue, for: .normal)
                    self.fetchMyLists()
                    //self.showUnlockItemSuccessMessage(category: "User List")
                } else {
                    let playList = self.dataArray[self.index]
                    playList.access_point = 0
                    playList.redeemed = true
                    //self.showUnlockItemSuccessMessage(category: "List", response: dicResponse)
                }
                self.tblPlayList.reloadData()
            } else {
                self.hideActivityIndicator(withTitle: title, Message: message)
            }
        }
    }
}


extension PlayListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        dataArray.removeAll()
        dataArray = allDataArray
        self.tblPlayList.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        if searchText == "" {
            dataArray.removeAll()
            dataArray = allDataArray
        } else {
            dataArray =  allDataArray.filter { (data: PlayList) -> Bool in
                let stringToCompare2 = data.name ?? ""
                
                if stringToCompare2.uppercased().contains(searchText.uppercased()) {
                    return true
                } else {
                    return false
                }
            }
        }
        self.tblPlayList.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        dataArray.removeAll()
        dataArray = allDataArray
        tblPlayList.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - User List
extension PlayListViewController: delegate_CreateList {
    
    @IBAction func createUserListButtonClicked(sender: UIButton) {
        let objDialouge = CreateListNameDialouge(nibName:"CreateListNameDialouge", bundle:nil)
        objDialouge.delegate = self
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
        
        
        /*
        let alertController = UIAlertController(title: "Name your List".localized(), message: "Give your list a memorable name".localized(), preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "List Name".localized()
            textField.text = self.listName
        }
        
        let saveAction = UIAlertAction(title: "Save".localized(), style: .default) { [unowned alertController] _ in
            let textField = alertController.textFields![0]
            self.saveListName(textField.text ?? "")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true)
        */
    }
    
    func fetchMyLists() {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.GetList.rawValue
        
        AF.request(urlString, method: .post, parameters: nil, encoding:URLEncoding.default,headers: headers).responseJSON { response in
            
            DispatchQueue.main.async(execute: {
                Utils.stopActivityIndicatorinView(self.view)
            })
            switch response.result {
            case .success(let value):
                debugPrint(response)
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    return
                }
                
                if dicResponse["status"] as? String ?? "" == "success" {
                    guard let dataResponse = (dicResponse["data"] as? [[String : Any]]) else {
                        return
                    }
                    self.listCount = dataResponse.count
                    self.tblPlayList.reloadData()
                } else {
                    Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["Message"] as? String ?? "Failed to get My Lists.".localized()), controller: self)
                }
            case .failure(let error):
                debugPrint(error)
                Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
            }
        }
    }
    
    func create_listname(_ success: Bool, listname: String) {
        if success {
            self.saveListName(listname)
        }
    }
    
    func saveListName(_ name: String) {
        listName = name
        if name.count == 0 {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter a valid list name".localized(), controller: self)
            return
        }
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.AddList.rawValue
        
        AF.request(urlString, method: .post, parameters: ["list_name" : name], encoding:URLEncoding.default,headers: headers).responseJSON { response in
            
            DispatchQueue.main.async(execute: {
                Utils.stopActivityIndicatorinView(self.view)
            })
            switch response.result {
            case .success(let value):
                debugPrint(response)
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    return
                }
                
                if dicResponse["status"] as? String ?? "" == "success" {
                    let message = dicResponse["message"] as? String ?? ""
                    guard let dataResponse = (dicResponse["response"] as? [[String : Any]]) else {
                        return
                    }
                    
                    let list = MyList.createMyList(list: dataResponse.first!)
                    let finalMessage = name + ", " + message
                    self.addEarnHistoryFromServer(addListMessage: finalMessage, list: list!)
                    self.listCount = self.listCount + 1
                    self.tblPlayList.reloadData()
                    self.listName = ""
                } else {
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to save My Lists.".localized()), okTitle: "Ok".localized(), controller: self) {
                        self.createUserListButtonClicked(sender: self.my_listButton)
                    }
                }
            case .failure(let error):
                debugPrint(error)
                Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
            }
        }
    }
}

extension PlayListViewController {
    func getPlayListFromServer(completion: @escaping ()-> Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.v2.getExpBenefitsPlayList.rawValue
            
            var param = ["type": recommendationVikriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
            param["type"] = appDelegate.cloud_vikriti_status
            
            AF.request(urlString, method: .post, parameters: param, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                defer {
                    completion()
                }
                switch response.result {
                
                case .success(let value):
                    print(response)
                    guard let arrPlayList = (value as? [[String: AnyObject]]) else {
                        return
                    }
                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "PlayList")
                    for dic in arrPlayList {
                        PlayList.createPlayListData(dicData: dic)
                    }
                    self.getPlayListFromDB()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        } else {
            self.getPlayListFromDB()
            completion()
        }
    }
    
    func getPlayListFromDB() {
        guard let arrPlayList = CoreDataHelper.sharedInstance.getListOfEntityWithName("PlayList", withPredicate: nil, sortKey: nil, isAscending: false) as? [PlayList] else {
            return
        }
        
        dataArray = arrPlayList
        tblPlayList.reloadData()
    }
}

extension PlayListViewController {
    func addEarnHistoryFromServer(addListMessage: String, list: MyList) {
        let params = ["activity_favorite_id": AyuSeedEarnActivity.userList.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
        ReferPopupViewController.addEarmHistoryFromServer(params: params) { (isSuccess, title, message) in
            print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
            self.hideActivityIndicator()
            if isSuccess {
                Utils.showAlertWithTitleInControllerWithCompletion(title, message: message, okTitle: "Ok".localized(), controller: self) {
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: addListMessage, okTitle: "Ok".localized(), controller: self) {
                        let storyBoard = UIStoryboard(name:"MyLists", bundle:nil)
                        guard let listsInfoViewController = storyBoard.instantiateViewController(withIdentifier: "MyListsInfoViewController") as? MyListsInfoViewController else {
                            return
                        }
                        listsInfoViewController.list = list
                        self.navigationController?.pushViewController(listsInfoViewController, animated: true)
                    }
                }
            } else {
                Utils.showAlertWithTitleInController(APP_NAME, message: addListMessage, controller: self)
            }
        }
    }
}

extension UIViewController {
    func showUnlockItemSuccessMessage(category: String, response: [String: Any]? = nil) {
        let status = response?["status"] as? String ?? ""
        let isSubscribe = response?["isSubscribe"] as? String ?? String(response?["isSubscribe"] as? Int ?? 0)
        var message = "unlocked successfully, valid for 1 month".localized()
        if status == "success", isSubscribe == "1" {
            message = response?["Message"] as? String ?? (response?["message"] as? String ?? "unlocked successfully".localized())
        } else {
            message = category.capitalizingFirstLetter().localized() + " " + message
        }
        print("----> message : ", message)
        Utils.showAlertWithTitleInController("Success".localized(), message: message, controller: self)
    }
}
