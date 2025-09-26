//
//  MyListsInfoViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 24/07/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class MyListsInfoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, delegate_CreateList {
    
    var navTitle = ""
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var view_NoData: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tableViewBottomHeightConstraint: NSLayoutConstraint!
    
    var dataArray = [[String : Any]]()
    var allDataArray = [[String : Any]]()
    var selectedList = [String]()
    var list = MyList()
    var listName = ""
    var listid = 0

    // MARK: View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_Title.text = self.navTitle
        self.view_NoData.isHidden = true
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        
        listid = Int(list.id)
        setupUI()
        self.listView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        if list.isFault {
            let predicate = NSPredicate(format: "id = %d", listid)
            guard let arrList = CoreDataHelper.sharedInstance.getListOfEntityWithName("MyList", withPredicate: predicate, sortKey: nil, isAscending: false) as? [MyList] else {
                return
            }
            
            list = arrList.first!
        }
        
        fetchListDetails()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tableView.isEditing = false
        super.viewWillAppear(animated)
    }
    
    // MARK: - Action Methods
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_OptionMenu_Action(_ sender: UIButton) {
    //@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
        if sender.tag == 12 {
            let rightBarButtonItem = UIBarButtonItem(title: " ••• ", style: .plain, target: self, action: #selector(btn_OptionMenu_Action(_:)))
            rightBarButtonItem.tag = 0
            navigationItem.rightBarButtonItem = rightBarButtonItem
            tableView.isEditing = false
            deleteButton.isHidden = true
            doneButton.isHidden = true
            selectedList = [String]()
            self.tableViewBottomHeightConstraint.constant = 0
            tableView.reloadData()
        } else {
            let alertController = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
            
            let editAction = UIAlertAction(title: "Edit".localized(), style: .default, handler: {
                (alert: UIAlertAction) -> Void in
                self.tableView.isEditing = true
                self.deleteButton.isHidden = false
                self.doneButton.isHidden = false
                
                let rightBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(self.btn_OptionMenu_Action(_:)))
                rightBarButtonItem.tag = 12
                self.navigationItem.rightBarButtonItem = rightBarButtonItem
                self.tableViewBottomHeightConstraint.constant = 50
                self.tableView.reloadData()
            })
            
            let renameAction = UIAlertAction(title: "Rename".localized(), style: .default, handler: {
                (alert: UIAlertAction) -> Void in
                self.showUpdateListAlert()
            })
            
            let deleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive, handler: {
                (alert: UIAlertAction) -> Void in
                self.showDeleteListAlert()
            })
            
            let addMoreAction = UIAlertAction(title: "Add More".localized(), style: .default, handler: {
                (alert: UIAlertAction) -> Void in
                let storyBoard = UIStoryboard(name:"MyLists", bundle:nil)
                guard let addToMyListViewController = storyBoard.instantiateViewController(withIdentifier: "AddToMyListViewController") as? AddToMyListViewController else {
                    return
                }
                addToMyListViewController.list = self.list
                addToMyListViewController.selectedList = self.allDataArray
                self.navigationController?.pushViewController(addToMyListViewController, animated: true)
            })
            
            let shareAction = UIAlertAction(title: "Share".localized(), style: .default) { (alert: UIAlertAction) in
                self.shareMyLists()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {
                (alert: UIAlertAction) -> Void in
                
            })
            
            alertController.addAction(editAction)
            alertController.addAction(renameAction)
            alertController.addAction(addMoreAction)
            alertController.addAction(shareAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func addToListButtonPressed(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name:"MyLists", bundle:nil)
        guard let addToMyListViewController = storyBoard.instantiateViewController(withIdentifier: "AddToMyListViewController") as? AddToMyListViewController else {
            return
        }
        addToMyListViewController.list = list
        self.navigationController?.pushViewController(addToMyListViewController, animated: true)
    }
    
    @IBAction func selectButtonPressed(_ sender: UIButton) {
        let listDetails = dataArray[sender.tag]
        if selectedList.contains(listDetails["id"] as? String ?? "") {
            if let index = selectedList.lastIndex(of: listDetails["id"] as! String) {
                selectedList.remove(at: index)
            }
        } else {
            selectedList.append(listDetails["id"] as! String)
        }
        tableView.reloadData()
        
        if selectedList.count > 0 {
            deleteButton.backgroundColor = .red
            deleteButton.setTitle("Delete".localized() + "(\(selectedList.count))", for: .normal)
        } else {
            deleteButton.backgroundColor = kAppMidGreyColor
            deleteButton.setTitle("Delete".localized(), for: .normal)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        reorderList()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        if selectedList.count > 0 {
            deleteSelectedList()
        } else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please select an item to delete".localized(), controller: self)
        }
    }
    
    // MARK: - Custom Methods

    func setupUI() {
        deleteButton.isHidden = true
        doneButton.isHidden = true
        listView.isHidden = false
        self.lbl_Title.text = list.list_name
        self.tableView.register(nibWithCellClass: MyListDataTableCell.self)
    }
    
    func showUpdateListAlert() {
        let objDialouge = CreateListNameDialouge(nibName:"CreateListNameDialouge", bundle:nil)
        objDialouge.is_update = true
        objDialouge.str_listName = self.lbl_Title.text ?? ""
        objDialouge.delegate = self
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
        
        
        
        /*
        let alertController = UIAlertController(title: "Rename your List".localized(), message: "Give your list a memorable name".localized(), preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "New List Name".localized()
            textField.text = self.listName
        }
        
        let saveAction = UIAlertAction(title: "Save".localized(), style: .default) { [unowned alertController] _ in
            let textField = alertController.textFields![0]
            self.updateListName((textField.text ?? ""))
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true)
        */
    }
    
    func create_listname(_ success: Bool, listname: String) {
        if success {
            self.updateListName(listname)
        }
    }
    
    func showDeleteListAlert() {
        Utils.showAlertWithTitleInControllerWithCompletion("Delete List".localized(), message: "Are you sure you want to delete this list?".localized(), cancelTitle: "Delete".localized(), okTitle: "Cancel".localized(), controller: self, completionHandler: {
            // Do Nothing
        }) {
            self.deleteList()
        }
    }
    
    func fetchListDetails() {
        self.listView.isHidden = false
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        
        if list.isFault {
            let predicate = NSPredicate(format: "id = %d", listid)
            guard let arrList = CoreDataHelper.sharedInstance.getListOfEntityWithName("MyList", withPredicate: predicate, sortKey: nil, isAscending: false) as? [MyList] else {
                return
            }
            
            list = arrList.first!
        }
        
        let urlString = kBaseNewURL + endPoint.GetListDetails.rawValue
        let params = ["listid" : list.id, "language_id" : Utils.getLanguageId()] as [String : Any]
        AF.request(urlString, method: .post, parameters:params , encoding:URLEncoding.default,headers: headers).responseJSON { response in
            
            DispatchQueue.main.async(execute: {
                Utils.stopActivityIndicatorinView(self.view)
            })
            switch response.result {
            case .success(let value):
                print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    return
                }
                
                if dicResponse["status"] as? String ?? "" == "success" {
                    guard let dataResponse = (dicResponse["data"] as? [[String : Any]]) else {
                        return
                    }
                    
                    for dic in dataResponse {
                        let myListObj = MyListDetails.createMyListDetails(listDetails: dic)
                    }
                    
                    self.getMyListDetailsFromDB()
                    
                    self.dataArray = dataResponse
                    self.allDataArray = dataResponse
                    if self.allDataArray.count > 0 {
                        self.listView.isHidden = false
                        self.view_NoData.isHidden = true
                    } else {
                        self.listView.isHidden = true
                        self.view_NoData.isHidden = false
                    }
                    self.tableView.reloadData()
                } else {
                    self.listView.isHidden = true
                    Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to get My Lists Details.".localized()), controller: self)
                }
            case .failure(let error):
                debugPrint(error)
                self.listView.isHidden = true
                Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
            }
        }
    }
    
    func updateListName(_ name: String) {
        self.listName = name
        if name.count == 0 {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please enter a valid list name".localized(), controller: self)
            return
        }
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.UpdateListById.rawValue
        
        AF.request(urlString, method: .post, parameters: ["list_name" : name, "id" : list.id], encoding:URLEncoding.default,headers: headers).responseJSON { response in
            
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
                    self.title = name
                    self.lbl_Title.text = name.capitalized
                    self.list.list_name = name
                    Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["message"] as? String ?? "Updated Successfully".localized()), controller: self)
                    self.listName = ""
                } else {
                    Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to rename to List.".localized()), controller: self)
                    
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to rename to List.".localized()), okTitle: "Ok".localized(), controller: self) {
                        self.showUpdateListAlert()
                    }
                }
            case .failure(let error):
                debugPrint(error)
                Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
            }
        }
    }
    
    func deleteListDetails(id: String, index: Int) {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.DeleteListDetails.rawValue
        let params = ["id" : id]
        AF.request(urlString, method: .post, parameters:params , encoding:URLEncoding.default,headers: headers).responseJSON { response in
            
            DispatchQueue.main.async(execute: {
                Utils.stopActivityIndicatorinView(self.view)
            })
            switch response.result {
            case .success(let value):
                print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    return
                }
                
                if dicResponse["status"] as? String ?? "" == "success" {
                    self.dataArray.remove(at: index)
                    
                    self.allDataArray.removeAll { (details) -> Bool in
                        if details["id"] as! String == id {
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    
                    if self.allDataArray.count > 0 {
                        self.listView.isHidden = false
                        self.view_NoData.isHidden = true
                    } else {
                        self.listView.isHidden = true
                        self.view_NoData.isHidden = false
                    }

                    self.tableView.reloadData()
                } else {
                    Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to delete selected item.".localized()), controller: self)
                }
            case .failure(let error):
                debugPrint(error)
                Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
            }
        }
    }
    
    func deleteList() {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.DeleteList.rawValue
        let params = ["id" : list.id]
        AF.request(urlString, method: .post, parameters:params , encoding:URLEncoding.default,headers: headers).responseJSON { response in
            
            DispatchQueue.main.async(execute: {
                Utils.stopActivityIndicatorinView(self.view)
            })
            switch response.result {
            case .success(let value):
                print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    return
                }
                
                if dicResponse["status"] as? String ?? "" == "success" {
                    CoreDataHelper.sharedInstance.deleteObject(self.list)
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to get My Lists Details.".localized()), controller: self)
                }
            case .failure(let error):
                debugPrint(error)
                Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
            }
        }
    }
    
    func deleteSelectedList() {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.DeleteMultipleListDetails.rawValue
        
        AF.upload(multipartFormData: { (multipartFormData) in
            
            let arrData =  try! JSONSerialization.data(withJSONObject: self.selectedList, options: .prettyPrinted)
            multipartFormData.append(arrData, withName: "id" as String)
        }, to:urlString, headers: headers)
            .responseJSON { (response) in
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
                        let rightBarButtonItem = UIBarButtonItem(title: " ••• ", style: .plain, target: self, action: #selector(self.btn_OptionMenu_Action(_:)))
                        rightBarButtonItem.tag = 0
                        self.navigationItem.rightBarButtonItem = rightBarButtonItem
                        self.tableView.isEditing = false
                        self.deleteButton.isHidden = true
                        self.doneButton.isHidden = true
                        
                        self.deleteButton.backgroundColor = kAppMidGreyColor
                        self.deleteButton.setTitle("Delete".localized(), for: .normal)
                        
                        for id in self.selectedList {
                            self.dataArray.removeAll { (details) -> Bool in
                                if details["id"] as! String == id {
                                    return true
                                } else {
                                    return false
                                }
                            }
                            
                            self.allDataArray.removeAll { (details) -> Bool in
                                if details["id"] as! String == id {
                                    return true
                                } else {
                                    return false
                                }
                            }
                        }
                        
                        self.tableView.reloadData()
                        self.selectedList = [String]()
                    } else {
                        Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to save My Lists.".localized()), okTitle: "Ok".localized(), controller: self) {
                        }
                    }
                case .failure(let error):
                    debugPrint(error)
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: error.localizedDescription, okTitle: "Ok".localized(), controller: self) {
                    }
                }
        }
    }
    
    func reorderList() {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.AddListReOrder.rawValue
        
        var favouriteIds = [String]()
        for dict in dataArray {
            favouriteIds.append(dict["id"] as! String)
        }
        
        let params = ["listid" : list.id, "favourite_id" : favouriteIds.joined(separator: ",")] as [String : Any]
        AF.request(urlString, method: .post, parameters:params , encoding:URLEncoding.default,headers: headers).responseJSON { response in
            
            DispatchQueue.main.async(execute: {
                Utils.stopActivityIndicatorinView(self.view)
            })
            switch response.result {
            case .success(let value):
                print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    return
                }
                
                if dicResponse["status"] as? String ?? "" == "success" {
                    let rightBarButtonItem = UIBarButtonItem(title: " ••• ", style: .plain, target: self, action: #selector(self.btn_OptionMenu_Action(_:)))
                    rightBarButtonItem.tag = 0
                    self.navigationItem.rightBarButtonItem = rightBarButtonItem
                    self.tableView.isEditing = false
                    self.deleteButton.isHidden = true
                    self.doneButton.isHidden = true
                    self.selectedList = [String]()
                    self.tableView.reloadData()
                } else {
                    Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to get My Lists Details.".localized()), controller: self)
                }
            case .failure(let error):
                debugPrint(error)
                Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
            }
        }
    }
    
    func getMyListDetailsFromDB() {
        
        let predicate = NSPredicate(format: "listid = %d", list.id)
        guard let arrList = CoreDataHelper.sharedInstance.getListOfEntityWithName("MyListDetails", withPredicate: predicate, sortKey: nil, isAscending: false) as? [MyListDetails] else {
            return
        }
//        dataArray = arrList
        tableView.reloadData()
    }
    
    func yogaSelectedAtIndex(index: Int, yoga: [String : Any]) {
        let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        let recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.yoga = Yoga.createYogaData(dicYoga: yoga)
        objYoga.recommendationVikriti = recommendationVikriti
        objYoga.recommendationPrakriti = recommendationPrakriti
        objYoga.isFromForYou = true
        objYoga.istype = .yoga
        self.present(objYoga, animated: true, completion: nil)
    }
    
    func meditationSelectedAtIndex(index: Int, meditation: [String : Any]) {
        let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        let recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.meditation = Meditation.createMeditationData(dicData: meditation)
        objYoga.recommendationVikriti = recommendationVikriti
        objYoga.recommendationPrakriti = recommendationPrakriti
        objYoga.isFromForYou = true
        objYoga.istype = .meditation
        self.present(objYoga, animated: true, completion: nil)
    }

    func pranayamaSelectedAtIndex(index: Int, pranayama: [String : Any]) {
        let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        let recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.pranayama = Pranayama.createPranayamaData(dicData: pranayama)
        objYoga.recommendationVikriti = recommendationVikriti
        objYoga.recommendationPrakriti = recommendationPrakriti
        objYoga.isFromForYou = true
        objYoga.istype = .pranayama
        self.present(objYoga, animated: true, completion: nil)
    }
    
    func mudraSelectedAtIndex(index: Int, mudra: [String : Any]) {
        let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        let recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.mudra = Mudra.createMudraData(dicData: mudra)
        objYoga.recommendationVikriti = recommendationVikriti
        objYoga.recommendationPrakriti = recommendationPrakriti
        objYoga.isFromForYou = true
        objYoga.istype = .mudra
        self.present(objYoga, animated: true, completion: nil)
    }

    func kriyaSelectedAtIndex(index: Int, kriya: [String : Any]) {
        let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        let recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.modalPresentationStyle = .fullScreen
        objYoga.kriya = Kriya.createKriyaData(dicData: kriya)
        objYoga.recommendationVikriti = recommendationVikriti
        objYoga.recommendationPrakriti = recommendationPrakriti
        objYoga.isFromForYou = true
        objYoga.istype = .kriya
        self.present(objYoga, animated: true, completion: nil)
    }
    
    func shareMyLists() {
        let text = "I just created my own list in AyuRythm!.\nCheck this out and many more on the app!".localized() + Utils.shareDownloadString
        
        let shareAll = [ text ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - UITableView Delegate and DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyListDataTableCell") as! MyListDataTableCell
        cell.selectionStyle = .none

        let list = dataArray[indexPath.row]
        let details = list["details"] as? [String : Any]
        cell.nameLabel.text = details?["name"] as? String
        cell.detailsLabel.text = details?["english_name"] as? String
        
        if let urlString = details?["image"] as? String, let url = URL(string: urlString) {
            cell.listImageView.af.setImage(withURL: url, placeholderImage:UIImage(named: "homePranayama"))
        }
        
        cell.selectButton.tag = indexPath.row
        if tableView.isEditing {
            cell.selectButton.isHidden = false
            cell.selectButtonWidthConstraint.constant = 25
            cell.selectButtonLeadngConstraint.constant = 12
            if selectedList.contains(list["id"] as! String) {
                cell.selectButton.isSelected = true
            } else {
                cell.selectButton.isSelected = false
            }
        } else {
            cell.selectButton.isHidden = true
            cell.selectButtonWidthConstraint.constant = 0
            cell.selectButtonLeadngConstraint.constant = 0
            cell.selectButton.isSelected = false
        }
        
        cell.selectButton.addTarget(self, action: #selector(self.selectButtonPressed(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let list = dataArray[indexPath.row]
        let istype = list["favourite_type"] as? String ?? ""
        let details = list["details"] as! [String : Any]
        if istype.lowercased() == "yoga" {
            yogaSelectedAtIndex(index: indexPath.row, yoga: details)
        } else if istype.lowercased() == "meditation" {
            meditationSelectedAtIndex(index: indexPath.item, meditation: details)
        } else if istype.lowercased() == "pranayama" {
            pranayamaSelectedAtIndex(index: indexPath.item, pranayama: details)
        } else if istype.lowercased() == "mudra" {
            mudraSelectedAtIndex(index: indexPath.item, mudra: details)
        } else {
            kriyaSelectedAtIndex(index: indexPath.item, kriya: details)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = dataArray[sourceIndexPath.row]
        dataArray.remove(at: sourceIndexPath.row)
        dataArray.insert(movedObject, at: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete".localized()) {action, index  in
           //handle delete
            let list = self.dataArray[indexPath.row]
            if let id = list["id"] as? String {
                self.deleteListDetails(id: id, index: indexPath.row)
            }
        }
        
        return [deleteAction]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MyListsInfoViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        dataArray.removeAll()
        dataArray = allDataArray
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        if searchText == "" {
            dataArray.removeAll()
            dataArray = allDataArray
        } else {
            dataArray =  allDataArray.filter { (data: [String : Any]) -> Bool in
                let listData = data["details"] as? [String : Any]
                let stringToCompare2 = listData?["name"] as? String ?? ""
                
                if stringToCompare2.uppercased().contains(searchText.uppercased()) {
                    return true
                } else {
                    return false
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        dataArray.removeAll()
        dataArray = allDataArray
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
