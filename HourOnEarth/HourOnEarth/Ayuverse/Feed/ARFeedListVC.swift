//
//  ARFeedListVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 10/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SwiftyJSON
import DropDown
import Alamofire
import SDWebImage
import ActiveLabel


class ARFeedListVC: UIViewController, UITextViewDelegate {
    
    var pageNO = 0
    var data_limit = 15
    var isLoading = false
    
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var deviderView: UIView!
    @IBOutlet weak var contentLibraryBtn: UIButton!
    @IBOutlet weak var categoryPickerView: ARCategoryPickerView!
    @IBOutlet weak var view_SearchBG: UIView!
    @IBOutlet weak var txt_Search: UITextField!
    @IBOutlet weak var constraint_view_SearchBG_Height: NSLayoutConstraint!
    @IBOutlet weak var img_view_Nodata: UIImageView!
    @IBOutlet weak var lbl_Nodata_Title: UILabel!
    @IBOutlet weak var lbl_Nodata_subTitle: UILabel!
    @IBOutlet weak var view_Nodata: UIView!
    @IBOutlet weak var lbl_writeSomething: UILabel!
    @IBOutlet weak var btn_AddMedia: UIButton!
    
    //var feeds = ["1", "2", "2", "2", "2", "2", "2", "2"]
    var isReadMore = false
    
    var feeds: [Feed] = []
    var AllFeeds: [Feed] = []
    var isSearching = false
    var selectedCategeory = "all"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view_Nodata.isHidden = true
        self.lbl_Nodata_subTitle.textAlignment = .center
        self.constraint_view_SearchBG_Height.constant = 0
        self.view_SearchBG.isHidden = true
        self.lbl_writeSomething.text = "Write something to post!".localized()
        self.btn_AddMedia.setTitle("Add media".localized(), for: .normal)
        self.contentLibraryBtn.setTitle("Content library".localized(), for: .normal)
        setupUI()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoryPickerView.collectionView.reloadData()
    }
    
    func setupUI() {
        feedTableView.register(nibWithCellClass: ARAyuverseFeedCell.self)
        feedTableView.register(nibWithCellClass: ARAyuverseFeedMediaCell.self)
        categoryPickerView.delegate = self
        self.feedTableView.pullTorefresh(#selector(self.Pullto_refreshScreen), tintcolor: kAppBlueColor, self)
        
        self.txt_Search.clearButtonMode = .whileEditing
        self.txt_Search.addTarget(self, action: #selector(self.textFieldEditing(_:)), for: .editingChanged)
        
        ARAyuverseManager.shared.fetchCommonData { [weak self] in
           self?.categoryPickerView.reloadData()
        
        }
        deviderView.isHidden = true
        contentLibraryBtn.isHidden = true
        
        
    }
    @objc func Pullto_refreshScreen() {
        self.pageNO = 0
        self.hide_SearchBar()
        self.txt_Search.text = ""
        self.getFeedList(categeory: selectedCategeory)
    }

    override func viewWillAppear(_ animated: Bool) {
        if isSearching {
            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
            searchFeedFromServer(text: "") { (success) in
                Utils.stopActivityIndicatorinView(self.view)
            }
        } else {
            getFeedList(categeory: selectedCategeory)
        }
        
    }
    func likeAFeed(data: Feed?, index: Int){
        
        let params = ["feed_id": data?.feedID ?? ""] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .likeAFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let likeFeedData = try? JSONDecoder().decode(LikeFeedData.self, from: responseJSON.rawData())
                if likeFeedData?.status == "success"{
                    if self?.feeds[index].mylikes == 0{
                        self?.feeds[index].mylikes = 1
                        self?.feeds[index].likes =  (self?.feeds[index].likes ?? 0) + 1
                    }else{
                        self?.feeds[index].mylikes = 0
                        self?.feeds[index].likes =  (self?.feeds[index].likes ?? 0) - 1
                    }
                    self?.feedTableView.reloadData()
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: likeFeedData?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.feedTableView.reloadData()
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
                if self?.feeds[index].shares == 0 {
                    self?.feeds[index].shares = 1
                }else{
                    self?.feeds[index].shares =  (self?.feeds[index].shares ?? 0) + 1
                }
                self?.feedTableView.reloadData()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    
    func deleteFeed(feed: Feed){
        let params = ["feed_id": feed.feedID ?? ""] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .deleteFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let deletFeed = try? JSONDecoder().decode(DeleteFeed.self, from: responseJSON.rawData())
                if deletFeed?.status == "success"{
                    let alert = UIAlertController(title: "Success".localized(), message: deletFeed?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                    self?.getFeedList(categeory: "all")
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
    func searchFeedFromServer (text: String, completion: @escaping (Bool)->Void) {
        if Utils.isConnectedToNetwork() {
            let urlString = kBaseNewURL + endPoint.searchFeed.rawValue
            let params = ["offset": 0,
                          "limit": self.data_limit,
                          "keyword": text,"datefilter": ""] as [String : Any]
            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { response in
                switch response.result {
                case .success(let value):
                    let welcome = try? JSONDecoder().decode(Welcome.self, from: response.data!)
                    self.feeds = welcome?.data ?? []
                    
                    if self.txt_Search.text == "" {
                        self.feeds = self.AllFeeds
                    }

                    completion(true)
                case .failure(_):
                    completion(false)
                }
            }
        }else {
            completion(false)
        }
    }
    func reportFeedUser(reportType: String, feed: Feed,reportUserId: String, report_msg: String){
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
    
    func getFeedList(categeory: String?) {
        
        let params = ["offset": self.pageNO,
                      "limit": self.data_limit,
                      "category" : categeory ?? "all"] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .getAllFeedList, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                
                let welcome = try? JSONDecoder().decode(Welcome.self, from: responseJSON.rawData())
                let arr_Data = welcome?.data ?? []
                
                if self?.pageNO == 0 {
                    self?.feeds.removeAll()
                    self?.AllFeeds.removeAll()
                }
                
                if arr_Data.count != 0 {
                    if self?.pageNO == 0 {
                        self?.feeds = welcome?.data ?? []
                    }
                    else {
                        for dic in arr_Data {
                            self?.feeds.append(dic)
                        }
                    }
                    self?.isLoading = false
                }
                else {
                    self?.isLoading = true
                }

                self?.AllFeeds = self?.feeds ?? []
                self?.manageTableView()
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    
    func addAComment(cell: ARAyuverseFeedCell?, feed: Feed) {
        let strCommentMsg = (cell?.commentTV.text ?? "").trimed()
        if strCommentMsg == "" {
            return
        }
        
        let params = ["feedcomment_id": "",
                      "feed_id": feed.feedID!,
                      "comment_msg": strCommentMsg] as [String : Any]
        
        Utils.doAyuVerseAPICall(endPoint: .commentOnFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
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
                self?.hideActivityIndicator()
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
                      "comment_msg": strCommentMsg] as [String : Any]

        Utils.doAyuVerseAPICall(endPoint: .commentOnFeed, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
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
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }

    
    @IBAction func createFeedPostBtnPressed(sender: UIButton) {
        let vc = ARCreateFeedPostVC.instantiate(fromAppStoryboard: .Ayuverse)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openContentLibraryBtnPressed(sender: UIButton) {
        ARContentLibraryHomeVC.showScreen(fromVC: self)
    }
}

extension ARFeedListVC: UITableViewDelegate, UITableViewDataSource {
    
    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global().async {
                // Fake background loading task for 2 seconds
                sleep(2)
                // Download more data here
                DispatchQueue.main.async {
                    self.pageNO = self.feeds.count
                    self.getFeedList(categeory: self.selectedCategeory)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if feeds[indexPath.row].files?.count ?? 0 > 0 {
            let cell = tableView.dequeueReusableCell(withClass: ARAyuverseFeedMediaCell.self, for: indexPath)
            cell.feed = feeds[indexPath.row]
            cell.currentController = self
            cell.index = indexPath.row
            cell.setupData(feeds[indexPath.row])
            
            var strPostMsg = feeds[indexPath.row].message?.trimed().base64Decoded()
            if strPostMsg == nil {
                strPostMsg = feeds[indexPath.row].message
            }
            
            let customType1 = ActiveType.custom(pattern: "\\sSee More\\b".localized()) //Looks for "are"
            let customType2 = ActiveType.custom(pattern: "\\sSee Less\\b".localized()) //Looks for "are"
            cell.textL.enabledTypes.append(customType1)
            cell.textL.enabledTypes.append(customType2)

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

                label.handleHashtagTap { self.tappedonLabel("Hashtag", message: $0, indx: indexPath) }
                label.handleURLTap { self.tappedonLabel("URL", message: $0.absoluteString, indx: indexPath) }

                let noOfLines = cell.textL.calculateMaxLines()
                let readmoreFont = UIFont.boldSystemFont(ofSize: 14)
                let readmoreFontColor = UIColor().hexStringToUIColor(hex: "#3E8B3A")

                if noOfLines > 4 {
                    cell.textL.numberOfLines = feeds[indexPath.row].is_ReadMore ? 0 : 4
                    let strWith_Text = feeds[indexPath.row].is_ReadMore ? "   " :"... "
                    let addTrellingText = feeds[indexPath.row].is_ReadMore ? kSeeMoreLessText.See_Less.rawValue.localized() : kSeeMoreLessText.See_More.rawValue.localized()
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
                if indexPath.row == self.feeds.count - 4 {
                    self.loadMoreData()
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: ARAyuverseFeedCell.self, for: indexPath)
            cell.feed = feeds[safe: indexPath.row]
            cell.index = indexPath.row

            cell.setupData(feeds[indexPath.row])

            var strPostMsg = feeds[indexPath.row].message?.trimed().base64Decoded()
            if strPostMsg == nil {
                strPostMsg = feeds[indexPath.row].message ?? ""
            }

            let customType1 = ActiveType.custom(pattern: "\\sSee More\\b".localized()) //Looks for "are"
            let customType2 = ActiveType.custom(pattern: "\\sSee Less\\b".localized()) //Looks for "are"
            cell.textL.enabledTypes.append(customType1)
            cell.textL.enabledTypes.append(customType2)

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

                label.handleHashtagTap { self.tappedonLabel("Hashtag", message: $0, indx: indexPath) }
                label.handleURLTap { self.tappedonLabel("URL", message: $0.absoluteString, indx: indexPath) }

                let noOfLines = cell.textL.calculateMaxLines()
                let readmoreFont = UIFont.boldSystemFont(ofSize: 14)
                let readmoreFontColor = UIColor().hexStringToUIColor(hex: "#3E8B3A")

                if noOfLines > 4 {
                    cell.textL.numberOfLines = feeds[indexPath.row].is_ReadMore ? 0 : 4
                    let strWith_Text = feeds[indexPath.row].is_ReadMore ? "   " :"... "
                    let addTrellingText = feeds[indexPath.row].is_ReadMore ? kSeeMoreLessText.See_Less.rawValue.localized() : kSeeMoreLessText.See_More.rawValue.localized()
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
                if indexPath.row == self.feeds.count - 4 {
                    self.loadMoreData()
                }
            }
            
            return cell
        }
        
        
        
    }

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
                feeds[indx.row].is_ReadMore = true
                self.feedTableView.reloadData()
                debugPrint("user tapped on see more text")
            }
            else if message == kSeeMoreLessText.See_Less.rawValue.localized().trimed() {
                feeds[indx.row].is_ReadMore = false
                self.feedTableView.reloadData()
                debugPrint("user tapped on see less text")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ARFeedDetailVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.feed = feeds[indexPath.row].feedID ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func manageTableView(_ search: Bool = false) {
        
        self.feedTableView.closeEndPullRefresh()
        
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
        self.view_Nodata.isHidden = self.feeds.count == 0 ? false : true
        self.feedTableView.reloadData()
    }
    
    
}

extension ARFeedListVC: ARCategoryPickerViewDelegate {
    func categoryPickerView(view: ARCategoryPickerView, didSelect category: ARAyuverseCategoryModel) {
        self.pageNO = 0
        if category.name == "All"{
            getFeedList(categeory: "all")
            selectedCategeory = "all"
        }else{
            getFeedList(categeory: category.name)
            selectedCategeory = category.name
        }
        
        
        print(">> selected category : ", category.name)
    }
}

extension ARFeedListVC: ARAyuverseFeedCellDelegate, delegate_repot {
    
    
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
//                self.reportFeedUser(reportType: "7", feed: data!, reportUserId: data?.userProfile?.userID ?? "")
            }))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedPostBtn btn: UIButton, data: Feed?) {
        addAComment(cell: cell, feed: data!)
    }
    
    func ayuverseFeedCell(cell: ARAyuverseFeedMediaCell, didPressedPostBtn btn: UIButton, data: Feed?) {
        addFeedMediaComment(cell: cell, feed: data!)
    }
        
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedCommentBtn btn: UIButton, data: Feed?) {
        DebugLog("-")
        guard let data = data else { return }
        let vc = ARFeedDetailVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.feed = data.feedID ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedShareBtn btn: UIButton, data: Feed?, index: Int?) {
        DebugLog("-")
        shareAFeed(data: data , index: index ?? 0)
        //guard let cell1 = cell as? ARAyuverseFeedMediaCell else{
         //   return
        //}
       /* let activityItems = [
                "Title",
                "Body",
                UIImage(systemName: "keyboard")!,
                UIImage(systemName: "square.and.arrow.up")!
            ] as [Any] */
        UIApplication.share(cell.textL.text ?? "")
        
        
    }
    
    
   /* func ayuverseFeedCell(cell: ARAyuverseFeedCell, didSelectMoreOption data: Datum?) {
        DebugLog("-")
    }
    
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedLikeBtn btn: UIButton, data: Datum?) {
        DebugLog("-")
    } */
    
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedCommentBtn btn: UIButton, data: String?) {
        DebugLog("-")
        guard let data = data else { return }
        let vc = ARFeedDetailVC.instantiate(fromAppStoryboard: .Ayuverse)
        vc.feed = data
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func ayuverseFeedCell(cell: ARAyuverseFeedCell, didPressedShareBtn btn: UIButton, data: String?) {
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
extension ARFeedListVC: UITextFieldDelegate {

    func show_SearchBar() {
        UIView.animate(withDuration: 0.3) {
            self.txt_Search.becomeFirstResponder()
            self.constraint_view_SearchBG_Height.constant = 60
            self.view_SearchBG.isHidden = false
            self.txt_Search.placeholder = "Search".localized()
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
                self.feeds = self.AllFeeds
                self.isSearching = false
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
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let strKey = textField.accessibilityHint, strKey == "ARAyuverseFeedMediaCell" {
            let indxxPath = IndexPath.init(row: textField.tag, section: 0)
            if let currentCell = feedTableView.cellForRow(at: indxxPath) as? ARAyuverseFeedMediaCell {
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
            if let currentCell = feedTableView.cellForRow(at: indxxPath) as? ARAyuverseFeedCell {
                if textField.text?.trimed() == "" {
                    currentCell.postBtn.setTitleColor(kAppMidGreyColor, for: .normal)
                }
                else {
                    currentCell.postBtn.setTitleColor(kAppBlueColor, for: .normal)
                }
            }
        }
    }
    
    
    func convert(_ hashElements:[String], string: String) -> NSAttributedString {

        let hasAttribute = [NSAttributedString.Key.foregroundColor: UIColor.orange]

        let normalAttribute = [NSAttributedString.Key.foregroundColor: UIColor.black]

        let mainAttributedString = NSMutableAttributedString(string: string, attributes: normalAttribute)

        let txtViewReviewText = string as NSString

        hashElements.forEach { if string.contains($0) {
            mainAttributedString.addAttributes(hasAttribute, range: txtViewReviewText.range(of: $0))
            }
        }
        return mainAttributedString
    }
    
}


