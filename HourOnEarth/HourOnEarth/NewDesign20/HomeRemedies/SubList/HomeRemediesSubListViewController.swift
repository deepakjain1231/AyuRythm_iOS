//
//  HomeRemediesSubListViewController.swift
//  HourOnEarth
//
//  Created by Pradeep on 1/28/19.
//  Copyright © 2019 Pradeep. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import Alamofire

class HomeRemediesSubListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, delegate_click_event, delegateFaceNaadi {
    
    var trial_DialogSingleTime = false
    var is_remedies_subscription = UserDefaults.user.is_remedies_subscribed
    @IBOutlet weak var homeRemedyDetailTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var bg_color = ""
    var arrAllData: [HomeRemediesDetail] = [HomeRemediesDetail]()
    var arrData: [HomeRemediesDetail] = [HomeRemediesDetail]()
    var titleHeading: String = ""
    var isFromAyuverseContentLibrary = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "Search".localized()
        arrAllData = self.arrData
        self.homeRemedyDetailTableView.tableFooterView = UIView()
        self.homeRemedyDetailTableView.rowHeight = UITableView.automaticDimension
        self.homeRemedyDetailTableView.estimatedRowHeight = 100
        self.title = titleHeading
        setBackButtonTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.is_remedies_subscription = UserDefaults.user.is_remedies_subscribed
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension HomeRemediesSubListViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "subListCell") as? SubListCell else {
            return UITableViewCell()
        }
        let dic = arrData[indexPath.item]
        cell.configure(title: dic.item ?? "")
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.bgView.backgroundColor = UIColor.fromHex(hexString: self.bg_color)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.is_remedies_subscription == false {
            self.setupSubscriptionDialouge(indx: indexPath.item)
        }
        else {
            self.goToDetailVC(indexPath_Item: indexPath.item)
        }
    }
    
    func setupSubscriptionDialouge(indx: Int) {
        if UserDefaults.user.free_remedies_count == UserDefaults.user.home_remedies_trial {
            if self.trial_DialogSingleTime == false {
                self.trial_DialogSingleTime = true
                self.dialouge_trial_ended()
            }
            else {
                self.dialouge_subscription()
            }
            return
        }
        
        if UserDefaults.user.free_remedies_count < UserDefaults.user.home_remedies_trial {
            self.dialouge_subscription()
            return
        }
        
        self.goToDetailVC(indexPath_Item: indx)
    }
    
    func dialouge_trial_ended() {
        if let parent = appDelegate.window?.rootViewController {
            let objDialouge = FreeTrialEndedDialouge(nibName:"FreeTrialEndedDialouge", bundle:nil)
            objDialouge.screen_from = ScreenType.from_home_remedies
            objDialouge.delegate = self
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
            parent.view.addSubview((objDialouge.view)!)
            objDialouge.didMove(toParent: parent)
        }
    }
    
    func handle_dialouge_btn_click_event(_ success: Bool) {
        if success {
            self.dialouge_subscription()
        }
    }
    
    //MARK: - DIALOUGE DELEGATE HANDLE
    func dialouge_subscription() {
        if let parent = appDelegate.window?.rootViewController {
            let objDialouge = HomeRemediesDialouge(nibName:"HomeRemediesDialouge", bundle:nil)
            objDialouge.screen_from = ScreenType.from_home_remedies
            objDialouge.delegate = self
            parent.addChild(objDialouge)
            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
            parent.view.addSubview((objDialouge.view)!)
            objDialouge.didMove(toParent: parent)
        }
    }
    
    func subscribe_tryNow_click(_ success: Bool, type: ScreenType) {
        if success {
            if type == ScreenType.from_home_remedies {
                let obj = FaceNaadiSubscriptionListVC.instantiate(fromAppStoryboard: .FaceNaadi)
                obj.str_screenFrom = type
                obj.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(obj, animated: true)
            }
            else if type == ScreenType.from_PrimeMember {
                let vc = ChooseSubscriptionPlanVC.instantiate(fromAppStoryboard: .Subscription)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //*****************************************************//
    
    func goToDetailVC(indexPath_Item: Int) {
        let storyBoard = UIStoryboard(name: "HomeRemedies", bundle: nil)
        let objRemedyView:RemediesDetailsViewController = storyBoard.instantiateViewController(withIdentifier: "RemediesDetailsViewController") as! RemediesDetailsViewController
        objRemedyView.dicSelectedInfo = arrData[indexPath_Item]
        objRemedyView.isFromAyuverseContentLibrary = isFromAyuverseContentLibrary
        self.navigationController?.pushViewController(objRemedyView, animated: true)
    }
}


extension HomeRemediesSubListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        self.arrData = self.arrAllData
        self.homeRemedyDetailTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        if searchText == "" {
            self.arrData = self.arrAllData
        } else {
            self.arrData = arrAllData.filter { (data: HomeRemediesDetail) -> Bool in
                let item = data.item ?? ""
                if item.uppercased().contains(searchText.uppercased()) {
                    return true
                } else {
                    return false
                }
            }
        }
        self.homeRemedyDetailTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       clearSearch()
    }
    
    func clearSearch() {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.arrData = self.arrAllData
        homeRemedyDetailTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
