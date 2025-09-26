//
//  DailyPlannerVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 30/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class DailyPlannerVC: BaseViewController {
    
    var loadFirstTime = false
    var current_streak = 0
    var int_selectedIndx = 0
    var arr_responseData = [[String: Any]]()
    var arr_section = [[String: Any]]()
    @IBOutlet weak var tbl_View: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.loadFirstTime = true
        self.tbl_View.register(nibWithCellClass: DailyPlannerFirstTableCell.self)
        self.tbl_View.register(nibWithCellClass: DailyPlannerSecondTableCell.self)
        self.tbl_View.register(nibWithCellClass: DailyPlanner_HeaderTableCell.self)
        self.tbl_View.register(nibWithCellClass: DailyPlannerRoutineTableCell.self)
        
        self.manageSection()
        self.callAPIforDailtPlanner(true)
    }
    
    func callAPIforDailtPlanner(_ animate: Bool) {
        if animate {
            showActivityIndicator()
        }
        
        self.getDailyPlannerDataToServer { isSuccess, status, message, arr_data in
            self.hideActivityIndicator()
            if isSuccess {
                if let arrData = arr_data {
                    print("arr_data : ", arrData)
                    self.arr_responseData = arrData
                    
                    if self.loadFirstTime {
                        self.loadFirstTime = false
                        self.int_selectedIndx = arrData.firstIndex(where: { dic in
                            let str_Date = dic["date"] as? String ?? ""
                            if  str_Date.contains(" ") {
                                let arrData = str_Date.components(separatedBy: " ")
                                let strDate = arrData.last ?? ""
                                let strTodayDate = Date().dateString(format: App.dateFormat.onlyDate)
                                return strDate == strTodayDate
                            }
                            return false
                        }) ?? 0
                    }

                    self.manageSection(apiCall: true)
                }
            } else {
                self.hideActivityIndicator()
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    func callAPIforSave_DailyPlanner(plan_date: String, plan_id: String, is_check: String) {
        showActivityIndicator()
        self.save_DailyPlanner_DataToServer(plandate: plan_date, planid: plan_id, ischeck: is_check) { isSuccess, status, message in
            if isSuccess {
                self.callAPIforDailtPlanner(false)
            } else {
                self.hideActivityIndicator()
                self.showAlert(title: status, message: message)
            }
        }
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
    
}

extension DailyPlannerVC {
    
    func getDailyPlannerDataToServer(completion: @escaping (Bool, String, String, [[String: Any]]?)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.getDailyPlanner.rawValue
            
            let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print("API URL: - \(urlString)\n\nParams: - \n\nResponse: - \(response)")
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        completion(false, "", "", nil)
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? ""
                    self.current_streak = dicResponse["current_streak"] as? Int ?? 0
                    let arr_response = dicResponse["data"] as? [[String: Any]] ?? [[:]]
                    let isSuccess = (status.lowercased() == "success")
                    completion(isSuccess, status, message, arr_response)
                case .failure(let error):
                    print(error)
                    completion(false, "", error.localizedDescription, nil)
                }
            }
        } else {
            completion(false, "", NO_NETWORK, nil)
        }
    }
    
    func save_DailyPlanner_DataToServer(plandate: String, planid: String, ischeck: String,completion: @escaping (Bool, String, String)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.setUserDailyPlanner.rawValue
            let param = ["plan_date": plandate, "plan_id": planid, "is_checked": ischeck]

            AF.request(urlString, method: .post, parameters: param, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print("API URL: - \(urlString)\n\nParams: - \(param)\n\nResponse: - \(response)")
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        completion(false, "", "")
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? ""
                    let isSuccess = (status.lowercased() == "success")
                    completion(isSuccess, status, message)
                case .failure(let error):
                    print(error)
                    completion(false, "", error.localizedDescription)
                }
            }
        } else {
            completion(false, "", NO_NETWORK)
        }
    }
}


//MARK: - UITableView Delegate DataSource Method
extension DailyPlannerVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection(apiCall: Bool = false) {
        self.arr_section.removeAll()
        
        var str_Name = "Hello".localized()
        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
            str_Name = "Hello".localized() + " \(empData["name"] as? String ?? "") 👋"
        }
        self.arr_section.append(["identifier": "header_cell", "title": str_Name.capitalized, "subtitle": "Let's be healthy this week!".localized()])
        
        if apiCall {
            self.arr_section.append(["identifier": "day_date", "data": self.arr_responseData])
            
            var arr_MorningData = [[String: Any]]()
            var arr_AfternoonData = [[String: Any]]()
            var arr_EveningData = [[String: Any]]()
            var arr_NightData = [[String: Any]]()
            if let dic_PlanData = self.arr_responseData[self.int_selectedIndx]["plans_data"] as? [String: Any] {
                for plan_data in dic_PlanData {
                    if plan_data.key.lowercased() == "morning" {
                        arr_MorningData = plan_data.value as? [[String: Any]] ?? [[:]]
                    }
                    else if plan_data.key.lowercased() == "afternoon" {
                        arr_AfternoonData = plan_data.value as? [[String: Any]] ?? [[:]]
                    }
                    else if plan_data.key.lowercased() == "evening" {
                        arr_EveningData = plan_data.value as? [[String: Any]] ?? [[:]]
                    }
                    else {
                        arr_NightData = plan_data.value as? [[String: Any]] ?? [[:]]
                    }
                }
            }
            
            if arr_MorningData.count != 0 {
                self.arr_section.append(["identifier": "day_header", "title": "☀ Morning".localized()])
                for morning_data in arr_MorningData {
                    self.arr_section.append(["identifier": "daily_routine", "value": morning_data])
                }
            }
            
            if arr_AfternoonData.count != 0 {
                self.arr_section.append(["identifier": "day_header", "title": "🌞 Afternoon".localized()])
                for afternoon_data in arr_AfternoonData {
                    self.arr_section.append(["identifier": "daily_routine", "value": afternoon_data])
                }
            }
            
            if arr_EveningData.count != 0 {
                self.arr_section.append(["identifier": "day_header", "title": "🌕 Evening".localized()])
                for evening_data in arr_EveningData {
                    self.arr_section.append(["identifier": "daily_routine", "value": evening_data])
                }
            }
            
            if arr_NightData.count != 0 {
                self.arr_section.append(["identifier": "day_header", "title": "🌙 Night".localized()])
                for night_data in arr_NightData {
                    self.arr_section.append(["identifier": "daily_routine", "value": night_data])
                }
            }
            
            
        }
        
        self.tbl_View.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let idetifier = self.arr_section[indexPath.row]["identifier"] as? String ?? ""
        if idetifier == "header_cell" {
            
            let cell = tableView.dequeueReusableCell(withClass: DailyPlannerFirstTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_title.text = self.arr_section[indexPath.row]["title"] as? String ?? ""
            cell.lbl_subtitle.text = self.arr_section[indexPath.row]["subtitle"] as? String ?? ""
            cell.lbl_current_steak.text = "\(self.current_streak) days"
            if self.arr_responseData.count != 0 {
                cell.lbl_taskDone.text = self.arr_responseData[self.int_selectedIndx]["task_done"] as? String ?? ""
            }
            
            return cell
        }
        else if idetifier == "day_date" {
            
            let cell = tableView.dequeueReusableCell(withClass: DailyPlannerSecondTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.int_selectedIndex = self.int_selectedIndx
            cell.arr_DayDate = self.arr_responseData
            
            cell.didCompliatation = {(indxx) in
                self.int_selectedIndx = indxx
                self.manageSection(apiCall: true)
            }
            
            return cell
        }
        else if idetifier == "day_header" {
            
            let cell = tableView.dequeueReusableCell(withClass: DailyPlanner_HeaderTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_Title.text = self.arr_section[indexPath.row]["title"] as? String ?? ""

            return cell
        }
        else if idetifier == "daily_routine" {
            
            let cell = tableView.dequeueReusableCell(withClass: DailyPlannerRoutineTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            if let dic_value = self.arr_section[indexPath.row]["value"] as? [String: Any] {
                cell.lbl_title.text = dic_value["daily_plans_title"] as? String ?? ""
                cell.lbl_time.text = dic_value["time_slot"] as? String ?? ""
                
                let str_imgIcon = dic_value["image"] as? String ?? ""
                cell.img_icon.sd_setImage(with: URL(string: str_imgIcon), placeholderImage: nil)
                
                let planChecked = dic_value["plan_checked"] as? String ?? ""
                if planChecked.lowercased() == "yes" {
                    cell.img_check.image = UIImage.init(named: "daily_routine_selection")
                }
                else {
                    cell.img_check.image = UIImage.init(named: "daily_routine_unselection")
                }
                
                let timeChecked = dic_value["time_checked"] as? String ?? ""
                if timeChecked == "false" {
                    cell.img_check.isHidden = true
                    cell.btn_check.isHidden = true
                }
                else {
                    cell.img_check.isHidden = false
                    cell.btn_check.isHidden = false
                }
                
                
                cell.didTappedonCheckMark = {(sender) in
                    let str_planID = dic_value["id"] as? String ?? ""
                    var str_planDate = dic_value["task_date"] as? String ?? ""
                    if planChecked.lowercased() == "no" {
                        self.callAPIforSave_DailyPlanner(plan_date: str_planDate, plan_id: str_planID, is_check: "1")
                    }
                }
            }
            
            return cell
        }
        
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idetifier = self.arr_section[indexPath.row]["identifier"] as? String ?? ""
        if idetifier == "daily_routine" {
            if let dic_value = self.arr_section[indexPath.row]["value"] as? [String: Any] {
                let objDialouge = DailyPlannerDialouge(nibName:"DailyPlannerDialouge", bundle:nil)
                objDialouge.dic_Value = dic_value
                self.addChild(objDialouge)
                objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
                self.view.addSubview((objDialouge.view)!)
                objDialouge.didMove(toParent: self)
            }
        }
    }
}


extension DailyPlannerVC {
    
    static func showScreen(fromVC: UIViewController) {
        let vc = DailyPlannerVC.instantiate(fromAppStoryboard: .DailyPlanner)
        vc.hidesBottomBarWhenPushed = true
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}
