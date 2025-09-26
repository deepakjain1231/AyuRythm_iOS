//
//  ARGroupRequestVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 19/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import SDWebImage

class ARGroupRequestVC: UIViewController {

    @IBOutlet weak var adminProfileView: ARUserProfileView!
    
    @IBOutlet weak var groupIconIV: UIImageView!
    var group: GroupData?
    var myGroup: MyGroupData?
    var from = "group"
    
    @IBOutlet weak var groupNameL: UILabel!
    @IBOutlet weak var memberL: UILabel!
    @IBOutlet weak var privacyType: UILabel!
    @IBOutlet weak var privacyTitle: UILabel!
    @IBOutlet weak var aboutL: UILabel!
    @IBOutlet weak var groupStatusL: UILabel!
    @IBOutlet weak var rulesL: UILabel!
    @IBOutlet weak var lbl_rulesTitle: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var canceLRequestBtn: UIButton!
    @IBOutlet weak var requestedBtn: UIButton!
    @IBOutlet weak var lbl_aboutTitle: UILabel!
    @IBOutlet weak var lbl_adminTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rulesL.text = ""
        self.title = "Groups".localized()
        self.privacyTitle.text = "Privacy".localized()
        self.canceLRequestBtn.setTitle("Cancel request".localized(), for: .normal)
        self.requestedBtn.setTitle("Requested".localized(), for: .normal)
        self.lbl_rulesTitle.text = "Rules".localized()
        self.lbl_aboutTitle.text = "About".localized()
        self.lbl_adminTitle.text = "Admin".localized()
        setBackButtonTitle()
        setupUI()
    }
    
    func setupUI() {
        adminProfileView.updateUI(for: .groupAdmin)
        adminProfileView.profilePicIV.af_setImage(withURLString: group?.userProfile?.userProfile)
        adminProfileView.usernameL.text = group?.userProfile?.userName
        //adminProfileView. = (group.groupMembers ?? "0") + " " + "Members"
        
        var strgroupName = group?.groupLabel?.trimed().base64Decoded()?.capitalized
        if strgroupName == nil {
            strgroupName = group?.groupLabel?.capitalized
        }
        groupNameL.text = strgroupName
        
        
        memberL.text = (group?.groupMembers ?? "0") + " " + "Members".localized()
        if (group?.groupMembers ?? "0") == "1" || (group?.groupMembers ?? "0") == "0" {
            memberL.text = (group?.groupMembers ?? "0") + " " + "Member".localized()
        }
        
        var str_img_URL = self.group?.groupImage ?? ""
        if str_img_URL == "" {
            groupIconIV.image = appImage.group_default_pic
        }
        else {
            if !(str_img_URL.contains("https")) {
                str_img_URL = image_BaseURL + str_img_URL
            }
            groupIconIV.sd_setImage(with: URL.init(string: str_img_URL), placeholderImage: appImage.group_default_pic, options: SDWebImageOptions.refreshCached, progress: nil, completed: nil)
        }
        
        if group?.groupType == "1"{
            privacyType.text = "Private".localized()
            self.joinBtn.setTitle("Requested to join".localized(), for: .normal)
        }else{
            privacyType.text = "Public".localized()
            self.joinBtn.setTitle("Join".localized(), for: .normal)
        }
        
        
        var strgroupDesc = self.group?.groupDescription?.trimed().base64Decoded()
        if strgroupDesc == nil {
            strgroupDesc = self.group?.groupDescription
        }
        self.aboutL.text = strgroupDesc
        
        let groupMember = Int(group?.groupMembers ?? "0")
        let limit = Int(group?.groupMemberLimit ?? "0")
        if limit! > groupMember!{
            groupStatusL.isHidden = true
        }else{
            if group?.groupType == "1" {
                groupStatusL.isHidden = false
            }
            else {
                groupStatusL.isHidden = true
            }
        }
        if group?.joinedGroupOrNot == 3{
            joinBtn.isHidden = false
            canceLRequestBtn.isHidden = true
            requestedBtn.isHidden = true
        }else if group?.joinedGroupOrNot == 2{
            canceLRequestBtn.isHidden = false
            requestedBtn.isHidden = false
            joinBtn.isHidden = true
        }else{
            canceLRequestBtn.isHidden = true
            requestedBtn.isHidden = true
            joinBtn.isHidden = true
        }
        getGroupRules()
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(TapResponce(_:)))
        groupIconIV.isUserInteractionEnabled = true
        groupIconIV.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func TapResponce(_ sender: UITapGestureRecognizer) {
        SMPhotoViewer.showImage(toView: self, image: groupIconIV.image!, fromView: groupIconIV)
    }
    
    func getGroupRules(){
        let params = ["group_id": group?.groupID ?? ""] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .fetchGroupRules, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let groupRules = try? JSONDecoder().decode(GroupRules.self, from: responseJSON.rawData())
                if groupRules?.status == "success"{
                    var rules = ""
                    for rule in groupRules!.data!{
                        rules = rules + String(rule.number ?? 0) + ". " + (rule.rule ?? "") + "\n\n"
                    }
                    
//                    //Set Attribut Text
//                    let newText = NSMutableAttributedString.init(string: rules)
//                    let paragraphStyle = NSMutableParagraphStyle()
//                    paragraphStyle.lineSpacing = 10 // Whatever line spacing you want in points
//
//                    newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
//
//                    self?.rulesL.attributedText = newText
                    self?.rulesL.text = rules.localized()
                }else{
                    let alert = UIAlertController(title: "Error".localized(), message: groupRules?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
                }
                self?.hideActivityIndicator()
            } else {
                self?.hideActivityIndicator(withMessage: message)
            }
        }
    }
    func joinGroup(groupId: String){
        self.showActivityIndicator()
        
        let params = ["group_id": groupId] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .joinAGroup, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                self?.hideActivityIndicator()
                let joinGroup = try? JSONDecoder().decode(JoinGroup.self, from: responseJSON.rawData())
                if joinGroup?.status == "success"{
                    if self?.group?.groupType == "2" {
                    }
                    else {
                        self?.canceLRequestBtn.isHidden = false
                        self?.requestedBtn.isHidden = false
                        self?.joinBtn.isHidden = true
                    }
                    let alert = UIAlertController(title: "Success".localized(), message: joinGroup?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "Ok".localized(), style: .default, handler: { avtionnn in
                        
                        if self?.group?.groupType == "1" {

                            if let stackVCs = self?.navigationController?.viewControllers {
                                if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupViewAllVC.self }) {
                                    (activeSubVC as? ARGroupViewAllVC)?.setupUI()
                                }
                            }

                        }
                        else if self?.group?.groupType == "2" {

                            var is_FindVC = false
                            if let stackVCs = self?.navigationController?.viewControllers {
                                if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupViewAllVC.self }) {
                                    is_FindVC = true
                                    (activeSubVC as? ARGroupViewAllVC)?.setupUI()
                                    self?.navigationController?.popToViewController(activeSubVC, animated: false)
                                }
                            }
                            
                            if is_FindVC == false {
                                self?.navigationController?.popViewController(animated: true)
                            }

                        }
                    }))
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
    func leaveGroup(){
        let params = ["group_id": group?.groupID ?? ""] as [String : Any]
        Utils.doAyuVerseAPICall(endPoint: .leaveAGroup, parameters: params,  headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let acceptData = try? JSONDecoder().decode(LikeQAModel.self, from: responseJSON.rawData())
                if acceptData?.status == "success"{
                    
                    if let stackVCs = self?.navigationController?.viewControllers {
                        if let activeSubVC = stackVCs.first(where: { type(of: $0) == ARGroupViewAllVC.self }) {
                            (activeSubVC as? ARGroupViewAllVC)?.setupUI()
                        }
                    }
                    

                    self?.joinBtn.isHidden = false
                    self?.canceLRequestBtn.isHidden = true
                    self?.requestedBtn.isHidden = true
                    let alert = UIAlertController(title: "Success".localized(), message: acceptData?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default))
                    self?.present(alert, animated: true)
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
    @IBAction func joinBtnAct(_ sender: UIButton) {
        joinGroup(groupId: group?.groupID ?? "")
    }
    @IBAction func cancelRequestBtnAct(_ sender: UIButton) {
        leaveGroup()
    }
    @IBAction func requestedBtnAct(_ sender: UIButton) {
    }
}
