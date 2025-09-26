//
//  HerbsViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 20/10/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class HerbsViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var type: RecommendationType = .kapha
    var arrHerbs: [Herb] = [Herb]()
    var arrAllHerbs: [Herb] = [Herb]()
    var isFromAyuverseContentLibrary = false

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!

    var selectedType = ""
    var selectedId = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedType
        self.navigationController?.isNavigationBarHidden = false
        setBackButtonTitle()
        searchBar.placeholder = selectedType
        getHerbDataFromServer()
    }
    
    @IBAction func selectionBtnPressed(sender: UIButton) {
        sender.isSelected.toggle()
        let item = arrHerbs[sender.tag]
        let id = String(item.id)
        ARContentLibraryManager.shared.addOrRemoveSelectContent(type: .herbs, id: id, image: item.image ?? "", selected: sender.isSelected)
    }
}

extension HerbsViewController {
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrHerbs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellFood = collectionView.dequeueReusableCell(withReuseIdentifier: "foodCell", for: indexPath) as? FoodCollectionViewCell else {
            return UICollectionViewCell()
        }
        let herb = arrHerbs[indexPath.item]
        let herbName = herb.herbs_name ?? ""
        let imageName = herb.image
        cellFood.configureFoodCell(foodName: herbName, image: imageName)
        
        if isFromAyuverseContentLibrary {
            cellFood.selectionBtn.isHidden = false
            cellFood.selectionBtn.tag = indexPath.row
            cellFood.selectionBtn.addTarget(self, action: #selector(selectionBtnPressed(sender:)), for: .touchUpInside)
            let id = String(herb.id)
            if let _ = ARContentLibraryManager.shared.selectedContents.firstIndex(where: { $0.type == .herbs && $0.id == id }) {
                cellFood.selectionBtn.isSelected = true
            } else {
                cellFood.selectionBtn.isSelected = false
            }
        } else {
            cellFood.selectionBtn.isHidden = true
        }
        return cellFood
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let herbDetails = storyBoard.instantiateViewController(withIdentifier: "HerbDetailViewController") as? HerbDetailViewController else {
            return
        }
        herbDetails.modalPresentationStyle = .fullScreen

        herbDetails.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        herbDetails.recommendationVikriti = type
        herbDetails.herbDetail = arrHerbs[indexPath.item]
        self.present(herbDetails, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGFloat = (kDeviceWidth - 40) / 3.0
        let font = UIFont.systemFont(ofSize: 12)
        let expectedHeight = heightForLable(text: arrHerbs[indexPath.item].herbs_name!, font: font, width:size)
        return CGSize(width: size, height: 137)
        //return CGSize(width: size, height: kDeviceWidth == 320.0 ? size + 60 : size + 40)
    }
    
    func heightForLable(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        // pass string, font, LableWidth
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
         label.numberOfLines = 0
         label.lineBreakMode = NSLineBreakMode.byWordWrapping
         label.font = font
         label.text = text
         label.sizeToFit()

         return label.frame.height
    }
    
}

extension HerbsViewController {
    func getHerbDataFromServer () {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.getHerbsByType.rawValue
            let params = ["item_type": type.rawValue, "type": selectedId, "language_id" : Utils.getLanguageId()] as [String : Any]
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).responseJSON{ response in
                
                switch response.result {
                    
                case .success(let value):
                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                    guard let responseJson = value as? [String: Any], let arrResponse = (responseJson["data"] as? [[String: Any]]) else {
                        return
                    }
                    let dataArray = arrResponse.compactMap{ Herb.createHerbData(dicData: $0) }
                    self.arrAllHerbs = dataArray
                    self.arrHerbs = dataArray
                    self.collectionView.reloadData()
                    Utils.stopActivityIndicatorinView(self.view)
                    //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.herbs_suggestion.rawValue)
                    
                    //self.getHerbDataFromDB()
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                    self.collectionView.reloadData()
                })
            }
        }else {
            self.getHerbDataFromDB()
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func getHerbDataFromDB() {
        guard let arrHerbs = CoreDataHelper.sharedInstance.getListOfEntityWithName("Herb", withPredicate: nil, sortKey: nil, isAscending: false) as? [Herb] else {
            return
        }
        self.arrAllHerbs = arrHerbs
        self.arrHerbs = arrHerbs
        self.collectionView.reloadData()
    }

}

extension HerbsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        if searchText == "" {
            self.arrHerbs = arrAllHerbs
        } else {
            self.arrHerbs =  arrAllHerbs.filter { (data: Herb) -> Bool in
                let herbName = data.herbs_name ?? ""
                if herbName.uppercased().contains(searchText.uppercased()) {
                    return true
                } else {
                    return false
                }
            }
        }
        self.collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       clearSearch()
    }
    
    func clearSearch() {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.arrHerbs = arrAllHerbs
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
