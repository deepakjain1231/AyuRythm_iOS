
import UIKit
import Alamofire

struct AyuSeedEarn: Equatable {
    enum Types {
        case completeVikritiPrashna
        case referFriend
        case completeSparshna
        case linkSocilMedia
        case createList
    }
    
    var type: Types
    var title: String
    var message: String
    var color: UIColor
    var image: String
    var popUpImage: String
    var popUpImage2: String? = nil
    
    static func customSparshnaEarnMessage() -> String {
        if let lastAssessmentDate = kUserDefaults.value(forKey: LAST_ASSESSMENT_DATE) as? String {
            if let lastAssessment = Utils.getDateFromString(lastAssessmentDate, format: "yyyy-MM-dd HH:mm:ss") {
                if Calendar.current.isDateInToday(lastAssessment) {
                    return "You have already earned the maximum Seeds for Sparshna today.\nPlease come back tomorrow to earn again.".localized()
                }
            }
        }
        return "Complete your Sparshna \ntest everyday and earn 25 AyuSeeds!".localized()
    }
    
    static func ==(lhs: AyuSeedEarn, rhs: AyuSeedEarn) -> Bool {
        return lhs.type == rhs.type
    }
}

struct AyuSeedRedeem: Equatable {
    enum Types {
        case userLists
        case meditations
        case mudras
        case kriyas
        case buyCoupons
    }
    
    var type: Types
    var title: String
    var color: UIColor
    var image: String
    var popUpImage: String
    
    static func ==(lhs: AyuSeedRedeem, rhs: AyuSeedRedeem) -> Bool {
        return lhs.type == rhs.type
    }
}

enum AyuSeedEarnActivity: Int {
    case sparshna = 1
    case referral
    case onboarding
    case vikritiPrashna
    case userList
    case favoriteAnItem
    case socialLinkFacebook
    case socialLinkGoogle
    case clickAdOrAffiliateLink
    case existingUsers
    case promoCode
}

class AyuSeedsViewController: BaseViewController {
    
    @IBOutlet weak var viewRoundRadius: UIView!
    @IBOutlet weak var viewEarnSelected: UIView!
    @IBOutlet weak var viewRedeemSelected: UIView!
    @IBOutlet weak var viewHistorySelected: UIView!
    @IBOutlet weak var viewCouponsSelected: UIView!
    @IBOutlet weak var viewNoCoupons: UIView!
    @IBOutlet weak var btnEarn: UIButton!
    @IBOutlet weak var btnRedeem: UIButton!
    @IBOutlet weak var btnHistory: UIButton!
    @IBOutlet weak var btnCoupons: UIButton!
    @IBOutlet weak var couponTabSV: UIStackView!
    @IBOutlet weak var collectionViewAyuSeeds: UICollectionView!
    @IBOutlet weak var tblHistory: UITableView!
    @IBOutlet weak var exploreContestView: ARExploreContestView!
    
    @IBOutlet weak var availableSeedsBtn: UIButton!
    /*@IBOutlet weak var spentSeedsBtn: UIButton!
    @IBOutlet weak var expiredSeedsBtn: UIButton!
    @IBOutlet weak var lifetimeSeedsBtn: UIButton!*/
    
    var recommendationVikriti: RecommendationType = .kapha
    var recommendationPrakriti: RecommendationType = .kapha
    var dicResponse = [[String: Any]]()
    var selectedTab = 0
    var isSeeMoreTapped = Bool()
    var isShowAyuSeedInro = false
    var coupons = [CouponModel]()
    var ayuSeedEarns = [AyuSeedEarn(type: .completeVikritiPrashna, title: "Complete Vikriti Prashna".localized(), message: "Earn 50 AyuSeeds by completing \nVikriti Prashna once a month".localized(), color: #colorLiteral(red: 0.8745098039, green: 0.9294117647, blue: 0.9843137255, alpha: 1), image: "ic_Earn1", popUpImage: "ic_ComVikriti"),
                        AyuSeedEarn(type: .completeSparshna, title: "Complete Sparshna".localized(), message: "Complete your Sparshna \ntest everyday and earn 25 AyuSeeds!".localized(), color: #colorLiteral(red: 0.9843137255, green: 0.8862745098, blue: 0.9058823529, alpha: 1), image: "ic_Earn3", popUpImage: "ic_Pressure"),
                        AyuSeedEarn(type: .linkSocilMedia, title: "Link your Social Media".localized(), message: "".localized(), color: #colorLiteral(red: 0.9551808238, green: 0.9715695977, blue: 0.8654548526, alpha: 1), image: "ic_Earn4", popUpImage: "ic_connectFB", popUpImage2: "ic_connectGoogle"),
                        AyuSeedEarn(type: .createList, title: "Create a List".localized(), message: "Completely for you, by you!\nAnd earn 10 AyuSeeds\n(For every list you make!)".localized(), color: #colorLiteral(red: 1, green: 0.9490196078, blue: 0.7921568627, alpha: 1), image: "ic_Earn5", popUpImage: "ic_UserListPopUp")]
    var ayuSeedRedeems = [AyuSeedRedeem(type: .buyCoupons, title: "Buy Coupons!".localized(), color: #colorLiteral(red: 0.8745098039, green: 0.9294117647, blue: 0.9843137255, alpha: 1), image: Locale.current.isCurrencyCodeInINR ? "buy-coupons" : "buy-coupons-disabled", popUpImage: ""),
                          AyuSeedRedeem(type: .meditations, title: "Meditation".localized(), color: #colorLiteral(red: 0.9568627451, green: 0.9019607843, blue: 0.7921568627, alpha: 1), image: "ic_MedicinesAyuSeeds", popUpImage: "ic_MeditationPopUp"),
                          AyuSeedRedeem(type: .mudras, title: "Mudras".localized(), color: #colorLiteral(red: 0.9568627451, green: 0.9725490196, blue: 0.8666666667, alpha: 1), image: "ic_MudrasAyuSeeds", popUpImage: "ic_MudraPopUp"),
                          AyuSeedRedeem(type: .kriyas, title: "Kriyas".localized(), color: #colorLiteral(red: 0.9843137255, green: 0.8862745098, blue: 0.9058823529, alpha: 1), image: "ic_KriasAyuSeeds", popUpImage: "ic_KriyasPopUp")]
    var ayuSeedsInfoMessage = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = nil
        exploreContestView.delegate = self

        //Remove Shop Section as per Sandeep
        if !Locale.current.isCurrencyCodeInINR || Locale.current.isCurrencyCodeInINR {
            self.ayuSeedRedeems = [AyuSeedRedeem(type: .meditations, title: "Meditation".localized(), color: #colorLiteral(red: 0.9568627451, green: 0.9019607843, blue: 0.7921568627, alpha: 1), image: "ic_MedicinesAyuSeeds", popUpImage: "ic_MeditationPopUp"),
                                  AyuSeedRedeem(type: .mudras, title: "Mudras".localized(), color: #colorLiteral(red: 0.9568627451, green: 0.9725490196, blue: 0.8666666667, alpha: 1), image: "ic_MudrasAyuSeeds", popUpImage: "ic_MudraPopUp"),
                                  AyuSeedRedeem(type: .kriyas, title: "Kriyas".localized(), color: #colorLiteral(red: 0.9843137255, green: 0.8862745098, blue: 0.9058823529, alpha: 1), image: "ic_KriasAyuSeeds", popUpImage: "ic_KriyasPopUp")]
        }


        collectionViewAyuSeeds.register(UINib(nibName: "AyuSeedsEarnCell", bundle: nil), forCellWithReuseIdentifier: "AyuSeedsEarnCell")
        tblHistory.register(UINib(nibName: "HistoryListCell", bundle: nil), forCellReuseIdentifier: "HistoryListCell")
        tblHistory.register(UINib(nibName: "RedeemCouponCell", bundle: nil), forCellReuseIdentifier: "RedeemCouponCell")
        tblHistory.register(UINib(nibName: "SeeMoreCell", bundle: nil), forCellReuseIdentifier: "SeeMoreCell")
        tblHistory.contentInset.top = 8
        
        //hide coupon tab outside india
        //Remove Shop Section as per Sandeep
        couponTabSV.isHidden = true// !Locale.current.isCurrencyCodeInINR
        
        recommendationVikriti = RecommendationType(rawValue: Utils.getRecommendationType()) ?? .kapha
        recommendationPrakriti = Utils.getPrakritiIncreaseValue()
        
        btnRedeemClicked(btnRedeem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTransactionHistory()
        NotificationFromServer()
        self.navigationController?.isNavigationBarHidden = false
        
        let referFriendEarn = AyuSeedEarn(type: .referFriend, title: "Refer a friend".localized(), message: String(format: "You and your friend, get %@ AyuSeeds each, when they sign up using your code!".localized(), kUserDefaults.referralPointValue), color: #colorLiteral(red: 1, green: 0.9490196078, blue: 0.7921568627, alpha: 1), image: "ic_Earn2", popUpImage: "ic_InviteAFriend")
        if !ayuSeedEarns.contains(referFriendEarn) {
            ayuSeedEarns.insert(referFriendEarn, at: 1)
            collectionViewAyuSeeds.reloadData()
        }
        
        let userListsRedeem = AyuSeedRedeem(type: .userLists, title: "User Lists".localized(), color: #colorLiteral(red: 1, green: 0.9490196078, blue: 0.7921568627, alpha: 1), image: "ic_Earn5", popUpImage: "ic_UserListPopUp")
        if ayuSeedRedeems.contains(userListsRedeem) {
            ayuSeedRedeems.removeLast()
            collectionViewAyuSeeds.reloadData()
        }
        
        if !kUserDefaults.bool(forKey: kUserListRedeemed) {
            ayuSeedRedeems.append(userListsRedeem)
        }
        
        let doNotShowAyuSeeds = kUserDefaults.value(forKey: kDoNotShowAyuSeeds) as? Bool ?? false
        if (!doNotShowAyuSeeds) {
            if !isShowAyuSeedInro {
                AyuSeedIntroViewController.showScreen(from: self)
                isShowAyuSeedInro = true
            }
        }
    }
    
    //MARK: Button Click Methods
    @IBAction func btnEarnClicked(_ sender: UIButton) {
        selectedTab = 0
        collectionViewAyuSeeds.reloadData()
        collectionViewAyuSeeds.isHidden = false
        tblHistory.isHidden = true
        viewNoCoupons.isHidden = true
        viewEarnSelected.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.5450980392, blue: 0.3333333333, alpha: 1)
        viewRedeemSelected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        viewHistorySelected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        viewCouponsSelected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        btnEarn.setTitleColor(.black, for: .normal)
        btnRedeem.setTitleColor(#colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6), for: .normal)
        btnHistory.setTitleColor(#colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6), for: .normal)
        btnCoupons.setTitleColor(#colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6), for: .normal)
    }

    @IBAction func btnRedeemClicked(_ sender: UIButton) {
        selectedTab = 1
        collectionViewAyuSeeds.reloadData()
        collectionViewAyuSeeds.isHidden = false
        tblHistory.isHidden = true
        viewNoCoupons.isHidden = true
        viewRedeemSelected.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.5450980392, blue: 0.3333333333, alpha: 1)
        viewEarnSelected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        viewHistorySelected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        viewCouponsSelected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        btnRedeem.setTitleColor(.black, for: .normal)
        btnEarn.setTitleColor(#colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6), for: .normal)
        btnHistory.setTitleColor(#colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6), for: .normal)
        btnCoupons.setTitleColor(#colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6), for: .normal)
    }

    @IBAction func btnHistoryClicked(_ sender: UIButton) {
        selectedTab = 2
        collectionViewAyuSeeds.isHidden = true
        tblHistory.isHidden = false
        viewNoCoupons.isHidden = true
        viewHistorySelected.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.5450980392, blue: 0.3333333333, alpha: 1)
        viewEarnSelected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        viewRedeemSelected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        viewCouponsSelected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        btnHistory.setTitleColor(.black, for: .normal)
        btnEarn.setTitleColor(#colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6), for: .normal)
        btnRedeem.setTitleColor(#colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6), for: .normal)
        btnCoupons.setTitleColor(#colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6), for: .normal)
        tblHistory.reloadData()
    }
    
    @IBAction func btnCouponsClicked(_ sender: UIButton) {
        selectedTab = 3
        collectionViewAyuSeeds.isHidden = true
        tblHistory.isHidden = false
        viewNoCoupons.isHidden = true
        viewHistorySelected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        viewEarnSelected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        viewRedeemSelected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        viewCouponsSelected.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.5450980392, blue: 0.3333333333, alpha: 1)
        btnHistory.setTitleColor(#colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6), for: .normal)
        btnEarn.setTitleColor(#colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6), for: .normal)
        btnRedeem.setTitleColor(#colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.6), for: .normal)
        btnCoupons.setTitleColor(.black, for: .normal)
        tblHistory.reloadData()
        
        showActivityIndicator()
        getRedeemedCouponsFromServer { (isSuccess, message, coupons) in
            self.hideActivityIndicator()
            if isSuccess {
                self.coupons = coupons
                self.viewNoCoupons.isHidden = !coupons.isEmpty
                self.tblHistory.reloadData()
            } else {
                self.showAlert(message: message)
            }
        }
    }
    
    @IBAction func btnBuyAyuSeedsClicked(_ sender: UIButton) {
        BuyAyuSeedsViewController.showScreen(presentingVC: self.tabBarController)
    }
    
    @IBAction func btnAyuSeedInfoClicked(_ sender: UIButton) {
        showAlert(title: "AyuSeeds".localized(), message: ayuSeedsInfoMessage)
    }
    
    @IBAction func btnGetCouponsClicked(_ sender: UIButton) {
        CouponCompanyCategoryViewController.showScreen(presentingVC: self)
    }
    
    @IBAction func btnEarnAyuSeedsClicked(_ sender: UIButton) {
        EarnAyuseedVC.showScreen(fromVC: self)
    }
    
    //MARK:- API call to retrive transaction history
    func fetchTransactionHistory() {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
           let urlString = kBaseNewURL + endPoint.transactionhistoryV2.rawValue
        
           AF.request(urlString, method: .post, parameters: ["language_id" : Utils.getLanguageId()], encoding:URLEncoding.default,headers: headers).responseJSON { response in
               
               DispatchQueue.main.async(execute: {
                   Utils.stopActivityIndicatorinView(self.view)
               })
               switch response.result {
               case .success(let value):
                    debugPrint(response)
                    guard let dicResponseValue = (value as? [String: Any]),
                          let dicResponse = dicResponseValue["response"] as? [[String : Any]] else {
                        return
                    }
                   
                    self.dicResponse = dicResponse
                    
                    var lifetimeSeeds = 0
                    var spentSeeds = 0
                    
                    for dic in self.dicResponse {
                        if let trancType = dic["type"] as? String {
                            if trancType == "spent" {
                                if let points = dic["points"] as? String {
                                    spentSeeds = spentSeeds + (Int(points) ?? 0)
                                }
                            }
                            else {
                                if let points = dic["points"] as? String {
                                    lifetimeSeeds = lifetimeSeeds + (Int(points) ?? 0)
                                }
                            }
                        }
                    }
                   self.availableSeedsBtn.setTitle((lifetimeSeeds - spentSeeds).stringValue, for: .normal)
                   self.ayuSeedsInfoMessage = String(format: "Spent Seeds - %@ \nLifetime Seeds - %@".localized(), spentSeeds.stringValue, lifetimeSeeds.stringValue)
                   /*self.spentSeedsBtn.setTitle(spentSeeds.stringValue, for: .normal)
                    self.expiredSeedsBtn.setTitle("0", for: .normal)
                    self.lifetimeSeedsBtn.setTitle(lifetimeSeeds.stringValue, for: .normal)
                    self.lblTotalEarned.text = "\(lifetimeSeeds)"
                    self.lblTotalSpent.text = "\(spentSeeds)"
                    self.lblRemaining.text = "\(lifetimeSeeds - spentSeeds)"*/

                    DispatchQueue.main.async(execute: {
                        self.tblHistory.reloadData()
                    })
                    
               case .failure(let error):
                   debugPrint(error)
                   Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
               }
           }
    }
}
//
extension AyuSeedsViewController: UICollectionViewDataSource, UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedTab == 0 ? ayuSeedEarns.count : ayuSeedRedeems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: AyuSeedsEarnCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AyuSeedsEarnCell", for: indexPath) as? AyuSeedsEarnCell else {
            return UICollectionViewCell()
        }
        if selectedTab == 0 {
            cell.ayuSeedEarn = ayuSeedEarns[indexPath.row]
            return cell
        }
        
        cell.ayuSeedRedeem = ayuSeedRedeems[indexPath.row]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size:CGFloat = (kDeviceWidth) / 2.0
        return CGSize(width: size, height: size)
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedTab == 0 {
            let ayuSeedEarn = ayuSeedEarns[indexPath.row]
            ReferPopupViewController.showScreen(ayuSeedEarn: ayuSeedEarn, fromVC: self)
            self.tabBarController?.tabBar.isHidden = true
        } else if selectedTab == 1 {
            
            //If registered but not given test
            if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil && kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti and Vikriti assessment to view recommendations".localized(), controller: self)
                return
            } else if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti assessment to view recommendations".localized(), controller: self)
                return
            } else if kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
                Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Vikriti assessment to view recommendations".localized(), controller: self)
                return
            }
            
            let ayuSeedRedeem = ayuSeedRedeems[indexPath.row]
            redirectAyuSeedRedeem(ayuSeedRedeem)
        }
    }
}

extension AyuSeedsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView delegate datasource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTab == 2 {
            if dicResponse.count > 3 && !isSeeMoreTapped {
                return 4
            }
            return dicResponse.count
        } else {
            return coupons.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedTab == 2 {
            if dicResponse.count > 3 {
                if indexPath.row != 3 || isSeeMoreTapped {
                    let historyCell = tableView.dequeueReusableCell(withIdentifier: "HistoryListCell", for: indexPath as IndexPath) as! HistoryListCell
                    
                    let data = dicResponse[indexPath.row]
                    if let trancType = data["type"] as? String {
                        if trancType == "spent" {
                            historyCell.imgSeed.image = #imageLiteral(resourceName: "ic_leafDown")
                        }
                        else {
                            historyCell.imgSeed.image = #imageLiteral(resourceName: "ic_leafUp")
                        }
                    }
                    if let activityMessage = data["activity_message"] as? String {
                        historyCell.lblDescription.text = activityMessage
                    }
                    if let date = data["created_date"] as? String {
                        historyCell.lblDate.text = date
                    }
                    if let points = data["points"] as? String {
                        historyCell.lblPoints.text = points
                    }
                    return historyCell
                } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreCell", for: indexPath as IndexPath) as? SeeMoreCell else {
                        return UITableViewCell()
                    }
                    cell.btnSeeMore.tag = indexPath.row
                    cell.btnSeeMore.addTarget(self, action: #selector(didTapSeeMore), for: .touchUpInside)
                    return cell
                }
            }
            let historyCell = tableView.dequeueReusableCell(withIdentifier: "HistoryListCell", for: indexPath as IndexPath) as! HistoryListCell
            let data = dicResponse[indexPath.row]
            if let trancType = data["type"] as? String {
                if trancType == "spent" {
                    historyCell.imgSeed.image = #imageLiteral(resourceName: "ic_leafDown")
                }
                else {
                    historyCell.imgSeed.image = #imageLiteral(resourceName: "ic_leafUp")
                }
            }
            if let activityMessage = data["activity_message"] as? String {
                historyCell.lblDescription.text = activityMessage
            }
            if let date = data["created_date"] as? String {
                historyCell.lblDate.text = date
            }
            if let points = data["points"] as? String {
                historyCell.lblPoints.text = points
            }

            return historyCell
        } else if selectedTab == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RedeemCouponCell", for: indexPath) as! RedeemCouponCell
            cell.coupon = coupons[indexPath.row]
            
            
            cell.didTappedonShopNow = { (sender) in

                if let arrViewControllers = self.navigationController?.viewControllers {
                    for aViewController in arrViewControllers {
                        if aViewController.isKind(of: AyuSeedsViewController.self) {
                            (aViewController as? AyuSeedsViewController)?.tabBarController?.selectedIndex = 2
                        }
                    }
                }
                
                
//                if let siteURL = coupons[indexPath.row].url, let url = URL(string: siteURL), UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.open(url)
//                }
            }
            
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedTab == 3 {
            return 236
        } else {
            return 80
        }
    }
    
    @objc func didTapSeeMore(sender: UIButton) {
        isSeeMoreTapped = true
        tblHistory.reloadData()
    }
}

extension AyuSeedsViewController: ARExploreContestViewDelegate {
    func exploreContestViewArrowBtnDidPressed(view: ARExploreContestView) {
        EarnAyuseedVC.showScreen(fromVC: self)
    }
}

extension AyuSeedsViewController {
    func redirectAyuSeedRedeem(_ redeem: AyuSeedRedeem) {
        switch redeem.type {
        case .userLists:
            print("userLists")
            tabBarController?.selectedIndex = 4
            
        case .meditations:
            print("meditations")
            showMeditationPlayListScreen()
            
        case .mudras:
            print("mudras")
            showMudraPlayListScreen()
            
        case .kriyas:
            print("kriyas")
            showKriyaPlayListScreen()
            
        case .buyCoupons:
            print("buyCoupons")
            /*
            //Remove Shop Section as per Sandeep
            if Locale.current.isCurrencyCodeInINR {
                CouponCompanyCategoryViewController.showScreen(presentingVC: self)
            } else {
                showAlert(title: "Feature Unavailable".localized(), message: "Sorry, this feature is currently not available in your country".localized())
            }
            */
        }
    }
    
    func showMeditationPlayListScreen() {
        showActivityIndicator()
        getMeditationFromServer{ [weak self] (isSuccess, message, dataArray) in
            guard let strongSelf = self else { return }
            
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
                return
            }
            objPlayList.recommendationPrakriti = strongSelf.recommendationPrakriti
            objPlayList.recommendationVikriti = strongSelf.recommendationVikriti
            objPlayList.meditationArray = dataArray
            objPlayList.istype = .meditation
            strongSelf.navigationController?.pushViewController(objPlayList, animated: true)
            strongSelf.hideActivityIndicator()
            
            /*if !isSuccess {
                strongSelf.showAlert(message: message)
            }*/
        }
    }
    
    func showMudraPlayListScreen() {
        showActivityIndicator()
        getMudraFromServer{ [weak self] (isSuccess, message, dataArray) in
            guard let strongSelf = self else { return }
            
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
                return
            }
            objPlayList.recommendationPrakriti = strongSelf.recommendationPrakriti
            objPlayList.recommendationVikriti = strongSelf.recommendationVikriti
            objPlayList.mudraArray = dataArray
            objPlayList.istype = .mudra
            strongSelf.navigationController?.pushViewController(objPlayList, animated: true)
            strongSelf.hideActivityIndicator()
            
            /*if !isSuccess {
                strongSelf.showAlert(message: message)
            }*/
        }
    }
    
    func showKriyaPlayListScreen() {
        showActivityIndicator()
        getKriyaFromServer{ [weak self] (isSuccess, message, dataArray) in
            guard let strongSelf = self else { return }
            
            let storyBoard = UIStoryboard(name: "ForYou", bundle: nil)
            guard let objPlayList = storyBoard.instantiateViewController(withIdentifier: "YogaPlayListViewController") as? YogaPlayListViewController else {
                return
            }
            objPlayList.recommendationPrakriti = strongSelf.recommendationPrakriti
            objPlayList.recommendationVikriti = strongSelf.recommendationVikriti
            objPlayList.kriyaArray = dataArray
            objPlayList.istype = .kriya
            strongSelf.navigationController?.pushViewController(objPlayList, animated: true)
            strongSelf.hideActivityIndicator()
            
            /*if !isSuccess {
                strongSelf.showAlert(message: message)
            }*/
        }
    }
}

//MARK: API calls
extension AyuSeedsViewController {
    
    func getMeditationFromServer(completion: @escaping (Bool, String, [Meditation])->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.getKriyaiOS_NewAPI.rawValue
            
            var params = ["from": "foryou",
                          "today_keys": "",//Video fav ID from Todaysgoal api
                          "list_type": "meditation",
                          "type": recommendationVikriti.rawValue,
                          "typetwo": Utils.getYourCurrentPrakritiStatus().rawValue,
                          "language_id" : Utils.getLanguageId()] as [String : Any]

#if !APPCLIP
        params["type"] = appDelegate.cloud_vikriti_status
#endif
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let arrResponse = (value as? [[String: Any]]) else {
                        completion(false, "", [])
                        return
                    }
                    let dataArray = arrResponse.compactMap{ Meditation.createMeditationData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                    /*for dic in arrResponse {
                        _ = Meditation.createMeditationData(dicData: dic)
                    }*/
                    completion(true, "", dataArray)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription, [])
                }
            }
        } else {
            completion(false, NO_NETWORK, [])
        }
    }
    
    func getKriyaFromServer(completion: @escaping (Bool, String, [Kriya])->Void) {
        if Utils.isConnectedToNetwork() {
            
            let urlString = kBaseNewURL + endPoint.getKriyaiOS_NewAPI.rawValue
            
            var params = ["from": "foryou",
                          "today_keys": "",//Video fav ID from Todaysgoal api
                          "list_type": "kriya",
                          "type": recommendationVikriti.rawValue,
                          "typetwo": Utils.getYourCurrentPrakritiStatus().rawValue,
                          "language_id" : Utils.getLanguageId()] as [String : Any]

#if !APPCLIP
        params["type"] = appDelegate.cloud_vikriti_status
#endif
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let arrResponse = (value as? [[String: Any]]) else {
                        completion(false, "", [])
                        return
                    }
                    let dataArray = arrResponse.compactMap{ Kriya.createKriyaData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                    completion(true, "", dataArray)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription, [])
                }
            }
        } else {
            completion(false, NO_NETWORK, [])
        }
    }
    
    func getMudraFromServer(completion: @escaping (Bool, String, [Mudra])->Void) {
        
        if Utils.isConnectedToNetwork() {
            
            let urlString = kBaseNewURL + endPoint.getKriyaiOS_NewAPI.rawValue
            
            var params = ["from": "foryou",
                          "today_keys": "",//Video fav ID from Todaysgoal api
                          "list_type": "mudra",
                          "type": recommendationVikriti.rawValue,
                          "typetwo": Utils.getYourCurrentPrakritiStatus().rawValue,
                          "language_id" : Utils.getLanguageId()] as [String : Any]

#if !APPCLIP
        params["type"] = appDelegate.cloud_vikriti_status
#endif
            
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let arrResponse = (value as? [[String: Any]]) else {
                        completion(false, "", [])
                        return
                    }
                    let dataArray = arrResponse.compactMap{ Mudra.createMudraData(dicData: $0) }.sorted(by: {$0.access_point < $1.access_point})
                    completion(true, "", dataArray)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription, [])
                }
            }
        } else {
            completion(false, NO_NETWORK, [])
        }
    }
    
    func getRedeemedCouponsFromServer(completion: @escaping (Bool, String, [CouponModel])->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.getCouponsRedeemHistory.rawValue

            AF.request(urlString, method: .post, parameters: ["language_id" : Utils.getLanguageId()], encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = value as? [String: Any] else {
                        completion(false, "", [CouponModel]())
                        return
                    }
                    
                    let status = dicResponse["status"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? "Fail to get coupons, please try after some time".localized()
                    var data = [CouponModel]()
                    if let dataArray = dicResponse["data"] as? [[String: Any]?] {
                        data = dataArray.map{ CouponModel(fromDictionary: $0 ?? [:]) }
                    }
                    let isSuccess = (status.lowercased() == "Success".lowercased())
                    completion(isSuccess, message, data)
                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription, [CouponModel]())
                }
            }
        } else {
            completion(false, NO_NETWORK, [CouponModel]())
        }
    }
}




