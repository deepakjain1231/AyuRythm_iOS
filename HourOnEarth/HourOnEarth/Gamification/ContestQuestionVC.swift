//
//  ContestQuestionVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 29/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class ContestQuestionVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionL: UILabel!
    @IBOutlet weak var questionCountL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var wrongQuestionsBtn: UIButton!
    @IBOutlet weak var rightQuestionsBtn: UIButton!
    @IBOutlet weak var topOrangeView: UIView!
    
    var questions = [ARContestQuestionModel]()
    var currentQuestionIndex = 0
    var currentQuestion: ARContestQuestionModel?
    var contest: ARContestModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contests".localized()
        let customBackBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ic-back-arrow"), title: "Back".localized(), target: self, action: #selector(backBtnPressed))
        //self.navigationController?.navigationBar.topItem?.backBarButtonItem = backBtn
        self.navigationItem.leftBarButtonItem = customBackBtn
        //Temo Comment//MoEngageHelper.shared.trackEvent(name: event.play_contest.rawValue)
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topOrangeView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 26)
    }
    
    func setupUI() {
        tableView.register(nibWithCellClass: ContestQuestionCell.self)
        showNextQuestion()
        nextBtn.isHidden = true
        //nextBtn.fadeOut(duration: 0)
    }
    
    @objc func backBtnPressed() {
        Utils.showAlertWithTitleInControllerWithCompletion("Do you really want to leave this contest?".localized(), message: "Your progress will be reset, and you have to start this contest from beginning".localized(), cancelTitle: "Resume".localized(), okTitle: "Leave".localized(), controller: self, completionHandler: { [weak self] in
            //leave contest
            self?.navigationController?.popViewController(animated: true)
        }) {
            //resume contest
        }
    }
    
    @IBAction func nextBtnPressed(sender: UIButton) {
        showNextQuestion()
    }
    
    func showNextQuestion() {
        currentQuestion = questions[safe: currentQuestionIndex]
        if let question = currentQuestion {
            questionCountL.text = "Question".localized() + " \(currentQuestionIndex + 1)/\(questions.count)"
            questionL.text = question.question
            currentQuestionIndex += 1
            tableView.allowsSelection = true
            tableView.reloadData()
            nextBtn.fadeOut()
        } else {
            //end of questions
            submitAnswersAndShowNextScreen()
        }
    }
    
    func updateUI(for option: ARContestQuestionOptionModel?) {
        guard let option = option else {
            print("selected option is nil !!!!")
            return
        }
        
        currentQuestion?.selectedOption = option.option
        let answerGivenQuestions = questions.filter{ $0.selectedOption != nil }
        let rightAnswers = answerGivenQuestions.filter{ $0.isCurrectAnswer }.count
        let wrongAnswers = answerGivenQuestions.count - rightAnswers
        rightQuestionsBtn.setTitle(rightAnswers.twoDigitStringValue, for: .normal)
        wrongQuestionsBtn.setTitle(wrongAnswers.twoDigitStringValue, for: .normal)
        tableView.reloadData()
        nextBtn.fadeIn()
    }
}

extension ContestQuestionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQuestion?.options.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ContestQuestionCell.self, for: indexPath)
        cell.question = currentQuestion
        cell.option = currentQuestion?.options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateUI(for: currentQuestion?.options[indexPath.row])
        tableView.allowsSelection = false
    }
}

extension ContestQuestionVC {
    func submitAnswersAndShowNextScreen() {
        showActivityIndicator()
        let questionAnswers = questions.compactMap{ [$0.id! : $0.selectedOption ?? ""] }
        let params = ["language_id" : Utils.getLanguageId(), "contest_id": contest?.id ?? "", "answers": questionAnswers.jsonStringRepresentation ?? "", "rowid": contest?.rowID ?? 0] as [String : Any]
        Utils.doAPICall(endPoint: .getContestSubmission, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
            if isSuccess, let dataJSON = responseJSON?["data"] {
                let result = ARContestResultModel(fromJson: dataJSON)
                self.hideActivityIndicator()
                let vc = ContestScoreVC.instantiate(fromAppStoryboard: .Gamification)
                vc.contestResult = result
                vc.contest = self.contest
                vc.contestTotalScore = self.questions.reduce(0, {$0 + $1.reward})
                NotificationCenter.default.post(name: .refreshContestList, object: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.hideActivityIndicator()
                self.showAlert(title: status, message: message)
            }
        }
    }
}

extension ContestQuestionVC {
    static func showScreen(contest: ARContestModel?, requiredAyuseeds: Int = 0, from fromVC: UIViewController) {
        guard let contest = contest else {
            return
        }

        fromVC.showActivityIndicator()
        let params = ["language_id" : Utils.getLanguageId(), "contest_id": contest.id!, "ayuseeds": requiredAyuseeds] as [String : Any]
        Utils.doAPICall(endPoint: .getUserContestQuestions, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
            if isSuccess {
                let questions = responseJSON?["Questions"]["questions"].array?.compactMap{ ARContestQuestionModel(fromJson: $0) } ?? []
                let rowID = responseJSON?["row id"].intValue ?? 0
                contest.rowID = rowID
                fromVC.hideActivityIndicator()
                if !questions.isEmpty {
                    let vc = ContestQuestionVC.instantiate(fromAppStoryboard: .Gamification)
                    vc.questions = questions
                    vc.contest = contest
                    fromVC.navigationController?.pushViewController(vc, animated: true)
                } else {
                    fromVC.showErrorAlert(message: "No questions found in this contest".localized())
                }
            } else {
                fromVC.hideActivityIndicator()
                fromVC.showAlert(title: status, message: message)
            }
        }
    }
}

extension ContestQuestionVC {
    static func checkContestUserStatusAndShowContest(contest: ARContestModel?, from fromVC: UIViewController) {
        fromVC.showActivityIndicator()
        let params = ["language_id" : Utils.getLanguageId(), "contest_id": contest?.id ?? ""] as [String : Any]
        Utils.doAPICall(endPoint: .getContestUserStatus, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess {
                //let message = responseJSON?["Message"].stringValue
                var ayuseeds = responseJSON?["Ayuseeds"].int
                ayuseeds = ayuseeds == nil ? responseJSON?["ayuseeds"].int : ayuseeds
                fromVC.hideActivityIndicator()
                if let ayuseeds = ayuseeds, ayuseeds > 0 {
                    //you need extra ayuseed to start contest
                    let message = String(format: "Your points will be reset.\nRedeem %d AyuSeeds to continue\nOr\nCome tomorrow and play for free".localized(), ayuseeds)
                    ContestScoreVC.showPlayAgainAlert(message: message, fromVC: fromVC) {
                        //play again
                        Self.showScreen(contest: contest, requiredAyuseeds: ayuseeds, from: fromVC)
                    } cancelHandler: {
                        //cancel
                    }
                } else {
                    //free to enter contest
                    Self.showScreen(contest: contest, requiredAyuseeds: ayuseeds ?? 0, from: fromVC)
                }
            } else {
                fromVC.hideActivityIndicator()
                fromVC.showAlert(title: status, message: message)
            }
        }
    }
}
