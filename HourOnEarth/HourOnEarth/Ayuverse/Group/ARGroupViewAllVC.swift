//
//  ARGroupViewAllVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 18/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit

class ARGroupViewAllVC: UIViewController {
    
    var pageNO = 0
    var data_limit = 10
    var isLoading = false
    var is_GroupSearch = false
    
    @IBOutlet weak var categoryPickerView: ARCategoryPickerView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var view_NoData: UIView!
    @IBOutlet weak var img_NoData: UIImageView!
    @IBOutlet weak var view_NoData_Title: UILabel!
    @IBOutlet weak var view_NoData_subTitle: UILabel!
    
    @IBOutlet weak var view_SearchBG: UIView!
    @IBOutlet weak var txt_Search: UITextField!
    @IBOutlet weak var constraint_view_SearchBG_Height: NSLayoutConstraint!
    
    

    var groups = [GroupData]()
    var arr_Allgroups = [GroupData]()
    var myGroups = [MyGroupData]()
    var arr_AllmyGroups = [MyGroupData]()
    var selectedCategeory = "all"
    var screen_Type: AyuVerse_DataType = .Ayu_none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view_NoData.isHidden = true
        self.view_NoData_subTitle.textAlignment = .center
        self.title = self.screen_Type == .MyGroup ? "My groups".localized() : "Popular groups".localized()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoryPickerView.collectionView.reloadData()
    }
    
    func setupUI() {
        self.pageNO = 0
        setBackButtonTitle()
        tableView.register(nibWithCellClass: ARAyuverseGroupCell.self)
        self.tableView.pullTorefresh(#selector(self.Pullto_refreshScreen), tintcolor: kAppBlueColor, self)
        
        self.txt_Search.clearButtonMode = .whileEditing
        self.txt_Search.addTarget(self, action: #selector(self.textFieldEditing(_:)), for: .editingChanged)
        
        categoryPickerView.delegate = self
        ARAyuverseManager.shared.fetchCommonData { [weak self] in
            ARAyuverseManager.shared.categories.forEach{ $0.isSelected = false }
            self?.categoryPickerView.reloadData()
        }
        
        if self.screen_Type == .MyGroup {
            getMyGroupList(true)
        }
        else {
            getGroupList(true)
        }
    }
    
    //Puul refresh action
    @objc func Pullto_refreshScreen() {
        self.pageNO = 0
        self.hide_SearchBar()
        self.txt_Search.text = ""
        
        if self.screen_Type == .MyGroup {
            getMyGroupList(false)
        }
        else {
            getGroupList(false)
        }
    }
    
    
    func getGroupList(_ animate: Bool){
        
        if animate {
            self.showActivityIndicator()
        }
        
        let params = ["offset": self.pageNO,
                      "limit": self.data_limit,
                      "group_category" : selectedCategeory] as [String : Any]//"featured": "1"
        
        Utils.doAyuVerseAPICall(endPoint: .getGroupList, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            self?.hideActivityIndicator()
            self?.tableView.closeEndPullRefresh()
            if isSuccess, let responseJSON = responseJSON {
                let groupList = try? JSONDecoder().decode(GroupList.self, from: responseJSON.rawData())
                let arr_Data = groupList?.data ?? []

                if self?.pageNO == 0 {
                    self?.myGroups.removeAll()
                }
                
                if arr_Data.count != 0 {
                    if self?.pageNO == 0 {
                        self?.groups = groupList?.data ?? []
                    }
                    else {
                        for dic in arr_Data {
                            self?.groups.append(dic)
                        }
                    }
                    self?.isLoading = false
                }
                else {
                    self?.isLoading = true
                }
                
                self?.arr_Allgroups =  self?.groups ?? []
                self?.hideActivityIndicator()
                self?.manageSection()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func getMyGroupList(_ animate: Bool){
        
        if animate {
            self.showActivityIndicator()
        }
        
        let params = ["offset": self.pageNO,
                      "limit": self.data_limit,
                      "group_category" : selectedCategeory] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .getMyGroupList, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            self?.hideActivityIndicator()
            self?.tableView.closeEndPullRefresh()
            
            if isSuccess, let responseJSON = responseJSON {
                do {
                    let groupList = try JSONDecoder().decode(MyGroupList.self, from: responseJSON.rawData())
                    let arr_Data = groupList.data ?? []

                    if self?.pageNO == 0 {
                        self?.myGroups.removeAll()
                    }
                    
                    if arr_Data.count != 0 {
                        if self?.pageNO == 0 {
                            self?.myGroups = groupList.data ?? []
                        }
                        else {
                            for dic in arr_Data {
                                self?.myGroups.append(dic)
                            }
                        }
                        self?.isLoading = false
                    }
                    else {
                        self?.isLoading = true
                    }
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
                self?.myGroups.sort(by: {$0.groupLabel?.trimed().base64Decoded() ?? "" < $1.groupLabel?.trimed().base64Decoded() ?? ""})
                self?.arr_AllmyGroups = self?.myGroups ?? []
                self?.manageSection()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    func joinGroup(groupId: String){
        let params = ["group_id": groupId] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .joinAGroup, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let joinGroup = try? JSONDecoder().decode(JoinGroup.self, from: responseJSON.rawData())
                if joinGroup?.status == "success" {
                    self?.pageNO = 0
                    self?.getGroupList(true)
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
    
    
    
    @IBAction func SearchClicked(_ sender: UIBarButtonItem) {
        if self.is_GroupSearch == false {
            self.is_GroupSearch = true
            self.show_SearchBar()
        }
        else {
            if self.txt_Search.text == "" {
                self.view.endEditing(true)
                self.is_GroupSearch = false
                self.hide_SearchBar()
            }
        }
    }
}

extension ARGroupViewAllVC: ARCategoryPickerViewDelegate {
    func categoryPickerView(view: ARCategoryPickerView, didSelect category: ARAyuverseCategoryModel) {
        print(">> selected category : ", category.name)
        self.pageNO = 0
        selectedCategeory = category.name ?? ""
        if self.screen_Type == .MyGroup {
            getMyGroupList(true)
        }else{
            getGroupList(true)
        }
    }
}

extension ARGroupViewAllVC: UITableViewDelegate, UITableViewDataSource {

    func manageSection(_ search: Bool = false) {
        self.tableView.closeEndPullRefresh()
        
        if search {
            self.view_NoData_Title.text = "No results found!".localized()
            self.img_NoData.image = UIImage.init(named: "icon_noSearch")
            self.view_NoData_subTitle.text = "We couldn’t find what you searched for.\nTry searching again.".localized()
        }
        else {
            self.view_NoData_Title.text = "No groups found!".localized()
            self.img_NoData.image = UIImage.init(named: "icon_noPost")
            self.view_NoData_subTitle.text = "All the group will appear here."
        }
        
        if self.screen_Type == .MyGroup {
            self.view_NoData.isHidden = self.myGroups.count == 0 ? false : true
        }
        else {
            self.view_NoData.isHidden = self.groups.count == 0 ? false : true
        }

        self.tableView.reloadData()
    }
    
    
    
    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global().async {
                // Fake background loading task for 2 seconds
                sleep(2)
                // Download more data here
                DispatchQueue.main.async {
                    if self.screen_Type == .MyGroup {
                        self.pageNO = self.myGroups.count
                        self.getMyGroupList(false)
                    }
                    else {
                        self.pageNO = self.groups.count
                        self.getGroupList(false)
                    }
                }
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.screen_Type == .MyGroup {
            return myGroups.count
        }else{
            return groups.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ARAyuverseGroupCell.self, for: indexPath)
        if self.screen_Type == .MyGroup {
            cell.postCountLbl.isHidden = false
            cell.postLbl.isHidden = false
            cell.joinBtn.isHidden = true
            cell.requestToJoinBtn.isHidden = true
            cell.myGroup = myGroups[indexPath.row]
        }else{
            cell.postCountLbl.isHidden = true
            cell.postLbl.isHidden = true
            if groups[indexPath.row].groupType == "1" {
                cell.joinBtn.isHidden = true
                if groups[indexPath.row].joinedGroupOrNot == 2 {
                    cell.requestToJoinBtn.isHidden = false
                    cell.requestToJoinBtn.setTitle("Requested".localized(), for: .normal)
                    cell.requestToJoinBtn.backgroundColor = .gray
                }
                else if groups[indexPath.row].joinedGroupOrNot == 3 {
                    cell.requestToJoinBtn.isHidden = false
                    cell.requestToJoinBtn.setTitle("Request to join".localized(), for: .normal)
                    cell.requestToJoinBtn.backgroundColor = .black
                }
                else {
                    cell.requestToJoinBtn.isHidden = true
                }
            }else{
                cell.joinBtn.isHidden = false
                cell.requestToJoinBtn.isHidden = true
            }
            cell.group = groups[indexPath.row]
        }
        
        cell.delegate = self
        
        
        // Check if the last row number is the same as the last current data element
        if self.isLoading == false {
            if self.screen_Type == .MyGroup {
                if indexPath.row == self.myGroups.count - 3 {
                    self.loadMoreData()
                }
            }
            else {
                if indexPath.row == self.groups.count - 3 {
                    self.loadMoreData()
                }
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.screen_Type == .MyGroup {
            let group = myGroups[indexPath.row]
            ARMyGroupDetailVC.showScreen(group: group, fromVC: self)

        }else{
            let group = groups[indexPath.row]
            let vc = ARGroupRequestVC.instantiate(fromAppStoryboard: .Ayuverse)
            vc.group = group
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
extension ARGroupViewAllVC: AyuverseGroupCellDelegate{
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
extension ARGroupViewAllVC: UITextFieldDelegate {

    func show_SearchBar() {
        UIView.animate(withDuration: 0.3) {
            self.constraint_view_SearchBG_Height.constant = 60
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
                if self.screen_Type == .MyGroup {
                    self.myGroups = self.arr_AllmyGroups
                }
                else {
                    self.groups = self.arr_Allgroups
                }
            }
            else {
                if self.screen_Type == .MyGroup {
                    //Search in My Group List
                    self.myGroups = self.arr_AllmyGroups.filter { dic_groupppp in
                        var strgroupName = dic_groupppp.groupLabel?.trimed().base64Decoded()
                        if strgroupName == nil {
                            strgroupName = dic_groupppp.groupLabel
                        }
                        return (strgroupName?.range(of: str_SearchText, options: .caseInsensitive) != nil)
                    }
                }
                else {
                    //Search in Popular Group List
                    self.groups = self.arr_Allgroups.filter { dic_groupppp in
                        var strgroupName = dic_groupppp.groupLabel?.trimed().base64Decoded()
                        if strgroupName == nil {
                            strgroupName = dic_groupppp.groupLabel
                        }
                        return (strgroupName?.range(of: str_SearchText, options: .caseInsensitive) != nil)
                    }
                }
            }
        }
        self.manageSection(true)
    }
    
}
