//
//  RecommendationsVC.swift
//  AyuRythmClip
//
//  Created by Paresh Dafda on 26/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import StoreKit

class RecommendationsVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
        
    @IBOutlet weak var tblForYou: UITableView!

    var recommendationVikriti: RecommendationType = .kapha
    var recommendationPrakriti: RecommendationType = .kapha

    var dataArray: [RecommendationsCellType] = [RecommendationsCellType]() {
        didSet {
            dataArray.sort(by: <)
            tblForYou.reloadData()
        }
    }
    var screenVisitCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationItem.rightBarButtonItem = nil
        navigationItem.largeTitleDisplayMode = .never
        recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        
        self.tblForYou.tableFooterView = UIView()
        tblForYou.register(UINib(nibName: "HomeYogaCell", bundle: nil), forCellReuseIdentifier: "HomeYogaCell")
        refreshData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAppDownloadBannerBasedOnScreenVisitCount()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = self.dataArray[indexPath.row]
        switch rowType {
        case .yoga, .meditation, .pranayama, .mudra, .kriya:
            return 245
        case .food:
            return 218
        }
    }
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = self.dataArray[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.indexPathNew = indexPath
        cell.collectionView.isHidden = false
        cell.globalCatLockView.isHidden = true
        cell.btnSeeMore.isHidden = true
        cell.selectionStyle = .none
        
        switch rowType {
        
        case .yoga(let section, let data):
            cell.configureUI(title: section.title, data: data, cellType: .yoga(isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            
        case .meditation(let section, let data):
            cell.configureUI(title: section.title, data: data, cellType: .meditation(isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            
        case .pranayama(let section, let data):
            cell.configureUI(title: section.title, data: data, cellType: .pranayama(isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            
        case .mudra(let section, let data):
            cell.configureUI(title: section.title, data: data, cellType: .mudra(isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            
        case .kriya(let section, let data):
            cell.configureUI(title: section.title, data: data, cellType: .kriya(isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))

        case .food(let section, let data):
            cell.configureUI(title: section.title, data: data, cellType: .food)
        }
        
        return cell
    }
    
    //MARK: RefreshData
    func refreshData() {
        dataArray.removeAll()
        
        getRecommendationsFromServer { [weak self] in
            self?.hideActivityIndicator()
        }
    }

    // MARK: - IBActions
    @IBAction func menuButtonClicked(_ sender: Any) {
        showAppDownloadBanner()
    }
    
    func showAppDownloadBannerBasedOnScreenVisitCount() {
        screenVisitCounter += 1
        if screenVisitCounter % 3 == 0 {
            showAppDownloadBanner()
        }
    }
    
    func showAppDownloadBanner() {
        //show bottom app install banner
        guard let scene = view.window?.windowScene else { return }

        let config = SKOverlay.AppConfiguration(appIdentifier: AppStoreAppID, position: .bottom)
        let overlay = SKOverlay(configuration: config)
        overlay.present(in: scene)
    }
}

extension RecommendationsVC: RecommendationSeeAllDelegate {
    func didSelectedSelectRowForRedeem(indexPath: IndexPath, index: Int?) {}
    
    func didSelectedSelectRow(indexPath: IndexPath, index: Int?) {
        let rowType = self.dataArray[indexPath.row]
        switch rowType {
        case .yoga(_, let yogaArray):
            guard let index = index else {
                //If index is not present then move to see all
               // self.showYogaPlayListScreen(data: yogaArray)
                return
            }
            
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
                return
            }
            objYoga.modalPresentationStyle = .fullScreen
            objYoga.yoga = yogaArray[index]
            self.present(objYoga, animated: true, completion: nil)
            
        case .food(_, let foodArray):
            guard let index = index else {
                //If index is not present then move to see all
                //self.showDetailScreen(sectionType: section, data: foodArray)
                return
            }
            
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objFoodDetails = storyBoard.instantiateViewController(withIdentifier: "FoodDetailViewController") as? FoodDetailViewController else {
                return
            }
            objFoodDetails.modalPresentationStyle = .fullScreen

            objFoodDetails.recommendationPrakriti = recommendationPrakriti
            objFoodDetails.recommendationVikriti = recommendationVikriti
            objFoodDetails.dataFood = foodArray[index]
            self.present(objFoodDetails, animated: true, completion: nil)
        case .meditation( _, let data):
                guard let index = index else {
                //If index is not present then move to see all
                //self.showMeditationPlayListScreen(data: data)
                return
            }
            
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
                return
            }
            objYoga.modalPresentationStyle = .fullScreen
            objYoga.meditation = data[index]
            objYoga.isFromForYou = true
            objYoga.istype = .meditation

            self.present(objYoga, animated: true, completion: nil)

        case .pranayama( _, let data):
                guard let index = index else {
                //If index is not present then move to see all
                //self.showPranayamaPlayListScreen(data: data)
                return
            }
            
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
                return
            }
            objYoga.modalPresentationStyle = .fullScreen
            objYoga.pranayama = data[index]
            objYoga.isFromForYou = true
            objYoga.istype = .pranayama

            self.present(objYoga, animated: true, completion: nil)

        case .mudra( _, let data):
                guard let index = index else {
                //If index is not present then move to see all
                //self.showMudraPlayListScreen(data: data)
                return
            }
            
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
                return
            }
            objYoga.modalPresentationStyle = .fullScreen
            objYoga.mudra = data[index]
                objYoga.isFromForYou = true
                objYoga.istype = .mudra

            self.present(objYoga, animated: true, completion: nil)

        case .kriya( _, let data):
                guard let index = index else {
                //If index is not present then move to see all
                //self.showkriyaPlayListScreen(data: data)
                return
            }
            
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
                return
            }
            objYoga.modalPresentationStyle = .fullScreen
            objYoga.kriya = data[index]
            objYoga.isFromForYou = true
            objYoga.istype = .kriya

            self.present(objYoga, animated: true, completion: nil)

        }
    }
}

extension RecommendationsVC {
    
    func getRecommendationsFromServer (completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.getAllTypeDataForAppClipV2.rawValue
            let params = ["type": recommendationVikriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                    guard let dicResponse = (value as? [[String: Any]]) else {
                        completion()
                        return
                    }

                    for dicObject in dicResponse {
                        if dicObject["type"] as? String == "Yoga" {
                            var managedObject = [Yoga]()
                            for dic in (dicObject["details"] as? [[String: Any]])! {
                                managedObject.append(Yoga.createYogaData(dicYoga: dic, needToSave: false)!)
                            }
                            if managedObject.count > 0 {
                                self.dataArray.append(.yoga(section: .yoga, data: managedObject))
                            }
                        }
                        else if dicObject["type"] as? String == "Pranayama" {
                            var managedObject = [Pranayama]()
                            for dic in (dicObject["details"] as? [[String: Any]])! {
                                managedObject.append(Pranayama.createPranayamaData(dicData: dic)!)
                            }
                            if managedObject.count > 0 {
                                self.dataArray.append(.pranayama(section: .pranayama, data: managedObject))
                            }
                        }
                        else if dicObject["type"] as? String == "Meditation" {
                            var managedObject = [Meditation]()
                            for dic in (dicObject["details"] as? [[String: Any]])! {
                                managedObject.append(Meditation.createMeditationData(dicData: dic, needToSave: false)!)
                            }
                            if managedObject.count > 0 {
                                self.dataArray.append(.meditation(section: .meditation, data: managedObject))
                            }
                        }
                        else if dicObject["type"] as? String == "Mudras" {
                            var managedObject = [Mudra]()
                            for dic in (dicObject["details"] as? [[String: Any]])! {
                                managedObject.append(Mudra.createMudraData(dicData: dic, needToSave: false)!)
                            }
                            if managedObject.count > 0 {
                                self.dataArray.append(.mudra(section: .mudra, data: managedObject))
                            }
                        }
                        else if dicObject["type"] as? String == "Kriyas" {
                            var managedObject = [Kriya]()
                            for dic in (dicObject["details"] as? [[String: Any]])! {
                                managedObject.append(Kriya.createKriyaData(dicData: dic, needToSave: false)!)
                            }
                            if managedObject.count > 0 {
                                self.dataArray.append(.kriya(section: .kriya, data: managedObject))
                            }
                        }
                        else if dicObject["type"] as? String == "Food" {
                            var managedObject = [Food]()
                            CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Food")
                            for dic in (dicObject["details"] as? [[String: Any]])! {
                                managedObject.append(Food.createFoodData(dicData: dic, needToSave: false)!)
                            }
                            if managedObject.count > 0 {
                                self.dataArray.append(.food(section: .food, data: managedObject))
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                completion()
            }
        } else {
            completion()
        }
    }
}
