//
//  FoodsViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 5/26/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class FoodsViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var type: RecommendationType = .kapha
    var arrFood: [Food] = [Food]()
    var arrAllFoods: [Food] = [Food]()
    var isFromAyuverseContentLibrary = false

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!

    var selectedType = ""
    var selectedId = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedType
        self.navigationController?.isNavigationBarHidden = false
        searchBar.placeholder = selectedType
        getFoodDataFromServer()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentClicked() {
        clearSearch()
    }
    
    func getFilteredData(selectedSegment: Int) -> [Food] {
        if selectedSegment == 0 {
            return self.arrAllFoods.filter({ ($0.food_status ?? "") == "favor"})
        } else {
            return self.arrAllFoods.filter({ ($0.food_status ?? "") == "avoid"})
        }
    }
    
    @IBAction func selectionBtnPressed(sender: UIButton) {
        sender.isSelected.toggle()
        let item = arrFood[sender.tag]
        let id = String(item.id)
        ARContentLibraryManager.shared.addOrRemoveSelectContent(type: .food, id: id, image: item.image ?? "", selected: sender.isSelected)
    }
}

extension FoodsViewController {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFood.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellFood = collectionView.dequeueReusableCell(withReuseIdentifier: "foodCell", for: indexPath) as? FoodCollectionViewCell else {
            return UICollectionViewCell()
        }
        let food = arrFood[indexPath.item]
        let foodName = food.food_name ?? ""
        let imageName = food.image
        cellFood.configureFoodCell(foodName: foodName, image: imageName)
        
        if isFromAyuverseContentLibrary {
            cellFood.selectionBtn.isHidden = false
            cellFood.selectionBtn.tag = indexPath.row
            cellFood.selectionBtn.addTarget(self, action: #selector(selectionBtnPressed(sender:)), for: .touchUpInside)
            let id = String(food.id)
            if let _ = ARContentLibraryManager.shared.selectedContents.firstIndex(where: { $0.type == .food && $0.id == id }) {
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
        guard let objFoodDetails = storyBoard.instantiateViewController(withIdentifier: "FoodDetailViewController") as? FoodDetailViewController else {
            return
        }
        objFoodDetails.modalPresentationStyle = .fullScreen

        objFoodDetails.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        objFoodDetails.recommendationVikriti = type
        objFoodDetails.dataFood = arrFood[indexPath.item];
        self.present(objFoodDetails, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGFloat = (kDeviceWidth - 40) / 3.0
        let font = UIFont.systemFont(ofSize: 12)
        let expectedHeight = heightForLable(text: arrFood[indexPath.item].food_name!, font: font, width:size)
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

extension FoodsViewController {
    func getFoodDataFromServer () {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.v2.getFoodByType.rawValue
            let params = ["item_type": type.rawValue, "type": selectedId, "language_id" : Utils.getLanguageId()] as [String : Any]
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).responseJSON{ response in
                
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let arrFood = (value as? [[String: Any]]) else {
                        return
                    }
                    CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Food")
                    for dic in arrFood {
                        Food.createFoodData(dicData: dic)
                    }

                    self.getFoodDataFromDB()
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
            self.getFoodDataFromDB()
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
    
    func getFoodDataFromDB() {
        guard let arrFood = CoreDataHelper.sharedInstance.getListOfEntityWithName("Food", withPredicate: nil, sortKey: nil, isAscending: false) as? [Food] else {
            return
        }
        self.arrAllFoods = []
        self.arrAllFoods = arrFood
        self.arrFood = []
        self.arrFood = self.getFilteredData(selectedSegment: 0)
        self.collectionView.reloadData()
    }

}

extension FoodsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        self.arrFood = getFilteredData(selectedSegment: self.segmentControl.selectedSegmentIndex)
        self.collectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        if searchText == "" {
            self.arrFood = getFilteredData(selectedSegment: self.segmentControl.selectedSegmentIndex)
        } else {
            let originalData = getFilteredData(selectedSegment: self.segmentControl.selectedSegmentIndex)
            self.arrFood =  originalData.filter { (data: Food) -> Bool in
                let foodName = data.food_name ?? ""
                if foodName.uppercased().contains(searchText.uppercased()) {
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
        self.arrFood = getFilteredData(selectedSegment: self.segmentControl.selectedSegmentIndex)
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
