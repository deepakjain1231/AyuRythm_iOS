//
//  Vikrati30QuestionnaireVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 31/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class Vikrati30QuestionnaireVC: BaseViewController {
    
    @IBOutlet weak var view_InitialBase: UIView!
    @IBOutlet weak var view_Initial: UIView!
    @IBOutlet weak var view_Q10: UIView!
    @IBOutlet weak var view_InitialStack: UIStackView!
    
    @IBOutlet weak var view_MiddleBase: UIView!
    @IBOutlet weak var view_Middle: UIView!
    @IBOutlet weak var view_Q20: UIView!
    @IBOutlet weak var view_MiddleStack: UIStackView!
    
    @IBOutlet weak var view_LastBase: UIView!
    @IBOutlet weak var view_Last: UIView!
    @IBOutlet weak var view_Q30: UIView!
    @IBOutlet weak var view_LastStack: UIStackView!
    
    @IBOutlet weak var tbl_view: UITableView!
    @IBOutlet weak var lbl_UserName: UILabel!
    
    @IBOutlet weak var lbl_Title: UILabel!
    
    @IBOutlet weak var lbl_hello_subTitle: UILabel!
    
    var arr_Chat = [[String: Any]]()
    var arrAllQuestions:[[String: Any]] = [[String: Any]]()
    //var arrQuestions:[[String: Any]] = [[String: Any]]()
    var dicAnswers:[Int: String] = [Int: String]()
    
    var currentAnswer = 0
    var currentQuestionIndex = 0
    var isFromOnBoarding = false
    
    var arrAnswersKapha:[Int] = [Int]()
    var arrAnswersVata:[Int] = [Int]()
    var arrAnswersPitha:[Int] = [Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_Title.text = "Vikriti".localized()
        self.lbl_hello_subTitle.text = "I'm AyuMonk your personal wellness assistant".localized()
        self.tbl_view.register(nibWithCellClass: ChatTableCell.self)
        self.tbl_view.register(nibWithCellClass: PrakritiQuestionTableCell.self)
        self.navigationController?.isNavigationBarHidden = true
        
        if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
            //REGISTERED USER
            let strUserName = (empData["name"] as? String ?? "")
            let arr_Name = strUserName.components(separatedBy: " ")
            if arr_Name.count != 0 {
                let strFirstName = arr_Name.first ?? strUserName
                self.lbl_UserName.text = "Hey".localized() + " \(strFirstName) 👋"
            }
            else {
                self.lbl_UserName.text = "Hey".localized() + " \(strUserName) 👋"
            }
        }

        self.getQuestionsFromServer()
        self.setupTopCustomHeader()
    }
    
    func setupTopCustomHeader() {
        self.view_Initial.roundCorners(corners: [.topLeft, .bottomLeft], radius: 8)
        self.view_InitialBase.roundCorners(corners: [.topLeft, .bottomLeft], radius: 8)
        
        self.view_Middle.roundCorners(corners: [.topLeft, .bottomLeft], radius: 8)
        self.view_MiddleBase.roundCorners(corners: [.topLeft, .bottomLeft], radius: 8)
        
        self.view_Last.roundCorners(corners: [.topLeft, .bottomLeft], radius: 8)
        self.view_LastBase.roundCorners(corners: [.topLeft, .bottomLeft], radius: 8)
        
        self.setupStack_asperForLoop(stack_view: self.view_InitialStack)
        self.setupStack_asperForLoop(stack_view: self.view_MiddleStack)
        self.setupStack_asperForLoop(stack_view: self.view_LastStack)
    }
    
    func setupStack_asperForLoop(stack_view: UIStackView) {
        let getWidth = stack_view.frame.size.width/9
        
        for i in 1...6 {
            let view_base = UIView()
            view_base.frame = CGRect.init(x: getWidth*CGFloat(i), y: 0, width: getWidth, height: stack_view.frame.size.height)
            view_base.backgroundColor = UIColor.clear
            let view_Dot = UIView()
            view_Dot.frame = CGRect.init(x: 0, y: 0, width: 5, height: 5)
            view_Dot.layer.cornerRadius = 2.5
            view_Dot.backgroundColor = UIColor.white
            view_Dot.center = CGPoint(x: view_base.frame.size.width / 2, y: view_base.frame.size.height / 2)
            view_base.addSubview(view_Dot)
            view_base.tag = i
            view_Dot.tag = i
            stack_view.addArrangedSubview(view_base)
        }
    }
    
    func backClick() {
        if let stackVCs = self.navigationController?.viewControllers {
            if let activeSubVC = stackVCs.first(where: { type(of: $0) == MyHomeViewController.self }) {
                self.navigationController?.popToViewController(activeSubVC, animated: false)
            }
        }
    }
    
    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        Utils.showAlertWithTitleInControllerWithCompletion("Vikriti Questions".localized(), message: "Are you sure you want to close this test?".localized(), cancelTitle: "Cancel", okTitle: "Yes", controller: self) {
            self.backClick()
        } completionHandlerCancel: {
        }
    }
    
    @IBAction func btn_Skip_Action(_ sender: UIButton) {
        saveVikritiQuestionAnswers()
        if let stackVCs = self.navigationController?.viewControllers {
            if let activeSubVC = stackVCs.first(where: { type(of: $0) == MyHomeViewController.self }) {
                self.navigationController?.popToViewController(activeSubVC, animated: false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let previousAnswersData = kUserDefaults.object(forKey: PRASHNA_VIKRITI_ANSWERS) as? Data {
            if let unArchieveData = NSKeyedUnarchiver.unarchiveObject(with: previousAnswersData) as? [Int: String] {
                self.dicAnswers = unArchieveData
            }
        } else {
            self.dicAnswers = [Int: String]()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !self.isFromOnBoarding {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension Vikrati30QuestionnaireVC {
    func getQuestionsFromServer () {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.v2.prashnaVikriti.rawValue
            let params = ["type": "prashna", "language_id" : Utils.getLanguageId()] as [String : Any]
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { [weak self] response in
                guard let `self` = self else {
                    return
                }
                
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let arrQuestions = (value as? [[String: Any]]) else {
                        return
                    }
                    let sortedQuestions = arrQuestions.sorted(by: { (dic1, dic2) -> Bool in
                        let questionID1 = Int((dic1["id"] as? String ?? "0")) ?? 0
                        let questionID2 = Int((dic2["id"] as? String ?? "0")) ?? 0
                        return questionID1 < questionID2
                    })
                    self.arrAllQuestions = sortedQuestions
                    if !self.arrAllQuestions.isEmpty {
                        self.updateData()
                    }
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: error.localizedDescription, okTitle: "Ok".localized(), controller: self) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        } else {
            Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: NO_NETWORK, okTitle: "Ok".localized(), controller: self) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}


extension Vikrati30QuestionnaireVC {
    static func showScreen(isFromOnBoarding: Bool = false, fromVC: UIViewController) {
        //New design
        let vc = Vikrati30QuestionnaireVC.instantiate(fromAppStoryboard: .Questionnaire)
        vc.hidesBottomBarWhenPushed = true
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updatePageNumber(isInitialUpdate: Bool = false) {
        updateSectionTitleAndProgress(isInitialUpdate: isInitialUpdate)
    }
    
    func updateSectionTitleAndProgress(isInitialUpdate: Bool = false) {
        var currentQuestionNumber = currentQuestionIndex
        let questionPerSection = 7
        var sectionNumber = 1
        switch currentQuestionIndex {
        case 0..<questionPerSection:
            currentQuestionNumber = currentQuestionIndex
            sectionNumber = 1
        case questionPerSection..<2*questionPerSection:
            currentQuestionNumber = currentQuestionIndex%questionPerSection
            sectionNumber = 2
        case 2*questionPerSection..<3*questionPerSection:
            currentQuestionNumber = currentQuestionIndex%(2*questionPerSection)
            sectionNumber = 3
        default:
            print("handle other sections")
            sectionNumber = 4
        }
        
        let isAnsweredLastQuestion = dicAnswers.keys.count == arrAllQuestions.count && currentQuestionIndex == arrAllQuestions.count
        
        var int_section = sectionNumber
        if sectionNumber == 4 {
            int_section = 3
        }
        
        updateQuestionConutLable(currentIndex: currentQuestionNumber, fromQuestions: questionPerSection, section: int_section)
                
        var giftClaimedQuestionIndices = kUserDefaults.giftClaimedVikritiQuestionIndices
        print("<<<< giftClaimedQuestionIndices : ", giftClaimedQuestionIndices)
        if !giftClaimedQuestionIndices.contains(currentQuestionIndex) && ((sectionNumber > 1 && currentQuestionNumber == 0) || isAnsweredLastQuestion) {
            ScratchCardVC.showScreen(cardType: "question", fromVC: self)
            giftClaimedQuestionIndices.append(currentQuestionIndex)
            print(">>>> giftClaimedQuestionIndices : ", giftClaimedQuestionIndices)
            kUserDefaults.giftClaimedVikritiQuestionIndices = giftClaimedQuestionIndices
        }
        
    }
    
    func updateData() {
        if let previousAnswersData = kUserDefaults.object(forKey: PRASHNA_VIKRITI_ANSWERS) as? Data {
            if let unArchieveData = NSKeyedUnarchiver.unarchiveObject(with: previousAnswersData) as? [Int: String] {
                self.dicAnswers = unArchieveData
            }
        } else {
            self.dicAnswers = [Int: String]()
        }
        
        if self.dicAnswers.keys.count > 0 {
            let totalAnswers = dicAnswers.keys.count
            self.currentQuestionIndex = (totalAnswers == self.arrAllQuestions.count) ? totalAnswers - 1 : totalAnswers
        }
        self.updatePageNumber(isInitialUpdate: true)
        self.manageSection(self.dicAnswers.count == 0 ? true : false)
    }
    
    func updateQuestionConutLable(currentIndex: Int, fromQuestions: Int, section: Int) {
        
        DispatchQueue.main.async {
            if section == 1 {
                for stack in self.view_InitialStack.subviews {
                    if stack.tag <= currentIndex {
                        if stack.tag == 1 {
                            self.view_Initial.backgroundColor = AppColor.app_SelectedGreenColor
                        }
                        else if stack.tag == 6 {
                            if currentIndex == 7 {
                                self.view_Q10.backgroundColor = AppColor.app_SelectedGreenColor
                                self.view_InitialBase.backgroundColor = AppColor.app_SelectedGreenColor
                            }
                            else {
                                self.view_Q10.backgroundColor = UIColor.clear
                                self.view_InitialBase.backgroundColor = UIColor.clear
                            }
                        }
                        stack.backgroundColor = AppColor.app_SelectedGreenColor
                        stack.subviews.first?.backgroundColor = AppColor.app_DotGrayColor
                    }
                    else {
                        if stack.tag == 1 {
                            self.view_Initial.backgroundColor = UIColor.clear
                        }
                        stack.backgroundColor = UIColor.clear
                        self.view_Q10.backgroundColor = UIColor.clear
                        stack.subviews.first?.backgroundColor = UIColor.white
                        self.view_InitialBase.backgroundColor = UIColor.clear
                    }
                }
            }
            else if section == 2 {
                self.view_Q10.backgroundColor = AppColor.app_SelectedGreenColor
                self.view_Initial.backgroundColor = AppColor.app_SelectedGreenColor
                self.view_InitialBase.backgroundColor = AppColor.app_SelectedGreenColor
                for stack in self.view_InitialStack.subviews {
                    stack.backgroundColor = AppColor.app_SelectedGreenColor
                    stack.subviews.first?.backgroundColor = AppColor.app_DotGrayColor
                }
                
                for stack in self.view_MiddleStack.subviews {
                    if stack.tag <= currentIndex {
                        if stack.tag == 1 {
                            self.view_Middle.backgroundColor = AppColor.app_SelectedGreenColor
                        }
                        else if stack.tag == 6 {
                            if currentIndex == 14 {
                                self.view_Q20.backgroundColor = AppColor.app_SelectedGreenColor
                                self.view_MiddleBase.backgroundColor = AppColor.app_SelectedGreenColor
                            }
                            else {
                                self.view_Q20.backgroundColor = UIColor.clear
                                self.view_MiddleBase.backgroundColor = UIColor.clear
                            }
                        }
                        stack.backgroundColor = AppColor.app_SelectedGreenColor
                        stack.subviews.first?.backgroundColor = AppColor.app_DotGrayColor
                    }
                    else {
                        if stack.tag == 1 {
                            self.view_Middle.backgroundColor = UIColor.clear
                        }
                        stack.backgroundColor = UIColor.clear
                        self.view_Q20.backgroundColor = UIColor.clear
                        stack.subviews.first?.backgroundColor = UIColor.white
                        self.view_MiddleBase.backgroundColor = UIColor.clear
                    }
                }
            }
            
            else if section == 3 {
                
                for stack in self.view_InitialStack.subviews {
                    stack.backgroundColor = AppColor.app_SelectedGreenColor
                    stack.subviews.first?.backgroundColor = AppColor.app_DotGrayColor
                }
                
                self.view_Q10.backgroundColor = AppColor.app_SelectedGreenColor
                self.view_Initial.backgroundColor = AppColor.app_SelectedGreenColor
                self.view_InitialBase.backgroundColor = AppColor.app_SelectedGreenColor
                
                for stack in self.view_MiddleStack.subviews {
                    stack.backgroundColor = AppColor.app_SelectedGreenColor
                    stack.subviews.first?.backgroundColor = AppColor.app_DotGrayColor
                }
                
                self.view_Q20.backgroundColor = AppColor.app_SelectedGreenColor
                self.view_Middle.backgroundColor = AppColor.app_SelectedGreenColor
                self.view_MiddleBase.backgroundColor = AppColor.app_SelectedGreenColor
                
                for stack in self.view_LastStack.subviews {
                    if stack.tag <= currentIndex {
                        if stack.tag == 1 {
                            self.view_Last.backgroundColor = AppColor.app_SelectedGreenColor
                        }
                        else if stack.tag == 6 {
                            if currentIndex == 21 {
                                self.view_Q30.backgroundColor = AppColor.app_SelectedGreenColor
                                self.view_LastBase.backgroundColor = AppColor.app_SelectedGreenColor
                            }
                            else {
                                self.view_Q30.backgroundColor = UIColor.clear
                                self.view_LastBase.backgroundColor = UIColor.clear
                            }
                        }
                        stack.backgroundColor = AppColor.app_SelectedGreenColor
                        stack.subviews.first?.backgroundColor = AppColor.app_DotGrayColor
                    }
                    else {
                        if stack.tag == 1 {
                            self.view_Last.backgroundColor = UIColor.clear
                        }
                        stack.backgroundColor = UIColor.clear
                        self.view_Q30.backgroundColor = UIColor.clear
                        stack.subviews.first?.backgroundColor = UIColor.white
                        self.view_LastBase.backgroundColor = UIColor.clear
                    }
                }
            }
        }
    }
    
    func clearSavedData() {
        kUserDefaults.set(nil, forKey: PRASHNA_VIKRITI_ANSWERS)
    }
    
    func saveVikritiQuestionAnswers() {
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: self.dicAnswers)
        kUserDefaults.set(archieveData, forKey: PRASHNA_VIKRITI_ANSWERS)
    }
}


//MARK: UITableView Delegates and Datasource Method

extension Vikrati30QuestionnaireVC: UITableViewDelegate, UITableViewDataSource, delegateConfirmation {
    
    func manageSection(_ initial_start: Bool) {
        self.arr_Chat.removeAll()
        
        if initial_start {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.arr_Chat.append(["id" : "chat", "text": "Vikrati_chat_text_1".localized()])
                self.tbl_view.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.arr_Chat.append(["id" : "chat", "text": "Vikrati_chat_text_2".localized()])
                    self.tbl_view.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                        self.arr_Chat.append(["id" : "chat", "text": "Vikrati_chat_text_3".localized()])
                        self.tbl_view.reloadData()
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                            self.arr_Chat.append(["id" : "chat", "text": "Vikrati_chat_text_4".localized()])
                            self.tbl_view.reloadData()
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                                
                                if let dic_firstQuestion = self.arrAllQuestions.first {
                                    self.arr_Chat.append(dic_firstQuestion)
                                }

                                self.tbl_view.reloadData()
                                self.tbl_view.scrollToRow(at: IndexPath.init(row: self.arr_Chat.count - 1, section: 0), at: .bottom, animated: true)
                            }
                        }
                    }
                }
            }
        }
        else {
            self.arr_Chat.append(["id" : "chat", "text": "Vikrati_chat_text_1".localized()])
            self.arr_Chat.append(["id" : "chat", "text": "Vikrati_chat_text_2".localized()])
            self.arr_Chat.append(["id" : "chat", "text": "Vikrati_chat_text_3".localized()])
            self.arr_Chat.append(["id" : "chat", "text": "Vikrati_chat_text_4".localized()])
            
            for questionnn in 0...self.currentQuestionIndex {
                self.arr_Chat.append(self.arrAllQuestions[questionnn])
            }

            self.tbl_view.reloadData()
            self.tbl_view.scrollToRow(at: IndexPath.init(row: self.arr_Chat.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Chat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = self.arr_Chat[indexPath.row]["id"] as? String ?? ""
        if identifier == "chat" {
            let cell = tableView.dequeueReusableCell(withClass: ChatTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_Text.text = self.arr_Chat[indexPath.row]["text"] as? String ?? ""
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withClass: PrakritiQuestionTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_Option4.text = ""
            cell.img_Option4.image = nil
            cell.constraint_lbl_Option4_Top.constant = 0
            cell.constraint_lbl_Option4_Bottom.constant = 0
            
            let questionID = Int((self.arr_Chat[indexPath.row]["question_id"] as? String ?? "0")) ?? 0
            let str_img_question = self.arr_Chat[indexPath.row]["detail_image"] as? String ?? ""
            cell.img_Question.sd_setImage(with: URL(string: str_img_question), placeholderImage: nil)
            
            cell.btn_Option1.addTarget(self, action: #selector(answerKaphClicked(sender:)), for: .touchUpInside)
            cell.btn_Option1.tag = currentQuestionIndex
            cell.btn_Option1.accessibilityValue = "\(questionID)"
            
            cell.btn_Option2.addTarget(self, action: #selector(answerPittaClicked(sender:)), for: .touchUpInside)
            cell.btn_Option2.tag = currentQuestionIndex
            cell.btn_Option2.accessibilityValue = "\(questionID)"
            
            cell.btn_Option3.addTarget(self, action: #selector(answerVataClicked(sender:)), for: .touchUpInside)
            cell.btn_Option3.tag = currentQuestionIndex
            cell.btn_Option3.accessibilityValue = "\(questionID)"
                        
            let selectionImage = UIImage.init(named: "radio_button_checked_blue")
            let un_selectionImage = UIImage.init(named: "radio_button_unchecked_blue")
            cell.img_Option1.image = un_selectionImage
            cell.img_Option2.image = un_selectionImage
            cell.img_Option3.image = un_selectionImage
            
            cell.lbl_Question.text = self.arr_Chat[indexPath.row]["question"] as? String ?? ""
            cell.lbl_Option1.text = self.arr_Chat[indexPath.row]["kapha"] as? String ?? ""
            cell.lbl_Option2.text = self.arr_Chat[indexPath.row]["pitta"] as? String ?? ""
            cell.lbl_Option3.text = self.arr_Chat[indexPath.row]["vatta"] as? String ?? ""

            if dicAnswers[questionID] == "Kapha" {
                cell.img_Option1.image = selectionImage
            } else if dicAnswers[questionID] == "Pitta" {
                cell.img_Option2.image = selectionImage
            } else if dicAnswers[questionID] == "Vata" {
                cell.img_Option3.image = selectionImage
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK: IBActions
    @objc func answerKaphClicked(sender: UIButton) {
        let questionID = Int(sender.accessibilityValue ?? "") ?? 0
        if let available = dicAnswers.keys.firstIndex(of: questionID) {
            dicAnswers[questionID] = "Kapha"
            self.tbl_view.reloadData()
            return
        }
        dicAnswers[questionID] = "Kapha"
        moveToNextAccount()
    }
    
    @objc func answerPittaClicked(sender: UIButton) {
        let questionID = Int(sender.accessibilityValue ?? "") ?? 0
        if let available = dicAnswers.keys.firstIndex(of: questionID) {
            dicAnswers[questionID] = "Pitta"
            self.tbl_view.reloadData()
            return
        }
        dicAnswers[questionID] = "Pitta"
        moveToNextAccount()
    }
    
    @objc func answerVataClicked(sender: UIButton) {
        let questionID = Int(sender.accessibilityValue ?? "") ?? 0
        if let available = dicAnswers.keys.firstIndex(of: questionID) {
            dicAnswers[questionID] = "Vata"
            self.tbl_view.reloadData()
            return
        }
        dicAnswers[questionID] = "Vata"
        moveToNextAccount()
    }
    
    func moveToNextAccount() {
        self.saveVikritiQuestionAnswers()
        DispatchQueue.main.async {
            guard self.currentQuestionIndex + 1 < self.arrAllQuestions.count else {
                self.currentQuestionIndex += 1
                self.tbl_view.reloadData()
                self.updatePageNumber()
                return
            }
            self.currentQuestionIndex += 1
            self.arr_Chat.append(self.arrAllQuestions[self.currentQuestionIndex])
            self.tbl_view.reloadData()
            self.tbl_view.scrollToRow(at: IndexPath.init(row: self.arr_Chat.count - 1, section: 0), at: .bottom, animated: true)
            self.updatePageNumber()
        }
    }
    
    func submitClick_after21Question() {
        
        if self.dicAnswers.keys.count == self.arrAllQuestions.count, self.currentQuestionIndex == self.arrAllQuestions.count {
            self.calculateResult()
            return
        }
    }
    
    func calculateResult() {
        var kaphaCount = 0.0
        var pittaCount = 0.0
        var vataCount = 0.0
        
        let arrVata = dicAnswers.values.filter { (str) -> Bool in
            if str == "Kapha" {
                kaphaCount += 1
                return false
            } else if str == "Pitta" {
                pittaCount += 1
                return false
            } else {
                return true
            }
        }
        vataCount = Double(arrVata.count)
        let resultSpar = "\(kaphaCount*28),\(pittaCount*28),\(vataCount*28)"
        kUserDefaults.set(resultSpar, forKey: VIKRITI_PRASHNA)
        let result = "[" + Utils.getVikritiValue() + "]"
        
        if kSharedAppDelegate.userId.isEmpty {
            //Store data locallly to send to server in registration
            let newValue = Utils.parseValidValue(string: result)
            kUserDefaults.set(newValue, forKey: RESULT_VIKRITI)
            kUserDefaults.set(true, forKey: kVikritiPrashnaCompleted)
            //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.vikriti_prashna.rawValue)
            kSharedAppDelegate.showHomeScreen()
        }
        postQuestionsData(value: result, score: result, prashnaAnswers: resultSpar)
    }
    
    func postQuestionsData(value: String, score: String, prashnaAnswers: String) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let answers = Utils.getAnswersString(dicAnswers: self.dicAnswers)
            let urlString = kBaseNewURL + endPoint.usergraphspar.rawValue
            var params = ["user_vikriti":value, "vikriti_prashna": "true", "answers": answers, "score": score, "vikriti_prashnavalue" : prashnaAnswers]
            params.addVikritiResultFinalValue()
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON  { response in
                
                switch response.result {
                    
                case .success(let values):
                    print(response)
                    guard let dic = (values as? [String: Any]) else {
                        return
                    }
                    if (dic["status"] as? String ?? "") == "Sucess" {
                        let newValues = Utils.parseValidValue(string: value)
                        kUserDefaults.set(newValues, forKey: RESULT_VIKRITI)
                        kUserDefaults.set(true, forKey: kVikritiPrashnaCompleted)
                        if !self.isFromOnBoarding {
                            self.navigationController?.isNavigationBarHidden = false
                        }
                        appDelegate.sparshanAssessmentDone = true
                        self.clearSavedData()
                        kUserDefaults.giftClaimedVikritiQuestionIndices = []
                        self.hideActivityIndicator()
                        self.backClick()
                    } else {
                        Utils.showAlertWithTitleInController(APP_NAME, message: (dic["Message"] as? String ?? ""), controller: self)
                    }
                    
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        }else {
            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
        }
    }
        
    func afterscretchScreenClose(_ success: Bool) {
        if success {
            if self.currentQuestionIndex == 21 {
                self.submitClick_after21Question()
            }
        }
    }
}

