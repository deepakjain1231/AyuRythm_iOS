//
//  ARGroupRequestListVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 24/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARGroupRequestListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var requestInfoL: UILabel!
    @IBOutlet weak var btn_AcceptAll: UIButton!
    
    var pageNO = 0
    var data_limit = 25
    var isLoading = false
    
    var requests: [MemberList] = []
    var group: GroupData?
    var myGroup: MyGroupData?
    var is_MyGroup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btn_AcceptAll.isHidden = true
        self.btn_AcceptAll.setTitle("Accept all".localized(), for: .normal)
        self.requestInfoL.text = String.init(format: "You have %@ spot left".localized(), "0")
        setupUI()
        getGroupMembersList()
    }
    
    func setupUI() {
        self.title = "Join requests".localized()
        setBackButtonTitle()
        tableView.register(nibWithCellClass: ARGroupMemberCell.self)
    }

    @IBAction func acceptAllBtnPressed(sender: UIBarButtonItem) {
        acceptRejectMember(flag: "", acceptType: "1", member_userID: "")
    }
    func acceptRejectMember(flag: String, acceptType: String, member_userID: String){
        
        var groupID = group?.groupID ?? ""
        if self.is_MyGroup {
            groupID = myGroup?.groupID ?? ""
        }

        let params = ["group_id": groupID, "user_id": member_userID, "flag": flag, "acceptall": acceptType] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .acceptRejectMember, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let acceptData = try? JSONDecoder().decode(LikeQAModel.self, from: responseJSON.rawData())
                if acceptData?.status == "success"{
                    self?.pageNO = 0
                    self?.getGroupMembersList()

                    let myGroupMemberCount:Int = Int(self?.myGroup?.groupMembers ?? "0") ?? 0
                    
                    if let stackVCs = self?.navigationController?.viewControllers {
                        if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupSettingVC.self }) {

                            if acceptType == "" {
                                let currentGroupMemmber = myGroupMemberCount + 1
                                (activeSubVC as? ARGroupSettingVC)?.myGroup?.groupMembers = "\(currentGroupMemmber)"
                            }
                            else if acceptType == "1" {
                                let currentGroupMemmber = myGroupMemberCount + (self?.requests.count ?? 0)
                                (activeSubVC as? ARGroupSettingVC)?.myGroup?.groupMembers = "\(currentGroupMemmber)"
                            }
                            (activeSubVC as? ARGroupSettingVC)?.setupUI_MyGroup()
                        }
                    }
                    
                    
                    if let stackVCs = self?.navigationController?.viewControllers {
                        if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARMyGroupDetailVC.self }) {

                            let dic_myGroup = (activeSubVC as? ARMyGroupDetailVC)?.group

                            if acceptType == "" {
                                let currentGroupMemmber = myGroupMemberCount + 1
                                dic_myGroup?.groupMembers = "\(currentGroupMemmber)"
                            }
                            else if acceptType == "1" {
                                let currentGroupMemmber = myGroupMemberCount + (self?.requests.count ?? 0)
                                dic_myGroup?.groupMembers = "\(currentGroupMemmber)"
                            }
                            (activeSubVC as? ARMyGroupDetailVC)?.groupDetailView.updateUI(from: dic_myGroup!)
                        }
                    }
                    
                    if let stackVCs = self?.navigationController?.viewControllers {
                        if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupViewAllVC.self }) {
                            (activeSubVC as! ARGroupViewAllVC).Pullto_refreshScreen()
                        }
                    }

                    
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: acceptData?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func removeFromGroup(userId: String){
        let params = ["group_id": group?.groupID ?? "", "delete_user_id": userId] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .removeGroupMember, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let acceptData = try? JSONDecoder().decode(LikeQAModel.self, from: responseJSON.rawData())
                if acceptData?.status == "success"{
                    self?.pageNO = 0
                    self?.getGroupMembersList()
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: acceptData?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    func getGroupMembersList(){
        
        var groupID = group?.groupID ?? ""
        if self.is_MyGroup {
            groupID = myGroup?.groupID ?? ""
        }
        
        if self.pageNO == 0 {
            self.showActivityIndicator()
        }
        
        let params = ["group_id": groupID, "membertype": "2", "limit": self.data_limit, "offset": self.pageNO] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .getGroupMembers, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            self?.hideActivityIndicator()
            if isSuccess, let responseJSON = responseJSON {
                let groupMember = try? JSONDecoder().decode(GroupMember.self, from: responseJSON.rawData())
                if groupMember?.status == "success"{
                    
                    let arr_Data = groupMember?.data ?? []
                    
                    if self?.pageNO == 0 {
                        self?.requests.removeAll()
                    }

                    if arr_Data.count != 0 {
                        if self?.pageNO == 0 {
                            self?.requests = groupMember?.data ?? []
                        }
                        else {
                            for dic in arr_Data {
                                self?.requests.append(dic)
                            }
                        }
                        self?.isLoading = false
                    }
                    else {
                        self?.isLoading = true
                    }

                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: groupMember?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                
                self?.btn_AcceptAll.isHidden = self?.requests.count == 0 ? true : false
                var spot = Int(self?.myGroup?.groupMemberLimit ?? "0")! - Int(self?.myGroup?.groupMembers ?? "0")!
                if spot < 0{
                    spot = 0
                }
                self?.requestInfoL.text = String.init(format: "You have %@ spot left".localized(), "\(spot)")
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
}

extension ARGroupRequestListVC: UITableViewDelegate, UITableViewDataSource {
    
    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global().async {
                // Fake background loading task for 2 seconds
                sleep(2)
                // Download more data here
                DispatchQueue.main.async {
                    self.pageNO = self.requests.count
                    self.getGroupMembersList()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ARGroupMemberCell.self, for: indexPath)
        cell.member = requests[safe: indexPath.row]
        cell.delegate = self
        cell.updateUI(isShowDeleteBtn: false, isShowRequestBtns: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.requests.count - 10, !isLoading {
            loadMoreData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension ARGroupRequestListVC: ARGroupMemberCellDelegate {
    func groupMemberCell(cell: ARGroupMemberCell, acceptMember member: MemberList) {
        ARLog("Accept member : \(member.userID ?? "")")
        acceptRejectMember(flag: "1", acceptType: "", member_userID: member.userID ?? "")
    }
    
    func groupMemberCell(cell: ARGroupMemberCell, rejectMember member: MemberList) {
        ARLog("Reject member : \(member)")
        acceptRejectMember(flag: "0", acceptType: "2", member_userID: member.userID ?? "")
    }
    func groupMemberCell(cell: ARGroupMemberCell, deleteMember member: MemberList) {
        removeFromGroup(userId: member.userID ?? "")
    }
}

