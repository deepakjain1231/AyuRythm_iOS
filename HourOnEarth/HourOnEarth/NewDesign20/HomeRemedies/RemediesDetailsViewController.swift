//
//  RemediesDetailsViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 6/4/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class RemediesDetailsViewController: BaseViewController , UITableViewDelegate , UITableViewDataSource, FavouriteSelectedDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var remediesTableView: UITableView!
    
    var remediesArr = [HomeRemediesDescription]()
    var allRemediesArr = [HomeRemediesDescription]()
    var dicSelectedInfo: HomeRemediesDetail?
    var isFromAyuverseContentLibrary = false
    var arr_BG_Design = [["bg_color": "#FFFAF0", "header_color": "#E0D774", "image_1": "home_remedies_design1_1", "image_2": "home_remedies_design1"],
                         ["bg_color": "#DFFFF5", "header_color": "#92DCC3", "image_1": "", "image_2": "home_remedies_design2"],
                         ["bg_color": "#FDF2EF", "header_color": "#E3A090", "image_1": "", "image_2": "home_remedies_design3"],
                         ["bg_color": "#E5EFFB", "header_color": "#87B9F3", "image_1": "", "image_2": "home_remedies_design4"],
                         ["bg_color": "#FFFAF0", "header_color": "#E0D774", "image_1": "home_remedies_design1_1", "image_2": "home_remedies_design1"],
                                              ["bg_color": "#DFFFF5", "header_color": "#92DCC3", "image_1": "", "image_2": "home_remedies_design2"],
                                              ["bg_color": "#FDF2EF", "header_color": "#E3A090", "image_1": "", "image_2": "home_remedies_design3"],
                                              ["bg_color": "#E5EFFB", "header_color": "#87B9F3", "image_1": "", "image_2": "home_remedies_design4"],
                         ["bg_color": "#FFFAF0", "header_color": "#E0D774", "image_1": "home_remedies_design1_1", "image_2": "home_remedies_design1"],
                                              ["bg_color": "#DFFFF5", "header_color": "#92DCC3", "image_1": "", "image_2": "home_remedies_design2"],
                                              ["bg_color": "#FDF2EF", "header_color": "#E3A090", "image_1": "", "image_2": "home_remedies_design3"],
                                              ["bg_color": "#E5EFFB", "header_color": "#87B9F3", "image_1": "", "image_2": "home_remedies_design4"],
                         ["bg_color": "#FFFAF0", "header_color": "#E0D774", "image_1": "home_remedies_design1_1", "image_2": "home_remedies_design1"],
                                              ["bg_color": "#DFFFF5", "header_color": "#92DCC3", "image_1": "", "image_2": "home_remedies_design2"],
                                              ["bg_color": "#FDF2EF", "header_color": "#E3A090", "image_1": "", "image_2": "home_remedies_design3"],
                                              ["bg_color": "#E5EFFB", "header_color": "#87B9F3", "image_1": "", "image_2": "home_remedies_design4"],
                         ["bg_color": "#FFFAF0", "header_color": "#E0D774", "image_1": "home_remedies_design1_1", "image_2": "home_remedies_design1"],
                                              ["bg_color": "#DFFFF5", "header_color": "#92DCC3", "image_1": "", "image_2": "home_remedies_design2"],
                                              ["bg_color": "#FDF2EF", "header_color": "#E3A090", "image_1": "", "image_2": "home_remedies_design3"],
                                              ["bg_color": "#E5EFFB", "header_color": "#87B9F3", "image_1": "", "image_2": "home_remedies_design4"],
                         ["bg_color": "#FFFAF0", "header_color": "#E0D774", "image_1": "home_remedies_design1_1", "image_2": "home_remedies_design1"],
                                              ["bg_color": "#DFFFF5", "header_color": "#92DCC3", "image_1": "", "image_2": "home_remedies_design2"],
                                              ["bg_color": "#FDF2EF", "header_color": "#E3A090", "image_1": "", "image_2": "home_remedies_design3"],
                                              ["bg_color": "#E5EFFB", "header_color": "#87B9F3", "image_1": "", "image_2": "home_remedies_design4"],
                         ["bg_color": "#FFFAF0", "header_color": "#E0D774", "image_1": "home_remedies_design1_1", "image_2": "home_remedies_design1"],
                                              ["bg_color": "#DFFFF5", "header_color": "#92DCC3", "image_1": "", "image_2": "home_remedies_design2"],
                                              ["bg_color": "#FDF2EF", "header_color": "#E3A090", "image_1": "", "image_2": "home_remedies_design3"],
                                              ["bg_color": "#E5EFFB", "header_color": "#87B9F3", "image_1": "", "image_2": "home_remedies_design4"],
                         ["bg_color": "#FFFAF0", "header_color": "#E0D774", "image_1": "home_remedies_design1_1", "image_2": "home_remedies_design1"],
                                              ["bg_color": "#DFFFF5", "header_color": "#92DCC3", "image_1": "", "image_2": "home_remedies_design2"],
                                              ["bg_color": "#FDF2EF", "header_color": "#E3A090", "image_1": "", "image_2": "home_remedies_design3"],
                                              ["bg_color": "#E5EFFB", "header_color": "#87B9F3", "image_1": "", "image_2": "home_remedies_design4"],
                         ["bg_color": "#FFFAF0", "header_color": "#E0D774", "image_1": "home_remedies_design1_1", "image_2": "home_remedies_design1"],
                                              ["bg_color": "#DFFFF5", "header_color": "#92DCC3", "image_1": "", "image_2": "home_remedies_design2"],
                                              ["bg_color": "#FDF2EF", "header_color": "#E3A090", "image_1": "", "image_2": "home_remedies_design3"],
                                              ["bg_color": "#E5EFFB", "header_color": "#87B9F3", "image_1": "", "image_2": "home_remedies_design4"],
                         ["bg_color": "#FFFAF0", "header_color": "#E0D774", "image_1": "home_remedies_design1_1", "image_2": "home_remedies_design1"],
                                              ["bg_color": "#DFFFF5", "header_color": "#92DCC3", "image_1": "", "image_2": "home_remedies_design2"],
                                              ["bg_color": "#FDF2EF", "header_color": "#E3A090", "image_1": "", "image_2": "home_remedies_design3"],
                                              ["bg_color": "#E5EFFB", "header_color": "#87B9F3", "image_1": "", "image_2": "home_remedies_design4"]]
    
    //-------------view controller life cycle ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = "Search".localized()
        remediesTableView.estimatedRowHeight = 66.0
        remediesTableView.rowHeight = UITableView.automaticDimension
        remediesTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        remediesTableView.register(UINib(nibName: "RemediesDetailsCell", bundle: nil), forCellReuseIdentifier: "RemediesDetailsCell")
        self.title = dicSelectedInfo?.item ?? ""
        self.getDetailsFromServer {
            
        }
        setBackButtonTitle()
        
        if UserDefaults.user.is_remedies_subscribed == false {
            //Home Remedies Showing Count
            let free_done_count = UserDefaults.user.home_remedies_trial + 1
            UserDefaults.user.set_home_remidies_trial_count(data: free_done_count)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //------------- Statusbar setting ----------------------------------------------------------------
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Tableview datasource & Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remediesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView .dequeueReusableCell(withIdentifier: "RemediesDetailsCell", for: indexPath) as! RemediesDetailsCell
        let remedie = remediesArr[indexPath.row]
        cell.lblTitle.text = remedie.option_name ?? ""
        cell.lblDetail.text = remedie.discription ?? ""
        cell.delegate = self
        cell.indexPath = indexPath
        cell.btnStar.isSelected = false
        if let star = remedie.star, star == "yes" {
            cell.btnStar.isSelected = true
        }
        cell.btnStar.isHidden = kSharedAppDelegate.userId.isEmpty
        cell.bgView.backgroundColor = UIColor().hexStringToUIColor(hex: remedie.colour ?? "")
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        
        if isFromAyuverseContentLibrary {
            cell.starSareBtnView.isHidden = true
            cell.selectionBtn.isHidden = false
            let id = String(remedie.desc_id)
            if let _ = ARContentLibraryManager.shared.selectedContents.firstIndex(where: { $0.type == .homeRemedies && $0.id == id }) {
                cell.selectionBtn.isSelected = true
            } else {
                cell.selectionBtn.isSelected = false
            }
        }
        
        //for Background Design
        let dic_colorSet = self.arr_BG_Design[indexPath.row]
        cell.bgView.backgroundColor = UIColor.fromHex(hexString: (dic_colorSet["bg_color"] ?? ""))
        cell.view_Header_bg.backgroundColor = UIColor.fromHex(hexString: (dic_colorSet["header_color"] ?? ""))
        let img1_name = (dic_colorSet["image_1"] ?? "")
        let img2_name = (dic_colorSet["image_2"] ?? "")
        cell.img_design_1.image = UIImage.init(named: img1_name)
        cell.img_design_2.image = UIImage.init(named: img2_name)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let remedie = remediesArr[indexPath.row]
        let id = String(remedie.desc_id)
        if let cell = tableView.cellForRow(at: indexPath) as? RemediesDetailsCell {
            cell.selectionBtn.isSelected.toggle()
            ARContentLibraryManager.shared.addOrRemoveSelectContent(type: .homeRemedies, id: id, image: "", selected: cell.selectionBtn.isSelected)
        }
    }
    
    func favSelectedAtIndex(index: IndexPath) {
        let favId = remediesArr[index.row].desc_id
        if remediesArr[index.row].star == "no" {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            updateFavOnServer(params: ["favourite_type_id": favId, "favourite_type": "homeremedies" ]) {
                self.getDetailsFromServer {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
        } else {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            deleteFavOnServer(params: ["favourite_type_id": favId , "favourite_type": "homeremedies"]) { success in
                if success {
                    self.getDetailsFromServer {
                        Utils.stopActivityIndicatorinView(self.view)
                    }
                } else {
                    Utils.stopActivityIndicatorinView(self.view)
                }
            }
        }
    }
    
    func shareSelectedAtIndex(index: IndexPath) {
        let homeRemedies = remediesArr[index.row]
        if let subCategory = dicSelectedInfo?.item, let remedyName = homeRemedies.option_name, let discription = homeRemedies.discription {
            //print("--->>> \(remedyName) \n\(discription)")
            
            let text = "\(remedyName): \n\(discription) \n\n" + String(format: "I just found a home remedy for %@ on AyuRythm app.".localized(), subCategory) + Utils.shareDownloadString
            
            let shareAll = [ text ] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    //MARK: - Naigationbar button click action
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getDetailsFromServer (completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: true)
            let urlString = kBaseNewURL + endPoint.v2.homeRemediesDesc.rawValue
            let remedieID = "\(dicSelectedInfo?.id  ?? 0)"
            let params = ["cat_type": remedieID, "language_id" : Utils.getLanguageId()] as [String : Any]
           

            AF.request(urlString, method: .post, parameters: params as Parameters, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                Utils.stopActivityIndicatorinView(self.view)
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let arrResponse = (value as? [[String: Any]]) else {
                        completion()
                        return
                    }
                    CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "HomeRemediesDescription")
                    for dic in arrResponse {
                        HomeRemediesDescription.createHomeRemediesDescriptionData(dicData: dic)
                    }
                    self.getRemediesDescriptionDataFromDB()
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                completion()
            }
        }else {
            getRemediesDescriptionDataFromDB()
            completion()
        //    Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func getRemediesDescriptionDataFromDB() {
        let remedieID = dicSelectedInfo?.id ?? 0
        let predicate = NSPredicate(format: "remedies_id = %d", remedieID)
        guard let arrRemedies = CoreDataHelper.sharedInstance.getListOfEntityWithName("HomeRemediesDescription", withPredicate: predicate, sortKey: nil, isAscending: true) as? [HomeRemediesDescription] else {
            return
        }
        self.remediesArr = arrRemedies
        self.allRemediesArr = arrRemedies
        self.remediesTableView.reloadData()
    }
    
    func updateFavOnServer (params: [String: Any], completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.saveFourite.rawValue
          

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success:
                    Utils.showAlertWithTitleInController("Added".localized(), message: "Successfully added to your favourite list.".localized(), controller: self)

                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                completion()
            }
        }else {
            completion()
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    
    func deleteFavOnServer (params: [String: Any], completion: @escaping (Bool)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.deleteFourite.rawValue
          

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success:
                    Utils.showAlertWithTitleInController("Removed".localized(), message: "Successfully removed from your favourite list.".localized(), controller: self)
                    completion(true)
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                    completion(false)
                }
            }
        }else {
            completion(false)
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
}


extension RemediesDetailsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        self.remediesArr = self.allRemediesArr
        self.remediesTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        if searchText == "" {
            self.remediesArr = self.allRemediesArr
        } else {
            self.remediesArr = allRemediesArr.filter { (data: HomeRemediesDescription) -> Bool in
                let name = data.option_name ?? ""
                let desc = data.discription ?? ""

                if name.uppercased().contains(searchText.uppercased()) || desc.uppercased().contains(searchText.uppercased()){
                    return true
                } else {
                    return false
                }
            }
        }
        self.remediesTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       clearSearch()
    }
    
    func clearSearch() {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.remediesArr = self.allRemediesArr
        remediesTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
