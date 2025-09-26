//
//  ForYouListVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 05/09/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class ForYouListVC: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var arr_Yoga = [Yoga]()
    var arr_Mudra = [Mudra]()
    var arr_Kriya = [Kriya]()
    var arr_Food = [FoodDemo]()
    var arr_Herb = [HerbType]()
    var arr_Pranayam = [Pranayama]()
    var arr_Meditation = [Meditation]()
    var arr_All_Data = [NSManagedObject] ()
    
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_infoText: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collect_view: UICollectionView!
    @IBOutlet weak var collect_view_filter: UICollectionView!
    @IBOutlet weak var constraint_Search_Height: NSLayoutConstraint!

    var is_searchOpen = false
    var dataArray = [NSManagedObject]()
    var sectionType : IsSectionType = .food
    var recommendationVikriti: RecommendationType = .kapha
    var recommendationPrakriti: RecommendationType = .kapha
    var isStatusVisible = true
    var isFromHome = false
    var headerTitle: String = ""
    var isFromAyuverseContentLibrary = false
    var arr_Filter: [IsSectionType] = [.food, .herbs, .yoga, .pranayama, .meditation, .mudra, .kriya]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHeader()
        setBackButtonTitle()
        self.collect_view.register(nibWithCellClass: ForYouFoodCollectionCell.self)
        self.collect_view.register(nibWithCellClass: ForYouFoodCollectionCell.self)
        self.collect_view_filter.register(nibWithCellClass: ForYouFilterCollectionCell.self)
        self.collect_view.register(nibWithCellClass: ForYouYogaKriyaMudraCollectionCell.self)

        recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        self.collect_view.reloadData()
    }
    
    func setupHeader() {
        if sectionType == .food {
            self.arr_All_Data = self.arr_Food
            self.constraint_Search_Height.constant = 0.0
            self.lbl_infoText.text = "Improved wellness with personalized food suggestions"
        }
        else if sectionType == .herbs {
            self.arr_All_Data = self.arr_Herb
            self.lbl_infoText.text = "Natural healing herbs to improve your overall wellness"
        }
        else if sectionType == .yoga {
            self.arr_All_Data = self.arr_Yoga
            self.lbl_infoText.text = "Enhancing Wellbeing through Personalized Yogasana"
        }
        else if sectionType == .meditation {
            self.arr_All_Data = self.arr_Meditation
            self.lbl_infoText.text = "Enhancing Wellbeing through Personalized Meditation"
        }
        else if sectionType == .pranayama {
            self.arr_All_Data = self.arr_Pranayam
            self.lbl_infoText.text = "Enhancing Wellness via Customized Pranayama Techniques"
        }
        else if sectionType == .kriya {
            self.arr_All_Data = self.arr_Kriya
            self.lbl_infoText.text = "Elevating Wellbeing through Customized Kriyas"
        }
        else if sectionType == .mudra {
            self.arr_All_Data = self.arr_Mudra
            self.lbl_infoText.text = "Elevating Wellbeing through Customized Mudras"
        }
        self.collect_view.reloadData()
        self.scroll_CollectionViewPosition()
    }
    
    func scroll_CollectionViewPosition() {
        self.lbl_Title.text = self.sectionType.title
        self.searchBar.placeholder = sectionType.title
        self.collect_view_filter.reloadData()
        if let indx = self.arr_Filter.firstIndex(of: self.sectionType) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                self.collect_view_filter.scrollToItem(at: IndexPath.init(row: indx, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: Actions
    @IBAction func btn_Filter_Action(_ sender: UIButton) {
        guard let objFilterView = Story_ForYou.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController else {
            return
        }
        objFilterView.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(objFilterView, animated: true)
    }

    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Search_Action(_ sender: UIButton) {
        if self.is_searchOpen == false {
            self.is_searchOpen = true
            UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.constraint_Search_Height.constant = 44
                self.view.layoutIfNeeded()
            }) { (success) in
            }
        }
        else {
            self.is_searchOpen = false
            UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.constraint_Search_Height.constant = 0
                self.view.layoutIfNeeded()
            }) { (success) in
            }
        }
    }
    
    
    
    
    //MARK: CollectionViewDataSource/Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collect_view_filter {
            return self.arr_Filter.count
        }
        return self.arr_All_Data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collect_view_filter {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForYouFilterCollectionCell", for: indexPath as IndexPath) as? ForYouFilterCollectionCell else {
                return UICollectionViewCell()
            }
            cell.lbl_Title.text = self.arr_Filter[indexPath.item].title
            if self.arr_Filter[indexPath.item] == self.sectionType {
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
        else {
            
            if self.sectionType == .yoga || self.sectionType == .mudra || self.sectionType == .meditation || self.sectionType == .kriya || self.sectionType == .pranayama {
                return self.getCellForYogaKriyaMudra(indexPath: indexPath)
            }
            else if self.sectionType == .food {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForYouFoodCollectionCell", for: indexPath as IndexPath) as? ForYouFoodCollectionCell else {
                    return UICollectionViewCell()
                }
                guard let food = self.arr_All_Data[indexPath.row] as? FoodDemo else {
                    return UICollectionViewCell()
                }
                cell.lockView.isHidden = true
                cell.btnLock.tag = indexPath.row
                cell.configureUI(foodType: food)
                return cell
            }
            else if self.sectionType == .herbs {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForYouFoodCollectionCell", for: indexPath as IndexPath) as? ForYouFoodCollectionCell else {
                    return UICollectionViewCell()
                }
                guard let herbType = self.arr_All_Data[indexPath.row] as? HerbType else {
                    return UICollectionViewCell()
                }
                cell.lockView.isHidden = true
                cell.btnLock.tag = indexPath.row
                cell.configureUI(herbType: herbType)
                return cell
            }
            else {
                return UICollectionViewCell()
            }
        }
        
    }
    
    func getCellForYogaKriyaMudra(indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collect_view.dequeueReusableCell(withReuseIdentifier: "ForYouYogaKriyaMudraCollectionCell", for: indexPath as IndexPath) as? ForYouYogaKriyaMudraCollectionCell else {
            return UICollectionViewCell()
        }
        
        cell.btnLock.tag = indexPath.row
        
        if self.sectionType == .yoga {
            guard let yoga = self.arr_All_Data[indexPath.row] as? Yoga else {
                return UICollectionViewCell()
            }
            cell.configureUI(yoga: yoga)
            
            if yoga.access_point == 0 {
                cell.lockView.isHidden = true
                cell.view_unlock_ayuseed.isHidden = true
            }
            else {
                cell.lockView.isHidden = yoga.redeemed
                cell.view_unlock_ayuseed.isHidden = yoga.redeemed
            }
            
            cell.didTappedonLockView = { (sender) in
                self.didSelectedSelectRowForRedeem(favID: Int(yoga.id), name: "yoga", accessPoint: Int(yoga.access_point))
            }
        }
        else if self.sectionType == .meditation {
            guard let meditation = self.arr_All_Data[indexPath.row] as? Meditation else {
                return UICollectionViewCell()
            }
            cell.configureUIMeditation(meditation: meditation)

            if meditation.access_point == 0 {
                cell.lockView.isHidden = true
                cell.view_unlock_ayuseed.isHidden = true
            }
            else {
                cell.lockView.isHidden = meditation.redeemed
                cell.view_unlock_ayuseed.isHidden = meditation.redeemed
            }
            
            cell.didTappedonLockView = { (sender) in
                self.didSelectedSelectRowForRedeem(favID: Int(meditation.id), name: "meditation", accessPoint: Int(meditation.access_point))
            }
        }
        else if self.sectionType == .pranayama {
            guard let pranayama = self.arr_All_Data[indexPath.row] as? Pranayama else {
                return UICollectionViewCell()
            }
            cell.configureUIPranayama(pranayama: pranayama)

            if pranayama.access_point == 0 {
                cell.lockView.isHidden = true
                cell.view_unlock_ayuseed.isHidden = true
            }
            else {
                cell.lockView.isHidden = pranayama.redeemed
                cell.view_unlock_ayuseed.isHidden = pranayama.redeemed
            }
            
            cell.didTappedonLockView = { (sender) in
                self.didSelectedSelectRowForRedeem(favID: Int(pranayama.id), name: "pranayama", accessPoint: Int(pranayama.access_point))
            }
        }
        else if self.sectionType == .mudra {
            guard let mudra = self.arr_All_Data[indexPath.row] as? Mudra else {
                return UICollectionViewCell()
            }
            cell.configureUIMudra(mudra: mudra)
            
            if mudra.access_point == 0 {
                cell.lockView.isHidden = true
                cell.view_unlock_ayuseed.isHidden = true
            }
            else {
                cell.lockView.isHidden = mudra.redeemed
                cell.view_unlock_ayuseed.isHidden = mudra.redeemed
            }
            
            cell.didTappedonLockView = { (sender) in
                self.didSelectedSelectRowForRedeem(favID: 0, name: "mudra", accessPoint: Int(mudra.access_point))
            }
        }
        else if self.sectionType == .kriya {
            guard let kriya = self.arr_All_Data[indexPath.row] as? Kriya else {
                return UICollectionViewCell()
            }
            cell.configureUIKriya(kriya: kriya)
            
            if kriya.access_point == 0 {
                cell.lockView.isHidden = true
                cell.view_unlock_ayuseed.isHidden = true
            }
            else {
                cell.lockView.isHidden = kriya.redeemed
                cell.view_unlock_ayuseed.isHidden = kriya.redeemed
            }
            
            cell.didTappedonLockView = { (sender) in
                self.didSelectedSelectRowForRedeem(favID: 0, name: "kriya", accessPoint: Int(kriya.access_point))
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collect_view_filter {
            return CGSize(width: 100, height: 50)
        }
        else {
            let padding: CGFloat = 30
            if sectionType == .food || sectionType == .herbs {
                let collectionViewSize = collectionView.frame.size.width - padding
                return CGSize(width: collectionViewSize/2, height: collectionViewSize/2 - 12)
            }
            else if self.sectionType == .yoga || self.sectionType == .pranayama || self.sectionType == .kriya || self.sectionType == .mudra || self.sectionType == .meditation {
                return CGSize(width: self.collect_view.frame.size.width, height: 90)
            }
            else {
                return CGSize(width: 0, height: 0)
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collect_view_filter {
            self.sectionType = self.arr_Filter[indexPath.item]
            self.setupHeader()
        }
        else {
            let dic_data = self.arr_All_Data[indexPath.item]
            
            if self.sectionType == .yoga || self.sectionType == .pranayama || self.sectionType == .kriya || self.sectionType == .mudra || self.sectionType == .meditation {
                yogaKriyaMudraSelectedAtIndex(type: self.sectionType, dataaaa: dic_data)
            }
            else if self.sectionType == .food {
                foodSelectedAtIndex(index: indexPath.item)
            }
            else if self.sectionType == .herbs {
                herbSelectedAtIndex(index: indexPath.item)
            }
        }
    }
    
    func foodSelectedAtIndex(index: Int) {
        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objFoodView = storyBoard.instantiateViewController(withIdentifier: "FoodsViewController") as? FoodsViewController else {
            return
        }
        guard let foodDemo = self.arr_All_Data[index] as? FoodDemo else {
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
        guard let herbType = self.arr_All_Data[index] as? HerbType, let vc = storyBoard.instantiateViewController(withIdentifier: "HerbsViewController") as? HerbsViewController else {
            return
        }
        vc.type = self.recommendationVikriti
        vc.selectedType = herbType.herbs_types ?? ""
        vc.selectedId = Int(herbType.id)
        vc.isFromAyuverseContentLibrary = isFromAyuverseContentLibrary
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func yogaKriyaMudraSelectedAtIndex(type: IsSectionType, dataaaa: NSManagedObject) {
        guard let obj = Story_ForYou.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
            return
        }
        obj.modalPresentationStyle = .fullScreen
        obj.yoga = dataaaa
        obj.kriya = dataaaa
        obj.mudra = dataaaa
        obj.pranayama = dataaaa
        obj.meditation = dataaaa
        obj.recommendationVikriti = self.recommendationVikriti
        obj.recommendationPrakriti = self.recommendationPrakriti
        obj.isFromForYou = true
        obj.istype = type
        self.present(obj, animated: true, completion: nil)
    }
    
    func didSelectedSelectRowForRedeem(favID: Int, name: String, accessPoint: Int) {
        AyuSeedsRedeemManager.shared.redeemItem(accessPoint: accessPoint, name: name, favID: favID, presentingVC: self.tabBarController ?? self) { [weak self] (isSuccess, isSubscriptionResumeSuccess, title, message) in
            guard let strongSelf = self else { return }
            strongSelf.refreshData()
        }
    }
    
    //MARK: RefreshData
    func refreshData() {
        self.dataArray.removeAll()
        self.arr_All_Data.removeAll()
        self.getYogaFromServer(self.sectionType) {
        }
    }
}

extension ForYouListVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        self.arr_All_Data.removeAll()
        self.arr_All_Data = dataArray
        self.collect_view.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        if searchText == "" {
            self.arr_All_Data.removeAll()
            self.arr_All_Data = dataArray
        } else {
            self.arr_All_Data =  dataArray.filter { (data: NSManagedObject) -> Bool in
                var stringToCompare = ""
                var stringToCompare2 = ""
                switch self.sectionType {
                case .yoga:
                    stringToCompare = (data as? Yoga)?.english_name ?? ""
                    stringToCompare2 = (data as? Yoga)?.name ?? ""
                case .food:
                    stringToCompare = (data as? FoodDemo)?.foodType ?? ""
                case .herbs:
                    stringToCompare = (data as? HerbType)?.herbs_types ?? ""
                case .meditation:
                    stringToCompare = (data as? Meditation)?.english_name ?? ""
                    stringToCompare2 = (data as? Meditation)?.name ?? ""
                case .pranayama:
                    stringToCompare = (data as? Pranayama)?.english_name ?? ""
                    stringToCompare2 = (data as? Pranayama)?.name ?? ""
                case .mudra:
                    stringToCompare = (data as? Mudra)?.english_name ?? ""
                    stringToCompare2 = (data as? Mudra)?.name ?? ""
                case .kriya:
                    stringToCompare = (data as? Kriya)?.english_name ?? ""
                    stringToCompare2 = (data as? Kriya)?.name ?? ""
                    
                default:
                    break
                }
                
                if stringToCompare.uppercased().contains(searchText.uppercased()) || stringToCompare2.uppercased().contains(searchText.uppercased()) {
                    return true
                } else {
                    return false
                }
            }
        }
        self.collect_view.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.arr_All_Data.removeAll()
        self.arr_All_Data = dataArray
        self.collect_view.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


//MARK: - API Call
extension ForYouListVC {
    
    func getYogaFromServer(_ type: IsSectionType, completion: @escaping ()->Void) {
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
            
            if type == .yoga {
                params["list_type"] = "yogasana"
            }
            else if type == .pranayama {
                params["list_type"] = "pranayam"
            }
            else if type == .meditation {
                params["list_type"] = "meditation"
            }
            else if type == .kriya {
                params["list_type"] = "kriya"
            }
            else if type == .mudra {
                params["list_type"] = "mudra"
            }

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let arrResponse = (value as? [[String: Any]]) else {
                        completion()
                        return
                    }
                    if type == .yoga {
                        let dataArray = arrResponse.compactMap{ Yoga.createYogaData(dicYoga: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        if !dataArray.isEmpty {
                            self.arr_Yoga = dataArray
                        }
                    }
                    else if type == .pranayama {
                        let dataArray = arrResponse.compactMap{ Pranayama.createPranayamaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        if !dataArray.isEmpty {
                            self.arr_Pranayam = dataArray
                        }
                    }
                    else if type == .meditation {
                        let dataArray = arrResponse.compactMap{ Meditation.createMeditationData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        if !dataArray.isEmpty {
                            self.arr_Meditation = dataArray
                        }
                    }
                    else if type == .kriya {
                        let dataArray = arrResponse.compactMap{ Kriya.createKriyaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        if !dataArray.isEmpty {
                            self.arr_Kriya = dataArray
                        }
                    }
                    else if type == .mudra {
                        let dataArray = arrResponse.compactMap{ Mudra.createMudraData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                        if !dataArray.isEmpty {
                            self.arr_Mudra = dataArray
                        }
                    }
                    self.setupHeader()

                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
                completion()
            }
        }
    }
}
