//
//  PlayListDetailVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 31/12/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class PlayListDetailVC: UIViewController {

    var type = ""
    var navTitle = ""
    var playListId = 0
    var arr_PlayList = [PlayListDetails]()
    var sectionTypes = [ForYouSectionType]()
    var is_selectedType: ForYouSectionType = .yoga
    var recommendationVikriti: RecommendationType = .kapha
    
    var favID = Int()
    var name = String()
    var accessPoint = Int()
    var unlockIndexPath = IndexPath()
    var dicResponse = [[String: Any]]()
    
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var collection_view: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_title.text = self.navTitle
        self.recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        self.tbl_View.register(nibWithCellClass: PlayListRowCell.self)
        self.tbl_View.register(nibWithCellClass: PlayListTableCell.self)
        self.tbl_View.tableFooterView = UIView()
        
        self.setupUI()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.callAPIFor_getPlayListDetailsFromServer()
        }
    }
    
    
    // MARK: - Custom Methods
    func setupUI() {
        self.collection_view.isHidden = true;
        self.collection_view.cornerRadiuss = 10
        self.collection_view.clipsToBounds = true
        self.collection_view.register(nibWithCellClass: ForYouFilterCollectionCell.self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: - Action Methods
    @IBAction func btn_Back_Pressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - API CALL
extension PlayListDetailVC {
    
    func callAPIFor_getPlayListDetailsFromServer() {
        if Utils.isConnectedToNetwork() {
            
            self.showActivityIndicator()
            
            let urlString = kBaseNewURL + endPoint.v2.getExpLevelPlayList.rawValue
            var params = ["type": recommendationVikriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
            if type == "benefit" {
                params["benid"] = "\(playListId)"
            } else {
                params["expid"] = "\(playListId)"
            }
            params["type"] = appDelegate.cloud_vikriti_status
            
            debugPrint("API URL: - \(urlString)\n\nParams: - \(params)")
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let arrPlayList = (value as? [[String: AnyObject]]) else {
                        return
                    }

                    self.sectionTypes.removeAll()
                    CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "PlayListDetails")

                    if arrPlayList.count != 0{
                        
                        for dic in arrPlayList {
                            PlayListDetails.createPlayListDetailsData(dicData: dic)
                            
                            if let detailsData = dic["details"] as? [[String: Any]], detailsData.count != 0 {
                                
                                let type = dic["type"] as? String ?? ""
                                if type == "Yoga" || type == "Yogasana" {
                                    self.sectionTypes.append(.yoga)
                                }
                                else if type == "Pranayama" {
                                    self.sectionTypes.append(.pranayama)
                                }
                                else if type == "Meditation" {
                                    self.sectionTypes.append(.meditation)
                                }
                                else if type == "Kriyas" || type == "Kriya" {
                                    self.sectionTypes.append(.kriya)
                                }
                                else if type == "Mudras" || type == "Mudra" {
                                    self.sectionTypes.append(.mudra)
                                }
                            }
                        }
                        
                        if self.sectionTypes.count != 0 {
                            self.is_selectedType = self.sectionTypes[0]
                        }
                        
                    }

                    self.getPlayListFromDB()
                    
                    self.collection_view.isHidden = false
                    self.collection_view.reloadData()
                    
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    self.hideActivityIndicator()
                })
            }
        } else {
            self.getPlayListFromDB()
        }
    }
    
    func getPlayListFromDB() {
        guard let arrPlayList = CoreDataHelper.sharedInstance.getListOfEntityWithName("PlayListDetails", withPredicate: nil, sortKey: nil, isAscending: false) as? [PlayListDetails] else {
            return
        }
        self.arr_PlayList = arrPlayList
        debugPrint(arrPlayList.count)
        debugPrint(arrPlayList)
        self.tbl_View.reloadData()
    }
}

//MARK: - UITableViewDelegate Datasource Method
extension PlayListDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func getDetailsData(type: PlayListDetailType) -> [NSManagedObject] {
        var dataArray = [NSManagedObject]()

        debugPrint(self.arr_PlayList)
        debugPrint(self.arr_PlayList.count)
        
        
        for dic_playList in self.arr_PlayList {
            if type == .Yoga {
                if (dic_playList.type ?? "").lowercased() == "yogasana" || (dic_playList.type ?? "").lowercased() == "yoga" {
                    dataArray = dic_playList.yoga?.allObjects as! [NSManagedObject]
                }
            }
            else if type == .Kriyas {
                if (dic_playList.type ?? "").lowercased() == "kriyas" || (dic_playList.type ?? "").lowercased() == "kriya" {
                    dataArray = dic_playList.kriyas?.allObjects as! [NSManagedObject]
                }
            }
            else if type == .Meditation {
                if (dic_playList.type ?? "").lowercased() == "meditation" {
                    dataArray = dic_playList.meditation?.allObjects as! [NSManagedObject]
                }
            }
            else if type == .Pranayama {
                if (dic_playList.type ?? "").lowercased() == "pranayama" {
                    dataArray = dic_playList.pranayama?.allObjects as! [NSManagedObject]
                }
            }
            else if type == .Mudras {
                if (dic_playList.type ?? "").lowercased() == "mudras" || (dic_playList.type ?? "").lowercased() == "mudra" {
                    dataArray = dic_playList.mudras?.allObjects as! [NSManagedObject]
                }
            }
        }
        
        
//        switch type {
//        case .Yoga:
//            dataArray = self.arr_PlayList.filter({$0.type == type.rawValue}).first?.yoga?.allObjects as! [NSManagedObject]
//        case .Kriyas:
//            dataArray = self.arr_PlayList.filter({$0.type == type.rawValue}).first?.kriyas?.allObjects as! [NSManagedObject]
//        case .Meditation:
//            dataArray = self.arr_PlayList.filter({$0.type == type.rawValue}).first?.meditation?.allObjects as! [NSManagedObject]
//        case .Pranayama:
//            dataArray = self.arr_PlayList.filter({$0.type == type.rawValue}).first?.pranayama?.allObjects as! [NSManagedObject]
//        case .Mudras:
//            dataArray = self.arr_PlayList.filter({$0.type == type.rawValue}).first?.mudras?.allObjects as! [NSManagedObject]
//            
//        }
        
        debugPrint(dataArray)
        debugPrint(dataArray.count)
        
        return dataArray
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1// self.arr_PlayList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if let type = self.arr_PlayList[section].type,
        
        debugPrint(self.is_selectedType.title)
        if self.arr_PlayList.count != 0 {
            if let selectedType =  PlayListDetailType(rawValue: self.is_selectedType.title) {
                
                
                debugPrint(self.getDetailsData(type: selectedType).count)
                
                return self.getDetailsData(type: selectedType).count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListTableCell", for: indexPath) as! PlayListTableCell
        cell.selectionStyle = .none

        //guard let type = self.arr_PlayList[indexPath.section].type,
                
        guard let selectedType =  PlayListDetailType(rawValue: self.is_selectedType.title) else {
            return UITableViewCell()
        }
        let data = self.getDetailsData(type: selectedType)[indexPath.row]
        switch selectedType {
        case .Yoga:
            guard let yoga = data as? Yoga else {
                return UITableViewCell()
            }
            cell.configureUI(yoga: yoga)
            let isLock = yoga.access_point > 0 ? !yoga.redeemed : false
            cell.toggleLockView(isLock: isLock)

        case .Kriyas:
            guard let kriya = data as? Kriya else {
                return UITableViewCell()
            }
            cell.configureUIKriya(kriya: kriya)

            let isLock = kriya.access_point > 0 ? !kriya.redeemed : false
            cell.toggleLockView(isLock: isLock)
            
        case .Meditation:
           guard let meditation = data as? Meditation else {
                return UITableViewCell()
            }
            cell.configureUIMeditation(meditation: meditation)
            let isLock = meditation.access_point > 0 ? !meditation.redeemed : false
            cell.toggleLockView(isLock: isLock)
            
        case .Pranayama:
           guard let pranayama = data as? Pranayama else {
                return UITableViewCell()
            }
            cell.configureUIPranayama(pranayama: pranayama)
            let isLock = pranayama.access_point > 0 ? !pranayama.redeemed : false
            cell.toggleLockView(isLock: isLock)
            
        case .Mudras:
            guard let mudra = data as? Mudra else {
                return UITableViewCell()
            }
            cell.configureUIMudra(mudra: mudra)
            let isLock = mudra.access_point > 0 ? !mudra.redeemed : false
            cell.toggleLockView(isLock: isLock)
        }
        cell.selectionStyle = .none
        cell.isFromPlayListDetailScreen = true
        cell.indexPath = indexPath
        //cell.delegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //guard let type = self.arr_PlayList[indexPath.section].type, 
        guard let selectedType =  PlayListDetailType(rawValue: self.is_selectedType.title) else {
            return
        }
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objView = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objView.modalPresentationStyle = .fullScreen
        
        let data = self.getDetailsData(type: selectedType)[indexPath.row]
        switch selectedType {
        case .Yoga:
            guard let yoga = data as? Yoga else {
                return
            }
            objView.istype = .yoga
            objView.yoga = yoga
            
        case .Kriyas:
            guard let kriya = data as? Kriya else {
                return
            }
            objView.istype = .kriya
            objView.kriya = kriya

        case .Meditation:
           guard let meditation = data as? Meditation else {
                return
            }
            objView.istype = .meditation
            objView.meditation = meditation

        case .Pranayama:
           guard let pranayama = data as? Pranayama else {
                return
            }
            objView.istype = .pranayama
            objView.pranayama = pranayama

        case .Mudras:
            guard let mudra = data as? Mudra else {
                return
            }
            objView.istype = .mudra
            objView.mudra = mudra
        }
        
        self.present(objView, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Delegate and DataSource Methods
extension PlayListDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        
        if self.sectionTypes[indexPath.item].title == "Yoga" {
            cell.lbl_Title.text = "Yogasana".localized()
        }
        else {
            cell.lbl_Title.text = self.sectionTypes[indexPath.item].title
        }
        
        if sectionTypes[indexPath.item] == self.is_selectedType {
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
        collectionView.deselectItem(at: indexPath, animated: true)
        self.is_selectedType = sectionTypes[indexPath.item]
        self.collection_view.reloadData()
        self.tbl_View.reloadData()
    }
    
}


extension PlayListDetailVC: PlayListDelegate {
    func lockMyListClicked(index: Int) {}
    
    func lockBenfitsClikced(indexPath: IndexPath) {
        guard let type = self.arr_PlayList[indexPath.section].type, let selectedType =  PlayListDetailType(rawValue: type) else {
            return
        }
        unlockIndexPath = indexPath
        let data = self.getDetailsData(type: selectedType)[indexPath.row]
        switch data {
        case let yoga as Yoga:
            accessPoint = Int(yoga.access_point)
            name = "yoga"
            favID = Int(yoga.id)
        case let meditation as Meditation:
            accessPoint = Int(meditation.access_point)
            name = "meditation"
            favID = Int(meditation.id)
        case let pranayama as Pranayama:
            accessPoint = Int(pranayama.access_point)
            name = "pranayama"
            favID = Int(pranayama.id)
        case let kriya as Kriya:
            accessPoint = Int(kriya.access_point)
            name = "kriya"
            favID = 0
        case let mudra as Mudra:
            accessPoint = Int(mudra.access_point)
            name = "mudra"
            favID = 0
        default:
            break
        }
        
        AyuSeedsRedeemManager.shared.redeemItem(accessPoint: accessPoint, name: name, favID: favID, presentingVC: self.tabBarController ?? self) { [weak self] (isSuccess, isSubscriptionResumeSuccess, title, message) in
            guard let self = self else { return }
            if isSubscriptionResumeSuccess {
                self.callAPIFor_getPlayListDetailsFromServer()
            } else {
                self.updateItemAfterUnlock(indexPath: self.unlockIndexPath)
            }
        }
    }
    
    func updateItemAfterUnlock(indexPath: IndexPath) {
        guard let type = self.arr_PlayList[indexPath.section].type, let selectedType =  PlayListDetailType(rawValue: type), self.tbl_View.isValid(indexPath: indexPath) else {
            return
        }
        let data = self.getDetailsData(type: selectedType)[indexPath.row]
        switch data {
        case let yoga as Yoga:
            yoga.redeemed = true
            self.tbl_View.reloadRows(at: [indexPath], with: .fade)
        case let meditation as Meditation:
            meditation.redeemed = true
            self.tbl_View.reloadRows(at: [indexPath], with: .fade)
        case let pranayama as Pranayama:
            pranayama.redeemed = true
            self.tbl_View.reloadRows(at: [indexPath], with: .fade)
        case _ as Kriya:
            if let dataArray = self.getDetailsData(type: selectedType) as? [Kriya] {
                dataArray.forEach{ $0.redeemed = true }
                self.tbl_View.reloadData()
            }
        case _ as Mudra:
            if let dataArray = self.getDetailsData(type: selectedType) as? [Mudra] {
                dataArray.forEach{ $0.redeemed = true }
                self.tbl_View.reloadData()
            }
        default:
            break
        }
    }
}
