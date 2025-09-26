//
//  ARGroupListVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 10/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SDWebImage


enum AyuVerse_DataType: Int {
    case Ayu_none
    case MyGroup
    case PopularGroup
}

class AyuVerse_Data {
    var title: String?
    var type: AyuVerse_DataType
    var subData: [Any]

    internal init(title: String? = nil, type: AyuVerse_DataType = .Ayu_none, subData: [Any]) {
        self.title = title
        self.type = type
        self.subData = subData
    }
}



class ARGroupListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lockIv: UIImageView!
    @IBOutlet weak var img_view_Nodata: UIImageView!
    @IBOutlet weak var lbl_Nodata_Title: UILabel!
    @IBOutlet weak var lbl_Nodata_subTitle: UILabel!
    
    @IBOutlet weak var view_Nodata: UIView!
    @IBOutlet weak var lbl_CreateGroup: UILabel!
    @IBOutlet weak var view_CreateGroup_BG: UIView!
    @IBOutlet weak var icon_Plue: UIImageView!
    @IBOutlet weak var view_SearchBG: UIView!
    @IBOutlet weak var txt_Search: UITextField!
    @IBOutlet weak var constraint_view_SearchBG_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_lbl_CreateGroup_Leading: NSLayoutConstraint!

    var is_GroupCreate_Permission = false
    var arr_Popular_groupList: [GroupData] = []
    var arr_myGroupList: [MyGroupData] = []
    var arr_All_Popular_groupList: [GroupData] = []
    var arr_All_myGroupList: [MyGroupData] = []
    
    var userLevel = ""
    
    var arr_dataSource = [AyuVerse_Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view_Nodata.isHidden = true
        self.view_CreateGroup_BG.isHidden = true
        self.lbl_Nodata_subTitle.textAlignment = .center
        self.constraint_view_SearchBG_Height.constant = 0
        self.lbl_CreateGroup.text = "Create your group".localized()
        setupUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.getMyGroupList()
    }
    
    func getPoPular_GroupList() {
        let params = ["offset": "0","limit": "6", "group_category" : "all"] as [String : Any]//"featured": "1"
        Utils.doAyuVerseAPICall(endPoint: .getGroupList, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let groupList = try? JSONDecoder().decode(GroupList.self, from: responseJSON.rawData())
                if groupList?.status == "success"{
                    self?.arr_Popular_groupList = groupList?.data ?? []
                    self?.arr_All_Popular_groupList = groupList?.data ?? []
                    self?.is_GroupCreate_Permission = groupList?.createGroupPermission ?? false
                }
                self?.manageSection()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func getMyGroupList() {
        
        let params = ["offset": "0","limit": "3", "group_category" : "all"] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .getMyGroupList, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                do {
                    let groupList = try JSONDecoder().decode(MyGroupList.self, from: responseJSON.rawData())
                    self?.arr_myGroupList = groupList.data ?? []//?.reversed() ?? []
                    self?.arr_All_myGroupList = groupList.data ?? []//?.reversed() ?? []
                    self?.is_GroupCreate_Permission = groupList.createGroupPermission ?? false
                }catch DecodingError.dataCorrupted(let context) {
                    print(context)
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.valueNotFound(let value, let context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
                self?.hideActivityIndicator()
                self?.manageSection()
                self?.getPoPular_GroupList()
            } else {
                self?.hideActivityIndicator(withMessage: message)
                self?.getPoPular_GroupList()
            }
        }
    }
    func joinGroup(groupId: String){
        let params = ["group_id": groupId] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .joinAGroup, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let joinGroup = try? JSONDecoder().decode(JoinGroup.self, from: responseJSON.rawData())
                if joinGroup?.status == "success"{
                    self?.getMyGroupList()
                    let alert = UIAlertController(title: "Success".localized(), message: joinGroup?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: joinGroup?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    func setupUI() {
        tableView.register(nibWithCellClass: ARAyuverseGroupCell.self)
        tableView.register(nibWithCellClass: ARAyuverseGroupSectionHeaderCell.self)
        self.tableView.pullTorefresh(#selector(self.Pullto_refreshScreen), tintcolor: kAppBlueColor, self)
        
        self.txt_Search.clearButtonMode = .whileEditing
        self.txt_Search.addTarget(self, action: #selector(self.textFieldEditing(_:)), for: .editingChanged)
        
//        refreshUIByAPICall { userStreakLevel in
//            self.userLevel = userStreakLevel?.nextLevel ?? ""
//            if userStreakLevel?.nextLevel == "Bronze" || userStreakLevel?.nextLevel == "Silver" || userStreakLevel?.nextLevel == "Gold"{
//                self.lockIv.isHidden = false
//            }else{
//                self.lockIv.isHidden = true
//            }
//        }
        
    }
    
    //Puul refresh action
    @objc func Pullto_refreshScreen() {
        self.hide_SearchBar()
        self.txt_Search.text = ""
        self.getMyGroupList()
    }
    
    func refreshUIByAPICall(completion: ((ARUserStreakLevelModel?) -> Void)? = nil) {
        StreakDetailVC.getUserStreakDetails { success, status, message, userStreakLevel in
            completion?(userStreakLevel)
        }
    }
    
    @IBAction func createGroupBtnPressed(sender: UIButton) {
        if self.is_GroupCreate_Permission {
            let vc = ARCreateGroupVC.instantiate(fromAppStoryboard: .Ayuverse)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let alert = UIAlertController(title: "Feature locked".localized(), message: "To create your own group you must fulfil these criteria \n You should be above gold level \n If you are an expert then please contact info@ayurythm.com to get started", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
            self.present(alert, animated: true)
        }
       
    }
    
    @IBAction func exploreAllBtnPressed(sender: UIButton) {
        let vc = ARGroupViewAllVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.screen_Type = self.arr_dataSource[sender.tag].type
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ARGroupListVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection(_ search: Bool = false) {
        self.arr_dataSource.removeAll()
        
        self.view_CreateGroup_BG.isHidden = false
        
        if self.is_GroupCreate_Permission {
            self.lockIv.isHidden = true
            self.icon_Plue.isHidden = false
            self.lbl_CreateGroup.textColor = .white
            self.icon_Plue.setImageColor(color: .white)
            self.constraint_lbl_CreateGroup_Leading.constant = -28
            self.view_CreateGroup_BG.backgroundColor = kAppGreenD2Color
        }
        
        if self.arr_myGroupList.count != 0 {
            self.arr_dataSource.append(AyuVerse_Data(title: "My groups".localized(), type: .MyGroup, subData: arr_myGroupList))
        }
        
        if self.arr_Popular_groupList.count != 0 {
            self.arr_dataSource.append(AyuVerse_Data(title: "Popular groups".localized(), type: .PopularGroup, subData: self.arr_Popular_groupList))
        }
        self.tableView.closeEndPullRefresh()
        
        if search {
            self.lbl_Nodata_Title.text = "No results found!".localized()
            self.img_view_Nodata.image = UIImage.init(named: "icon_noSearch")
            self.lbl_Nodata_subTitle.text = "We couldn’t find what you searched for.\nTry searching again.".localized()
        }
        else {
            self.lbl_Nodata_Title.text = "No groups found!".localized()
            self.img_view_Nodata.image = UIImage.init(named: "icon_noPost")
            self.lbl_Nodata_subTitle.text = "All the group will appear here."
        }
        self.view_Nodata.isHidden = self.arr_dataSource.count == 0 ? false : true
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arr_dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arr_dataSource[section].type == .MyGroup {
            if self.arr_dataSource[section].subData.count >= 3 {
                return 2
            }
        }
        if self.arr_dataSource[section].type == .PopularGroup {
            if self.arr_dataSource[section].subData.count >= 6 {
                return 5
            }
        }

        return self.arr_dataSource[section].subData.count
//        if section == 0{
//            return myGroupList.count
//        }else{
//            return groupList.count
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: ARAyuverseGroupCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.joinBtn.isHidden = true
        cell.postLbl.isHidden = true
        cell.postCountLbl.isHidden = true
        cell.requestToJoinBtn.isHidden = true
        
        let arr_Inner_groupData = self.arr_dataSource[indexPath.section]
        if arr_Inner_groupData.type == .MyGroup {
            if let group = arr_Inner_groupData.subData[indexPath.row] as? MyGroupData {
                cell.groupType.text = group.groupType == "1" ? "Private".localized() : "Public".localized()
                var strgroupName = group.groupLabel?.trimed().base64Decoded()
                if strgroupName == nil {
                    strgroupName = group.groupLabel
                }
                cell.groupNameLbl.text = strgroupName
                cell.groupCatLbl.text = group.groupCategories
                cell.view_cat_BG.isHidden = group.groupCategories == "" ? true : false
                cell.memberCountLbl.text = group.groupMembers
                cell.postCountLbl.text = group.newPost
                cell.postCountLbl.isHidden = false
                cell.postLbl.isHidden = false
                cell.joinBtn.isHidden = true
                cell.requestToJoinBtn.isHidden = true
                cell.myGroup = group
            }
        }
        else {
            cell.postLbl.isHidden = true
            cell.postCountLbl.isHidden = true
            if let dic_Populoar = arr_Inner_groupData.subData[indexPath.row] as? GroupData {
                if dic_Populoar.groupType == "1" {
                    cell.joinBtn.isHidden = true
                    if dic_Populoar.joinedGroupOrNot == 2 {
                        cell.requestToJoinBtn.isHidden = false
                        cell.requestToJoinBtn.setTitle("Requested".localized(), for: .normal)
                        cell.requestToJoinBtn.backgroundColor = .gray
                    }
                    else if dic_Populoar.joinedGroupOrNot == 3 {
                        cell.requestToJoinBtn.isHidden = false
                        cell.requestToJoinBtn.setTitle("Request to join".localized(), for: .normal)
                        cell.requestToJoinBtn.backgroundColor = .black
                    }
                    else {
                        cell.requestToJoinBtn.isHidden = true
                    }
                }
                else {
                    cell.joinBtn.isHidden = false
                    cell.requestToJoinBtn.isHidden = true
                }
                cell.group = dic_Populoar
                cell.delegate = self
            }
        }
        
         return cell
            
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withClass: ARAyuverseGroupSectionHeaderCell.self)
        cell.exploreBtn.isHidden = true
        
        cell.section = self.arr_dataSource[section].title ?? ""
        if self.arr_dataSource[section].type == .MyGroup {
            if self.arr_dataSource[section].subData.count >= 3 {
                cell.exploreBtn.isHidden = false
            }
        }
        if self.arr_dataSource[section].type == .PopularGroup {
            if self.arr_dataSource[section].subData.count >= 6 {
                cell.exploreBtn.isHidden = false
            }
        }

        cell.exploreBtn.tag = section
        cell.exploreBtn.addTarget(self, action: #selector(exploreAllBtnPressed(sender:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.arr_dataSource[indexPath.section].type == .MyGroup {
            if let dic_group = self.arr_dataSource[indexPath.section].subData[indexPath.row] as? MyGroupData {
                ARMyGroupDetailVC.showScreen(group: dic_group, fromVC: self)
            }
        }
        else {
            if let dic_Populoar = self.arr_dataSource[indexPath.section].subData[indexPath.row] as? GroupData {
                let vc = ARGroupRequestVC.instantiate(fromAppStoryboard: .Ayuverse)
                vc.group = dic_Populoar
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        /*
        if indexPath.section == 0{
            ARMyGroupDetailVC.showScreen(group: myGroupList[indexPath.row], fromVC: self)
        }else{
            if groupList[indexPath.row].groupType == "1" {
                let vc = ARGroupRequestVC.instantiate(fromAppStoryboard: .Ayuverse)
                vc.group = groupList[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                ARGroupDetailVC.showScreen(group: groupList[indexPath.row], fromVC: self)
            }
            
        }*/
       
    }
}
extension ARGroupListVC: AyuverseGroupCellDelegate {
    
    func ayuverseGroupCell(cell: ARAyuverseGroupCell, didPressedJoinBtn btn: UIButton, data: GroupData?) {
        self.joinGroup(groupId: data?.groupID ?? "")
    }
    
    func ayuverseGroupCell(cell: ARAyuverseGroupCell, didPressedRequestToJoinBtn btn: UIButton, data: GroupData?) {
        if data?.joinedGroupOrNot != 2{
            self.joinGroup(groupId: data?.groupID ?? "")
        }
        
    }
    
    
}


//MARK: -- Search Bar
extension ARGroupListVC: UITextFieldDelegate {

    func show_SearchBar() {
        UIView.animate(withDuration: 0.3) {
            self.txt_Search.becomeFirstResponder()
            self.constraint_view_SearchBG_Height.constant = 60
            self.txt_Search.placeholder = "Search".localized()
            self.view.layoutIfNeeded()
        }
    }
    
    func hide_SearchBar() {
        UIView.animate(withDuration: 0.3) {
            self.constraint_view_SearchBG_Height.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func textFieldEditing(_ textField: UITextField) {
        if let str_SearchText = textField.text {
            if str_SearchText == "" {
                self.arr_myGroupList = self.arr_All_myGroupList
                self.arr_Popular_groupList = self.arr_All_Popular_groupList
            }
            else {
                //Search in My Group List
                self.arr_myGroupList = self.arr_All_myGroupList.filter { dic_groupppp in
                    var strgroupName = dic_groupppp.groupLabel?.trimed().base64Decoded()
                    if strgroupName == nil {
                        strgroupName = dic_groupppp.groupLabel
                    }
                    return (strgroupName?.range(of: str_SearchText, options: .caseInsensitive) != nil)
                }
                
                //Search in Popular Group List
                self.arr_Popular_groupList = self.arr_All_Popular_groupList.filter { dic_groupppp in
                    var strgroupName = dic_groupppp.groupLabel?.trimed().base64Decoded()
                    if strgroupName == nil {
                        strgroupName = dic_groupppp.groupLabel
                    }
                    return (strgroupName?.range(of: str_SearchText, options: .caseInsensitive) != nil)
                }
            }
        }
        
        self.manageSection(true)
    }
    
    
    
}
