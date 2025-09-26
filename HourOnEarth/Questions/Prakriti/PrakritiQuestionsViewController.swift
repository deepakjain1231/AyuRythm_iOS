//
//  PrakritiQuestionsViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 5/27/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class PrakritiQuestionsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tblQuestions: UITableView!
    @IBOutlet weak var lblCurrentPage: UILabel!
    @IBOutlet weak var lblTotalPage: UILabel!
    @IBOutlet weak var btnCompleted: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnSkippedQuestion: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var topProgressView: CustomProgressView!
    @IBOutlet weak var lblSection: UILabel!

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
        
        tblQuestions.register(UINib(nibName: "PrakritiCell", bundle: nil), forCellReuseIdentifier: "PrakritiCell")
        self.navigationController?.isNavigationBarHidden = true

        self.tblQuestions.estimatedRowHeight = 250
        self.tblQuestions.rowHeight = UITableView.automaticDimension
        lblCurrentPage.text = ""
        btnSkip.isHidden = true
        btnSkippedQuestion.isHidden = true
        
        if isCompletedQuestions || isSkippedQuestions {
            self.btnCompleted.isHidden = true
            self.btnPause.isHidden = true
            self.btnSkippedQuestion.isHidden = true
            self.btnSkip.isHidden = true
            updatePageNumber()
        } else {
            self.getQuestionsFromServer()
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
        self.btnSkippedQuestion.setTitle(("\(self.arraySkippedQuestionsIds.count) " + "Questions Skipped".localized()), for: .normal)
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
    
    //MARK: UITableView Delegates and Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrQuestions.count == 0 {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PrakritiCell = tableView.dequeueReusableCell(withIdentifier: "PrakritiCell") as! PrakritiCell
        cell.btnAnswer1.addTarget(self, action: #selector(PrakritiQuestionsViewController.answerYesClicked(sender:)), for: .touchUpInside)
        cell.btnAnswer1.tag = currentQuestionIndex
        
        cell.btnAnswer2.addTarget(self, action: #selector(PrakritiQuestionsViewController.answerNoClicked(sender:)), for: .touchUpInside)
        cell.btnAnswer2.tag = currentQuestionIndex

        cell.btnAnswer3.addTarget(self, action: #selector(PrakritiQuestionsViewController.answerMTTOClicked(sender:)), for: .touchUpInside)
          cell.btnAnswer3.tag = currentQuestionIndex
        
        cell.btnAnswer4.addTarget(self, action: #selector(PrakritiQuestionsViewController.answerAlwaysClicked(sender:)), for: .touchUpInside)
        cell.btnAnswer4.tag = currentQuestionIndex
        
        cell.btnAnswer2.isSelected = false
        cell.btnAnswer1.isSelected = false
        cell.btnAnswer3.isSelected = false
        cell.btnAnswer4.isSelected = false
        
        let defaultBGClor = UIColor.white.withAlphaComponent(0.3)
        cell.btnAnswer2.backgroundColor = defaultBGClor
        cell.btnAnswer1.backgroundColor = defaultBGClor
        cell.btnAnswer3.backgroundColor = defaultBGClor
        cell.btnAnswer4.backgroundColor = defaultBGClor
      
        let questionID = Int((arrQuestions[currentQuestionIndex]["id"] as? String ?? "0")) ?? 0
        cell.lblQuestion.text =  (arrQuestions[currentQuestionIndex]["question"] as? String ?? "")

        if let optionsArray = arrQuestions[currentQuestionIndex]["options"] as? [[String: Any]], optionsArray.count >= 4 {
            let sortedOptions = optionsArray.sorted(by: { (dic1, dic2) -> Bool in
                let optionId1 = Int((dic1["id"] as? String ?? "0")) ?? 0
                let optionId2 = Int((dic2["id"] as? String ?? "0")) ?? 0
                return optionId1 < optionId2
            })
            cell.lblAnswer1.text = sortedOptions[0]["qoption"] as? String ?? ""
            cell.lblAnswer2.text = sortedOptions[1]["qoption"] as? String ?? ""
            cell.lblAnswer3.text = sortedOptions[2]["qoption"] as? String ?? ""
            cell.lblAnswer4.text = sortedOptions[3]["qoption"] as? String ?? ""

        }
        
        if dicAnswers[questionID] == 0 {
            cell.btnAnswer1.isSelected = true
            cell.btnAnswer1.backgroundColor = kAppGreenD2Color
        } else if dicAnswers[questionID] == 1 {
            cell.btnAnswer2.isSelected = true
            cell.btnAnswer2.backgroundColor = kAppGreenD2Color
        } else if dicAnswers[questionID] == 2 {
            cell.btnAnswer3.isSelected = true
            cell.btnAnswer3.backgroundColor = kAppGreenD2Color
        }else if dicAnswers[questionID] == 3 {
            cell.btnAnswer4.isSelected = true
            cell.btnAnswer4.backgroundColor = kAppGreenD2Color
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK: IBActions
    
    @IBAction func btnPauseClicked(_ sender: UIButton) {
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: dicAnswers)
        kUserDefaults.set(archieveData, forKey: kPrakritiAnswers)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnCompletedClicked(_ sender: UIButton) {
        self.arrCompletedQuestions.sort(by: { (dic1, dic2) -> Bool in
            let questionID1 = Int((dic1["id"] as? String ?? "0")) ?? 0
            let questionID2 = Int((dic2["id"] as? String ?? "0")) ?? 0
            return questionID1 < questionID2
        })
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let objSlideView:PrakritiQuestionsViewController = storyBoard.instantiateViewController(withIdentifier: "PrakritiQuestionsViewController") as! PrakritiQuestionsViewController
        objSlideView.isTryAsGuest = self.isTryAsGuest
        objSlideView.dicAnswers = self.dicAnswers
        objSlideView.arrQuestions = self.arrCompletedQuestions
        objSlideView.isCompletedQuestions = true
        objSlideView.arrAllQuestions = self.arrAllQuestions
        self.navigationController?.pushViewController(objSlideView, animated: true)
    }

    @IBAction func skippedQuestionsClicked(_ sender: UIButton) {
        self.arrSkippedQuestions.sort(by: { (dic1, dic2) -> Bool in
            let questionID1 = Int((dic1["id"] as? String ?? "0")) ?? 0
            let questionID2 = Int((dic2["id"] as? String ?? "0")) ?? 0
            return questionID1 < questionID2
        })
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let objSlideView:PrakritiQuestionsViewController = storyBoard.instantiateViewController(withIdentifier: "PrakritiQuestionsViewController") as! PrakritiQuestionsViewController
        objSlideView.isTryAsGuest = self.isTryAsGuest
        objSlideView.dicAnswers = self.dicAnswers
        objSlideView.arrQuestions = self.arrSkippedQuestions
        objSlideView.arrAllQuestions = self.arrAllQuestions
        objSlideView.isCompletedQuestions = false
        objSlideView.isSkippedQuestions = true
        self.navigationController?.pushViewController(objSlideView, animated: true)
    }
  
    @objc func answerYesClicked(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let questionID = Int((arrQuestions[sender.tag]["id"] as? String ?? "0")) ?? 0
        dicAnswers[questionID] = 0
        
        if !isCompletedQuestions {
            arrCompletedQuestions.append(arrQuestions[sender.tag])
            self.updatePageNumber()
            removeFromSkipIfAnswered(questionId: questionID)
        }
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: dicAnswers)
        kUserDefaults.set(archieveData, forKey: kPrakritiAnswers)
        moveToNextAccount()
        //self.tblQuestions.reloadData()
    }
    
    @objc func answerNoClicked(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let questionID = Int((arrQuestions[sender.tag]["id"] as? String ?? "0")) ?? 0
        dicAnswers[questionID] = 1
        
        if !isCompletedQuestions {
            self.updatePageNumber()
            arrCompletedQuestions.append(arrQuestions[sender.tag])
            removeFromSkipIfAnswered(questionId: questionID)
        }
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: dicAnswers)
        kUserDefaults.set(archieveData, forKey: kPrakritiAnswers)
        moveToNextAccount()
    }
    
    @objc func answerAlwaysClicked(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let questionID = Int((arrQuestions[sender.tag]["id"] as? String ?? "0")) ?? 0
        dicAnswers[questionID] = 3
        
        if !isCompletedQuestions {
            self.updatePageNumber()
            arrCompletedQuestions.append(arrQuestions[sender.tag])
            removeFromSkipIfAnswered(questionId: questionID)
        }
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: dicAnswers)
        kUserDefaults.set(archieveData, forKey: kPrakritiAnswers)
        moveToNextAccount()
        //self.tblQuestions.reloadData()
    }
    
    @objc func answerMTTOClicked(sender: UIButton) {
     sender.isSelected = !sender.isSelected
        let questionID = Int((arrQuestions[sender.tag]["id"] as? String ?? "0")) ?? 0
        dicAnswers[questionID] = 2
        
        if !isCompletedQuestions {
            self.updatePageNumber()
            arrCompletedQuestions.append(arrQuestions[sender.tag])
            removeFromSkipIfAnswered(questionId: questionID)
        }
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: dicAnswers)
        kUserDefaults.set(archieveData, forKey: kPrakritiAnswers)
        moveToNextAccount()
      //  self.tblQuestions.reloadData()
    }
          
    func removeFromSkipIfAnswered(questionId: Int) {
        if arraySkippedQuestionsIds.contains(questionId) {
            arraySkippedQuestionsIds.remove(at: arraySkippedQuestionsIds.firstIndex(of: questionId) ?? 0)
        }
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: arraySkippedQuestionsIds)
        kUserDefaults.set(archieveData, forKey: kSkippedQuestions)
    }
    
    func moveToNextAccount() {
        self.tblQuestions.reloadData()
        self.tblQuestions.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tblQuestions.isUserInteractionEnabled = true
            guard self.currentQuestionIndex + 1 < self.arrQuestions.count else {
                return
            }
            self.currentQuestionIndex += 1
            self.updatePageNumber()
            self.tblQuestions.reloadData()
        }
    }
    
    //PREVIOUS
    @IBAction func submitClicked(_ sender: Any) {
        self.updatePageNumber()
        self.tblQuestions.reloadData()
    }
   
    @IBAction func btnPrevClicked(_ sender: Any) {
        if (currentQuestionIndex - 1) < 0 {
            return
        }
        currentQuestionIndex -= 1
       self.updatePageNumber()
       self.tblQuestions.reloadData()
    }
    
    @IBAction func btnNextClicked(_ sender: Any) {
        if !arrQuestions.indices.contains(currentQuestionIndex) {
            return
        }
        
        let questionID = Int((arrQuestions[currentQuestionIndex]["id"] as? String ?? "0")) ?? 0
        let answer = dicAnswers[questionID]
        guard answer != nil else {
            Utils.showAlertWithTitleInController("Oops!".localized(), message: "You didn't answer current question.".localized(), controller: self)
            return
        }
        
        if dicAnswers.keys.count == arrAllQuestions.count {
            calculateResult()
            return
        }
        guard currentQuestionIndex + 1 < arrQuestions.count else {
            return
        }
        currentQuestionIndex += 1
        self.updatePageNumber()
        self.tblQuestions.reloadData()
    }
    
    @IBAction func btnSkipClicked(_ sender: Any) {
        let questionID = Int((arrQuestions[currentQuestionIndex]["id"] as? String ?? "0")) ?? 0
        guard arrQuestions.count > 0 && dicAnswers[questionID] == nil else {
            return
        }
    
        skipCount += 1
        arrSkippedQuestions.append(arrQuestions[currentQuestionIndex])
       
        arraySkippedQuestionsIds.append(questionID)
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: arraySkippedQuestionsIds)
        kUserDefaults.set(archieveData, forKey: kSkippedQuestions)
        
        arrQuestions.remove(at: currentQuestionIndex)
        self.btnSkippedQuestion.setTitle(("\(arraySkippedQuestionsIds.count) " + "Questions Skipped".localized()), for: .normal)
        if arrQuestions.count == currentQuestionIndex {
            currentQuestionIndex -= 1
        }
        self.updatePageNumber()
        self.tblQuestions.reloadData()
    }
    
    func calculateResult() {
        //MARK:- 1 to 10 10 to 20 and 20 to 30
         let kaphaQuestions = Array(self.arrAllQuestions[0..<10])
               for question in kaphaQuestions {
                   let questionID = Int((question["id"] as? String ?? "0")) ?? 0
                   if let value = dicAnswers[questionID] {
                       arrAnswersKapha.append(value)
                   }
               }
               
               let pittaQuestions = Array(self.arrAllQuestions[10..<20])
               for question in pittaQuestions {
                   let questionID = Int((question["id"] as? String ?? "0")) ?? 0
                   if let value = dicAnswers[questionID] {
                       arrAnswersPitha.append(value)
                   }
               }
               
               let vataQuestions = Array(self.arrAllQuestions[20..<30])
               for question in vataQuestions {
                   let questionID = Int((question["id"] as? String ?? "0")) ?? 0
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
            
            let storyBoard = UIStoryboard(name: "PrakritiResult", bundle: nil)
            let objDescription = storyBoard.instantiateViewController(withIdentifier: "PrakritiResult") as! PrakritiResult
            objDescription.isRegisteredUser = false
            self.navigationController?.pushViewController(objDescription, animated: true)
      } else {
            postQuestionsData(value: result, answers: answers, score: result)
        }
    }
 
    func updatePageNumber() {
        self.lblCurrentPage.text = "Question".localized() + " \(currentQuestionIndex + 1)"
        self.lblTotalPage.text = "/\(arrQuestions.count)"
        self.progressBar.progress = Float(currentQuestionIndex) / Float(arrQuestions.count)
        if currentQuestionIndex + 1 == self.arrQuestions.count {
            self.btnNext.isUserInteractionEnabled = true
            self.btnNext.setTitle("SUBMIT".localized(), for: .normal)
        } else {
            let questionID = Int((arrQuestions[currentQuestionIndex]["id"] as? String ?? "0")) ?? 0
            if dicAnswers[questionID] != nil {
                self.btnNext.isUserInteractionEnabled = true
                self.btnNext.setTitle("NEXT".localized(), for: .normal)
            } else {
                self.btnNext.isUserInteractionEnabled = false
                self.btnNext.setTitle("".localized(), for: .normal)
            }
        }
        updateSectionTitleAndProgress()
    }
    
    func updateSectionTitleAndProgress() {
        var currentQuestionNumber = currentQuestionIndex
        let questionPerSection = 10
        switch currentQuestionIndex {
        case 0..<questionPerSection:
            lblSection.text = "Section".localized() + " 1"
            currentQuestionNumber = currentQuestionIndex
        case questionPerSection..<2*questionPerSection:
            lblSection.text = "Section".localized() + " 2"
            currentQuestionNumber = currentQuestionIndex%questionPerSection
        case 2*questionPerSection..<3*questionPerSection:
            lblSection.text = "Section".localized() + " 3"
            currentQuestionNumber = currentQuestionIndex%(2*questionPerSection)
        default:
            lblSection.text = "Section".localized() + " 4"
            topProgressView.progress = 0
        }
        self.lblTotalPage.text = "/\(questionPerSection)"
        topProgressView.progress = currentQuestionNumber
        self.lblCurrentPage.text = "Question".localized() + " \(currentQuestionNumber + 1)"
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
        self.btnSkippedQuestion.setTitle(("\(self.arraySkippedQuestionsIds.count) " + "Questions Skipped".localized()), for: .normal)
        self.updatePageNumber()
        self.tblQuestions.reloadData()
    }
}

extension PrakritiQuestionsViewController {
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
                    self.updateData()
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
                        if !self.isFromOnBoarding {
                            self.navigationController?.isNavigationBarHidden = false
                        }
                        //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.parakriti_prashna.rawValue)
                        let storyBoard = UIStoryboard(name: "PrakritiResult", bundle: nil)
                        let objDescription = storyBoard.instantiateViewController(withIdentifier: "PrakritiResult") as! PrakritiResult
                        objDescription.isRegisteredUser = !kSharedAppDelegate.userId.isEmpty
                        self.navigationController?.pushViewController(objDescription, animated: true)
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
    
    func clearSavedData() {
        kUserDefaults.set(nil, forKey: kPrakritiAnswers)
        kUserDefaults.set(nil, forKey: kSkippedQuestions)
    }
       
}
