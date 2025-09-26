//
//  AyuMonkVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 31/10/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import IQKeyboardManagerSwift

class AyuMonkVC: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, delegate_click_event, delegateFaceNaadi {
    
    var strMessage = ""
    var is_restrict = false
    var chat_response_id = ""
    var is_AyuMonk_Subscribed = UserDefaults.user.is_ayumonk_subscribed
    var popupShwoing_singleTime = false
    var is_locationEnable = false
    let locationManager = CLLocationManager()
    
    var dic_Response = [String: Any]()
    var arr_msg = [[String: Any]]()
    var arr_chatHistory = [[String: Any]]()
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var btn_Back: UIButton!
    @IBOutlet weak var btn_Delete: UIButton!
    @IBOutlet weak var btn_Send: UIButton!
    @IBOutlet weak var txt_Msg: UITextView!
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var lblTxtMsgPlaceholder: UILabel!
    @IBOutlet weak var heightOfTextViewMessage: NSLayoutConstraint!
    @IBOutlet weak var BottomLayoutTxTMessage: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        self.navigationController?.isNavigationBarHidden = true
        
        //Register Table Cell
        self.tbl_View.register(nibWithCellClass: AyuMonkLoaderTableCell.self)
        self.tbl_View.register(nibWithCellClass: AyuMonkSenderTableCell.self)
        self.tbl_View.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
        
        self.initCurrentLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // MARK:- KEYBOARD METHODS
    @objc func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        let userinfo:NSDictionary = (notification.userInfo as NSDictionary?)!
        if let keybordsize = (userinfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let bottomSafeArea = appDelegate.window?.safeAreaInsets.bottom ?? 0
            self.BottomLayoutTxTMessage.constant = keybordsize.height - bottomSafeArea
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        print("keyboardWillHide")
        self.BottomLayoutTxTMessage.constant = 0
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.is_AyuMonk_Subscribed = UserDefaults.user.is_ayumonk_subscribed
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    func setupSubscriptionDialouge() {
        if self.is_AyuMonk_Subscribed == false {
            if UserDefaults.user.free_ayumonk_question == UserDefaults.user.ayumonk_trial {
                self.dialouge_trial_ended()
                return
            }
            
            if UserDefaults.user.free_ayumonk_question < UserDefaults.user.ayumonk_trial {
                self.dialouge_subscription()
            }
        }
    }
    
    func dialouge_trial_ended() {
        if self.popupShwoing_singleTime == false {
            self.popupShwoing_singleTime = true
            self.view.endEditing(true)
            if let parent = appDelegate.window?.rootViewController {
                let objDialouge = FreeTrialEndedDialouge(nibName:"FreeTrialEndedDialouge", bundle:nil)
                objDialouge.screen_from = .from_AyuMonk_Only
                objDialouge.delegate = self
                parent.addChild(objDialouge)
                objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
                parent.view.addSubview((objDialouge.view)!)
                objDialouge.didMove(toParent: parent)
            }
        }
        
    }
    
    //MARK: - DIALOUGE DELEGATE HANDLE
    func dialouge_subscription() {
        if let parent = appDelegate.window?.rootViewController {
            let objDialouge = AyuMonkDialouge(nibName:"AyuMonkDialouge", bundle:nil)
            objDialouge.delegate = self
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
            parent.view.addSubview((objDialouge.view)!)
            objDialouge.didMove(toParent: parent)
        }
    }
    
    func handle_dialouge_btn_click_event(_ success: Bool) {
        self.popupShwoing_singleTime = false
        if success {
            self.dialouge_subscription()
        }
    }
    
    func subscribe_tryNow_click(_ success: Bool, type: ScreenType) {
        if success {
            if type == ScreenType.from_AyuMonk_Only {
                let obj = FaceNaadiSubscriptionListVC.instantiate(fromAppStoryboard: .FaceNaadi)
                obj.str_screenFrom = type
                self.navigationController?.pushViewController(obj, animated: true)
            }
            else if type == ScreenType.from_PrimeMember {
                let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    //*******************************************************************//
    
    //MARK: - CHECK LOCATION PERMISSION
    func checkLocationPermissionEnableDisable() {
        //Here you can check whether you have allowed the permission or not.
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Authorize.")
                    self.is_locationEnable = true
                    self.callAPIforGetDetails()
                case .notDetermined:
                    print("Not determined.")
                case .restricted:
                    print("Restricted.")
                    self.is_locationEnable = false
                    self.callAPIforGetDetails()
                case .denied:
                    print("Denied.")
                    self.is_locationEnable = false
                    self.callAPIforGetDetails()
                @unknown default:
                    print("Error")
                }
            }else {
                print("Disable Loacation.")
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.checkLocationPermissionEnableDisable()
    }
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - TEXTVIEW DELEGATES
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if self.is_AyuMonk_Subscribed == false {
            if UserDefaults.user.free_ayumonk_question == UserDefaults.user.ayumonk_trial ||
                UserDefaults.user.free_ayumonk_question < UserDefaults.user.ayumonk_trial {
                self.dialouge_subscription()
                return false
            }
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == self.txt_Msg {
            //SET  HEIGHT OF MESSAGE TEXTVIEW ACCORDING CONTENT
            self.animatedHeightOfTextView(txtHeight: textView.contentSize.height)
            
            if textView.text == nil || textView.text == ""{
                self.lblTxtMsgPlaceholder.isHidden = false
            }else{
                self.lblTxtMsgPlaceholder.isHidden = true
            }
            
            if textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                self.btn_Send.isEnabled = false
            }else{
                self.btn_Send.isEnabled = true
            }
        }
    }
    
    func animatedHeightOfTextView(txtHeight:CGFloat) {
        self.heightOfTextViewMessage.constant = txtHeight < 30 ? 30 : (txtHeight < 110 ? txtHeight:110)
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 500    // 250 Limit Value
    }

    // MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Delete_Action(_ sender: UIButton) {
        let title = "Clear history".localized()
            let message = "Are you sure you want to clear your chat histoty?".localized()
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .default))
            alertController.addAction(UIAlertAction(title: "Yes".localized(), style: .destructive, handler: { (_) in
                self.arr_msg.removeAll()
                self.arr_chatHistory.removeAll()
                self.saveChatHistory()
                self.tbl_View.reloadData()
                self.callAPI_forDeleteChatLog()
            }))
            self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func btnSendMessage_Action(_ sender: UIButton) {
        if self.is_restrict {
            return
        }
        if let strSendMessage = self.txt_Msg.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if strSendMessage != "" {
                
                if self.is_AyuMonk_Subscribed == false {
                    if UserDefaults.user.free_ayumonk_question == UserDefaults.user.ayumonk_trial || UserDefaults.user.free_ayumonk_question < UserDefaults.user.ayumonk_trial {
                        self.dialouge_subscription()
                        return
                    }
                    
                }
                
                self.txt_Msg.text = ""
                self.strMessage = strSendMessage
                self.lblTxtMsgPlaceholder.isHidden = false
                self.animatedHeightOfTextView(txtHeight: 0)
                
                let author_user = self.dic_Response["author_user"] as? String ?? ""
                let dic_Initial = ["author": author_user, "content": strSendMessage, "date": getCurrentDate("hh:mm a")]
                self.arr_chatHistory.insert(dic_Initial, at: 0)
                self.arr_msg.append(["author": author_user, "content": strSendMessage])
                self.tbl_View.reloadData()
                self.manageSection()
                
                if self.is_AyuMonk_Subscribed == false {
                    //Send Message Count
                    let free_done_count = UserDefaults.user.ayumonk_trial + 1
                    UserDefaults.user.set_ayumonk_trialCount(data: free_done_count)
                    self.setupSubscriptionDialouge()
                }
            }
        }
    }
    
    func initCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.startUpdatingLocation()
        self.checkLocationPermissionEnableDisable()
    }
}

//MARK: - API Call
extension AyuMonkVC {
    
    func callAPIforGetDetails() {
        var params = [String: Any]()
        params["city"] = ""
        params["language"] = Utils.getLanguageId()
        self.showActivityIndicator()
        
        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
            let dob = empData["dob"] as! String

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let birthday = dateFormatter.date(from: dob)

            let ageComponents = Calendar.current.dateComponents([.year], from: birthday!, to: Date())
            params["age_year"] = "\(Double(ageComponents.year!))"

            if let measurement = empData["measurements"] as? String {
                let arrMeasurement = Utils.parseValidValue(string: measurement).components(separatedBy: ",")
                if arrMeasurement.count >= 2 {
                    let dHei = Double(arrMeasurement[0].replacingOccurrences(of: "\"", with: ""))!
                    let dWei = Double(arrMeasurement[1].replacingOccurrences(of: "\"", with: ""))!
                    
                    params["height_cm"] = "\(dHei)"
                    params["weight_kg"] = "\(dWei)"
                }
            }
            
            params["gender"] = empData["gender"] as? String ?? ""
            params["name"] = empData["name"] as? String ?? ""
            
            params["dosha_aggravation"] = empData["aggravation"] as? String ?? ""
            params["vikriti_dosha"] = empData["vikriti"] as? String ?? ""
            params["prakriti_dosha"] = empData["prakriti_dosha"] as? String ?? ""
            params["current_time"] = getCurrentDate("hh:mm a")
        }
        
        if self.is_locationEnable {
            if let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate {

                MPLocation.getCity_From_Lat_Long(pdblatitude: "\(locValue.latitude)", withLongitude: "\(locValue.longitude)") { (address) in
                    params["city"] = address
                }
            }
        }
        

        let urlString = kBaseNewURL + endPoint.get_ayumonk_config.rawValue

        AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
            self.hideActivityIndicator()
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
                    if let datas = dicResponse["data"] as? [String: Any] {
                        self.dic_Response = datas
                    }

                    self.get_saved_ChatHistory()
                    
                    self.callAPI_forGetChatLog()

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                        self.setupSubscriptionDialouge()
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
}

//MARK: - UITableViewDataSource Delegate Method
extension AyuMonkVC: UITableViewDelegate, UITableViewDataSource {
    
    func addLoader() {
        self.is_restrict = true
        var dic_res = [String: Any]()
        dic_res["author"] = "loader"
        dic_res["content"] = "loader"
        self.arr_chatHistory.insert(dic_res, at: 0)
        self.tbl_View.reloadData()
    }
    
    func removeLoader() {
        self.is_restrict = false
        if let indx = self.arr_chatHistory.firstIndex(where: { dic in
            return (dic["author"] as? String ?? "") == "loader"
        }) {
            self.arr_chatHistory.remove(at: indx)
        }
    }
    
    func manageSection() {
        self.addLoader()
        let strEndPoint = self.dic_Response["base_url"] as? String ?? ""
        let strProject_id = self.dic_Response["project_id"] as? String ?? ""
        let strModel_id = self.dic_Response["model_id"] as? String ?? ""
        let strToken = self.dic_Response["bearer_token"] as? String ?? ""
        
        let strURL = "\(strEndPoint)v1/projects/\(strProject_id)/locations/us-central1/publishers/google/models/\(strModel_id):predict"
        
        let candidateCount = self.dic_Response["candidateCount"] as? Int ?? 0
        let maxOutputTokens = self.dic_Response["maxOutputTokens"] as? Int ?? 0
        let temperature = self.dic_Response["temperature"] as? Double ?? 0.0
        let topP = self.dic_Response["topP"] as? Double ?? 0.0
        let topK = self.dic_Response["topK"] as? Int ?? 0
        let strContext = self.dic_Response["context"] as? String ?? ""
        let arr_Examples = self.dic_Response["examples"] as? [[String: Any]] ?? [[:]]
        let strDefault_message = self.dic_Response["default_message"] as? String ?? ""
        let author_user = self.dic_Response["author_user"] as? String ?? ""
        
        var params = [String: Any]()
        params["parameters"] = ["candidateCount": candidateCount,
                                "maxOutputTokens": maxOutputTokens,
                                "temperature": temperature,
                                "topP": topP,
                                "topK": topK] as [String : Any]
        
        var arr_instances = [[String: Any]]()
        if self.arr_msg.count == 0 {
            let dic_Initial = ["author": author_user, "content": strDefault_message]
            self.arr_msg.append(dic_Initial)
            self.saveChatHistory()
        }
        
        let dic_instances = ["context": strContext, "examples": arr_Examples, "messages": self.arr_msg] as [String : Any]
        
        arr_instances.append(dic_instances)
        params["instances"] = arr_instances
        
        let postData = params.jsonStringRepresentation?.data(using: .utf8)

        var request = URLRequest(url: URL.init(string: strURL)!,timeoutInterval: 60.0)
        request.addValue(strToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "content-type")

        request.httpMethod = "POST"
        request.httpBody = postData
        
        if Connectivity.isConnectedToInternet {

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    return
                }
                DispatchQueue.main.async {
                    self.removeLoader()
                    
                    print(String(data: data, encoding: .utf8)!)
                    if let dic_json = self.dataToJSON(data: data) as? [String: Any] {
                        if let arr_predictions = dic_json["predictions"] as? [[String: Any]], let arr_candidates = arr_predictions[0]["candidates"] as? [[String: Any]], let dic_last_candidates = arr_candidates.last {
                            
                            var dic_res = dic_last_candidates
                            let author_bot = self.dic_Response["author_bot"] as? String ?? ""
                            let str_content = dic_last_candidates["content"] as? String ?? ""
                            dic_res["author"] = author_bot
                            dic_res["date"] = getCurrentDate("hh:mm a")
                            self.arr_chatHistory.insert(dic_res, at: 0)
                            
                            //For Api
                            let dic_Initial = ["author": author_bot, "content": str_content]
                            self.arr_msg.append(dic_Initial)
                            self.saveChatHistory()
                            self.callAPI_forAddData(str_answer: str_content, chat_json: dic_json)
                        
                        }
                        self.tbl_View.reloadData()
                    }
                }
            }
            task.resume()
            
        }
        else {
            self.removeLoader()
            self.tbl_View.reloadData()
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
        
    }
    
    func dataToJSON(data: Data) -> Any? {
       do {
           return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
       } catch let myJSONError {
           print(myJSONError)
       }
       return nil
    }
    
    func saveChatHistory() {
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: self.arr_chatHistory)
        kUserDefaults.set(archieveData, forKey: kAyuMonkHistory)
        
        let archieveData_API = NSKeyedArchiver.archivedData(withRootObject: self.arr_msg)
        kUserDefaults.set(archieveData_API, forKey: kAyuMonkHistory_API)
    }
    
    func get_saved_ChatHistory() {
//        if kUserDefaults.object(forKey: kAyuMonkHistory) != nil {
//            if let data = kUserDefaults.object(forKey: kAyuMonkHistory) as? Data {
//                if let arr_history_Data = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[String: Any]] {
//                    self.arr_chatHistory = arr_history_Data
//                }
//            }
//        }
//        
        if kUserDefaults.object(forKey: kAyuMonkHistory_API) != nil {
            if let data = kUserDefaults.object(forKey: kAyuMonkHistory_API) as? Data {
                if let arr_msg_Data = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[String: Any]] {
                    self.arr_msg = arr_msg_Data
                }
            }
        }
//        
//        self.callAPI_forGetChatLog()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_chatHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let str_author = self.arr_chatHistory[indexPath.row]["author"] as? String ?? ""
        if str_author == "loader" {
            let cell = tableView.dequeueReusableCell(withClass: AyuMonkLoaderTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.transform = self.tbl_View.transform
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withClass: AyuMonkSenderTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.transform = self.tbl_View.transform

            let str_date = self.arr_chatHistory[indexPath.row]["date"] as? String ?? ""
            let str_author = self.arr_chatHistory[indexPath.row]["author"] as? String ?? ""
            let str_content = self.arr_chatHistory[indexPath.row]["content"] as? String ?? ""
            if str_author == (self.dic_Response["author_bot"] as? String ?? "") {
                //Bot
                cell.lbl_Sender_Msg.text = ""
                cell.lbl_Sender_MsgDate.text = ""
                cell.view_Sender_BG.isHidden = true
                cell.view_Receiver_BG.isHidden = false
                cell.lbl_Receiver_MsgDate.text = str_date
                cell.lbl_Receiver_Msg.text = str_content.trimed()
                cell.lbl_Receiver_Name.text = self.dic_Response["bot_name"] as? String ?? ""
            }
            else {
                //Sender
                cell.lbl_Receiver_Msg.text = ""
                cell.lbl_Receiver_Name.text = ""
                cell.lbl_Receiver_MsgDate.text = ""
                cell.view_Sender_BG.isHidden = false
                cell.view_Receiver_BG.isHidden = true
                cell.lbl_Sender_MsgDate.text = str_date
                cell.lbl_Sender_Msg.text = str_content.trimed()
            }

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let str_author = self.arr_chatHistory[indexPath.row]["author"] as? String ?? ""
        if str_author == "loader" {
            return 40
        }
        else {
            return UITableView.automaticDimension
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}


//MARK: - API CALL
extension AyuMonkVC {
    
    func callAPI_forAddData(str_answer: String, chat_json: [String: Any]) {
        
        var params = [String: Any]()
        
        params["question"] = self.strMessage
        
        if self.strMessage == "" {
            params["question"] = self.dic_Response["default_message"] as? String ?? ""
        }

        params["answer"] = str_answer
        params["chat_json_data"] = chat_json.jsonStringRepresentation
        
        let urlString = kBaseNewURL + endPoint.add_ayumonk_log.rawValue
        
        AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
            self.hideActivityIndicator()
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
                    self.chat_response_id = dicResponse["chat_history_id"] as? String ?? ""
                    self.hideActivityIndicator()
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
        
    func callAPI_forGetChatLog() {
        
        let urlString = kBaseNewURL + endPoint.get_ayumonk_log.rawValue
        
        AF.request(urlString, method: .post, parameters: nil, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
            self.hideActivityIndicator()
            switch response.result {
            case .success(let value):
                print("API URL: - \(urlString)\n\nResponse: - \(response)")
                guard let dicResponse = value as? [String: Any] else {
                    self.hideActivityIndicator(withMessage: Opps)
                    return
                }
                
                let isSuccess = dicResponse["status"] as? String == "success"
                let message = dicResponse["message"] as? String ?? Opps
                if isSuccess {
                    self.hideActivityIndicator()
                    if let dic_response_data = dicResponse["data"] as? [String: Any] {
                        debugPrint(dic_response_data)
                        
                        if let dic_chat_response = dic_response_data["chat_response"] as? [String: Any] {
                            self.chat_response_id = dic_chat_response["id"] as? String ?? ""
                            debugPrint(self.chat_response_id)
                        }
                        
                        if let arr_chat_msg = dic_response_data["question_answer_details"] as? [[String: Any]], arr_chat_msg.count != 0 {
                            
                            self.arr_chatHistory.removeAll()
                                                    
                            for dic_msg in arr_chat_msg {
                                let str_q = dic_msg["question"] as? String ?? ""
                                let str_a = dic_msg["answer"] as? String ?? ""
                                var str_date = dic_msg["created_at"] as? String ?? ""
                                
                                let dateformat = DateFormatter()
                                dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                if let datee = dateformat.date(from: str_date) {
                                    dateformat.dateFormat = "hh:mm a"
                                    str_date = dateformat.string(from: datee)
                                }
                                
                                var is_add = true
                                if str_q.trimed().lowercased() == (self.dic_Response["default_message"] as? String ?? "").trimed().lowercased() {
                                    is_add = false
                                }
                                
                                let author = self.dic_Response["author_bot"] as? String ?? ""
                                let dic_Initial = ["author": author, "content": str_a, "date": str_date]
                                self.arr_chatHistory.append(dic_Initial)
                                
                                
                                if is_add {
                                    let author = self.dic_Response["author_user"] as? String ?? ""
                                    let dic_Initial = ["author": author, "content": str_q, "date": str_date]
                                    self.arr_chatHistory.append(dic_Initial)
                                }

                            }
                            
                            self.tbl_View.reloadData()
                            
                        }
                        else {
                            self.manageSection()
                        }

                    }
                }
                else {
                    self.manageSection()
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func callAPI_forDeleteChatLog() {
        
        let urlString = kBaseNewURL + endPoint.delete_ayumonk_log.rawValue
        
        let param = ["chat_history_id": self.chat_response_id]
        
        AF.request(urlString, method: .post, parameters: param, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
            self.hideActivityIndicator()
            switch response.result {
            case .success(let value):
                print("API URL: - \(urlString)\n\nResponse: - \(response)")
                guard let dicResponse = value as? [String: Any] else {
                    self.hideActivityIndicator(withMessage: Opps)
                    return
                }
                
                let isSuccess = dicResponse["status"] as? String == "success"
                let message = dicResponse["message"] as? String ?? Opps
                if isSuccess {
                    self.hideActivityIndicator()
                    
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
