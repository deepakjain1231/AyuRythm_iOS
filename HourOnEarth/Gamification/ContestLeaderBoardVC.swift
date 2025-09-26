//
//  ContestLeaderBoardVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 08/12/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import AlamofireImage

class ContestLeaderBoardVC: UIViewController {

    @IBOutlet weak var contestNameL: UILabel!
    @IBOutlet weak var firstContesterView: ARTopContesterView!
    @IBOutlet weak var secondContesterView: ARTopContesterView!
    @IBOutlet weak var secondContesterSeperatorView: UIView!
    @IBOutlet weak var thirdContesterView: ARTopContesterView!
    @IBOutlet weak var thirdContesterSeperatorView: UIView!
    @IBOutlet weak var myRankView: ARTopContesterView!
    @IBOutlet weak var myRankContentView: UIView!
    @IBOutlet weak var myRankSeperatorView: DashedLineView!
    @IBOutlet weak var playNowBtn: UIButton!
    @IBOutlet weak var totalContestersL: UILabel!
    
    var contesters = [ARContestLeaderModel]()
    var myRank: ARContestLeaderModel?
    var contest: ARContestModel?
    var totalContesters = 0
    var isFromContestHomeScreen = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Leaderboard".localized()
        setBackButtonTitle()
        setupUI()
    }
    
    func setupUI() {
        myRankSeperatorView.perDashLength = 10
        myRankSeperatorView.spaceBetweenDash = 8
        updateUIForTopContesters()
    }
    
    func updateUIForTopContesters() {
        
        contestNameL.text = contest?.name
        var attrText = NSAttributedString(string: "Total participants : ".localized())
        attrText += NSAttributedString(string: totalContesters.stringValue, attributes: [.foregroundColor: UIColor.fromHex(hexString: "#387BFF"), .font : UIFont.systemFont(ofSize: totalContestersL.font.pointSize, weight: .semibold)])
        totalContestersL.attributedText = attrText
        if let firstContester = contesters[safe: 0] {
            firstContesterView.updateUI(for: firstContester)
        } else {
            firstContesterView.isHidden = true
        }
        if let secondContester = contesters[safe: 1] {
            secondContesterView.updateUI(for: secondContester)
        } else {
            secondContesterSeperatorView.isHidden = true
            secondContesterView.isHidden = true
        }
        if let thirdContester = contesters[safe: 2] {
            thirdContesterView.updateUI(for: thirdContester)
        } else {
            thirdContesterView.isHidden = true
            thirdContesterView.isHidden = true
        }
        
        if let myRank = myRank, myRank.rank.intValue > 3 {
            myRankView.updateUI(for: myRank)
        } else {
            myRankSeperatorView.isHidden = true
            myRankView.isHidden = true
        }
        if let myRank = myRank {
            playNowBtn.setTitle("Play Again".localized(), for: .normal)
        } else {
            playNowBtn.setTitle(isFromContestHomeScreen ? "Play Now".localized() : "Play Again".localized(), for: .normal)
        }
        playNowBtn.isHidden = (contest?.isContestExpired ?? false)
    }
    
    @IBAction func playNowBtnPressed(sender: UIButton) {
        if isFromContestHomeScreen {
            self.navigationController?.popViewController(animated: true)
            //ContestQuestionVC.checkContestUserStatusAndShowContest(contest: contest, from: self)
        } else {
            if let navVC = self.navigationController {
                if let vc = navVC.viewControllers.first(where: { $0.isKind(of: ContestHomeVC.self) }) {
                    navVC.popToViewController(vc, animated: true)
                }
            }
            /*ContestScoreVC.showPlayAgainAlert(fromVC: self) {
                //play again
                /*if let navVC = self.navigationController {
                    let vcs = navVC.viewControllers
                    if let vc = vcs.first(where: { $0.isKind(of: ContestHomeVC.self) }) {
                        navVC.popToViewController(vc, animated: true)
                    }
                }*/
                ContestQuestionVC.showScreen(contest: self.contest, from: self)
            } cancelHandler: {
                //cancel
            }*/
            //ContestQuestionVC.checkContestUserStatusAndShowContest(contest: self.contest, from: self)
        }
    }
    
    @IBAction func exploreOherContentsBtnPressed(sender: UIButton) {
        if let navVC = self.navigationController {
            let vcs = navVC.viewControllers
            if let vc = vcs.first(where: { $0.isKind(of: ContestListVC.self) }) {
                navVC.popToViewController(vc, animated: true)
            } else if let vc = vcs.first(where: { $0.isKind(of: EarnAyuseedVC.self) }) {
                navVC.popToViewController(vc, animated: true)
            }
        }
    }
}

extension ContestLeaderBoardVC {
    static func showSrceenFrom(isFromContestHomeScreen: Bool = false, vc fromVC: UIViewController) {
        let vc = ContestLeaderBoardVC.instantiate(fromAppStoryboard: .Gamification)
        vc.isFromContestHomeScreen = isFromContestHomeScreen
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func showScreen(contest: ARContestModel?, isFromContestHomeScreen: Bool = false, from fromVC: UIViewController) {
        guard let contest = contest else {
            return
        }

        fromVC.showActivityIndicator()
        let params = ["language_id" : Utils.getLanguageId(), "contest_id": contest.id!] as [String : Any]
        Utils.doAPICall(endPoint: .getcontestLeaderboard, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let contesters = responseJSON["data"].array?.compactMap{ ARContestLeaderModel(fromJson: $0) } ?? []
                let myRank = responseJSON["user_data"].exists() ? ARContestLeaderModel(fromJson: responseJSON["user_data"]) : nil
                let totalContesters = responseJSON["total_participant"].intValue
                fromVC.hideActivityIndicator()
                let vc = ContestLeaderBoardVC.instantiate(fromAppStoryboard: .Gamification)
                vc.isFromContestHomeScreen = isFromContestHomeScreen
                vc.contest = contest
                vc.contesters = contesters
                vc.myRank = myRank
                vc.totalContesters = totalContesters
                fromVC.navigationController?.pushViewController(vc, animated: true)
            } else {
                fromVC.hideActivityIndicator()
                fromVC.showAlert(title: status, message: message)
            }
        }
    }
}

// MARK: -
class ARTopContesterView: UIView {
    @IBOutlet weak var rankL: UILabel!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var pointL: UILabel!
    @IBOutlet weak var proTagL: UILabel!
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var levelIV: UIImageView!
    @IBOutlet weak var levelBGIV: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageIV.makeItRounded()
        imageIV.layer.borderWidth = 2.0
        levelIV.makeItRounded()
    }
    
    func updateUI(for data: ARContestLeaderModel?) {
        guard let data = data else { return }
        
        rankL.text = data.rank
        nameL.text = data.isMySelf ? "Me" : data.userName
        pointL.text = "\(data.points!) pt"
        proTagL.isHidden = (data.isSubscribed == 0)
        proTagL.cornerRadiuss = 4
        proTagL.clipsToBounds = true
        
        if let imageURL = data.imageURL {
            imageIV.af.setImage(withURL: imageURL)
        }
        imageIV.layer.borderColor = (data.isMySelf ? UIColor.app.gamificationOrangeDark : UIColor.clear).cgColor
        
        levelIV.isHidden = data.levelImage.isEmpty
        levelBGIV.isHidden = data.levelImage.isEmpty
        levelIV.af_setImage(withURLString: data.levelImage)
    }
}
