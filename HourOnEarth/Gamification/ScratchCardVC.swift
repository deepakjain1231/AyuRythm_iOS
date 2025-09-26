//
//  ScratchCardVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 18/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

protocol delegateConfirmation {
    func afterscretchScreenClose(_ success: Bool)
}


import UIKit

class ScratchCardVC: UIViewController {
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var subtitleL: UILabel!
    @IBOutlet weak var effectIV: UIImageView!
    @IBOutlet weak var afterCardScratchEffectIV: UIImageView!
    @IBOutlet weak var scratchImageView: ARScratchCardView!
    
    var delegate: delegateConfirmation?
    var scratchCard: ARScratchCardModel?
    var timer: ARCountDownTimer?
    var isAutodismissCard = false
    static let congratulationWonMessage = "Great! you’ve won AyuSeeds".localized()

    override func viewDidLoad() {
        super.viewDidLoad()
        //effectIV.isHidden = true
        effectIV.image = UIImage.gifImageWithName("reward-light-effect")
        afterCardScratchEffectIV.isHidden = true
        afterCardScratchEffectIV.image = UIImage.gifImageWithName("confetti")
        scratchImageView.delegate = self
        scratchImageView.configureCard(scratchCard: scratchCard)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isAutodismissCard {
            startTimer(forCount: 3)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    deinit {
        print(">>> ScratchCardVC deinit ")
    }
    
    @IBAction func closeBtnPressed(sender: UIButton) {
        self.delegate?.afterscretchScreenClose(true)
        dismiss(animated: true, completion: nil)
    }
}

extension ScratchCardVC: ARScratchCardViewDelegate {
    func startTimer(forCount count: Int){
        timer = ARCountDownTimer()
        timer?.startTimer(count: count, timerExpiredHandler:  {
            self.delegate?.afterscretchScreenClose(true)
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
        titleL.text = " "
        if scratchCard?.cardTypeValue == .betterLuckNextTime {
            subtitleL.text = " "
            effectIV.fadeOut(duration: 0.36)
        } else {
            effectIV.fadeOut(duration: 0.36) { success in
                self.afterCardScratchEffectIV.fadeIn()
            }
            subtitleL.isHidden = false
            subtitleL.text = ScratchCardVC.congratulationWonMessage
        }
        startTimer(forCount: 2)
    }
}

extension ScratchCardVC {
    static func showScreenFromRewardList(scratchCard: ARScratchCardModel, fromVC: UIViewController) {
        if !scratchCard.isClaimed && !scratchCard.isExpired {
            Self.showScreen(scratchCard: scratchCard, fromVC: fromVC)
        } else if scratchCard.cardTypeValue != .ayuseeds {
            let vc = StreakLevelDetailVC.instantiate(fromAppStoryboard: .Gamification)
            vc.scratchCardReward = scratchCard
            fromVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    static func showScreen(cardType: String? = nil, scratchCard: ARScratchCardModel? = nil, fromVC: UIViewController) {
        if let scratchCard = scratchCard {
            let vc = ScratchCardVC.instantiate(fromAppStoryboard: .Gamification)
            vc.scratchCard = scratchCard
            vc.delegate = fromVC as? delegateConfirmation
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            fromVC.present(vc, animated: true, completion: nil)
            return
        }
        
        fromVC.showActivityIndicator()
        Self.getScratchCard(cardType: cardType) { success, status, message, scratchCard in
            if let scratchCard = scratchCard {
                fromVC.hideActivityIndicator()
                let vc = ScratchCardVC.instantiate(fromAppStoryboard: .Gamification)
                vc.scratchCard = scratchCard
                vc.isAutodismissCard = true
                vc.delegate = fromVC as? delegateConfirmation
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

extension ScratchCardVC {
    static func getScratchCard(cardType: String? = nil, completion: ((Bool, String, String, ARScratchCardModel?) -> Void)? = nil ) {
        let isTryAsGuest = kSharedAppDelegate.userId.isEmpty
        let endPoint = isTryAsGuest ? endPoint.getScratchCardWithoutRegistration : endPoint.getScratchCard
        let params = ["language_id" : Utils.getLanguageId(), "type": cardType ?? ""] as [String: Any]
        Utils.doAPICall(endPoint: endPoint, parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let card = ARScratchCardModel(fromJson: responseJSON["data"])
                if isTryAsGuest {
                    //store this scratch card for later update when user complete registration
                    let cardDetail = ["scratchid":card.scratchid, "id":card.id, "date":card.createdAt, "status": "0"] //status 0 means not opened card
                    var storedScartchCards = kUserDefaults.storedScratchCards
                    storedScartchCards[card.scratchid] = cardDetail
                    kUserDefaults.storedScratchCards = storedScartchCards
                }
                completion?(isSuccess, status, message, card)
            } else {
                completion?(isSuccess, status, message, nil)
            }
        }
    }
    
    static func updateScratchCard(scratchCard: ARScratchCardModel?, completion: ((Bool, String, String) -> Void)? = nil ) {
        let isTryAsGuest = kSharedAppDelegate.userId.isEmpty
        if isTryAsGuest, let scratchID = scratchCard?.scratchid {
            //store this scratch card for later update when user complete registration
            var storedScartchCards = kUserDefaults.storedScratchCards
            if var cardDetail = storedScartchCards[scratchID] as? [String: Any] {
                cardDetail["status"] = "1" //1 means card opened
                storedScartchCards[scratchID] = cardDetail
                kUserDefaults.storedScratchCards = storedScartchCards
            }
            return
        }
        
        let scratchCardId = scratchCard?.scratchid ?? "0"
        let params = ["language_id" : Utils.getLanguageId(), "scratch_id": scratchCardId] as [String: Any]
        Utils.doAPICall(endPoint: .updateMyScratchCard
                        , parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess {
                NotificationCenter.default.post(name: .refreshScratchCardList, object: ["scratch_id": scratchCardId])
                completion?(isSuccess, status, message)
            } else {
                completion?(isSuccess, status, message)
            }
        }
    }
    
    static func updateStoredScratchCardOnServer(completion: ((Bool, String, String) -> Void)? = nil ) {
        let storedScartchCards = kUserDefaults.storedScratchCards.map{ $0.value } as? [[String: Any]] ?? []
        let storedScartchCardsStr = storedScartchCards.jsonStringRepresentation ?? ""
        let params = ["language_id" : Utils.getLanguageId(), "scratchcards": storedScartchCardsStr] as [String: Any]
        Utils.doAPICall(endPoint: .getScratchCardUpdate
                        , parameters: params, headers: Utils.apiCallHeaders) { isSuccess, status, message, responseJSON in
            if isSuccess {
                kUserDefaults.storedScratchCards = [:]
                completion?(isSuccess, status, message)
            } else {
                completion?(isSuccess, status, message)
            }
        }
    }
}
