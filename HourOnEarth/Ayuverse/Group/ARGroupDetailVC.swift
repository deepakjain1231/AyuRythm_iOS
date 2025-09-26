//
//  ARGroupDetailVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 19/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import DropDown
import SDWebImage

class ARGroupDetailView: UIView {
    @IBOutlet weak var picIV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var membersL: UILabel!
    
    func updateUI(from group: GroupData) {
        picIV.layer.cornerRadius = 8
        picIV.layer.masksToBounds = true
        
        
        var strgroupName = group.groupLabel?.trimed().base64Decoded()
        if strgroupName == nil {
            strgroupName = group.groupLabel
        }
        nameL.text = strgroupName
        
//        picIV.af_setImage(withURLString: group.groupImage)
        
        let str_img_URL = group.groupImage ?? ""
        if str_img_URL == "" {
            picIV.image = appImage.group_default_pic
        }
        else {
            picIV.sd_setImage(with: URL.init(string: str_img_URL), placeholderImage: appImage.group_default_pic, options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)
        }
        
        if (group.groupMembers ?? "0") == "1" || (group.groupMembers ?? "0") == "0" {
            membersL.text = (group.groupMembers ?? "0") + " " + "Member".localized()
        }
        else {
            membersL.text = (group.groupMembers ?? "0") + " " + "Members".localized()
        }

    }
    func updateUI(from group: MyGroupData) {
        picIV.layer.cornerRadius = 8
        picIV.layer.masksToBounds = true
        
        var strgroupName = group.groupLabel?.trimed().base64Decoded()
        if strgroupName == nil {
            strgroupName = group.groupLabel
        }
        nameL.text = strgroupName
        
//        picIV.af_setImage(withURLString: group.groupImage)
        
        var str_img_URL = group.groupImage ?? ""
        if str_img_URL == "" {
            picIV.image = appImage.group_default_pic
        }
        else {
            if !(str_img_URL.contains("https")) {
                str_img_URL = image_BaseURL + str_img_URL
            }
            
            picIV.sd_setImage(with: URL.init(string: str_img_URL), placeholderImage: appImage.group_default_pic, options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)
        }
        
        if (group.groupMembers ?? "0") == "1" || (group.groupMembers ?? "0") == "0" {
            membersL.text = (group.groupMembers ?? "0") + " " + "Member".localized()
        }
        else {
            membersL.text = (group.groupMembers ?? "0") + " " + "Members".localized()
        }
        
        
    }
}

class ARGroupDetailVC: UIViewController {
    
    var pageNO = 0
    var data_limit = 15
    var isLoading = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupDetailView: ARGroupDetailView!
    @IBOutlet weak var deviderView: UIView!
    @IBOutlet weak var btn_GroupDetail: UIButton!
    @IBOutlet weak var lbl_writeSomething: UILabel!
    
    @IBOutlet weak var btn_AddMedia: UIButton!
    @IBOutlet weak var contentLibraryBtn: UIButton!
    var group: GroupData?
    var groupFeed: [Feed] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_writeSomething.text = "Write something to post!".localized()
        self.btn_AddMedia.setTitle("Add media".localized(), for: .normal)
        self.contentLibraryBtn.setTitle("Content library".localized(), for: .normal)
        
        setupUI()
        groupDetailView.updateUI(from: group!)
        getGroupFeeds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    func getGroupFeeds(){
        let params = ["offset": self.pageNO,
                      "limit": self.data_limit,
                      "group_id": group!.groupID!,
                      "user_id": ""] as [String : Any]

        Utils.doAyuVerseAPICall(endPoint: .getGroupFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            self?.tableView.closeEndPullRefresh()
            if isSuccess, let responseJSON = responseJSON {
                let groupFeed = try? JSONDecoder().decode(GroupFeed.self, from: responseJSON.rawData())
                let arr_Data = groupFeed?.data ?? []

                if groupFeed?.status == "success"{

                    if self?.pageNO == 0 {
                        self?.groupFeed.removeAll()
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

                    self?.tableView.reloadData()
                }
                else{
                    let alert = UIAlertController(title: "Error".localized(), message: groupFeed?.message, preferredStyle: .alert)
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
        setBackButtonTitle()
        tableView.register(nibWithCellClass: ARAyuverseFeedCell.self)
        tableView.register(nibWithCellClass: ARAyuverseFeedMediaCell.self)
        self.tableView.pullTorefresh(#selector(self.Pullto_refreshScreen), tintcolor: kAppBlueColor, self)
        deviderView.isHidden = true
        contentLibraryBtn.isHidden = true
    }

    
    @objc func Pullto_refreshScreen() {
        self.pageNO = 0
        getGroupFeeds()
    }
    
    func showGroupRequestVC() {
        let vc = ARGroupRequestVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.group = group
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showGroupSettingVC() {
        let vc = ARGroupSettingVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.group = group
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backBtnPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moreOptionBtnPressed(sender: UIButton) {
        showMoreActionAlert()
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
        vc.group = group
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ARGroupDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ARAyuverseFeedCell.self, for: indexPath)
        let feed = groupFeed[indexPath.row]
        if feed.files?.count ?? 0 > 0 {
            let cell = tableView.dequeueReusableCell(withClass: ARAyuverseFeedMediaCell.self, for: indexPath)
            cell.feed = feed
            cell.index = indexPath.row
            cell.currentController = self
            cell.userProfileView.profilePicIV.af_setImage(withURLString: feed.userProfile?.userProfile)
            if feed.userProfile?.userBadge != ""{
                cell.userProfileView.badgeIV.af_setImage(withURLString: feed.userProfile?.userBadge)
                cell.userProfileView.badgeView.isHidden = false
            }else{
                cell.userProfileView.badgeView.isHidden = true
            }
            cell.userProfileView.usernameL.text = feed.userProfile?.userName
            if #available(iOS 13.0, *) {
                cell.userProfileView.timeL.text = feed.createdAt?.UTCToLocalDate(incomingFormat: App.dateFormat.serverSendDateTime)?.timeAgoDisplay()
            } else {
                // Fallback on earlier versions
            }
            
            let int_LikeCount = feed.likes ?? 0
            if int_LikeCount == 0 {
                cell.likeBtn.setTitle("", for: .normal)
            }
            else {
                cell.likeBtn.setTitle(String(feed.likes ?? 0), for: .normal)
            }
            
            let int_CommentCount = feed.comments ?? 0
            if int_CommentCount == 0 {
                cell.commentBtn.setTitle("", for: .normal)
            }
            else {
                cell.commentBtn.setTitle(String(feed.comments ?? 0), for: .normal)
            }
            
            
            if feed.mylikes == 0{
                cell.likeBtn.setImage(UIImage(named: "like"), for: .normal)
            }else{
                cell.likeBtn.setImage(UIImage(named: "like-selected"), for: .normal)
            }
            cell.userIv1.layer.cornerRadius = 14
            cell.userIv1.clipsToBounds  = true
            cell.postBtn1.titleLabel?.font = cell.postBtn1.titleLabel?.font.withSize(12)
            
            var strFeedMsg = feed.message?.trimed().base64Decoded()
            if strFeedMsg == nil {
                strFeedMsg = feed.message
            }
            cell.textL.text = strFeedMsg
            
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: ARAyuverseFeedCell.self, for: indexPath)
            cell.feed = groupFeed[indexPath.row]
            cell.index = indexPath.row
            cell.userProfileView.profilePicIV.af_setImage(withURLString: feed.userProfile?.userProfile)
            if feed.userProfile?.userBadge != ""{
                cell.userProfileView.badgeIV.af_setImage(withURLString: feed.userProfile?.userBadge)
                cell.userProfileView.badgeView.isHidden = false
            }else{
                cell.userProfileView.badgeView.isHidden = true
            }
            cell.userProfileView.usernameL.text = feed.userProfile?.userName
            if #available(iOS 13.0, *) {
                cell.userProfileView.timeL.text = feed.createdAt?.UTCToLocalDate(incomingFormat: App.dateFormat.serverSendDateTime)?.timeAgoDisplay()
            } else {
                // Fallback on earlier versions
            }
            
            let int_LikeCount = feed.likes ?? 0
            if int_LikeCount == 0 {
                cell.likeBtn.setTitle("", for: .normal)
            }
            else {
                cell.likeBtn.setTitle(String(feed.likes ?? 0), for: .normal)
            }
            
            let int_CommentCount = feed.comments ?? 0
            if int_CommentCount == 0 {
                cell.commentBtn.setTitle("", for: .normal)
            }
            else {
                cell.commentBtn.setTitle(String(feed.comments ?? 0), for: .normal)
            }

            if feed.mylikes == 0{
                cell.likeBtn.setImage(UIImage(named: "like"), for: .normal)
            }else{
                cell.likeBtn.setImage(UIImage(named: "like-selected"), for: .normal)
            }
            cell.userIv.layer.cornerRadius = 14
            cell.postBtn.titleLabel?.font = cell.postBtn.titleLabel?.font.withSize(12)
            cell.userIv.clipsToBounds  = true
            
            var strFeedMsg = feed.message?.trimed().base64Decoded()
            if strFeedMsg == nil {
                strFeedMsg = feed.message
            }
            cell.textL.text = strFeedMsg
            
            cell.delegate = self
            return cell
        }
        
        //return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ARFeedDetailVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.feed = groupFeed[indexPath.row].feedID ?? ""
        vc.groupId =  groupFeed[indexPath.row].groupID ?? ""
        vc.isFromGroup = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func addGroupFeedComment(cell:ARAyuverseFeedCell?, feed: Feed) {
        let strCommentMsg = (cell?.commentTV.text ?? "").trimed()
        if strCommentMsg == "" {
            return
        }
        
        let params = ["feedcomment_id": "",
                      "comment_msg": strCommentMsg.base64Encoded() ?? "",
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
                      "comment_msg": strCommentMsg.base64Encoded() ?? "",
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
    func reportFeedUser(reportType: String, feed: Feed,reportUserId: String){
        let params = ["answer_id": "",
                      "comment_id": "",
                      "question_id": "",
                      "report_type": reportType,
                      "feed_id": feed.feedID ?? "",
                      "report_message": "reported",
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
        let params = ["feed_id": data?.feedID ?? "",
                      "group_id": group?.groupID ?? ""] as [String : Any]
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
        
        let params = ["feed_id": data?.feedID ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .shareFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                if self?.groupFeed[index].shares == 0{
                    self?.groupFeed[index].shares = 1
                }else{
                    self?.groupFeed[index].shares =  (self?.groupFeed[index].shares ?? 0) + 1
                }
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
}

extension ARGroupDetailVC {
    func showMoreActionAlert() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Request".localized(), style: .default, handler: { _ in
            self.showGroupRequestVC()
        }))
        actionSheet.addAction(UIAlertAction(title: "Settings".localized(), style: .default, handler: { _ in
            self.showGroupSettingVC()
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    static func showScreen(group: GroupData, fromVC: UIViewController) {
        let vc = ARGroupDetailVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.group = group
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
}
extension ARGroupDetailVC: ARAyuverseFeedCellDelegate {
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
                reportFeedUser(reportType: "3", feed: data!, reportUserId: "")
            }))
            actionSheet.addAction(UIAlertAction(title: "Report User".localized(), style: .default, handler: { _ in
                self.reportFeedUser(reportType: "7", feed: data!, reportUserId: data?.userProfile?.userID ?? "")
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
                alert.addAction(UIAlertAction(title: "Delete".localized(), style: .default){_ in
                    self.deleteFeed(feed: data!)
                })
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
                self.present(alert, animated: true)
            }))
        } else {
            actionSheet.addAction(UIAlertAction(title: "Report Post".localized(), style: .default, handler: { [self] _ in
                reportFeedUser(reportType: "3", feed: data!, reportUserId: "")
            }))
            actionSheet.addAction(UIAlertAction(title: "Report User".localized(), style: .default, handler: { _ in
                self.reportFeedUser(reportType: "7", feed: data!, reportUserId: data?.userProfile?.userID ?? "")
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
       // let someText:String = "Hello want to share text also"
       // let objectsToShare:UIImage =
          //  let sharedObjects:[AnyObject] = [objectsToShare,someText]
        shareAFeed(data: data , index: index ?? 0)
        UIApplication.share(cell.textL.text ?? "")
    }
}
