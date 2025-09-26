//
//  FoodDetailViewController.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 18/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class FoodDetailViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tblFoodDetail: UITableView!
    @IBOutlet weak var topConstratint: NSLayoutConstraint!
    var dataFood = Food()
    var recommendationVikriti: RecommendationType = .kapha
    var recommendationPrakriti: RecommendationType = .kapha
    var isFavourite = false
    var isFromFav = false
    var dataFoodFav = FavouriteFood()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tblFoodDetail.tableHeaderView = UIView()

        self.tblFoodDetail.tableFooterView = UIView()
        self.tblFoodDetail.estimatedRowHeight = 534.0
        tblFoodDetail.register(UINib(nibName: "FoodDetailsCell", bundle: nil), forCellReuseIdentifier: "FoodDetailsCell")
        tblFoodDetail.reloadData()
        
        if isFromFav == false
        {
            if let star = dataFood.star {
                
                self.isFavourite = !(star == "no")
            }
        }
        else
        {   if let star = dataFoodFav.star {
                self.isFavourite = !(star == "no")
            }
        }

             if #available(iOS 11.0, *) {
                 let window = UIApplication.shared.keyWindow
                 let topPadding = window?.safeAreaInsets.top
                 self.topConstratint.constant = -(topPadding ?? 0)
             }
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
       
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return UITableView.automaticDimension
       }
        
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
               return 1
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodDetailsCell") as? FoodDetailsCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        if isFromFav == false {
            cell.configureUIFood(food: dataFood, isFavourite: self.isFavourite, recPrakriti: recommendationPrakriti, recVikriti: recommendationVikriti)
        } else{
            cell.configureUIFoodFav(food: dataFoodFav, isFavourite: self.isFavourite, recPrakriti: recommendationPrakriti, recVikriti: recommendationVikriti)
        }
        cell.selectionStyle = .none
        return cell
    }

}
extension FoodDetailViewController: FoodDetailsDelegate {
    // Added by Aakash
    func shareClickedwith(hindiName: String, enName: String, desc: String) {
        #if !APPCLIP
        // Code you don't want to use in your app clip.
        let text = hindiName + "\n\n" + "Benefits".localized() + ":\n" + desc.truncated() + "\n\n" + Utils.shareRegisterDownloadString
        let shareAll = [ text ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        #else
        // Code your app clip may access.
        let text = hindiName + "\n\n" + "Benefits".localized() + ":\n" + desc.truncated()
        showAppClipsShareActivityViewController(text: text)
        #endif
    }

    func cancelClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func starClicked() {

        if isFavourite {
            //Remove
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
           
            deleteFavOnServer(params: ["favourite_type_id": isFromFav == false ? dataFood.id : dataFoodFav.id, "favourite_type": "food" ]) {
                    Utils.stopActivityIndicatorinView(self.view)
                }
           
        } else {
            //add
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            
            updateFavOnServer(params: ["favourite_type_id": isFromFav == false ? dataFood.id : dataFoodFav.id, "favourite_type": "food" ]) {
                    Utils.stopActivityIndicatorinView(self.view)
                }
        }
    }
    
}

extension FoodDetailViewController {
    func updateFavOnServer (params: [String: Any], completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.saveFourite.rawValue
           

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success:
                    Utils.showAlertWithTitleInController("Added".localized(), message: "Successfully added to your favourite list.".localized(), controller: self)
                    self.isFavourite = true
                    self.tblFoodDetail.reloadData()
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
    
    func deleteFavOnServer (params: [String: Any], completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.deleteFourite.rawValue
           

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success:
                    Utils.showAlertWithTitleInController("Removed".localized(), message: "Successfully removed from your favourite list.".localized(), controller: self)
                    self.isFavourite = false
                    self.tblFoodDetail.reloadData()
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
