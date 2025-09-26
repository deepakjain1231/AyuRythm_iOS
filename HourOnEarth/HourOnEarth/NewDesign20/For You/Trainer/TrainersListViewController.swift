//
//  TrainersListViewController.swift
//  HourOnEarth
//
//  Created by Ayu on 15/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class TrainersListViewController: BaseViewController {//}, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //@IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tbl_view: UITableView!
    @IBOutlet weak var lbl_Title: UILabel!
    
    var dataArray = [Trainer]()
    var trainerArray = [Trainer]()
    var recommendationVikriti: RecommendationType = .kapha
    var isRequiredLoadingDataFromServer = false
    
    
    // MARK: - View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            self.tbl_view.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        
        //Register Table Cell
        self.tbl_view.register(nibWithCellClass: TrainerListTableCell.self)
        
        
        
        let rightButtonItem = UIBarButtonItem(image: UIImage(named: "invalidName_menu"), style: .plain, target: self, action: #selector(rightButtonAction(sender:)))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        searchBar.placeholder = "Trainers".localized()
        self.title = "Trainers".localized()
        self.lbl_Title.text = "Trainers".localized()
        self.dataArray = trainerArray
        
        if isRequiredLoadingDataFromServer {
            showActivityIndicator()
            getTrainerDetailsFromServer {
                self.hideActivityIndicator()
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Action Methods
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Filter_Action(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objFilterView = storyBoard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController else {
            return
        }
        objFilterView.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(objFilterView, animated: true)
    }
    
    @objc func rightButtonAction(sender: UIBarButtonItem) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objFilterView = storyBoard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController else {
            return
        }
        objFilterView.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(objFilterView, animated: true)
        //present(objFilterView, animated: true, completion: nil)
    }
    
    // MARK: - Custom Methods
    
    func getFilterByTags(arrYoga: [Yoga]) -> [Yoga] {
        guard Shared.sharedInstance.filterTags.count > 0 else {
            return arrYoga
        }
        var filteredArray = [Yoga]()
        for yoga in arrYoga {
            let benefits = (yoga.benefits?.allObjects as? [Benefits] ?? []).compactMap({$0.benefitsname})
            let filteredData = Shared.sharedInstance.filterTags.filter({benefits.contains($0)})
            if filteredData.count > 0 {
                filteredArray.append(yoga)
            }
        }
        return filteredArray
    }
    
    func getFilterByLevels(arrYoga: [Yoga]) -> [Yoga] {
        guard Shared.sharedInstance.filterLevels.count > 0 else {
            return arrYoga
        }
        var filteredArray = [Yoga]()
        for yoga in arrYoga {
            if Shared.sharedInstance.filterLevels.contains(yoga.experiencelevel ?? "") {
                filteredArray.append(yoga)
            }
        }
        return filteredArray
    }
    /*
    //MARK: - CollectionViewDataSource and Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getCellForYoga(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kDeviceWidth/2, height: kDeviceWidth/2)
    }
    
    func getCellForYoga(indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "TrainerCell", for: indexPath as IndexPath) as? HOEYogaCell else {
            return UICollectionViewCell()
        }
        let trainer = dataArray[indexPath.row]
        cell.indexPath = indexPath
        cell.lblEngName.text = trainer.name
        cell.lockView.isHidden = true
        
        if let url = URL(string: trainer.image ?? "") {
            cell.imgThumb.af.setImage(withURL: url)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    */
}

//MARK: - UITableView Delegate DataSource Method
extension TrainersListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainerListTableCell", for: indexPath) as! TrainerListTableCell
        cell.selectionStyle = .none

        let trainer = self.dataArray[indexPath.row]
        cell.lbl_Title.text = trainer.name ?? ""
        cell.lbl_subTitle.text = (trainer.type ?? "").capitalized

        if let url = URL(string: trainer.image ?? "") {
            cell.img_Thumb.af.setImage(withURL: url)
        }
        
        //Action See Program
        cell.didTappedonSeeProgram = { (sender) in
            let objYoga = Story_ForYou.instantiateViewController(withIdentifier: "TrainerDetailsViewController") as! TrainerDetailsViewController
            objYoga.trainer = self.dataArray[indexPath.row]
            self.navigationController?.pushViewController(objYoga, animated: true)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension TrainersListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        dataArray = trainerArray

        self.tbl_view.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        if searchText == "" {
            
        } else {
            
        }
        self.tbl_view.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        dataArray = trainerArray
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        tbl_view.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension TrainersListViewController {
    func getTrainerDetailsFromServer(completion: @escaping ()-> Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.getTrainer.rawValue
            
            var param = ["type": recommendationVikriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
            param["type"] = appDelegate.cloud_vikriti_status
            
            AF.request(urlString, method: .post, parameters: param, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                defer {
                    completion()
                }
                switch response.result {
                
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        return
                    }
                    
                    guard let dataResponse = (dicResponse["response"] as? [[String : Any]]) else {
                        return
                    }
                    
                    CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "TrainerPackage")
                    CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "PackageTimeSlot")
                    for dic in dataResponse {
                        Trainer.createTrainerData(dicData: dic)
                    }
                    self.getTrainerFromDB()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        } else {
            self.getTrainerFromDB()
            completion()
        }
    }
    
    func getTrainerFromDB() {
        guard let arrTrainer = CoreDataHelper.sharedInstance.getListOfEntityWithName("Trainer", withPredicate: nil, sortKey: nil, isAscending: false) as? [Trainer] else {
            return
        }
        
        dataArray = arrTrainer
        tbl_view.reloadData()
    }
}
