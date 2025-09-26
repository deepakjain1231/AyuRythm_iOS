//
//  HerbList_NewVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 31/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class HerbList_NewVC: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, delegateCheckMarkRefresh {

    var dic_goalData: response_Data?
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var lbl_count: UILabel!
    @IBOutlet weak var img_header: UIImageView!
    @IBOutlet weak var globalCatLockView: UIView!
    @IBOutlet weak var collection_view: UICollectionView!
    
    var delegate: RecommendationSeeAllDelegate?
    
    var dataArray = [NSManagedObject]()
    //var sectionType : ForYouSectionType = .food
    var sectionType : TodayGoal_Type = .Food
    var recommendationVikriti: RecommendationType = .kapha
    var recommendationType = "kapha"
    var isStatusVisible = true
    var isFromHome = false
    var headerTitle: String = ""
    var isFromAyuverseContentLibrary = false
    private var filteredDataArray = [NSManagedObject] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        self.recommendationType = Utils.getRecommendationType()
        self.setupView()
        
        
        //Register Collection Cell
        self.collection_view.register(nibWithCellClass: HOEYogaCell.self)
        self.collection_view.register(nibWithCellClass: HOEFoodCell.self)
        self.collection_view.register(nibWithCellClass: HOEHerbCell.self)
        self.collection_view.register(nibWithCellClass: YogasanaPranayamTableCell.self)
        
        self.filteredDataArray = dataArray
        self.collection_view.reloadData()
    }
    
    func setupView() {
        self.lbl_Title.text = sectionType.rawValue.localized()
        let img_header = self.dic_goalData?.image ?? ""
        let str_desc = self.dic_goalData?.description ?? ""//["description"] as? String ?? ""
        self.lbl_subTitle.text = str_desc
        
        if sectionType == .Food {
            self.img_header.image = UIImage.init(named: "icon_food_header")
            self.lbl_subTitle.text = "Improved wellness with personalized food suggestions"
            getFoodFromServer { }
        }
        else if sectionType == .Herbs {
            self.img_header.image = UIImage.init(named: "icon_herbs_header")
            self.lbl_subTitle.text = "Natural healing herbs to improve your overall wellness"
            getHerbTypesFromServer { }
        }
        else if sectionType == .Yogasana {
            
            if img_header == "" {
                self.img_header.image = UIImage.init(named: "icon_yogasana_header")
            }
            else {
                self.img_header.sd_setImage(with: URL.init(string: img_header), placeholderImage: UIImage.init(named: "icon_yogasana_header"))
            }

            getYogaFromServer(goal_type: .Yogasana, completion: { })
        }
        else if sectionType == .Pranayama {
            
            if img_header == "" {
                self.img_header.image = UIImage.init(named: "icon_yogasana_header")
            }
            else {
                self.img_header.sd_setImage(with: URL.init(string: img_header), placeholderImage: UIImage.init(named: "icon_yogasana_header"))
            }

            getYogaFromServer(goal_type: .Pranayama, completion: { })
        }
        else if sectionType == .Meditation {
            
            if img_header == "" {
                self.img_header.image = UIImage.init(named: "icon_meditation_header")
            }
            else {
                self.img_header.sd_setImage(with: URL.init(string: img_header), placeholderImage: UIImage.init(named: "icon_meditation_header"))
            }

            getYogaFromServer(goal_type: .Meditation, completion: { })
        }
        else if sectionType == .Kriyas {
            
            if img_header == "" {
                self.img_header.image = UIImage.init(named: "icon_kriya_header")
            }
            else {
                self.img_header.sd_setImage(with: URL.init(string: img_header), placeholderImage: UIImage.init(named: "icon_kriya_header"))
            }

            getYogaFromServer(goal_type: sectionType, completion: { })
        }
        else if sectionType == .Mudras {
            
            if img_header == "" {
                self.img_header.image = UIImage.init(named: "icon_mudra_header")
            }
            else {
                self.img_header.sd_setImage(with: URL.init(string: img_header), placeholderImage: UIImage.init(named: "icon_mudra_header"))
            }

            getYogaFromServer(goal_type: .Mudras, completion: { })
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func globalCatLockTapped(_ sender: UIButton) {

        var accessPoint = Int()
        var name = String()
        var favID = Int()
        
        if self.sectionType == .Mudras {
            if let mudra = self.filteredDataArray[0] as? Mudra {
                accessPoint = Int(mudra.access_point)
                name = "mudra"
                favID = 0
            }
        }
        else if self.sectionType == .Kriyas {
            if let kriya = self.filteredDataArray[0] as? Kriya {
                accessPoint = Int(kriya.access_point)
                name = "kriya"
                favID = 0
            }
        }

        AyuSeedsRedeemManager.shared.redeemItem(accessPoint: accessPoint, name: name, favID: favID, presentingVC: self.tabBarController ?? self) { [weak self]
            (isSuccess, isSubscriptionResumeSuccess, title, message) in
            guard let self = self else { return }
            self.setupView()
        }
        
    }

}
    
   

//MARK: CollectionViewDataSource/Delegates
 
extension HerbList_NewVC {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.sectionType == .Food {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEFoodCell", for: indexPath as IndexPath) as? HOEFoodCell else {
                return UICollectionViewCell()
            }
            guard let food = filteredDataArray[indexPath.row] as? FoodDemo else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.btnLock.tag = indexPath.row
            cell.configureUI(foodType: food)
            return cell
        }
        else if self.sectionType == .Herbs {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HOEHerbCell", for: indexPath as IndexPath) as? HOEHerbCell else {
                return UICollectionViewCell()
            }
            guard let herbType = filteredDataArray[indexPath.row] as? HerbType else {
                return UICollectionViewCell()
            }
            cell.lockView.isHidden = true
            cell.btnLock.tag = indexPath.row
            cell.configureUI(herbType: herbType)
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YogasanaPranayamTableCell", for: indexPath as IndexPath) as? YogasanaPranayamTableCell else {
                return UICollectionViewCell()
            }
            
            if self.sectionType == .Yogasana {
                guard let yoga = filteredDataArray[indexPath.row] as? Yoga else {
                    return UICollectionViewCell()
                }
                cell.configureUI(yoga: yoga)
                cell.btnLock.tag = indexPath.row
                debugPrint("yoga.access_point \(yoga.access_point)")
                if yoga.access_point == 0 {
                    cell.lockView.isHidden = true
                }
                else {
                    cell.lockView.isHidden = yoga.redeemed
                }
                
                cell.didTappedoncheckmark = { (sender) in
                    self.CallApiforUpdateTask(type: "yogasana", fav_id: (yoga.favorite_id ?? ""), duration: yoga.video_duration ?? "")
                }
                
                cell.didTappedonLockView = { (sender) in
                    self.didSelectedSelectRowForRedeem(type: self.sectionType, index: indexPath.row)
                }
            }
            else if self.sectionType == .Meditation {
                guard let Meditation = self.filteredDataArray[indexPath.row] as? Meditation else {
                    return UICollectionViewCell()
                }
                cell.configureUIMeditation(meditation: Meditation)
                cell.btnLock.tag = indexPath.row
                debugPrint("meditation.access_point \(Meditation.access_point)")
                if Meditation.access_point == 0 {
                    cell.lockView.isHidden = true
                }
                else {
                    cell.lockView.isHidden = Meditation.redeemed
                }
                
                cell.didTappedoncheckmark = { (sender) in
                    self.CallApiforUpdateTask(type: "meditation", fav_id: (Meditation.favorite_id ?? ""), duration: Meditation.video_duration ?? "")
                }
                
                cell.didTappedonLockView = { (sender) in
                    self.didSelectedSelectRowForRedeem(type: self.sectionType, index: indexPath.row)
                }
                
                
            }
            else if self.sectionType == .Pranayama {
                guard let Pranayama = self.filteredDataArray[indexPath.row] as? Pranayama else {
                    return UICollectionViewCell()
                }
                cell.configureUIPranayama(Pranayama: Pranayama)
                cell.btnLock.tag = indexPath.row
                debugPrint("pranayama.access_point \(Pranayama.access_point)")
                if Pranayama.access_point == 0 {
                    cell.lockView.isHidden = true
                }
                else {
                    cell.lockView.isHidden = Pranayama.redeemed
                }
                
                cell.didTappedoncheckmark = { (sender) in
                    self.CallApiforUpdateTask(type: "pranayama", fav_id: (Pranayama.favorite_id ?? ""), duration: Pranayama.video_duration ?? "")
                }
                
                cell.didTappedonLockView = { (sender) in
                    self.didSelectedSelectRowForRedeem(type: self.sectionType, index: indexPath.row)
                }
            }
            else if self.sectionType == .Kriyas {
                guard let Kriyas = self.filteredDataArray[indexPath.row] as? Kriya else {
                    return UICollectionViewCell()
                }
                cell.configureUIKriya(kriya: Kriyas)
                
                
                cell.didTappedoncheckmark = { (sender) in
                    self.CallApiforUpdateTask(type: "kriya", fav_id: (Kriyas.favorite_id ?? ""), duration: Kriyas.video_duration ?? "")
                }
            }
            else if self.sectionType == .Mudras {
                guard let Mudras = self.filteredDataArray[indexPath.row] as? Mudra else {
                    return UICollectionViewCell()
                }
                cell.configureUIMudra(mudra: Mudras)
                
                
                cell.didTappedoncheckmark = { (sender) in
                    self.CallApiforUpdateTask(type: "mudra", fav_id: (Mudras.favorite_id ?? ""), duration: Mudras.video_duration ?? "")
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 30
        if self.sectionType == .Food || self.sectionType == .Herbs {
            let collectionViewSize = collectionView.frame.size.width - padding
            return CGSize(width: collectionViewSize/2, height: collectionViewSize/2 - 20)
        }
        else if self.sectionType == .Yogasana || self.sectionType == .Pranayama || self.sectionType == .Kriyas || self.sectionType == .Mudras || self.sectionType == .Meditation {
            return CGSize(width: collection_view.frame.size.width, height: 90)
        }
        return CGSize(width: 0, height: 0)
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.sectionType == .Food {
            foodSelectedAtIndex(index: indexPath.item)
        }
        else if self.sectionType == .Herbs {
            herbSelectedAtIndex(index: indexPath.item)
        }
        else {
            yogaSelectedAtIndex(index: indexPath.item, selection: self.sectionType)
        }
    }
    
    func foodSelectedAtIndex(index: Int) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "FoodsViewController") as? FoodsViewController else {
            return
        }
        guard let foodDemo = filteredDataArray[index] as? FoodDemo else {
            return
        }
        objFoodView.type = self.recommendationVikriti
        objFoodView.selectedType = foodDemo.foodType ?? ""
        objFoodView.selectedId = Int(foodDemo.id)
        objFoodView.isFromAyuverseContentLibrary = isFromAyuverseContentLibrary
        self.navigationController?.pushViewController(objFoodView, animated: true)
    }
    
    func herbSelectedAtIndex(index: Int) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let herbType = filteredDataArray[index] as? HerbType, let vc = storyBoard.instantiateViewController(withIdentifier: "HerbsViewController") as? HerbsViewController else {
            return
        }
        vc.type = self.recommendationVikriti
        vc.selectedType = herbType.herbs_types ?? ""
        vc.selectedId = Int(herbType.id)
        vc.isFromAyuverseContentLibrary = isFromAyuverseContentLibrary
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func yogaSelectedAtIndex(index: Int, selection: TodayGoal_Type) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        objYoga.delegate = self
        objYoga.screenFrom = .from_herbListVC
        objYoga.is_needDetails_ApiCall = true
        objYoga.modalPresentationStyle = .fullScreen
        
        if selection == .Yogasana {
            guard let yoga = filteredDataArray[index] as? Yoga else {
                return
            }
            objYoga.yoga = yoga
            objYoga.istype = .yoga
            objYoga.str_id = yoga.content_id ?? ""
            objYoga.objectFavoriteId = yoga.favorite_id ?? ""
        }
        else if selection == .Meditation {
            guard let meditation = filteredDataArray[index] as? Meditation else {
                return
            }
            objYoga.meditation = meditation
            objYoga.istype = .meditation
            objYoga.str_id = meditation.content_id ?? ""
            objYoga.objectFavoriteId = meditation.favorite_id ?? ""
        }
        else if selection == .Pranayama {
            guard let pranayama = filteredDataArray[index] as? Pranayama else {
                return
            }
            objYoga.pranayama = pranayama
            objYoga.istype = .pranayama
            objYoga.str_id = pranayama.content_id ?? ""
            objYoga.objectFavoriteId = pranayama.favorite_id ?? ""
        }
        else if selection == .Kriyas {
            guard let kriya = filteredDataArray[index] as? Kriya else {
                return
            }
            objYoga.kriya = kriya
            objYoga.istype = .kriya
            objYoga.str_id = kriya.content_id ?? ""
            objYoga.objectFavoriteId = kriya.favorite_id ?? ""
        }
        else if selection == .Mudras {
            guard let mudra = filteredDataArray[index] as? Mudra else {
                return
            }
            objYoga.mudra = mudra
            objYoga.istype = .mudra
            objYoga.str_id = mudra.content_id ?? ""
            objYoga.objectFavoriteId = mudra.favorite_id ?? ""
        }
        self.present(objYoga, animated: true, completion: nil)
    }
    
    func didSelectedSelectRowForRedeem(type: TodayGoal_Type, index: Int) {
        
        var accessPoint = Int()
        var name = String()
        var favID = Int()
        
        if type == .Meditation {
            guard let Meditation = self.filteredDataArray[index] as? Meditation else {
                return
            }
            name = type.rawValue.lowercased()
            favID = Meditation.id
            accessPoint = Int(Meditation.access_point)
        }
        else if type == .Yogasana {
            guard let yogasana = self.filteredDataArray[index] as? Yoga else {
                return
            }
            name = type.rawValue.lowercased()
            favID = Int(yogasana.id)
            accessPoint = Int(yogasana.access_point)
        }
        else if type == .Pranayama {
            guard let pranayama = self.filteredDataArray[index] as? Pranayama else {
                return
            }
            name = type.rawValue.lowercased()
            favID = pranayama.id
            accessPoint = Int(pranayama.access_point)
        }
        
        AyuSeedsRedeemManager.shared.redeemItem(accessPoint: accessPoint, name: name, favID: favID, presentingVC: self.tabBarController ?? self) { [weak self] (isSuccess, isSubscriptionResumeSuccess, title, message) in
            guard let strongSelf = self else { return }
            strongSelf.setupView()
        }
    }
    
}

//MARK: - API Call

extension HerbList_NewVC {
    
    func getFoodFromServer(completion: @escaping ()-> Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.v2.getFoodType.rawValue
            let params = ["language_id" : Utils.getLanguageId()] as [String : Any]

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in

                defer {
                    completion()
                }
                switch response.result {

                case .success(let value):
                    print(response)
                    guard let arrQuestions = (value as? [[String: AnyObject]]) else {

                        return
                    }
                    CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "FoodDemo")
                    for dic in arrQuestions {
                        FoodDemo.createFoodData(dicData: dic)
                    }
                    self.getFoodFromDB()

                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        } else {
            self.getFoodFromDB()
            completion()
        }
    }
    
    
    
    func getHerbTypesFromServer(completion: @escaping ()-> Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            var params = ["type": recommendationVikriti.rawValue,
                          "language_id" : Utils.getLanguageId()] as [String : Any]
            
            params["type"] = appDelegate.cloud_vikriti_status
            
            let urlString = kBaseNewURL + endPoint.getHerbsTypes.rawValue
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in

                defer {
                    completion()
                }
                switch response.result {

                case .success(let value):
                    print(response)
                    guard let arrResponse = value as? [[String: AnyObject]] else {
                        return
                    }
                    let dataArray = arrResponse.compactMap{ HerbType.createHerbData(dicData: $0) }
                    //self.dataArray = dataArray
                    self.filteredDataArray = dataArray
                    self.checkData()

                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        } else {
            self.getHerbTypesFromDB()
            completion()
        }
    }
    
    
    
    //MARK: - YOGASANA
    
    func getYogaFromServer (goal_type: TodayGoal_Type, completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.getKriyaiOS_NewAPI.rawValue
            
            let todayKeysID = self.dic_goalData?.goal_data?.user_video_favorit_id ?? ""
            var params = ["from": "home",
                          "today_keys": todayKeysID,//Video fav ID from Todaysgoal api
                          "list_type": "",
                          "type": recommendationVikriti.rawValue,
                          "typetwo": Utils.getYourCurrentPrakritiStatus().rawValue,
                          "language_id" : Utils.getLanguageId()] as [String : Any]
            
#if !APPCLIP
        params["type"] = appDelegate.cloud_vikriti_status
#endif
            
            if goal_type == .Yogasana {
                params["list_type"] = "yogasana"
            }
            else if goal_type == .Pranayama {
                params["list_type"] = "pranayam"
            }
            else if goal_type == .Meditation {
                params["list_type"] = "meditation"
            }
            else if goal_type == .Kriyas {
                params["list_type"] = "kriya"
            }
            else if goal_type == .Mudras {
                params["list_type"] = "mudra"
            }
            
            debugPrint("API URL===>>\(urlString)\n\nParams=====>>\(params)")
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let arrResponse = (value as? [[String: Any]]) else {
                        completion()
                        return
                    }
                    if goal_type == .Yogasana {
                        
                        let dataArray = arrResponse.compactMap{ Yoga.createYogaData(dicYoga: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        TodayRecommendations.shared.saveIDs(ids: dataArray.compactMap{ String($0.id) }.joined(separator: ","), forType: .yoga)
                        //self.dataArray = dataArray
                        self.filteredDataArray = dataArray
                        
                    }
                    else if goal_type == .Pranayama {
                        
                        let dataArray = arrResponse.compactMap{ Pranayama.createPranayamaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        TodayRecommendations.shared.saveIDs(ids: dataArray.compactMap{ String($0.id) }.joined(separator: ","), forType: .pranayam)
                        
                        //self.dataArray = dataArray
                        self.filteredDataArray = dataArray
                        
                    }
                    else if goal_type == .Meditation {
                        
                        let dataArray = arrResponse.compactMap{ Meditation.createMeditationData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        TodayRecommendations.shared.saveIDs(ids: dataArray.compactMap{ String($0.id) }.joined(separator: ","), forType: .meditation)
                        
                        //self.dataArray = dataArray
                        self.filteredDataArray = dataArray
                        
                    }
                    else if goal_type == .Kriyas {
                        
                        let dataArray = arrResponse.compactMap{ Kriya.createKriyaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        TodayRecommendations.shared.saveIDs(ids: dataArray.compactMap{ String($0.id) }.joined(separator: ","), forType: .kriya)
                        
                        //self.dataArray = dataArray
                        self.filteredDataArray = dataArray
                        
                        if dataArray.count != 0 {
                            guard let kriyas = dataArray[0] as? Kriya else {
                                return
                            }
                            if dataArray.count > 0, kriyas.access_point > 0 {
                                self.collection_view.isHidden = !kriyas.redeemed
                                self.globalCatLockView.isHidden = kriyas.redeemed
                            }
                            else {
                                self.collection_view.isHidden = false
                                self.globalCatLockView.isHidden = true
                            }
                        }
                        
                    }
                    else if goal_type == .Mudras {
                        
                        let dataArray = arrResponse.compactMap{ Mudra.createMudraData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        TodayRecommendations.shared.saveIDs(ids: dataArray.compactMap{ String($0.id) }.joined(separator: ","), forType: .mudra)
                        
                        //self.dataArray = dataArray
                        self.filteredDataArray = dataArray
                        
                        if dataArray.count != 0 {
                            guard let Mudras = dataArray[0] as? Mudra else {
                                return
                            }
                            if dataArray.count > 0, Mudras.access_point > 0 {
                                self.collection_view.isHidden = !Mudras.redeemed
                                self.globalCatLockView.isHidden = Mudras.redeemed
                            }
                            else {
                                self.collection_view.isHidden = false
                                self.globalCatLockView.isHidden = true
                            }
                        }

                    }
                    
                    self.checkData()
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                completion()
            }
        } else {
            if goal_type == .Yogasana {
                getYogaDataFromDB()
            }
            else if goal_type == .Pranayama {
                self.getPranayamaDataFromDB()
            }
            else if goal_type == .Meditation {
                self.getMeditationDataFromDB()
            }
            else if goal_type == .Kriyas {
                self.getKriyaDataFromDB()
            }
            else if goal_type == .Mudras {
                self.getMudraDataFromDB()
            }
            completion()
        }
    }
    
    func checkData() {
        if self.filteredDataArray.count == 0 || self.filteredDataArray.count == 1 {
            self.lbl_count.text = "\(self.filteredDataArray.count) item"
        }
        else {
            self.lbl_count.text = "\(self.filteredDataArray.count) items"
        }
        self.collection_view.reloadData()
    }
    
    
    func CallApiforUpdateTask(type: String, fav_id: String, duration: String) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            
            Utils.completeDailyTask(favorite_id: fav_id, taskType: type, str_duration: duration) { success, status, msggg in
                appDelegate.apiCallingAsperDataChage = true
                
                if self.sectionType == .Yogasana {
                    if let indx = self.filteredDataArray.firstIndex(where: { dic_dataa in
                        if let dic_yogasana = dic_dataa as? Yoga {
                            return (dic_yogasana.favorite_id ?? "") == fav_id
                        }
                        return false
                    }) {
                        if let dic_yogasana = self.filteredDataArray[indx] as? Yoga {
                            dic_yogasana.is_video_watch = "yes"

                            self.filteredDataArray.remove(at: indx)
                            if self.filteredDataArray.count == indx {
                                self.filteredDataArray.append(dic_yogasana)
                            }
                            else {
                                self.filteredDataArray.insert(dic_yogasana, at: indx)
                            }
                        }
                    }
                }
                else if self.sectionType == .Pranayama {
                    if let indx = self.filteredDataArray.firstIndex(where: { dic_dataa in
                        if let dic_pranayam = dic_dataa as? Pranayama {
                            return (dic_pranayam.favorite_id ?? "") == fav_id
                        }
                        return false
                    }) {
                        if let dic_pramayamm = self.filteredDataArray[indx] as? Pranayama {
                            dic_pramayamm.is_video_watch = "yes"
                            
                            self.filteredDataArray.remove(at: indx)
                            if self.filteredDataArray.count == indx {
                                self.filteredDataArray.append(dic_pramayamm)
                            }
                            else {
                                self.filteredDataArray.insert(dic_pramayamm, at: indx)
                            }
                        }
                    }
                }
                else if self.sectionType == .Meditation {
                    if let indx = self.filteredDataArray.firstIndex(where: { dic_dataa in
                        if let dic_meditation = dic_dataa as? Meditation {
                            return (dic_meditation.favorite_id ?? "") == fav_id
                        }
                        return false
                    }) {
                        if let dic_meditation = self.filteredDataArray[indx] as? Meditation {
                            dic_meditation.is_video_watch = "yes"
                            
                            self.filteredDataArray.remove(at: indx)
                            if self.filteredDataArray.count == indx {
                                self.filteredDataArray.append(dic_meditation)
                            }
                            else {
                                self.filteredDataArray.insert(dic_meditation, at: indx)
                            }
                        }
                    }
                }
                else if self.sectionType == .Kriyas {
                    if let indx = self.filteredDataArray.firstIndex(where: { dic_dataa in
                        if let dic_kriya = dic_dataa as? Kriya {
                            return (dic_kriya.favorite_id ?? "") == fav_id
                        }
                        return false
                    }) {
                        if let dic_kriya = self.filteredDataArray[indx] as? Kriya {
                            dic_kriya.is_video_watch = "yes"
                            
                            self.filteredDataArray.remove(at: indx)
                            if self.filteredDataArray.count == indx {
                                self.filteredDataArray.append(dic_kriya)
                            }
                            else {
                                self.filteredDataArray.insert(dic_kriya, at: indx)
                            }
                        }
                    }
                }
                else if self.sectionType == .Mudras {
                    if let indx = self.filteredDataArray.firstIndex(where: { dic_dataa in
                        if let dic_mudra = dic_dataa as? Mudra {
                            return (dic_mudra.favorite_id ?? "") == fav_id
                        }
                        return false
                    }) {
                        if let dic_mudra = self.filteredDataArray[indx] as? Mudra {
                            dic_mudra.is_video_watch = "yes"
                            
                            self.filteredDataArray.remove(at: indx)
                            if self.filteredDataArray.count == indx {
                                self.filteredDataArray.append(dic_mudra)
                            }
                            else {
                                self.filteredDataArray.insert(dic_mudra, at: indx)
                            }
                        }
                    }
                }
                self.collection_view.reloadData()
                Utils.stopActivityIndicatorinView(self.view)
                
                //self.setupView()
            }
        }
    }
}

//MARK: Database calls
extension HerbList_NewVC {
    
    func getFoodFromDB() {
        guard let arrFood = CoreDataHelper.sharedInstance.getListOfEntityWithName("FoodDemo", withPredicate: nil, sortKey: nil, isAscending: false) as? [FoodDemo] else {
            return
        }
        //self.dataArray = arrFood
        self.filteredDataArray = arrFood
        self.checkData()
    }
    
    func getHerbTypesFromDB() {
        guard let arrHerb = CoreDataHelper.sharedInstance.getListOfEntityWithName("HerbType", withPredicate: nil, sortKey: nil, isAscending: false) as? [HerbType] else {
            return
        }
        //self.dataArray = arrHerb
        self.filteredDataArray = arrHerb
        self.checkData()
    }
    
    func getYogaDataFromDB() {
        let predicate = NSPredicate(format: "type CONTAINS[cd] %@", recommendationType)
        guard let arrYoga = CoreDataHelper.sharedInstance.getListOfEntityWithName("Yoga", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Yoga] else {
            return
        }
        
        let arrSorted = arrYoga.sorted { (obj1, obj2) -> Bool in
            return obj1.access_point < obj2.access_point
        }
        //self.dataArray = arrSorted
        self.filteredDataArray = arrSorted
        self.checkData()
    }
    
    func getPranayamaDataFromDB() {
        let predicate = NSPredicate(format: "type CONTAINS[cd] %@", recommendationType)
        guard let arrPrananyam = CoreDataHelper.sharedInstance.getListOfEntityWithName("Pranayama", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Pranayama] else {
            return
        }
        
        let arrSorted = arrPrananyam.sorted { (obj1, obj2) -> Bool in
            return obj1.access_point < obj2.access_point
        }
        
        //self.dataArray = arrSorted
        self.filteredDataArray = arrSorted
        self.checkData()
    }
    
    func getMeditationDataFromDB() {
        let predicate = NSPredicate(format: "type CONTAINS[cd] %@", recommendationType)
        guard let arrMeditation = CoreDataHelper.sharedInstance.getListOfEntityWithName("Meditation", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Meditation] else {
            return
        }
        let arrSorted = arrMeditation.sorted { (obj1, obj2) -> Bool in
            return obj1.access_point < obj2.access_point
        }

        //self.dataArray = arrSorted
        self.filteredDataArray = arrSorted
        self.checkData()
    }
    
    func getMudraDataFromDB() {
        let predicate = NSPredicate(format: "type CONTAINS[cd] %@", recommendationType)
        guard let arrMudra = CoreDataHelper.sharedInstance.getListOfEntityWithName("Mudra", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Mudra] else {
            return
        }
        //self.dataArray = arrMudra
        self.filteredDataArray = arrMudra
        self.checkData()
    }
    
    func getKriyaDataFromDB() {
        let predicate = NSPredicate(format: "type CONTAINS[cd] %@", recommendationType)
        guard let arrKriya = CoreDataHelper.sharedInstance.getListOfEntityWithName("Kriya", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Kriya] else {
            return
        }
        //self.dataArray = arrKriya
        self.filteredDataArray = arrKriya
        self.checkData()
    }
    
    func screenRefresh(_ is_success: Bool) {
        if is_success {
            self.setupView()
        }
    }
}
