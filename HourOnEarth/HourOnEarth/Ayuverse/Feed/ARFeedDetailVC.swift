//
//  ARFeedDetailVC.swift
//  HourOnEarth
//
//  Created by Suraj Singh on 22/07/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import DropDown
import SDWebImage
import ActiveLabel

class ARFeedDetailVC: UIViewController, UITextViewDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentTV: UITextView!
    @IBOutlet weak var commentInputView: UIView!
    @IBOutlet weak var commentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var img_view_Nodata: UIImageView!
    @IBOutlet weak var lbl_Nodata_Title: UILabel!
    @IBOutlet weak var lbl_Nodata_subTitle: UILabel!
    @IBOutlet weak var btn_send: UIButton!
    @IBOutlet weak var view_Nodata: UIView!
    @IBOutlet weak var constraint_view_Bottom: NSLayoutConstraint!
    
    var commentViewBottomConstraintConstant: CGFloat = 0
    var keyboardAnimationDuration = 0.0
    
    var feed = ""
    var feedData: Feed?
    var comments: [Comment] = []
    var isUpdateComment = false
    var isUpdateReplyComment = false
    var isReplyComment = false
    var feedCommentId = ""
    var isFromGroup = false
    var groupId = ""
    var selectedCommentID = ""
    var comment_ID = ""
    var reply_comment_ID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentTV.addDoneToolbar()
        tableView.register(nibWithCellClass: ARAyuverseFeedCell.self)
        tableView.register(nibWithCellClass: ARAyuverseFeedMediaCell.self)
        tableView.register(nibWithCellClass: ARFeedCommentCell.self)
        tableView.register(nibWithCellClass: ARFeedCommentReplyCell.self)
        tableView.register(nibWithCellClass: ARNoCommentTableCell.self)
        self.tableView.pullTorefresh(#selector(self.Pullto_refreshScreen), tintcolor: kAppBlueColor, self)
        //self.view_Nodata.isHidden = true
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constraint_view_Bottom.constant = keyboardSize.size.height/2
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.constraint_view_Bottom.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @objc func Pullto_refreshScreen() {
        if isFromGroup{
            getGroupFeedComment()
        }else{
            fetchComments()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        changeIQKeyboardManagerEnableStatus(enable: false)
        observeKeyboardEvents()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        changeIQKeyboardManagerEnableStatus(enable: true)
        removeObserveKeyboardEvents()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupUI() {
        commentInputView.addShadow(shadowColor: UIColor.black.cgColor, shadowOffset: CGSize(width: 0, height: -1), shadowOpacity: 0.2, shadowRadius: 2)
        commentTV.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        commentTV.placeholder = "Write a comment".localized()
        commentTV.delegate = self
        //tableView.keyboardDismissMode = .onDrag
        commentTV.cornerRadiuss = 8
        commentTV.clipsToBounds = true
       // commentInputView.isHidden = true
        
        self.postButtonGrayColor()
        updateTableContentInset()
        if isFromGroup{
            getGroupFeedComment()
        }else{
            fetchComments()
        }
        
    }
    func fetchComments(){
        self.showActivityIndicator()
        let params = ["feed_id": feed] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .fetchComments, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            self?.tableView.closeEndPullRefresh()
            if isSuccess, let responseJSON = responseJSON {
                let feedComment = try? JSONDecoder().decode(FetchComment.self, from: responseJSON.rawData())
                self?.feedData = feedComment?.feed
                self?.comments =  feedComment?.comments ?? []
                self?.manageTableView()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func likeAComment(data: Comment?, index: Int) {
        
        let params = ["feed_id": data?.feedID ?? "",
                      "comment_id": data?.commentID ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .likeAComment, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let likeFeedData = try? JSONDecoder().decode(LikeFeedData.self, from: responseJSON.rawData())
                if likeFeedData?.status == "success"{
                    if self?.comments[index].mylike == 0 {
                        self?.comments[index].mylike = 1
                        self?.comments[index].likes =  (self?.comments[index].likes ?? 0) + 1
                    }else{
                        self?.comments[index].mylike = 0
                        self?.comments[index].likes =  (self?.comments[index].likes ?? 0) - 1
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

        let params = ["feed_id": feed, "group_id": groupId] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .shareFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                if self?.feedData?.shares == 0 {
                    self?.feedData?.shares = 1
                }else{
                    self?.feedData?.shares = (self?.feedData?.shares ?? 0) + 1
                }
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    
    func addAComment(commentText: String, feed: Feed) {
        if commentText == "" {
            return
        }
        
        let params = ["feedcomment_id": "",
                      "feed_id": feed.feedID!,
                      "comment_msg": commentText.base64Encoded() ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .commentOnFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                
                let addCommentData = try? JSONDecoder().decode(AddComment.self, from: responseJSON.rawData())
                if addCommentData?.status == "success"{
                    self?.commentTV.text = ""
                    feed.comments = (feed.comments ?? 0) + 1
                    let comment = Comment.init(commentID: String(addCommentData?.data?.commentID ?? 0), gfeedID: "", feedID: addCommentData?.data?.feedID, userID: addCommentData?.data?.userID, feedcommentsID: addCommentData?.data?.feedcommentsID, userId1: addCommentData?.data?.userId1, message: addCommentData?.data?.message, mylike: addCommentData?.data?.mylike, likes: addCommentData?.data?.likes, shares: addCommentData?.data?.shares, createdAt: addCommentData?.data?.createdAt, updatedAt: "", isReported: addCommentData?.data?.isReported, commentcount: addCommentData?.data?.commentcount, commentarray: addCommentData?.data?.commentarray as? [Commentarray], userProfile: addCommentData?.data?.userProfile)
                    self?.comments.append(comment)
                    self?.feedData?.comments = feed.comments ?? 0
                    self?.manageTableView()
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
    
    func update_Comment(commentText: String, feed: Feed) {
        if commentText == "" {
            return
        }

        self.showActivityIndicator()
        var params = ["action_type": "1",
                      "feed_id": feed.feedID!,
                      "comment_id": self.comment_ID,
                      "comment_msg": commentText.base64Encoded() ?? ""] as [String : Any]
        
        var strURL: endPoint = .EditorDeleteAComment
        
        if self.isFromGroup {
            strURL = .EditorDeleteACommentGroup
            
            params = ["action_type": "1",
                      "gfeed_id": feed.feedID!,
                      "comment_id": self.comment_ID,
                      "comment_msg": commentText.base64Encoded() ?? ""] as [String : Any]
        }
        
        Utils.doAyuVerseAPICall(endPoint: strURL, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            self?.isUpdateComment = false
            if isSuccess, let responseJSON = responseJSON {
                self?.Pullto_refreshScreen()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    
    func addFeedMediaComment(cell: ARAyuverseFeedMediaCell?, feed: Feed) {
        let strCommentMsg = (cell?.commentTV1.text ?? "").trimed()
        if strCommentMsg == "" {
            return
        }
        
        let params = ["feedcomment_id": "",
                      "feed_id": feed.feedID!,
                      "comment_msg": strCommentMsg.base64Encoded() ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .commentOnFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                
                let addCommentData = try? JSONDecoder().decode(AddComment.self, from: responseJSON.rawData())
                if addCommentData?.status == "success"{
                    cell?.commentTV1.text = ""
                    feed.comments = (feed.comments ?? 0) + 1
                    cell?.commentBtn.setTitle(String(feed.comments ?? 0), for: .normal)
                    let comment = Comment.init(commentID: String(addCommentData?.data?.commentID ?? 0), gfeedID: "", feedID: addCommentData?.data?.feedID, userID: addCommentData?.data?.userID, feedcommentsID: addCommentData?.data?.feedcommentsID, userId1: addCommentData?.data?.userId1, message: addCommentData?.data?.message, mylike: addCommentData?.data?.mylike, likes: addCommentData?.data?.likes, shares: addCommentData?.data?.shares, createdAt: addCommentData?.data?.createdAt, updatedAt: "", isReported: addCommentData?.data?.isReported, commentcount: addCommentData?.data?.commentcount, commentarray: addCommentData?.data?.commentarray as? [Commentarray], userProfile: addCommentData?.data?.userProfile)
                    self?.comments.append(comment)
                    self?.manageTableView()
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
    func manageTableView() {
        //self.view_Nodata.isHidden = self.comments.count == 0 ? false : true
        self.tableView.reloadData()
    }
    func addGroupFeedComment(msg: String?,commentId: String?) {
        if (msg ?? "").trimed() == "" {
            return
        }

        let params = ["gfeed_id": feed,
                      "group_id": groupId,
                      "feedcomment_id": commentId!,
                      "id": kSharedAppDelegate.userId,
                      "comment_msg": msg?.base64Encoded() ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .groupFeedComment, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                
                let addCommentData = try? JSONDecoder().decode(AddComment.self, from: responseJSON.rawData())
                if addCommentData?.status == "success"{
                    self?.commentTV.text = ""
                    self?.getGroupFeedComment()
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: addCommentData?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.manageTableView()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func getGroupFeedComment(){
        let params = ["feed_id": feed, "group_id": groupId, "limit": "20", "offset": "0"] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .getGroupFeedComment, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            self?.tableView.closeEndPullRefresh()
            if isSuccess, let responseJSON = responseJSON {
                let feedComment = try? JSONDecoder().decode(FetchComment.self, from: responseJSON.rawData())
                  self?.feedData = feedComment?.feed
                 self?.comments =  feedComment?.comments ?? []
                //self?.feeds = welcome?.data ?? []
                self?.manageTableView()
                //self?.tableView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func addReplyOnComment(msg: String?,feedCommentId: String){
        if (msg ?? "") == "" {
            return
        }
        
        let params = ["feed_id": feed,
                      "feedcomment_id": feedCommentId,
                      "comment_msg": msg?.base64Encoded() ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .commentOnFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                
                let addCommentData = try? JSONDecoder().decode(AddReplyComment.self, from: responseJSON.rawData())
                if addCommentData?.status == "success"{
                   // if comment != nil{
                    self?.commentTV.text = ""
                    self?.fetchComments()
                   // }
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: addCommentData?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.isReplyComment = false
                //self?.isUpdateReplyComment = false
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
                self?.commentTV.placeholder = "Write a comment".localized()
            } else {
                self?.commentTV.placeholder = "Write a comment".localized()
                self?.isReplyComment = false
                //self?.isUpdateReplyComment = false
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    func updateReplyOnComment(msg: String?, feed: Feed){
        if (msg ?? "") == "" {
            return
        }
        
        self.showActivityIndicator()
        var params = ["action_type": "1",
                      "feed_id": feed.feedID!,
                      "comment_id": self.reply_comment_ID,
                      "comment_msg": msg?.base64Encoded() ?? ""] as [String : Any]
        
        var strURL: endPoint = .EditorDeleteAComment
        
        if self.isFromGroup {
            strURL = .EditorDeleteACommentGroup
            
            params = ["action_type": "1",
                      "gfeed_id": feed.feedID!,
                      "comment_id": self.reply_comment_ID,
                      "comment_msg": msg?.base64Encoded() ?? ""] as [String : Any]
        }
        
        Utils.doAyuVerseAPICall(endPoint: strURL, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                self?.commentTV.text = ""
                self?.isReplyComment = false
                self?.isUpdateReplyComment = false
                self?.Pullto_refreshScreen()
                self?.tableView.reloadData()
                self?.hideActivityIndicator()
                self?.commentTV.placeholder = "Write a comment".localized()
            } else {
                self?.commentTV.placeholder = "Write a comment".localized()
                self?.isReplyComment = false
                self?.isUpdateReplyComment = false
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    func deleteComment(feedID: String, commentID: String) {
        
        self.showActivityIndicator()
        var params = ["action_type": "2",
                      "feed_id": feedID,
                      "comment_id": commentID] as [String : Any]
        
        var strURL: endPoint = .EditorDeleteAComment
        
        if self.isFromGroup {
            strURL = .EditorDeleteACommentGroup
            
            params = ["action_type": "2",
                      "gfeed_id": feedID,
                      "comment_id": commentID] as [String : Any]
        }
        
        Utils.doAyuVerseAPICall(endPoint: strURL, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                self?.Pullto_refreshScreen()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    
    
    @IBAction func sendBtnPressed(sender: UIButton) {
        guard let commentText = commentTV.text else {
            print("no comment entered")
            return
        }
        if commentTV.text != ""{
            if isFromGroup{
                if isReplyComment {
                    if self.isUpdateReplyComment {
                        updateReplyOnComment(msg: commentText, feed: feedData!)
                    }
                    else {
                        addGroupFeedComment(msg: commentText, commentId: feedCommentId)
                    }
                }else{
                    if self.isUpdateComment {
                        update_Comment(commentText: commentText, feed: feedData!)
                    }
                    else {
                        addGroupFeedComment(msg: commentText, commentId: "")
                    }
                }
            }else{
                if isReplyComment {
                    if self.isUpdateReplyComment {
                        updateReplyOnComment(msg: commentText, feed: feedData!)
                    }
                    else {
                        addReplyOnComment(msg: commentText, feedCommentId: feedCommentId)
                    }
                }else{
                    if self.isUpdateComment {
                        update_Comment(commentText: commentText, feed: feedData!)
                    }
                    else {
                        addAComment(commentText: commentText, feed: feedData!)
                    }
                    
                }
            }
            
            self.view.endEditing(true)
            DispatchQueue.main.async {
                self.tableView.scrollToBottom()
            }
        }else{
            print("Please Enter Comment or Reply")
        }
        
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
        
        if textView.text?.trimed() == "" {
            self.postButtonGrayColor()
        }
        else {
            let origImage = UIImage(named: "send-btn")
            self.btn_send.setImage(origImage, for: .normal)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 500
    }
}


extension ARFeedDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if comments.count == 0 {
            return 2
        }
        return comments.count + 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            if comments.count == 0 {
                return 0
            }
            else {
                let arrData = self.comments[section - 1]
                let id = arrData.commentID ?? ""
                if self.selectedCommentID == id {
                    return arrData.commentarray?.count ?? 0
                }
                else {
                    return 0
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        else {
            if comments.count == 0 {
                let cell = tableView.dequeueReusableCell(withClass: ARNoCommentTableCell.self)
                cell.selectionStyle = .none
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withClass: ARFeedCommentCell.self)
                cell.selectionStyle = .none
                cell.delegate = self
                cell.comment = comments[section - 1]
                cell.index = section - 1
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return UITableView.automaticDimension
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if let dic_feedData = feedData {
                    if dic_feedData.files!.count > 0 {
                        let cell = tableView.dequeueReusableCell(withClass: ARAyuverseFeedMediaCell.self)
                        cell.feed = dic_feedData
                        cell.index = indexPath.section
                        cell.currentController = self
                        cell.setupData(dic_feedData)
                        
                        var strPostMsg = dic_feedData.message?.trimed().base64Decoded()
                        if strPostMsg == nil {
                            strPostMsg = dic_feedData.message
                        }

                        let arr_GetURL = Utils.getLinkfromString(str_msggggg: strPostMsg ?? "")
                        if arr_GetURL.count != 0 {
                            for strGetURL in arr_GetURL {
                                if strGetURL.contains("http") {
                                }
                                else {
                                    strPostMsg = strPostMsg?.replacingOccurrences(of: strGetURL, with: "https://\(strGetURL)")
                                }
                            }
                        }
                                
                        cell.textL.customize { label in
                            label.text = strPostMsg ?? ""
                            label.textColor = UIColor.black
                            label.hashtagColor = kAppBlueColor
                            label.URLColor = kAppBlueColor

                            label.handleHashtagTap { self.tappedonLabel("Hashtag", message: $0) }
                            label.handleURLTap { self.tappedonLabel("URL", message: $0.absoluteString) }

                            let readmoreFont = UIFont.boldSystemFont(ofSize: 14)
                            let readmoreFontColor = UIColor().hexStringToUIColor(hex: "#3E8B3A")

                            cell.textL.numberOfLines = 0
                        }
                        

                        cell.delegate = self
                        cell.commentStView1.isHidden = true

                        return cell
                        
                    } else {
                        let cell = tableView.dequeueReusableCell(withClass: ARAyuverseFeedCell.self)
                        cell.feed = dic_feedData
                        cell.index = indexPath.section
                        cell.setupData(dic_feedData)
                        
                        var strPostMsg = dic_feedData.message?.trimed().base64Decoded()
                        if strPostMsg == nil {
                            strPostMsg = dic_feedData.message
                        }

                        let arr_GetURL = Utils.getLinkfromString(str_msggggg: strPostMsg ?? "")
                        if arr_GetURL.count != 0 {
                            for strGetURL in arr_GetURL {
                                if strGetURL.contains("http") {
                                }
                                else {
                                    strPostMsg = strPostMsg?.replacingOccurrences(of: strGetURL, with: "https://\(strGetURL)")
                                }
                            }
                        }
                                
                        cell.textL.customize { label in
                            label.text = strPostMsg ?? ""
                            label.textColor = UIColor.black
                            label.hashtagColor = kAppBlueColor
                            label.URLColor = kAppBlueColor

                            label.handleHashtagTap { self.tappedonLabel("Hashtag", message: $0) }
                            label.handleURLTap { self.tappedonLabel("URL", message: $0.absoluteString) }

                            let readmoreFont = UIFont.boldSystemFont(ofSize: 14)
                            let readmoreFontColor = UIColor().hexStringToUIColor(hex: "#3E8B3A")

                            cell.textL.numberOfLines = 0
                        }
                        
                        
                        cell.commentStView.isHidden = true
                        cell.delegate = self

                        return cell
                    }
                }
            }
        } else {
            let cell = tableView.dequeueReusableCell(withClass: ARFeedCommentReplyCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.delegate = self
            
            let commentReply = self.comments[indexPath.section - 1].commentarray?[indexPath.row]
            cell.comment = commentReply
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tappedonLabel(_ title: String, message: String) {
        
        if title == "Hashtag" {
            debugPrint("user tapped on hashtag text")
            
            let vc = ARSearchFeedVC.instantiate(fromAppStoryboard: .Ayuverse)
            vc.str_Search = "#\(message)"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if title == "URL" {
            debugPrint("user tapped on link text")
            kSharedAppDelegate.openWebLinkinBrowser(message)
        }
    }

    
    func deleteFeed(feed: Feed){
        let params = ["feed_id": feed.feedID ?? ""] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .deleteFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let deletFeed = try? JSONDecoder().decode(DeleteFeed.self, from: responseJSON.rawData())
                if deletFeed?.status == "success"{
                    self?.navigationController?.popViewController(animated: true)
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
        
        let params = ["group_id": "",
                      "answer_id": "",
                      "comment_id": "",
                      "question_id": "",
                      "report_type": reportType,
                      "feed_id": feed.feedID ?? "",
                      "report_message": report_msg,
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
        let params = ["feed_id": feed,"group_id": groupId] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .likeAFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let likeFeedData = try? JSONDecoder().decode(LikeFeedData.self, from: responseJSON.rawData())
                if likeFeedData?.status == "success"{
                    if self?.feedData?.mylikes == 0{
                        self?.feedData?.mylikes = 1
                        self?.feedData?.likes =  (self?.feedData?.likes ?? 0) + 1
                    }else{
                        self?.feedData?.mylikes = 0
                        self?.feedData?.likes =  (self?.feedData?.likes ?? 0) - 1
                    }
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
    
}


extension ARFeedDetailVC: ARAyuverseFeedCellDelegate, delegate_repot {
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
                vc.isGroup = self.isFromGroup
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
                //self.reportFeedUser(reportType: "0", feed: data!, reportUserId: "")
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
               //self.reportFeedUser(reportType: "0", feed: data!, reportUserId: "")
            }))
            actionSheet.addAction(UIAlertAction(title: "Report User".localized(), style: .default, handler: { _ in
                self.openReportPostDialouge(strReportPost_User: "user", selectedFedd: data)
                //self.reportFeedUser(reportType: "7", feed: data!, reportUserId: data?.userProfile?.userID ?? "")
            }))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedPostBtn btn: UIButton, data: Feed?) {
       /* if cell.commentTV.text != ""{
            if isFromGroup{
                addGroupFeedComment(msg: cell.commentTV.text, commentId: "")
                cell.commentTV.text = ""
            }else{
               addAComment(cell: cell, feed: data!)
            }
        }else{
            print("Please Enter Comment First")
        } */
        
    }
    func ayuverseFeedCell(cell: ARAyuverseFeedMediaCell, didPressedPostBtn btn: UIButton, data: Feed?) {
        if cell.commentTV1.text != "" {
            if isFromGroup{
                addGroupFeedComment(msg: cell.commentTV1.text, commentId: "")
                cell.commentTV1.text = ""
            }else{
               addFeedMediaComment(cell: cell, feed: data!)
            }
        }else{
            print("Please Enter Comment First")
        }
    }
    
   
    
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedCommentBtn btn: UIButton, data: Feed?) {
        DebugLog("-")
        guard let data = data else { return }
        commentTV.becomeFirstResponder()
    }
    
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedShareBtn btn: UIButton, data: Feed?, index: Int?) {
        DebugLog("-")
        shareAFeed(data: data , index: index ?? 0)
        UIApplication.share(cell.textL.text ?? "")
    }
    
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedLikeBtn btn: UIButton, data: String?) {
        DebugLog("-")
        
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
                self.reportFeedUser(reportType: "0", feed: selectedFeed!, reportUserId: "", report_msg: reportmsg)
            }
            else {
                self.reportFeedUser(reportType: "7", feed: selectedFeed!, reportUserId: selectedFeed?.userProfile?.userID ?? "", report_msg: reportmsg)
            }
        }
    }
}

extension ARFeedDetailVC: ARFeedCommentReplyCellDelegate {
    func commentCell(cell: ARFeedCommentReplyCell, didPressOptionBtn data: Commentarray?, index: Int?) {
        
        print("do edit delete on index : ", cell.index ?? 0)
        //Edit Delete Comment
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Edit".localized(), style: .default, handler: { _ in
            var strComment = data?.message?.trimed().base64Decoded()
            if strComment == nil {
                strComment = data?.message ?? ""
            }
            self.isReplyComment = true
            self.isUpdateReplyComment = true
            self.commentTV.placeholder = ""
            self.commentTV.text = strComment
            self.reply_comment_ID = data?.commentID ?? ""
            let origImage = UIImage(named: "send-btn")
            self.btn_send.setImage(origImage, for: .normal)
            self.commentTV.becomeFirstResponder()
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { _ in
            let alert = UIAlertController(title: "Delete Comment".localized(), message: "Are you sure you want to delete this comment?".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive){_ in
                //Delete Comment
                self.deleteComment(feedID: data?.feedID ?? "", commentID: data?.commentID ?? "")
            })
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
            self.present(alert, animated: true)
        }))
        self.present(actionSheet, animated: true, completion: nil)
        
    }
}



extension ARFeedDetailVC {
    func observeKeyboardEvents() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func removeObserveKeyboardEvents() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func changeIQKeyboardManagerEnableStatus(enable: Bool) {
        IQKeyboardManager.shared.enable = enable
        IQKeyboardManager.shared.enableAutoToolbar = enable
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.32
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        //print("Keyboard height in method: \(keyboardViewEndFrame.height)")
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            commentViewBottomConstraintConstant = 0
            resetCommentView()
        } else {
            commentViewBottomConstraintConstant = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
            activateCommentView()
        }
    }
    
    func activateCommentView() {
        UIView.animate(
            withDuration: keyboardAnimationDuration,
            delay: 0.0,
            options: [.curveEaseIn],
            animations: {
                self.commentViewBottomConstraint.constant = self.commentViewBottomConstraintConstant
                self.view.layoutIfNeeded()
            }) { success in
                self.updateTableContentInset()
            }
    }
    
    func resetCommentView() {
        UIView.animate(
            withDuration: keyboardAnimationDuration,
            delay: 0.0,
            options: [.curveEaseOut],
            animations: {
                self.commentViewBottomConstraint.constant = self.commentViewBottomConstraintConstant
            }) { success in
                self.updateTableContentInset()
            }
        commentTV.text = ""
        self.isUpdateComment = false
        commentTV.placeholder = "Write a comment".localized()
        self.postButtonGrayColor()
        commentTV.textViewDidChange(commentTV)
    }
    
    func updateTableContentInset() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: commentInputView.frame.height, right: 0)
    }
    
    func postButtonGrayColor() {
        let origImage = UIImage(named: "send-btn")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        self.btn_send.setImage(tintedImage, for: .normal)
        self.btn_send.tintColor = kAppMidGreyColor
    }
}

extension ARFeedDetailVC: ARFeedCommentCellDelegate {
    func commentCell(cell: ARFeedCommentCell, didPressViewReplyBtn data: Comment?) {
        if self.selectedCommentID == cell.comment?.commentID ?? "" {
            self.selectedCommentID = ""
        }
        else {
            self.selectedCommentID = cell.comment?.commentID ?? ""
        }
        self.tableView.reloadData()
        /*if let indexPath = tableView.indexPath(for: cell) {
            print("view reply on index : ", indexPath.row)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ARFeedCommentReplyVC") as! ARFeedCommentReplyVC
            vc.comment = data
            self.present(vc, animated: true, completion: nil)
        }*/
    }
    
    func commentCell(cell: ARFeedCommentCell, didPressLikeBtn data: Comment?, index: Int?) {
        //if let indexPath = tableView.indexPath(for: cell) {
        print("do like on index : ", cell.index)
            likeAComment(data: data , index: index ?? 0)
        //}
    }
    
    func commentCell(cell: ARFeedCommentCell, didPressReplyBtn data: Comment?) {
        //if let indexPath = tableView.indexPath(for: cell) {
        print("do reply on index : ", cell.index)
        feedCommentId = data?.commentID ?? ""
        isReplyComment = true
        self.isUpdateReplyComment = false
        commentTV.placeholder = "Add your reply...".localized()
        commentInputView.isHidden = false
        commentTV.becomeFirstResponder()
        
        
        //}
    }
    
    
    func commentCell(cell: ARFeedCommentCell, didPressEditDeleteBtn data: Comment?, index: Int?) {
        print("do edit delete on index : ", cell.index ?? 0)
        //Edit Delete Comment
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Edit".localized(), style: .default, handler: { _ in
            var strComment = data?.message?.trimed().base64Decoded()
            if strComment == nil {
                strComment = data?.message ?? ""
            }
            self.isUpdateComment = true
            self.commentTV.placeholder = ""
            self.commentTV.text = strComment
            self.comment_ID = data?.commentID ?? ""
            let origImage = UIImage(named: "send-btn")
            self.btn_send.setImage(origImage, for: .normal)
            self.commentTV.becomeFirstResponder()
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { _ in
            let alert = UIAlertController(title: "Delete Comment".localized(), message: "Are you sure you want to delete this comment?".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive){_ in
                //Delete Comment
                self.deleteComment(feedID: data?.feedID ?? "", commentID: data?.commentID ?? "")
            })
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
            self.present(alert, animated: true)
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
   
}
