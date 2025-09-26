//
//  StreakRewardVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 22/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit

class StreakRewardVC: UIViewController {
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var subtitleL: UILabel!
    @IBOutlet weak var effectIV: UIImageView!
    @IBOutlet weak var popupBGView: UIView!
    @IBOutlet weak var scratchImageView: ARScratchCardView!
    @IBOutlet weak var streakTimelineView: StreakTimelineView!
    
    var scratchCard: ARScratchCardModel?
    var timer: ARCountDownTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        effectIV.isHidden = true
        //effectIV.image = UIImage.gifImageWithName("reward-light-effect")
        popupBGView.clipsToBounds = true
        scratchImageView.delegate = self
        scratchImageView.configureCard(scratchCard: scratchCard)
        streakTimelineView.updateUI(from: kSharedAppDelegate.userStreakLevel)
        updateUI(from: kSharedAppDelegate.userStreakLevel)
        streakTimelineView.refreshUIByAPICall { userStreakLevel in
            self.updateUI(from: userStreakLevel)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer(forCount: 3)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    @IBAction func closeBtnPressed(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateUI(from userStreakLevel: ARUserStreakLevelModel?) {
        guard let userStreakLevel = userStreakLevel else { return }
        
        titleL.text = userStreakLevel.isUserOnNoRankLevel ? "You begin the streak!".localized() : "You’re doing great".localized()
        subtitleL.text = userStreakLevel.streakRewardSubtitleText
    }
}

extension StreakRewardVC: ARScratchCardViewDelegate {
    func startTimer(forCount count: Int){
        timer = ARCountDownTimer()
        timer?.startTimer(count: count, timerExpiredHandler:  {
            self.dismiss(animated: true)
        })
    }
    
    func stopTimer() {
        timer?.stopTimer()
        timer = nil
    }
    
    func scratchCardViewDidBeginScratch(view: ARScratchCardView) {
        print(">>> scratchCardViewDidBeginScratch <<")
        stopTimer()
    }
    
    func scratchCardViewDidFinishScratch(view: ARScratchCardView) {
        ScratchCardVC.updateScratchCard(scratchCard: scratchCard)
        if scratchCard?.cardTypeValue == .betterLuckNextTime {
            subtitleL.text = " "
        } else {
            subtitleL.text = ScratchCardVC.congratulationWonMessage
        }
        startTimer(forCount: 2)
    }
}

extension StreakRewardVC {
    static func showScreen(cardType: String? = nil, scratchCard: ARScratchCardModel? = nil, fromVC: UIViewController) {
        fromVC.showActivityIndicator()
        ScratchCardVC.getScratchCard(cardType: cardType) { success, status, message, scratchCard in
            if let scratchCard = scratchCard {
                fromVC.hideActivityIndicator()
                let vc = StreakRewardVC.instantiate(fromAppStoryboard: .Gamification)
                vc.scratchCard = scratchCard
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                fromVC.present(vc, animated: true, completion: nil)
            } else {
                fromVC.hideActivityIndicator()
                fromVC.showAlert(title: status, message: message)
            }
        }
    }
}
