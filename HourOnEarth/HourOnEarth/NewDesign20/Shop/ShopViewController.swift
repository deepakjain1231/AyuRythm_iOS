//
//  ShopViewController.swift
//  HourOnEarth
//
//  Created by Apple on 21/01/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

enum ShopRowType {
    case categories(categories: [[String: Any]])
    case recommended(dic: [[String: Any]])
    case featured(dic: [[String: Any]])
}

class ShopViewController: BaseViewController {

    @IBOutlet weak var tblViewShop: UITableView!
    
    var shopArray = [ShopRowType]()
    var arrCategories = [[String: Any]]()
    var arrRecomCategories = [[String: Any]]()
    var arrFeaturedCategories = [[String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblViewShop.register(UINib(nibName: "ShopCategoriesCell", bundle: nil), forCellReuseIdentifier: "ShopCategoriesCell")
        tblViewShop.register(UINib(nibName: "ShopProductsCell", bundle: nil), forCellReuseIdentifier: "ShopProductsCell")

        self.getCategoriesFromServer()
        self.getFeaturedFromServer()
        self.getRecommendationFromServer()
    }
}

extension ShopViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 126
        }
        return 265
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = shopArray[indexPath.row]
        switch rowType {
        case .categories(let categories):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCategoriesCell") as? ShopCategoriesCell else {
                return UITableViewCell()
            }
            cell.configureUI(dataArray: categories)
            return cell
            
        case .featured(let arrProducts):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShopProductsCell") as? ShopProductsCell else {
                return UITableViewCell()
            }
            cell.configureUI(dataArray: arrProducts, flowType: .featured)
            return cell
            
        case .recommended(let arrProducts):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShopProductsCell") as? ShopProductsCell else {
                return UITableViewCell()
            }
            cell.configureUI(dataArray: arrProducts, flowType: .recommended)
            return cell
        }
    }
    
}

extension ShopViewController {
    
    func prepareData() {
        shopArray.removeAll()
        shopArray.append(.categories(categories: self.arrCategories))
        shopArray.append(.recommended(dic: arrRecomCategories))
        shopArray.append(.featured(dic: arrFeaturedCategories))
        self.tblViewShop.reloadData()
    }
    
    func getCategoriesFromServer () {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseUrlShop + endPoint.shopCategories.rawValue
         

            AF.request(urlString, method: .get, parameters: nil, encoding:URLEncoding.default,headers: headers).responseJSON { response in
                
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? [String: Any]) else {
                        return
                    }
                    self.arrCategories = dicResponse["children_data"] as! [[String : Any]]
                    self.prepareData()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
            }
        }else {
            // Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func getFeaturedFromServer () {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseUrlShop + endPoint.shopFeatured.rawValue
        

            AF.request(urlString, method: .get, parameters: nil, encoding:URLEncoding.default,headers: headers).responseJSON { response in
                
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? [String: Any]) else {
                        return
                    }
                    self.arrRecomCategories = dicResponse["items"] as! [[String : Any]]
                    self.prepareData()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
            }
        }else {
            // Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func getRecommendationFromServer () {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseUrlShop + endPoint.shopRecommendation.rawValue
          

            AF.request(urlString, method: .get, parameters: nil, encoding:URLEncoding.default,headers: headers).responseJSON { response in
                
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? [String: Any]) else {
                        return
                    }
                    self.arrFeaturedCategories = dicResponse["items"] as! [[String : Any]]
                    self.prepareData()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
            }
        }else {
            // Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
}
