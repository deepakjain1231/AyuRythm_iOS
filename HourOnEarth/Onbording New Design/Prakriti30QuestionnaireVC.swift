//
//  Prakriti30QuestionnaireVCViewController.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 04/05/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire


class Prakriti30QuestionnaireVC: BaseViewController {//}, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var lbl_Title: UILabel!
    
    @IBOutlet weak var lbl_hello_subTitle: UILabel!
    
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
    
    //@IBOutlet weak var topGiftProgressView: ARGiftProgressView!
    //@IBOutlet weak var topProgressView: CustomProgressView!
    
    var arr_Chat = [[String: Any]]()
    var arrAllQuestions:[[String: Any]] = [[String: Any]]()
    var arrQuestions:[[String: Any]] = [[String: Any]]()
    var dicAnswers:[Int: Int] = [Int: Int]()
    var arraySkippedQuestionsIds:[Int] = [Int]()
    var arrCompletedQuestions: [[String: Any]] = [[String: Any]]()
    var arrSkippedQuestions: [[String: Any]] = [[String: Any]]()
    
    var arrAnswersKapha:[Int] = [Int]()
    var arrAnswersVata:[Int] = [Int]()
    var arrAnswersPitha:[Int] = [Int]()
    
    var currentAnswer = 0
    var currentQuestionIndex = 0
    var skipCount = 0
    var isTryAsGuest = false
    var isCompletedQuestions = false
    var isSkippedQuestions = false
    var isFromOnBoarding = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_Title.text = "Prakriti".localized()
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
        
        if isCompletedQuestions || isSkippedQuestions {
            updatePageNumber()
        } else {
            self.updateData()
//            self.getQuestionsFromServer()
        }
        
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
        
        for i in 1...9 {
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
    
    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        if let stackVCs = self.navigationController?.viewControllers {
            if let activeSubVC = stackVCs.first(where: { type(of: $0) == MyHomeViewController.self }) {
                self.navigationController?.popToViewController(activeSubVC, animated: false)
            }
        }
    }
    
    @IBAction func btn_Skip_Action(_ sender: UIButton) {
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: dicAnswers)
        kUserDefaults.set(archieveData, forKey: kPrakritiAnswers)
        if let stackVCs = self.navigationController?.viewControllers {
            if let activeSubVC = stackVCs.first(where: { type(of: $0) == MyHomeViewController.self }) {
                self.navigationController?.popToViewController(activeSubVC, animated: false)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let previousAnswersData = kUserDefaults.object(forKey: kPrakritiAnswers) as? Data {
            if let unArchieveData = NSKeyedUnarchiver.unarchiveObject(with: previousAnswersData) as? [Int:Int] {
                self.dicAnswers = unArchieveData
            }
        } else {
            self.dicAnswers = [Int: Int]()
        }
        
        if let previousAnswersData = kUserDefaults.object(forKey: kSkippedQuestions) as? Data {
            if let unArchieveData = NSKeyedUnarchiver.unarchiveObject(with: previousAnswersData) as? [Int] {
                self.arraySkippedQuestionsIds = unArchieveData
            }
        } else {
            self.arraySkippedQuestionsIds = []
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

extension Prakriti30QuestionnaireVC {
    func getQuestionsFromServer () {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.v2.getprakrutiquestionswithoptions.rawValue
            let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
            
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
                    //Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
                    Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: error.localizedDescription, okTitle: "Ok".localized(), controller: self) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                DispatchQueue.main.async(execute: {
                    Utils.stopActivityIndicatorinView(self.view)
                })
            }
        } else {
            //Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
            Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: NO_NETWORK, okTitle: "Ok".localized(), controller: self) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func postQuestionsData(value: String, answers: String, score: String) {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.updateparkriti.rawValue
            var params = ["user_prakriti": value, "answers": answers, "score": score]
            params.addPrakritiResultFinalValue()
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON  { response in
                
                switch response.result {
                    
                case .success(let values):
                    print(response)
                    guard let dic = (values as? [String: Any]) else {
                        return
                    }
                    if (dic["status"] as? String ?? "") == "Sucess" {
                        let newValue = Utils.parseValidValue(string: value)
                        kUserDefaults.set(newValue, forKey: RESULT_PRAKRITI)
                        self.clearSavedData()
                        kUserDefaults.giftClaimedPrakritiQuestionIndices = []
                        if !self.isFromOnBoarding {
                            self.navigationController?.isNavigationBarHidden = false
                        }
                        /*
                        let storyBoard = UIStoryboard(name: "PrakritiResult", bundle: nil)
                        let objDescription = storyBoard.instantiateViewController(withIdentifier: "PrakritiResult") as! PrakritiResult
                        objDescription.isRegisteredUser = !kSharedAppDelegate.userId.isEmpty
                        self.navigationController?.pushViewController(objDescription, animated: true)
                        */
                        appDelegate.sparshanAssessmentDone = true
                        let vc = PrakritiResult1VC.instantiate(fromAppStoryboard: .Questionnaire)
                        vc.isRegisteredUser = !kSharedAppDelegate.userId.isEmpty
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    } else {
                        Utils.showAlertWithTitleInController(APP_NAME, message: (dic["Message"] as? String ?? ""), controller: self)
                    }
                    
                case .failure(let error):
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
    
    
}


extension Prakriti30QuestionnaireVC {
    static func showScreen(isFromOnBoarding: Bool = false, fromVC: UIViewController) {
        //New design
        let vc = Prakriti30QuestionnaireVC.instantiate(fromAppStoryboard: .Questionnaire)
        vc.isTryAsGuest = kSharedAppDelegate.userId.isEmpty
        vc.isFromOnBoarding = isFromOnBoarding
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updatePageNumber(isInitialUpdate: Bool = false) {
        /*
        var currentQuestionNumber = currentQuestionIndex
        let questionPerSection = 10
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
        */

//        updateQuestionConutLable(currentIndex: currentQuestionIndex, fromQuestions: arrQuestions.count, section: sectionNumber)
//        if currentQuestionIndex + 1 == self.arrQuestions.count {
//            self.updatePageNumber()
//            self.tbl_view.reloadData()
//        } else {
//            let questionID = Int((arrQuestions[currentQuestionIndex]["id"] as? String ?? "0")) ?? 0
//            if dicAnswers[questionID] != nil {
//            } else {
//            }
//        }
        updateSectionTitleAndProgress(isInitialUpdate: isInitialUpdate)
    }
    
    func updateSectionTitleAndProgress(isInitialUpdate: Bool = false) {
        var currentQuestionNumber = currentQuestionIndex
        let questionPerSection = 10
        var sectionNumber = 1
        switch currentQuestionIndex {
        case 0..<questionPerSection:
            //lblSection.text = "Section".localized() + " 1"
            currentQuestionNumber = currentQuestionIndex
            sectionNumber = 1
        case questionPerSection..<2*questionPerSection:
            //lblSection.text = "Section".localized() + " 2"
            currentQuestionNumber = currentQuestionIndex%questionPerSection
            sectionNumber = 2
        case 2*questionPerSection..<3*questionPerSection:
            //lblSection.text = "Section".localized() + " 3"
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
        
        var giftClaimedQuestionIndices = kUserDefaults.giftClaimedPrakritiQuestionIndices
        //print("<<<< giftClaimedQuestionIndices : ", giftClaimedQuestionIndices)
        if !giftClaimedQuestionIndices.contains(currentQuestionIndex) && ((sectionNumber > 1 && currentQuestionNumber == 0) || isAnsweredLastQuestion) {
            ScratchCardVC.showScreen(cardType: "question", fromVC: self)
            giftClaimedQuestionIndices.append(currentQuestionIndex)
            print(">>>> giftClaimedQuestionIndices : ", giftClaimedQuestionIndices)
            kUserDefaults.giftClaimedPrakritiQuestionIndices = giftClaimedQuestionIndices
        }
        else {
            self.afterscretchScreenClose(true)
        }
    }
    
    func updateData() {
        for question in self.arrAllQuestions {
            let questionID = Int((question["id"] as? String ?? "0")) ?? 0
            if self.arraySkippedQuestionsIds.contains(questionID) {
                self.arrSkippedQuestions.append(question)
            } else if self.dicAnswers[questionID] != nil {
                self.arrCompletedQuestions.append(question)
            }
            self.arrQuestions.append(question)
        }
        if self.dicAnswers.keys.count > 0 {
            let totalAnswers = dicAnswers.keys.count
            self.currentQuestionIndex = (totalAnswers == arrAllQuestions.count) ? totalAnswers - 1 : totalAnswers
        }
        self.arrCompletedQuestions.sort(by: { (dic1, dic2) -> Bool in
            let questionID1 = Int((dic1["id"] as? String ?? "0")) ?? 0
            let questionID2 = Int((dic2["id"] as? String ?? "0")) ?? 0
            return questionID1 < questionID2
        })
        self.updatePageNumber(isInitialUpdate: true)
        self.manageSection(self.arrCompletedQuestions.count == 0 ? true : false)
    }
    
    func updateQuestionConutLable(currentIndex: Int, fromQuestions: Int, section: Int) {
        
        DispatchQueue.main.async {
            if section == 1 {
                for stack in self.view_InitialStack.subviews {
                    if stack.tag <= currentIndex {
                        if stack.tag == 1 {
                            self.view_Initial.backgroundColor = AppColor.app_SelectedGreenColor
                        }
                        else if stack.tag == 9 {
                            if currentIndex == 10 {
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
                        else if stack.tag == 9 {
                            if currentIndex == 20 {
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
                        else if stack.tag == 9 {
                            if currentIndex == 30 {
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
        kUserDefaults.set(nil, forKey: kPrakritiAnswers)
        kUserDefaults.set(nil, forKey: kSkippedQuestions)
    }
}


//MARK: UITableView Delegates and Datasource Method

extension Prakriti30QuestionnaireVC: UITableViewDelegate, UITableViewDataSource , delegateConfirmation {
    
    func manageSection(_ initial_start: Bool) {
        self.arr_Chat.removeAll()
        
        if initial_start {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.arr_Chat.append(["id" : "chat", "text": "Prakriti_chat_text_1".localized()])
                self.tbl_view.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.arr_Chat.append(["id" : "chat", "text": "Prakriti_chat_text_2".localized()])
                    self.tbl_view.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                        self.arr_Chat.append(["id" : "chat", "text": "Prakriti_chat_text_3".localized()])
                        self.tbl_view.reloadData()
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                            self.arr_Chat.append(["id" : "chat", "text": "Prakriti_chat_text_4".localized()])
                            self.tbl_view.reloadData()
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                                
                                if let dic_firstQuestion = self.arrQuestions.first {
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
            self.arr_Chat.append(["id" : "chat", "text": "Prakriti_chat_text_1".localized()])
            self.arr_Chat.append(["id" : "chat", "text": "Prakriti_chat_text_2".localized()])
            self.arr_Chat.append(["id" : "chat", "text": "Prakriti_chat_text_3".localized()])
            self.arr_Chat.append(["id" : "chat", "text": "Prakriti_chat_text_4".localized()])
            
            for questionnn in 0...self.currentQuestionIndex {
                self.arr_Chat.append(self.arrQuestions[questionnn])
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
            
            let questionID = Int((self.arr_Chat[indexPath.row]["question_id"] as? String ?? "0")) ?? 0
            let str_img_question = self.arr_Chat[indexPath.row]["detail_image"] as? String ?? ""
            cell.img_Question.sd_setImage(with: URL(string: str_img_question), placeholderImage: nil)
            
            cell.btn_Option1.addTarget(self, action: #selector(answerYesClicked(sender:)), for: .touchUpInside)
            cell.btn_Option1.tag = currentQuestionIndex
            cell.btn_Option1.accessibilityValue = "\(questionID)"

            cell.btn_Option2.addTarget(self, action: #selector(answerNoClicked(sender:)), for: .touchUpInside)
            cell.btn_Option2.tag = currentQuestionIndex
            cell.btn_Option2.accessibilityValue = "\(questionID)"

            cell.btn_Option3.addTarget(self, action: #selector(answerMTTOClicked(sender:)), for: .touchUpInside)
            cell.btn_Option3.tag = currentQuestionIndex
            cell.btn_Option3.accessibilityValue = "\(questionID)"

            cell.btn_Option4.addTarget(self, action: #selector(answerAlwaysClicked(sender:)), for: .touchUpInside)
            cell.btn_Option4.tag = currentQuestionIndex
            cell.btn_Option4.accessibilityValue = "\(questionID)"
            
            let selectionImage = UIImage.init(named: "radio_button_checked_blue")
            let un_selectionImage = UIImage.init(named: "radio_button_unchecked_blue")
            cell.img_Option1.image = un_selectionImage
            cell.img_Option2.image = un_selectionImage
            cell.img_Option3.image = un_selectionImage
            cell.img_Option4.image = un_selectionImage
            
            
            cell.lbl_Question.text = self.arr_Chat[indexPath.row]["question"] as? String ?? ""
            if let optionsArray = self.arr_Chat[indexPath.row]["options"] as? [[String: Any]], optionsArray.count >= 4 {
                let sortedOptions = optionsArray.sorted(by: { (dic1, dic2) -> Bool in
                    let optionId1 = Int((dic1["id"] as? String ?? "0")) ?? 0
                    let optionId2 = Int((dic2["id"] as? String ?? "0")) ?? 0
                    return optionId1 < optionId2
                })
                cell.lbl_Option1.text = sortedOptions[0]["qoption"] as? String ?? ""
                cell.lbl_Option2.text = sortedOptions[1]["qoption"] as? String ?? ""
                cell.lbl_Option3.text = sortedOptions[2]["qoption"] as? String ?? ""
                cell.lbl_Option4.text = sortedOptions[3]["qoption"] as? String ?? ""
            }
            
            

            if dicAnswers[questionID] == 0 {
                cell.img_Option1.image = selectionImage
            } else if dicAnswers[questionID] == 1 {
                cell.img_Option2.image = selectionImage
            } else if dicAnswers[questionID] == 2 {
                cell.img_Option3.image = selectionImage
            }else if dicAnswers[questionID] == 3 {
                cell.img_Option4.image = selectionImage
            }

            return cell
        }
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    @objc func answerYesClicked(sender: UIControl) {
        let questionID = Int(sender.accessibilityValue ?? "") ?? 0// Int((arrQuestions[sender.tag]["id"] as? String ?? "0")) ?? 0
        if let available = dicAnswers.keys.firstIndex(of: questionID) {
            dicAnswers[questionID] = 0
            self.tbl_view.reloadData()
            return
        }
        dicAnswers[questionID] = 0
        
        if !isCompletedQuestions {
            arrCompletedQuestions.append(arrQuestions[sender.tag])
            //self.updatePageNumber()
            removeFromSkipIfAnswered(questionId: questionID)
        }
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: dicAnswers)
        kUserDefaults.set(archieveData, forKey: kPrakritiAnswers)
        moveToNextAccount()
    }
    
    @objc func answerNoClicked(sender: UIControl) {
        let questionID = Int(sender.accessibilityValue ?? "") ?? 0// Int((arrQuestions[sender.tag]["id"] as? String ?? "0")) ?? 0
        if let available = dicAnswers.keys.firstIndex(of: questionID) {
            dicAnswers[questionID] = 1
            self.tbl_view.reloadData()
            return
        }
        dicAnswers[questionID] = 1
        
        if !isCompletedQuestions {
            //self.updatePageNumber()
            arrCompletedQuestions.append(arrQuestions[sender.tag])
            removeFromSkipIfAnswered(questionId: questionID)
        }
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: dicAnswers)
        kUserDefaults.set(archieveData, forKey: kPrakritiAnswers)
        moveToNextAccount()
    }
    
    @objc func answerAlwaysClicked(sender: UIControl) {
        let questionID = Int(sender.accessibilityValue ?? "") ?? 0// Int((arrQuestions[sender.tag]["id"] as? String ?? "0")) ?? 0
        if let available = dicAnswers.keys.firstIndex(of: questionID) {
            dicAnswers[questionID] = 3
            self.tbl_view.reloadData()
            return
        }
        dicAnswers[questionID] = 3
        
        if !isCompletedQuestions {
            //self.updatePageNumber()
            arrCompletedQuestions.append(arrQuestions[sender.tag])
            removeFromSkipIfAnswered(questionId: questionID)
        }
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: dicAnswers)
        kUserDefaults.set(archieveData, forKey: kPrakritiAnswers)
        moveToNextAccount()
    }
    
    @objc func answerMTTOClicked(sender: UIControl) {
        let questionID = Int(sender.accessibilityValue ?? "") ?? 0// Int((arrQuestions[sender.tag]["id"] as? String ?? "0")) ?? 0
        if let available = dicAnswers.keys.firstIndex(of: questionID) {
            dicAnswers[questionID] = 2
            self.tbl_view.reloadData()
            return
        }
        dicAnswers[questionID] = 2
        
        if !isCompletedQuestions {
            //self.updatePageNumber()
            arrCompletedQuestions.append(arrQuestions[sender.tag])
            removeFromSkipIfAnswered(questionId: questionID)
        }
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: dicAnswers)
        kUserDefaults.set(archieveData, forKey: kPrakritiAnswers)
        moveToNextAccount()
    }
    
    func moveToNextAccount() {
        DispatchQueue.main.async {
            guard self.currentQuestionIndex + 1 < self.arrQuestions.count else {
                self.currentQuestionIndex += 1
                self.tbl_view.reloadData()
                self.updatePageNumber()
                return
            }
            self.currentQuestionIndex += 1
            self.arr_Chat.append(self.arrQuestions[self.currentQuestionIndex])
            self.tbl_view.reloadData()
            self.tbl_view.scrollToRow(at: IndexPath.init(row: self.arr_Chat.count - 1, section: 0), at: .bottom, animated: true)
            self.updatePageNumber()
        }
    }
    
    func submitClick_after30Question() {
        
        if self.dicAnswers.keys.count == self.arrAllQuestions.count, self.currentQuestionIndex == self.arrAllQuestions.count {
            self.calculateResult()
            return
        }
    }
    
    func calculateResult() {
        //MARK:- 1 to 10 10 to 20 and 20 to 30
        let kaphaQuestions = Array(self.arrAllQuestions[0..<10])
        for question in kaphaQuestions {
            let questionID = Int((question["question_id"] as? String ?? "0")) ?? 0
            if let value = dicAnswers[questionID] {
                arrAnswersKapha.append(value)
            }
        }
        
        let pittaQuestions = Array(self.arrAllQuestions[10..<20])
        for question in pittaQuestions {
            let questionID = Int((question["question_id"] as? String ?? "0")) ?? 0
            if let value = dicAnswers[questionID] {
                arrAnswersPitha.append(value)
            }
        }
        
        let vataQuestions = Array(self.arrAllQuestions[20..<30])
        for question in vataQuestions {
            let questionID = Int((question["question_id"] as? String ?? "0")) ?? 0
            if let value = dicAnswers[questionID] {
                arrAnswersVata.append(value)
            }
        }
        
        
        let totalKaphAnswered: Double = Double(arrAnswersKapha.reduce(0, { x, y  in
            x + y
        }))
        
        let totalPithaAnswered: Double = Double(arrAnswersPitha.reduce(0, { x, y  in
            x + y
        }))
        
        let totalVataAnswered: Double = Double(arrAnswersVata.reduce(0, { x, y  in
            x + y
        }))
        
        let total = totalPithaAnswered + totalKaphAnswered + totalVataAnswered
        
        guard total != 0 else {
            Utils.showAlertWithTitleInControllerWithCompletion("Error".localized(), message: "Please retake the test and answer as accurately as possible.".localized(), okTitle: "Ok".localized(), controller: self) {
                self.clearSavedData()
                self.navigationController?.popToRootViewController(animated: true)
            }
            return
        }
        
        let percentPitha = totalPithaAnswered * 100.0/total
        
        let percentKapha = totalKaphAnswered * 100.0/total
        
        let percentVata =  totalVataAnswered * 100.0/total
        //KPV
        let result = "[" + "\"\(percentKapha.roundToOnePlace)\",\"\(percentPitha.roundToOnePlace)\",\"\(percentVata.roundToOnePlace)\"" + "]"
        
        let answers = Utils.getAnswersString(dicAnswers: self.dicAnswers)
        if isTryAsGuest {
            //Store data locallly to send to server in registration
            let newValue = Utils.parseValidValue(string: result)
            kUserDefaults.set(newValue, forKey: RESULT_PRAKRITI)
            kUserDefaults.set(answers, forKey: kPrakritiAnswersToSend)
            self.clearSavedData()
            appDelegate.sparshanAssessmentDone = true
            kUserDefaults.giftClaimedPrakritiQuestionIndices = []
            
            let storyBoard = UIStoryboard(name: "PrakritiResult", bundle: nil)
            let objDescription = storyBoard.instantiateViewController(withIdentifier: "PrakritiResult") as! PrakritiResult
            objDescription.isRegisteredUser = false
            self.navigationController?.pushViewController(objDescription, animated: true)
        } else {
            postQuestionsData(value: result, answers: answers, score: result)
        }
    }
    
    func removeFromSkipIfAnswered(questionId: Int) {
        if arraySkippedQuestionsIds.contains(questionId) {
            arraySkippedQuestionsIds.remove(at: arraySkippedQuestionsIds.firstIndex(of: questionId) ?? 0)
        }
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: arraySkippedQuestionsIds)
        kUserDefaults.set(archieveData, forKey: kSkippedQuestions)
    }
    
    func afterscretchScreenClose(_ success: Bool) {
        if success {
            if self.currentQuestionIndex == 30 {
                self.submitClick_after30Question()
            }
        }
    }
}
