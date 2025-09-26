//
//  ARCreateGroupVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 18/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import SwiftyJSON
import MobileCoreServices
import AlignedCollectionViewFlowLayout

class ARCreateGroupVC: UIViewController {

    var isImageChange = false
    var is_EditGroupDetail = false
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var memberCountTF: UITextField!
    @IBOutlet weak var view_countBG: UIView!
    @IBOutlet weak var memberCountView: UIView!
    @IBOutlet weak var descTV: UITextView!
    @IBOutlet weak var categoryCountL: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var publicGroupBtn: UIButton!
    @IBOutlet weak var privateGroupBtn: UIButton!
    @IBOutlet weak var groupPicBtn: UIButton!
    @IBOutlet weak var stack_category_Title: UIStackView!

    @IBOutlet weak var lbl_whatWouldTitle: UILabel!
    @IBOutlet weak var lbl_groupPrivacyTitle: UILabel!
    @IBOutlet weak var lbl_addGroupIconTitle: UILabel!
    @IBOutlet weak var lbl_chooseCategoryTitle: UILabel!
    @IBOutlet weak var lbl_chooseCategoryMin1: UILabel!
    
    var dic_groupDetail: MyGroupData?
    var categories = [ARAyuverseCategoryModel]()
    var mediaPicker: PDImagePicker?
    var groupPic: UIImage?
    var groupType = "2"
    var groupLimit = ""
    var categeory = "Others"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.view_countBG.isHidden = true
        
        if self.is_EditGroupDetail {
            self.title = "Update Group".localized()
            self.postBtn.setTitle("Update".localized(), for: .normal)
            setupDetail()
        }
        else {
            self.title = "Create a Group".localized()
        }
        
        self.lbl_whatWouldTitle.text = "What would you like to call your group?".localized()
        self.nameTF.placeholder = "Add title for your group...".localized()
        self.lbl_groupPrivacyTitle.text = "Group privacy".localized()
        self.lbl_addGroupIconTitle.text = "Add your group icon here".localized()
        self.lbl_chooseCategoryTitle.text = "Choose category".localized()
        self.postBtn.setTitle("Create".localized(), for: .normal)
        self.publicGroupBtn.setTitle("Public".localized(), for: .normal)
        self.privateGroupBtn.setTitle("Private".localized(), for: .normal)
        self.memberCountTF.placeholder = "Type how many users you want to join...".localized()
    }
    
    func setupUI() {
        setBackButtonTitle()
        collectionView.register(nibWithCellClass: ARCategoryCell.self)
        nameTF.setLeftPaddingPoints(16)
        groupPicBtn.imageView?.contentMode = .scaleAspectFill
        descTV.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        descTV.placeholder = "Add a breif description about your group...".localized()
        
        if let alignedFlowLayout = collectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout {
            alignedFlowLayout.horizontalAlignment = .left
            alignedFlowLayout.verticalAlignment = .top
            alignedFlowLayout.minimumLineSpacing = 10
            alignedFlowLayout.minimumInteritemSpacing = 10
            self.collectionView.collectionViewLayout = alignedFlowLayout
        }
        
        ARAyuverseManager.shared.fetchCommonData { [weak self] in
            if ARAyuverseManager.shared.categories.count > 0 {
                if ARAyuverseManager.shared.categories.first?.name == "All" {
                    ARAyuverseManager.shared.categories.remove(at: 0)
                }
            }
            self?.categories = ARAyuverseManager.shared.categories
            self?.categories.append(ARAyuverseCategoryModel.init(fromJson: JSON.init(["id": "", "category_status": "", "category_name": "Others"])))
            self?.categories.forEach{ $0.isSelected = false }
            self?.categories.last?.isSelected = true
            self?.collectionView.reloadData()
        }
    }
    
    func setupDetail() {
        self.descTV.placeholder = ""
        self.stack_category_Title.isHidden = true
        groupType = self.dic_groupDetail?.groupType ?? ""
        groupLimit = self.dic_groupDetail?.groupMemberLimit ?? ""
        
        var strgroupName = self.dic_groupDetail?.groupLabel?.trimed().base64Decoded()
        if strgroupName == nil {
            strgroupName = self.dic_groupDetail?.groupLabel
        }
        self.nameTF.text = strgroupName
        
        var strgroupDesc = self.dic_groupDetail?.groupDescription?.trimed().base64Decoded()
        if strgroupDesc == nil {
            strgroupDesc = self.dic_groupDetail?.groupDescription
        }
        self.descTV.text = strgroupDesc

        self.categeory = self.dic_groupDetail?.groupCategories ?? ""
        
        self.categories.forEach{ $0.isSelected = false }
        if let indxx = self.categories.firstIndex(where: { dic_category in
            return dic_category.name == self.categeory
        }) {
            self.categories[indxx].isSelected = true
        }
        else {
            self.categories.last?.isSelected = true
        }
        
        var str_img_URL = self.dic_groupDetail?.groupImage ?? ""
        if str_img_URL == "" {
            self.groupPic = appImage.group_default_pic
            self.groupPicBtn.setImage(appImage.group_default_pic, for: .normal)
        }
        else {
            if !(str_img_URL.contains("https")) {
                str_img_URL = image_BaseURL + str_img_URL
            }

            self.groupPicBtn.sd_setImage(with: URL.init(string: str_img_URL), for: .normal, placeholderImage: appImage.group_default_pic, options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                self.groupPic = self.groupPicBtn.imageView?.image ?? appImage.group_default_pic
            }
        }
        
        if groupLimit == "" || groupLimit == "0" {
            groupLimit = "50"
        }
        
        
        if self.groupType == "1" {
            memberCountView.isHidden = false
            privateGroupBtn.isSelected = true
            privateGroupBtn.backgroundColor = .black
            publicGroupBtn.isSelected = false
            self.view_countBG.isHidden = false
            self.memberCountTF.text = self.dic_groupDetail?.groupMemberLimit ?? ""
            publicGroupBtn.backgroundColor = UIColor.fromHex(hexString: "EEEEEE")
        }
        else {
            self.memberCountTF.text = ""
            self.view_countBG.isHidden = true
            memberCountView.isHidden = true
            publicGroupBtn.isSelected = true
            publicGroupBtn.backgroundColor = .black
            privateGroupBtn.isSelected = false
            privateGroupBtn.backgroundColor = UIColor.fromHex(hexString: "EEEEEE")
        }
        self.collectionView.reloadData()
    }
    
    func showMediaPicker() {
        if mediaPicker == nil {
            mediaPicker = PDImagePicker(presentingVC: self, delegate: self, mediaTypes: [.image], allowsEditing: true)
        }
        mediaPicker?.present()
    }
    
    @IBAction func btn_staticMemberCount_Action(_ sender: UIButton) {
        self.groupLimit = "\(sender.tag)"
        self.memberCountTF.text = "\(sender.tag)"
    }
    
    @IBAction func postBtnPressed(sender: UIButton) {
        var msg = ""
        var is_Validation = false
        if nameTF.text == "" {
            is_Validation = true
            msg = "Please enter group name.".localized()
        }
        else if descTV.text == "" {
            is_Validation = true
            msg = "Please enter description.".localized()
        }
//        else if groupPic == nil {
//            is_Validation = true
//            msg = "Please select group icon."
//        }
        
        if is_Validation {
            let alert = UIAlertController(title: "Error".localized(), message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
            self.present(alert, animated: true)
        }
        else {
            if groupType == "1" {
                if memberCountTF.text == ""{
                    groupLimit = "50"
                }else{
                    groupLimit = memberCountTF.text ?? "50"
                }
            }
            createGroup()
        }
    }
    
    @IBAction func addPhotoBtnPressed(sender: UIButton) {
        showMediaPicker()
    }
    
    @IBAction func groupPrivacyBtnPressed(sender: UIButton) {
        sender.backgroundColor = .black
        sender.isSelected = true
        if sender == privateGroupBtn {
            publicGroupBtn.backgroundColor = UIColor.fromHex(hexString: "EEEEEE")
            publicGroupBtn.isSelected = false
            memberCountView.isHidden = false
            groupType = "1"
            groupLimit = "50"
            self.view_countBG.isHidden = false
        } else {
            self.view_countBG.isHidden = true
            privateGroupBtn.backgroundColor = UIColor.fromHex(hexString: "EEEEEE")
            privateGroupBtn.isSelected = false
            memberCountView.isHidden = true
            groupType = "2"
            groupLimit = ""
        }
    }
    
    func createGroup(){
        Utils.startActivityIndicatorInView(self.view, userInteraction: false)
        var urlString = kBaseNewURL + endPoint.createGroup.rawValue
        
        if self.is_EditGroupDetail {
            urlString = kBaseNewURL + endPoint.EditGroup.rawValue
        }
        
        AF.upload(multipartFormData: { (multipartFormData) in

            var params = ["group_type" : self.groupType,
                          "group_label": (self.nameTF.text ?? "").base64Encoded() ?? "",
                          "group_member_limit" : self.groupLimit,
                          "group_description": (self.descTV.text ?? "").base64Encoded() ?? "",
                          "group_user_id": kSharedAppDelegate.userId] as [String : Any]

            if self.is_EditGroupDetail {
                params["group_id"] = self.dic_groupDetail?.groupID ?? ""
            }
            else {
                params["group_categories"] = self.categeory
            }

            for (key, value) in params {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            if self.groupPic != nil {
                if self.isImageChange {
                    guard let imgData = self.groupPic?.jpegData(compressionQuality: 0.7) else { return }
                       let timestamp = NSDate().timeIntervalSince1970
                        multipartFormData.append(imgData, withName: "group_image", fileName: String(timestamp) + ".jpeg", mimeType: "image/jpeg")
                }
            }

        },to: URL.init(string: urlString)!, usingThreshold: UInt64.init(), method: .post, headers: Utils.apiCallHeaders).response{ response in
            
            if((response.error == nil)){
                do{
                    if let jsonData = response.data {
                        
                        if self.is_EditGroupDetail {
                            
                            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
                            if let dictFromJSON = decoded as? [String: Any] {
                                debugPrint(dictFromJSON)
                                let strStatus = dictFromJSON["status"] as? String ?? ""
                                let strMessage = dictFromJSON["message"] as? String ?? ""
                                if strStatus == "success" {
                                    if let dic_Data = dictFromJSON["data"] as? [String: Any] {
                                        
                                        var strgroupName = (dic_Data["group_label"] as? String ?? "").trimed().base64Decoded()
                                        if strgroupName == nil {
                                            strgroupName = dic_Data["group_label"] as? String ?? ""
                                        }
                                        self.dic_groupDetail?.groupLabel = strgroupName
                                        
                                        var str_groupDesc = (dic_Data["group_description"] as? String ?? "").trimed().base64Decoded()
                                        if str_groupDesc == nil {
                                            str_groupDesc = dic_Data["group_description"] as? String ?? ""
                                        }
                                        self.dic_groupDetail?.groupDescription = str_groupDesc
                                        
                                        self.dic_groupDetail?.groupCategories = dic_Data["group_categories"] as? String ?? ""
                                        
                                        if self.isImageChange {
                                            self.dic_groupDetail?.groupImage = dic_Data["group_image"] as? String ?? ""
                                        }

                                        self.dic_groupDetail?.groupMemberLimit = dic_Data["group_member_limit"] as? String ?? ""
                                        self.dic_groupDetail?.groupType = dic_Data["group_type"] as? String ?? ""
                                    }
                                    
                                    let alert = UIAlertController(title: "", message: strMessage, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction.init(title: "Ok".localized(), style: .default, handler: { actionnnn in
                                        
                                        var is_FindVC = false
                                        
                                        if let stackVCs = self.navigationController?.viewControllers {

                                            if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupViewAllVC.self }) {
                                                (activeSubVC as? ARGroupViewAllVC)?.pageNO = 0
                                                (activeSubVC as? ARGroupViewAllVC)?.getMyGroupList(false)
                                            }

                                            if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupSettingVC.self }) {
                                                is_FindVC = true
                                                (activeSubVC as? ARGroupSettingVC)?.myGroup = self.dic_groupDetail
                                                (activeSubVC as? ARGroupSettingVC)?.setupUI_MyGroup()
                                                self.navigationController?.popToViewController(activeSubVC, animated: false)
                                            }
                                        }

                                        
                                        if let stackVCs = self.navigationController?.viewControllers {

                                            if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupViewAllVC.self }) {
                                                (activeSubVC as? ARGroupViewAllVC)?.pageNO = 0
                                                (activeSubVC as? ARGroupViewAllVC)?.getMyGroupList(false)
                                            }

                                            if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARMyGroupDetailVC.self }) {
                                                (activeSubVC as? ARMyGroupDetailVC)?.group =
                                                self.dic_groupDetail
                                                (activeSubVC as? ARMyGroupDetailVC)?.groupDetailView.updateUI(from: self.dic_groupDetail!)

                                                if is_FindVC == false {
                                                    is_FindVC = true
                                                    self.navigationController?.popToViewController(activeSubVC, animated: false)
                                                }
                                            }
                                        }

                                        if is_FindVC == false {
                                            if let stackVCs = self.navigationController?.viewControllers {
                                                if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARAyuverseHomeVC.self }) {
                                                    is_FindVC = true
                                                    self.navigationController?.popToViewController(activeSubVC, animated: false)
                                                }
                                            }
                                        }
                                        
                                        if is_FindVC == false {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }))
                                    self.present(alert, animated: true)
                                }
                                else{
                                    let alert = UIAlertController(title: "Error".localized(), message: strMessage, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                                    self.present(alert, animated: true)
                                }
                            }
                        }
                        else {
                            let createGroup = try? JSONDecoder().decode(CreateGroup.self, from: jsonData)
                            if createGroup?.status == "success" {
                                self.navigationController?.popViewController(animated: true)
                            }else{
                                let alert = UIAlertController(title: "Error".localized(), message: createGroup?.message, preferredStyle: .alert)
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
    
    
    
}


extension ARCreateGroupVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = categories[indexPath.row]
        return CGSize(width: category.textWidth + 32, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ARCategoryCell.self, for: indexPath)
        cell.selectionBGColor = .black
        cell.category = categories[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //categories.forEach{ $0.isSelected = false }
        let category = categories[indexPath.row]
        self.categeory = category.name
        category.isSelected.toggle()
        collectionView.reloadData()
    }
}

extension ARCreateGroupVC: PDImagePickerDelegate {
    func imagePicker(_ imagePicker: PDImagePicker, didSelectImage image: UIImage?) {
        groupPic = image
        self.isImageChange = true
        groupPicBtn.setImage(image, for: .normal)
    }
}
