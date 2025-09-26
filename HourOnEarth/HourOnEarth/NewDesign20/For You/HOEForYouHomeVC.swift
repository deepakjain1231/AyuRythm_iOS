//
//  HOEForYouHomeVC.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 11/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

enum ForYouSectionType {
    case playlist
    case weekly_planner
    case food
    case yoga
    case meditation
    case pranayama
    case mudra
    case kriya
    case yogaFavourite
    case meditationFavourite
    case pranayamaFavourite
    case mudraFavourite
    case kriyaFavourite
    case trainer
    case herbs
    case homeRemedies
    
    var title: String {
        switch self {
        case .food:
            return "Food".localized()
        case .weekly_planner:
            return "Weekely planner".localized()
        case .yoga:
            return "Yoga".localized()
        case .meditation:
            return "Meditation".localized()
        case .pranayama:
            return "Pranayama".localized()
        case .mudra:
            return "Mudras".localized()
        case .kriya:
            return "Kriyas".localized()
        case .yogaFavourite:
            return "Yoga".localized()
        case .playlist:
            return "List".localized()
        case .meditationFavourite:
            return "Meditation".localized()
        case .pranayamaFavourite:
            return "Pranayama".localized()
        case .mudraFavourite:
            return "Mudra".localized()
        case .kriyaFavourite:
            return "Kriya".localized()
        case .trainer:
            return "Wellness Trainers".localized()
        case .herbs:
            return "Herbs".localized()
        case .homeRemedies:
            return "Home Remedies".localized()
        }
    }
}

enum ForYouCellType {
    case weekly_planner
    case yoga(section: ForYouSectionType, data:[Yoga])
    case meditation(section: ForYouSectionType, data:[Meditation])
    case pranayama(section: ForYouSectionType, data:[Pranayama])
    case mudra(section: ForYouSectionType, data:[Mudra])
    case kriya(section: ForYouSectionType, data:[Kriya])
    case food(section: ForYouSectionType, data: [FoodDemo])
    case herbs(section: ForYouSectionType, data: [HerbType])
    case playlits(section: ForYouSectionType, title: String, data: [PlayList])
    case trainer(section: ForYouSectionType, title: String, data: [Trainer])
    
    var sortOrder: Int {
        switch self {
        case .trainer:
            return 0
        case .playlits:
            return 1
        case .weekly_planner:
            return 2
        case .food:
            return 3
        case .herbs:
            return 4
        case .yoga:
            return 5
        case .pranayama:
            return 6
        case .meditation:
            return 7
        case .mudra:
            return 8
        case .kriya:
            return 9
        }
    }
    
    static func < (lhs: ForYouCellType, rhs: ForYouCellType) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}

class HOEForYouHomeVC: BaseViewController {
    
    @IBOutlet weak var tblForYou: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var view_Header: UIView!
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var contraint_view_Header_TOP: NSLayoutConstraint!
    @IBOutlet weak var contraint_searchBar_Height: NSLayoutConstraint!
    private var isSearching = false
    
    @IBOutlet weak var btn_userHeader: UIButton!
    @IBOutlet weak var img_userIconHeader: UIImageView!
    @IBOutlet weak var view_ProUser: UIView!
    
    var arr_Yoga = [Yoga]()
    var arr_Pranayam = [Pranayama]()
    var arr_Meditation = [Meditation]()
    var arr_Mudra = [Mudra]()
    var arr_Kriya = [Kriya]()
    var arr_Food = [FoodDemo]()
    var arr_Herb = [HerbType]()
    
    var recommendationVikriti: RecommendationType = .kapha
    var recommendationPrakriti: RecommendationType = .kapha
    private var filteredDataArray = [ForYouCellType] ()
    
    var unlockIndexPath = IndexPath()
    var unlockIndex = Int()
    var accessPoint = Int()
    var name = String()
    var favID = Int()
    
    var dataArray: [ForYouCellType] = [ForYouCellType]() {
        didSet {
            dataArray.sort(by: <)
            tblForYou.reloadData()
            if dataArray.count > 0 && self.unlockIndexPath.count > 0 && tblForYou.isValid(indexPath: unlockIndexPath) {
                self.tblForYou.scrollToRow(at: self.unlockIndexPath, at: .middle, animated: false)
                self.unlockIndexPath = IndexPath(row: 0, section: 0)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = nil
        
        if #available(iOS 15.0, *) {
            self.tblForYou.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        
        //Register Table Cell=======//
        self.tblForYou.register(nibWithCellClass: HomeYogaCell.self)
        self.tblForYou.register(nibWithCellClass: WeeklyPlannerTableCell.self)
        self.tblForYou.register(nibWithCellClass: TrainerCollectionViewCell.self)
        self.tblForYou.register(nibWithCellClass: PlayListCollectionViewCell.self)
        //*************************//
        
        showNavProfileButton_MyHomeViewController(img_view: self.img_userIconHeader, btn_Profile: self.btn_userHeader, handlePro: self.view_ProUser)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        self.refreshData()
        self.NotificationFromServer()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //FloatingButton.addButton(in: self.view)
        handlePushNotificationDeepLink()
        showViewSuggestionScreenForSparshnaResult()
    }
    
}

//MARK: - UITableView Delegate DataSource Method
extension HOEForYouHomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = self.dataArray[indexPath.row]
        switch rowType {
        case .trainer:
            return 55 + (kDeviceWidth/4) + 25 + 30
        case .playlits:
            return 55 + (kDeviceWidth/4) + 55
        case .yoga, .meditation, .pranayama, .mudra, .kriya:
            return 245
        case .food, .herbs:
            return 55 + (kDeviceWidth/4) + 55
        case .weekly_planner:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = self.dataArray[indexPath.row]
        switch rowType {
        case .trainer( _, let title, let dataArray):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrainerCollectionViewCell") as? TrainerCollectionViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.indexPath = indexPath
            cell.configureUI(title: title, data: dataArray)
            cell.selectionStyle = .none
            return cell
            
        case .playlits( _, let title, let dataArray):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListCollectionViewCell") as? PlayListCollectionViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.indexPath = indexPath
            cell.configureUI(title: title, data: dataArray)
            cell.selectionStyle = .none
            return cell
            
        case .yoga(let section, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.indexPathNew = indexPath
            cell.collectionView.isHidden = false
            cell.globalCatLockView.isHidden = true
            cell.btnSeeMore.isHidden = false
            cell.configureUI(title: section.title, data: data, cellType: .yoga(isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            cell.selectionStyle = .none
            return cell
            
        case .meditation(let section, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.indexPathNew = indexPath
            cell.collectionView.isHidden = false
            cell.globalCatLockView.isHidden = true
            cell.btnSeeMore.isHidden = false
            cell.configureUI(title: section.title, data: data, cellType: .meditation(isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            cell.selectionStyle = .none
            return cell
            
        case .pranayama(let section, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.indexPathNew = indexPath
            cell.collectionView.isHidden = false
            cell.globalCatLockView.isHidden = true
            cell.btnSeeMore.isHidden = false
            cell.configureUI(title: section.title, data: data, cellType: .pranayama(isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            cell.selectionStyle = .none
            return cell
            
        case .mudra(let section, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            if data.count > 0, data[0].access_point > 0 {
                cell.collectionView.isHidden = !data[0].redeemed
                cell.globalCatLockView.isHidden = data[0].redeemed
                cell.btnSeeMore.isHidden = !data[0].redeemed
            }
            else {
                cell.collectionView.isHidden = false
                cell.btnSeeMore.isHidden = false
                cell.globalCatLockView.isHidden = true
            }
            cell.delegate = self
            cell.indexPathNew = indexPath
            cell.configureUI(title: section.title, data: data, cellType: .mudra(isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            cell.selectionStyle = .none
            return cell
            
        case .kriya(let section, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            if data.count > 0, data[0].access_point > 0 {
                cell.collectionView.isHidden = !data[0].redeemed
                cell.globalCatLockView.isHidden = data[0].redeemed
                cell.btnSeeMore.isHidden = !data[0].redeemed
            }
            else {
                cell.collectionView.isHidden = false
                cell.btnSeeMore.isHidden = false
                cell.globalCatLockView.isHidden = true
            }
            cell.delegate = self
            cell.indexPathNew = indexPath
            cell.configureUI(title: section.title, data: data, cellType: .kriya(isStatusVisible: true, recPrakriti: self.recommendationPrakriti, recVikriti: self.recommendationVikriti))
            cell.selectionStyle = .none
            return cell
            
        case .weekly_planner:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyPlannerTableCell") as? WeeklyPlannerTableCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.btn_click.addTarget(self, action: #selector(weeklyPlannerBanner_Clicked(_:)), for: .touchUpInside)
            return cell
            
        case .food(let section, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.indexPathNew = indexPath
            cell.collectionView.isHidden = false
            cell.globalCatLockView.isHidden = true
            cell.btnSeeMore.isHidden = false
            cell.configureUI(title: section.title, data: data, cellType: .foodDemo)
            cell.selectionStyle = .none
            return cell
            
        case .herbs(let section, let data):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeYogaCell") as? HomeYogaCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.indexPathNew = indexPath
            cell.collectionView.isHidden = false
            cell.globalCatLockView.isHidden = true
            cell.btnSeeMore.isHidden = false
            cell.configureUI(title: section.title, data: data, cellType: .herbType)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    
    @objc func weeklyPlannerBanner_Clicked(_ sender: UIButton) {
        let vc = MP_Product_CategoryVC.instantiate(fromAppStoryboard: .WeeklyPlaner)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: RefreshData
    func refreshData() {
        let group = DispatchGroup()
        dataArray.removeAll()
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        
        //Remove Shop Section as per Sandeep
        //self.dataArray.append(.weekly_planner)
        
        group.enter()
        self.getTrainerDetailsFromServer {
            group.leave()
        }
        
        group.enter()
        self.getPlayListFromServer {
            group.leave()
        }

        group.enter()
        self.getFoodFromServer {
            group.leave()
        }
        
        group.enter()
        self.getHerbTypesFromServer {
            group.leave()
        }
        
        //if SurveyData.shared.isContentAvailable(type: .Yogasana) {
            group.enter()
        self.getYogaFromServer(goal_type: .Yogasana) {
            group.leave()
        }
        //}
        
        //if SurveyData.shared.isContentAvailable(type: .Pranayama) {
            group.enter()
        self.getYogaFromServer(goal_type: .Pranayama) {
            group.leave()
        }
        //}
        
        //if SurveyData.shared.isContentAvailable(type: .Meditation) {
            group.enter()
        self.getYogaFromServer(goal_type: .Meditation) {
            group.leave()
        }
        //}
        
        //if SurveyData.shared.isContentAvailable(type: .Mudras) {
            group.enter()
        self.getYogaFromServer(goal_type: .Mudras) {
            group.leave()
        }
        //}
        
        //if SurveyData.shared.isContentAvailable(type: .Kriyas) {
            group.enter()
        self.getYogaFromServer(goal_type: .Kriyas) {
            group.leave()
        }
        //}
        
        group.notify(queue: .main) {
            Utils.stopActivityIndicatorinView(self.view)
        }
    }
    
    // MARK: - IBActions
    @IBAction func profileButtonClicked(_ sender: Any) {
        
    }
    
    @IBAction func menuButtonClicked(_ sender: Any) {
        
    }
    
    @IBAction func btn_Search_Action(_ sender: UIButton) {
        self.view.endEditing(true)
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view recommendations", controller: self)
            return
        }
        let storyBoard = UIStoryboard(name: "MyHome", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "GlobalSearchViewController") as? GlobalSearchViewController else {
            return
        }
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }
    
    @IBAction func btn_Filter_Action(_ sender: UIControl) {
        if sender.tag == 101 {
            self.goToFoodHerbList(section_type: .food, arr_data: self.arr_Food)
        }
        else if sender.tag == 102 {
            self.goToFoodHerbList(section_type: .herbs, arr_data: self.arr_Herb)
        }
        else if sender.tag == 103 {
            self.goToFoodHerbList(section_type: .yoga, arr_data: self.arr_Yoga)
            //self.gotoKriyaMudraScreen(type: .yoga)
        }
        else if sender.tag == 104 {
            self.goToFoodHerbList(section_type: .mudra, arr_data: self.arr_Mudra)
//            self.gotoKriyaMudraScreen(type: .mudra)
        }
        else if sender.tag == 105 {
            self.goToFoodHerbList(section_type: .pranayama, arr_data: self.arr_Pranayam)
//            self.gotoKriyaMudraScreen(type: .pranayama)
        }
        else if sender.tag == 106 {
            self.goToFoodHerbList(section_type: .meditation, arr_data: self.arr_Meditation)
//            self.gotoKriyaMudraScreen(type: .meditation)
        }
        else if sender.tag == 107 {
            self.goToFoodHerbList(section_type: .kriya, arr_data: self.arr_Kriya)
//            self.gotoKriyaMudraScreen(type: .kriya)
        }
    }
}

extension HOEForYouHomeVC: RecommendationSeeAllDelegate {
    func didSelectedSelectRow(indexPath: IndexPath, index: Int?) {
        let rowType = self.dataArray[indexPath.row]
        switch rowType {
        case .trainer(_,_, let trainerList):
            guard let index = index else {
                showTrainerList(with: trainerList)
                return
            }
            
            guard let obj_trainerDetails = Story_ForYou.instantiateViewController(withIdentifier: "TrainerDetailsViewController") as? TrainerDetailsViewController else {
                return
            }
            obj_trainerDetails.trainer = trainerList[index]
            obj_trainerDetails.hidesBottomBarWhenPushed = true
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.pushViewController(obj_trainerDetails, animated: true)
            
            break
        case .playlits(_,_, let playList):
            guard let index = index else {
                //If index is not present then move to see all
               showCuretedPlayList(with: playList)
                return
            }
            let storyBoard = UIStoryboard(name: "PlayList", bundle: nil)
            guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "PlayListDetailVC") as? PlayListDetailVC else {
                return
            }
            if let favID = playList[index].favorite_id, let playListId = Int(favID) {
                objPlayList.playListId = playListId
                objPlayList.type = playList[index].type ?? ""
                objPlayList.navTitle = playList[index].name ?? ""
                objPlayList.hidesBottomBarWhenPushed = true
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.pushViewController(objPlayList, animated: true)
            }
            
        case .yoga(_, let yogaArray):
            guard let index = index else {
                //If index is not present then move to see all
                //self.showYogaPlayListScreen(data: yogaArray)
                self.goToFoodHerbList(section_type: .yoga, arr_data: self.arr_Yoga)
                return
            }
            
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objYoga = storyBoard.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
                return
            }
            objYoga.modalPresentationStyle = .fullScreen
            objYoga.yoga = yogaArray[index]
            self.present(objYoga, animated: true, completion: nil)
            
        case .weekly_planner:
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "FoodsViewController") as? FoodsViewController else {
                return
            }
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.pushViewController(objFoodView, animated: true)
            
        case .food(let section, let foodArray):
            guard let index = index else {
                //If index is not present then move to see all
                //self.showDetailScreen(sectionType: section, data: foodArray)
                self.goToFoodHerbList(section_type: .food, arr_data: self.arr_Food)
                return
            }
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "FoodsViewController") as? FoodsViewController else {
                return
            }
            let foodDemo = foodArray[index]
            objFoodView.type = self.recommendationVikriti
            objFoodView.selectedType = foodDemo.foodType ?? ""
            objFoodView.selectedId = Int(foodDemo.id)
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.pushViewController(objFoodView, animated: true)
            
        case .herbs(let section, let herbTypeArray):
            guard let index = index else {
                //If index is not present then move to see all
                //self.showDetailScreen(sectionType: section, data: herbTypeArray)
                self.goToFoodHerbList(section_type: .herbs, arr_data: self.arr_Herb)
                return
            }
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let vc = storyBoard.instantiateViewController(withIdentifier: "HerbsViewController") as? HerbsViewController else {
                return
            }
            let herbType = herbTypeArray[index]
            vc.type = self.recommendationVikriti
            vc.selectedType = herbType.herbs_types ?? ""
            vc.selectedId = Int(herbType.id)
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .meditation( _, let data):
            guard let index = index else {
                //If index is not present then move to see all
                //self.showMeditationPlayListScreen(data: data)
                self.goToFoodHerbList(section_type: .meditation, arr_data: self.arr_Meditation)
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
                self.goToFoodHerbList(section_type: .pranayama, arr_data: self.arr_Pranayam)
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
                self.goToFoodHerbList(section_type: .mudra, arr_data: self.arr_Mudra)
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
                self.goToFoodHerbList(section_type: .kriya, arr_data: self.arr_Kriya)
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
    
    
    func didSelectedSelectRowForRedeem(indexPath: IndexPath, index: Int?) {
        
        unlockIndexPath = indexPath
        unlockIndex = index ?? 0
        
        let rowType = self.dataArray[indexPath.row]
        switch rowType {
        case .playlits(_,_, let playList):
            guard let index = index else {
                return
            }
            
            accessPoint = Int(playList[index].access_point)
            name = playList[index].item ?? "benefit"
            favID = Int(playList[index].id)
            
        case .yoga(_, let dataArray):
            guard let index = index else {
                return
            }
            accessPoint = Int(dataArray[index].access_point)
            name = "yoga"
            favID = Int(dataArray[index].id)
            
        case .pranayama(_, let dataArray):
            guard let index = index else {
                return
            }
            accessPoint = Int(dataArray[index].access_point)
            name = "pranayama"
            favID = Int(dataArray[index].id)
            
        case .meditation(_, let dataArray):
            guard let index = index else {
                return
            }
            accessPoint = Int(dataArray[index].access_point)
            name = "meditation"
            favID = Int(dataArray[index].id)
            
        case .mudra(_, let dataArray):
            accessPoint = Int(dataArray[0].access_point)
            name = "mudra"
            favID = 0
            
        case .kriya(_, let dataArray):
            accessPoint = Int(dataArray[0].access_point)
            name = "kriya"
            favID = 0
            
        default:
            break
        }
        
        AyuSeedsRedeemManager.shared.redeemItem(accessPoint: accessPoint, name: name, favID: favID, presentingVC: self.tabBarController ?? self) { [weak self] (isSuccess, isSubscriptionResumeSuccess, title, message) in
            guard let strongSelf = self else { return }
            strongSelf.refreshData()
        }
    }
    
    func showDetailScreen(sectionType: ForYouSectionType, data: [NSManagedObject], isRequiredLoadingDataFromServer: Bool = false, animated: Bool = true) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "HOEYogaListVC") as? HOEYogaListVC else {
            return
        }
        objFoodView.recommendationPrakriti = self.recommendationPrakriti
        objFoodView.recommendationVikriti = self.recommendationVikriti
        objFoodView.dataArray = data
        objFoodView.sectionType = sectionType
        objFoodView.isStatusVisible = true
        if sectionType == .food, isRequiredLoadingDataFromServer {
            objFoodView.isFromHome = true
        }
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(objFoodView, animated: animated)
    }
    
    func showTrainerList(with trainerList: [Trainer], isRequiredLoadingDataFromServer: Bool = false) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "TrainersListViewController") as? TrainersListViewController else {
            return
        }
        vc.trainerArray = trainerList
        vc.recommendationVikriti = recommendationVikriti
        vc.isRequiredLoadingDataFromServer = isRequiredLoadingDataFromServer
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showCuretedPlayList(with playList: [PlayList], isRequiredLoadingDataFromServer: Bool = false) {
        let storyBoard = UIStoryboard(name: "PlayList", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "PlayListViewController") as? PlayListViewController else {
            return
        }
        vc.dataArray = playList
        vc.recommendationVikriti = recommendationVikriti
        vc.isRequiredLoadingDataFromServer = isRequiredLoadingDataFromServer
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showMeditationPlayListScreen(data: [Meditation], isRequiredLoadingDataFromServer: Bool = false, animated: Bool = true) {
        /*
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = self.recommendationPrakriti
        objPlayList.recommendationVikriti = self.recommendationVikriti
        objPlayList.meditationArray = data
        objPlayList.istype = .meditation
        objPlayList.isFromHomeScreen = isRequiredLoadingDataFromServer
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(objPlayList, animated: animated)
        */
    }
    
    func showPranayamaPlayListScreen(data: [Pranayama], isRequiredLoadingDataFromServer: Bool = false, animated: Bool = true) {
        /*
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = self.recommendationPrakriti
        objPlayList.recommendationVikriti = self.recommendationVikriti
        objPlayList.pranayamaArray = data
        objPlayList.istype = .pranayama
        objPlayList.isFromHomeScreen = isRequiredLoadingDataFromServer
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(objPlayList, animated: animated)
        */
    }
    
    func showYogaPlayListScreen(data: [Yoga], isRequiredLoadingDataFromServer: Bool = false, animated: Bool = true) {
        /*
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = self.recommendationPrakriti
        objPlayList.recommendationVikriti = self.recommendationVikriti
        objPlayList.yogaArray = data
        objPlayList.istype = .yoga
        objPlayList.isFromHomeScreen = isRequiredLoadingDataFromServer
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(objPlayList, animated: animated)
        */
    }
    
    func showMudraPlayListScreen(data: [Mudra]) {
        /*
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = self.recommendationPrakriti
        objPlayList.recommendationVikriti = self.recommendationVikriti
        objPlayList.mudraArray = data
        objPlayList.istype = .mudra
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(objPlayList, animated: true)
        */
    }
    
    func showkriyaPlayListScreen(data: [Kriya]) {
//        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
//        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
//            return
//        }
//        objPlayList.recommendationPrakriti = self.recommendationPrakriti
//        objPlayList.recommendationVikriti = self.recommendationVikriti
//        objPlayList.kriyaArray = data
    }
    
    func gotoKriyaMudraScreen(type: IsSectionType, is_RequiredLoadData_Server: Bool = false, animat: Bool = true) {
        let objVC = Story_ForYou.instantiateViewController(withIdentifier: "YogaPlayListViewController") as! YogaPlayListViewController
        
        if type == .kriya {
            objVC.kriyaArray = self.arr_Kriya
        }
        if type == .mudra {
            objVC.mudraArray = self.arr_Mudra
        }
        if type == .yoga {
            objVC.yogaArray = self.arr_Yoga
        }
        if type == .pranayama {
            objVC.pranayamaArray = self.arr_Pranayam
        }
        if type == .meditation {
            objVC.meditationArray = self.arr_Meditation
        }
        
        objVC.istype = type
        objVC.isFromHomeScreen = is_RequiredLoadData_Server
        objVC.recommendationVikriti = self.recommendationVikriti
        objVC.recommendationPrakriti = self.recommendationPrakriti
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(objVC, animated: animat)
    }
    
    func goToFoodHerbList(section_type: IsSectionType, arr_data: [NSManagedObject], is_RequiredLoadData_Server: Bool = false, animat: Bool = true) {
//        guard let objVC = Story_ForYou.instantiateViewController(withIdentifier: "HOEYogaListVC") as? HOEYogaListVC else {
//            return
//        }
        guard let objVC = Story_ForYou.instantiateViewController(withIdentifier: "ForYouListVC") as? ForYouListVC else {
            return
        }
        objVC.recommendationPrakriti = self.recommendationPrakriti
        objVC.recommendationVikriti = self.recommendationVikriti
        objVC.dataArray = arr_data
        objVC.sectionType = section_type
        
        objVC.arr_Yoga = self.arr_Yoga
        objVC.arr_Pranayam = self.arr_Pranayam
        objVC.arr_Meditation = self.arr_Meditation
        objVC.arr_Kriya = self.arr_Kriya
        objVC.arr_Mudra = self.arr_Mudra
        objVC.arr_Food = self.arr_Food
        objVC.arr_Herb = self.arr_Herb
        
        objVC.isStatusVisible = true
        objVC.hidesBottomBarWhenPushed = true
        if section_type == .food, is_RequiredLoadData_Server {
            objVC.isFromHome = true
        }
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(objVC, animated: animat)
    }
    
}

extension HOEForYouHomeVC {
    func getFoodFromServer(completion: @escaping ()-> Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            var params = ["type": recommendationVikriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
            params["type"] = appDelegate.cloud_vikriti_status
            
            let urlString = kBaseNewURL + endPoint.v2.getFoodType.rawValue
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                defer {
                    completion()
                }
                switch response.result {
                
                case .success(let value):
                    Utils.stopActivityIndicatorinView(self.view)
                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                    guard let arrResponse = value as? [[String: AnyObject]] else {
                        return
                    }
                    
                    /*for dic in arrQuestions {
                     FoodDemo.createFoodData(dicData: dic)
                     }
                     self.getFoodFromDB()*/
                    let dataArray = arrResponse.compactMap{ FoodDemo.createFoodData(dicData: $0) }
                    self.dataArray.append(.food(section:.food , data: dataArray))
                    self.arr_Food = dataArray
                    
                case .failure(let error):
                    print(error)
                    Utils.stopActivityIndicatorinView(self.view)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
//                DispatchQueue.main.async(execute: {
//                    Utils.stopActivityIndicatorinView(self.view)
//                })
            }
        } else {
            Utils.stopActivityIndicatorinView(self.view)
            self.getFoodFromDB()
            completion()
        }
    }
    
    func getHerbTypesFromServer(completion: @escaping ()-> Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            var params = ["type": recommendationVikriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
            params["type"] = appDelegate.cloud_vikriti_status
            
            let urlString = kBaseNewURL + endPoint.getHerbsTypes.rawValue
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                defer {
                    completion()
                }
                switch response.result {
                
                case .success(let value):
                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                    guard let arrResponse = value as? [[String: AnyObject]] else {
                        return
                    }
                    
                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "HerbType")
                    let dataArray = arrResponse.compactMap{ HerbType.createHerbData(dicData: $0) }
                    self.dataArray.append(.herbs(section:.herbs , data: dataArray))
                    self.arr_Herb = dataArray
                    
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
    
//    func getYogaFromServer(completion: @escaping ()-> Void) {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.getForYouYoga.rawValue
//            let params = ["type": recommendationVikriti.rawValue,"typetwo": recommendationPrakriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//
//                defer {
//                    completion()
//                }
//                switch response.result {
//
//                case .success(let value):
//                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
//                    guard let arrResponse = (value as? [[String: AnyObject]]) else {
//
//                        return
//                    }
//                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Yoga")
//                    let dataArray = arrResponse.compactMap{ Yoga.createYogaData(dicYoga: $0) }.sorted(by: {$0.access_point < $1.access_point})
//                    if !dataArray.isEmpty {
//                        self.dataArray.append(.yoga(section: .yoga, data: dataArray))
//                    }
//                //self.getYogaFromDB()
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
//            self.getYogaFromDB()
//            completion()
//        }
//    }
    
//    func getPranayamaFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.getPranayamaios.rawValue
//            let params = ["type": recommendationVikriti.rawValue,"typetwo": recommendationPrakriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Pranayama")
//                    let dataArray = arrResponse.compactMap{ Pranayama.createPranayamaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
//                    if !dataArray.isEmpty {
//                        self.dataArray.append(.pranayama(section: .pranayama, data: dataArray))
//                    }
//                //self.getPranayamaDataFromDB()
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            self.getPranayamaDataFromDB()
//            completion()
//            // Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
//        }
//    }
    
//    func getMeditationFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.getMeditationios.rawValue
//            let params = ["type": recommendationVikriti.rawValue,"typetwo": recommendationPrakriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Meditation")
//                    let dataArray = arrResponse.compactMap{ Meditation.createMeditationData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
//                    if !dataArray.isEmpty {
//                        self.dataArray.append(.meditation(section: .meditation, data: dataArray))
//                    }
//                //self.getMeditationDataFromDB()
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            self.getMeditationDataFromDB()
//            completion()
//            // Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
//        }
//    }
    
//    func getMudraFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.getMudraios.rawValue
//            let params = ["type": recommendationVikriti.rawValue,"typetwo": recommendationPrakriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Mudra")
//                    let dataArray = arrResponse.compactMap{ Mudra.createMudraData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
//                    if !dataArray.isEmpty {
//                        self.dataArray.append(.mudra(section: .mudra, data: dataArray))
//                    }
//                //self.getMudraDataFromDB()
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            self.getMudraDataFromDB()
//            completion()
//            // Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
//        }
//    }
    
    
//    func getKriyaFromServer (completion: @escaping ()->Void) {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.getKriyaios.rawValue
//            let params = ["type": recommendationVikriti.rawValue,"typetwo": recommendationPrakriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
//                    guard let arrResponse = (value as? [[String: Any]]) else {
//                        completion()
//                        return
//                    }
//                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "Kriya")
//                    let dataArray = arrResponse.compactMap{ Kriya.createKriyaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
//                    if !dataArray.isEmpty {
//                        self.dataArray.append(.kriya(section: .kriya, data: dataArray))
//                    }
//                //self.getKriyaDataFromDB()
//                case .failure(let error):
//                    print(error)
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                completion()
//            }
//        } else {
//            self.getKriyaDataFromDB()
//            completion()
//            // Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
//        }
//    }
    
    func getPlayListFromServer(completion: @escaping ()-> Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.v2.getExpBenefitsPlayList.rawValue
            var param = ["type": recommendationVikriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
            param["type"] = appDelegate.cloud_vikriti_status
            
            AF.request(urlString, method: .post, parameters: param, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                defer {
                    completion()
                }
                switch response.result {
                
                case .success(let value):
                    print(response)
                    guard let arrPlayList = (value as? [[String: AnyObject]]) else {
                        return
                    }
                    //CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "PlayList")
                    for dic in arrPlayList {
                        PlayList.createPlayListData(dicData: dic)
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
    
    func getIndividualTrainerDetailsFromServer(trainerID: String, completion: @escaping (Trainer?)-> Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.getTrainer.rawValue
            var param = ["type": recommendationVikriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
            param["type"] = appDelegate.cloud_vikriti_status
            
            AF.request(urlString, method: .post, parameters: param, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                defer {
                    completion(nil)
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
                    var trainerDetail: Trainer?
                    for dic in dataResponse {
                        let trainer = Trainer.createTrainerData(dicData: dic)
                        if let id = dic["id"] as? String, id == trainerID {
                            trainerDetail = trainer
                        }
                    }
                    completion(trainerDetail)
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        } else {
            completion(nil)
        }
    }
}

//MARK: Database calls
extension HOEForYouHomeVC {
    
    func getPlayListFromDB() {
        guard let arrPlayList = CoreDataHelper.sharedInstance.getListOfEntityWithName("PlayList", withPredicate: nil, sortKey: nil, isAscending: false) as? [PlayList] else {
            return
        }
        
        self.dataArray.append(.playlits(section: .playlist, title: "Curated list for you", data: arrPlayList))
    }
    
    func getTrainerFromDB() {
        guard let arrTrainer = CoreDataHelper.sharedInstance.getListOfEntityWithName("Trainer", withPredicate: nil, sortKey: nil, isAscending: false) as? [Trainer] else {
            return
        }
        
        self.dataArray.append(.trainer(section: .trainer, title: "Wellness Trainers", data: arrTrainer))
    }
    
    func getYogaFromDB() {
        let predicate1 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        let predicate2 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationPrakriti.rawValue)
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
        
        guard let arrYoga = CoreDataHelper.sharedInstance.getListOfEntityWithName("Yoga", withPredicate: predicate, sortKey: "name", isAscending: true) as? [Yoga] else {
            return
        }
        let arrSorted = arrYoga.sorted { (obj1, obj2) -> Bool in
            return obj1.access_point < obj2.access_point
        }
        
        self.dataArray.append(.yoga(section: .yoga, data: arrSorted))
        self.arr_Yoga = arrSorted
    }
    
    func getFoodFromDB() {
        guard let arrFood = CoreDataHelper.sharedInstance.getListOfEntityWithName("FoodDemo", withPredicate: nil, sortKey: nil, isAscending: false) as? [FoodDemo] else {
            return
        }
        self.dataArray.append(.food(section:.food , data: arrFood))
        self.arr_Food = arrFood
    }
    
    func getHerbTypesFromDB() {
        guard let arrHerb = CoreDataHelper.sharedInstance.getListOfEntityWithName("HerbType", withPredicate: nil, sortKey: nil, isAscending: false) as? [HerbType] else {
            return
        }
        self.dataArray.append(.herbs(section:.herbs , data: arrHerb))
        self.arr_Herb = arrHerb
    }
    
    func getPranayamaDataFromDB() {
        let predicate1 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        let predicate2 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationPrakriti.rawValue)
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
        guard let arrPrananyam = CoreDataHelper.sharedInstance.getListOfEntityWithName("Pranayama", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Pranayama] else {
            return
        }
        let arrSorted = arrPrananyam.sorted { (obj1, obj2) -> Bool in
            return obj1.access_point < obj2.access_point
        }
        
        self.dataArray.append(.pranayama(section: .pranayama, data: arrSorted))
        self.arr_Pranayam = arrSorted
    }
    
    func getMeditationDataFromDB() {
        let predicate1 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        let predicate2 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationPrakriti.rawValue)
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
        guard let arrMeditation = CoreDataHelper.sharedInstance.getListOfEntityWithName("Meditation", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Meditation] else {
            return
        }
        let arrSorted = arrMeditation.sorted { (obj1, obj2) -> Bool in
            return obj1.access_point < obj2.access_point
        }
        
        self.dataArray.append(.meditation(section: .meditation, data: arrSorted))
        self.arr_Meditation = arrSorted
    }
    
    func getMudraDataFromDB() {
        let predicate1 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        let predicate2 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationPrakriti.rawValue)
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
        guard let arrMudra = CoreDataHelper.sharedInstance.getListOfEntityWithName("Mudra", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Mudra] else {
            return
        }
        self.dataArray.append(.mudra(section: .mudra, data: arrMudra))
        self.arr_Mudra = arrMudra
    }
    
    func getKriyaDataFromDB() {
        let predicate1 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationVikriti.rawValue)
        let predicate2 = NSPredicate(format: "type CONTAINS[cd] %@", recommendationPrakriti.rawValue)
        let predicate = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
        guard let arrKriya = CoreDataHelper.sharedInstance.getListOfEntityWithName("Kriya", withPredicate: predicate, sortKey: nil, isAscending: false) as? [Kriya] else {
            return
        }
        self.dataArray.append(.kriya(section: .kriya, data: arrKriya))
        self.arr_Kriya = arrKriya
    }
    
}

extension HOEForYouHomeVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        guard !kSharedAppDelegate.userId.isEmpty else {
            Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view recommendations", controller: self)
            return
        }
        let storyBoard = UIStoryboard(name: "MyHome", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "GlobalSearchViewController") as? GlobalSearchViewController else {
            return
        }
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(objPlayList, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension HOEForYouHomeVC {
    func handlePushNotificationDeepLink() {
        if let notificationInfo = kSharedAppDelegate.notificationInfo, notificationInfo.tabSelectedIndex == 1 {
            switch notificationInfo.redirectEvent {
            case .Trainer:
                if let otherInfo = notificationInfo.otherInfo, let trainerID = otherInfo["trainer_id"] as? String {
                    showTrainerDetailScreen(with: trainerID)
                } else {
                    showTrainerList(with: [], isRequiredLoadingDataFromServer: true)
                }
                
            case .CuratedLists:
                showCuretedPlayList(with: [], isRequiredLoadingDataFromServer: true)
                
            default:
                break
            }
            kSharedAppDelegate.notificationInfo = nil
        }
    }
    
    func showTrainerDetailScreen(with trainerID: String) {
        getIndividualTrainerDetailsFromServer(trainerID: trainerID) { trainer in
            if let trainer = trainer {
                let vc = TrainerDetailsViewController.instantiateFromStoryboard("ForYou")
                vc.trainer = trainer
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension HOEForYouHomeVC {
    func showViewSuggestionScreenForSparshnaResult() {
        if let screen = kSharedAppDelegate.viewSuggestionScreenFromSparshnaResult {
            switch screen {
            case .pranayam:
                showPranayamaPlayListScreen(data: [], isRequiredLoadingDataFromServer: true, animated: false)
            case .yoga:
                showYogaPlayListScreen(data: [], isRequiredLoadingDataFromServer: true, animated: false)
            case .meditation:
                showMeditationPlayListScreen(data: [], isRequiredLoadingDataFromServer: true, animated: false)
            default:
                showDetailScreen(sectionType: .food, data: [], isRequiredLoadingDataFromServer: true, animated: false)
            }
        }
        kSharedAppDelegate.viewSuggestionScreenFromSparshnaResult = nil
    }
}


//MARK: - API Call
extension HOEForYouHomeVC {
    
    func getYogaFromServer (goal_type: TodayGoal_Type, completion: @escaping ()->Void) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.getKriyaiOS_NewAPI.rawValue
            
            var params = ["from": "foryou",
                          "today_keys": "",//Video fav ID from Todaysgoal api
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
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    Utils.stopActivityIndicatorinView(self.view)
                    guard let arrResponse = (value as? [[String: Any]]) else {
                        completion()
                        return
                    }
                    if goal_type == .Yogasana {

                        let dataArray = arrResponse.compactMap{ Yoga.createYogaData(dicYoga: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        if !dataArray.isEmpty {
                            self.dataArray.append(.yoga(section: .yoga, data: dataArray))
                            self.arr_Yoga = dataArray
                        }

                    }
                    else if goal_type == .Pranayama {
                        
                        let dataArray = arrResponse.compactMap{ Pranayama.createPranayamaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        if !dataArray.isEmpty {
                            self.dataArray.append(.pranayama(section: .pranayama, data: dataArray))
                            self.arr_Pranayam = dataArray
                        }
                        
                    }
                    else if goal_type == .Meditation {
                        
                        let dataArray = arrResponse.compactMap{ Meditation.createMeditationData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        if !dataArray.isEmpty {
                            self.dataArray.append(.meditation(section: .meditation, data: dataArray))
                            self.arr_Meditation = dataArray
                        }
                        
                    }
                    else if goal_type == .Kriyas {
                        
                        let dataArray = arrResponse.compactMap{ Kriya.createKriyaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        if !dataArray.isEmpty {
                            self.dataArray.append(.kriya(section: .kriya, data: dataArray))
                            self.arr_Kriya = dataArray
                        }
                        
                    }
                    else if goal_type == .Mudras {
                        
                        let dataArray = arrResponse.compactMap{ Mudra.createMudraData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        if !dataArray.isEmpty {
                            self.dataArray.append(.mudra(section: .mudra, data: dataArray))
                            self.arr_Mudra = dataArray
                        }

                    }

                case .failure(let error):
                    print(error)
                    Utils.stopActivityIndicatorinView(self.view)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
//                DispatchQueue.main.async(execute: {
//                    Utils.stopActivityIndicatorinView(self.view)
//                })
                completion()
            }
        } else {
            Utils.stopActivityIndicatorinView(self.view)
            if goal_type == .Yogasana {
                getYogaFromDB()
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
}
