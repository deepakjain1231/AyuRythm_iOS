//
//  ARCreateFeedPostVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 07/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MobileCoreServices

class ARCreateFeedPostVC: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var txt_Feed: UITextView!
    @IBOutlet weak var lbl_mediaCount: UILabel!
    @IBOutlet weak var btn_Post: UIButton!
    @IBOutlet weak var btn_Add: UIControl!
    @IBOutlet weak var lbl_UploadMedia_Title: UILabel!
    @IBOutlet weak var lbl_Category_Title: UILabel!
    @IBOutlet weak var lbl_Category_Optional: UILabel!
    @IBOutlet weak var txt_Hashtag: UITextField!
    @IBOutlet weak var collectionView_Image: UICollectionView!
    @IBOutlet weak var picker_category: ARCategoryPickerView!
    @IBOutlet weak var collection_hashtag: UICollectionView!
    @IBOutlet weak var constraint_picker_hashtag_top: NSLayoutConstraint!
    @IBOutlet weak var constraint_picker_category_top: NSLayoutConstraint!
    @IBOutlet weak var constraint_picker_category_height: NSLayoutConstraint!
    @IBOutlet weak var constraint_picker_hashtag_height: NSLayoutConstraint!
    
    @IBOutlet weak var view_HashTagCollection_BG: UIView!
    @IBOutlet weak var collection_SearchHash: UICollectionView!
    @IBOutlet weak var constraint_collection_SearchHash_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_collection_SearchHash_Bottom: NSLayoutConstraint!
    
    var arr_SearchedTag: [HashTag] = []
    var mediaPicker: PDImagePicker?
    var mediaFileLimit: Int = 5
    var arr_medias = [[String: Any]]()
    var arr_Added_Hashtags = [String]()
    var currentCategeory = "others"
    var isGroup = false
    var groupId = ""
    var feed: Feed?
    var isEditingFeed = false
    var imageFiles = [String]()
    var deletedFiles = [String]()
    var arr_editedMedias = [[String: Any]]()
    var othersCategeory: ARAyuverseCategoryModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create a Post".localized()
        self.lbl_UploadMedia_Title.text = "".localized()
        self.lbl_Category_Title.text = "Choose category".localized()
        self.lbl_Category_Optional.text = "(Optional)".localized()
        self.btn_Post.setTitle("Post".localized(), for: .normal)
        self.lbl_UploadMedia_Title.text = "Upload media".localized()
        
        setupUI()
        updateUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK:- KEYBOARD METHODS
    @objc func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        let userinfo:NSDictionary = (notification.userInfo as NSDictionary?)!
        if let keybordsize = (userinfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //let bottmSafearea = kSharedAppDelegate.window?.safeAreaInsets.bottom ?? 0
            self.constraint_collection_SearchHash_Bottom.constant = keybordsize.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        print("keyboardWillHide")
        self.constraint_collection_SearchHash_Bottom.constant = 0
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView_Image.reloadData()
    }
    
    func setupUI() {
        self.view_HashTagCollection_BG.isHidden = true
        self.collection_SearchHash.backgroundColor = .clear
        self.constraint_collection_SearchHash_Bottom.constant = 0
        self.constraint_collection_SearchHash_Height.constant = 0
        //self.view_HashTagCollection_BG.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        
        let customBackBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ic-back-arrow"), title: "Back".localized(), target: self, action: #selector(backBtnPressed))
        self.navigationItem.leftBarButtonItem = customBackBtn
        
        self.picker_category.collectionView.setupUISpace(top: 0, left: 0, bottom: 0, right: 0, itemSpacing: 12, lineSpacing: 0)
        self.collection_SearchHash.setupUISpace(top: 0, left: 18, bottom: 0, right: 0, itemSpacing: 12, lineSpacing: 8)
        
        self.collection_hashtag.setupUISpace(allSide: 0, itemSpacing: 12, lineSpacing: 12)
        //self.collection_SearchHash.setupUISpace(allSide: 0, itemSpacing: 12, lineSpacing: 12)
        collectionView_Image.setupUISpace(allSide: 0, itemSpacing: 10, lineSpacing: 0)
        collectionView_Image.register(nibWithCellClass: ARFeedPostMediaCell.self)
        self.collection_hashtag.register(nibWithCellClass: ARFeedHashtagCollectionCell.self)
        self.collection_SearchHash.register(nibWithCellClass: SearchHashTagCollectionCell.self)
        
        self.arr_medias.append(["type": "image", "value" : #imageLiteral(resourceName: "add-image")])
        txt_Feed.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        txt_Feed.placeholder = "What's on your mind? Write here...".localized()
        txt_Feed.delegate = self
        self.txt_Hashtag.delegate = self
        self.txt_Hashtag.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        if self.isGroup {
            self.lbl_Category_Title.text = ""
            self.lbl_Category_Optional.text = ""
            self.constraint_picker_category_top.constant = -22
            self.constraint_picker_category_height.constant = 0
        }
        else {
            ARAyuverseManager.shared.categories.removeAll()
            ARAyuverseManager.shared.fetchCommonData { [weak self] in
                if ARAyuverseManager.shared.categories.count > 0{
                    ARAyuverseManager.shared.categories.remove(at: 0)
                    self?.othersCategeory = ARAyuverseCategoryModel(name: "Others", status: "1", id: "11")
                    ARAyuverseManager.shared.categories.append((self?.othersCategeory)!)
                }
                if self?.othersCategeory != nil{
                    self?.picker_category.selectedCategory = self?.othersCategeory
                }
               self?.picker_category.reloadData()
            }
        }
        
        
        if isEditingFeed {
            self.title = "Update a Post".localized()
            btn_Post.setTitle("Update".localized(), for: .normal)
            var strPostMsg = feed?.message?.trimed().base64Decoded()
            if strPostMsg == nil {
                strPostMsg = feed?.message
            }
            txt_Feed.text = strPostMsg
            if feed?.message != ""{
                txt_Feed.placeholder = ""
            }
            if feed?.files?.count ?? 0 > 0 {
                if let tempFiles = self.feed?.files as? [String] {
                    self.addImage_Video(strFile: tempFiles)
                }
            }
            else {
                self.setupdata_reloadCollection()
            }
        }
        else {
            self.btn_Post.backgroundColor = UIColor.lightGray
        }
    }
    
    func addImage_Video(strFile: [String]) {
        var arr_files = strFile
        
        if let strFrstFile = arr_files.first {
            if let url = URL(string: strFrstFile) {
                if url.pathExtension == "mp4" || url.pathExtension == "mov" {
                    let strThumURl = url.absoluteString.replacingOccurrences(of: url.pathExtension, with: "png")
                    if let str_imgURL = URL.init(string: strThumURl) {
                        if let data = try? Data(contentsOf: str_imgURL) {
                            let image: UIImage = UIImage(data: data)!
                            self.arr_medias.insert(["type": "video", "thumb": image, "value": url], at: 0)
                                imageFiles.insert(strFrstFile, at: 0)
                                arr_files.remove(at: 0)
                                if arr_files.count == 0 {
                                    self.updateUI()
                                    self.setupdata_reloadCollection()
                                }
                                else {
                                    self.addImage_Video(strFile: arr_files)
                                }
                            }
                    }
                    else {
                        getThumbnailImageFromVideoUrl(url: url) { imagee in
                            if let img = imagee {
                                self.arr_medias.insert(["type": "video", "thumb": img, "value": url], at: 0)
                                self.imageFiles.insert(strFrstFile, at: 0)
                                arr_files.remove(at: 0)
                                if arr_files.count == 0 {
                                    self.updateUI()
                                    self.setupdata_reloadCollection()
                                }
                                else {
                                    self.addImage_Video(strFile: arr_files)
                                }
                            }
                        }
                    }
                }
                else {
                    if let data = try? Data(contentsOf: url) {
                        let image: UIImage = UIImage(data: data)!
                        self.arr_medias.insert(["type": "image", "image_url": url, "value": image], at: 0)
                        imageFiles.insert(strFrstFile, at: 0)
                        arr_files.remove(at: 0)
                        if arr_files.count == 0 {
                            self.updateUI()
                            self.setupdata_reloadCollection()
                        }
                        else {
                            self.addImage_Video(strFile: arr_files)
                        }
                    }
                }
            }
        }

    }
    
    func setupdata_reloadCollection() {
        self.btn_Post.backgroundColor = kAppBlueColor
        
        let strTagss = feed?.tags ?? ""
        if strTagss != "" {
            self.arr_Added_Hashtags = strTagss.components(separatedBy: ",")
            self.collection_hashtag.reloadData()
            DispatchQueue.main.async {
                self.collection_hashtag.reloadData()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func updateUI() {
        self.collectionView_Image.reloadData()
        if self.txt_Feed.text == "" {
            self.btn_Post.backgroundColor = self.arr_medias.count == 1 ? .lightGray : kAppBlueColor
        }
        else {
            self.btn_Post.backgroundColor = kAppBlueColor
        }
        lbl_mediaCount.text = "\(self.arr_medias.count - 1)/\(mediaFileLimit)"
    }
    
    func showMediaPicker() {
        guard self.arr_medias.count < 6 else {
            showAlert(message: "Maximum \(mediaFileLimit) media files allowed in post")
            return
        }
        
        if mediaPicker == nil {
            mediaPicker = PDImagePicker(presentingVC: self, delegate: self, mediaTypes: [.image, .movie], allowsEditing: true)
        }
        mediaPicker?.present(is_video: true)
    }
    
    @objc func backBtnPressed() {
        if self.arr_medias.count > 1 || txt_Feed.text != "" {
            let alert = UIAlertController(title: "Do you really want to leave?".localized(), message: "If you leave now, you’ll lose this post".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Leave".localized(), style: .destructive){_ in
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
            self.present(alert, animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btn_addHashTag_Action(_ sender: UIControl) {
        var strHashTag = self.txt_Hashtag.text ?? ""
        if strHashTag.trimed() == "" {
            return
        }
        strHashTag = strHashTag.replacingOccurrences(of: " ", with: "")
        self.addHashTagInArray_Refresh(strHashTag)
    }
    
    @IBAction func postBtnPressed(sender: UIButton) {
        self.view.endEditing(true)
        let strPostText = (self.txt_Feed.text ?? "").trimed()
        if strPostText != "" || self.arr_medias.count > 1 {
            if isEditingFeed {
                editFeed(strPostText)
            }else{
                addFeed(strPostText)
            }
        }
    }
    func editFeed(_ postText: String) {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        var urlString = ""
        var params: [String: Any] = [:]
        if isGroup {
            urlString = kBaseNewURL + endPoint.editPostInAGroup.rawValue
            params = ["group_id": groupId,
                      "feed_id": feed?.feedID ?? "",
                      "decoded_message": postText,
                      "feed_message": postText.base64Encoded() ?? ""] as [String : Any]
            
            if deletedFiles.count != 0 {
                params["delete_files"] = "\(deletedFiles.joined(separator: ", ")),"
            }
        }
        else {
            urlString = kBaseNewURL + endPoint.editFeed.rawValue
            
            params = ["feed_id": feed?.feedID ?? "",
                      "decoded_message": postText,
                      "post_category" : self.currentCategeory,
                      "feed_message": postText.base64Encoded() ?? ""] as [String : Any]
            
            if deletedFiles.count != 0 {
                params["delete_files"] = "\(deletedFiles.joined(separator: ", ")),"
            }
        }
        AF.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in params {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            
            var temp_medias = self.arr_medias
            if let lastImage = temp_medias.last {
                if let img = lastImage["value"] as? UIImage, img == UIImage.init(named: "add-image") {
                    temp_medias.removeLast()
                }
            }
            
            for dic_media in temp_medias {
                if (dic_media["type"] as? String ?? "") == "image" {
                    if let img = dic_media["value"] as? UIImage, img != UIImage.init(named: "add-image") {
                        if let imgageurl = dic_media["image_url"] as? URL {
                            if imgageurl.absoluteString.contains("http") || imgageurl.absoluteString.contains("https") {
                            }
                            else {
                                guard let imgData = img.jpegData(compressionQuality: 0.7) else { return }
                                let timestamp = NSDate().timeIntervalSince1970
                                multipartFormData.append(imgData, withName: "image_files[]", fileName: String(timestamp) + ".jpeg", mimeType: "image/jpeg")
                            }
                        }
                        else {
                            guard let imgData = img.jpegData(compressionQuality: 0.7) else { return }
                            let timestamp = NSDate().timeIntervalSince1970
                            multipartFormData.append(imgData, withName: "image_files[]", fileName: String(timestamp) + ".jpeg", mimeType: "image/jpeg")
                        }
                    }
                }
                else {
                    if let videoURL = dic_media["value"] as? URL {
                        if videoURL.absoluteString.contains("http") || videoURL.absoluteString.contains("https") {
                        }
                        else {
                            let timestamp = NSDate().timeIntervalSince1970
                            multipartFormData.append(videoURL, withName: "image_files[]", fileName: String(timestamp) + ".mp4", mimeType: "video/mp4")
                        }
                    }
                }
            }
            
            
        },to: URL.init(string: urlString)!, usingThreshold: UInt64.init(),
                  method: .post,
                  headers: Utils.apiCallHeaders).response{ response in
            if((response.error == nil)){
                do{
                    if let jsonData = response.data{
                        if self.isGroup{
                            let addFeed = try? JSONDecoder().decode(PostGroupFeed.self, from: jsonData)
                            if addFeed?.status == "success" {
                                
                                if let stackVCs = self.navigationController?.viewControllers {
                                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARFeedDetailVC.self }) {
                                        (activeSubVC as? ARFeedDetailVC)?.Pullto_refreshScreen()
                                    }
                                }
                                
                                if let stackVCs = self.navigationController?.viewControllers {
                                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupViewAllVC.self }) {
                                        (activeSubVC as? ARGroupViewAllVC)?.pageNO = 0
                                        (activeSubVC as? ARGroupViewAllVC)?.getMyGroupList(false)
                                    }
                                }
                                
                                if let stackVCs = self.navigationController?.viewControllers {
                                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupDetailVC.self }) {
                                        (activeSubVC as? ARGroupDetailVC)?.pageNO = 0
                                        (activeSubVC as? ARGroupDetailVC)?.getGroupFeeds()
                                    }
                                }
                                
                                self.navigationController?.popViewController(animated: true)
                            }else{
                                let alert = UIAlertController(title: "Error".localized(), message: addFeed?.message, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                                self.present(alert, animated: true)
                            }
                        }else{
                            let addFeed = try? JSONDecoder().decode(AddFeed.self, from: jsonData)
                            if addFeed?.status == "success" {
                                
                                if let stackVCs = self.navigationController?.viewControllers {
                                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARFeedDetailVC.self }) {
                                        (activeSubVC as? ARFeedDetailVC)?.Pullto_refreshScreen()
                                    }
                                }
                                
                                if let stackVCs = self.navigationController?.viewControllers {
                                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARAyuverseHomeVC.self }) {
                                        ((activeSubVC as? ARAyuverseHomeVC)?.children.first as? ARFeedListVC)?.Pullto_refreshScreen()
                                    }
                                }
                                
                                
                                
                                self.navigationController?.popViewController(animated: true)
                            }else{
                                let alert = UIAlertController(title: "Error".localized(), message: addFeed?.message, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                                self.present(alert, animated: true)
                            }
                        }
                        
                    }
                }catch{
                    print("error message")
                }
                self.hideActivityIndicator()
            }else{
                self.hideActivityIndicator()
                print(response.error!.localizedDescription)
            }
        }
    }
    
    func addFeed(_ postText: String) {
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        var urlString = ""
        var params: [String: Any] = [:]
        if isGroup {
            urlString = kBaseNewURL + endPoint.postInAGroup.rawValue
            
            params = ["group_id": groupId,
                      "decoded_message": postText,
                      "feed_message": postText.base64Encoded() ?? ""] as [String : Any]
        }
        else{
            urlString = kBaseNewURL + endPoint.addFeed.rawValue
            
            params = ["post_category" : self.currentCategeory,
                      "decoded_message": postText,
                      "feed_message": postText.base64Encoded() ?? ""] as [String : Any]
        }
        AF.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in params {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            
            var temp_medias = self.arr_medias
            if let lastImage = temp_medias.last {
                if let img = lastImage["value"] as? UIImage, img == UIImage.init(named: "add-image") {
                    temp_medias.removeLast()
                }
            }
            
            for dic_media in temp_medias {
                if (dic_media["type"] as? String ?? "") == "image" {
                    if let img = dic_media["value"] as? UIImage, img != UIImage.init(named: "add-image") {
                        guard let imgData = img.jpegData(compressionQuality: 0.7) else { return }
                        let timestamp = NSDate().timeIntervalSince1970
                        multipartFormData.append(imgData, withName: "image_files[]", fileName: String(timestamp) + ".jpeg", mimeType: "image/jpeg")
                    }
                }
                else {
                    if let videoURL = dic_media["value"] as? URL {
                        let timestamp = NSDate().timeIntervalSince1970
                        multipartFormData.append(videoURL, withName: "image_files[]", fileName: String(timestamp) + ".mp4", mimeType: "video/mp4")
                    }
                }
            }
            
        },to: URL.init(string: urlString)!, usingThreshold: UInt64.init(),
                  method: .post,
                  headers: Utils.apiCallHeaders).response{ response in
            if((response.error == nil)){
                do{
                    if let jsonData = response.data{
                        if self.isGroup{
                            let addFeed = try? JSONDecoder().decode(PostGroupFeed.self, from: jsonData)
                            if addFeed?.status == "success" {
                                
                                if let stackVCs = self.navigationController?.viewControllers {
                                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupViewAllVC.self }) {
                                        (activeSubVC as? ARGroupViewAllVC)?.pageNO = 0
                                        (activeSubVC as? ARGroupViewAllVC)?.getMyGroupList(false)
                                    }
                                }
                                
                                if let stackVCs = self.navigationController?.viewControllers {
                                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupDetailVC.self }) {
                                        (activeSubVC as? ARGroupDetailVC)?.pageNO = 0
                                        (activeSubVC as? ARGroupDetailVC)?.getGroupFeeds()
                                    }
                                }
                                
                                self.navigationController?.popViewController(animated: true)
                            }else{
                                let alert = UIAlertController(title: "Error".localized(), message: addFeed?.message, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                                self.present(alert, animated: true)
                            }
                        }else{
                            let addFeed = try? JSONDecoder().decode(AddFeed.self, from: jsonData)
                            if addFeed?.status == "success" {
                                
                                if let stackVCs = self.navigationController?.viewControllers {
                                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARAyuverseHomeVC.self }) {
                                        ((activeSubVC as? ARAyuverseHomeVC)?.children.first as? ARFeedListVC)?.Pullto_refreshScreen()
                                    }
                                }
                                
                                self.navigationController?.popViewController(animated: true)
                            }else{
                                let alert = UIAlertController(title: "Error".localized(), message: addFeed?.message, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                                self.present(alert, animated: true)
                            }
                        }
                        
                    }
                }catch{
                    print("error message")
                }
                self.hideActivityIndicator()
            }else{
                self.hideActivityIndicator()
                print(response.error!.localizedDescription)
            }
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
        
        self.btn_Post.backgroundColor = textView.text == "" ? .lightGray : kAppBlueColor
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 1000
    }
    
    func mimeTypeForPath(path: URL) -> String {
        let pathExtension = path.pathExtension

        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    
    //MARK: - UITextFieldDelegte
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let strtrxt = textField.text ?? ""
        self.changeAddButtonEnableDisable(strtrxt)
        if strtrxt != "" {
            self.callAPIforSearchHashTag(strtrxt)
        }
        else {
            self.arr_SearchedTag.removeAll()
            self.view_HashTagCollection_BG.isHidden = true
            self.constraint_collection_SearchHash_Height.constant = 0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.arr_SearchedTag.removeAll()
        let strtrxt = textField.text ?? ""
        if strtrxt.trimed() == "" {
            self.changeAddButtonEnableDisable(strtrxt)
            self.view_HashTagCollection_BG.isHidden = true
            self.constraint_collection_SearchHash_Height.constant = 0
        }
        else {
            self.addHashTagInArray_Refresh(strtrxt)
        }
    }
    
    func changeAddButtonEnableDisable(_ strtrxt: String) {
        if strtrxt == "" {
            self.btn_Add.backgroundColor = .lightGray
        }
        else {
            self.btn_Add.backgroundColor = kAppBlueColor
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        return true
    }
}

//MARK: - UICollectionViewDelegate Datasource
extension ARCreateFeedPostVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collection_hashtag {
            return self.arr_Added_Hashtags.count
        }
        else if collectionView == self.collection_SearchHash {
            return self.arr_SearchedTag.count
        }
        else {
            return self.arr_medias.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collection_hashtag {
            let strHashTag = self.arr_Added_Hashtags[indexPath.row]
            let size = strHashTag.size(withAttributes:[.font: UIFont.systemFont(ofSize: 15)])
            var getNewWidth = size.width + 45
            getNewWidth = getNewWidth.rounded(FloatingPointRoundingRule.up)
            return CGSize.init(width: getNewWidth, height: 25)
        }
        else if collectionView == self.collection_SearchHash {
            if (self.arr_SearchedTag.count - 1) >= indexPath.row {
                let strHashTag = self.arr_SearchedTag[indexPath.row].tagname ?? ""
                let size = strHashTag.size(withAttributes:[.font: UIFont.systemFont(ofSize: 16)])
                var getNewWidth = size.width
                getNewWidth = getNewWidth.rounded(FloatingPointRoundingRule.up)
                return CGSize.init(width: getNewWidth, height: 50)
            }
            return CGSize.init(width: 50, height: 50)
        }
        else {
            let cellWidth = collectionView.widthOfItemCellFor(noOfCellsInRow: 3)
            return CGSize(width: cellWidth, height: cellWidth)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collection_hashtag {
            let cell = collectionView.dequeueReusableCell(withClass: ARFeedHashtagCollectionCell.self, for: indexPath)
            cell.view_Base.layer.cornerRadius = 6
            cell.lbl_Title.text = "#\(self.arr_Added_Hashtags[indexPath.item])"
            
            
            //Remove Tag
            cell.didTappedonOnRemoveTag = { (sender) in
                self.arr_Added_Hashtags.remove(at: indexPath.item)
                self.collection_hashtag.reloadData()
                
                if self.arr_Added_Hashtags.count == 0 {
                    //self.constraint_picker_hashtag_top.constant = 5
                    //self.constraint_picker_hashtag_height.constant = 0
                }
            }
            
            return cell
        }
        else if collectionView == self.collection_SearchHash {
            let cell = collectionView.dequeueReusableCell(withClass: SearchHashTagCollectionCell.self, for: indexPath)
            cell.view_Base.layer.cornerRadius = 6
            
            if (self.arr_SearchedTag.count - 1) >= indexPath.row {
                let strTagName = self.arr_SearchedTag[indexPath.item].tagname ?? ""
                if strTagName.first == "#" {
                    cell.lbl_Title.text = self.arr_SearchedTag[indexPath.item].tagname ?? ""
                }
                else {
                    cell.lbl_Title.text = "#\(self.arr_SearchedTag[indexPath.item].tagname ?? "")"
                }
                
                cell.didTappedonOnWholeCell = { (sender) in
                    let strHashTag = self.arr_SearchedTag[indexPath.item].tagname ?? ""
                    self.addHashTagInArray_Refresh(strHashTag)
                }
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withClass: ARFeedPostMediaCell.self, for: indexPath)
            cell.deleteBtn.tag = indexPath.row
            cell.isForCreatePostCell = true
            cell.count = self.arr_medias.count
            cell.media = self.arr_medias[indexPath.row]

            cell.delegate = self
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collection_hashtag {
        }
        else if collectionView == self.collection_SearchHash {
        }
        else {
            if indexPath.row == self.arr_medias.count - 1 {
                //show media picker
                showMediaPicker()
            } else {
                let media = self.arr_medias[indexPath.row]
                print(">> select media : ", media)
            }
        }
    }
    
    func addHashTagInArray_Refresh(_ strHashTag: String) {
        var strHashtag_Text = strHashTag
        if strHashtag_Text.first == "#" {
            strHashtag_Text = String(strHashtag_Text.dropFirst())
        }

        self.txt_Hashtag.text = ""
        self.btn_Add.backgroundColor = .lightGray
        self.view_HashTagCollection_BG.isHidden = true
        //self.constraint_picker_hashtag_top.constant = 12
        //self.constraint_picker_hashtag_height.constant = 30
        self.constraint_collection_SearchHash_Height.constant = 0
        self.arr_Added_Hashtags.append(strHashTag)
        self.collection_hashtag.reloadData()
        //self.collection_hashtag.scrollToItem(at: IndexPath.init(row: self.arr_Added_Hashtags.count - 1, section: 0), at: .centeredHorizontally, animated: true)
        self.view.endEditing(true)
        DispatchQueue.main.async {
            self.collection_hashtag.reloadData()
            self.view.layoutIfNeeded()
        }
    }
}

extension ARCreateFeedPostVC: ARFeedPostMediaCellDelegate {
    func feedPostMediaCell(cell: ARFeedPostMediaCell, didDeleteAt index: Int) {
        ARLog("Delete media at index : \(index)")
        self.arr_medias.remove(at: index)

        if self.arr_medias.count < 5 && !self.arr_medias.contains(where: { dicMMedia in
            return (dicMMedia["value"] as? UIImage) == #imageLiteral(resourceName: "add-image")
        }) {
            self.arr_medias.append(["type": "image", "value": #imageLiteral(resourceName: "add-image")])
        }

        if isEditingFeed {
            if let indxx = self.arr_editedMedias.firstIndex(where: { dicMMedia in
                let strType = self.arr_medias[index]["type"] as? String ?? ""
                if strType == "image" {
                    let strImageValue = self.arr_medias[index]["value"] as? UIImage
                    return strImageValue == (dicMMedia["value"] as? UIImage ?? #imageLiteral(resourceName: "add-image"))
                }
                else {
                    let strVideoValue = self.arr_medias[index]["value"] as? URL
                    return strVideoValue == (dicMMedia["value"] as? URL)
                }
            }) {
                self.arr_editedMedias.remove(at: indxx)
            }
            
            let strImageFile = imageFiles[index]
            imageFiles.remove(at: index)
            deletedFiles.append(strImageFile)
        }
        updateUI()
    }
}
extension ARCreateFeedPostVC: ARCategoryPickerViewDelegate {
    func categoryPickerView(view: ARCategoryPickerView, didSelect category: ARAyuverseCategoryModel) {
        if category.name == "All"{
            currentCategeory = "all"
        }else{
            currentCategeory = category.name!
        }
        
        print(">> selected category : ", category.name)
    }
}

extension ARCreateFeedPostVC: PDImagePickerDelegate {
    
    func imagePicker(_ imagePicker: PDImagePicker, didSelectImage image: UIImage?) {
        if let image = image {
            self.arr_medias.insert(["type" : "image", "value": image], at: 0)
            if isEditingFeed {
                self.arr_editedMedias.append(["type" : "image", "value": image])
            }
            if self.arr_medias.count == 6{
                self.arr_medias.remove(at: self.arr_medias.count - 1)
            }
            //medias.append(image)
            self.btn_Post.backgroundColor = kAppBlueColor
            updateUI()
        }
    }
    
    func imagePicker(_ imagePicker: PDImagePicker, didSelectMovie url: URL?) {
        if let strURL = url {
            let file_size = fileSize(forURL: strURL)
            if file_size <= 25.0 {
                getThumbnailImageFromVideoUrl(url: strURL) { image in
                    if let img = image {
                        self.arr_medias.insert(["type" : "video", "thumb": img, "value": strURL], at: 0)
                        if self.isEditingFeed {
                            self.arr_editedMedias.append(["type" : "video", "thumb": img, "value": strURL])
                        }
                        if self.arr_medias.count == 6 {
                            self.arr_medias.remove(at: self.arr_medias.count - 1)
                        }
                        self.btn_Post.backgroundColor = kAppBlueColor
                        self.updateUI()
                    }
                }
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    Utils.showAlertWithTitleInController(APP_NAME, message:  "Please select file below 25 mb.", controller: self)
                }
            }
        }
    }
    
    
    
    
    func callAPIforSearchHashTag(_ strText: String) {

        var strSearch_Text = strText
        if strSearch_Text.first == "#" {
            strSearch_Text = String(strSearch_Text.dropFirst())
        }
        let escapedString = strSearch_Text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

        let params = ["search_tag": escapedString ?? ""] as [String : Any]

        Utils.doAyuVerseAPICall(endPoint: .searchTag, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {

                let data_hashTag = try? JSONDecoder().decode(SearchHashTag.self, from: responseJSON.rawData())
                self?.arr_SearchedTag.removeAll()
                if let arr_Data = data_hashTag?.data {
                    self?.arr_SearchedTag = arr_Data
                }

                if self?.arr_SearchedTag.count == 0 {
                    self?.view_HashTagCollection_BG.isHidden = true
                    self?.constraint_collection_SearchHash_Height.constant = 0
                }
                else {
                    self?.view_HashTagCollection_BG.isHidden = false
                    self?.constraint_collection_SearchHash_Height.constant = 75
                }
                DispatchQueue.main.async {
                    self?.collection_SearchHash.reloadData()
                }
            }
            else {
                self?.arr_SearchedTag.removeAll()
                self?.view_HashTagCollection_BG.isHidden = true
                self?.constraint_collection_SearchHash_Height.constant = 0
                self?.collection_SearchHash.reloadData()
            }
        }
    }

}




