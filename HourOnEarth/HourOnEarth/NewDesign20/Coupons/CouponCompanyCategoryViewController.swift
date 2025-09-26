//
//  CouponCompanyCategoryViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 19/11/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class CouponCompanyModel {

    var companyName : String!
    var coupons : [CouponModel]!
    var id : String!
    var logo : String!
    var url : String!


    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        companyName = dictionary["company_name"] as? String
        coupons = [CouponModel]()
        if let categoriesArray = dictionary["categories"] as? [[String:Any]]{
            for dic in categoriesArray{
                let value = CouponModel(fromDictionary: dic)
                coupons.append(value)
            }
        }
        id = dictionary["id"] as? String
        logo = dictionary["logo"] as? String
        url = dictionary["url"] as? String ?? ""
        
        if !logo.isEmpty, !logo.hasPrefix("http") {
            logo = "https://www.ayurythm.com/" + logo
        }
    }
}

class CouponModel {

    var about : String!
    var ayuseeds : String!
    var categoryName : String!
    var colorCode : String!
    var companyId : String!
    var descriptionField : String!
    var favoriteId : String!
    var id : String!
    var image : String!
    var languageId : String!
    var message : String!
    var status : String!
    var url : String!
    var detail_image: String!
    var companyName : String!
    var couponcode : String!


    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        about = dictionary["about"] as? String
        ayuseeds = dictionary["ayuseeds"] as? String
        categoryName = dictionary["category_name"] as? String
        colorCode = dictionary["color_code"] as? String
        companyId = dictionary["company_id"] as? String
        descriptionField = dictionary["description"] as? String
        favoriteId = dictionary["favorite_id"] as? String
        id = dictionary["id"] as? String
        image = dictionary["image"] as? String ?? ""
        detail_image = dictionary["detail_image"] as? String ?? ""
        languageId = dictionary["language_id"] as? String
        message = dictionary["message"] as? String
        status = dictionary["status"] as? String
        url = dictionary["url"] as? String
        companyName = dictionary["company_name"] as? String ?? ""
        couponcode = dictionary["couponcode"] as? String ?? ""
    }

    func getBGAndTintColors() -> (UIImage, UIColor) {
        if colorCode == "1" {
            return (#imageLiteral(resourceName: "coupon-bg-yellow"), .darkGray)
        } else if colorCode == "2" {
            return (#imageLiteral(resourceName: "coupon-bg-green"), .darkGray)
        } else {
            return (#imageLiteral(resourceName: "coupon-bg-blue"), .white)
        }
    }
}

class CouponCompanyCategoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var couponCompanies = [CouponCompanyModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Buy Coupons!".localized()
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //setupUI()
    }
    
    func setupUI() {
        showActivityIndicator()
        CouponCompanyCategoryViewController.getCouponsFromServer { (isSuccess, message, couponCompanies) in
            if isSuccess {
                self.couponCompanies = couponCompanies
                self.tableView.reloadData()
                self.hideActivityIndicator()
            } else {
                self.hideActivityIndicator()
                self.showAlert(message: message)
            }
        }
    }
    
    static func showScreen(presentingVC: UIViewController) {
        presentingVC.showActivityIndicator()
        CouponCompanyCategoryViewController.getCouponsFromServer { (isSuccess, message, couponCompanies) in
            if isSuccess {
                presentingVC.hideActivityIndicator()
                if let couponCompany = couponCompanies.first, couponCompanies.count == 1 {
                    CouponListViewController.showCoupons(couponCompany: couponCompany, presentingVC: presentingVC)
                } else {
                    let vc = CouponCompanyCategoryViewController.instantiateFromStoryboard("Coupons")
                    vc.couponCompanies = couponCompanies
                    presentingVC.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                presentingVC.hideActivityIndicator()
                presentingVC.showAlert(message: message)
            }
        }
    }
}

extension CouponCompanyCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return couponCompanies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CouponCategoryCell") as? CouponCategoryCell else {
            return UITableViewCell()
        }
        
        cell.couponCompany = couponCompanies[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CouponListViewController.showCoupons(couponCompany: couponCompanies[indexPath.row], presentingVC: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CouponCompanyCategoryViewController {
    
    static func getCouponsFromServer(completion: @escaping (Bool, String, [CouponCompanyModel])->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.getAllThirdPartyCouponsList.rawValue

            AF.request(urlString, method: .post, parameters: ["language_id" : Utils.getLanguageId()], encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        completion(false, "", [CouponCompanyModel]())
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? "Fail to get coupons, please try after some time".localized()
                    var data = [CouponCompanyModel]()
                    if let dataArray = dicResponse["data"] as? [[String: Any]] {
                        data = dataArray.map{ CouponCompanyModel(fromDictionary: $0) }
                    }
                    let isSuccess = (status.lowercased() == "Success".lowercased())
                    completion(isSuccess, message, data)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription, [CouponCompanyModel]())
                }
            }
        } else {
            completion(false, NO_NETWORK, [CouponCompanyModel]())
        }
    }
}

class CouponCategoryCell: UITableViewCell {
    
    @IBOutlet weak var companyNameL: UILabel!
    
    var couponCompany: CouponCompanyModel? {
        didSet {
            guard let couponCompany = couponCompany else { return }
            
            companyNameL.text = couponCompany.companyName
        }
    }
}
