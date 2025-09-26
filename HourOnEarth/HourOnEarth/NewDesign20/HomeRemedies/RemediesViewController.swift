//
//  RemediesViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 6/4/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class RemediesViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate {
    
    var remediesArr = [[String: String]]()
    var remediesArrAll = [[String: String]]()
    
    @IBOutlet weak var remediesTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchEnable = false
    
    //-------------view controller life cycle ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        //searchController.searchBar.barTintColor = UIColor(red: 128.0/255.0, green: 199.0/255.0, blue: 130.0/255/0, alpha: 1.0)
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.placeholder = "Search Remedy".localized()
        definesPresentationContext = true
        self.remediesTableView.tableHeaderView = searchController.searchBar
        remediesTableView.tableFooterView=UIView(frame: CGRect.zero)
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.getRemediesFromServer()
        //end
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchController.searchBar.text = ""
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView .dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let categoryName = cell.contentView.viewWithTag(1000) as! UILabel
        categoryName.text = remediesArr[indexPath.row]["name"]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        var arrRemedy = [String]()
        
        let dicRemedy = remediesArr[indexPath.row]
        
        for index in 1...(dicRemedy.keys.count - 2) {
            let key = "remedie\(index)"
            let value: String = dicRemedy[key]!.replacingOccurrences(of: "\n", with: "")
            if !value.isEmpty {
                arrRemedy.append(value)
            }
        }
        
//        for key in dicRemedy.keys.sorted() {
//            if key == "name" || key == "id" {
//                continue
//            }
//            let value: String = dicRemedy[key]!.replacingOccurrences(of: "\n", with: "")
//            if !value.isEmpty {
//                arrRemedy.append(value)
//            }
//        }
        
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let objRemedyView:RemediesDetailsViewController = storyBoard.instantiateViewController(withIdentifier: "RemediesDetailsViewController") as! RemediesDetailsViewController
     //  objRemedyView.titleRemedy = dicRemedy["name"] ?? ""
        self.navigationController?.pushViewController(objRemedyView, animated: true)
        
    }
    
    //MARK: - Naigationbar button click action
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension RemediesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchController.searchBar.text ?? ""
        
        
        if searchText == "" {
            remediesArr.removeAll()
            remediesArr = remediesArrAll
        } else {
            remediesArr =  remediesArrAll.filter { (category:[String: String]) -> Bool in
                if let name = category["name"] {
                    if name.uppercased().contains(searchText.uppercased()) {
                        return true
                    } else {
                        return false
                    }
                }
                return false
            }
        }
        self.remediesTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        remediesArr.removeAll()
        remediesArr = remediesArrAll
        remediesTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

//    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
//        searchBar.showsCancelButton = true
//        isSearchEnable = true
//        self.lblHint.isHidden = true
//        categoriesArr.removeAll()
//        categoriesTableView.reloadData()
//        return true
//    }
}


extension RemediesViewController {
    func getRemediesFromServer () {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + "homeremedies.php"
            AF.request(urlString, method: .get, parameters: nil, encoding:URLEncoding.default).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let arrQuestions = (value as? [[String: String]]) else {
                        
                        return
                    }
                    self.remediesArrAll = arrQuestions
                    self.remediesArr = arrQuestions
                    self.remediesTableView.reloadData()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
}
