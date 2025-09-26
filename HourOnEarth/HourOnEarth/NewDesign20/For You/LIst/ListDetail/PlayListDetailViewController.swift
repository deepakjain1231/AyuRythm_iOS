//
//  ListDetailViewController.swift
//  HourOnEarth
//
//  Created by Apple on 17/06/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

enum PlayListDetailType: String, CaseIterable {
    case Yoga
    case Kriyas
    case Meditation
    case Pranayama
    case Mudras
}

class PlayListDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var playListId = 0
    var tabsArray = [PlayListDetails]()
    var selectedIndex = 0
    var navTitle = ""
    var type = ""
    var recommendationVikriti: RecommendationType = .kapha
    
    var dicResponse = [[String: Any]]()
    var unlockIndexPath = IndexPath()
    var accessPoint = Int()
    var name = String()
    var favID = Int()

    var is_searchOpen = false
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var tblPlayList: UITableView!
    @IBOutlet weak var constrant_search_bar_Height: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = navTitle
        self.lbl_title.text = navTitle
        recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        tblPlayList.register(UINib(nibName: "PlayListRowCell", bundle: nil), forCellReuseIdentifier: "PlayListRowCell")
        self.tblPlayList.register(nibWithCellClass: PlayListTableCell.self)
        self.tblPlayList.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getPlayListDetailsFromServer {
            self.tblPlayList.reloadData()
        }
    }
    
    func getDetailsData(type: PlayListDetailType) -> [NSManagedObject] {
        var dataArray = [NSManagedObject]()

        switch type {
        case .Yoga:
            dataArray = tabsArray.filter({$0.type == type.rawValue}).first?.yoga?.allObjects as! [NSManagedObject]
        case .Kriyas:
            dataArray = tabsArray.filter({$0.type == type.rawValue}).first?.kriyas?.allObjects as! [NSManagedObject]
        case .Meditation:
            dataArray = tabsArray.filter({$0.type == type.rawValue}).first?.meditation?.allObjects as! [NSManagedObject]
        case .Pranayama:
            dataArray = tabsArray.filter({$0.type == type.rawValue}).first?.pranayama?.allObjects as! [NSManagedObject]
        case .Mudras:
            
            dataArray = tabsArray.filter({$0.type == type.rawValue}).first?.mudras?.allObjects as! [NSManagedObject]
            
        }
        return dataArray
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tabsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let type = self.tabsArray[section].type, let selectedType =  PlayListDetailType(rawValue: type) {
            
            return self.getDetailsData(type: selectedType).count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListTableCell", for: indexPath) as! PlayListTableCell
        cell.selectionStyle = .none

        guard let type = self.tabsArray[indexPath.section].type, let selectedType =  PlayListDetailType(rawValue: type) else {
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
        cell.delegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = self.tabsArray[indexPath.section].type, let selectedType =  PlayListDetailType(rawValue: type) else {
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
    
    
    // MARK: - Action Methods
    @IBAction func btn_Back_Pressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Search_Action(_ sender: UIButton) {
        if self.is_searchOpen == false {
            self.is_searchOpen = true
            UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.constrant_search_bar_Height.constant = 44
                self.view.layoutIfNeeded()
            }) { (success) in
            }
        }
        else {
            self.is_searchOpen = false
            UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.constrant_search_bar_Height.constant = 0
                self.view.layoutIfNeeded()
            }) { (success) in
            }
        }
    }
}

extension PlayListDetailViewController {
    func getPlayListDetailsFromServer(completion: @escaping ()-> Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.v2.getExpLevelPlayList.rawValue
            var params = ["type": recommendationVikriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
            if type == "benefit" {
                params["benid"] = "\(playListId)"
            } else {
                params["expid"] = "\(playListId)"
            }
            params["type"] = appDelegate.cloud_vikriti_status
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                defer {
                    completion()
                }
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let arrPlayList = (value as? [[String: AnyObject]]) else {
                        
                        return
                    }
                    
                    CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "PlayListDetails")
                    
                    for dic in arrPlayList {
                        PlayListDetails.createPlayListDetailsData(dicData: dic)
                    }
                    self.getPlayListFromDB()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        } else {
            self.getPlayListFromDB()
            completion()
        }
    }
    
    func getPlayListFromDB() {
        guard let arrPlayList = CoreDataHelper.sharedInstance.getListOfEntityWithName("PlayListDetails", withPredicate: nil, sortKey: nil, isAscending: false) as? [PlayListDetails] else {
            return
        }
        self.tabsArray = arrPlayList
    }
}

extension PlayListDetailViewController: PlayListDelegate {
    func lockMyListClicked(index: Int) {}
    
    func lockBenfitsClikced(indexPath: IndexPath) {
        guard let type = self.tabsArray[indexPath.section].type, let selectedType =  PlayListDetailType(rawValue: type) else {
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
                self.getPlayListDetailsFromServer {
                    self.tblPlayList.reloadData()
                }
            } else {
                self.updateItemAfterUnlock(indexPath: self.unlockIndexPath)
            }
        }
    }
    
    func updateItemAfterUnlock(indexPath: IndexPath) {
        guard let type = self.tabsArray[indexPath.section].type, let selectedType =  PlayListDetailType(rawValue: type), tblPlayList.isValid(indexPath: indexPath) else {
            return
        }
        let data = self.getDetailsData(type: selectedType)[indexPath.row]
        switch data {
        case let yoga as Yoga:
            yoga.redeemed = true
            tblPlayList.reloadRows(at: [indexPath], with: .fade)
        case let meditation as Meditation:
            meditation.redeemed = true
            tblPlayList.reloadRows(at: [indexPath], with: .fade)
        case let pranayama as Pranayama:
            pranayama.redeemed = true
            tblPlayList.reloadRows(at: [indexPath], with: .fade)
        case _ as Kriya:
            if let dataArray = self.getDetailsData(type: selectedType) as? [Kriya] {
                dataArray.forEach{ $0.redeemed = true }
                tblPlayList.reloadData()
            }
        case _ as Mudra:
            if let dataArray = self.getDetailsData(type: selectedType) as? [Mudra] {
                dataArray.forEach{ $0.redeemed = true }
                tblPlayList.reloadData()
            }
        default:
            break
        }
    }
}



//
////
////  ListDetailViewController.swift
////  HourOnEarth
////
////  Created by Apple on 17/06/20.
////  Copyright © 2020 Pradeep. All rights reserved.
////
//
//import UIKit
//import CoreData
//import Alamofire
//
//enum PlayListDetailType: String {
//    case Yoga
//    case Kriyas
//    case Meditation
//    case Pranayama
//    case Mudras
//}
//
//class PlayListDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
//
//    var playListId = 0
//    var tabsArray = [PlayListDetails]()
//    var dataArray = [NSManagedObject]()
//    var selectedIndex = 0
//    var selectedType: PlayListDetailType = .Yoga
//
//    @IBOutlet weak var tblPlayList: UITableView!
//    @IBOutlet weak var collectionViewSegment: UICollectionView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tblPlayList.register(UINib(nibName: "PlayListRowCell", bundle: nil), forCellReuseIdentifier: "PlayListRowCell")
//        self.getPlayListDetailsFromServer {
//            if let type = self.tabsArray.first?.type, let selectedType =  PlayListDetailType(rawValue: type) {
//                self.selectedType = selectedType
//                self.getDetailsData(type:self.selectedType)
//            }
//            self.collectionViewSegment.reloadData()
//            self.tblPlayList.reloadData()
//        }
//        // Do any additional setup after loading the view.
//    }
//
//    func getDetailsData(type: PlayListDetailType) {
//        switch type {
//        case .Yoga:
//            dataArray = tabsArray.filter({$0.type == type.rawValue}).first?.yoga?.allObjects as! [NSManagedObject]
//        case .Kriyas:
//            dataArray = tabsArray.filter({$0.type == type.rawValue}).first?.kriyas?.allObjects as! [NSManagedObject]
//        case .Meditation:
//            dataArray = tabsArray.filter({$0.type == type.rawValue}).first?.meditation?.allObjects as! [NSManagedObject]
//        case .Pranayama:
//            dataArray = tabsArray.filter({$0.type == type.rawValue}).first?.pranayama?.allObjects as! [NSManagedObject]
//        case .Mudras:
//            dataArray = tabsArray.filter({$0.type == type.rawValue}).first?.mudras?.allObjects as! [NSManagedObject]
//        }
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 76
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.dataArray.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListRowCell") as? PlayListRowCell else {
//            return UITableViewCell()
//        }
//        let data = self.dataArray[indexPath.item]
//        switch self.selectedType {
//        case .Yoga:
//            guard let yoga = data as? Yoga else {
//                return UITableViewCell()
//            }
//            cell.configureUI(title: yoga.name, subTitle: yoga.english_name, urlString: yoga.image)
//
//        case .Kriyas:
//            guard let kriya = data as? Kriya else {
//                return UITableViewCell()
//            }
//            cell.configureUI(title: kriya.name, subTitle: kriya.english_name, urlString: kriya.image)
//
//        case .Meditation:
//           guard let meditation = data as? Meditation else {
//                return UITableViewCell()
//            }
//            cell.configureUI(title: meditation.name, subTitle: meditation.english_name, urlString: meditation.image)
//
//        case .Pranayama:
//           guard let pranayama = data as? Pranayama else {
//                return UITableViewCell()
//            }
//            cell.configureUI(title: pranayama.name, subTitle: pranayama.english_name, urlString: pranayama.image)
//
//        case .Mudras:
//            guard let mudra = data as? Mudra else {
//                return UITableViewCell()
//            }
//            cell.configureUI(title: mudra.name, subTitle: mudra.english_name, urlString: mudra.image)
//        }
//        cell.selectionStyle = .none
//        return cell
//    }
//
//}
//
//extension PlayListDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return tabsArray.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifierMenuBar", for: indexPath)
//        if let label = cell.viewWithTag(1) as? UILabel {
//            label.text = tabsArray[indexPath.item].type
//
//            if selectedIndex == indexPath.row {
//                label.textColor = #colorLiteral(red: 0.6091104746, green: 0.3192708492, blue: 0.6146215796, alpha: 1)
//            } else {
//                label.textColor = UIColor.lightGray
//            }
//        }
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if let type = self.tabsArray[indexPath.item].type, let selectedType =  PlayListDetailType(rawValue: type) {
//            self.selectedType = selectedType
//            self.getDetailsData(type:self.selectedType)
//            self.tblPlayList.reloadData()
//        }
//    }
//}
//
//extension PlayListDetailViewController {
//    func getPlayListDetailsFromServer(completion: @escaping ()-> Void) {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.getExpLevelPlayList.rawValue
//            AF.request(urlString, method: .post, parameters: ["expid": "\(playListId)"], encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//
//                defer {
//                    completion()
//                }
//                switch response.result {
//
//                case .success(let value):
//                    print(response)
//                    guard let arrPlayList = (value as? [[String: AnyObject]]) else {
//
//                        return
//                    }
//                    for dic in arrPlayList {
//                        PlayListDetails.createPlayListDetailsData(dicData: dic)
//                    }
//                    self.getPlayListFromDB()
//
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                DispatchQueue.main.async(execute: {
//                    Utils.stopActivityIndicatorinView(self.view)
//                })
//            }
//        } else {
//            self.getPlayListFromDB()
//            completion()
//        }
//    }
//
//    func getPlayListFromDB() {
//        guard let arrPlayList = CoreDataHelper.sharedInstance.getListOfEntityWithName("PlayListDetails", withPredicate: nil, sortKey: nil, isAscending: false) as? [PlayListDetails] else {
//            return
//        }
//        self.tabsArray = arrPlayList
//    }
//}
