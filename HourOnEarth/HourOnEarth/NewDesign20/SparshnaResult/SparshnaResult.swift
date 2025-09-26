//
//  HOESparshnaResult.swift
//  HourOnEarth
//
//  Created by Dhiren Bharadava on 22/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire


class SparshnaResultHeaderData {
    var currentKPVStatus: CurrentKPVStatus
    var what_it_means : String
    var what_to_do : String
    
    init(currentKPVStatus: CurrentKPVStatus, what_it_means: String, what_to_do: String) {
        self.currentKPVStatus = currentKPVStatus
        self.what_it_means = what_it_means
        self.what_to_do = what_to_do
    }
}

class SparshnaResult: UIViewController,UITableViewDelegate {
    
    @IBOutlet weak var tblSparshnaResult: UITableView!
    
    var selectedIndex : Int = 0
    var isRegisteredUser = true
    var isFromCameraView = false
    var resultDic: [String: Any] = [String: Any]()
    var resultHeaderData = SparshnaResultHeaderData(currentKPVStatus: .Balanced, what_it_means: "", what_to_do: "")
    var resultParams = [SparshnaResultParamModel]()
    var resultFilteredParams = [SparshnaResultParamModel]()
    var isDetailedResultVisible = false
    var currentKPVStatus = Utils.getYourCurrentKPVState()
    
    var pranayamCount = 0
    var meditationCount = 0
    var yogaCount = 0
    var foodCount = 0
    #if !APPCLIP
    var preferenceContentTypes: [TodayGoal_Type] = [.Yogasana, .Pranayama, .Meditation, .Mudras, .Kriyas]
    var finalViewSuggestion = TodayRecommendations.Types.food
    #endif
    
    var arrKeys: [String] = [String]()
    var detailDict:[String:String] = [String:String]()
    var arrcollapsa : [[String: Any]] = [[String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Your Current State".localized()
        
        // MARK :- set Done button and Color.
        #if !APPCLIP
        let rightButtonItemTitle = "Done".localized()
        //Add left share nav button
        let shareButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_Share.png"), style: .plain, target: self, action: #selector(shareSparhnaResultButtonAction(sender:)))
        self.navigationItem.leftBarButtonItem = shareButtonItem
        #else
        let rightButtonItemTitle = "Next"
        self.navigationItem.leftBarButtonItem = nil
        #endif
        
        let rightButtonItem = UIBarButtonItem(title: rightButtonItemTitle, style: .plain, target: self, action: #selector(rightButtonAction(sender:)))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        self.tblSparshnaResult.delegate = self
        self.tblSparshnaResult.dataSource = self
        
        resultHeaderData.currentKPVStatus = currentKPVStatus
        resultDic = getLastAssessmentData()
        getSparshnaMasterResultFromServer()
        getSparshnaParamDetailsFromServer()
        
        tblSparshnaResult.register(UINib(nibName: "SparshnaResultsCell", bundle: nil), forCellReuseIdentifier: "SparshnaResultsCell")
        tblSparshnaResult.register(UINib(nibName: "SparshnaResultParamListCell", bundle: nil), forCellReuseIdentifier: "SparshnaResultParamListCell")
        
        #if !APPCLIP
        // Code you don't want to use in your app clip.
        if isFromCameraView {
            //addEarnHistoryFromServer()
            Utils.completeDailyTask(favorite_id: "1", taskType: "sparshna")
            showScratchCardRewardScreen()
        }
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        #if !APPCLIP
        // Code you don't want to use in your app clip.
        #endif
    }
    
    //MARK: Actions
    @objc func rightButtonAction(sender: UIBarButtonItem) {
        #if !APPCLIP
        // Code you don't want to use in your app clip.
        if isRegisteredUser {
            if kSharedAppDelegate.isSocialRegisteredUser {
                kSharedAppDelegate.showHomeScreen()
                kSharedAppDelegate.isSocialRegisteredUser = false
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            kSharedAppDelegate.showHomeScreen()
        }
        #else
        // Code your app clip may access.
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let objDescription = storyBoard.instantiateViewController(withIdentifier: "RecommendationsVC") as! RecommendationsVC
        self.navigationController?.pushViewController(objDescription, animated: true)
        #endif
        
    }
    
    @objc func viewSuggestionsBtnClicked() {
        
        #if !APPCLIP
        // Code you don't want to use in your app clip.
        showProperViewSuggestionScreen()
        #else
        // Code your app clip may access.
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let objDescription = storyBoard.instantiateViewController(withIdentifier: "RecommendationsVC") as! RecommendationsVC
        self.navigationController?.pushViewController(objDescription, animated: true)
        #endif
      //  MoEngage.sharedInstance().trackEvent(event.view_suggestion.rawValue, with: nil)
        //MoEngageHelper.shared.trackEvent(name: event.view_suggestion.rawValue)
    }
    //MoEngageHelper.shared.trackEvent(name: event.view_suggestion.rawValue)
}

// MARK: - TableView DataSource
extension SparshnaResult: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SparshnaResultsCell") as? SparshnaResultsCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.configureUI(withData: resultHeaderData)
            cell.viewSuggestionsBtn.removeTarget(self, action: nil, for: .touchUpInside)
            cell.viewSuggestionsBtn.addTarget(self, action: #selector(viewSuggestionsBtnClicked), for: .touchUpInside)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SparshnaResultParamListCell") as? SparshnaResultParamListCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.configureUI(resultParams: resultParams, resultFilteredParams: resultFilteredParams, isDetailedResultVisible: isDetailedResultVisible)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 1 ? getParamListCellHeight() : 450
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableView.automaticDimension
        return indexPath.row == 1 ? getParamListCellHeight() : UITableView.automaticDimension
    }
    
    func getParamListCellHeight() -> CGFloat {
        let paramCount = isDetailedResultVisible ? resultParams.count : resultFilteredParams.count
        let cellCount = paramCount.isMultiple(of: 2) ? paramCount : paramCount + 1
        return ((SparshnaResultParamListCell.maxCellHeight * CGFloat(cellCount/2)) + 36)
    }
}

extension SparshnaResult: SparshnaResultParamListCellDelegate {
    func showInfoOfParam(at index: Int) {
        let resultParam = isDetailedResultVisible ? resultParams[index] : resultFilteredParams[index]
        let vc = SparshnaResultParamDetailVC.instantiateFromStoryboard("SparshnaResult")
        vc.resultParam = resultParam
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        if let tabVC = self.tabBarController {
            tabVC.present(vc, animated: true, completion: nil)
        } else {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func showHideDetailedResult(isShow: Bool) {
        self.isDetailedResultVisible = isShow
        self.tblSparshnaResult.reloadData()
        //self.tblSparshnaResult.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }
}

// MARK: - Utilities Methods
extension SparshnaResult {
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
extension SparshnaResult {
    @objc func shareSparhnaResultButtonAction(sender: UIBarButtonItem) {
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
extension SparshnaResult {
    func showScratchCardRewardScreen() {
        DispatchQueue.delay(.seconds(1)) {
            if !Utils.isSparshnaDoneToday {
                StreakRewardVC.showScreen(cardType: "sparshna", fromVC: self)
            }
        }
    }
    
    func showProperViewSuggestionScreen() {
        pranayamCount = resultFilteredParams.filter{ $0.paramType.viewSuggestionType == .pranayam }.count
        meditationCount = resultFilteredParams.filter{ $0.paramType.viewSuggestionType == .meditation }.count
        yogaCount = resultFilteredParams.filter{ $0.paramType.viewSuggestionType == .yoga }.count
        foodCount = resultFilteredParams.filter{ $0.paramType.viewSuggestionType == .food }.count
        
        //check this category selected in preferences or not
        if !SurveyData.shared.contentTypeIDs.isEmpty {
            preferenceContentTypes = [.Yogasana, .Pranayama, .Meditation, .Mudras, .Kriyas]// SurveyData.shared.contentTypeIDs.compactMap{ SurveyStep3ViewController.ContentType(rawValue: $0) }
        }
        
        getFinalViewSuggestionAndShowThem()
    }
    
    func getFinalViewSuggestionAndShowThem() {
        
//        print("pranayamCount : ", pranayamCount)
//        print("meditationCount : ", meditationCount)
//        print("yogaCount : ", yogaCount)
//        print("foodCount : ", foodCount)
        
        showActivityIndicator()
        if pranayamCount >= meditationCount, preferenceContentTypes.contains(.Pranayama) {
            if pranayamCount >= yogaCount {
                if pranayamCount >= foodCount {
                    finalViewSuggestion = .pranayam
                } else {
                    finalViewSuggestion = .food
                }
            } else if yogaCount >= foodCount, preferenceContentTypes.contains(.Yogasana) {
                finalViewSuggestion = .yoga
            } else {
                finalViewSuggestion = .food
            }
        } else if meditationCount >= yogaCount, preferenceContentTypes.contains(.Meditation) {
            if meditationCount >= foodCount {
                finalViewSuggestion = .meditation
            } else {
                finalViewSuggestion = .food
            }
        } else if yogaCount >= foodCount, preferenceContentTypes.contains(.Yogasana) {
            finalViewSuggestion = .yoga
        } else {
            finalViewSuggestion = .food
        }
        print("Final View Suggestion before data count : ", finalViewSuggestion)
        
        getViewSuggestionDataCountFromServer(viewSuggestionType: finalViewSuggestion) { (isSuccess, message, dataCount) in
            if isSuccess {
                if dataCount == 0 {
                    switch self.finalViewSuggestion {
                    case .pranayam:
                        self.pranayamCount = 0
                    case .meditation:
                        self.meditationCount = 0
                    case .yoga:
                        self.yogaCount = 0
                    case.food:
                        print("comment MoEngage")
                        //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.food_suggestion.rawValue)
                    default:
                        print("unhandled other case")
                    }
                    self.getFinalViewSuggestionAndShowThem()
                } else {
                    //show view suggestion screen
                    print("====>>>> Final View Suggestion : ", self.finalViewSuggestion)
                    self.hideActivityIndicator()
                     if let tabBarVC = kSharedAppDelegate.window?.rootViewController as? UITabBarController {
                        if let vcs = tabBarVC.viewControllers, vcs.count > 0, let forYouNVC = vcs[1] as? UINavigationController {
                            forYouNVC.popToRootViewController(animated: false)
                        }
                        kSharedAppDelegate.viewSuggestionScreenFromSparshnaResult = self.finalViewSuggestion
                        tabBarVC.selectedIndex = 1
                        //self.navigationController?.popViewController(animated: false)
                     }
                }
            } else {
                self.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    func getViewSuggestionDataCountFromServer(viewSuggestionType: TodayRecommendations.Types, completion: @escaping (Bool, String, Int)->Void) {
        if Utils.isConnectedToNetwork() {
            let recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
            let recommendationPrakriti = Utils.getYourCurrentPrakritiStatus()
            
            var urlEndPoint = endPoint.getForYouYoga.rawValue
            if viewSuggestionType == .pranayam {
                urlEndPoint = endPoint.getPranayamaios.rawValue
            } else if viewSuggestionType == .meditation {
                urlEndPoint = endPoint.getMeditationios.rawValue
            } else if viewSuggestionType == .food {
                //food data is always there so dont check for data count here
                return completion(true, "", 1)
            }
            let urlString = kBaseNewURL + urlEndPoint
            var params = ["type": recommendationVikriti.rawValue,"typetwo": recommendationPrakriti.rawValue, "language_id" : Utils.getLanguageId()] as [String : Any]

            params["type"] = appDelegate.cloud_vikriti_status


            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    //print(response)
                    guard let arrResponse = value as? [[String: Any]] else {
                        return completion(false, Opps, 0)
                    }
                    completion(true, "", arrResponse.count)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription,0)
                }
            }
        } else {
            completion(false, NO_NETWORK, 0)
        }
    }
}
#endif

extension SparshnaResult {
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
        let params = ["aggravation_type" : currentKPVStatus.stringValue, "language_id" : Utils.getLanguageId()] as [String : Any]
        let urlString = kBaseNewURL + endPoint.get_sparshna_master_result.rawValue
        
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
                        self.resultHeaderData.what_it_means = data["what_it_means"] as? String ?? ""
                        self.resultHeaderData.what_to_do = data["what_to_do"] as? String ?? ""
                        self.tblSparshnaResult.reloadData()
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
        let params = ["aggravation_type" : currentKPVStatus.stringValue, "language_id" : Utils.getLanguageId()] as [String : Any]
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
                        self.resultFilteredParams = resultParamArr.filter{ $0.paramKPVValue == self.currentKPVStatus}
                        //self.resultParams = dataArray.map{ SparshnaResultParamModel(fromDictionary: $0) }
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
