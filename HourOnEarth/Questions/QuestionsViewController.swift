//
//  QuestionsViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 5/25/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class QuestionsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tblQuestions: UITableView!
    @IBOutlet weak var lblCurrentPage: UILabel!
    @IBOutlet weak var lblTotalPage: UILabel!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var topProgressView: CustomProgressView!
    @IBOutlet weak var lblSection: UILabel!
    
    var arrQuestions: [[String: Any]] = [[String: Any]]()
    var dicAnswers:[Int: String] = [Int: String]()
    
    var currentPage = 0
    var currentQuestionsAnswered = 0
    var isFromOnBoarding = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblQuestions.register(UINib(nibName: "PrakritiCell", bundle: nil), forCellReuseIdentifier: "PrakritiCell")
        self.navigationController?.isNavigationBarHidden = true
        self.tblQuestions.estimatedRowHeight = 160.0
        self.tblQuestions.rowHeight = UITableView.automaticDimension
        self.getQuestionsFromServer()
        
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
        if !isFromOnBoarding {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableView Delegates and Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrQuestions.count == 0 {
            return 0
        }
        if (self.arrQuestions.count - currentPage) < 1 {
            return (self.arrQuestions.count - currentPage)
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PrakritiCell = tableView.dequeueReusableCell(withIdentifier: "PrakritiCell") as! PrakritiCell
        cell.lblQuestion.text = (arrQuestions[currentPage  + indexPath.row]["question"] as? String ?? "")
        cell.lblAnswer1.text = " " + (arrQuestions[currentPage + indexPath.row]["kapha"] as? String ?? "")
        cell.btnAnswer1.addTarget(self, action: #selector(QuestionsViewController.answerKaphClicked(sender:)), for: .touchUpInside)
        cell.btnAnswer1.tag = indexPath.row
        
        cell.lblAnswer2.text =  " " + (arrQuestions[currentPage + indexPath.row]["pitta"] as? String ?? "")
        cell.btnAnswer2.addTarget(self, action: #selector(QuestionsViewController.answerPittaClicked(sender:)), for: .touchUpInside)
        cell.btnAnswer2.tag = indexPath.row
        
        var strAns3 = (arrQuestions[currentPage + indexPath.row]["vata"] as? String ?? "")
        if strAns3 == "" {
            strAns3 = (arrQuestions[currentPage + indexPath.row]["vatta"] as? String ?? "")
        }
        cell.lblAnswer3.text = " " + strAns3
        cell.btnAnswer3.addTarget(self, action: #selector(QuestionsViewController.answerVataClicked(sender:)), for: .touchUpInside)
        cell.btnAnswer3.tag = indexPath.row
        
        cell.btnAnswer4.isHidden = true
        cell.lblAnswer4.isHidden = true
        cell.viewAnswer4.isHidden = true
        
        cell.btnAnswer2.isSelected = false
        cell.btnAnswer1.isSelected = false
        cell.btnAnswer3.isSelected = false
        cell.btnAnswer4.isSelected = false
        
        let defaultBGClor = UIColor.white.withAlphaComponent(0.3)
        cell.btnAnswer2.backgroundColor = defaultBGClor
        cell.btnAnswer1.backgroundColor = defaultBGClor
        cell.btnAnswer3.backgroundColor = defaultBGClor
        cell.btnAnswer4.backgroundColor = defaultBGClor
        
        guard let questionId = Int(arrQuestions[currentPage]["id"] as? String ?? "0") else {
            return UITableViewCell()
        }
        
        switch dicAnswers[questionId] {
        case "Kapha":
            cell.btnAnswer1.isSelected = true
            cell.btnAnswer1.backgroundColor = kAppGreenD2Color
        case "Pitta":
            cell.btnAnswer2.isSelected = true
            cell.btnAnswer2.backgroundColor = kAppGreenD2Color
        case "Vata":
            cell.btnAnswer3.isSelected = true
            cell.btnAnswer3.backgroundColor = kAppGreenD2Color
        default:
            break
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    //MARK: IBActions
    @objc func answerKaphClicked(sender: UIButton) {
        let questionID = Int((arrQuestions[currentPage]["id"] as? String ?? "0")) ?? 0
        dicAnswers[questionID] = "Kapha"
        moveToNextAccount()
    }
    
    @objc func answerPittaClicked(sender: UIButton) {
        let questionID = Int((arrQuestions[currentPage]["id"] as? String ?? "0")) ?? 0
        dicAnswers[questionID] = "Pitta"
        moveToNextAccount()
    }
    
    @objc func answerVataClicked(sender: UIButton) {
        let questionID = Int((arrQuestions[currentPage]["id"] as? String ?? "0")) ?? 0
        dicAnswers[questionID] = "Vata"
        moveToNextAccount()
    }
    
    
    func moveToNextAccount() {
        self.tblQuestions.reloadData()
        self.tblQuestions.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tblQuestions.isUserInteractionEnabled = true
            guard self.currentPage + 1 < self.arrQuestions.count else {
                return
            }
            self.currentPage += 1
            self.updatePageNumber()
            self.tblQuestions.reloadData()
        }
    }
    
    @IBAction func previousClicked(_ sender: Any) {
        if (currentPage - 1) < 0 {
            return
        }
        currentPage -= 1
        currentQuestionsAnswered = 0
        self.updatePageNumber()
        self.tblQuestions.reloadData()
    }
    
    @IBAction func pauseClicked(_ sender: UIButton) {
        let archieveData = NSKeyedArchiver.archivedData(withRootObject: self.dicAnswers)
        kUserDefaults.set(archieveData, forKey: PRASHNA_VIKRITI_ANSWERS)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNextClicked(_ sender: Any) {
        if !arrQuestions.indices.contains(currentPage) {
            return
        }
        
        let questionID = Int((arrQuestions[currentPage]["id"] as? String ?? "0")) ?? 0
        let answer = dicAnswers[questionID]
        guard answer != nil else {
            Utils.showAlertWithTitleInController("Oops!", message: "You didn't answer current question.".localized(), controller: self)
            return
        }
        
        if dicAnswers.keys.count == arrQuestions.count {
            checkDataFrom()
            return
        }
        guard currentPage + 1 < arrQuestions.count else {
            return
        }
        currentPage += 1
        self.updatePageNumber()
        self.tblQuestions.reloadData()
    }
    
    func checkDataFrom() {
        
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
            kSharedAppDelegate.showHomeScreen()
        }
        postQuestionsData(value: result, score: result, prashnaAnswers: resultSpar)
    }
    
    func updatePageNumber() {
        self.lblTotalPage.text = "/\(arrQuestions.count)"
        self.progressBar.progress = Float(currentPage) / Float(arrQuestions.count)
        if (self.arrQuestions.count - currentPage) < 1 {
            self.lblCurrentPage.text = "Question".localized() + " \(currentPage + (self.arrQuestions.count - currentPage))"
        } else {
            self.lblCurrentPage.text = "Question".localized() + " \((currentPage + 1))"
        }
        
        self.btnPrevious.isHidden = false
        
        if currentPage + 1 == self.arrQuestions.count {
            self.btnNext.isUserInteractionEnabled = true
            self.btnNext.setTitle("SUBMIT".localized(), for: .normal)
        } else {
            //self.btnNext.setTitle("NEXT".localized(), for: .normal)
            let questionID = Int((arrQuestions[currentPage]["id"] as? String ?? "0")) ?? 0
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
        var currentQuestionNumber = currentPage
        let questionPerSection = 7
        switch currentPage {
        case 0..<questionPerSection:
            lblSection.text = "Section".localized() + " 1"
            currentQuestionNumber = currentPage
        case questionPerSection..<2*questionPerSection:
            lblSection.text = "Section".localized() + " 2"
            currentQuestionNumber = currentPage%questionPerSection
        case 2*questionPerSection..<3*questionPerSection:
            lblSection.text = "Section".localized() + " 3"
            currentQuestionNumber = currentPage%(2*questionPerSection)
        default:
            lblSection.text = "Section".localized() + " 4"
            topProgressView.progress = 0
        }
        self.lblTotalPage.text = "/\(questionPerSection)"
        topProgressView.progress = currentQuestionNumber
        self.lblCurrentPage.text = "Question".localized() + " \(currentQuestionNumber + 1)"
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
            self.currentPage = (totalAnswers == arrQuestions.count) ? totalAnswers - 1 : totalAnswers
        }
        self.updatePageNumber()
        self.tblQuestions.reloadData()
    }
}

extension QuestionsViewController {
    func getQuestionsFromServer () {
        if Utils.isConnectedToNetwork() {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            let urlString = kBaseNewURL + endPoint.v2.prashnaVikriti.rawValue
            let params = ["type": "prashna", "language_id" : Utils.getLanguageId()] as [String : Any]
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                    
                case .success(let value):
                    print(response)
                    guard let arrQuestions = (value as? [[String: Any]]) else {
                        
                        return
                    }
                    self.arrQuestions = arrQuestions
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
        }else {
            //Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
            Utils.showAlertWithTitleInControllerWithCompletion(APP_NAME, message: NO_NETWORK, okTitle: "Ok".localized(), controller: self) {
                self.navigationController?.popViewController(animated: true)
            }
        }
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
                        self.clearSavedData()
                        //self.navigationController?.popToRootViewController(animated: true)
                        self.addEarnHistoryFromServer()
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
    
    func clearSavedData() {
        kUserDefaults.set(nil, forKey: PRASHNA_VIKRITI_ANSWERS)
    }
}

extension QuestionsViewController {
    func addEarnHistoryFromServer() {
        let params = ["activity_favorite_id": AyuSeedEarnActivity.vikritiPrashna.rawValue, "language_id": Utils.getLanguageId()] as [String : Any]
        ReferPopupViewController.addEarmHistoryFromServer(params: params) { (isSuccess, title, message) in
            print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
            self.hideActivityIndicator()
            if isSuccess {
                Utils.showAlertWithTitleInControllerWithCompletion(title, message: message, okTitle: "Ok", controller: self) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}

extension QuestionsViewController {
    static func showScreen(fromVC: UIViewController) {
        Utils.showAlertWithTitleInControllerWithCompletion("INSTRUCTIONS", message: "Take a deep breath and be patient. We hate to take you through these many questions but we would like to ascertain that we have every detail of your body’s dosha assessed, so that better lifestyle suggestion for wellness, disease prevention, long life and recovery from any ailment, can be presented to you, tailored! We would like to be precise, when it comes to your health assessment!".localized(), okTitle: "Ok".localized(), controller: fromVC) {
            let objSlideView = QuestionsViewController.instantiate(fromAppStoryboard: .Home)
            fromVC.navigationController?.pushViewController(objSlideView, animated: true)
        }
    }
}
