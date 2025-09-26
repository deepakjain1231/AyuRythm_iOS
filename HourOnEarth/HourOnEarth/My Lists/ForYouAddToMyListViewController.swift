//
//  ForYouAddToMyListViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 25/07/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

protocol ForYouAddToMyListDelegate: class {
    func refreshView()
}

class ForYouAddToMyListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: ForYouAddToMyListDelegate?
    var dataArray = [MyList]()
    var selectedList = [String]()
    var favouriteType: IsSectionType = .yoga
    var favouriteId = String()
    var id = String()
    var listName = ""
    
    // MARK: View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if tableView != nil {
            tableView.tableFooterView = UIView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyLists()
    }

    // MARK: - Action Methods
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createListButtonPressed(_ sender: UIButton) {
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
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let list = dataArray[sender.tag];
        if selectedList.contains("\(list.id)") {
            // Do Nothing
        } else {
            self.selectedList.append("\(list.id)")
        }
        tableView.reloadData()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        addToList()
    }
    
    // MARK: - Custom Methods
    
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
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to get My Lists.".localized()), okTitle: "Ok".localized(), controller: self) {
                    }
                }
            case .failure(let error):
                debugPrint(error)
                Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: error.localizedDescription, okTitle: "Ok".localized(), controller: self) {
                }
            }
        }
    }
    
    func saveListName(_ name: String) {
        self.listName = name
        if name.count == 0 {
            Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: "Please enter a valid list name".localized(), okTitle: "Ok".localized(), controller: self) {
            }
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
                print("API URL: - \(urlString)\n\nParams: - \n\nResponse: - \(response)")
                guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                    return
                }
                
                if dicResponse["status"] as? String ?? "" == "success" {
                    let message = dicResponse["message"] as? String ?? ""
                    guard let dataResponse = (dicResponse["response"] as? [[String : Any]]) else {
                        return
                    }
                    
                    let list = MyList.createMyList(list: dataResponse.first!)
                    self.dataArray.append(list!)
                    self.tableView.reloadData()
                    self.listName = ""
//                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: "Added Successfully.".localized(), okTitle: "Ok".localized(), controller: self) {
//                    }
                    let finalMessage = name + " " + "list created successfully".localized()
                    self.addEarnHistoryFromServer(addListMessage: finalMessage, list: list!)
                } else {
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to save My Lists.").localized(), okTitle: "Ok".localized(), controller: self) {
                        self.createListButtonPressed(UIButton())
                    }
                }
            case .failure(let error):
                debugPrint(error)
                Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: error.localizedDescription, okTitle: "Ok".localized(), controller: self) {
                    
                }
            }
        }
    }
    
    func addToList() {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.AddListDetails.rawValue
        
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(self.favouriteId.data(using: String.Encoding.utf8)!, withName: "favourite_id")
            if (self.favouriteType == .yoga) {
                multipartFormData.append("yoga".data(using: String.Encoding.utf8)!, withName: "favourite_type")
            } else if (self.favouriteType == .pranayama) {
                multipartFormData.append("pranayama".data(using: String.Encoding.utf8)!, withName: "favourite_type")
            } else if (self.favouriteType == .meditation) {
                multipartFormData.append("meditation".data(using: String.Encoding.utf8)!, withName: "favourite_type")
            } else if (self.favouriteType == .kriya) {
                multipartFormData.append("kriya".data(using: String.Encoding.utf8)!, withName: "favourite_type")
            } else if (self.favouriteType == .mudra) {
                multipartFormData.append("mudra".data(using: String.Encoding.utf8)!, withName: "favourite_type")
            }
            
            let arrData =  try! JSONSerialization.data(withJSONObject: self.selectedList, options: .prettyPrinted)
            multipartFormData.append(arrData, withName: "listid" as String)
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
                        if (self.favouriteType == .yoga) {
                            Yoga.updateYogaForMyList(id: self.id, selectedList: self.selectedList.joined(separator: ","))
                        } else if (self.favouriteType == .pranayama) {
                            Pranayama.updatePranayamaForMyList(id: self.id, selectedList: self.selectedList.joined(separator: ","))
                        } else if (self.favouriteType == .meditation) {
                            Meditation.updateMeditationForMyList(id: self.id, selectedList: self.selectedList.joined(separator: ","))
                        } else if (self.favouriteType == .kriya) {
                            Kriya.updateKriyaForMyList(id: self.id, selectedList: self.selectedList.joined(separator: ","))
                        } else if (self.favouriteType == .mudra) {
                            Mudra.updateMudraForMyList(id: self.id, selectedList: self.selectedList.joined(separator: ","))
                        }
                        
                        if self.delegate != nil {
                            self.delegate?.refreshView()
                        }
                        
                        self.dismiss(animated: true, completion: nil)
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
    
    func getMyListFromDB() {
        guard let arrYoga = CoreDataHelper.sharedInstance.getListOfEntityWithName("MyList", withPredicate: nil, sortKey: nil, isAscending: false) as? [MyList] else {
            return
        }
        dataArray = arrYoga
        tableView.reloadData()
    }
    
    // MARK: - UITableView Delegate and DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as? MyListsTableViewCell else {
            return UITableViewCell()
        }
        
        let list = dataArray[indexPath.row]
        cell.nameLabel.text = list.list_name
        cell.addButton.tag = indexPath.row
        if selectedList.contains("\(list.id)") {
            cell.addButton.isSelected = true
        } else {
            cell.addButton.isSelected = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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

extension ForYouAddToMyListViewController {
    func addEarnHistoryFromServer(addListMessage: String, list: MyList) {
        let params = ["activity_favorite_id": AyuSeedEarnActivity.userList.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
        ReferPopupViewController.addEarmHistoryFromServer(params: params) { (isSuccess, title, message) in
            print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
            self.hideActivityIndicator()
            if isSuccess {
                Utils.showAlertWithTitleInControllerWithCompletion(title, message: message, okTitle: "Ok".localized(), controller: self) {
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: addListMessage, okTitle: "Ok".localized(), controller: self) {
//                        let storyBoard = UIStoryboard(name:"MyLists", bundle:nil)
//                        guard let listsInfoViewController = storyBoard.instantiateViewController(withIdentifier: "MyListsInfoViewController") as? MyListsInfoViewController else {
//                            return
//                        }
//                        listsInfoViewController.list = list
//                        self.navigationController?.pushViewController(listsInfoViewController, animated: true)
                    }
                }
            } else {
                Utils.showAlertWithTitleInController(APP_NAME, message: addListMessage, controller: self)
            }
        }
    }
}
