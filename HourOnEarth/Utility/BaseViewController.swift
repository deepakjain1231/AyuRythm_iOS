//
//  BaseViewController.swift
//  HourOnEarth
//
//  Created by Apple on 13/05/20.
//  Copyright © 2020 Pradeep. All rights reserved.
//

import UIKit
import Alamofire

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var headers: HTTPHeaders {
        get {
            return ["Authorization": Utils.getAuthToken()]
        }
    }
    
    #if !APPCLIP
    @IBAction func profileBtnClicked(_ sender: Any) {
        let obj = Story_SideMenu.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
        obj.hidesBottomBarWhenPushed = true
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    
    func startPrakritiTestFlow() {
        let storyBoard = UIStoryboard(name: "InitialFlow", bundle: nil)
        let objDescription = storyBoard.instantiateViewController(withIdentifier: "PrakritiViewController") as! PrakritiViewController
        self.navigationController?.pushViewController(objDescription, animated: true)
    }
    #endif
}

#if !APPCLIP
extension BaseViewController {
    
    func showNavProfileButton() {
        self.createLeftBarButton(0)
    }
    
    func showNavProfileButton_MyHomeViewController(img_view: UIImageView, btn_Profile: UIButton, handlePro: UIView) {
        handlePro.isHidden = true
        btn_Profile.layer.borderWidth = 0
        btn_Profile.layer.borderColor = UIColor.fromHex(hexString: "#F9B014").cgColor
        
        if let urlString = kUserDefaults.value(forKey: kUserImage) as? String, let url = URL(string: urlString) {
            img_view.sd_setImage(with: url, placeholderImage: UIImage.init(named: "icon_userHeader"))
            img_view.layer.cornerRadius = 25
            img_view.clipsToBounds = true
        }
        
        let profileiconType = getNavProfile_Image(notifCount: 0)
        if profileiconType == .Pro {
            btn_Profile.layer.borderWidth = 2
            handlePro.isHidden = false
        }
        else {
            btn_Profile.layer.borderWidth = 0
            handlePro.isHidden = true
        }

        btn_Profile.addTarget(self, action: #selector(self.profileBtnClicked(_:)), for: .touchUpInside)
    }
    
    func getNavProfileBtnImage(notifCount: Int) -> UIImage {
        let isProUser = UserDefaults.user.is_main_subscription
        if notifCount > 0 {
            if isProUser {
                return #imageLiteral(resourceName: "nav-btn-profile-notif-pro")
            } else {
                return #imageLiteral(resourceName: "nav-btn-profile-notif")
            }
        } else {
            if isProUser {
                return #imageLiteral(resourceName: "nav-btn-profile-pro")
            } else {
                return #imageLiteral(resourceName: "icon_userHeader")
            }
        }
    }
    
    func getNavProfile_Image(notifCount: Int) -> ProfileIconType {
        let isProUser = UserDefaults.user.is_main_subscription
        if notifCount > 0 {
            if isProUser {
                return .ProNotification
            } else {
                return .Notification
            }
        } else {
            if isProUser {
                return .Pro
            } else {
                return .kNone
            }
        }
    }
    
    func NotificationFromServer() {
        guard !kSharedAppDelegate.userId.isEmpty else {
            showNavProfileButton()
            return
        }
        
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.notificationList.rawValue
            
            AF.request(urlString, method: .post, parameters: nil, encoding:URLEncoding.default, headers: headers).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? [[String : Any]]) else {
                        return
                    }
                    var arrUnreadCount = 0
                    
                    for dict in dicResponse {
                        let strStatus = dict["readstatus"] as? String
                        if strStatus == "0"
                        {
                            arrUnreadCount += 1
                        }
                    }

                    self.createLeftBarButton(arrUnreadCount)

                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func createLeftBarButton(_ arrUnreadCount: Int) {
        //create a new button
        let imgProfileIcon = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        if let urlString = kUserDefaults.value(forKey: kUserImage) as? String, let url = URL(string: urlString) {
            imgProfileIcon.sd_setImage(with: url, placeholderImage: UIImage.init(named: "icon_userHeader"))
            imgProfileIcon.layer.cornerRadius = 22
            imgProfileIcon.clipsToBounds = true
        }
        
        let view_Pro = UIView.init(frame: CGRect.init(x: 9.5, y: 33, width: 25, height: 11))
        view_Pro.backgroundColor = UIColor.fromHex(hexString: "#F9B014")
        view_Pro.layer.cornerRadius = 5.5
        view_Pro.isUserInteractionEnabled = false
        
        let lbl_Pro = UILabel.init(frame: CGRect.init(x: 5, y: 1, width: 15, height: 9))
        lbl_Pro.text = "Pro"
        lbl_Pro.textAlignment = .center
        lbl_Pro.textColor = .black
        lbl_Pro.font = UIFont.AppFontMedium(8)
        view_Pro.addSubview(lbl_Pro)
        
        let view_Notification = UIView.init(frame: CGRect.init(x: 38, y: 2, width: 8, height: 8))
        view_Notification.backgroundColor = UIColor.red
        view_Notification.layer.cornerRadius = 4
        view_Notification.isUserInteractionEnabled = false
        
        let view_custom = UIControl.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        view_custom.backgroundColor = UIColor.white
        view_custom.layer.borderColor = UIColor.fromHex(hexString: "#F9B014").cgColor
        view_custom.layer.cornerRadius = 22.5
        view_custom.addSubview(imgProfileIcon)
        view_custom.isUserInteractionEnabled = true
        
        let profileiconType = getNavProfile_Image(notifCount: arrUnreadCount)
        if profileiconType == .Pro {
            view_custom.layer.borderWidth = 2
            view_custom.addSubview(view_Pro)
        }
        else if profileiconType == .Notification {
            view_Notification.bringSubviewToFront(view_custom)
            view_custom.addSubview(view_Notification)
        }
        else if profileiconType == .ProNotification {
            view_custom.layer.borderWidth = 2
            view_custom.addSubview(view_Pro)
            view_custom.addSubview(view_Notification)
            view_Notification.bringSubviewToFront(view_custom)
        }

        view_custom.addTarget(self, action: #selector(self.profileBtnClicked(_:)), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: view_custom)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
    }
}
#endif


// MARK: -
extension Utils {
    static var apiCallHeaders: HTTPHeaders {
        get {
            debugPrint("Authorization Token:====\(Utils.getAuthToken())")
            return ["Authorization": Utils.getAuthToken()]
        }
    }
}
