//
//  ContestHomeVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 29/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class ContestHomeVC: BaseViewController {
    
    @IBOutlet weak var contestNameL: UILabel!
    @IBOutlet weak var contestSubtitleL: UILabel!
    @IBOutlet weak var dayL: UILabel!
    @IBOutlet weak var hourL: UILabel!
    @IBOutlet weak var minutesL: UILabel!
    @IBOutlet weak var secondL: UILabel!
    @IBOutlet weak var contestRewardL: UILabel!
    @IBOutlet weak var timerTitleL: UILabel!
    @IBOutlet weak var checkWinnerL: UILabel!
    @IBOutlet weak var topOrangeView: UIView!
    @IBOutlet weak var timerStackView: UIStackView!
    @IBOutlet weak var bottomBtnsView: UIView!
    @IBOutlet weak var enterBtn: UIButton!
    
    var countdownTimer: Timer?
    var nextContestDate: Date? = Date().addingTimeInterval(2*24*60*60)
    var contest: ARContestModel?
    var serverDateTime = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contests".localized()
        setBackButtonTitle()
        let rulesBtn = UIBarButtonItem(title: "Rules".localized(), style: .plain, target: self, action: #selector(showContestRulesScreen(_:)))
        self.navigationItem.rightBarButtonItem = rulesBtn
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topOrangeView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 26)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getContestLatestDetails()
    }
    
    func setupUI() {
        guard let contest = contest else {
            return
        }

        contestNameL.text = contest.name
        contestSubtitleL.text = contest.subtitle
        checkWinnerL.text = String(format: "Check winners on %@".localized(), contest.contestCheckWinnerDate.dateStringEnglishLocale(format: "dd-MMM-yyyy"))
        contestRewardL.setHtmlText(text: contest.descriptionHtml)
        serverDateTime = contest.serverDateTime
        let todayDate = contest.serverDateTime
        timerStackView.isHidden = true
        bottomBtnsView.isHidden = false
        enterBtn.isHidden = true
        if contest.contestStartDate > todayDate {
            timerTitleL.text = "COMING SOON".localized()
            nextContestDate = contest.contestStartDate
            startNextContestTimer()
            timerStackView.isHidden = false
            bottomBtnsView.isHidden = true
        } else {
            if contest.contestEndDate > todayDate {
                timerTitleL.text = "ENDING".localized()
                nextContestDate = contest.contestEndDate
                let diffDateHours = Calendar.current.dateComponents([.hour], from: todayDate, to: contest.contestEndDate).hour ?? 0
                if diffDateHours <= 24 {
                    timerTitleL.text = "ENDING SOON".localized()
                }
                startNextContestTimer()
                timerStackView.isHidden = false
                enterBtn.isHidden = false
            } else {
                timerTitleL.text = "CONTEST EXPIRED".localized()
                nextContestDate = todayDate
            }
        }
    }
    
    @IBAction func checkLeaderBoardBtnPressed(sender: UIButton) {
        ContestLeaderBoardVC.showScreen(contest: contest, isFromContestHomeScreen: true, from: self)
    }
    
    @IBAction func enterBtnPressed(sender: UIButton) {
        ContestQuestionVC.checkContestUserStatusAndShowContest(contest: contest, from: self)
    }
}

extension ContestHomeVC {
    func startNextContestTimer() {
        stopNextPostTimer()
        updateNextContestCountDownTime()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateNextContestCountDownTime), userInfo: nil, repeats: true)
    }
    
    func stopNextPostTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    @objc func updateNextContestCountDownTime() {
        guard let nextContestDate = nextContestDate else {
            print(" nextPostDate = nil")
            stopNextPostTimer()
            return
        }
        
        let currentDate = Date()/*.addingTimeInterval(-serverDateTime.timeIntervalSinceNow)*/
        let diffDateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: currentDate, to: nextContestDate)
        
        if nextContestDate <= currentDate {
            timerCompleted()
        } else {
            let hours = diffDateComponents.hour ?? 0
            dayL.text = (hours/24).twoDigitStringValue
            hourL.text = (hours%24).twoDigitStringValue
            minutesL.text = (diffDateComponents.minute ?? 0).twoDigitStringValue
            secondL.text = (diffDateComponents.second ?? 0).twoDigitStringValue
        }
    }
    
    func timerCompleted() {
        stopNextPostTimer()
        dayL.text = "00"
        hourL.text = "00"
        minutesL.text = "00"
        secondL.text = "00"
        //setupUI()
        getContestLatestDetails()
    }
}

extension ContestHomeVC {
    func getContestLatestDetails() {
        showActivityIndicator()
        let params = ["language_id" : Utils.getLanguageId(), "contest_id": contest?.id ?? ""] as [String : Any]
        Utils.doAPICall(endPoint: .getContestDetails, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
            if isSuccess, let dataJSON = responseJSON?["contest_description"] {
                let contest = ARContestModel(fromJson: dataJSON)
                self.contest = contest
                self.setupUI()
                self.hideActivityIndicator()
            } else {
                self.hideActivityIndicator()
                self.showAlert(title: status, message: message)
            }
        }
    }
    
    static func showScreen(contest: ARContestModel, fromVC: UIViewController) {
        if contest.isWinnerDeclared {
            let vc = ContestWinnerVC.instantiate(fromAppStoryboard: .Gamification)
            vc.contest = contest
            fromVC.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = ContestHomeVC.instantiate(fromAppStoryboard: .Gamification)
            vc.contest = contest
            fromVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func showContestRulesScreen(_ sender: UIBarButtonItem) {
        let vc = ContestRulesVC.instantiate(fromAppStoryboard: .Gamification)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
