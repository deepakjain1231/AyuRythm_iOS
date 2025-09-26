//
//  EarnAyuseedVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 24/11/21.
//  Copyright © 2021 AyuRythm. All rights reserved.
//

import UIKit
import AVFoundation

class EarnAyuseedVC: BaseViewController {

    @IBOutlet weak var streakTimelineView: StreakTimelineView!
    @IBOutlet weak var inviteUserL: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var rewardCollectionView: UICollectionView!
    
    @IBOutlet weak var taskListView: UIView!
    @IBOutlet weak var contestViewAllBtn: UIView!
    @IBOutlet weak var contestListView: UIView!
    @IBOutlet weak var myRewardListView: UIView!
    @IBOutlet weak var rewardCollectionViewAspectRatioCont: NSLayoutConstraint!
    
    @IBOutlet weak var facebookConnectBtn: UIButton!
    @IBOutlet weak var facebookConnectStatusBtn: UIButton!
    @IBOutlet weak var googleConnectBtn: UIButton!
    @IBOutlet weak var googleConnectStatusBtn: UIButton!
    
    var tasks = [ARDailyTaskModel]()
    var scratchCards = [ARScratchCardModel]()
    var contests = [ARContestModel]()
    
    var inviteFriendText = String(format: "You and your friend, get %@ AyuSeeds each, when they sign up using your code!".localized(), kUserDefaults.referralPointValue)
    var socialLoginHelper: SocialLoginHelper?
    var googleLink: SMLinkModel?
    var facebookLink: SMLinkModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rewards & Contests".localized()
        setBackButtonTitle()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.reloadData()
        rewardCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        fetchAllData()
    }
    
    func setupUI() {
        taskListView.isHidden = true
        contestListView.isHidden = true
        myRewardListView.isHidden = true
        inviteUserL.text = inviteFriendText
        collectionView.setupUISpace(allSide: 0, itemSpacing: 0, lineSpacing: 16)
        collectionView.register(nibWithCellClass: ContestDetailCell.self)
        
        rewardCollectionView.setupUISpace(allSide: 0, itemSpacing: 20, lineSpacing: 16)
        rewardCollectionView.register(nibWithCellClass: ScratchCardCell.self)
        
        tableView.register(nibWithCellClass: StreakTaskCell.self)
        tableView.reloadData()
        streakTimelineView.updateUI(from: kSharedAppDelegate.userStreakLevel)
        updateSocialMediaLinkStatus()
        
        NotificationCenter.default.addObserver(forName: .refreshScratchCardList, object: nil, queue: nil) { [weak self] notif in
            self?.fetchScratchCardList()
        }
        /*
        NotificationCenter.default.addObserver(forName: .refreshDailyTaskList, object: nil, queue: nil) { [weak self] notif in
            self?.fetchDailyTaskList()
        }*/
    }
    
    @IBAction func inviteFriendsBtnPressed(sender: UIButton) {
        referAFriend()
    }
    
    @IBAction func infoBtnPressed(sender: UIButton) {
        showAlert(title: "Streak".localized(), message: "You can get exciting rewards while maintaining your daily streak.\n\n• Maintain your streak by doing sparshna\n• Reach new levels to claim\nexciting rewards".localized())
    }
    
    @IBAction func seeBenefitsBtnPressed(sender: UIButton) {
        let vc = StreakDetailVC.instantiate(fromAppStoryboard: .Gamification)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func viewAllContestBtnPressed(sender: UIButton) {
        let vc = ContestListVC.instantiate(fromAppStoryboard: .Gamification)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func viewAllMyRewardsBtnPressed(sender: UIButton) {
        let vc = RewardListVC.instantiate(fromAppStoryboard: .Gamification)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func connectFacebookBtnPressed(sender: UIButton) {
        doSocialMediaLink(for: .facebook)
    }
    
    @IBAction func connectGoogleBtnPressed(sender: UIButton) {
        doSocialMediaLink(for: .gmail)
    }
}

extension EarnAyuseedVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: StreakTaskCell.self, for: indexPath)
        cell.task = tasks[indexPath.row]
        /*let isHideProgress = (indexPath.row == tasks.count - 1)
        cell.progressL.isHidden = isHideProgress
        if isHideProgress {
            cell.statusBtn.setImage(#imageLiteral(resourceName: "gift-icon"), for: .normal)
        }*/
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        redirectToTask(task: task)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension EarnAyuseedVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == rewardCollectionView {
            return scratchCards.count
        } else {
            return contests.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == rewardCollectionView {
            let cellWidth = collectionView.widthOfItemCellFor(noOfCellsInRow: 2)
            return CGSize(width: cellWidth, height: cellWidth)
        } else {
            var cellWidth = collectionView.frame.size.width - 16
            cellWidth = min(cellWidth, 250)
            return CGSize(width: cellWidth, height: collectionView.frame.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == rewardCollectionView {
            let cell = collectionView.dequeueReusableCell(withClass: ScratchCardCell.self, for: indexPath)
            cell.scratchCard = scratchCards[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withClass: ContestDetailCell.self, for: indexPath)
            cell.data = contests[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == rewardCollectionView {
            let scratchCard = scratchCards[indexPath.row]
            ScratchCardVC.showScreenFromRewardList(scratchCard: scratchCard, fromVC: self)
        } else {
            let contest = contests[indexPath.row]
            ContestHomeVC.showScreen(contest: contest, fromVC: self)
        }
    }
}

extension EarnAyuseedVC {
    static func showScreen(fromVC: UIViewController) {
        let vc = EarnAyuseedVC.instantiate(fromAppStoryboard: .Gamification)
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}

extension EarnAyuseedVC {
    func fetchAllData() {
        fetchUserStreakLevelDetails()
        //fetchDailyTaskList()
        fetchContests()
        fetchScratchCardList()
    }
    
    func fetchUserStreakLevelDetails() {
        streakTimelineView.refreshUIByAPICall()
    }
    
    //As per saneep sir said : - 21-August-2023
    /*
    func fetchDailyTaskList() {
        MoEngageHelper.shared.trackEvent(name: event.today_plan.rawValue)
        doAPICall(endPoint: .getDailyTaskList, parameters: ["language_id" : Utils.getLanguageId()], headers: headers) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess {
                let tasks = responseJSON?["data"].array?.compactMap{ ARDailyTaskModel(fromJson: $0) } ?? []
                /*if let index = tasks.firstIndex(where: { $0.isCompleted == false }) {
                    tasks[index].isNext = true
                }*/
                self?.tasks = tasks
                self?.tableView.reloadData()
                self?.taskListView.isHidden = tasks.isEmpty
            }
        }
    }
    */
    
    func fetchContests() {
        ContestListVC.fetchContestList(limit: 4) { [weak self] isSuccess, status, message, contests in
            self?.contests = contests
            self?.contestViewAllBtn.isHidden = (contests.count < 4)
            self?.collectionView.reloadData()
            self?.contestListView.isHidden = contests.isEmpty
        }
    }
    
    func fetchScratchCardList() {
        RewardListVC.getScratchCardList(limit: 4) { [weak self] isSuccess, status, message, scratchCards in
            self?.scratchCards = scratchCards
            self?.rewardCollectionViewAspectRatioCont.constant = scratchCards.count > 2 ? 0 : ((self?.rewardCollectionView.frame.size.width ?? 0) / 2)
            self?.myRewardListView.layoutIfNeeded()
            self?.rewardCollectionView.reloadData()
            self?.myRewardListView.isHidden = scratchCards.isEmpty
        }
    }
}

extension EarnAyuseedVC {
    func redirectToTask(task: ARDailyTaskModel) {
        switch task.taskType {
        case .yoga, .pranayam, .meditation, .kriya, .mudra:
            let vc = YogaPlayListViewController.instantiate(fromAppStoryboard: .ForYou)
            vc.recommendationPrakriti = Utils.getPrakritiIncreaseValue()
            vc.recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
            vc.isFromHomeScreen = true
            vc.istype = IsSectionType.getType(for: task.taskType)
            self.navigationController?.pushViewController(vc, animated: true)
        
        case .sparshna:
            SparshnaAlert.showSparshnaTestScreen(isBackBtnVisible: true, fromVC: self)
        
        case .suryanamaskaar:
            CCRYNUnlockAlertVC.unlockAndAddCCYNCount(isBackBtnVisible: true, fromVC: self)
            
        case .other:
            print("redirect to other")
        }
    }
}

// MARK: - Social Link and invite friend methods
extension EarnAyuseedVC {
    func referAFriend() {
        let referFriendEarn = AyuSeedEarn(type: .referFriend, title: "Refer a friend".localized(), message: inviteFriendText, color: #colorLiteral(red: 1, green: 0.9490196078, blue: 0.7921568627, alpha: 1), image: "ic_Earn2", popUpImage: "ic_InviteAFriend")
        ReferPopupViewController.showScreen(ayuSeedEarn: referFriendEarn, fromVC: self)
    }
    
    func updateSocialMediaLinkStatus() {
        googleLink = SMLinkModel(title: "Google", type: .gmail)
        facebookLink = SMLinkModel(title: "Facebook", type: .facebook)
        if let googleLink = googleLink, googleLink.isLinked {
            googleConnectStatusBtn.isSelected = true
            googleConnectBtn.isUserInteractionEnabled = false
        }
        if let facebookLink = facebookLink, facebookLink.isLinked {
            facebookConnectStatusBtn.isSelected = true
            facebookConnectBtn.isUserInteractionEnabled = false
        }
    }
    
    func doSocialMediaLink(for type: ARLoginType) {
        showActivityIndicator()
        socialLoginHelper = SocialLoginHelper(presentingVC: self)
        if type == .facebook {
            socialLoginHelper?.doFacebookSignIn { [weak self] (isSuccess, message, user, loginType) in
                //print("isSuccess : ", isSuccess, "\nmessage : ", message, "\nemail : ", user?.email, "\nphoneNumber : ", user?.phoneNumber, "\nloginType : ", loginType)
                if isSuccess, let user = user {
                    self?.connectSocialLinkAndEarn(socialLoginUser: user, loginType: loginType)
                } else {
                    self?.hideActivityIndicator()
                    self?.showAlert(message: message)
                }
                self?.socialLoginHelper = nil
            }
        } else if type == .gmail {
            socialLoginHelper?.doGoogleSignIn { [weak self] (isSuccess, message, user, loginType) in
                //print("isSuccess : ", isSuccess, "\nmessage : ", message, "\nemail : ", user?.email, "\nphoneNumber : ", user?.phoneNumber, "\nloginType : ", loginType)
                if isSuccess, let user = user {
                    self?.connectSocialLinkAndEarn(socialLoginUser: user, loginType: loginType)
                } else {
                    self?.hideActivityIndicator()
                    self?.showAlert(message: message)
                }
                self?.socialLoginHelper = nil
            }
        }
        
    }
    
    func updateSocialLinkConnactionStatus(type: ARLoginType, email: String?) {
        if type == .gmail {
            googleLink?.saveSocialLinkEmail(email: email)
            googleConnectStatusBtn.isSelected = true
            googleConnectBtn.isUserInteractionEnabled = false
        } else if type == .facebook {
            facebookLink?.saveSocialLinkEmail(email: email)
            facebookConnectStatusBtn.isSelected = true
            facebookConnectBtn.isUserInteractionEnabled = false
        }
    }
    
    func connectSocialLinkAndEarn(socialLoginUser: SocialLoginUser, loginType: ARLoginType) {
        ReferPopupViewController.updateSocialConnectDetailsFromServer(socialLoginUser: socialLoginUser, loginType: loginType) { [weak self] (isSuccess, title, message) in
            print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
            if isSuccess {
                let favID = (loginType == .facebook) ? AyuSeedEarnActivity.socialLinkFacebook.rawValue : AyuSeedEarnActivity.socialLinkGoogle.rawValue
                let params = ["activity_favorite_id": favID, "language_id": Utils.getLanguageId()] as [String : Any]
                ReferPopupViewController.addEarmHistoryFromServer(params: params) { (isSuccess, title, message) in
                    print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
                    self?.hideActivityIndicator()
                    self?.updateSocialLinkConnactionStatus(type: loginType, email: socialLoginUser.email)
                    self?.showAlert(title: title, message: message)
                }
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(message: message)
            }
        }
    }
}

// MARK: - Daily Task
extension IsSectionType {
    static func getType(for taskType: ARDailyTaskType) -> IsSectionType {
        switch taskType {
        case .yoga:
            return .yoga
            
        case .pranayam:
            return .pranayama
            
        case .meditation:
            return .meditation
            
        case .kriya:
            return .kriya
            
        case .mudra:
            return .mudra
        
        default:
            print("redirect to other")
            return .yoga
        }
    }
}

// MARK: -
class BorderedView: DesignableView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }

    func commonSetup() {
        cornerRadius = 14
        borderWidth = 1
        borderColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
}

// MARK: -
class BorderedWithShadowView: DesignableView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }

    func commonSetup() {
        //shadow = true
        addShadow(shadowColor: UIColor().hexStringToUIColor(hex: "#9E9C9B").cgColor, shadowOffset: CGSize(width: 0, height: 1), shadowOpacity: 0.4, shadowRadius: 3)
        cornerRadius = 14
        borderWidth = 1
        borderColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
}
