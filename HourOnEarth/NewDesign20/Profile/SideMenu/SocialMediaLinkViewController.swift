//
//  SocialMediaLinkViewController.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 11/08/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire

class SMLinkModel {
    var title: String
    var type: ARLoginType
    var email: String? = nil
    var isLinked: Bool {
        guard let email = email else {
            return false
        }
        
        return !email.isEmpty
    }

    public init(title: String, type: ARLoginType) {
        self.title = title
        self.type = type
        
        switch type {
        case .gmail:
            self.email = kUserDefaults.string(forKey: kGoogleLinkEmail)
        case .facebook:
            self.email = kUserDefaults.string(forKey: kFacebookLinkEmail)
        case .apple:
            //do for apple id
            break
        default:
            break
        }
    }
    
    func saveSocialLinkEmail(email: String?) {
        guard let email = email else { return }
        self.email = email
        switch type {
        case .gmail:
            kUserDefaults.set(email, forKey: kGoogleLinkEmail)
        case .facebook:
            kUserDefaults.set(email, forKey: kFacebookLinkEmail)
        case .apple:
            //do for apple id
            break
        default:
            break
        }
    }
    
    static func saveSocialLinkEmails(from data: [String : Any]) {
        if let googleLinkEmail = data["social_gmail"] as? String, googleLinkEmail != "0", !googleLinkEmail.isEmpty {
            kUserDefaults.set(googleLinkEmail, forKey: kGoogleLinkEmail)
        } else {
            kUserDefaults.set(nil, forKey: kGoogleLinkEmail)
        }
        if let facebookLinkEmail = data["social_email"] as? String, facebookLinkEmail != "0", !facebookLinkEmail.isEmpty {
            kUserDefaults.set(facebookLinkEmail, forKey: kFacebookLinkEmail)
        } else {
            kUserDefaults.set(nil, forKey: kFacebookLinkEmail)
        }
    }
}

class SocialMediaLinkViewController: UITableViewController {

    var socialLoginHelper: SocialLoginHelper?
    var dataSource = [SMLinkModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Link with Social Media".localized()
        tableView.tableFooterView = UIView()
        dataSource = [SMLinkModel(title: "Link to Google", type: .gmail),
                      SMLinkModel(title: "Link to Facebook", type: .facebook)/*,
                      SMLinkModel(title: "Link to Apple", type: .apple)*/]
    }
}

extension SocialMediaLinkViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SocialLinkCell") else {
            return UITableViewCell()
        }
        
        let model = dataSource[indexPath.row]
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.email ?? ""
        cell.accessoryType = model.isLinked ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        
        guard !model.isLinked else {
            print("Already Link")
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        switch model.type {
        case .gmail:
            print("Link to Google")
            connectToGoogle()
        case .facebook:
            print("Link to Facebook")
            connectToFacebook()
        case .apple:
            print("Link to Apple")
            if #available(iOS 13, *) {
                connectToApple()
            } else {
                // Fallback on earlier versions
                showAlert(message: "Apple sign in only available in iOS 13 and later version devices")
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SocialMediaLinkViewController {
    func connectToFacebook() {
        showActivityIndicator()
        socialLoginHelper = SocialLoginHelper(presentingVC: self)
        socialLoginHelper?.doFacebookSignIn(completion: socialLoginCompletion)
    }
    
    func connectToGoogle() {
        showActivityIndicator()
        socialLoginHelper = SocialLoginHelper(presentingVC: self)
        socialLoginHelper?.doGoogleSignIn(completion: socialLoginCompletion)
    }
    
    @available(iOS 13, *)
    func connectToApple() {
        showActivityIndicator()
        socialLoginHelper = SocialLoginHelper(presentingVC: self)
        socialLoginHelper?.doAppleSignIn(completion: socialLoginCompletion)
    }
    
    func socialLoginCompletion(isSuccess: Bool, message: String, user: SocialLoginUser?, loginType: ARLoginType) {
        print("isSuccess : ", isSuccess, "\nmessage : ", message, "\nemail : ", user?.email, "\nphoneNumber : ", user?.phoneNumber, "\nloginType : ", loginType)
        if isSuccess, let user = user {
            //connectSocialLinkAndEarn(email: email, number: user.phoneNumber, loginType: loginType)
            hideActivityIndicator()
            connectSocialLinkAndEarn(socialLoginUser: user, loginType: loginType)
        } else {
            hideActivityIndicator()
            showAlert(message: message)
        }
        socialLoginHelper = nil
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
                    self?.updateView(with: socialLoginUser, loginType: loginType)
                    self?.showAlert(title: title, message: message)
                }
            } else {
                self?.hideActivityIndicator()
                self?.showAlert(message: message)
            }
        }
    }
    
    func updateView(with socialLoginUser: SocialLoginUser, loginType: ARLoginType) {
        if let model = dataSource.first(where: { $0.type == loginType }) {
            model.saveSocialLinkEmail(email: socialLoginUser.email)
            tableView.reloadData()
        }
    }
}
