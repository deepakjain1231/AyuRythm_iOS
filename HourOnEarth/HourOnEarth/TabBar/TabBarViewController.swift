//
//  TabBarViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 8/27/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, delegateTeremSelection {

    override func viewDidLoad() {
        super.viewDidLoad()
        //removeTabbarItemsText()
        self.delegate = self
        //self.tabBar.tintColor = UIColor.red
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //handlePushNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBar.items {
            for item in items {
                item.title = ""
                item.imageInsets = UIEdgeInsets.init(top: 6, left: 0, bottom: -6, right: 0);
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let navController = viewController as? UINavigationController {
            if navController.viewControllers.first is HOEForYouHomeVC {
                
                guard !kSharedAppDelegate.userId.isEmpty else {
                    Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view recommendations".localized(), controller: self)
                    return false
                }
                
                //If registered but not given test
                if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil && kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
                    Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti and Vikriti assessment to view recommendations".localized(), controller: self)
                    return false
                } else if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil {
                    Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti assessment to view recommendations".localized(), controller: self)
                    return false
                } else if kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
                    Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Vikriti assessment to view recommendations".localized(), controller: self)
                    return false
                }
            } else if navController.viewControllers.first is MPHomeVC {
                if Locale.current.isCurrencyCodeInINR {
                    //If registered but not given test
                    if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil && kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
                        Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti and Vikriti assessment to view personalized products".localized(), controller: self)
                        return false
                    } else if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil {
                        Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti assessment to view personalized products".localized(), controller: self)
                        return false
                    } else if kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
                        Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Vikriti assessment to view personalized products".localized(), controller: self)
                        return false
                    }
                } else {
                    showAlert(title: "Feature Unavailable".localized(), message: "Sorry, this feature is currently not available in your country".localized())
                    return false
                }
            } else if navController.viewControllers.first is FavouritesViewController {
                guard !kSharedAppDelegate.userId.isEmpty else {
                    Utils.showAlertWithTitleInController(APP_NAME, message: "Please Register now to view Favourites section".localized(), controller: self)
                    return false
                }
                
                //If registered but not given test
                if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil && kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
                    Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti and Vikriti assessment to view recommendations".localized(), controller: self)
                    return false
                } else if kUserDefaults.value(forKey: RESULT_PRAKRITI) == nil {
                    Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Prakriti assessment to view recommendations".localized(), controller: self)
                    return false
                } else if kUserDefaults.value(forKey: RESULT_VIKRITI) == nil {
                    Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your Vikriti assessment to view recommendations".localized(), controller: self)
                    return false
                }
            } else if navController.viewControllers.first is AyuSeedsViewController {
                guard !kSharedAppDelegate.userId.isEmpty else {
                    Utils.showAlertWithTitleInController(APP_NAME, message: "Please complete your assessment or Register now to view recommendations".localized(), controller: self)
                    return false
                }
                if let ayuSeedsViewController = navController.viewControllers.first as? AyuSeedsViewController {
                    ayuSeedsViewController.isShowAyuSeedInro = false
                }
                
            }
            else if navController.viewControllers.first is ARAyuverseHomeVC {
                guard !kSharedAppDelegate.userId.isEmpty else {
                    Utils.showAlertWithTitleInController(APP_NAME, message: "Please Register now to view AyuVerse".localized(), controller: self)
                    return false
                }
                
                if UserDefaults.standard.object(forKey: "Welcome_AyuVerse") != nil {
                    return true
                }
                let vc = ARAyuVerseWelcomeVC.instantiate(fromAppStoryboard: .Ayuverse)
                vc.delegate = self
                vc.modalPresentationStyle = .fullScreen
                kSharedAppDelegate.window?.rootViewController?.present(vc, animated: true)
               return false
           }
        }
        return true
    }
    
    
    //MARK: - Terms and Condition Accepted
    func terms_condition_selection(_ success: Bool) {
        if success {
            self.selectedIndex = 4
        }
    }
    
}

extension TabBarViewController {
    func handlePushNotification() {
        if let notificationInfo = kSharedAppDelegate.notificationInfo {
            selectedIndex = notificationInfo.tabSelectedIndex
            kSharedAppDelegate.notificationInfo = nil
            print("tabbar selectedIndex after: ", selectedIndex)
        }
    }
    
    static func handlePushNotification() {
        if let notificationInfo = kSharedAppDelegate.notificationInfo {
            if let topVC = UIApplication.topViewController() {
                if let tabbarVC = topVC.tabBarController {
                    tabbarVC.switchToIndex(index: notificationInfo.tabSelectedIndex)
                } else if let presentingVC = UIViewController.findRootPresentingVC(topVC) {
                    presentingVC.dismiss(animated: true) {
                        let tabbarVC = (presentingVC as? UITabBarController) ?? presentingVC.tabBarController
                        tabbarVC?.switchToIndex(index: notificationInfo.tabSelectedIndex)
                    }
                }
            }
            if !notificationInfo.isThereSecondLavelRedirect {
                kSharedAppDelegate.notificationInfo = nil
            }
        }
    }
}

extension UITabBarController {
    func switchToIndex(index: Int) {
        if selectedIndex != index {
            selectedIndex = index
            print("tabbar selectedIndex after: ", selectedIndex)
        } else {
            viewControllers?[selectedIndex].viewWillAppear(false)
            viewControllers?[selectedIndex].viewDidAppear(false)
        }
        //viewControllers?[selectedIndex].viewDidAppear(false)
    }
}

extension UIViewController {
    static func findRootPresentingVC(_ vc: UIViewController? = nil) -> UIViewController? {
        if let pvc = vc?.presentingViewController {
            return findRootPresentingVC(pvc)
        }
        return vc
    }
}
