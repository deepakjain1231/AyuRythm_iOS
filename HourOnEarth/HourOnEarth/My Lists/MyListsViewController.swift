//
//  MyListsViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 24/07/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class MyListsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var listButton : UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var constrant_search_bar_Height: NSLayoutConstraint!
    
    var is_searchOpen = false
    var dataArray = [MyList]()
    var allDataArray = [MyList]()
    var listName = ""
    
    // MARK: - View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "List".localized()
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        
        //Registe Table Cell
        self.tableView.register(nibWithCellClass: MyListTableCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        self.navigationController?.isNavigationBarHidden = true
        //NotificationFromServer()
        
    }

    // MARK: - Action Methods
    @IBAction func btn_Back_Action(_ sender: UIButton) {
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
    
    @IBAction func createListButtonPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Name your List".localized(), message: "Give your list a memorable name".localized(), preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = self.listName
            textField.placeholder = "List Name".localized()
        }
        
        let saveAction = UIAlertAction(title: "Save".localized(), style: .default) { [unowned alertController] _ in
            let textField = alertController.textFields![0]
            //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.creating_list.rawValue)
            self.saveListName(textField.text ?? "")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true)
    }
    
    @IBAction func lockButtonPressed(_ sender: UIButton) {
        let name = "User Defined List"
        let favID = 0
        let accessPoint = kUserDefaults.integer(forKey: kUserListPoints)
        AyuSeedsRedeemManager.shared.redeemItem(accessPoint: accessPoint, name: name, favID: favID, presentingVC: self.tabBarController ?? self, isShowSuccessAlert: false) { [weak self] (isSuccess, isSubscriptionResumeSuccess, title, message) in
            guard let self = self else { return }
            
            if isSuccess {
                kUserDefaults.set(true, forKey: kUserListRedeemed)
                self.setupUI()
            } else {
                self.hideActivityIndicator(withTitle: title, Message: message)
            }
        }
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        lockView.isHidden = kUserDefaults.bool(forKey: kUserListRedeemed)
        
        listButton.isEnabled = kUserDefaults.bool(forKey: kUserListRedeemed)
        if kUserDefaults.bool(forKey: kUserListRedeemed) {
            listButton.setTitleColor(.systemBlue, for: .normal)
        } else {
            listButton.setTitleColor(.gray, for: .normal)
        }
        
        fetchMyLists()
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
                print("API URL: - \(urlString)\n\nParams: - \n\nResponse: - \(response)")
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    return
                }
                
                if dicResponse["status"] as? String ?? "" == "success" {
                    guard let dataResponse = (dicResponse["data"] as? [[String : Any]]) else {
                        return
                    }
                    
                    CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "MyList")
                    
                    for dic in dataResponse {
                        let _ = MyList.createMyList(list: dic)
                    }
                    
                    self.getMyListFromDB()
                } else {
                    Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to get My Lists.".localized()), controller: self)
                }
            case .failure(let error):
                debugPrint(error)
                Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
            }
        }
    }
    
    func saveListName(_ name: String) {
        self.listName = name
        if name.count == 0 {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter a valid list name".localized(), controller: self)
            return
        }
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.AddList.rawValue
        
        AF.request(urlString, method: .post, parameters: ["list_name" : name], encoding:URLEncoding.default,headers: headers).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                print("API URL: - \(urlString)\n\nParams: - \(["list_name" : name])\n\nResponse: - \(response)")
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    return
                }
                
                if dicResponse["status"] as? String ?? "" == "success" {
                    let message = dicResponse["message"] as? String ?? ""
                    guard let dataResponse = (dicResponse["response"] as? [[String : Any]]) else {
                        Utils.stopActivityIndicatorinView(self.view)
                        return
                    }
                    
                    self.listName = "";
                    let list = MyList.createMyList(list: dataResponse.first!)
                    self.dataArray.append(list!)
                    self.allDataArray.append(list!)
                    self.tableView.reloadData()
                    let finalMessage = name + " " + "list created successfully".localized()
                    self.addEarnHistoryFromServer(addListMessage: finalMessage, list: list!)
                } else {
                    Utils.stopActivityIndicatorinView(self.view)
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to save My Lists.".localized()), okTitle: "Ok".localized(), controller: self) {
                        self.createListButtonPressed(self.listButton)
                    }
                }
            case .failure(let error):
                debugPrint(error)
                Utils.stopActivityIndicatorinView(self.view)
                Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
            }
        }
    }
    
    func getMyListFromDB() {
        if kUserDefaults.bool(forKey: kUserListRedeemed) {
            guard let arrYoga = CoreDataHelper.sharedInstance.getListOfEntityWithName("MyList", withPredicate: nil, sortKey: nil, isAscending: false) as? [MyList] else {
                return
            }

            dataArray = arrYoga
            allDataArray = arrYoga
        }
        tableView.reloadData()
    }
    
    // MARK: - UITableView Delegate and DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyListTableCell") as? MyListTableCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            cell.lbl_title.text = "Favourites"
            cell.lbl_sub_title.isHidden = true
            cell.img_player.isHidden = true
            cell.imgThumb.image = UIImage.init(named: "favourites")
        }
        else {
            cell.img_player.isHidden = false
            let list = self.dataArray[indexPath.row - 1]
            cell.lbl_title.text = list.list_name
            cell.lbl_sub_title.isHidden = true
            if let image = list.image, let url = URL(string: image) {
                cell.imgThumb.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "icon_my_list_cell"))
            } else {
                cell.imgThumb.image = #imageLiteral(resourceName: "icon_my_list_cell")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            self.btn_fav_Action()
        }
        else {
            
            let storyBoard = UIStoryboard(name:"MyLists", bundle:nil)
            guard let listsInfoViewController = storyBoard.instantiateViewController(withIdentifier: "MyListsInfoViewController") as? MyListsInfoViewController else {
                return
            }
            listsInfoViewController.list = dataArray[indexPath.row - 1]
            listsInfoViewController.navTitle = dataArray[indexPath.row - 1].list_name?.capitalized ?? ""
            self.navigationController?.pushViewController(listsInfoViewController, animated: true)
        }
    }
    
    func btn_fav_Action() {
        let storyBoard = UIStoryboard(name:"Favourites", bundle:nil)
        guard let obj_fav = storyBoard.instantiateViewController(withIdentifier: "FavouritesViewController") as? FavouritesViewController else {
            return
        }
        self.navigationController?.pushViewController(obj_fav, animated: true)
    }
    
//    @IBAction func back_Action(sender: UIButton) {
//        navigationController?.popViewController(animated: true)
//    }
}

extension MyListsViewController {
    
    func addEarnHistoryFromServer(addListMessage: String, list: MyList) {
        let params = ["activity_favorite_id": AyuSeedEarnActivity.userList.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
        ReferPopupViewController.addEarmHistoryFromServer(params: params) { (isSuccess, title, message) in
            print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
            self.hideActivityIndicator()
            if isSuccess {
                Utils.showAlertWithTitleInControllerWithCompletion(title, message: message, okTitle: "Ok", controller: self) {
                    Utils.showAlertWithTitleInControllerWithCompletion(title, message: addListMessage, okTitle: "Ok", controller: self) {
                        let storyBoard = UIStoryboard(name:"MyLists", bundle:nil)
                        guard let listsInfoViewController = storyBoard.instantiateViewController(withIdentifier: "MyListsInfoViewController") as? MyListsInfoViewController else {
                            return
                        }
                        listsInfoViewController.list = list
                        self.navigationController?.pushViewController(listsInfoViewController, animated: true)
                    }
                }
            } else {
                Utils.showAlertWithTitleInControllerWithCompletion(title, message: addListMessage, okTitle: "Ok".localized(), controller: self) {
                    let storyBoard = UIStoryboard(name:"MyLists", bundle:nil)
                    guard let listsInfoViewController = storyBoard.instantiateViewController(withIdentifier: "MyListsInfoViewController") as? MyListsInfoViewController else {
                        return
                    }
                    listsInfoViewController.list = list
                    self.navigationController?.pushViewController(listsInfoViewController, animated: true)
                }
            }
        }
    }
}

extension MyListsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view recommendations", controller: self)
            return
        }
        let storyBoard = UIStoryboard(name: "MyHome", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "GlobalSearchViewController") as? GlobalSearchViewController else {
            return
        }
        objPlayList.isFromMyListSearch = true
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
