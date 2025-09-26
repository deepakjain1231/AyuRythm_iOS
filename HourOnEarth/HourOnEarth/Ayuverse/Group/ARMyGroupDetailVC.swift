//
//  ARMyGroupDetailVC.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 28/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import DropDown
import Alamofire
import ActiveLabel

class ARMyGroupDetailVC: UIViewController {
    
    
    var pageNO = 0
    var data_limit = 15
    var isLoading = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn_AddMedia: UIButton!
    @IBOutlet weak var contenLibBtn: UIButton!
    @IBOutlet weak var groupDetailView: ARGroupDetailView!
    @IBOutlet weak var deviderView: UIView!
    @IBOutlet weak var btn_GroupDetail: UIButton!
    @IBOutlet weak var view_NoData: UIView!
    @IBOutlet weak var lbl_writeSomething: UILabel!
    @IBOutlet weak var img_view_Nodata: UIImageView!
    @IBOutlet weak var lbl_Nodata_Title: UILabel!
    @IBOutlet weak var lbl_Nodata_subTitle: UILabel!
    
    @IBOutlet weak var view_SearchBG: UIView!
    @IBOutlet weak var txt_Search: UITextField!
    @IBOutlet weak var constraint_view_SearchBG_Height: NSLayoutConstraint!
    
    var group: MyGroupData?
    var groupFeed: [Feed] = []
    var AllgroupFeed: [Feed] = []
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_writeSomething.text = "Write something to post!".localized()
        self.btn_AddMedia.setTitle("Add media".localized(), for: .normal)
        self.contenLibBtn.setTitle("Content library".localized(), for: .normal)
        self.lbl_Nodata_Title.text = "No posts found!".localized()
        self.img_view_Nodata.image = UIImage.init(named: "icon_noPost")
        self.lbl_Nodata_subTitle.text = "All the post will appear here.".localized()
        
        
        setupUI()
        groupDetailView.updateUI(from: group!)
        tableView.delegate = self
        tableView.dataSource = self
        self.view_NoData.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        getGroupFeeds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    func getGroupFeeds(){
        self.showActivityIndicator()
        let params = ["group_id": group!.groupID!,
                      "limit": self.data_limit,
                      "offset": self.pageNO,
                      "user_id": ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .getGroupFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            self?.tableView.closeEndPullRefresh()
            self?.hideActivityIndicator()
            if isSuccess, let responseJSON = responseJSON {
                let groupFeed = try? JSONDecoder().decode(GroupFeed.self, from: responseJSON.rawData())
                let arr_Data = groupFeed?.data ?? []

                if groupFeed?.status == "success"{
                    
                    if self?.pageNO == 0 {
                        self?.groupFeed.removeAll()
                        self?.AllgroupFeed.removeAll()
                    }
                    
                    if arr_Data.count != 0 {
                        if self?.pageNO == 0 {
                            self?.groupFeed = groupFeed?.data ?? []
                        }
                        else {
                            for dic in arr_Data {
                                self?.groupFeed.append(dic)
                            }
                        }
                        self?.isLoading = false
                    }
                    else {
                        self?.isLoading = true
                    }

                    self?.AllgroupFeed = self?.groupFeed ?? []
                }else{
                    //let alert = UIAlertController(title: "Error".localized(), message: groupFeed?.message, preferredStyle: .alert)
                    //alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    //self?.present(alert, animated: true)
                }
                self?.view_NoData.isHidden = self?.groupFeed.count == 0 ? false : true
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func setupUI() {
        setBackButtonTitle()
        tableView.register(nibWithCellClass: ARAyuverseFeedCell.self)
        tableView.register(nibWithCellClass: ARAyuverseFeedMediaCell.self)
        self.tableView.pullTorefresh(#selector(self.Pullto_refreshScreen), tintcolor: kAppBlueColor, self)
        
        self.txt_Search.clearButtonMode = .whileEditing
        self.txt_Search.addTarget(self, action: #selector(self.textFieldEditing(_:)), for: .editingChanged)
        
        deviderView.isHidden = true
        contenLibBtn.isHidden = true
    }
    
    @objc func Pullto_refreshScreen() {
        getGroupFeeds()
    }
    
    func showGroupRequestVC() {
        let vc = ARGroupRequestVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.myGroup = group
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showGroupSettingVC() {
        let vc = ARGroupSettingVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.myGroup = group
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backBtnPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moreOptionBtnPressed(sender: UIButton) {
        if self.group?.groupAdmin == kSharedAppDelegate.userId {
            showMoreActionEditDeleteAlert()
        }
        else {
            showMoreActionAlert()
        }
    }
    
    @IBAction func createFeedPostBtnPressed(sender: UIButton) {
        let vc = ARCreateFeedPostVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.isGroup = true
        vc.groupId = group!.groupID!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openContentLibraryBtnPressed(sender: UIButton) {
        ARContentLibraryHomeVC.showScreen(fromVC: self)
    }
    
    @IBAction func btn_My_GroupDetail(_ sender: UIButton) {
        let vc = ARGroupSettingVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.myGroup = group
        vc.is_MyGroup = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ARMyGroupDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global().async {
                // Fake background loading task for 2 seconds
                sleep(2)
                // Download more data here
                DispatchQueue.main.async {
                    self.pageNO = self.groupFeed.count
                    self.getGroupFeeds()
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ARAyuverseFeedCell.self, for: indexPath)
        let dic_feed = groupFeed[indexPath.row]
        if dic_feed.files?.count ?? 0 > 0 {
            let cell = tableView.dequeueReusableCell(withClass: ARAyuverseFeedMediaCell.self, for: indexPath)
            cell.feed = dic_feed
            cell.index = indexPath.row
            cell.currentController = self
            cell.setupData(dic_feed)

            var strFeedMsg = dic_feed.message?.trimed().base64Decoded()
            if strFeedMsg == nil {
                strFeedMsg = dic_feed.message
            }
            
            let customType1 = ActiveType.custom(pattern: "\\sSee More\\b".localized()) //Looks for "are"
            let customType2 = ActiveType.custom(pattern: "\\sSee Less\\b".localized()) //Looks for "are"
            cell.textL.enabledTypes.append(customType1)
            cell.textL.enabledTypes.append(customType2)

            let arr_GetURL = Utils.getLinkfromString(str_msggggg: strFeedMsg ?? "")
            if arr_GetURL.count != 0 {
                for strGetURL in arr_GetURL {
                    if strGetURL.contains("http") {
                    }
                    else {
                        strFeedMsg = strFeedMsg?.replacingOccurrences(of: strGetURL, with: "https://\(strGetURL)")
                    }
                }
            }
                    
            cell.textL.customize { label in
                label.text = strFeedMsg ?? ""
                label.textColor = UIColor.black
                label.hashtagColor = kAppBlueColor
                label.URLColor = kAppBlueColor

                label.handleHashtagTap { self.tappedonLabel("Hashtag", message: $0, indx: indexPath) }
                label.handleURLTap { self.tappedonLabel("URL", message: $0.absoluteString, indx: indexPath) }

                let noOfLines = cell.textL.calculateMaxLines()
                let readmoreFont = UIFont.boldSystemFont(ofSize: 14)
                let readmoreFontColor = UIColor().hexStringToUIColor(hex: "#3E8B3A")

                if noOfLines > 4 {
                    cell.textL.numberOfLines = dic_feed.is_ReadMore ? 0 : 4
                    let strWith_Text = dic_feed.is_ReadMore ? "   " :"... "
                    let addTrellingText = dic_feed.is_ReadMore ? kSeeMoreLessText.See_Less.rawValue.localized() : kSeeMoreLessText.See_More.rawValue.localized()
                    DispatchQueue.main.async {
                        cell.textL.addTrailing(with: strWith_Text, moreText: addTrellingText, moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
                    }
                    
                } else {
                    cell.textL.numberOfLines = 0
                }
                

                //Custom types
                label.customColor[customType1] = UIColor().hexStringToUIColor(hex: "#3E8B3A")
                label.customColor[customType2] = UIColor().hexStringToUIColor(hex: "#3E8B3A")

                label.handleCustomTap(for: customType1) { self.tappedonLabel("Custom type", message: $0, indx: indexPath) }
                label.handleCustomTap(for: customType2) { self.tappedonLabel("Custom type", message: $0, indx: indexPath) }
            }
            
            
            
            
            
            
            cell.delegate = self
            
            cell.commentTV1.delegate = self
            cell.commentTV1.tag = indexPath.row
            cell.commentTV1.accessibilityHint = "ARAyuverseFeedMediaCell"
            cell.commentTV1.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            
            // Check if the last row number is the same as the last current data element
            if self.isLoading == false {
                if indexPath.row == self.groupFeed.count - 4 {
                    self.loadMoreData()
                }
            }

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: ARAyuverseFeedCell.self, for: indexPath)
            cell.feed = dic_feed
            cell.index = indexPath.row
            cell.setupData(dic_feed)
            
            var strFeedMsg = dic_feed.message?.trimed().base64Decoded()
            if strFeedMsg == nil {
                strFeedMsg = dic_feed.message
            }
            
            let customType1 = ActiveType.custom(pattern: "\\sSee More\\b".localized()) //Looks for "are"
            let customType2 = ActiveType.custom(pattern: "\\sSee Less\\b".localized()) //Looks for "are"
            cell.textL.enabledTypes.append(customType1)
            cell.textL.enabledTypes.append(customType2)

            let arr_GetURL = Utils.getLinkfromString(str_msggggg: strFeedMsg ?? "")
            if arr_GetURL.count != 0 {
                for strGetURL in arr_GetURL {
                    if strGetURL.contains("http") {
                    }
                    else {
                        strFeedMsg = strFeedMsg?.replacingOccurrences(of: strGetURL, with: "https://\(strGetURL)")
                    }
                }
            }
                    
            cell.textL.customize { label in
                label.text = strFeedMsg ?? ""
                label.textColor = UIColor.black
                label.hashtagColor = kAppBlueColor
                label.URLColor = kAppBlueColor

                label.handleHashtagTap { self.tappedonLabel("Hashtag", message: $0, indx: indexPath) }
                label.handleURLTap { self.tappedonLabel("URL", message: $0.absoluteString, indx: indexPath) }

                let noOfLines = cell.textL.calculateMaxLines()
                let readmoreFont = UIFont.boldSystemFont(ofSize: 14)
                let readmoreFontColor = UIColor().hexStringToUIColor(hex: "#3E8B3A")

                if noOfLines > 4 {
                    cell.textL.numberOfLines = dic_feed.is_ReadMore ? 0 : 4
                    let strWith_Text = dic_feed.is_ReadMore ? "   " :"... "
                    let addTrellingText = dic_feed.is_ReadMore ? kSeeMoreLessText.See_Less.rawValue.localized() : kSeeMoreLessText.See_More.rawValue.localized()
                    DispatchQueue.main.async {
                        cell.textL.addTrailing(with: strWith_Text, moreText: addTrellingText, moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
                    }
                    
                } else {
                    cell.textL.numberOfLines = 0
                }
                

                //Custom types
                label.customColor[customType1] = UIColor().hexStringToUIColor(hex: "#3E8B3A")
                label.customColor[customType2] = UIColor().hexStringToUIColor(hex: "#3E8B3A")

                label.handleCustomTap(for: customType1) { self.tappedonLabel("Custom type", message: $0, indx: indexPath) }
                label.handleCustomTap(for: customType2) { self.tappedonLabel("Custom type", message: $0, indx: indexPath) }
            }
            
            
            cell.delegate = self
            
            cell.commentTV.delegate = self
            cell.commentTV.tag = indexPath.row
            cell.commentTV.accessibilityHint = "ARAyuverseFeedCell"
            cell.commentTV.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            
            // Check if the last row number is the same as the last current data element
            if self.isLoading == false {
                if indexPath.row == self.groupFeed.count - 4 {
                    self.loadMoreData()
                }
            }

            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ARFeedDetailVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.feed = groupFeed[indexPath.row].feedID ?? ""
        vc.groupId =  groupFeed[indexPath.row].groupID ?? ""
        vc.isFromGroup = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- tappedOnLabel
    func tappedonLabel(_ title: String, message: String, indx: IndexPath) {
        
        if title == "Hashtag" {
            debugPrint("user tapped on hashtag text")
            
            self.show_SearchBar()
            self.txt_Search.text = "#\(message)"
            
            isSearching = true
            searchFeedFromServer(text: "#\(message)"){ (success) in
                Utils.stopActivityIndicatorinView(self.view)
                self.manageTableView(true)
            }
        }
        else if title == "URL" {
            debugPrint("user tapped on link text")
            kSharedAppDelegate.openWebLinkinBrowser(message)
        }
        else {
            if message == kSeeMoreLessText.See_More.rawValue.localized().trimed() {
                self.groupFeed[indx.row].is_ReadMore = true
                self.tableView.reloadData()
                debugPrint("user tapped on see more text")
            }
            else if message == kSeeMoreLessText.See_Less.rawValue.localized().trimed() {
                groupFeed[indx.row].is_ReadMore = false
                self.tableView.reloadData()
                debugPrint("user tapped on see less text")
            }
        }
    }
    
    func manageTableView(_ search: Bool = false) {
        self.tableView.closeEndPullRefresh()
        if search {
            self.lbl_Nodata_Title.text = "No results found!".localized()
            self.img_view_Nodata.image = UIImage.init(named: "icon_noSearch")
            self.lbl_Nodata_subTitle.text = "We couldn’t find what you searched for.\nTry searching again.".localized()
        }
        else {
            self.lbl_Nodata_Title.text = "No posts found!".localized()
            self.img_view_Nodata.image = UIImage.init(named: "icon_noPost")
            self.lbl_Nodata_subTitle.text = "All the post will appear here.".localized()
        }
        self.view_NoData.isHidden = self.groupFeed.count == 0 ? false : true
        self.tableView.reloadData()
    }
    
    
    func addGroupFeedComment(cell:ARAyuverseFeedCell?, feed: Feed) {
        let strCommentMsg = (cell?.commentTV.text ?? "").trimed()
        if strCommentMsg == "" {
            return
        }
        
        let params = [ "feedcomment_id": "",
                       "comment_msg": strCommentMsg,
                       "gfeed_id": feed.feedID ?? "",
                       "id": kSharedAppDelegate.userId,
                       "group_id": group?.groupID ?? ""] as [String : Any]

        Utils.doAyuVerseAPICall(endPoint: .groupFeedComment, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let addCommentData = try? JSONDecoder().decode(AddComment.self, from: responseJSON.rawData())
                if addCommentData?.status == "success"{
                    cell?.commentTV.text = ""
                    feed.comments = (feed.comments ?? 0) + 1
                    cell?.commentBtn.setTitle(String(feed.comments ?? 0), for: .normal)
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: addCommentData?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func addGroupFeedMediaComment(cell:ARAyuverseFeedMediaCell?, feed: Feed) {
        let strCommentMsg = (cell?.commentTV1.text ?? "").trimed()
        if strCommentMsg == "" {
            return
        }

        let params = ["feedcomment_id": "",
                      "comment_msg": strCommentMsg,
                      "gfeed_id": feed.feedID ?? "",
                      "id": kSharedAppDelegate.userId,
                      "group_id": group?.groupID ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .groupFeedComment, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let addCommentData = try? JSONDecoder().decode(AddComment.self, from: responseJSON.rawData())
                if addCommentData?.status == "success"{
                    cell?.commentTV1.text = ""
                    feed.comments = (feed.comments ?? 0) + 1
                    cell?.commentBtn.setTitle(String(feed.comments ?? 0), for: .normal)
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: addCommentData?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func deleteFeed(feed: Feed){
        let params = ["gfeed_id": feed.feedID ?? ""] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .deleteGroupFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let deletFeed = try? JSONDecoder().decode(DeleteFeed.self, from: responseJSON.rawData())
                if deletFeed?.status == "success"{
                    let alert = UIAlertController(title: "Success".localized(), message: deletFeed?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                    self?.getGroupFeeds()
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: deletFeed?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func reportFeedUser(reportType: String, feed: Feed,reportUserId: String, report_msg: String) {
        
        let params = ["answer_id": "",
                      "comment_id": "",
                      "question_id": "",
                      "report_type": reportType,
                      "feed_id": feed.feedID ?? "",
                      "report_message": report_msg,
                      "group_id": group?.groupID ?? "",
                      "report_user_id":reportUserId] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .reportFeedOrComment, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let deletFeed = try? JSONDecoder().decode(DeleteFeed.self, from: responseJSON.rawData())
                if deletFeed?.status == "success"{
                    let alert = UIAlertController(title: "Success".localized(), message: deletFeed?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: deletFeed?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func likeAFeed(data: Feed?, index: Int){
        let params = ["feed_id": data?.feedID ?? "","group_id": group?.groupID ?? ""] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .likeAFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let likeFeedData = try? JSONDecoder().decode(LikeFeedData.self, from: responseJSON.rawData())
                if likeFeedData?.status == "success"{
                    if self?.groupFeed[index].mylikes == 0{
                        self?.groupFeed[index].mylikes = 1
                        self?.groupFeed[index].likes =  (self?.groupFeed[index].likes ?? 0) + 1
                    }else{
                        self?.groupFeed[index].mylikes = 0
                        self?.groupFeed[index].likes =  (self?.groupFeed[index].likes ?? 0) - 1
                    }
                    self?.tableView.reloadData()
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: likeFeedData?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    func shareAFeed(data: Feed?, index: Int) {
        let params = ["feed_id": data?.feedID ?? "",
                      "group_id": data?.groupID ?? ""] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .shareFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                if self?.groupFeed[index].shares == 0 {
                    self?.groupFeed[index].shares = 1
                }else{
                    self?.groupFeed[index].shares = (self?.groupFeed[index].shares ?? 0) + 1
                }
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
}

extension ARMyGroupDetailVC {
    func showMoreActionAlert() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Search".localized(), style: .default, handler: { _ in
            //self.showGroupRequestVC()
            //Search Press
            
            if self.isSearching == false {
                self.isSearching = true
                self.show_SearchBar()
            }
            else {
                if self.txt_Search.text == "" {
                    self.view.endEditing(true)
                    self.isSearching = false
                    self.hide_SearchBar()
                }
            }

        }))
        actionSheet.addAction(UIAlertAction(title: "Leave Group".localized(), style: .default, handler: { _ in
            self.callAPIforDeleteAndLeave_Group(is_delete: false, is_leave: true)
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showMoreActionEditDeleteAlert() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Edit".localized(), style: .default, handler: { _ in
            
            //Edit Group
            let vc = ARCreateGroupVC.instantiate(fromAppStoryboard: .Ayuverse)
            vc.is_EditGroupDetail = true
            vc.dic_groupDetail = self.group
            self.navigationController?.pushViewController(vc, animated: true)

        }))
        
        actionSheet.addAction(UIAlertAction(title: "Search".localized(), style: .default, handler: { _ in
            //Search Group
            self.show_SearchBar()
        }))

        actionSheet.addAction(UIAlertAction(title: "Delete Group".localized(), style: .destructive, handler: { _ in
            //Delete Group
            ARLog("Delete Group")
            let alert = UIAlertController(title: "Do you really want to delete?".localized(), message: "Are you sure you want to delete this group?".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive){_ in
                self.callAPIforDeleteAndLeave_Group(is_delete: true, is_leave: false)
            })
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
            self.present(alert, animated: true)
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
    static func showScreen(group: MyGroupData, fromVC: UIViewController) {
        let vc = ARMyGroupDetailVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.group = group
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - API Call for Delete Group
    func callAPIforDeleteAndLeave_Group(is_delete: Bool, is_leave: Bool) {
        
        self.showActivityIndicator()
        let group_ID = self.group?.groupID ?? ""
        
        let params = ["group_id": group_ID] as [String : Any]
        
        var str_URLEndPoint: endPoint = .DeleteAGroup
        if is_leave {
            str_URLEndPoint = .leaveAGroup
        }

        Utils.doAyuVerseAPICall(endPoint: str_URLEndPoint, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
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
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let strKey = textField.accessibilityHint, strKey == "ARAyuverseFeedMediaCell" {
            let indxxPath = IndexPath.init(row: textField.tag, section: 0)
            if let currentCell = tableView.cellForRow(at: indxxPath) as? ARAyuverseFeedMediaCell {
                if textField.text?.trimed() == "" {
                    currentCell.postBtn1.setTitleColor(kAppMidGreyColor, for: .normal)
                }
                else {
                    currentCell.postBtn1.setTitleColor(kAppBlueColor, for: .normal)
                }
            }
        }
        else if let strKey = textField.accessibilityHint, strKey == "ARAyuverseFeedCell" {
            let indxxPath = IndexPath.init(row: textField.tag, section: 0)
            if let currentCell = tableView.cellForRow(at: indxxPath) as? ARAyuverseFeedCell {
                if textField.text?.trimed() == "" {
                    currentCell.postBtn.setTitleColor(kAppMidGreyColor, for: .normal)
                }
                else {
                    currentCell.postBtn.setTitleColor(kAppBlueColor, for: .normal)
                }
            }
        }
    }
}

extension ARMyGroupDetailVC: ARAyuverseFeedCellDelegate, delegate_repot {
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedLikeBtn btn: UIButton, data: Feed?, index: Int?) {
        DebugLog("-")
        likeAFeed(data: data , index: index ?? 0)
    }
    
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didSelectMoreOption data: Feed?) {
        DebugLog("-")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        if data?.userProfile?.userID == kSharedAppDelegate.userId {
            actionSheet.addAction(UIAlertAction(title: "Edit".localized(), style: .default, handler: { _ in
                let vc = ARCreateFeedPostVC.instantiate(fromAppStoryboard: .Ayuverse)
                vc.isEditingFeed = true
                vc.feed = data
                vc.isGroup = true
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            actionSheet.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { _ in
                let alert = UIAlertController(title: "Delete Post".localized(), message: "Are you sure you want to delete this post?".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive){_ in
                    self.deleteFeed(feed: data!)
                })
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
                self.present(alert, animated: true)
            }))
        } else {
            actionSheet.addAction(UIAlertAction(title: "Report Post".localized(), style: .default, handler: { [self] _ in
                self.openReportPostDialouge(strReportPost_User: "post", selectedFedd: data)
               // reportFeedUser(reportType: "3", feed: data!, reportUserId: "")
            }))
            actionSheet.addAction(UIAlertAction(title: "Report User".localized(), style: .default, handler: { _ in
                self.openReportPostDialouge(strReportPost_User: "user", selectedFedd: data)
                //self.reportFeedUser(reportType: "7", feed: data!, reportUserId: data?.userProfile?.userID ?? "")
            }))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func ayuverseFeedCell(cell: ARAyuverseFeedMediaCell, didSelectMoreOption data: Feed?) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        if data?.userProfile?.userID == kSharedAppDelegate.userId {
            actionSheet.addAction(UIAlertAction(title: "Edit".localized(), style: .default, handler: { _ in
                let vc = ARCreateFeedPostVC.instantiate(fromAppStoryboard: .Ayuverse)
                vc.isEditingFeed = true
                vc.feed = data
                vc.isGroup = true
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            actionSheet.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { _ in
                let alert = UIAlertController(title: "Delete Post".localized(), message: "Are you sure you want to delete this post?".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive){_ in
                    self.deleteFeed(feed: data!)
                })
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
                self.present(alert, animated: true)
            }))
        } else {
            actionSheet.addAction(UIAlertAction(title: "Report Post".localized(), style: .default, handler: { [self] _ in
                self.openReportPostDialouge(strReportPost_User: "post", selectedFedd: data)
                //reportFeedUser(reportType: "3", feed: data!, reportUserId: "")
            }))
            actionSheet.addAction(UIAlertAction(title: "Report User".localized(), style: .default, handler: { _ in
                self.openReportPostDialouge(strReportPost_User: "user", selectedFedd: data)
                //self.reportFeedUser(reportType: "7", feed: data!, reportUserId: data?.userProfile?.userID ?? "")
            }))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func ayuverseFeedCell(cell: ARAyuverseFeedMediaCell, didPressedPostBtn btn: UIButton, data: Feed?) {
        addGroupFeedMediaComment(cell: cell, feed: data!)
    }
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedPostBtn btn: UIButton, data: Feed?) {
        addGroupFeedComment(cell: cell, feed: data!)
    }
    
       
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedCommentBtn btn: UIButton, data: Feed?) {
        DebugLog("-")
        guard let data = data else { return }
        let vc = ARFeedDetailVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.feed = data.feedID ?? ""
        vc.groupId = data.groupID ?? ""
        vc.isFromGroup = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedShareBtn btn: UIButton, data: Feed?, index: Int?) {
        DebugLog("-")
        shareAFeed(data: data , index: index ?? 0)
        UIApplication.share(cell.textL.text ?? "")
    }
    
    
    func openReportPostDialouge(strReportPost_User: String, selectedFedd: Feed?) {
        //"msg_type" 1 for Post, 2 for User
        let str_msg_type = strReportPost_User == "post" ? "1" : "2"

        let param = ["language_id": Utils.getLanguageId(),
                     "msg_type": str_msg_type] as [String : Any]

        Utils.doAyuVerseAPICall(endPoint: .getreportMessage, parameters: param,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let reportData = try? JSONDecoder().decode(ReportMessage.self, from: responseJSON.rawData())
                if (reportData?.status ?? "") == "success" {
                    if let arrTemp = reportData?.data {
                        
                        if let parent = kSharedAppDelegate.window?.rootViewController {
                            let objDialouge = ReportPostDialouge(nibName:"ReportPostDialouge", bundle:nil)
                            objDialouge.delegate = self
                            objDialouge.arr_ReportData = arrTemp
                            objDialouge.currentFeedSelection = selectedFedd
                            objDialouge.is_ForPost_User = strReportPost_User
                            parent.addChild(objDialouge)
                            objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            parent.view.addSubview((objDialouge.view)!)
                            objDialouge.didMove(toParent: parent)
                        }
                    }
                }
            }
        }
    }
    
    func report_message_selected(_ success: Bool, reportmsg: String, currentType: String, selectedFeed: Feed?) {
        if success {
            if currentType == "post" {
                self.reportFeedUser(reportType: "3", feed: selectedFeed!, reportUserId: "", report_msg: reportmsg)
            }
            else {
                self.reportFeedUser(reportType: "7", feed: selectedFeed!, reportUserId: selectedFeed?.userProfile?.userID ?? "", report_msg: reportmsg)
            }
        }
    }
}


extension ARMyGroupDetailVC: UITextFieldDelegate {

    func show_SearchBar() {
        UIView.animate(withDuration: 0.3) {
            self.constraint_view_SearchBG_Height.constant = 60
            self.view_SearchBG.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    func hide_SearchBar() {
        UIView.animate(withDuration: 0.3) {
            self.constraint_view_SearchBG_Height.constant = 0
            self.view_SearchBG.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func textFieldEditing(_ textField: UITextField) {
        if let str_SearchText = textField.text {
            if str_SearchText == "" {
                self.groupFeed = self.AllgroupFeed
                isSearching = false
                self.manageTableView(true)
            }
            else {
                //Search in feeds
                isSearching = true
                searchFeedFromServer(text: str_SearchText){ (success) in
                    Utils.stopActivityIndicatorinView(self.view)
                    self.manageTableView(true)
                }
            }
        }
    }
    
    func searchFeedFromServer (text: String, completion: @escaping (Bool)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.group_searchFeed.rawValue
            let params = ["keyword": text,"datefilter": "", "group_id": self.group?.groupID ?? ""]
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    let groupFeed = try? JSONDecoder().decode(GroupFeed.self, from: response.data!)
                    self.groupFeed = groupFeed?.data ?? []
                    completion(true)
                case .failure(_):
                    completion(false)
                }
            }
        }else {
            completion(false)
        }
    }
    

}
