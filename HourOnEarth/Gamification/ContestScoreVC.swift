//
//  ContestScoreVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 29/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class ContestScoreVC: UIViewController {
    
    @IBOutlet weak var scoreL: UILabel!
    @IBOutlet weak var wrongCountBtn: UIButton!
    @IBOutlet weak var corretCountBtn: UIButton!
    @IBOutlet weak var completionBtn: UIButton!
    @IBOutlet weak var totalQuestionBtn: UIButton!
    @IBOutlet weak var topOrangeView: UIView!
    @IBOutlet weak var luckDrawInfoStackView: UIStackView!
    
    var contest: ARContestModel?
    var contestResult: ARContestResultModel?
    var contestTotalScore = 0
    var isScratchCardGiven = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Score".localized()
        setBackButtonTitle()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topOrangeView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 26)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //remove contest screen from stack
        if let navVC = self.navigationController {
            var vcs = navVC.viewControllers
            if let contestVCIndex = vcs.firstIndex(where: { $0.isKind(of: ContestQuestionVC.self) }) {
                vcs.remove(safeAt: contestVCIndex)
                navVC.viewControllers = vcs
                setBackButtonTitle()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isScratchCardGiven, let contestResult = contestResult, contestResult.resultPercentage >= 60 {
            //give scratch card to user
            ScratchCardVC.showScreen(cardType: "contest", fromVC: self)
            isScratchCardGiven = true
        }
    }
    
    func setupUI() {
        guard let contestResult = contestResult else {
            return
        }

        scoreL.text = contestResult.points.stringValue
        wrongCountBtn.setTitle(contestResult.wrongCount.stringValue, for: .normal)
        corretCountBtn.setTitle(contestResult.correctCount.stringValue, for: .normal)
        completionBtn.setTitle(contestTotalScore.stringValue, for: .normal)
        totalQuestionBtn.setTitle(contestResult.totalQuestion.stringValue, for: .normal)
        luckDrawInfoStackView.isHidden = (contestResult.resultPercentage != 100)
    }
    
    @IBAction func leaderBoardBtnPressed(sender: UIButton) {
        ContestLeaderBoardVC.showScreen(contest: contest, from: self)
    }
    
    @IBAction func shareResultBtnPressed(sender: UIButton) {
        let shareAll = [ Utils.shareContestDownloadString ] as [Any]

        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func homeBtnPressed(sender: UIButton) {
        if let navVC = self.navigationController {
            let vcs = navVC.viewControllers
            if let vc = vcs.first(where: { $0.isKind(of: ContestListVC.self) }) {
                navVC.popToViewController(vc, animated: true)
            } else if let vc = vcs.first(where: { $0.isKind(of: EarnAyuseedVC.self) }) {
                navVC.popToViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func playAgainBtnPressed(sender: UIButton) {
        ContestQuestionVC.checkContestUserStatusAndShowContest(contest: self.contest, from: self)
    }
}

extension ContestScoreVC {
    static func showPlayAgainAlert(title: String? = nil, message: String, fromVC vc: UIViewController, playAgainHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) {
        let title = (title != nil) ? title : "Do you really want to start over this contest?".localized()
        
        Utils.showAlertWithTitleInControllerWithCompletion(title, message: message, cancelTitle: "Cancel".localized(), okTitle: "Play again".localized(), controller: vc, completionHandler: playAgainHandler, completionHandlerCancel: cancelHandler)
    }
}
