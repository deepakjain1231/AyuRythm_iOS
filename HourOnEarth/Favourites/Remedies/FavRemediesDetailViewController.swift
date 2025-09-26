//
//  FavRemediesDetailViewController.swift
//  HourOnEarth
//
//  Created by Apple on 18/04/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class FavRemediesDetailViewController: BaseViewController , UITableViewDelegate , UITableViewDataSource, FavouriteSelectedDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var remediesTableView: UITableView!
    @IBOutlet weak var heightSearch: NSLayoutConstraint!

    var remediesArr = [FavouriteHomeRemedies]()
    var allRemediesArr = [FavouriteHomeRemedies]()
    var titleRemedy: String = ""
    var isFromFavourites = true
    var isFromGlobal = false
    var searchArr = [[String: Any]]()
    var favouriteIDs = [String]()
    
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
        if isFromGlobal {
            heightSearch.constant = 0
        }
        searchBar.placeholder = "Search".localized()
        if isFromFavourites {
            allRemediesArr = remediesArr
        }
        remediesTableView.estimatedRowHeight = 66.0
        remediesTableView.rowHeight = UITableView.automaticDimension
        remediesTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        remediesTableView.register(UINib(nibName: "RemediesFavouritesCell", bundle: nil), forCellReuseIdentifier: "RemediesFavouritesCell")
        self.title = titleRemedy
        
        for searchItem in searchArr {
            let favId = searchItem["desc_id"] as? String ?? ""
            if let star = searchItem["star"] as? String, star == "yes" {
                favouriteIDs.append(favId)
            }
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
        return isFromFavourites ? remediesArr.count : searchArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView .dequeueReusableCell(withIdentifier: "RemediesFavouritesCell", for: indexPath) as! RemediesFavouritesCell
        if isFromFavourites {
            cell.lblTitle.text = remediesArr[indexPath.row].option_name ?? ""
            cell.lblDetail.text = remediesArr[indexPath.row].descriptionDetail ?? ""
            cell.lblSubCategory.text = remediesArr[indexPath.row].subcategory ?? ""
            cell.bgView.backgroundColor = UIColor().hexStringToUIColor(hex: remediesArr[indexPath.row].colour ?? "")
            cell.btnStar.isSelected = true
        } else {
            cell.lblTitle.text = searchArr[indexPath.row]["option_name"] as? String ?? ""
            cell.lblDetail.text = searchArr[indexPath.row]["description"] as? String ?? ""
            cell.btnStar.isSelected = false
            cell.lblSubCategory.text = searchArr[indexPath.row]["subcategoryname"] as? String ?? ""
            cell.bgView.backgroundColor = UIColor().hexStringToUIColor(hex: searchArr[indexPath.row]["colour"] as? String ?? "")
            let favId = searchArr[indexPath.row]["desc_id"] as? String ?? ""
            if self.favouriteIDs.contains(favId) {
                cell.btnStar.isSelected = true
            }
        }
        
        cell.btnStar.isHidden = kSharedAppDelegate.userId.isEmpty
        cell.bgView.layer.cornerRadius = 15.0
        cell.indexPath = indexPath
        cell.delegate = self
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        
        
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
        
    }
    
    func favSelectedAtIndex(index: IndexPath) {
        if isFromFavourites {
            guard let favId = remediesArr[index.row].desc_id else { return }
            self.markAsFavoutite(favId: favId, index: index)
        } else {
            guard let favId = searchArr[index.row]["desc_id"] as? String else { return }
            if !favouriteIDs.contains(favId) {
                Utils.startActivityIndicatorInView(self.view, userInteraction: false)
                addFavOnServer(params: ["favourite_type_id": favId, "favourite_type": "homeremedies" ]) {
                    self.favouriteIDs.append(favId)
                    Utils.stopActivityIndicatorinView(self.view)
                    self.remediesTableView.reloadData()
                }
            } else {
                Utils.startActivityIndicatorInView(self.view, userInteraction: false)
                deleteFavOnServer(params: ["favourite_type_id": favId , "favourite_type": "homeremedies"]) { success in
                    if success {
                        if let index = self.favouriteIDs.firstIndex(of: favId) {
                            self.favouriteIDs.remove(at: index)
                        }
                        Utils.stopActivityIndicatorinView(self.view)
                        self.remediesTableView.reloadData()

                    } else {
                        Utils.stopActivityIndicatorinView(self.view)
                    }
                }
            }
        }
    }
    
    func shareSelectedAtIndex(index: IndexPath) {
        if isFromFavourites {
            let homeRemedies = remediesArr[index.row]
            shareHomeRemedies(name: homeRemedies.option_name, discription: homeRemedies.descriptionDetail, subCategory: homeRemedies.subcategory)
        } else {
            let homeRemedies = searchArr[index.row]
            shareHomeRemedies(name: homeRemedies["option_name"] as? String, discription: homeRemedies["description"] as? String, subCategory: homeRemedies["subcategoryname"] as? String)
        }
    }
    
    func shareHomeRemedies(name: String?, discription: String?, subCategory: String?) {
        if let subCategory = subCategory, let name = name, let discription = discription {
            //print("--->>> \(name) \n\(discription)")
            
            let text = "\(name): \n\(discription) \n\n" + String(format: "I just found a home remedy for %@ on AyuRythm app.".localized(), subCategory) + Utils.shareDownloadString
            
            let shareAll = [ text ] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func markAsFavoutite(favId: String, index: IndexPath) {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        deleteFavOnServer(params: ["favourite_type_id": favId, "favourite_type": "homeremedies"]) { success in
            if success {
                CoreDataHelper.sharedInstance.deleteObject(self.remediesArr[index.row])
                self.remediesArr.remove(at: index.row)
                self.remediesTableView.reloadData()
            }
            Utils.stopActivityIndicatorinView(self.view)
        }
    }
    
    //MARK: - Naigationbar button click action
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        } else {
            completion(false)
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func addFavOnServer (params: [String: Any], completion: @escaping ()->Void) {
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
}

extension FavRemediesDetailViewController: UISearchBarDelegate {
    
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
            self.remediesArr = allRemediesArr.filter { (data: FavouriteHomeRemedies) -> Bool in
                let name = data.option_name ?? ""
                let desc = data.descriptionDetail ?? ""

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
