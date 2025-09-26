//
//  ARGroupSettingVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 24/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SDWebImage

class ARGroupSettingVC: UIViewController {

    var pageNO = 0
    var data_limit = 20
    var isLoading = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupDetailView: ARGroupDetailView!
    @IBOutlet weak var groupNameL: UILabel!
    @IBOutlet weak var groupIv: UIImageView!
    @IBOutlet weak var adminProfileView: ARUserProfileView!
    @IBOutlet weak var aboutL: UILabel!
    @IBOutlet weak var lbl_aboutTitle: UILabel!
    @IBOutlet weak var lbl_adminTitle: UILabel!
    @IBOutlet weak var lbl_membersTitle: UILabel!
    @IBOutlet weak var lbl_joinRequest_Title: UILabel!
    
    @IBOutlet weak var groupType: UILabel!
    @IBOutlet weak var privacyTitle: UILabel!
    @IBOutlet weak var joinRequestCountBtn: ResizableButton!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBOutlet weak var stack_Nottification: UIStackView!
    @IBOutlet weak var stack_JoinRequest: UIStackView!
    
    
    
    @IBOutlet weak var countMembersL: UILabel!
    var members: [MemberList] = []
    var group: GroupData?
    var myGroup: MyGroupData?
    var from = "group"
    var is_MyGroup = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Groups".localized()
        self.privacyTitle.text = "Privacy".localized()
        self.lbl_aboutTitle.text = "About".localized()
        self.lbl_adminTitle.text = "Admin".localized()
        self.lbl_membersTitle.text = "Members".localized()
        self.lbl_joinRequest_Title.text = "Join requests".localized()
        if self.is_MyGroup {
            setupUI_MyGroup()
        }
        else {
            setupUI()
        }
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(TapResponce(_:)))
        self.groupIv.isUserInteractionEnabled = true
        self.groupIv.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupUI() {
        setBackButtonTitle()
        tableView.register(nibWithCellClass: ARGroupMemberCell.self)
        adminProfileView.updateUI(for: .groupAdmin)
        adminProfileView.profilePicIV.af_setImage(withURLString: group?.userProfile?.userProfile)
        adminProfileView.usernameL.text = group?.userProfile?.userName
        //adminProfileView. = (group.groupMembers ?? "0") + " " + "Members"
        
        var strgroupName = group?.groupLabel?.trimed().base64Decoded()
        if strgroupName == nil {
            strgroupName = group?.groupLabel
        }
        groupNameL.text = strgroupName
        groupDetailView.membersL.text = (group?.groupMembers ?? "0") + " " + "Members".localized()
        if (group?.groupMembers ?? "0") == "1" || (group?.groupMembers ?? "0") == "0" {
            groupDetailView.membersL.text = (group?.groupMembers ?? "0") + " " + "Member".localized()
        }
        
        if group?.groupType == "1"{
            groupType.text = "Private".localized()
        }else{
            groupType.text = "Public".localized()
        }
        
        var strgroupDesc = self.group?.groupDescription?.trimed().base64Decoded()
        if strgroupDesc == nil {
            strgroupDesc = self.group?.groupDescription
        }
        self.aboutL.text = strgroupDesc
        
        countMembersL.text = "(" + (group?.groupMembers ?? "0")  + ")"
        getGroupMembersList(group?.groupID ?? "")
    }
    
    func setupUI_MyGroup() {
        setBackButtonTitle()
        groupIv.layer.cornerRadius = 8
        groupIv.layer.masksToBounds = true
        self.stack_Nottification.isHidden = true
        tableView.register(nibWithCellClass: ARGroupMemberCell.self)
        adminProfileView.updateUI(for: .groupAdmin)
        adminProfileView.profilePicIV.af_setImage(withURLString: myGroup?.userProfile?.userProfile)
        adminProfileView.usernameL.text = myGroup?.userProfile?.userName
        
        var strgroupName = myGroup?.groupLabel?.trimed().base64Decoded()
        if strgroupName == nil {
            strgroupName = myGroup?.groupLabel
        }
        groupNameL.text = strgroupName

        groupDetailView.membersL.text = (myGroup?.groupMembers ?? "0") + " " + "Members".localized()
        if (myGroup?.groupMembers ?? "0") == "1" || (myGroup?.groupMembers ?? "0") == "0" {
            groupDetailView.membersL.text = (myGroup?.groupMembers ?? "0") + " " + "Member".localized()
        }
        
        self.joinRequestCountBtn.setImage(nil, for: .normal)
        self.joinRequestCountBtn.isUserInteractionEnabled = false
        
        var str_img_URL = self.myGroup?.groupImage ?? ""
        if str_img_URL == "" {
            groupIv.image = appImage.group_default_pic
        }
        else {
            if !(str_img_URL.contains("https")) {
                str_img_URL = image_BaseURL + str_img_URL
            }
            groupIv.sd_setImage(with: URL.init(string: str_img_URL), placeholderImage: appImage.group_default_pic, options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)
        }
        
        if myGroup?.groupType == "1"{
            groupType.text = "Private".localized()
            self.stack_Nottification.isHidden = true
            if kSharedAppDelegate.userId == self.myGroup?.groupAdmin {
                self.stack_JoinRequest.isHidden = false
            }
        }else{
            groupType.text = "Public".localized()
            self.stack_JoinRequest.isHidden = true
        }
        
        
        var strgroupDesc = self.myGroup?.groupDescription?.trimed().base64Decoded()
        if strgroupDesc == nil {
            strgroupDesc = self.myGroup?.groupDescription
        }
        self.aboutL.text = strgroupDesc
        countMembersL.text = "(" + (myGroup?.groupMembers ?? "0")  + ")"
        getGroupMembersList(myGroup?.groupID ?? "")
    }
    
    @objc func TapResponce(_ sender: UITapGestureRecognizer) {
        SMPhotoViewer.showImage(toView: self, image: self.groupIv.image!, fromView: self.groupIv)
    }
    
    func getGroupMembersList(_ groupID: String){

        if self.pageNO == 0 {
            self.showActivityIndicator()
        }
        
        let params = ["group_id": groupID, "membertype": "1", "limit": self.data_limit, "offset": self.pageNO] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .getGroupMembers, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            self?.hideActivityIndicator()
            if isSuccess, let responseJSON = responseJSON {
                let groupMember = try? JSONDecoder().decode(GroupMember.self, from: responseJSON.rawData())
                if groupMember?.status == "success"{
                    
                    let arr_Data = groupMember?.data ?? []
                    
                    if self?.pageNO == 0 {
                        self?.members.removeAll()
                    }

                    if arr_Data.count != 0 {
                        if self?.pageNO == 0 {
                            self?.members = groupMember?.data ?? []
                            self?.members.sort(by: {$0.userName ?? "" < $1.userName ?? ""})
                        }
                        else {
                            for dic in arr_Data {
                                self?.members.append(dic)
                            }
                        }
                        self?.isLoading = false
                    }
                    else {
                        self?.isLoading = true
                    }

                    self?.tableView.reloadData()
                    if self?.pageNO == 0 {
                        getGroupWaitingMembersList()
                    }
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: groupMember?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
        
        func getGroupWaitingMembersList(){
            
            var groupID = group?.groupID ?? ""
            if self.is_MyGroup {
                groupID = myGroup?.groupID ?? ""
            }

            let params = ["group_id": groupID, "membertype": "2", "limit": "5000", "offset": "0"] as [String : Any]
            Utils.doAyuVerseAPICall(endPoint: .getGroupMembers, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
                if isSuccess, let responseJSON = responseJSON {
                    let groupMember = try? JSONDecoder().decode(GroupMember.self, from: responseJSON.rawData())
                    if groupMember?.status == "success"{
                        
                        if groupMember?.data?.count != 0 {
                            self?.joinRequestCountBtn.isUserInteractionEnabled = true
                            self?.joinRequestCountBtn.setImage(UIImage.init(named: "arrow-black"), for: .normal)
                        }
                        self?.joinRequestCountBtn.setTitle(String(groupMember?.data?.count ?? 0), for: .normal)
                        
                    }else{
                        let alert = UIAlertController(title: "Error".localized(), message: groupMember?.message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                        self?.present(alert, animated: true)
                    }
                    self?.hideActivityIndicator()
                } else {
                    self?.hideActivityIndicator(withMessage: message)
                }
            }
        }
    }
    func leaveGroup(){
        var group_ID = group?.groupID ?? ""
        if self.is_MyGroup {
            group_ID = myGroup?.groupID ?? ""
        }
        self.showActivityIndicator()
        let params = ["group_id": group_ID] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .leaveAGroup, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let acceptData = try? JSONDecoder().decode(LikeQAModel.self, from: responseJSON.rawData())
                if acceptData?.status == "success"{
                    
                    if kSharedAppDelegate.userId == self?.myGroup?.groupAdmin {
                        self?.getGroupMembersList(group_ID)
                    }
                    else {
                        let alert = UIAlertController(title: "", message: acceptData?.message ?? "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { actionnn in
                            
                            var is_FindVC = false
                            if let stackVCs = self?.navigationController?.viewControllers {
                                if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupViewAllVC.self }) {
                                    is_FindVC = true
                                    (activeSubVC as! ARGroupViewAllVC).pageNO = 0
                                    (activeSubVC as! ARGroupViewAllVC).getMyGroupList(false)
                                    self?.navigationController?.popToViewController(activeSubVC, animated: false)
                                }
                            }
                            
                            if is_FindVC == false {
                                if let stackVCs = self?.navigationController?.viewControllers {
                                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARAyuverseHomeVC.self }) {
                                        is_FindVC = true
                                        self?.navigationController?.popToViewController(activeSubVC, animated: false)
                                    }
                                }
                            }
                            
                            if is_FindVC == false {
                                self?.navigationController?.popViewController(animated: true)
                            }

                        }))
                        self?.present(alert, animated: true)
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
        
        self.showActivityIndicator()
        var group_ID = group?.groupID ?? ""
        if self.is_MyGroup {
            group_ID = myGroup?.groupID ?? ""
        }
        
        let params = ["group_id": group_ID, "delete_user_id": userId] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .removeGroupMember, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            self?.hideActivityIndicator()
            if isSuccess, let responseJSON = responseJSON {
                let acceptData = try? JSONDecoder().decode(LikeQAModel.self, from: responseJSON.rawData())
                if acceptData?.status == "success"{
                    var memberCount: Int = Int(self?.myGroup?.groupMembers ?? "") ?? 0
                    memberCount = memberCount - 1
                    self?.myGroup?.groupMembers = "\(memberCount)"
                    self?.countMembersL.text = "(" + "\(memberCount)"  + ")"
                    self?.groupDetailView.membersL.text = "\(memberCount)" + " " + "Members".localized()
                    if memberCount == 1 {
                        self?.groupDetailView.membersL.text = "\(memberCount)" + " " + "Member".localized()
                    }
                    
                    if let stackVCs = self?.navigationController?.viewControllers {
                        if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARMyGroupDetailVC.self }) {
                            (activeSubVC as! ARMyGroupDetailVC).group = self?.myGroup
                            (activeSubVC as! ARMyGroupDetailVC).groupDetailView.updateUI(from: (self?.myGroup)!)
                        }
                    }

                    if let stackVCs = self?.navigationController?.viewControllers {
                        if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupViewAllVC.self }) {
                            (activeSubVC as! ARGroupViewAllVC).Pullto_refreshScreen()
                        }
                    }

                    self?.getGroupMembersList(group_ID)
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
    

    @IBAction func moreOptionBtnPressed(sender: UIBarButtonItem) {
        if kSharedAppDelegate.userId == self.myGroup?.groupAdmin {
            showMoreActionForEditDeleteAlert()
        }
        else {
            showMoreActionAlert()
        }
        
    }
    
    @IBAction func showGroupRequestBtnPressed(sender: UIButton) {
        let vc = ARGroupRequestListVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.group = group
        vc.myGroup = myGroup
        vc.is_MyGroup = self.is_MyGroup
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
}

extension ARGroupSettingVC: UITableViewDelegate, UITableViewDataSource {
    
    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global().async {
                // Fake background loading task for 2 seconds
                sleep(2)
                // Download more data here
                DispatchQueue.main.async {
                    self.pageNO = self.members.count
                    var grrouppID = self.group?.groupID ?? ""
                    if grrouppID == "" {
                        grrouppID = self.myGroup?.groupID ?? ""
                    }
                    self.getGroupMembersList(grrouppID)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ARGroupMemberCell.self, for: indexPath)
        cell.member = members[indexPath.row]
        cell.delegate = self
        
        if kSharedAppDelegate.userId == self.myGroup?.groupAdmin {
            if members[indexPath.row].userID == kSharedAppDelegate.userId {
                cell.updateUI(isShowDeleteBtn: false)
            }
            else {
                cell.updateUI(isShowDeleteBtn: true)
            }
        }
        else {
            cell.updateUI(isShowDeleteBtn: false)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.members.count - 5, !isLoading {
            loadMoreData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension ARGroupSettingVC: ARGroupMemberCellDelegate {
    func groupMemberCell(cell: ARGroupMemberCell, deleteMember member: MemberList) {
        ARLog("Delete member : \(member)")

        let alert = UIAlertController(title: "Do you really want to remove this member?".localized(), message: "Are you sure you want to remove this member from your group?".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Remove".localized(), style: .destructive){_ in
            self.removeFromGroup(userId: member.userID ?? "")
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        self.present(alert, animated: true)

    }
    
    
}

extension ARGroupSettingVC {
    func showMoreActionAlert() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
//        actionSheet.addAction(UIAlertAction(title: "Search".localized(), style: .default, handler: { _ in
//            ARLog("Search")
//        }))
        
        actionSheet.addAction(UIAlertAction(title: "Leave Group".localized(), style: .destructive, handler: { _ in
            ARLog("Leave Group")
            let alert = UIAlertController(title: "Do you really want to leave?".localized(), message: "Are you sure you want to leave this group?".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Leave".localized(), style: .destructive){_ in
                self.leaveGroup()
            })
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
            self.present(alert, animated: true)
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showMoreActionForEditDeleteAlert() {

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))

        actionSheet.addAction(UIAlertAction(title: "Edit".localized(), style: .default, handler: { _ in
            ARLog("Edit Group")
            
            //Edit Group
            let vc = ARCreateGroupVC.instantiate(fromAppStoryboard: .Ayuverse)
            vc.is_EditGroupDetail = true
            vc.dic_groupDetail = self.myGroup
            self.navigationController?.pushViewController(vc, animated: true)
            
        }))


        actionSheet.addAction(UIAlertAction(title: "Delete Group".localized(), style: .destructive, handler: { _ in
            ARLog("Delete Group")
            
            let alert = UIAlertController(title: "Do you really want to delete?".localized(), message: "Are you sure you want to delete this group?".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive){_ in
                self.callAPIforDeleteGroup()
            })
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
            self.present(alert, animated: true)
        }))
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    
    //MARK: - API Call for Delete Group
    func callAPIforDeleteGroup() {
        self.showActivityIndicator()
        let group_ID = myGroup?.groupID ?? ""
        
        let params = ["group_id": group_ID] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .DeleteAGroup, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let acceptData = try? JSONDecoder().decode(LikeQAModel.self, from: responseJSON.rawData())
                if acceptData?.status == "success"{
                    
                    let alert = UIAlertController(title: "", message: acceptData?.message ?? "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { actionnn in
                        
                        var is_FindVC = false
                        if let stackVCs = self?.navigationController?.viewControllers {
                            if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupViewAllVC.self }) {
                                is_FindVC = true
                                (activeSubVC as! ARGroupViewAllVC).pageNO = 0
                                (activeSubVC as! ARGroupViewAllVC).getMyGroupList(false)
                                self?.navigationController?.popToViewController(activeSubVC, animated: false)
                            }
                        }
                        
                        if is_FindVC == false {
                            if let stackVCs = self?.navigationController?.viewControllers {
                                if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARAyuverseHomeVC.self }) {
                                    is_FindVC = true
                                    self?.navigationController?.popToViewController(activeSubVC, animated: false)
                                }
                            }
                        }
                        
                        if is_FindVC == false {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }))
                    self?.present(alert, animated: true)
                }
                else {
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
}

