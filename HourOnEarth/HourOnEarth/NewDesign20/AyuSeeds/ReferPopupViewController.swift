//
//  MyHomeViewController.swift
//  HourOnEarth
//
//  Created by Apple on 15/01/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
import QuartzCore

class ReferPopupViewController: BaseViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewPopUP: UIView!
    @IBOutlet weak var viewRefer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var socialLinkPopupsStackView: UIStackView!
    @IBOutlet weak var buttonConnectFacebook: UIButton!
    @IBOutlet weak var buttonConnectGoogle: UIButton!
    @IBOutlet weak var buttonReferralCode: UIButton!
    @IBOutlet weak var buttonLetsGo: UIButton!
    
    var parentVC: UIViewController?
    var ayuSeedEarn: AyuSeedEarn?
    var socialLoginHelper: SocialLoginHelper?
    var googleLink: SMLinkModel?
    var facebookLink: SMLinkModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //socialLinkPopupsStackView.isHidden = true
        
        if let ayuSeedEarn = ayuSeedEarn {
            lblTitle.text = ayuSeedEarn.title
            if ayuSeedEarn.type == .linkSocilMedia {
                socialLinkPopupsStackView.isHidden = false
                viewRefer.isHidden = true
                googleLink = SMLinkModel(title: "Google", type: .gmail)
                facebookLink = SMLinkModel(title: "Facebook", type: .facebook)
                if let googleLink = googleLink, googleLink.isLinked {
                    buttonConnectGoogle.setTitle("Connected".localized(), for: .normal)
                    buttonConnectGoogle.isUserInteractionEnabled = false
                }
                if let facebookLink = facebookLink, facebookLink.isLinked {
                    buttonConnectFacebook.setTitle("Connected".localized(), for: .normal)
                    buttonConnectFacebook.isUserInteractionEnabled = false
                }
            } else {
                image.image = UIImage(named: ayuSeedEarn.popUpImage)
                viewRefer.backgroundColor = ayuSeedEarn.color
                if ayuSeedEarn.type == .completeSparshna {
                    lblDescription.text = AyuSeedEarn.customSparshnaEarnMessage()
                } else {
                    lblDescription.text = ayuSeedEarn.message
                }
                
                if ayuSeedEarn.type == .referFriend, let referralCode = kUserDefaults.string(forKey: kUserReferralCode) {
                    
                    let dashedBorderL = CAShapeLayer()
                    dashedBorderL.strokeColor = kAppGreenD2Color.cgColor
                    dashedBorderL.lineDashPattern = [5, 3]
                    dashedBorderL.frame = buttonReferralCode.bounds
                    dashedBorderL.fillColor = nil
                    dashedBorderL.lineWidth = 1.6
                    dashedBorderL.path = UIBezierPath(roundedRect: buttonReferralCode.bounds, cornerRadius: 6).cgPath
                    buttonReferralCode.layer.addSublayer(dashedBorderL)
                    
                    buttonReferralCode.setTitle(referralCode, for: .normal)
                    buttonReferralCode.isHidden = false
                    buttonLetsGo.setTitle("Refer Now".localized(), for: .normal)
                }
            }
        }
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(closeBottomSheet))
        swipeDown.direction = .down
        viewPopUP.addGestureRecognizer(swipeDown)
        
        if #available(iOS 11.0, *) {
            self.bottomConstraint.constant = -(self.viewPopUP.frame.height + view.safeAreaInsets.bottom)
        } else {
            self.bottomConstraint.constant = -(self.viewPopUP.frame.height + view.layoutMargins.bottom)
        }
        self.view.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.openBottomSheet()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    //MARK: Button Click Methods
    
    @IBAction func btnReferNowClicked(_ sender: UIButton) {
        if let ayuSeedEarn = ayuSeedEarn {
            redirectAyuSeedEarn(ayuSeedEarn)
        }
    }
    
    @IBAction func btnCopyReferralCodeClicked(_ sender: UIButton) {
        //print("code : ", sender.title(for: .normal))
        if let code = sender.title(for: .normal), !code.isEmpty {
            UIPasteboard.general.string = code
            Utils.showAlertWithTitleInControllerWithCompletion("", message: "Referral Code copied successfully".localized(), okTitle: "Ok".localized(), controller: self) { [weak self] in
                self?.closeView()
            }
        }
    }
    
    @IBAction func btnConnectToFacebookClicked(_ sender: UIButton) {
        showActivityIndicator()
        socialLoginHelper = SocialLoginHelper(presentingVC: self)
        socialLoginHelper?.doFacebookSignIn { [weak self] (isSuccess, message, user, loginType) in
            print("isSuccess : ", isSuccess, "\nmessage : ", message, "\nemail : ", user?.email, "\nphoneNumber : ", user?.phoneNumber, "\nloginType : ", loginType)
            if isSuccess, let user = user {
                self?.connectSocialLinkAndEarn(socialLoginUser: user, loginType: loginType)
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(message: message)
            }
            self?.socialLoginHelper = nil
        }
    }
    
    @IBAction func btnConnectToGoogleClicked(_ sender: UIButton) {
        showActivityIndicator()
        socialLoginHelper = SocialLoginHelper(presentingVC: self)
        socialLoginHelper?.doGoogleSignIn { [weak self] (isSuccess, message, user, loginType) in
            print("isSuccess : ", isSuccess, "\nmessage : ", message, "\nemail : ", user?.email, "\nphoneNumber : ", user?.phoneNumber, "\nloginType : ", loginType)
            if isSuccess, let user = user {
                self?.connectSocialLinkAndEarn(socialLoginUser: user, loginType: loginType)
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(message: message)
            }
            self?.socialLoginHelper = nil
        }
    }
    
    func updateSocialLinkConnactionStatus(type: ARLoginType, email: String?) {
        if type == .gmail {
            googleLink?.saveSocialLinkEmail(email: email)
            buttonConnectGoogle.setTitle("Connected".localized(), for: .normal)
            buttonConnectGoogle.isUserInteractionEnabled = false
        } else if type == .facebook {
            facebookLink?.saveSocialLinkEmail(email: email)
            buttonConnectFacebook.setTitle("Connected".localized(), for: .normal)
            buttonConnectFacebook.isUserInteractionEnabled = false
        }
    }

    
    //MARK: Private Helper Methods

    func openBottomSheet() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func closeBottomSheet(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .down:
                self.closeView()
            default:
                break
            }
        }
    }
    
    func closeView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomConstraint.constant = -(self.viewPopUP.frame.height + self.view.safeAreaInsets.bottom)
            self.view.layoutIfNeeded()
        }, completion: {
            (value: Bool) in
            self.dismiss(animated: false, completion: {
                self.parentVC?.tabBarController?.tabBar.isHidden = false
            })
        })
    }
    
    func closeViewNew() {
        UIView.animate(withDuration: 0.0, animations: {
            self.bottomConstraint.constant = -(self.viewPopUP.frame.height + self.view.safeAreaInsets.bottom)
            self.view.layoutIfNeeded()
        }, completion: {
            (value: Bool) in
            self.dismiss(animated: false, completion: {
//                self.parentVC?.tabBarController?.tabBar.isHidden = false
            })
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.view {
                closeView()
            }
        }
    }
}

extension ReferPopupViewController {
    func redirectAyuSeedEarn(_ earn: AyuSeedEarn) {
        switch earn.type {
        case .completeVikritiPrashna:
            print("completeVikritiPrashna")
            completePrashnaOrSparshnaClicked(isPrashna: true)
            closeView()
            
        case .referFriend:
            print("referFriend")
            referAFriend()
            
        case .completeSparshna:
            print("completeSparshna")
            completePrashnaOrSparshnaClicked(isPrashna: false)
//            closeView()
            
        case .linkSocilMedia:
            print("linkSocilMedia")
            
        case .createList:
            print("createList")
            parentVC?.tabBarController?.selectedIndex = 4
            closeView()
        }
    }
}

extension ReferPopupViewController {
    
    func completePrashnaOrSparshnaClicked(isPrashna: Bool) {
        if isPrashna {
            showPrashna()
        } else {
            showSparshna()
        }
    }
    
    func showSparshna() {
        if kUserDefaults.bool(forKey: kDoNotShowTestInfo) {
            self.closeViewNew()
            let objSlideView = CameraViewController.instantiate(fromAppStoryboard: .Camera)
            self.parentVC?.navigationController?.pushViewController(objSlideView, animated: true)
            
            /*
            let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
            let objAlert = storyBoard.instantiateViewController(withIdentifier: "SparshnaAlert") as! SparshnaAlert
            objAlert.modalPresentationStyle = .overCurrentContext
            objAlert.completionHandler = {
                self.closeViewNew()
                let objSlideView = CameraViewController.instantiate(fromAppStoryboard: .Camera)
                self.parentVC?.navigationController?.pushViewController(objSlideView, animated: true)
            }
            self.present(objAlert, animated: true)
            */
        } else {
            let storyBoard = UIStoryboard(name: "SparshnaTestInfo", bundle: nil)
            let objSlideView: SparshnaTestInfoViewController = storyBoard.instantiateViewController(withIdentifier: "SparshnaTestInfoViewController") as! SparshnaTestInfoViewController
            parentVC?.navigationController?.pushViewController(objSlideView, animated: true)

        }
    }
    
    func showPrashna() {
        VikritiQuestionsVC.showScreen(fromVC: self)
    }
}

extension ReferPopupViewController {
    static func updateSocialConnectDetailsFromServer(socialLoginUser: SocialLoginUser, loginType: ARLoginType, completion: @escaping (Bool, String, String)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.addSocialData.rawValue
            var params = ["socialid": socialLoginUser.socialID, "type": loginType.stringValue]
            //send existing user email
            if let empData = kUserDefaults.object(forKey: USER_DATA) as? [String: Any] {
                params["email"] = empData["email"] as? String ?? ""
            }
            if let socialemail = socialLoginUser.email {
                params["socialemail"] = socialemail
            }
            /*if let number = socialLoginUser.phoneNumber {
                params["user_mobile"] = number
            }*/
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: addEarnHistoryheaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        completion(false, APP_NAME, "")
                        return
                    }
                    
                    let isSuccess = dicResponse["status"] as? String == "Sucess"
                    let title = dicResponse["title"] as? String ?? ""
                    let message = dicResponse["message"] as? String ?? ""
                    completion(isSuccess, title, message)
                case .failure(let error):
                    print(error)
                    completion(false, APP_NAME, error.localizedDescription)
                }
            }
        } else {
            completion(false, APP_NAME, NO_NETWORK)
        }
    }
    
    static func addEarmHistoryFromServer(params: [String: Any], completion: @escaping (Bool, String, String)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.addEarnhistory.rawValue

            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: addEarnHistoryheaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        completion(false, APP_NAME, "")
                        return
                    }
                    
                    let isSuccess = dicResponse["status"] as? String == "success"
                    let title = dicResponse["title"] as? String ?? APP_NAME
                    let message = dicResponse["message"] as? String ?? ""
                    completion(isSuccess, title, message)
                case .failure(let error):
                    print(error)
                    completion(false, APP_NAME, error.localizedDescription)
                }
            }
        } else {
            completion(false, APP_NAME, NO_NETWORK)
        }
    }
    
    private class var addEarnHistoryheaders: HTTPHeaders {
        get {
            return ["Authorization": Utils.getAuthToken()]
        }
    }
    
    func testAddEarnHistoryAPIcall() {
        let params = ["activity_favorite_id": 1, "language_id": Utils.getLanguageId()] as [String : Any]
        ReferPopupViewController.addEarmHistoryFromServer(params: params) { (isSuccess, title, message) in
            print("isSuccess : ", isSuccess, "\ntitle : ", title, "\nmessage : ", message)
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
                    self?.closeView()
                }
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(message: message)
            }
        }
    }
    
    func referAFriend() {
        let shareAll = [ Utils.shareRegisterDownloadString ] as [Any]

        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension ReferPopupViewController {
    static func showScreen(ayuSeedEarn: AyuSeedEarn?, fromVC: UIViewController) {
        fromVC.tabBarController?.tabBar.isHidden = true
        let vc = ReferPopupViewController.instantiate(fromAppStoryboard: .AyuSeeds)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.parentVC = fromVC
        vc.ayuSeedEarn = ayuSeedEarn
        fromVC.present(vc, animated: true, completion: nil)
    }
}
