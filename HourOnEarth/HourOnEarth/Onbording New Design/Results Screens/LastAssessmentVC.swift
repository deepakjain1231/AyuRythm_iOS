//
//  LastAssessmentVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 29/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class LastAssessmentVC: UIViewController {

    var KpvPer1 = ""
    var KpvPer2 = ""
    var KpvPer3 = ""
    var arr_desc = [String]()
    var arr_Ids = [Int]()
    var arrIncreaseValue = [KPVType]()
    var arr_section = [[String: Any]]()
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tbl_View: UITableView!
    
    var arr_Food = [Food]()
    var arr_Pranayam = [Pranayama]()
    var arr_Yogasana = [Yoga]()
    var arr_Meditation = [Meditation]()
    var screenFrom = ScreenType.k_none
    var arr_Remedies: [HomeRemedies] = [HomeRemedies]()
    
    var isFromCameraView = false
    var dic_suggestion_data = [String: Any]()
    var resultDic: [String: Any] = [String: Any]()
    var resultParams = [SparshnaResultParamModel]()
    var resultFilteredParams = [SparshnaResultParamModel]()
    var currentKPVStatus = Utils.getYourCurrentKPVState()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_Title.text = "Current result".localized()
        
        if self.screenFrom == .today_screen {
            self.lbl_Title.text = "Last Assessment".localized()
        }
        
        //*********************************************************************************//
        //Register Table Cell==============================================================//
        self.tbl_View.register(nibWithCellClass: TitleHeaderTableCell.self)
        self.tbl_View.register(nibWithCellClass: SparshnaWellnessTableCell.self)
        self.tbl_View.register(nibWithCellClass: Aggrivation_MeansTableCell.self)
        self.tbl_View.register(nibWithCellClass: SuggestionForActivityTableCell.self)
        self.tbl_View.register(nibWithCellClass: EnhanceWellnessJourneyTableCell.self)
        self.tbl_View.register(nibWithCellClass: YogaSuggestionAssessmentTableCell.self)
        self.tbl_View.register(nibWithCellClass: SparshnaResultDisclaimerTableCell.self)
#if !APPCLIP
        self.tbl_View.register(nibWithCellClass: SideMenuButtonTableCell.self)
#else
#endif
        //***********************************************************************************//
        //***********************************************************************************//
        
#if !APPCLIP
        self.checkAggravatedValue()
#endif
        
        resultDic = getLastAssessmentData()
        getSparshnaMasterResultFromServer()
        getSparshnaParamDetailsFromServer()
        getRemediesFromServer()
        
        #if !APPCLIP
        // Code you don't want to use in your app clip.
        if isFromCameraView {
            //addEarnHistoryFromServer()
            Utils.completeDailyTask(favorite_id: "1", taskType: "sparshna")
            showScratchCardRewardScreen()
        }
        
        
        UIApplication.shared.isIdleTimerDisabled = false
        
        #endif
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.tabBarController?.tabBar.isHidden = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func backAction() {
#if !APPCLIP
        // Code you don't want to use in your app clip.
        if kSharedAppDelegate.isSocialRegisteredUser {
            kSharedAppDelegate.showHomeScreen()
            kSharedAppDelegate.isSocialRegisteredUser = false
        } else {
            if let stackVCs = self.navigationController?.viewControllers {
                if let activeSubVC = stackVCs.first(where: { type(of: $0) == MyHomeViewController.self }) {
                    self.navigationController?.popToViewController(activeSubVC, animated: false)
                }
            }
        }
#else
        // Code your app clip may access.
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let objDescription = storyBoard.instantiateViewController(withIdentifier: "RecommendationsVC") as! RecommendationsVC
        self.navigationController?.pushViewController(objDescription, animated: true)
#endif
    }
    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.backAction()
    }
    
    @IBAction func btn_Share_Action(_ sender: UIButton) {
        self.shareSparhnaResultButtonAction()
    }

}



//MARK: UITableView Delegates and Datasource Method

extension LastAssessmentVC: UITableViewDelegate, UITableViewDataSource {

    func manageSection() {
        self.arr_section.removeAll()
        
        var arr_suggestion = [[String: Any]]()
        arr_suggestion.append(["icon": "aggrivation_type_yogasana", "title": "Yogasana".localized(), "type": IsSectionType.yoga])
        arr_suggestion.append(["icon": "aggrivation_type_pranayam", "title": "Pranayama".localized(), "type": IsSectionType.pranayama])
        arr_suggestion.append(["icon": "aggrivation_type_meditation", "title": "Meditation".localized(), "type": IsSectionType.meditation])
        arr_suggestion.append(["icon": "aggrivation_type_kriyas", "title": "Kriyas".localized(), "type": IsSectionType.kriya])
        arr_suggestion.append(["icon": "aggrivation_type_mudras", "title": "Mudras".localized(), "type": IsSectionType.mudra])
        
#if !APPCLIP 
        self.arr_section.append(["identifier": "wellness_index"])
        let strText = String(format: "%@ aggravation may lead to".localized(), appDelegate.cloud_vikriti_status.capitalized)// getDisplayMessage().2.localized())
        
        if appDelegate.cloud_vikriti_status.trimed() != "" {//} getDisplayMessage().2.localized().trimed() != "" {
            self.arr_section.append(["identifier": "aggrivated_may_lead", "title": strText])
        }

        self.arr_section.append(["identifier": "wellness_journey", "title": "Enhance your wellness journey"])
        
        self.arr_section.append(["identifier": "header", "title": "Detailed result"])
        
        for dic_result in self.resultFilteredParams {
            var int_id = 0
            var arr_RandomData = [NSManagedObject]()
            var get_sectionType = self.getSection_Type(dic_result)
            if get_sectionType == .Yogasana {
                if self.arr_Yogasana.count != 0 {

                    //Check Random Data is Already There
                    if let dic = self.arr_Yogasana.randomElement() {
                        int_id = Int(dic.favorite_id ?? "") ?? 0
                        if let indxx = self.arr_Yogasana.firstIndex(where: { dic in
                            return Int(dic.favorite_id ?? "") == int_id
                        }) {
                            self.arr_Yogasana.remove(at: indxx)
                        }
                        arr_RandomData.append(dic)
                    }
                    //*************************************************//
                }
            }
            else if get_sectionType == .Meditation {
                if self.arr_Meditation.count != 0 {

                    //Check Random Data is Already There
                    if let dic = self.arr_Meditation.randomElement() {
                        int_id = Int(dic.favorite_id ?? "") ?? 0
                        if let indxx = self.arr_Meditation.firstIndex(where: { dic in
                            return Int(dic.favorite_id ?? "") == int_id
                        }) {
                            self.arr_Meditation.remove(at: indxx)
                        }
                        arr_RandomData.append(dic)
                    }
                    //*************************************************//
                }
            }
            else if get_sectionType == .Pranayama {
                if self.arr_Pranayam.count != 0 {

                    //Check Random Data is Already There
                    if let dic = self.arr_Pranayam.randomElement() {
                        int_id = Int(dic.favorite_id ?? "") ?? 0
                        if let indxx = self.arr_Pranayam.firstIndex(where: { dic in
                            return Int(dic.favorite_id ?? "") == int_id
                        }) {
                            self.arr_Pranayam.remove(at: indxx)
                        }
                        arr_RandomData.append(dic)
                    }
                    //*************************************************//
                }
            }
            else if get_sectionType == .Food {
                if self.arr_Food.count != 0 {
                    
                    for i in 0...2 {
                        //Check Random Data is Already There
                        if let dic = self.arr_Food.randomElement() {
                            int_id = Int(dic.food_type_id ?? "") ?? 0
                            if let indxx = self.arr_Food.firstIndex(where: { dic in
                                return Int(dic.food_type_id ?? "") == int_id
                            }) {
                                self.arr_Food.remove(at: indxx)
                            }
                            arr_RandomData.append(dic)
                        }
                        //*************************************************//
                    }
                    
                }
            }
            
            if arr_RandomData.count != 0 {
                self.arr_section.append(["id": int_id, "identifier": "result_data", "title": "Detailed result", "section_type": get_sectionType, "value": dic_result, "suggestion": arr_RandomData])
            }

        }
        
        self.arr_section.append(["identifier": "disclimer", "title": ""])
        self.arr_section.append(["identifier": "view_all", "title": "View all".localized()])
        self.arr_section.append(["identifier": "home", "title": "Back to home"])
        
        
        
        //let strText1 = String(format: "Personalized home remedies for %@".localized(), getDisplayMessage().2.localized())
        //self.arr_section.append(["identifier": "home_remedies", "title": strText1, "data": self.arr_Remedies])
#endif
        
        self.tbl_View.reloadData()
    }
    
    func getSection_Type(_ dic_result: SparshnaResultParamModel) -> TodayGoal_Type {
        var sectionType : TodayGoal_Type = .knone
        let paramValue = Int(dic_result.paramStringValue) ?? 0
        if dic_result.paramType == .bpm {
            if (paramValue < 70) {
                sectionType = .Yogasana
            } else if (paramValue >= 70 && paramValue <= 80) {
                sectionType = .Meditation
            } else {
                sectionType = .Pranayama
            }
        }
        else if dic_result.paramType == .dp {
            if (paramValue < 60) {
                sectionType = .Food
            } else if (paramValue >= 60 && paramValue <= 80) {
                sectionType = .Meditation
            } else {
                sectionType = .Pranayama
            }
        }
        else if dic_result.paramType == .bala {
            if (paramValue < 30) {
                sectionType = .Yogasana
            } else if (paramValue >= 30 && paramValue <= 40) {
                sectionType = .Yogasana
            } else {
                sectionType = .Meditation
            }
        }
        else if dic_result.paramType == .kath {
            if (paramValue < 210) {
                sectionType = .Yogasana
            } else if (paramValue >= 210 && paramValue <= 310) {
                sectionType = .Meditation
            } else {
                sectionType = .Pranayama
            }
        }
        else if dic_result.paramType == .gati {
            if dic_result.paramStringValue == "Kapha" {
                sectionType = .Yogasana
            } else if dic_result.paramStringValue == "Pitta" {
                sectionType = .Meditation
            } else {
                sectionType = .Pranayama
            }
        }
        else if dic_result.paramType == .rythm {
            if paramValue == 0 {
                sectionType = .Pranayama
            } else {
                sectionType = .Yogasana
            }
        }
        return sectionType
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_section.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let identifier = self.arr_section[indexPath.row]["identifier"] as? String ?? ""
        if identifier == "wellness_index" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SparshnaWellnessTableCell") as? SparshnaWellnessTableCell else {
                    return UITableViewCell()
                }
            cell.selectionStyle = .none
            
#if !APPCLIP
            let strTextMsg = getDisplayMessage().0.localized()
            var strKPVPrensentage = getDisplayMessage().1.localized()
            var strKPV = getDisplayMessage().2.localized()
            
            var fullText = String(format: strTextMsg.localized(), strKPV, strKPVPrensentage)
            
            if appDelegate.cloud_vikriti_status != "" {
                strKPVPrensentage = ""
                strKPV = appDelegate.cloud_vikriti_status
                fullText = String(format: "Your %@ is aggravated".localized(), strKPV.capitalized)
            }
            else {
                if let dic_userInfo = UserDefaults.user.get_user_info_result_data["Userinfo"] as? [String: Any] {
                    strKPVPrensentage = ""
                    strKPV = dic_userInfo["aggravation"] as? String ?? ""
                    fullText = String(format: "Your %@ is aggravated".localized(), strKPV.capitalized)
                }
            }
            
            
            
            setupAttributedText(str_FullText: fullText,
                                fullTextFont: UIFont.AppFontSemiBold(16),
                                fullTextColor: UIColor.fromHex(hexString: "#777777"),
                                highlightText1: strKPV,
                                highlightText1Font: UIFont.AppFontSemiBold(16),
                                highlightText1Color: UIColor.fromHex(hexString: "#2F2E2E"),
                                highlightText2: strKPVPrensentage,
                                highlightText2Font: UIFont.AppFontSemiBold(16),
                                highlightText2Color: UIColor.fromHex(hexString: "#2F2E2E"),
                                lbl_attribute: cell.lbl_bodyConstitution)
            
            self.setup_KPV_colors(img_aggrivation: cell.img_aggrivation, imgKPV: cell.img_KPV_full, view_aggrivation: cell.view_aggrivation, lbl_Text: cell.lbl_bodyConstitution, img_arrow: cell.img_KPV_arrow)
#endif
            
            cell.didTappedonDetailResult = {(sender) in
                let vc = SparshnaDetailResultVC.instantiate(fromAppStoryboard: .Questionnaire)
                vc.resultDic = self.resultDic
                vc.resultParams = self.resultParams
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            return cell
        }
        else if identifier == "aggrivated_may_lead" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Aggrivation_MeansTableCell") as? Aggrivation_MeansTableCell else {
                    return UITableViewCell()
                }
            cell.selectionStyle = .none
            cell.lbl_title.text = self.arr_section[indexPath.row]["title"] as? String ?? ""
            cell.lbl_desc.setBulletListedAttributedText(stringList: self.arr_desc, paragraphSpacing: 8)
            
            return cell
        }
        else if identifier == "wellness_journey" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EnhanceWellnessJourneyTableCell") as? EnhanceWellnessJourneyTableCell else {
                    return UITableViewCell()
                }
            cell.selectionStyle = .none
            cell.lbl_Title.text = self.arr_section[indexPath.row]["title"] as? String ?? ""
            cell.collection_view.reloadData()
            
            cell.didTappedonCellIndex = { (sender) in
#if !APPCLIP
                if sender == 111 {
                    //Diet Plan
                    self.gotoDietPlanFlow()
                }
                else if sender == 112 {
                    guard let vc = Story_ForYou.instantiateViewController(withIdentifier: "TrainersListViewController") as? TrainersListViewController else {
                        return
                    }
                    vc.isRequiredLoadingDataFromServer = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if sender == 113 {
                    let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.isNavigationBarHidden = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                        UIApplication.topViewController?.tabBarController?.selectedIndex = 2
                    }
                }
#endif
            }
            
            return cell
        }
        else if identifier == "view_all" || identifier == "home" {
            
#if !APPCLIP
            let cell = tableView.dequeueReusableCell(withClass: SideMenuButtonTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_logout.textColor = AppColor.app_DarkGreenColor
            cell.lbl_logout.text = self.arr_section[indexPath.row]["title"] as? String ?? ""
            cell.btn_logout.layer.borderWidth = identifier == "view_all" ? 1 : 0
            cell.btn_logout.layer.borderColor = identifier == "view_all" ? AppColor.app_DarkGreenColor.cgColor : UIColor.clear.cgColor
            cell.constraint_btn_logout_top.constant = identifier == "view_all" ? 5 : -8
            
            cell.didTappedonLogout = { (sender) in
                if identifier == "view_all" {
                    let vc = SparshnaDetailResultVC.instantiate(fromAppStoryboard: .Questionnaire)
                    vc.resultDic = self.resultDic
                    vc.resultParams = self.resultParams
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    self.backAction()
                }
            }
            
            return cell
#else
#endif
            
        }
        else if identifier == "disclimer" {
            let cell = tableView.dequeueReusableCell(withClass: SparshnaResultDisclaimerTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            return cell
        }
        
        else if identifier == "header" {
            let cell = tableView.dequeueReusableCell(withClass: TitleHeaderTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.lbl_Title.textColor = .black
            cell.constraint_lbl_Title_top.constant = 0
            cell.lbl_Title.font = UIFont.init(name: "Inter-Medium", size: 18)
            cell.lbl_Title.text = self.arr_section[indexPath.row]["title"] as? String ?? ""
            
            return cell
        }
        else if identifier == "result_data" {
            let cell = tableView.dequeueReusableCell(withClass: YogaSuggestionAssessmentTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.superVC = self
            cell.constraint_img_range_Height.constant = 22
            cell.constraint_img_range_Leading.constant = 8
            cell.view_Main.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
            
            if let dic_value = self.arr_section[indexPath.row]["value"] as? SparshnaResultParamModel {
                let unqID = self.arr_section[indexPath.row]["id"] as? Int ?? 0
                if let arr_data = self.arr_section[indexPath.row]["suggestion"] as? [NSManagedObject] {
                    let sec_type = self.arr_section[indexPath.row]["section_type"] as? TodayGoal_Type ?? .knone
                    cell.sectionType = sec_type
                    if sec_type == .Food {
                        cell.constraint_collect_view_Height.constant = 110
                    }
                    else {
                        cell.constraint_collect_view_Height.constant = 78
                    }
                    cell.arr_Data = arr_data
                    cell.lbl_infoText.text = "Here's a quick \(sec_type.rawValue) exercise to bring back your \(dic_value.title) to ideal state"
                }
                
                cell.lbl_Title.text = dic_value.title
                cell.lbl_subTitle.text = dic_value.subtitle
                cell.lbl_range.text = dic_value.paramDisplayValue
                cell.img_type.image = dic_value.paramIcon
                
                cell.img_range.isHidden = false
                switch dic_value.paramKPVValue {
                case .Kapha:
                    cell.img_range.image = #imageLiteral(resourceName: "Kaphaa")
                case .Pitta:
                    cell.img_range.image = #imageLiteral(resourceName: "PittaN")
                case .Vata:
                    cell.img_range.image = #imageLiteral(resourceName: "VataN")
                default:
                    cell.img_range.isHidden = true
                    cell.constraint_img_range_Height.constant = 0
                    cell.constraint_img_range_Leading.constant = 0
                }
                cell.lbl_shortDescriptionL.text = dic_value.shortDescription
                cell.whatDoesThisMeanL.text = dic_value.whatDoesMeans
                
                if dic_value.whatDoesMeans.isEmpty {
                    cell.whatDoesThisMeanSV.isHidden = true
                }
                cell.updateValueRangesAndSelectedValue(dic_value)
                
                if let indx = self.arr_Ids.firstIndex(of: indexPath.row) {
                    cell.view_InnerSecond.isHidden = false
                    cell.view_InnerFirst.layer.borderWidth = 0
                    cell.view_Main.layer.borderWidth = 1
                    UIView.animate(withDuration: 0.3) {
                        cell.btn_arrow.transform = cell.btn_arrow.transform.rotated(by: CGFloat(M_PI_2)*2)
                    }
                }
                else {
                    cell.view_InnerFirst.layer.borderWidth = 0
                    cell.view_Main.layer.borderWidth = 1
                    cell.view_InnerSecond.isHidden = true
                    UIView.animate(withDuration: 0.3) {
                        cell.btn_arrow.transform = .identity
                    }
                }
                
                cell.didTappedonArrow = {(sender) in
                    if let indx = self.arr_Ids.firstIndex(of: indexPath.row) {
                        self.arr_Ids.remove(at: indx)
                    }
                    else {
                        self.arr_Ids.removeAll()
                        self.arr_Ids.append(indexPath.row)
                    }
                    self.tbl_View.reloadData()
                }
                
                cell.didSuccessAfterUnlock = { (yoga_id, sec_type) in
                    if unqID == yoga_id {
                        if sec_type == .Yogasana {
                            if let indexSection = self.arr_section.firstIndex(where: { dic in
                                return (dic["id"] as? Int ?? 0) == yoga_id
                            }) {
                                if let arr_data = self.arr_section[indexPath.row]["suggestion"] as? [NSManagedObject] {
                                    var arr_Temp = arr_data
                                    if let indxxx = arr_data.firstIndex(where: { dic_yoga in
                                        return Int((dic_yoga as? Yoga)?.favorite_id ?? "") == yoga_id
                                    }) {
                                        let dicNew = arr_data[indxxx] as? Yoga
                                        dicNew?.access_point = 0
                                        arr_Temp.remove(at: indxxx)
                                        arr_Temp.append(dicNew!)
                                        var dic_suggstion = self.arr_section[indexPath.row]
                                        dic_suggstion["suggestion"] = arr_Temp
                                        self.arr_section.remove(at: indexSection)
                                        self.arr_section.insert(dic_suggstion, at: indexSection)
                                    }
                                }
                            }
                        }
                        else if sec_type == .Meditation {
                            if let indexSection = self.arr_section.firstIndex(where: { dic in
                                return (dic["id"] as? Int ?? 0) == yoga_id
                            }) {
                                if let arr_data = self.arr_section[indexPath.row]["suggestion"] as? [NSManagedObject] {
                                    var arr_Temp = arr_data
                                    if let indxxx = arr_data.firstIndex(where: { dic_medi in
                                        return Int((dic_medi as? Meditation)?.favorite_id ?? "") == yoga_id
                                    }) {
                                        let dicNew = arr_data[indxxx] as? Meditation
                                        dicNew?.access_point = 0
                                        arr_Temp.remove(at: indxxx)
                                        arr_Temp.append(dicNew!)
                                        var dic_suggstion = self.arr_section[indexPath.row]
                                        dic_suggstion["suggestion"] = arr_Temp
                                        self.arr_section.remove(at: indexSection)
                                        self.arr_section.insert(dic_suggstion, at: indexSection)
                                    }
                                }
                            }
                        }
                        else if sec_type == .Pranayama {
                            if let indexSection = self.arr_section.firstIndex(where: { dic in
                                return (dic["id"] as? Int ?? 0) == yoga_id
                            }) {
                                if let arr_data = self.arr_section[indexPath.row]["suggestion"] as? [NSManagedObject] {
                                    var arr_Temp = arr_data
                                    if let indxxx = arr_data.firstIndex(where: { dic_prana in
                                        return Int((dic_prana as? Pranayama)?.favorite_id ?? "") == yoga_id
                                    }) {
                                        let dicNew = arr_data[indxxx] as? Pranayama
                                        dicNew?.access_point = 0
                                        arr_Temp.remove(at: indxxx)
                                        arr_Temp.append(dicNew!)
                                        var dic_suggstion = self.arr_section[indexPath.row]
                                        dic_suggstion["suggestion"] = arr_Temp
                                        self.arr_section.remove(at: indexSection)
                                        self.arr_section.insert(dic_suggstion, at: indexSection)
                                    }
                                }
                            }
                        }
                        
                        self.tbl_View.reloadData()
                    }
                }
                
                
                //Go To Detail Screen
                cell.didGoToDetail = { (sec_type, dic) in
                    self.goToDetailScreen_asperType(typeee: sec_type, data: dic)
                }
                //************************************************************************//
            }
            
            return cell
        }
        else if identifier == "aggrivation" || identifier == "home_remedies" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionForActivityTableCell") as? SuggestionForActivityTableCell else {
                    return UITableViewCell()
                }
            cell.selectionStyle = .none
            cell.lbl_Title.text = self.arr_section[indexPath.row]["title"] as? String ?? ""
            
            if identifier == "aggrivation" {
                cell.cellType = ""
                cell.constraint_btn_allActivity_Top.constant = -8
                cell.constraint_btn_allActivity_height.constant = 0
                cell.arr_suggestion = self.arr_section[indexPath.row]["data"] as? [[String: Any]] ?? [[:]]
            }
            else {
                cell.cellType = "remedies"
                cell.constraint_btn_allActivity_Top.constant = -6
                cell.constraint_btn_allActivity_height.constant = 50
                cell.arr_remedies = self.arr_Remedies
            }
            
            cell.didTappedonActivity = { (sender) in
                self.goToYogaPranayamVC(sender)
            }
            
            cell.didTappedonRemedies = { (remedies) in
                self.gotoHomeRemediesVC(dicRemedy: remedies)
            }
            
            cell.didTappedonAllActivity = { (sender) in
#if !APPCLIP
                let vc = HomeRemediesViewController.instantiate(fromAppStoryboard: .HomeRemedies)
                vc.isFromAyuverseContentLibrary = true
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
#endif
            }

            return cell
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 12 : 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450//indexPath.row == 1 ? getParamListCellHeight() : 450
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableView.automaticDimension
        return UITableView.automaticDimension// indexPath.row == 1 ? getParamListCellHeight() : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indx = self.arr_Ids.firstIndex(of: indexPath.row) {
            self.arr_Ids.remove(at: indx)
        }
        else {
            self.arr_Ids.append(indexPath.row)
        }
        self.tbl_View.reloadData()
    }
    
    func gotoDietPlanFlow() {
#if !APPCLIP
        if UserDefaults.user.is_main_subscription {
            ARWellnessPlanVC.showScreen(fromVC: self)
        }
        else {
            if UserDefaults.user.is_diet_plan_subscribed {
                ARWellnessPlanVC.showScreen(fromVC: self)
            }
            else {
                DietPlanLandingVC.showScreen(fromVC: self)
            }
        }
#endif
    }
    
    func goToYogaPranayamVC(_ sender: IsSectionType) {
#if !APPCLIP
        let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        let recommendationPrakriti = Utils.getPrakritiIncreaseValue()

        let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
        guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
            return
        }
        objPlayList.recommendationPrakriti = recommendationPrakriti
        objPlayList.recommendationVikriti = recommendationVikriti
        objPlayList.istype = sender
        objPlayList.isFromHomeScreen = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(objPlayList, animated: true)
#endif
    }
    
    func gotoHomeRemediesVC(dicRemedy: HomeRemedies) {
#if !APPCLIP
        let storyBoard = UIStoryboard(name: "HomeRemedies", bundle: nil)
        let objRemedyView:HomeRemediesSubListViewController = storyBoard.instantiateViewController(withIdentifier: "HomeRemediesSubListViewController") as! HomeRemediesSubListViewController
        objRemedyView.arrData = dicRemedy.subcategory?.allObjects as? [HomeRemediesDetail] ?? []
        objRemedyView.titleHeading = dicRemedy.item ?? ""
        objRemedyView.isFromAyuverseContentLibrary = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(objRemedyView, animated: true)
#endif
    }

}


// MARK: - Utilities Methods
extension LastAssessmentVC {
    func getLastAssessmentData()  -> [String: Any]  {
        guard let lastAssData = kUserDefaults.value(forKey: LAST_ASSESSMENT_DATA) as? String, !lastAssData.isEmpty else {
            return [:]
        }
        let resultString = lastAssData
        guard let dataStr = resultString.data(using: .utf8) else {
            return [:]
        }
        
        do {
            let jsonData = try JSONSerialization.jsonObject(with: dataStr, options: .allowFragments)
            let resultDic = jsonData as! [String: Any]
            print(resultDic)
            return resultDic
        } catch let error {
            print(error)
            return [:]
        }
    }
}

// MARK: - Result Sharing
extension LastAssessmentVC {
    func shareSparhnaResultButtonAction() {
        if let headerCell = tbl_View.cellForRow(at: IndexPath(row: 0, section: 0)) as? SparshnaWellnessTableCell {
            var details = "Your Current State".localized()
            details.append(":\n")
            details.append(headerCell.lbl_bodyConstitution.text ?? "")
            //details.append("\n\n" + "What does this mean?".localized())
            //details.append("\n" + (headerCell.lblDescription.text ?? ""))
            details.append("\n\n")
            details.append("Detailed results".localized())
            details.append(":\n" + getParamDetailSharingString(for: .bpm))
            details.append("\n" + getParamDetailSharingString(for: .o2r))
            
            //print("--->>> \(details)")
            
            var text = ""
            #if !APPCLIP
            // Code you don't want to use in your app clip.
            text = "\(details) \n\n" + "I just did Naadi Pariksha to assess my current wellness state and various health parameters using AyuRythm app, in 30 seconds.".localized() + Utils.shareDownloadString
            
            let shareAll = [ text ] as [Any]
            let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
            #else
            // Code your app clip may access.
            text = "\(details) \n\n" + String(format: "I just did Naadi Pariksha to assess my current wellness state and various health parameters using AyuRythm app, in 30 seconds.".localized())
            showAppClipsShareActivityViewController(text: text)
            #endif
        }
    }
    
    func getParamDetailSharingString(for type: SparshnaResultParamModel.ParamType) ->String {
        if type == .bpm, let paramDetail = resultParams.first(where: { $0.paramType == .bpm }) {
            return "Vega".localized() + " : " + paramDetail.paramDisplayValue
        } else if type == .o2r, let paramDetail = resultParams.first(where: { $0.paramType == .o2r }) {
            return "SpO2".localized() + " : \(paramDetail.paramStringValue) " + "(" + paramDetail.paramDisplayValue + ")"
        }
        return ""
    }
}

#if !APPCLIP
extension LastAssessmentVC {
    func showScratchCardRewardScreen() {
        DispatchQueue.delay(.seconds(1)) {
            if !Utils.isSparshnaDoneToday {
                StreakRewardVC.showScreen(cardType: "sparshna", fromVC: self)
            }
        }
    }
}
#endif

extension LastAssessmentVC {
    #if !APPCLIP
    func addEarnHistoryFromServer() {
        let params = ["activity_favorite_id": AyuSeedEarnActivity.sparshna.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
        ReferPopupViewController.addEarmHistoryFromServer(params: params) { [weak self] (isSuccess, title, message) in
            print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
            if isSuccess {
                self?.showAlert(title: title, message: message)
            }
        }
    }
    #endif
    
    func getSparshnaMasterResultFromServer() {
        showActivityIndicator()
        var params = ["aggravation_type" : currentKPVStatus.stringValue, "language_id" : Utils.getLanguageId()] as [String : Any]
        let urlString = kBaseNewURL + endPoint.get_sparshna_master_result.rawValue
        
#if !APPCLIP
        params["aggravation_type"] = appDelegate.cloud_vikriti_status
#endif
        
        AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
            switch response.result {
            case .success(let value):
                print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                guard let dicResponse = value as? [String: Any] else {
                    self.hideActivityIndicator(withMessage: Opps)
                    return
                }
                
                let isSuccess = dicResponse["status"] as? String == "success"
                let message = dicResponse["message"] as? String ?? Opps
                if isSuccess {
                    if let datas = dicResponse["data"] as? [[String: Any]], let data = datas.first {
                        var what_it_means  = data["what_it_means"] as? String ?? ""
                        what_it_means = what_it_means.replacingOccurrences(of: "-", with: "").trimed()
                        self.arr_desc = what_it_means.components(separatedBy: "\n")
//                        self.resultHeaderData.what_it_means = data["what_it_means"] as? String ?? ""
//                        self.resultHeaderData.what_to_do = data["what_to_do"] as? String ?? ""
                        
                        self.manageSection()
                    }
                    self.hideActivityIndicator()
                } else {
                    self.hideActivityIndicator(withMessage: message)
                }
            case .failure(let error):
                print(error)
                self.hideActivityIndicator(withError: error)
            }
        }
    }
    
    func getSparshnaParamDetailsFromServer() {
        showActivityIndicator()
        var params = ["aggravation_type" : currentKPVStatus.stringValue, "language_id" : Utils.getLanguageId()] as [String : Any]
        let urlString = kBaseNewURL + endPoint.get_sparshna_result.rawValue
        
#if !APPCLIP
        params["aggravation_type"] = appDelegate.cloud_vikriti_status
#endif
        
        AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
            switch response.result {
            case .success(let value):
                print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                guard let dicResponse = value as? [String: Any] else {
                    self.hideActivityIndicator(withMessage: Opps)
                    return
                }
                
                let isSuccess = dicResponse["status"] as? String == "success"
                let message = dicResponse["message"] as? String ?? Opps
                if isSuccess {
                    var resultParamArr = [SparshnaResultParamModel]()
                    if let dataArray = dicResponse["data"] as? [[String: Any]] {
                        dataArray.forEach { data in
                            let paramData = SparshnaResultParamModel(fromDictionary: data)
                            if paramData.paramType == .bmi {
                                let value = self.resultDic[paramData.paramType.rawValue] as? Double ?? 0
                                paramData.paramStringValue = String(value)
                            } else if paramData.paramType == .gati {
                                let value = self.resultDic[paramData.paramType.rawValue] as? String ?? ""
                                paramData.paramStringValue = value
                            } else if paramData.paramType == .rythm {
                                let value = self.resultDic["rythm"] as? Int ?? 0
                                paramData.paramStringValue = String(value)
                            } else {
                                let value = self.resultDic[paramData.paramType.rawValue] as? Int ?? 0
                                paramData.paramStringValue = String(value)
                            }
                            paramData.updateParamDetails()
                            if paramData.aggravationType != "" {
                                resultParamArr.append(paramData)
                            }
                        }
                        self.resultParams = resultParamArr
                        debugPrint("Result Params====\(resultParamArr)")
                        self.resultFilteredParams = resultParamArr.filter{ $0.paramKPVValue == self.currentKPVStatus}
                        
#if !APPCLIP

                        self.resultFilteredParams.removeAll()
                        
                        for dic_result_param in resultParamArr {

                            if dic_result_param.paramType == .rythm && dic_result_param.paramKPVValue == .Balanced {
                                if (appDelegate.cloud_vikriti_status.lowercased()).contains("kapha") {
                                    self.resultFilteredParams.append(dic_result_param)
                                }
                                else if (appDelegate.cloud_vikriti_status.lowercased()).contains("pitta") {
                                    self.resultFilteredParams.append(dic_result_param)
                                }
                            }
                            else {
                                if (appDelegate.cloud_vikriti_status.lowercased()).contains(dic_result_param.paramKPVValue.stringValue.lowercased()) {
                                    self.resultFilteredParams.append(dic_result_param)
                                }
                            }
                            
                        }
                        
                        
//                        self.resultFilteredParams = resultParamArr.filter {
//                            
//                            if $0.paramType == .rythm && $0.paramKPVValue == .Balanced {
//                                return true
//                            }
//                            else {
//                                (appDelegate.cloud_vikriti_status.lowercased()).contains($0.paramKPVValue.stringValue.lowercased())
//                            }
//                                    
//                        }
                         
#endif
                        
                        //self.resultParams = dataArray.map{ SparshnaResultParamModel(fromDictionary: $0) }
                    }
                    self.logicforAPICall()
                    self.manageSection()
                    self.hideActivityIndicator()
                } else {
                    self.hideActivityIndicator(withMessage: message)
                }
            case .failure(let error):
                print(error)
                self.hideActivityIndicator(withError: error)
            }
        }
    }
    
    func logicforAPICall() {
        var arr_ListType = [String]()
        if self.resultFilteredParams.count != 0 {
            for dic_resultData in self.resultFilteredParams {

                let paramValue = Int(dic_resultData.paramStringValue) ?? 0
                if dic_resultData.paramType == .bpm {
                    //Vega
                    if (paramValue < 70) {
                        arr_ListType.append("yogasana")
                    } else if (paramValue >= 70 && paramValue <= 80) {
                        arr_ListType.append("meditation")
                    } else {
                        arr_ListType.append("pranayam")
                    }
                }
                else if dic_resultData.paramType == .sp {
                    //Akruti Matra
                    if (paramValue < 90) {
                        arr_ListType.append("yogasana")
                    } else if (paramValue >= 90 && paramValue <= 120) {
                        arr_ListType.append("meditation")
                    } else {
                        arr_ListType.append("food")
                    }
                }
                else if dic_resultData.paramType == .dp {
                    //Akruti Tanaav
                    if (paramValue < 60) {
                        arr_ListType.append("food")
                    } else if (paramValue >= 60 && paramValue <= 80) {
                        arr_ListType.append("meditation")
                    } else {
                        arr_ListType.append("pranayam")
                    }
                }
                else if dic_resultData.paramType == .bala {
                    if (paramValue < 30) {
                        arr_ListType.append("yogasana")
                    } else if (paramValue >= 30 && paramValue <= 40) {
                        arr_ListType.append("yogasana")
                    } else {
                        arr_ListType.append("meditation")
                    }
                }
                else if dic_resultData.paramType == .kath {
                    if (paramValue < 210) {
                        arr_ListType.append("yogasana")
                    } else if (paramValue >= 210 && paramValue <= 310) {
                        arr_ListType.append("meditation")
                    } else {
                        arr_ListType.append("pranayam")
                    }
                }
                else if dic_resultData.paramType == .gati {
                    if dic_resultData.paramStringValue == "Kapha" {
                        arr_ListType.append("yogasana")
                    } else if dic_resultData.paramStringValue == "Pitta" {
                        arr_ListType.append("meditation")
                    } else {
                        arr_ListType.append("pranayam")
                    }
                }
                else if dic_resultData.paramType == .rythm {
                    if paramValue == 0 {
                        arr_ListType.append("pranayam")
                    } else {
                        arr_ListType.append("yogasana")
                    }
                }
            }
            if arr_ListType.count != 0 {
                self.removeSameValue(arr_ListType)
            }
        }
    }
    
    func removeSameValue(_ arr_ListType: [String]) {
        var arrValue = [String]()
        for list_type in arr_ListType {
            if let indx = arrValue.firstIndex(of: list_type) {
            }
            else {
                arrValue.append(list_type)
            }
        }
        let list_type = arrValue.joined(separator: ", ")
        self.callAPIforGetSuggestion(str_list_type: list_type)
    }
    
    func callAPIforGetSuggestion(str_list_type: String) {
        showActivityIndicator()
        let recommendationPrakriti = Utils.getYourCurrentPrakritiStatus()
        let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? RecommendationType.kapha
        
        var params = ["language_id" : Utils.getLanguageId(),
                      "type": recommendationVikriti.rawValue,
                      "typetwo": recommendationPrakriti.rawValue,
                      "list_type" : str_list_type] as [String : Any]
        
#if !APPCLIP
        params["type"] = appDelegate.cloud_vikriti_status
#endif
        
        let urlString = kBaseNewURL + endPoint.getAllTypeData.rawValue

        print("API URL: - \(urlString)\n\nParams: - \(params)\n\nHeader: - \(Utils.apiCallHeaders)")
        
        AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
            switch response.result {
            case .success(let value):
                print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
                guard let dicResponse = value as? [String: Any] else {
                    self.hideActivityIndicator(withMessage: Opps)
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.dic_suggestion_data = dicResponse
                    
                    if let arr_Data = self.dic_suggestion_data["yogasana"] as? [[String: Any]] {
                        self.arr_Yogasana = arr_Data.compactMap{ Yoga.createYogaData(dicYoga: $0, needToSave: false) }
                    }
                    if let arr_Data = self.dic_suggestion_data["pranayama"] as? [[String: Any]] {
                        self.arr_Pranayam = arr_Data.compactMap{ Pranayama.createPranayamaData(dicData: $0, needToSave: false) }
                    }
                    if let arr_Data = self.dic_suggestion_data["meditation"] as? [[String: Any]] {
                        self.arr_Meditation = arr_Data.compactMap{ Meditation.createMeditationData(dicData: $0, needToSave: false) }
                    }
                    if let arr_Data = self.dic_suggestion_data["food"] as? [[String: Any]] {
                        self.arr_Food = arr_Data.compactMap{ Food.createFoodData(dicData: $0, needToSave: false) }
                    }
                    self.manageSection()
                    self.hideActivityIndicator()
                }
                
            case .failure(let error):
                print(error)
                self.hideActivityIndicator(withError: error)
            }
        }
    }
}

extension LastAssessmentVC {
    static func showScreen(isFromOnBoarding: Bool = false, fromVC: UIViewController) {
        //New design
        let vc = LastAssessmentVC.instantiate(fromAppStoryboard: .Questionnaire)
        vc.hidesBottomBarWhenPushed = true
        if isFromOnBoarding {
            vc.screenFrom = ScreenType.today_screen
        }
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension LastAssessmentVC  {
    
    func getRemediesFromServer () {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.v2.homeRemediesCat.rawValue
            AF.request(urlString, method: .post, parameters: ["language_id" : Utils.getLanguageId()], encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {

                case .success(let value):
                    print(response)
                    guard let arrResponse = (value as? [[String: Any]]) else {
                        return
                    }
                    CoreDataHelper.sharedInstance.clearAllDataFrom(entityName: "HomeRemedies")
                    for dic in arrResponse {
                        HomeRemedies.createHomeRemediesData(dicData: dic)
                    }
                    self.getRemediesDataFromDB()
                case .failure(let error):
                    print(error)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        }else {
            getRemediesDataFromDB()
        }
    }
    
    func getRemediesDataFromDB() {
        guard let arrRemedies = CoreDataHelper.sharedInstance.getListOfEntityWithName("HomeRemedies", withPredicate: nil, sortKey: nil, isAscending: true) as? [HomeRemedies] else {
            return
        }
        if arrRemedies.count >= 3 {
            let data_id = [Int64]()
            self.checkData(data_id: data_id, arrRemedies: arrRemedies) { success in
                self.manageSection()
            }
        }
        else {
            self.arr_Remedies = arrRemedies
            self.manageSection()
        }
    }
    
    func checkData(data_id: [Int64], arrRemedies: [HomeRemedies], completion: @escaping (Bool)->Void) {
        var indx_id = data_id
        if let randonData1 = arrRemedies.randomElement() {
            if indx_id.contains(randonData1.id) {
                self.checkData(data_id: indx_id, arrRemedies: arrRemedies) { success in
                    if self.arr_Remedies.count >= 3 {
                        completion(true)
                    }
                }
            }
            else {
                indx_id.append(randonData1.id)
                self.arr_Remedies.append(randonData1)
            }
        }
        
        if self.arr_Remedies.count >= 3 {
            completion(true)
        }
        else {
            self.checkData(data_id: indx_id, arrRemedies: arrRemedies) { success in
                if self.arr_Remedies.count >= 3 {
                    completion(true)
                }
            }
        }
    }
}

//MARK: - Login for KPV (Increase Decrease)
extension LastAssessmentVC {
#if !APPCLIP
    func checkAggravatedValue() {
        
        func setStatus(prakriti: Double, vikriti: Double, kpvType: KPVType) {
            if abs(vikriti - prakriti) <= 5 {
                //if value is less than or equal to 5 then normal
                //Normal Aggravated
            } else if vikriti > prakriti {
                //If vikriti value is higher than prakriti= aggrevated
                //Increased Aggravated
                arrIncreaseValue.append(kpvType)
            } else {
                //imbalance
                //Decreased Aggravated
            }
        }
        
        var kaphaP = 0.0
        var pittaP = 0.0
        var vataP = 0.0
        
        if let strPrashna = kUserDefaults.value(forKey: RESULT_PRAKRITI) as? String {
            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaP = Double(arrPrashnaScore[0]) ?? 0
                pittaP = Double(arrPrashnaScore[1]) ?? 0
                vataP = Double(arrPrashnaScore[2]) ?? 0
            }
        } else {
            return
        }
        
        if let strPrashna = kUserDefaults.value(forKey: RESULT_VIKRITI) as? String {
            let arrPrashnaScore = strPrashna.components(separatedBy: ",")
            if arrPrashnaScore.count == 3 {
                let kapha = Double(arrPrashnaScore[0]) ?? 0
                let pitta = Double(arrPrashnaScore[1]) ?? 0
                let vata = Double(arrPrashnaScore[2]) ?? 0
                // new - original / original *100
                let percentIncreaseK = (kapha - kaphaP) //*100/kaphaP
                let percentIncreaseP = (pitta - pittaP) //*100/pittaP
                let percentIncreaseV = (vata - vataP) //*100/vataP
                
                self.KpvPer1 = "\(Int(abs(round(percentIncreaseK))))%"
                self.KpvPer2 = "\(Int(abs(round(percentIncreaseP))))%"
                self.KpvPer3 = "\(Int(abs(round(percentIncreaseV))))%"
                
                setStatus(prakriti: kaphaP, vikriti: kapha, kpvType: .KAPHA)
                setStatus(prakriti: pittaP, vikriti: pitta, kpvType: .PITTA)
                setStatus(prakriti: vataP, vikriti: vata, kpvType: .VATA)
            }
        }
    }
    
    func getDisplayMessage() -> (String, String, String) {
        if self.arrIncreaseValue.contains(.VATA) {
            return ("Your %@ is aggravated\nby %@".localized(), self.KpvPer3, "Vata".localized())
        } else if self.arrIncreaseValue.contains(.PITTA) {
            return ("Your %@ is aggravated\nby %@".localized(), self.KpvPer2, "Pitta".localized())
        } else if self.arrIncreaseValue.contains(.KAPHA) {
            return ("Your %@ is aggravated\nby %@".localized(), self.KpvPer1, "Kapha".localized())
        } else {
            return ("You have reached the balance".localized(), "", "")
        }
    }
    
    //MARK: - Setup Text
    func setup_KPV_colors(img_aggrivation: UIImageView, imgKPV: UIImageView, view_aggrivation: UIView, lbl_Text: UILabel, img_arrow: UIImageView) {
        
        imgKPV.isHidden = true
        img_arrow.isHidden = true
        
        let currentKPVStatus = appDelegate.cloud_vikriti_status// Utils.getYourCurrentKPVState(isHandleBalanced: false)
        
        if currentKPVStatus.lowercased() == CurrentKPVStatus.Kapha.stringValue.lowercased() {
            img_aggrivation.image = UIImage(named: "Kaphaa")
            
            if let kapha_gradientColor = CAGradientLayer.init(frame: view_aggrivation.frame, colors: kapha_colors, direction: GradientDirection.Top).creatGradientImage() {
                view_aggrivation.layer.borderColor = UIColor.init(patternImage: kapha_gradientColor).cgColor
            }
        }
        else if currentKPVStatus.lowercased() == CurrentKPVStatus.Pitta.stringValue.lowercased()  {
            img_aggrivation.image = UIImage(named: "PittaN")
            
            if let pitta_gradientColor = CAGradientLayer.init(frame: view_aggrivation.frame, colors: pitta_colors, direction: GradientDirection.Top).creatGradientImage() {
                view_aggrivation.layer.borderColor = UIColor.init(patternImage: pitta_gradientColor).cgColor
            }
        }
        else if currentKPVStatus.lowercased() == CurrentKPVStatus.Vata.stringValue.lowercased()  {
            img_aggrivation.image = UIImage(named: "VataN")
            
            if let vata_gradientColor = CAGradientLayer.init(frame: view_aggrivation.frame, colors: vata_colors, direction: GradientDirection.Right).creatGradientImage() {
                view_aggrivation.layer.borderColor = UIColor.init(patternImage: vata_gradientColor).cgColor
            }
        }
        else if currentKPVStatus.lowercased() == CurrentKPVStatus.Kapha_Pitta.stringValue.lowercased() {
            imgKPV.isHidden = false
            imgKPV.image = UIImage(named: "icon_kapha_pitta_kp")
            img_aggrivation.image = UIImage(named: "")
            view_aggrivation.layer.borderColor = UIColor.clear.cgColor
        }
        else if currentKPVStatus.lowercased() == CurrentKPVStatus.Pitta_Vata.stringValue.lowercased() {
            imgKPV.isHidden = false
            imgKPV.image = UIImage(named: "icon_pitta_vata_pv")
            img_aggrivation.image = UIImage(named: "")
            view_aggrivation.layer.borderColor = UIColor.clear.cgColor
        }
        else if currentKPVStatus.lowercased() == CurrentKPVStatus.Vata_Kapha.stringValue.lowercased() {
            imgKPV.isHidden = false
            imgKPV.image = UIImage(named: "icon_vata_kapha_vk")
            img_aggrivation.image = UIImage(named: "")
            view_aggrivation.layer.borderColor = UIColor.clear.cgColor
        }
        else if currentKPVStatus.lowercased() == CurrentKPVStatus.Kapha_Pitta_Vata.stringValue.lowercased() {
            imgKPV.isHidden = false
            imgKPV.image = UIImage(named: "icon_kapah_pitta_vata_kpv")
            img_aggrivation.image = UIImage(named: "")
            view_aggrivation.layer.borderColor = UIColor.clear.cgColor
        }
        else {
            imgKPV.isHidden = false
            img_arrow.isHidden = true
            img_aggrivation.image = UIImage(named: "")
            imgKPV.image = UIImage(named: "icon_balance")
            lbl_Text.text = "You have reached the balance".localized()
            view_aggrivation.layer.borderColor = UIColor.clear.cgColor
        }
    }
#endif
}


//Go To Detail Screen
extension LastAssessmentVC {
    func goToDetailScreen_asperType(typeee: TodayGoal_Type, data: NSManagedObject) {
#if !APPCLIP
        let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        
        if typeee == .Food {
            guard let dic_food = data as? Food else {
                return
            }

            guard let obj = Story_ForYou.instantiateViewController(withIdentifier: "FoodDetailViewController") as? FoodDetailViewController else {
                return
            }
            obj.modalPresentationStyle = .fullScreen
            obj.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
            obj.recommendationVikriti = recommendationVikriti
            obj.dataFood = dic_food
            self.present(obj, animated: true, completion: nil)
        }
        else {
            guard let objYoga = Story_ForYou.instantiateViewController(withIdentifier: "YogaDetailViewController") as? YogaDetailViewController else {
                return
            }
            objYoga.screenFrom = .from_herbListVC
            objYoga.modalPresentationStyle = .fullScreen
            
            if typeee == .Yogasana {
                guard let yoga = data as? Yoga else {
                    return
                }
                objYoga.yoga = yoga
                objYoga.istype = .yoga
            }
            else if typeee == .Meditation {
                guard let meditation = data as? Meditation else {
                    return
                }
                objYoga.meditation = meditation
                objYoga.istype = .meditation
            }
            else if typeee == .Pranayama {
                guard let pranayama = data as? Pranayama else {
                    return
                }
                objYoga.pranayama = pranayama
                objYoga.istype = .pranayama
            }
            self.present(objYoga, animated: true, completion: nil)
        }
#endif
    }
}
