//
//  AddToMyListViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 25/07/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class AddToMyListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var navTitle = ""
    var typeResponse = [ForYouSectionType : Any]()
    var dataArray = [NSManagedObject]()
    var allDataArray = [NSManagedObject]()
    var selectedList = [[String: Any]]()
    var sectionTypes = [ForYouSectionType]()
    var list = MyList()
    var listid = 0
    var selectedType: ForYouSectionType = .yoga
    var recommendationVikriti: RecommendationType = .kapha
    var recommendationPrakriti: RecommendationType = .kapha
    
    var selectedIndex: IndexPath?
    var accessPoint = 0
    var name = ""
    var favID = 0
    
    // MARK: View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_Title.text = self.navTitle
        listid = Int(list.id)
        setupUI()
        if tableView != nil {
            tableView.tableFooterView = UIView()
        }
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
        
        recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        refreshData()
    }

    // MARK: - Action Methods
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Done_Action(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonPressed(sender: UIButton) {
        var fav_id = ""
        var fav_type = ""
        if selectedType == .yoga {
            let list = dataArray[sender.tag] as! Yoga;
            fav_type = "yogasana"
            fav_id = list.favorite_id ?? ""
        }
        else if selectedType == .pranayama {
            let list = dataArray[sender.tag] as! Pranayama;
            fav_type = "pranayama"
            fav_id = list.favorite_id ?? ""
        }
        else if selectedType == .meditation {
            let list = dataArray[sender.tag] as! Meditation;
            fav_type = "meditation"
            fav_id = list.favorite_id ?? ""
        }
        else if selectedType == .kriya {
            let list = dataArray[sender.tag] as! Kriya;
            fav_type = "kriya"
            fav_id = list.favorite_id ?? ""
        }
        else if selectedType == .mudra {
            let list = dataArray[sender.tag] as! Mudra;
            fav_type = "mudra"
            fav_id = list.favorite_id ?? ""
        }

        if let indx = self.selectedList.firstIndex(where: { dic_list in
            let str_favId = dic_list["favourite_id"] as? String ?? ""
            let str_favType = dic_list["favourite_type"] as? String ?? ""
            return str_favId == fav_id && str_favType == fav_type
        }) {
            removeFromList(id: fav_id, listObj: [String : Any]())
        } else {
            addToList(favouriteId: fav_id, favouriteType: fav_type)
        }
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        title = list.list_name
        collectionView.isHidden = true;
        collectionView.cornerRadiuss = 10
        collectionView.clipsToBounds = true
        self.tableView.register(nibWithCellClass: PlayListTableCell.self)
        self.collectionView.register(nibWithCellClass: ForYouFilterCollectionCell.self)
        self.infoLabel.text = "\(self.selectedList.count)" + " " + "Items Added".localized()
    }
    
    func refreshData(selectedType: ForYouSectionType = .yoga) {
        let group = DispatchGroup()
        dataArray.removeAll()
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        
        if selectedType == .yoga {
            group.enter()
            self.getYogaFromServer(goal_type: .Yogasana, completion: {
                group.leave()
            })
        }
        
        if selectedType == .pranayama {
            group.enter()
            self.getYogaFromServer(goal_type: .Pranayama, completion: {
                group.leave()
            })
        }

        if selectedType == .meditation {
            group.enter()
            self.getYogaFromServer(goal_type: .Meditation, completion: {
                group.leave()
            })
        }
        
        if selectedType == .mudra {
            group.enter()
            self.getYogaFromServer(goal_type: .Mudras, completion: {
                group.leave()
            })
        }

        if selectedType == .kriya {
            group.enter()
            self.getYogaFromServer(goal_type: .Kriyas, completion: {
                group.leave()
            })
        }

        group.notify(queue: .main) {
            Utils.stopActivityIndicatorinView(self.view)
            self.sectionTypes = [.yoga, .pranayama, .meditation, .kriya, .mudra]
            self.collectionView.isHidden = false
            self.selectedType = selectedType
            self.allDataArray = self.typeResponse[self.selectedType] as! [NSManagedObject]
            self.dataArray = self.allDataArray
            self.collectionView.reloadData()
            self.tableView.reloadData()
            
            if let selectedIndex = self.selectedIndex {
                self.tableView.scrollToRow(at: selectedIndex, at: .none, animated: false)
                self.selectedIndex = nil
            }
        }
    }
    
    func addToList(favouriteId: String, favouriteType : String) {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        let urlString = kBaseNewURL + endPoint.AddListDetails.rawValue
        
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(favouriteId.data(using: String.Encoding.utf8)!, withName: "favourite_id")
            multipartFormData.append(favouriteType.lowercased().data(using: String.Encoding.utf8)!, withName: "favourite_type")
            
            var list = [Int32]()
            list.append(self.list.id)
            
            let arrData =  try! JSONSerialization.data(withJSONObject: list, options: .prettyPrinted)
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
                        guard let dataResponse = (dicResponse["data"] as? [[String : Any]]) else {
                            return
                        }
                        
                        let myListObj = MyListDetails.createMyListDetails(listDetails: dataResponse.first!)

                        self.selectedList.append(dataResponse.first!)
                        self.infoLabel.text = "\(self.selectedList.count)" + " " + "Items Added".localized()
                        self.tableView.reloadData()
                    } else {
                        Utils.showAlertWithTitleInController(APP_NAME, message: (dicResponse["message"] as? String ?? "Failed to save My Lists.".localized()), controller: self)
                    }
                case .failure(let error):
                    debugPrint(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
        }
    }
    
    func removeFromList(id: String, listObj: [String : Any]) {
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
                    if let indx = self.selectedList.firstIndex(where: { dic_list in
                        let str_id = dic_list["id"] as? String ?? ""
                        return str_id == id
                    }) {
                        self.selectedList.remove(at: indx)
                    }

                    self.infoLabel.text = "\(self.selectedList.count)" + " " + "Items Added".localized()
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
    
    // MARK: - UITableView Delegate and DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListTableCell") as! PlayListTableCell
        cell.selectionStyle = .none
        cell.lbl_time.text = ""
        
        var list_image: String?
        var list_access_point = 0
        var list_redeemed = false
        var list_favorite_id = ""
        var list_favorite_type = ""
        
        if selectedType == .yoga {
            let list = dataArray[indexPath.row] as! Yoga
            list_image = list.image
            list_favorite_type = "yogasana"
            list_redeemed = list.redeemed
            list_favorite_id = list.favorite_id ?? ""
            list_access_point = Int(list.access_point)
            cell.lbl_title.text = list.name
            cell.lbl_sub_title.text = list.english_name
            cell.addButton.tag = indexPath.row
            cell.lbl_unlock_ayuseed.text = "\(list.access_point)"
            cell.lbl_unlock_ayuseed_title.text = list.redeemed ? "" : "Unlock with"
        }
        else if selectedType == .pranayama {
            let list = dataArray[indexPath.row] as! Pranayama
            list_image = list.image
            list_favorite_type = "pranayama"
            list_redeemed = list.redeemed
            list_favorite_id = list.favorite_id ?? ""
            list_access_point = Int(list.access_point)
            cell.lbl_title.text = list.name
            cell.lbl_sub_title.text = list.english_name
            cell.addButton.tag = indexPath.row
            cell.lbl_unlock_ayuseed.text = "\(list.access_point)"
            cell.lbl_unlock_ayuseed_title.text = list.redeemed ? "" : "Unlock with"
        }
        else if selectedType == .meditation {
            let list = dataArray[indexPath.row] as! Meditation
            list_image = list.image
            list_favorite_type = "meditation"
            list_redeemed = list.redeemed
            list_favorite_id = list.favorite_id ?? ""
            list_access_point = Int(list.access_point)
            cell.lbl_title.text = list.name
            cell.lbl_sub_title.text = list.english_name
            cell.addButton.tag = indexPath.row
            cell.lbl_unlock_ayuseed.text = "\(list.access_point)"
            cell.lbl_unlock_ayuseed_title.text = list.redeemed ? "" : "Unlock with"
        }
        else if selectedType == .mudra {
            let list = dataArray[indexPath.row] as! Mudra
            list_image = list.image
            list_favorite_type = "mudra"
            list_redeemed = list.redeemed
            list_favorite_id = list.favorite_id ?? ""
            list_access_point = Int(list.access_point)
            cell.lbl_title.text = list.name
            cell.lbl_sub_title.text = list.english_name
            cell.addButton.tag = indexPath.row
            cell.lbl_unlock_ayuseed.text = "\(list.access_point)"
            cell.lbl_unlock_ayuseed_title.text = list.redeemed ? "" : "Unlock with"
        }
        else if selectedType == .kriya {
            let list = dataArray[indexPath.row] as! Kriya
            list_image = list.image
            list_favorite_type = "kriya"
            list_redeemed = list.redeemed
            list_favorite_id = list.favorite_id ?? ""
            list_access_point = Int(list.access_point)
            cell.lbl_title.text = list.name
            cell.lbl_sub_title.text = list.english_name
            cell.addButton.tag = indexPath.row
            cell.lbl_unlock_ayuseed.text = "\(list.access_point)"
            cell.lbl_unlock_ayuseed_title.text = list.redeemed ? "" : "Unlock with"
        }
        
        
        if let urlString = list_image, let url = URL(string: urlString) {
            cell.imgThumb.af.setImage(withURL: url, placeholderImage:UIImage(named: "homePranayama"))
        }
        
        if (list_access_point == 0 || list_redeemed) {
            cell.addButton.isHidden = false
            cell.lockView.isHidden = true
            cell.view_unlock_ayuseed.isHidden = true
        } else {
            cell.addButton.isHidden = true
            cell.lockView.isHidden = false
            cell.view_unlock_ayuseed.isHidden = false
        }
        
        if let indx = self.selectedList.firstIndex(where: { dic_list in
            let fav_id = dic_list["favourite_id"] as? String ?? ""
            let fav_type = dic_list["favourite_type"] as? String ?? ""
            return fav_id == list_favorite_id && fav_type == list_favorite_type
        }) {
            cell.addButton.setImage(UIImage.init(named: "icon_selected_playlist"), for: .normal)
        } else {
            cell.addButton.setImage(UIImage.init(named: "icon_plus_gray_add"), for: .normal)
        }
        
        
        cell.addButton.addTarget(self, action: #selector(addButtonPressed(sender:)), for: .touchUpInside)

        cell.didTappedonLockView = { (sender) in
            self.startUnlockItemPrecess(at: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MyListsTableViewCell, !cell.lockView.isHidden {
            //Means show unlock item alert
            startUnlockItemPrecess(at: indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func startUnlockItemPrecess(at indexPath: IndexPath) {
        self.selectedIndex = indexPath
        if selectedType == .yoga, let data = self.dataArray[indexPath.row] as? Yoga {
            accessPoint = Int(data.access_point)
            name = "yoga"
            favID = Int(data.id)
        }
        else if selectedType == .meditation, let data = self.dataArray[indexPath.row] as? Meditation {
            accessPoint = Int(data.access_point)
            name = "meditation"
            favID = Int(data.id)
        }
        else if selectedType == .pranayama, let data = self.dataArray[indexPath.row] as? Pranayama {
            accessPoint = Int(data.access_point)
            name = "pranayama"
            favID = Int(data.id)
        }
        else if selectedType == .mudra, let data = self.dataArray[indexPath.row] as? Mudra {
            accessPoint = Int(data.access_point)
            name = "mudra"
            favID = 0
        }
        else if selectedType == .kriya, let data = self.dataArray[indexPath.row] as? Kriya {
            accessPoint = Int(data.access_point)
            name = "kriya"
            favID = 0
        }
        
        
        AyuSeedsRedeemManager.shared.redeemItem(accessPoint: accessPoint, name: name, favID: favID, presentingVC: self.tabBarController ?? self) { [weak self] (isSuccess, isSubscriptionResumeSuccess, title, message) in
            guard let self = self else { return }
            
            /*if self.selectedType == .yoga, let data = self.dataArray[self.selectedIndex.row] as? Yoga {
                data.redeemed = true
                self.dataArray[self.selectedIndex.row] = data
            } else if self.selectedType == .meditation, let data = self.dataArray[self.selectedIndex.row] as? Meditation {
                data.redeemed = true
                self.dataArray[self.selectedIndex.row] = data
            } else if self.selectedType == .pranayama, let data = self.dataArray[self.selectedIndex.row] as? Pranayama {
                data.redeemed = true
                self.dataArray[self.selectedIndex.row] = data
            } else if self.selectedType == .mudra, let newDataArray = self.dataArray as? [Mudra] {
                newDataArray.forEach{ $0.redeemed = true }
                self.dataArray = newDataArray
            } else if self.selectedType == .kriya, let newDataArray = self.dataArray as? [Kriya] {
                newDataArray.forEach{ $0.redeemed = true }
                self.dataArray = newDataArray
            }
            self.tableView.reloadData()*/
            self.refreshData(selectedType: self.selectedType)
        }
    }
    
    // MARK: - UICollectionView Delegate and DataSource Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sectionTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForYouFilterCollectionCell", for: indexPath as IndexPath) as? ForYouFilterCollectionCell else {
            return UICollectionViewCell()
        }
        cell.lbl_Title.text = self.sectionTypes[indexPath.item].title
        if sectionTypes[indexPath.item] == selectedType {
            cell.lbl_Title.textColor = UIColor.white
            cell.view_Base.backgroundColor = AppColor.app_GreenColor
            cell.view_Base.layer.borderColor = UIColor.clear.cgColor
        }
        else {
            cell.view_Base.backgroundColor = .white
            cell.lbl_Title.textColor = UIColor.fromHex(hexString: "#111111").withAlphaComponent(0.8)
            cell.view_Base.layer.borderColor = UIColor.fromHex(hexString: "#111111").withAlphaComponent(0.8).cgColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        collectionView.deselectItem(at: indexPath, animated: true)
        selectedType = sectionTypes[indexPath.item]
        
        if let arr_temp = typeResponse[selectedType] as? [NSManagedObject] {
            allDataArray = arr_temp
            dataArray = allDataArray
            collectionView.reloadData()
            tableView.reloadData()
            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
        else {
            self.refreshData(selectedType: selectedType)
        }
        
        
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

extension AddToMyListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        dataArray.removeAll()
//        dataArray = allDataArray
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        if searchText == "" {
            dataArray.removeAll()
//            dataArray = allDataArray
        } else {
//            dataArray = allDataArray.filter { (data: [String : Any]) -> Bool in
//                let stringToCompare2 = data["name"] as? String ?? ""
//
//                if stringToCompare2.uppercased().contains(searchText.uppercased()) {
//                    return true
//                } else {
//                    return false
//                }
//            }
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        dataArray.removeAll()
//        dataArray = allDataArray
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

//    func getYogaFromServer(completion: @escaping ()-> Void) {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.getForYouYoga.rawValue
//            let params = ["type": recommendationVikriti.rawValue,"typetwo": recommendationPrakriti.rawValue, "language_id" : Utils.getLanguageId(), "from": "list"] as [String : Any]
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//
//                defer {
//                    completion()
//                }
//                switch response.result {
//
//                case .success(let value):
//                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
//                    guard let arrQuestions = (value as? [[String: AnyObject]]) else {
//
//                        return
//                    }
//                    for dic in arrQuestions {
//                        _ = Yoga.createYogaData(dicYoga: dic)
//                    }
//                    self.getYogaFromDB()
//
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                DispatchQueue.main.async(execute: {
//                    Utils.stopActivityIndicatorinView(self.view)
//                })
//            }
//        } else {
//            self.getYogaFromDB()
//            completion()
//        }
//    }
    
//    func getPranayamaFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.getPranayamaios.rawValue
//            let params = ["type": recommendationVikriti.rawValue,"typetwo": recommendationPrakriti.rawValue, "language_id" : Utils.getLanguageId(), "from": "list"] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    for dic in arrResponse {
//                        _ = Pranayama.createPranayamaData(dicData: dic)
//                    }
//                    self.getPranayamaDataFromDB()
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            self.getPranayamaDataFromDB()
//            completion()
//        }
//    }
    
//    func getMeditationFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.getMeditationios.rawValue
//            let params = ["type": recommendationVikriti.rawValue,"typetwo": recommendationPrakriti.rawValue, "language_id" : Utils.getLanguageId(), "from": "list"] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    for dic in arrResponse {
//                        Meditation.createMeditationData(dicData: dic)
//                    }
//                    self.getMeditationDataFromDB()
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            self.getMeditationDataFromDB()
//            completion()
//            // Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
//        }
//    }
    
//    func getMudraFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.getMudraios.rawValue
//            let params = ["type": recommendationVikriti.rawValue,"typetwo": recommendationPrakriti.rawValue, "language_id" : Utils.getLanguageId(), "from": "list"] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    for dic in arrResponse {
//                        _ = Mudra.createMudraData(dicData: dic)
//                    }
//                    self.getMudraDataFromDB()
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            self.getMudraDataFromDB()
//            completion()
//        }
//    }
    
    
//    func getKriyaFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.getKriyaios.rawValue
//            let params = ["type": recommendationVikriti.rawValue,"typetwo": recommendationPrakriti.rawValue, "language_id" : Utils.getLanguageId(), "from": "list"] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    for dic in arrResponse {
//                        _ = Kriya.createKriyaData(dicData: dic)
//                    }
//                    self.getKriyaDataFromDB()
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            self.getKriyaDataFromDB()
//            completion()
//        }
//    }
    
    func getYogaFromDB() {
        let predicate1 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        let predicate2 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationPrakriti.rawValue)
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])

        guard let arrYoga = CoreDataHelper.sharedInstance.getListOfEntityWithName("Yoga", withPredicate: predicate, sortKey: "name", isAscending: true) as? [Yoga] else {
            return
        }
        let arrSorted = arrYoga.sorted { (obj1, obj2) -> Bool in
            return obj1.access_point < obj2.access_point
        }

        self.typeResponse[.yoga] = arrSorted;
    }
    
    func getPranayamaDataFromDB() {
        let predicate1 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        let predicate2 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationPrakriti.rawValue)
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
        guard let arrPrananyam = CoreDataHelper.sharedInstance.getListOfEntityWithName("Pranayama", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Pranayama] else {
            return
        }
        let arrSorted = arrPrananyam.sorted { (obj1, obj2) -> Bool in
            return obj1.access_point < obj2.access_point
        }

        self.typeResponse[.pranayama] = arrSorted;
    }
    
    func getMeditationDataFromDB() {
        let predicate1 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        let predicate2 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationPrakriti.rawValue)
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
        guard let arrMeditation = CoreDataHelper.sharedInstance.getListOfEntityWithName("Meditation", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Meditation] else {
            return
        }
        let arrSorted = arrMeditation.sorted { (obj1, obj2) -> Bool in
            return obj1.access_point < obj2.access_point
        }

        self.typeResponse[.meditation] = arrSorted;
    }
    
    func getMudraDataFromDB() {
        let predicate1 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        let predicate2 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationPrakriti.rawValue)
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
        guard let arrMudra = CoreDataHelper.sharedInstance.getListOfEntityWithName("Mudra", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Mudra] else {
            return
        }
        
        self.typeResponse[.mudra] = arrMudra;
    }
    
    func getKriyaDataFromDB() {
        let predicate1 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        let predicate2 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationPrakriti.rawValue)
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
        guard let arrKriya = CoreDataHelper.sharedInstance.getListOfEntityWithName("Kriya", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Kriya] else {
            return
        }
        
        self.typeResponse[.kriya] = arrKriya;
    }

}




//MARK: - API Call
extension AddToMyListViewController {
    
    func getYogaFromServer (goal_type: TodayGoal_Type, completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.getKriyaiOS_NewAPI.rawValue
            
            var params = ["from": "foryou",
                          "today_keys": "",//Video fav ID from Todaysgoal api
                          "list_type": "",
                          "type": recommendationVikriti.rawValue,
                          "typetwo": Utils.getYourCurrentPrakritiStatus().rawValue,
                          "language_id" : Utils.getLanguageId()] as [String : Any]
            
#if !APPCLIP
        params["type"] = appDelegate.cloud_vikriti_status
#endif
            
            if goal_type == .Yogasana {
                params["list_type"] = "yogasana"
            }
            else if goal_type == .Pranayama {
                params["list_type"] = "pranayam"
            }
            else if goal_type == .Meditation {
                params["list_type"] = "meditation"
            }
            else if goal_type == .Kriyas {
                params["list_type"] = "kriya"
            }
            else if goal_type == .Mudras {
                params["list_type"] = "mudra"
            }
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let arrResponse = (value as? [[String: Any]]) else {
                        completion()
                        return
                    }
                    if goal_type == .Yogasana {

                        for dic in arrResponse {
                            _ = Yoga.createYogaData(dicYoga: dic)
                        }
                        self.getYogaFromDB()

                    }
                    else if goal_type == .Pranayama {
                        
                        for dic in arrResponse {
                            _ = Pranayama.createPranayamaData(dicData: dic)
                        }
                        self.getPranayamaDataFromDB()
                        
                    }
                    else if goal_type == .Meditation {

                        for dic in arrResponse {
                            Meditation.createMeditationData(dicData: dic)
                        }
                        self.getMeditationDataFromDB()
                        
                    }
                    else if goal_type == .Kriyas {

                        for dic in arrResponse {
                            _ = Kriya.createKriyaData(dicData: dic)
                        }
                        self.getKriyaDataFromDB()
                        
                    }
                    else if goal_type == .Mudras {

                        for dic in arrResponse {
                            _ = Mudra.createMudraData(dicData: dic)
                        }
                        self.getMudraDataFromDB()

                    }
                    
                    if let arr_temp = self.typeResponse[self.selectedType] as? [NSManagedObject] {
                        self.allDataArray = arr_temp
                        self.dataArray = self.allDataArray
                        self.collectionView.reloadData()
                        self.tableView.reloadData()                        
                    }
                    

                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                completion()
            }
        } else {
            if goal_type == .Yogasana {
                getYogaFromDB()
            }
            else if goal_type == .Pranayama {
                self.getPranayamaDataFromDB()
            }
            else if goal_type == .Meditation {
                self.getMeditationDataFromDB()
            }
            else if goal_type == .Kriyas {
                self.getKriyaDataFromDB()
            }
            else if goal_type == .Mudras {
                self.getMudraDataFromDB()
            }
            completion()
        }
    }
}
