//
//  SparshnaDetailResultVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 22/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class SparshnaDetailResultVC: UIViewController {

    var arr_Ids = [Int]()
    var aggrivation_type = ""
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tblSparshnaResult: UITableView!
    
    var isFromCameraView = false
    var resultDic: [String: Any] = [String: Any]()
    var resultHeaderData = SparshnaResultHeaderData(currentKPVStatus: .Balanced, what_it_means: "", what_to_do: "")
    var resultParams = [SparshnaResultParamModel]()
    var currentKPVStatus = Utils.getYourCurrentKPVState()
    
    var pranayamCount = 0
    var meditationCount = 0
    var yogaCount = 0
    var foodCount = 0
    #if !APPCLIP
    //var preferenceContentTypes: [TodayGoal_Type] = [.Yogasana, .Pranayama, .Meditation, .Mudras, .Kriya]
    //var finalViewSuggestion = TodayRecommendations.Types.food
    #endif
    
    var arrKeys: [String] = [String]()
    var detailDict:[String:String] = [String:String]()
    var arrcollapsa : [[String: Any]] = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.lbl_Title.text = "Detailed Result".localized()
        
        
        //***************************************************************************//
        //Register Table Cell========================================================//
        self.tblSparshnaResult.register(nibWithCellClass: CurrentBalDetailTypeTableCell.self)
        self.tblSparshnaResult.register(nibWithCellClass: SparshnaResultDisclaimerTableCell.self)
#if !APPCLIP
        self.tblSparshnaResult.register(nibWithCellClass: SideMenuButtonTableCell.self)
        self.tblSparshnaResult.register(nibWithCellClass: HomeScreenNoSparshnaTableCell.self)
#else
#endif
        //***************************************************************************//
        //***************************************************************************//
        
        
        resultHeaderData.currentKPVStatus = currentKPVStatus
        
        if (kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil) {
            resultDic = getLastAssessmentData()
            getSparshnaParamDetailsFromServer()
        }
        else {
            let dic_disclimer = ["aggravation_type": "disclimer", "favorite_id": "", "parameter": "", "short_description": "", "title": "", "what_does_means": ""]
            self.resultParams.append(SparshnaResultParamModel.init(fromDictionary: dic_disclimer))
            self.tblSparshnaResult.reloadData()
        }
        
//
//        getSparshnaMasterResultFromServer()
//        getSparshnaParamDetailsFromServer()
        
//        #if !APPCLIP
//        // Code you don't want to use in your app clip.
//        if isFromCameraView {
//            //addEarnHistoryFromServer()
//            Utils.completeDailyTask(favorite_id: "1", taskType: "sparshna")
//            showScratchCardRewardScreen()
//        }
//        #endif
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
        var is_find = false
        if let stackVCs = self.navigationController?.viewControllers {
            if let activeSubVC = stackVCs.first(where: { type(of: $0) == MyHomeViewController.self }) {
                is_find = true
                self.navigationController?.popToViewController(activeSubVC, animated: false)
            }
        }
        
        if is_find == false {
            kSharedAppDelegate.showHomeScreen()
        }
#else
#endif
    }
    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
#if !APPCLIP
        // Code you don't want to use in your app clip.
        if kSharedAppDelegate.isSocialRegisteredUser {
            kSharedAppDelegate.showHomeScreen()
            kSharedAppDelegate.isSocialRegisteredUser = false
        } else {
            self.navigationController?.popViewController(animated: true)
        }
#else
        // Code your app clip may access.
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let objDescription = storyBoard.instantiateViewController(withIdentifier: "RecommendationsVC") as! RecommendationsVC
        self.navigationController?.pushViewController(objDescription, animated: true)
#endif
    }
    
    @IBAction func btn_Share_Action(_ sender: UIButton) {
        self.shareSparhnaResultButtonAction()
    }

}




//MARK: UITableView Delegates and Datasource Method

extension SparshnaDetailResultVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultParams.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let paramData = self.resultParams[indexPath.row]
        if paramData.aggravationType == "add_questionnaire" {
            
#if !APPCLIP
            let cell = tableView.dequeueReusableCell(withClass: HomeScreenNoSparshnaTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.setupForQuestionnaires(is_sparshna: true, is_parshna: false)
            
            cell.didTappedonTryNow = { (sender) in
                PrakritiQuestionIntroVC.showScreen(isFromOnBoarding: true, fromVC: self)
            }
            
            return cell
#else
#endif
            
        }
        else if paramData.aggravationType == "skip_button" {
            
#if !APPCLIP
            let cell = tableView.dequeueReusableCell(withClass: SideMenuButtonTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_logout.textColor = AppColor.app_TextBlueColor
            cell.lbl_logout.text = "SKIP".localized().capitalized
            cell.btn_logout.layer.borderWidth = 0
            cell.constraint_btn_logout_top.constant = 0
            
            cell.didTappedonLogout = { (sender) in
                self.backAction()
            }
            
            return cell
#else
#endif
            
        }
        else if paramData.aggravationType == "disclimer" {
            let cell = tableView.dequeueReusableCell(withClass: SparshnaResultDisclaimerTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentBalDetailTypeTableCell") as? CurrentBalDetailTypeTableCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
        cell.constraint_img_range_Height.constant = 22
        cell.constraint_img_range_Leading.constant = 8

        cell.lbl_Title.text = paramData.title
        cell.lbl_subTitle.text = paramData.subtitle
        cell.lbl_range.text = paramData.paramDisplayValue
        cell.img_type.image = paramData.paramIcon

        cell.img_range.isHidden = false
        switch paramData.paramKPVValue {
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

        cell.lbl_shortDescriptionL.text = paramData.shortDescription
        cell.whatDoesThisMeanL.text = paramData.whatDoesMeans

        if paramData.whatDoesMeans.isEmpty {
            cell.whatDoesThisMeanSV.isHidden = true
        }
        cell.updateValueRangesAndSelectedValue(paramData)
        
        
        if let indx = self.arr_Ids.firstIndex(of: indexPath.row) {
            cell.view_InnerSecond.isHidden = false
            cell.view_InnerFirst.layer.borderWidth = 0
            cell.view_Main.layer.borderWidth = 1
            UIView.animate(withDuration: 0.3) {
                cell.btn_arrow.transform = cell.btn_arrow.transform.rotated(by: CGFloat(M_PI_2)*2)
            }
        }
        else {
            cell.view_InnerFirst.layer.borderWidth = 1
            cell.view_Main.layer.borderWidth = 0
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
            self.tblSparshnaResult.reloadData()//.reloadRows(at: [indexPath], with: .none)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 12 : 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450//indexPath.row == 1 ? getParamListCellHeight() : 450
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indx = self.arr_Ids.firstIndex(of: indexPath.row) {
            self.arr_Ids.remove(at: indx)
        }
        else {
            self.arr_Ids.append(indexPath.row)
        }
        self.tblSparshnaResult.reloadData()
    }

}

// MARK: - Utilities Methods
extension SparshnaDetailResultVC {
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
extension SparshnaDetailResultVC {
    @objc func shareSparhnaResultButtonAction() {
        if let headerCell = tblSparshnaResult.cellForRow(at: IndexPath(row: 0, section: 0)) as? SparshnaResultsCell {
            var details = "Your Current State".localized()
            details.append(":\n")
            details.append(headerCell.lblTitleImbalance.text ?? "")
            details.append("\n\n" + "What does this mean?".localized())
            details.append("\n" + (headerCell.lblDescription.text ?? ""))
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
extension SparshnaDetailResultVC {
//    func showScratchCardRewardScreen() {
//        DispatchQueue.delay(.seconds(1)) {
//            if !Utils.isSparshnaDoneToday {
//                StreakRewardVC.showScreen(cardType: "sparshna", fromVC: self)
//            }
//        }
//    }
    
//    func showProperViewSuggestionScreen() {
//        pranayamCount = resultFilteredParams.filter{ $0.paramType.viewSuggestionType == .pranayam }.count
//        meditationCount = resultFilteredParams.filter{ $0.paramType.viewSuggestionType == .meditation }.count
//        yogaCount = resultFilteredParams.filter{ $0.paramType.viewSuggestionType == .yoga }.count
//        foodCount = resultFilteredParams.filter{ $0.paramType.viewSuggestionType == .food }.count
//
//        //check this category selected in preferences or not
//        if !SurveyData.shared.contentTypeIDs.isEmpty {
//            preferenceContentTypes = SurveyData.shared.contentTypeIDs.compactMap{ SurveyStep3ViewController.ContentType(rawValue: $0) }
//        }
//
//        getFinalViewSuggestionAndShowThem()
//    }
    
//    func getFinalViewSuggestionAndShowThem() {
//
////        print("pranayamCount : ", pranayamCount)
////        print("meditationCount : ", meditationCount)
////        print("yogaCount : ", yogaCount)
////        print("foodCount : ", foodCount)
//
//        showActivityIndicator()
//        if pranayamCount >= meditationCount, preferenceContentTypes.contains(.Pranayama) {
//            if pranayamCount >= yogaCount {
//                if pranayamCount >= foodCount {
//                    finalViewSuggestion = .pranayam
//                } else {
//                    finalViewSuggestion = .food
//                }
//            } else if yogaCount >= foodCount, preferenceContentTypes.contains(.Yogasana) {
//                finalViewSuggestion = .yoga
//            } else {
//                finalViewSuggestion = .food
//            }
//        } else if meditationCount >= yogaCount, preferenceContentTypes.contains(.Meditation) {
//            if meditationCount >= foodCount {
//                finalViewSuggestion = .meditation
//            } else {
//                finalViewSuggestion = .food
//            }
//        } else if yogaCount >= foodCount, preferenceContentTypes.contains(.Yogasana) {
//            finalViewSuggestion = .yoga
//        } else {
//            finalViewSuggestion = .food
//        }
//        print("Final View Suggestion before data count : ", finalViewSuggestion)
//
//        getViewSuggestionDataCountFromServer(viewSuggestionType: finalViewSuggestion) { (isSuccess, message, dataCount) in
//            if isSuccess {
//                if dataCount == 0 {
//                    switch self.finalViewSuggestion {
//                    case .pranayam:
//                        self.pranayamCount = 0
//                    case .meditation:
//                        self.meditationCount = 0
//                    case .yoga:
//                        self.yogaCount = 0
//                    case.food:
//                        MoEngageHelper.shared.trackEvent(name: event.food_suggestion.rawValue)
//                    default:
//                        print("unhandled other case")
//                    }
//                    self.getFinalViewSuggestionAndShowThem()
//                } else {
//                    //show view suggestion screen
//                    print("====>>>> Final View Suggestion : ", self.finalViewSuggestion)
//                    self.hideActivityIndicator()
//                     if let tabBarVC = kSharedAppDelegate.window?.rootViewController as? UITabBarController {
//                        if let vcs = tabBarVC.viewControllers, vcs.count > 0, let forYouNVC = vcs[1] as? UINavigationController {
//                            forYouNVC.popToRootViewController(animated: false)
//                        }
//                        kSharedAppDelegate.viewSuggestionScreenFromSparshnaResult = self.finalViewSuggestion
//                        tabBarVC.selectedIndex = 1
//                        //self.navigationController?.popViewController(animated: false)
//                     }
//                }
//            } else {
//                self.hideActivityIndicator(withMessage: message)
//            }
//        }
//    }
    
//    func getViewSuggestionDataCountFromServer(viewSuggestionType: TodayRecommendations.Types, completion: @escaping (Bool, String, Int)->Void) {
//        if Utils.isConnectedToNetwork() {
//            let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
//            let recommendationPrakriti = Utils.getPrakritiIncreaseValue()
//
//            var urlEndPoint = endPoint.getForYouYoga.rawValue
//            if viewSuggestionType == .pranayam {
//                urlEndPoint = endPoint.getPranayamaios.rawValue
//            } else if viewSuggestionType == .meditation {
//                urlEndPoint = endPoint.getMeditationios.rawValue
//            } else if viewSuggestionType == .food {
//                //food data is always there so dont check for data count here
//                return completion(true, "", 1)
//            }
//            let urlString = kBaseNewURL + urlEndPoint
//            let params = ["type": recommendationVikriti.rawValue,"typetwo": recommendationPrakriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//                switch response.result {
//                case .success(let value):
//                    //print(response)
//                    guard let arrResponse = value as? [[String: Any]] else {
//                        return completion(false, Opps, 0)
//                    }
//                    completion(true, "", arrResponse.count)
//                case .failure(let error):
//                    print(error)
//                    completion(false, error.localizedDescription,0)
//                }
//            }
//        } else {
//            completion(false, NO_NETWORK, 0)
//        }
//    }
}
#endif

extension SparshnaDetailResultVC {
//    #if !APPCLIP
//    func addEarnHistoryFromServer() {
//        let params = ["activity_favorite_id": AyuSeedEarnActivity.sparshna.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]
//        ReferPopupViewController.addEarmHistoryFromServer(params: params) { [weak self] (isSuccess, title, message) in
//            print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
//            if isSuccess {
//                self?.showAlert(title: title, message: message)
//            }
//        }
//    }
//    #endif
    
//    func getSparshnaMasterResultFromServer() {
//        showActivityIndicator()
//        let params = ["aggravation_type" : currentKPVStatus.stringValue, "language_id" : Utils.getLanguageId()] as [String : Any]
//        let urlString = kBaseNewURL + endPoint.get_sparshna_master_result.rawValue
//
//        AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
//            switch response.result {
//            case .success(let value):
//                print("API URL: - \(urlString)\n\nParams: - \(params)\n\nResponse: - \(response)")
//                guard let dicResponse = value as? [String: Any] else {
//                    self.hideActivityIndicator(withMessage: Opps)
//                    return
//                }
//
//                let isSuccess = dicResponse["status"] as? String == "success"
//                let message = dicResponse["message"] as? String ?? Opps
//                if isSuccess {
//                    if let datas = dicResponse["data"] as? [[String: Any]], let data = datas.first {
//                        self.resultHeaderData.what_it_means = data["what_it_means"] as? String ?? ""
//                        self.resultHeaderData.what_to_do = data["what_to_do"] as? String ?? ""
//                        self.tblSparshnaResult.reloadData()
//                    }
//                    self.hideActivityIndicator()
//                } else {
//                    self.hideActivityIndicator(withMessage: message)
//                }
//            case .failure(let error):
//                print(error)
//                self.hideActivityIndicator(withError: error)
//            }
//        }
//    }
    
    func getSparshnaParamDetailsFromServer() {
        showActivityIndicator()
        let params = ["aggravation_type" : self.aggrivation_type, "language_id" : Utils.getLanguageId()] as [String : Any]
        let urlString = kBaseNewURL + endPoint.get_sparshna_result.rawValue

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
                        let dic_disclimer = ["aggravation_type": "disclimer", "favorite_id": "", "parameter": "", "short_description": "", "title": "", "what_does_means": ""]
                        self.resultParams.append(SparshnaResultParamModel.init(fromDictionary: dic_disclimer))
#if !APPCLIP
                        if (kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil) {
                            
                            var dic_extra = ["aggravation_type": "add_questionnaire",
                                             "favorite_id": "",
                                             "parameter": "",
                                             "short_description": "",
                                             "title": "",
                                             "what_does_means": ""]
                            self.resultParams.append(SparshnaResultParamModel.init(fromDictionary: dic_extra))
                            
                            dic_extra["aggravation_type"] = "skip_button"
                            dic_extra["title"] = "SKIP".localized().capitalized
                            self.resultParams.append(SparshnaResultParamModel.init(fromDictionary: dic_extra))
                        }
#else
#endif
                    }
                    self.tblSparshnaResult.reloadData()
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
}


extension SparshnaDetailResultVC {
    static func showScreen(isFromOnBoarding: Bool = false, fromVC: UIViewController) {
        //New design
        let vc = SparshnaDetailResultVC.instantiate(fromAppStoryboard: .Questionnaire)
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
    
}
